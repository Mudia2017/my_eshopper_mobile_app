import 'dart:convert';

import 'package:eshopper_mobile_app/componets/data_computation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class EditMyOrder extends StatefulWidget {
  final String orderNo, token;
  EditMyOrder({required this.orderNo, required this.token});
  @override
  _EditMyOrderState createState() => _EditMyOrderState();
}

class _EditMyOrderState extends State<EditMyOrder> {
  @override
  void initState() {
    super.initState();

    getCustomerDetailOrder('');
  }

  bool isDoneLoading = false;
  List myOrderItemData = [];
  var userInfo = {};
  double grandTotal = 0;
  String selectedValue = "----";
  String myOrderNote = '';

  // ===== API USED TO GET CUSTOMER ORDER DETAIL ==========
  getCustomerDetailOrder(updateShippingInfo) async {
    var data = {
      'order_no': widget.orderNo,
      'updateShippingInfo': updateShippingInfo,
    };
    var response = await http.post(
      Uri.parse(
          'http://192.168.43.50:8000/apis/v1/homePage/api_updateMyOrder/'),
      body: jsonEncode(data),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Token ${widget.token}",
      },
    );

    try {
      if (response.statusCode == 200) {
        var myOrder = json.decode(response.body);
        setState(() {
          myOrderItemData = myOrder['orderItemData'];
          userInfo = myOrder['order_obj'];
          if (myOrder['grandTotal'] != 0) {
            grandTotal = double.parse(myOrder['grandTotal']);
          }
        });
        if ('${userInfo['private_note']}'.isEmpty ||
            '${userInfo['private_note']}' == 'null') {
          myOrderNote = '';
        } else {
          myOrderNote = '${userInfo['private_note']}';
        }
      }
      isDoneLoading = true;
    } catch (error) {
      isDoneLoading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    var serviceProvider = Provider.of<DataProcessing>(context);
    // THIS CONDITION IS PLACE TO UPDATE ORDER ITEMS ONCE ANY
    // ACTION IS MADE
    if (serviceProvider.isAdminUpdatedRecord == true &&
        isDoneLoading == false) {
      userInfo = serviceProvider.adminDetailOrderHeader;
      myOrderItemData = serviceProvider.adminOrderItemData;
      grandTotal = serviceProvider.adminUpdateOrderGrandTotal;
    } else {
      isDoneLoading = false;
      serviceProvider.isAdminUpdatedRecord = false;
    }
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [
            Color(0xFF40C4FF),
            Color(0xFFA7FFEB),
          ])),
        ),
        title: titleSection(),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF40C4FF),
              Color(0xFFA7FFEB),
            ],
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          firstHeaderSection(
                            '${userInfo['order_date']}',
                            '${userInfo['address']}',
                            '${userInfo['city']}',
                            '${userInfo['state']}',
                            '${userInfo['mobile']}',
                            '${userInfo['altMobile']}',
                            '${userInfo['user_name']}',
                            '${userInfo['user_email']}',
                            '${userInfo['date_joined']}',
                            '${userInfo['last_login']}',
                            '${userInfo['status']}',
                          ),
                          secondHeaderSection(
                            '${userInfo['status']}',
                            '${userInfo['address']}',
                            '${userInfo['city']}',
                            '${userInfo['state']}',
                            '${userInfo['mobile']}',
                            '${userInfo['altMobile']}',
                            '${userInfo['optional_note']}',
                          )
                        ],
                      )
                    ],
                  ),
                ),
                Expanded(
                    flex: 1,
                    child: thirdHeaderSection(
                      '${userInfo['status']}',
                      '${userInfo['payment_option']}',
                    ))
              ],
            ),
            const Divider(
              height: 12,
              thickness: 2,
              color: Color(0xFF757575),
            ),
            detailHeader(),
            const Divider(
              color: Colors.black,
              height: 10,
              thickness: 0.5,
            ),
            Flexible(
              child: myOrderItemData.isNotEmpty
                  ? ListView.builder(
                      itemCount: myOrderItemData.length,
                      itemBuilder: (BuildContext cxt, int x) => detailContent(
                        myOrderItemData.toList()[x]['itemRowId'].toString(),
                        myOrderItemData.toList()[x]['ptdImage'].toString(),
                        myOrderItemData.toList()[x]['ptdName'].toString(),
                        myOrderItemData.toList()[x]['price'].toString(),
                        myOrderItemData.toList()[x]['qty'].toString(),
                        myOrderItemData.toList()[x]['lineTotal'].toString(),
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (myOrderItemData.isEmpty && isDoneLoading == true)
                          Flexible(
                            child: Center(
                              child: Text(
                                'No record!',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.red.shade200,
                                ),
                              ),
                            ),
                          ),
                        if (isDoneLoading == false) CircularProgressIndicator(),
                      ],
                    ),
            ),
            contentBottom(grandTotal),
          ],
        ),
      ),
    );
  }

  // CONTROLLER AND SHOW DIALOG ALERT USED TO WRITE REASON FOR CLOSING AN ORDER
  TextEditingController textfieldControllerCloseOrderNote =
      TextEditingController();
  _dialogFormCloseOrderNote(BuildContext, context) async {
    final _formKey = GlobalKey<FormState>();
    var serviceProvider = Provider.of<DataProcessing>(context, listen: false);

    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            scrollable: true,
            title: Center(
              child: Text(
                'Private Note',
                style: GoogleFonts.sora().copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            content: Form(
              key: _formKey,
              child: Column(
                children: [
                  if (myOrderNote != '')
                    TextFormField(
                      controller: textfieldControllerCloseOrderNote,
                      keyboardType: TextInputType.multiline,
                      maxLines: 7,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Reason to Close an Order',
                        hintText: 'Your reason for closing this order',
                        hintStyle: GoogleFonts.sora().copyWith(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please give reason for closing this order!';
                        }
                        return null;
                      },
                    ),
                  if (myOrderNote == '')
                    TextFormField(
                      controller: textfieldControllerCloseOrderNote,
                      keyboardType: TextInputType.multiline,
                      maxLines: 7,
                      decoration: InputDecoration(
                        labelText: 'Reason to Close an Order',
                        hintText: 'Your reason for closing this order',
                        hintStyle: GoogleFonts.sora().copyWith(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please give reason for closing this order!';
                        }
                        return null;
                      },
                    ),
                ],
              ),
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            Colors.grey.shade700)),
                  ),
                  if (myOrderNote != '')
                    ElevatedButton(
                      onPressed: null,
                      child: const Text('Ok'),
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Colors.orange.shade100)),
                    ),
                  if (myOrderNote == '')
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          // IF COMPLUSORY FIELDS ARE VALID, THE INPUT DATA
                          // IS COLLECTED ELSE RAISE AN INVALID FIELD

                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Ok'),
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.orange)),
                    ),
                ],
              )
            ],
          );
        });
  }

  List<DropdownMenuItem<String>> get dropdownItems {
    List<DropdownMenuItem<String>> menuItems = [
      const DropdownMenuItem(
          child: Text(
            "Select Status",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          value: "----"),
      const DropdownMenuItem(
          child: Text(
            "Cancelled",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          value: "cancelled"),
      const DropdownMenuItem(
          child: Text(
            "Rejected",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          value: "rejected"),
    ];
    return menuItems;
  }

  Container dropdownMenu() {
    return Container(
      child: DropdownButton(
        value: selectedValue,
        onChanged: (String? newValue) {
          setState(() {
            selectedValue = newValue!;
            if (newValue == 'cancelled' || newValue == 'rejected') {
              // POP A DIALOG BOX FOR ADMIN TO GIVE REASON FOR CLOSING AN ORDER
              _dialogFormCloseOrderNote(BuildContext, context);
            }
          });
        },
        items: dropdownItems,
      ),
    );
  }

  Container disabledDropDownMenu() {
    return Container(
      child: DropdownButton(
        onChanged: null,
        value: selectedValue,
        items: dropdownItems,
      ),
    );
  }

  shippingInfo(address, city, state, mobile, altMobile) {
    var updateShipAddress = {
      "address": address,
      "city": city,
      "state": state,
      "mobile": mobile,
      "altMobile": altMobile,
    };
    return updateShipAddress;
  }

  // THIS CONTROLLERS AND SHOW DIALOG ALERT IS USED TO EDIT SHIPPING ADDRESS
  TextEditingController textfieldControllerAddress = TextEditingController();
  TextEditingController textfieldControllerCity = TextEditingController();
  TextEditingController textfieldControllerState = TextEditingController();
  TextEditingController textfieldControllerMobile = TextEditingController();
  TextEditingController textfieldControllerAltMobile = TextEditingController();
  TextEditingController textfieldControllerOptionalNote =
      TextEditingController();

  _displayDialog_editShippingAdd(BuildContext context) async {
    var serviceProvider = Provider.of<DataProcessing>(context, listen: false);

    textfieldControllerAddress = TextEditingController(
        text: '${userInfo['address']}'.toString() == 'null'
            ? ''
            : '${userInfo['address']}'.toString());
    textfieldControllerCity = TextEditingController(
        text: '${userInfo['city']}'.toString() == 'null'
            ? ''
            : '${userInfo['city']}'.toString());
    textfieldControllerState = TextEditingController(
        text: '${userInfo['state']}'.toString() == 'null'
            ? ''
            : '${userInfo['state']}'.toString());
    textfieldControllerMobile = TextEditingController(
        text: '${userInfo['mobile']}'.toString() == 'null'
            ? ''
            : '${userInfo['mobile']}'.toString());
    textfieldControllerAltMobile = TextEditingController(
        text: '${userInfo['altMobile']}'.toString() == 'null'
            ? ''
            : '${userInfo['altMobile']}'.toString());

    final _formKey = GlobalKey<FormState>();

    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            scrollable: true,
            title: Text(
              'Edit shipping address',
              style: GoogleFonts.sora().copyWith(fontWeight: FontWeight.bold),
            ),
            content: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // TEXT-FORM-FIELD FOR ADDRESS
                  TextFormField(
                    maxLines: null,
                    controller: textfieldControllerAddress,
                    keyboardType: TextInputType.streetAddress,
                    decoration: InputDecoration(
                      labelText: 'Address',
                      hintText: 'Shipping address',
                      hintStyle: GoogleFonts.sora().copyWith(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter shipping address';
                      }
                      return null;
                    },
                  ),

                  // TEXT-FORM-FIELD FOR CITY
                  TextFormField(
                    maxLines: null,
                    controller: textfieldControllerCity,
                    keyboardType: TextInputType.streetAddress,
                    decoration: InputDecoration(
                      labelText: 'City',
                      hintText: 'City',
                      hintStyle: GoogleFonts.sora().copyWith(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter city name';
                      }
                      return null;
                    },
                  ),

                  // TEXT-FORM-FIELD FOR STATE
                  TextFormField(
                    maxLines: null,
                    controller: textfieldControllerState,
                    keyboardType: TextInputType.streetAddress,
                    decoration: InputDecoration(
                      labelText: 'State',
                      hintText: 'State',
                      hintStyle: GoogleFonts.sora().copyWith(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter state name';
                      }
                      return null;
                    },
                  ),

                  // TEXT-FORM-FIELD FOR MOBILE
                  TextFormField(
                    maxLines: null,
                    controller: textfieldControllerMobile,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Mobile',
                      hintText: 'Mobile',
                      hintStyle: GoogleFonts.sora().copyWith(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter mobile number';
                      }
                      return null;
                    },
                  ),

                  // TEXT-FORM-FIELD FOR ALT-MOBILE
                  TextFormField(
                    maxLines: null,
                    controller: textfieldControllerAltMobile,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Home phone',
                      hintText: 'Home',
                      hintStyle: GoogleFonts.sora().copyWith(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.grey)),
                  ),
                  ElevatedButton(
                    child: const Text('Update'),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        // IF ALL COMPLUSORY FIELDS ARE VALID, UPDATE SHIPPING
                        // INFOMATION, ELSE THE VALIDATOR WILL RAISE AN ERROR
                        // ON INVALID FIELD.

                        // CALL THE DIALOG TO PREVENT USER FROM THE UI UNTIL DATA IS SAVED TO THE SERVER
                        setState(() {
                          serviceProvider.isLoadDialogBox = true;
                          serviceProvider.buildShowDialog(context);
                        });
                        await getCustomerDetailOrder(
                          shippingInfo(
                              textfieldControllerAddress.text,
                              textfieldControllerCity.text,
                              textfieldControllerState.text,
                              textfieldControllerMobile.text,
                              textfieldControllerAltMobile.text),
                        );

                        // CALL THE DIALOG TO ALLOW USER PERFORM OPERATION ON THE UI

                        serviceProvider.isLoadDialogBox = false;
                        serviceProvider.buildShowDialog(context);

                        setState(() {
                          userInfo['address'] = textfieldControllerAddress.text;
                          userInfo['city'] = textfieldControllerCity.text;
                          userInfo['state'] = textfieldControllerState.text;
                          userInfo['mobile'] = textfieldControllerMobile.text;
                          userInfo['altMobile'] =
                              textfieldControllerAltMobile.text;
                        });
                        Navigator.pop(context);

                        // ScaffoldMessenger.of(context).showSnackBar(
                        //   const SnackBar(content: Text('Processing Data')),
                        // );
                      }
                    },
                  )
                ],
              )
            ],
          );
        });
  }

  Container titleSection() {
    return Container(
      margin: const EdgeInsets.all(0.0),
      child: Text("Edit My Order: " + widget.orderNo,
          style: const TextStyle(
              color: Colors.black,
              fontSize: 16.0,
              fontWeight: FontWeight.bold)),
    );
  }

  // ========= FIRST COLUMN OF THE HEADER SECTION =======
  Container firstHeaderSection(String orderDate, address, city, state, mobile,
      altMobile, userName, userEmail, joinDate, lastLoginDate, status) {
    var serviceProvider = Provider.of<DataProcessing>(context);
    return Container(
        child: Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Status: ',
                style: GoogleFonts.sora()
                    .copyWith(fontSize: 12, fontWeight: FontWeight.bold),
              ),

              // USING THE IF STATEMENT TO KNOW WHICH COLOR BACKGROUND WILL
              // DISPLAY ON THE STATUS
              if (status == 'Completed')
                Expanded(
                  child: Text(
                    ' $status ',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                      backgroundColor: Colors.green.shade900,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              if (status == 'Processing')
                Expanded(
                  child: Text(
                    ' $status ',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                      backgroundColor: Colors.blue.shade900,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              if (status == 'On hold')
                Expanded(
                  child: Text(
                    ' $status ',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                      backgroundColor: Colors.orange.shade900,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              if (status == 'Shipped')
                Expanded(
                  child: Text(
                    ' $status ',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                      backgroundColor: Colors.purple.shade900,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              if (status == 'Cancelled' ||
                  status == 'Refunded' ||
                  status == 'Failed' ||
                  status == 'Rejected')
                Expanded(
                  child: Text(
                    ' $status ',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                      backgroundColor: Colors.red.shade900,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(
            height: 8,
          ),
          if ('${userInfo['refund_status']}'.isNotEmpty &&
              '${userInfo['refund_status']}' != 'null')
            Row(
              children: [
                Text(
                  'Refund Status:',
                  style: GoogleFonts.sora()
                      .copyWith(fontSize: 9, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  width: 3,
                ),
                Expanded(
                  child: Text(
                    '${userInfo['refund_status']}',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: TextStyle(
                      color: Colors.red.shade800,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          Text(
            'Order',
            style: GoogleFonts.sora().copyWith(
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              Text(
                'Order date:',
                style: GoogleFonts.sora().copyWith(
                  fontSize: 10,
                ),
              ),
              Expanded(
                child: Text(
                  orderDate,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: GoogleFonts.sora().copyWith(fontSize: 10),
                ),
              )
            ],
          ),
          const SizedBox(
            height: 8,
          ),
          InkWell(
            child: Text(
              'Bill to:',
              style: GoogleFonts.sora().copyWith(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
              ),
            ),
            onTap: () {
              serviceProvider.popDialogMsg(context, 'Bill to address',
                  '$address\n$city\n$state\n$mobile\n$altMobile');
            },
          ),
          const SizedBox(
            height: 8,
          ),
          if (joinDate != '')
            InkWell(
              child: Text(
                'Customer Profile',
                style: GoogleFonts.sora().copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              onTap: () {
                serviceProvider.popDialogMsg(context, 'Customer Profile',
                    'Username: $userName\nEmail: $userEmail\nDate Join: $joinDate\nLast Login: $lastLoginDate');
              },
            ),
          if (joinDate == '')
            InkWell(
              child: Text(
                'Guest Profile',
                style: GoogleFonts.sora().copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              onTap: () {
                serviceProvider.popDialogMsg(context, 'Guest Profile',
                    'Username: $userName\nEmail: $userEmail\nDate Join: $joinDate\nLast Login: $lastLoginDate');
              },
            ),
        ],
      ),
    ));
  }

  // ========= SECOND COLUMN OF THE HEADER SECTION =======
  Container secondHeaderSection(
      String status, address, city, state, mobile, altMobile, optionalNote) {
    var serviceProvider = Provider.of<DataProcessing>(context);
    return Container(
        child: Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Shipping',
                style: GoogleFonts.sora().copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // CHECKING THE ORDER STATUS TO DETERMIN IF EDIT SHIPPING PEN
              // CAN BE ACTIVE OR INACTIVE
              if (status == 'Completed')
                IconButton(
                  onPressed: () {
                    serviceProvider.warningToastMassage(
                        'Inactive pen. Order have been completed!');
                  },
                  icon: const Icon(
                    Icons.edit_outlined,
                    color: Colors.grey,
                  ),
                ),
              if (status == 'Processing')
                IconButton(
                  onPressed: () {
                    _displayDialog_editShippingAdd(context);
                  },
                  icon: const Icon(
                    Icons.edit_outlined,
                    color: Color(0xFF2962FF),
                  ),
                ),
              if (status == 'On hold')
                IconButton(
                  onPressed: () {
                    _displayDialog_editShippingAdd(context);
                  },
                  icon: const Icon(
                    Icons.edit_outlined,
                    color: Color(0xFF2962FF),
                  ),
                ),
              if (status == 'Shipped')
                IconButton(
                  onPressed: () {
                    serviceProvider.warningToastMassage(
                        'Inactive pen. Item have been shipped!');
                  },
                  icon: const Icon(
                    Icons.edit_outlined,
                    color: Colors.grey,
                  ),
                ),
              if (status == 'Cancelled' ||
                  status == 'Refunded' ||
                  status == 'Failed' ||
                  status == 'Rejected')
                IconButton(
                  onPressed: () {
                    serviceProvider.warningToastMassage('Inactive pen!');
                  },
                  icon: const Icon(
                    Icons.edit_outlined,
                    color: Colors.grey,
                  ),
                ),
            ],
          ),
          Text(
            address,
            style: GoogleFonts.sora().copyWith(fontSize: 10),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
          Text(
            city,
            style: GoogleFonts.sora().copyWith(fontSize: 10),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
          Text(
            state,
            style: GoogleFonts.sora().copyWith(fontSize: 10),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
          Text(
            mobile,
            style: GoogleFonts.sora().copyWith(fontSize: 10),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
          Text(
            altMobile,
            style: GoogleFonts.sora().copyWith(fontSize: 10),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
          const SizedBox(
            height: 1,
          ),
          Text(
            'Customer Provided Note:',
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: GoogleFonts.sora().copyWith(
              fontSize: 8,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            optionalNote,
            style: GoogleFonts.sora().copyWith(fontSize: 10),
            overflow: TextOverflow.ellipsis,
            maxLines: 3,
          ),
        ],
      ),
    ));
  }

  // ========= THIRD COLUMN OF THE HEADER SECTION =======
  Container thirdHeaderSection(status, paymentOption) {
    var serviceProvider = Provider.of<DataProcessing>(context);
    return Container(
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Pay Method: ',
                style: GoogleFonts.sora().copyWith(
                  fontSize: 10,
                ),
              ),
              Expanded(
                child: Text(
                  paymentOption,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: GoogleFonts.sora().copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              )
            ],
          ),
          if (status == 'Processing' || status == 'On hold') dropdownMenu(),
          if (status == 'Shipped' ||
              status == 'Cancelled' ||
              status == 'Refunded' ||
              status == 'Failed' ||
              status == 'Rejected' ||
              status == 'Completed')
            disabledDropDownMenu(),

          // DISPLAY NOTE FIELD
          if (myOrderNote != '')
            OutlinedButton(
              onPressed: () {
                textfieldControllerCloseOrderNote.text = myOrderNote;
                _dialogFormCloseOrderNote(BuildContext, context);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Note',
                    style: GoogleFonts.tinos().copyWith(
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  const Icon(
                    Icons.comment,
                    size: 15,
                  )
                ],
              ),
            ),
          if (myOrderNote == '')
            OutlinedButton(
              onPressed: () {
                textfieldControllerCloseOrderNote.text = myOrderNote;
                _dialogFormCloseOrderNote(BuildContext, context);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Note',
                    style: GoogleFonts.tinos().copyWith(
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  if (textfieldControllerCloseOrderNote.text.isNotEmpty)
                    const Icon(
                      Icons.comment,
                      size: 15,
                    )
                ],
              ),
            ),

          if (status == 'Shipped' ||
              status == 'Cancelled' ||
              status == 'Refunded' ||
              status == 'Failed' ||
              status == 'Rejected' ||
              status == 'Completed')
            MaterialButton(
              onPressed: null,
              child: const Text(
                'Update',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              elevation: 0,
              disabledColor: Colors.blue.shade200,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4)),
              height: 30,
            ),
          if (status == 'Processing' || status == 'On hold')
            MaterialButton(
              onPressed: () {
                // (1) CONFIRM THAT STATUS IS SELECTED
                // (2) CONFIRM THAT REASON FOR CLOSING AN ORDER IS FILLED ON THE
                // PRIVATE NOTE
                // IF THE TWO CONDITIONS ARE MEANT, GET A CONFIRMATION BEFORE
                // EXECUTING THE ORDER
                if (selectedValue == '----') {
                  serviceProvider
                      .warningToastMassage('Kindly select a valid status');
                } else if (selectedValue == 'cancelled' ||
                    selectedValue == 'rejected') {
                  if (textfieldControllerCloseOrderNote.text.isEmpty) {
                    serviceProvider.warningToastMassage(
                        'Kindly give reason for closing the order before proceding');
                  } else {
                    // CONFIRM IF THE USER WANT TO UPDATE THE ORDER PROCESS
                    serviceProvider.confirmationPopDialogMsg(
                      context,
                      'Confirm Action',
                      'You are about to close the status of an order.\nThis action is irriversable!\nDo you want to continue?',
                      widget.orderNo,
                      '',
                      '',
                      widget.token,
                      selectedValue,
                      '',
                      '',
                      '',
                      textfieldControllerCloseOrderNote.text,
                      'edit_my_order',
                    );
                  }
                }
              },
              child: const Text(
                'Update',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              elevation: 0,
              color: Colors.blue,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4)),
              height: 30,
            ),
        ],
      ),
    );
  }

  Container detailHeader() {
    return Container(
      child: Column(
        children: [
          Row(
            children: [
              Text('Order Item',
                  style:
                      GoogleFonts.sora().copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(
            color: Colors.grey,
          ),
          Table(children: [
            TableRow(children: [
              Text(
                'Image',
                style: GoogleFonts.sora().copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent.shade700,
                ),
              ),
              Text(
                'Name',
                style: GoogleFonts.sora().copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent.shade700,
                ),
              ),
              Text(
                'Unit Price',
                style: GoogleFonts.sora().copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent.shade700,
                ),
              ),
              Text(
                'Qty',
                style: GoogleFonts.sora().copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent.shade700,
                ),
              ),
              Text(
                'Line Total',
                style: GoogleFonts.sora().copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent.shade700,
                ),
              ),
            ])
          ]),
        ],
      ),
    );
  }

  Container detailContent(
      String itemRowId, image, ptdName, price, qty, lineTotal) {
    var serviceProvider = Provider.of<DataProcessing>(context);
    return Container(
      child: Column(
        children: [
          Table(
            children: [
              TableRow(
                children: [
                  if (image != "http://192.168.43.50:8000")
                    Image.network(
                      image,
                      fit: BoxFit.cover,
                    ),
                  if (image == "http://192.168.43.50:8000")
                    const Icon(
                      Icons.photo_size_select_actual_sharp,
                      color: Colors.black26,
                      size: 60,
                    ),
                  Text(
                    ptdName,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
                    style: GoogleFonts.sora().copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '₦ ' + serviceProvider.formattedNumber(double.parse(price)),
                    style: GoogleFonts.tinos().copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'x ' + qty,
                    style: GoogleFonts.sora().copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '₦ ' +
                        serviceProvider
                            .formattedNumber(double.parse(lineTotal)),
                    style: GoogleFonts.tinos().copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              if ('${userInfo['status']}' != 'Completed' &&
                  '${userInfo['status']}' != 'Shipped' &&
                  '${userInfo['status']}' != 'Cancelled' &&
                  '${userInfo['status']}' != 'Failed' &&
                  '${userInfo['status']}' != 'Refunded' &&
                  '${userInfo['status']}' != 'Rejected')
                TableRow(children: [
                  OutlinedButton(
                    onPressed: () async {
                      var response =
                          await serviceProvider.confirmationPopDialogMsg(
                        context,
                        'Confirm Action',
                        'You are about to reduce the quantity of an item.\nKindly note that this action is irriversable if you proceed!',
                        widget.orderNo,
                        itemRowId,
                        'reduction',
                        widget.token,
                        '',
                        '',
                        '',
                        '',
                        '',
                        'edit_my_order',
                      );
                    },
                    child: const Text(
                      'reduce',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(),
                  OutlinedButton(
                    onPressed: () async {
                      await serviceProvider.confirmationPopDialogMsg(
                        context,
                        'Confirm Action',
                        'You are about to delete an item from the cart.\nKindly note that this action is irriversable!\nDo you want to proceed?',
                        widget.orderNo,
                        itemRowId,
                        'delete',
                        widget.token,
                        '',
                        '',
                        '',
                        '',
                        '',
                        'edit_my_order',
                      );
                    },
                    child: Text(
                      'delete',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.red.shade300,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Text(''),
                  const Text(''),
                ])
            ],
          ),
          const Divider(
            color: Colors.grey,
          )
        ],
      ),
    );
  }

  Container contentBottom(double grandTotal) {
    var serviceProvider = Provider.of<DataProcessing>(context);
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(
            width: 10,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('Shipping:'),
              Text('Total:'),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₦ 0',
                style: GoogleFonts.tinos()
                    .copyWith(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                '₦ ' + serviceProvider.formattedNumber(grandTotal),
                style: GoogleFonts.tinos()
                    .copyWith(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          )
        ],
      ),
    );
  }
}

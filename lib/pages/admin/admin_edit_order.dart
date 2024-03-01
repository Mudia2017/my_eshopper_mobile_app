import 'dart:convert';

import 'package:eshopper_mobile_app/componets/data_computation.dart';
import 'package:eshopper_mobile_app/componets/pdf_invoice_slip.dart';
import 'package:eshopper_mobile_app/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:eshopper_mobile_app/componets/pdf_packing_slip.dart';

class AdminUpdateOrder extends StatefulWidget {
  final String orderNo, token;
  AdminUpdateOrder({required this.orderNo, required this.token});
  @override
  _AdminUpdateOrderState createState() => _AdminUpdateOrderState();
}

class _AdminUpdateOrderState extends State<AdminUpdateOrder> {
  @override
  void initState() {
    super.initState();

    getDetailOrder();
  }

  var detailOrder = {};
  bool isVerifiedPayment = false;
  List orderItemData = [];
  double grandTotal = 0;
  String selectedValue = "----";
  bool isDoneLoading = false;
  String paymentMethod = '--';

  // ============= API USED TO GET OF THE ORDER SELECTED ============
  getDetailOrder() async {
    var data = {'order_no': widget.orderNo};
    var response = await http.post(
      Uri.parse(
          '${dotenv.env['URL_ENDPOINT']}/apis/v1/homePage/api_adminEditOrder/'),
      body: jsonEncode(data),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Token ${widget.token}",
      },
    );

    try {
      if (response.statusCode == 200) {
        var adminDetailOrder = json.decode(response.body);
        setState(() {
          detailOrder = adminDetailOrder['order_obj'];
          isVerifiedPayment = adminDetailOrder['isVerifiedPayment'];
          orderItemData = adminDetailOrder['orderItemData'];
          if (adminDetailOrder['grandTotal'] == 0) {
            grandTotal = 0;
          } else {
            grandTotal = double.parse(adminDetailOrder['grandTotal']);
          }

          isDoneLoading = true;
        });
      }
    } catch (error) {
      rethrow;
    }
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
            "Complete",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          value: "complete"),
      const DropdownMenuItem(
          child: Text(
            "Processing",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          value: "processing"),
      const DropdownMenuItem(
          child: Text(
            "On hold",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          value: "on_hold"),
      const DropdownMenuItem(
          child: Text(
            "Shipped",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          value: "shipped"),
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
      const DropdownMenuItem(
          child: Text(
            "Failed",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          value: "failed"),
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
            if (newValue == 'complete' && isVerifiedPayment == false) {
              // POP A DIALOG BOX FOR ADMIN TO ENTER AMOUNT PAID AND
              // PAYMENT CHANNEL. IT WILL BE USED TO CREATE THE PAYMENT
              // RECORD ON THE PAYMENT DB TABLE.
              _dialogDisplayPaymentForm(BuildContext, context);
            } else if (newValue == 'cancelled' ||
                newValue == 'rejected' ||
                newValue == 'failed') {
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

  List<DropdownMenuItem<String>> get paymentChannel {
    List<DropdownMenuItem<String>> paymentMenuList = [
      const DropdownMenuItem(
        child: Text(
          'Select Payment Channel',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        value: '--',
      ),
      const DropdownMenuItem(
        child: Text(
          'Cash Payment',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        value: 'cash_payment',
      ),
      const DropdownMenuItem(
        child: Text(
          'Bank Transfer',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        value: 'bank_transfer',
      ),
      const DropdownMenuItem(
        child: Text(
          'POS',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        value: 'pos',
      ),
    ];
    return paymentMenuList;
  }

  // THIS CONTROLLERS AND SHOW DIALOG ALERT IS USED TO ENTER AMOUNT PAID IF
  // PAYMENT WAS NOT VERIFIED
  TextEditingController textfieldControllerAmtPaid = TextEditingController();
  TextEditingController textfieldControllerPaymentNote =
      TextEditingController();
  _dialogDisplayPaymentForm(BuildContext, context) async {
    final _formKey = GlobalKey<FormState>();

    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            scrollable: true,
            title: Center(
              child: Text(
                'Payment details',
                style: GoogleFonts.sora().copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            content: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField(
                      value: paymentMethod,
                      onChanged: (String? newVal) {
                        setState(() {
                          paymentMethod = newVal!;
                        });
                      },
                      decoration: InputDecoration(
                        hintStyle: GoogleFonts.sora().copyWith(),
                      ),
                      items: paymentChannel,
                      validator: (value) {
                        if (value == null || value == '--') {
                          return 'Please select payment means';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: textfieldControllerAmtPaid,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Amount in NGN',
                        hintText: 'Amount paid',
                        hintStyle: GoogleFonts.sora().copyWith(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter amount paid';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: textfieldControllerPaymentNote,
                      keyboardType: TextInputType.multiline,
                      maxLines: 5,
                      decoration: InputDecoration(
                        labelText: 'Payment note',
                        hintText: 'Optional payment note',
                        hintStyle: GoogleFonts.sora().copyWith(),
                      ),
                    ),
                  ],
                )),
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
      },
    );
  }

  shippingInfo(orderId, address, city, state, mobile, altMobile) {
    var updateShipAddress = {
      'orderId': orderId,
      "address": address,
      "city": city,
      "state": state,
      "mobile": mobile,
      "altMobile": altMobile,
    };
    return updateShipAddress;
  }

  // CONTROLLER AND SHOW DIALOG ALERT USED TO WRITE REASON FOR CLOSING AN ORDER
  TextEditingController textfieldControllerCloseOrderNote =
      TextEditingController();
  _dialogFormCloseOrderNote(BuildContext, context) async {
    final _formKey = GlobalKey<FormState>();

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
              child: TextFormField(
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

  final PdfPackingSlipService packingSlipService = PdfPackingSlipService();
  final PdfInvoiceService invoiceService = PdfInvoiceService();

  @override
  Widget build(BuildContext context) {
    var serviceProvider = Provider.of<DataProcessing>(context);
    // THIS CONDITION IS PLACE TO UPDATE ORDER ITEMS ONCE ANY
    // ACTION IS MADE
    if (serviceProvider.isAdminUpdatedRecord == true &&
        isDoneLoading == false) {
      detailOrder = serviceProvider.adminDetailOrderHeader;
      orderItemData = serviceProvider.adminOrderItemData;
      grandTotal = serviceProvider.adminUpdateOrderGrandTotal;
      isVerifiedPayment = serviceProvider.isVerifiedPayment;
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
                            '${detailOrder['order_date']}',
                            '${detailOrder['address']}',
                            '${detailOrder['city']}',
                            '${detailOrder['state']}',
                            '${detailOrder['mobile']}',
                            '${detailOrder['altMobile']}',
                            '${detailOrder['optional_note']}',
                            '${detailOrder['user_name']}',
                            '${detailOrder['user_email']}',
                            '${detailOrder['date_joined']}',
                            '${detailOrder['last_login']}',
                            '${detailOrder['status']}',
                          ),
                          secondHeaderSection(
                            '${detailOrder['status']}',
                            '${detailOrder['payment_option']}',
                            isVerifiedPayment,
                            '${detailOrder['address']}',
                            '${detailOrder['city']}',
                            '${detailOrder['state']}',
                            '${detailOrder['mobile']}',
                            '${detailOrder['altMobile']}',
                            '${detailOrder['optional_note']}',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  width: 8,
                ),
                Expanded(
                  flex: 1,
                  child: thirdHeaderSection('${detailOrder['status']}'),
                ),
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
            // ========== DISPLAY WHEN ORDER-ITEM IS EMPTY =======
            if (orderItemData.isEmpty && isDoneLoading == true)
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
            Flexible(
              child: detailOrder.isNotEmpty
                  ? ListView.builder(
                      itemCount: orderItemData.length,
                      itemBuilder: (BuildContext cxt, int x) => detailContent(
                        orderItemData.toList()[x]['itemRowId'].toString(),
                        orderItemData.toList()[x]['ptdImage'].toString(),
                        orderItemData.toList()[x]['ptdName'].toString(),
                        orderItemData.toList()[x]['storeLocation'].toString(),
                        orderItemData.toList()[x]['price'].toString(),
                        orderItemData.toList()[x]['qty'].toString(),
                        orderItemData.toList()[x]['lineTotal'].toString(),
                      ),
                    )
                  : Center(
                      child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        CircularProgressIndicator(),
                      ],
                    )),
            ),
            contentBottom(grandTotal),
          ],
        ),
      ),
      // ),
    );
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
        text: '${detailOrder['address']}'.toString() == 'null'
            ? ''
            : '${detailOrder['address']}'.toString());
    textfieldControllerCity = TextEditingController(
        text: '${detailOrder['city']}'.toString() == 'null'
            ? ''
            : '${detailOrder['city']}'.toString());
    textfieldControllerState = TextEditingController(
        text: '${detailOrder['state']}'.toString() == 'null'
            ? ''
            : '${detailOrder['state']}'.toString());
    textfieldControllerMobile = TextEditingController(
        text: '${detailOrder['mobile']}'.toString() == 'null'
            ? ''
            : '${detailOrder['mobile']}'.toString());
    textfieldControllerAltMobile = TextEditingController(
        text: '${detailOrder['altMobile']}'.toString() == 'null'
            ? ''
            : '${detailOrder['altMobile']}'.toString());

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
                        await serviceProvider.adminUpdateOrder(
                          true,
                          widget.orderNo,
                          '',
                          '',
                          widget.token,
                          '',
                          '',
                          '',
                          '',
                          shippingInfo(
                              '${detailOrder['orderId']}',
                              textfieldControllerAddress.text,
                              textfieldControllerCity.text,
                              textfieldControllerState.text,
                              textfieldControllerMobile.text,
                              textfieldControllerAltMobile.text),
                          '',
                        );

                        // CALL THE DIALOG TO ALLOW USER PERFORM OPERATION ON THE UI

                        serviceProvider.isLoadDialogBox = false;
                        serviceProvider.buildShowDialog(context);

                        setState(() {
                          detailOrder['address'] =
                              textfieldControllerAddress.text;
                          detailOrder['city'] = textfieldControllerCity.text;
                          detailOrder['state'] = textfieldControllerState.text;
                          detailOrder['mobile'] =
                              textfieldControllerMobile.text;
                          detailOrder['altMobile'] =
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
      child: Text("Update Order: " + widget.orderNo,
          style: const TextStyle(
              color: Colors.black,
              fontSize: 18.0,
              fontWeight: FontWeight.bold)),
    );
  }

  // ========= FIRST COLUMN OF THE HEADER SECTION =======
  Container firstHeaderSection(
      String orderDate,
      address,
      city,
      state,
      mobile,
      altMobile,
      optionalNote,
      userName,
      userEmail,
      joinDate,
      lastLoginDate,
      status) {
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
          if ('${detailOrder['refund_status']}'.isNotEmpty &&
              '${detailOrder['refund_status']}' != 'null')
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
                    '${detailOrder['refund_status']}',
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
          Row(
            children: [
              const Text(
                'Send email to customer',
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (status == 'Cancelled' ||
                  status == 'Refunded' ||
                  status == 'Failed' ||
                  status == 'Rejected' ||
                  status == 'Completed')
                const Flexible(
                  child: IconButton(
                    onPressed: null,
                    disabledColor: Color(0xFF64B5F6),
                    icon: Icon(
                      Icons.email_outlined,
                    ),
                  ),
                ),
              if (status == 'Processing' ||
                  status == 'On hold' ||
                  status == 'Shipped')
                Flexible(
                  child: IconButton(
                    onPressed: () {
                      serviceProvider.sendEmailDialogPopUp(
                          context, 'Send an E-mail to Customer');
                    },
                    icon: const Icon(
                      Icons.email_outlined,
                      color: Colors.blueAccent,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    ));
  }

  // ========= SECOND COLUMN OF THE HEADER SECTION =======
  Container secondHeaderSection(String status, paymentOption, payVerification,
      address, city, state, mobile, altMobile, optionalNote) {
    var serviceProvider = Provider.of<DataProcessing>(context);
    return Container(
        child: Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
          Row(
            children: [
              Text(
                'Verify Pay: ',
                style: GoogleFonts.sora().copyWith(
                  fontSize: 10,
                ),
              ),
              if (payVerification == false)
                Expanded(
                  child: Text(
                    'Unverified X',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: GoogleFonts.sora().copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      color: Colors.red.shade900,
                    ),
                  ),
                ),
              if (payVerification == true)
                Expanded(
                  child: Text(
                    'Verified',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: GoogleFonts.sora().copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      color: Colors.green.shade900,
                    ),
                  ),
                ),
            ],
          ),
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
  Container thirdHeaderSection(status) {
    var serviceProvider = Provider.of<DataProcessing>(context);
    return Container(
      child: Column(
        children: [
          if (status == 'Processing' ||
              status == 'On hold' ||
              status == 'Shipped')
            dropdownMenu(),
          if (status == 'Cancelled' ||
              status == 'Refunded' ||
              status == 'Failed' ||
              status == 'Rejected' ||
              status == 'Completed')
            disabledDropDownMenu(),
          if (status == 'Cancelled' ||
              status == 'Refunded' ||
              status == 'Failed' ||
              status == 'Rejected' ||
              status == 'Completed')
            MaterialButton(
              onPressed: null,
              child: const Text(
                'Update Order',
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
          if (status == 'Processing' ||
              status == 'On hold' ||
              status == 'Shipped')
            MaterialButton(
              onPressed: () async {
                // CONFIRM THAT (1) A STATUS HAVE BEEN SELECTED.
                // (2) IF STATUS OF COMPLETE IS SELECTED AND PAYMENT
                // WAS NOT VERIFIED, ENSURE AMOUNT PAID AND PAYMENT
                // METHOD WAS ENTERED IN THE PAYMENT FORM FIELD
                // BEFORE PROCEEDING...
                // IF ANY OTHER VALID STATUS IS SELECTED, EXECUTE AS SELECTED
                if (selectedValue != '----') {
                  if (selectedValue == 'complete' &&
                      isVerifiedPayment == false &&
                      (paymentMethod == '--' ||
                          textfieldControllerAmtPaid.text.isEmpty)) {
                    serviceProvider.warningToastMassage(
                        'You cannot update until the payment detail is filled!');
                  } else if (selectedValue == 'complete') {
                    // CONFIRM IF THE USER WANT TO COMPLETE THE ORDER PROCESS
                    await serviceProvider.confirmationPopDialogMsg(
                      context,
                      'Confirm Action',
                      'You are about to complete the status of an order.\nIf you proceed this action is irriversable.\nDo you want to continue?',
                      widget.orderNo,
                      '',
                      '',
                      widget.token,
                      selectedValue,
                      textfieldControllerAmtPaid.text,
                      paymentMethod,
                      textfieldControllerPaymentNote.text,
                      '',
                      'admin_edit_order',
                    );
                  } else if (selectedValue == 'processing' ||
                      selectedValue == 'on_hold' ||
                      selectedValue == 'shipped') {
                    // CONFIRM IF THE USER WANT TO UPDATE THE ORDER PROCESS
                    await serviceProvider.confirmationPopDialogMsg(
                      context,
                      'Confirm Action',
                      'You are about to update the status of an order.\nDo you want to continue?',
                      widget.orderNo,
                      '',
                      '',
                      widget.token,
                      selectedValue,
                      textfieldControllerAmtPaid.text,
                      paymentMethod,
                      textfieldControllerPaymentNote.text,
                      '',
                      'admin_edit_order',
                    );
                  } else if (selectedValue == 'cancelled' ||
                      selectedValue == 'rejected' ||
                      selectedValue == 'failed') {
                    if (textfieldControllerCloseOrderNote.text.isNotEmpty) {
                      // CONFIRM IF THE USER WANT TO UPDATE THE ORDER PROCESS
                      await serviceProvider.confirmationPopDialogMsg(
                        context,
                        'Confirm Action',
                        'You are about to close the status of an order.\nThis action is irriversable!\nDo you want to continue?',
                        widget.orderNo,
                        '',
                        '',
                        widget.token,
                        selectedValue,
                        textfieldControllerAmtPaid.text,
                        paymentMethod,
                        textfieldControllerPaymentNote.text,
                        textfieldControllerCloseOrderNote.text,
                        'admin_edit_order',
                      );
                    } else {
                      serviceProvider.warningToastMassage(
                          'Kindly give reason for closing the order before proceding');
                    }
                  }
                } else {
                  serviceProvider
                      .warningToastMassage('Kindly select a valid status');
                }
              },
              child: const Text(
                'Update Order',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
              color: Colors.blue,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4)),
              height: 30,
            ),
          if (status == 'Processing' ||
              status == 'On hold' ||
              status == 'Shipped' ||
              status == 'Completed')
            MaterialButton(
              onPressed: () async {
                final data = await packingSlipService.createPackingSlip(
                  orderItemData,
                  detailOrder,
                );
                packingSlipService.savePdfFile(
                    "packing slip ${getCurrentDate()}", data);
              },
              child: const Text('Packing Slip',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  )),
              color: Colors.blue,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4)),
              height: 30,
            ),
          if (status == 'Cancelled' ||
              status == 'Refunded' ||
              status == 'Failed' ||
              status == 'Rejected')
            MaterialButton(
              onPressed: null,
              child: const Text('Packing Slip',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  )),
              color: Colors.blue,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4)),
              height: 30,
              disabledColor: Colors.blue.shade200,
            ),
          if (status == 'Processing' ||
              status == 'On hold' ||
              status == 'Shipped' ||
              status == 'Completed')
            MaterialButton(
              onPressed: () async {
                final data = await invoiceService.generateInvoice(
                  orderItemData,
                  detailOrder,
                  getCurrentDate(),
                  serviceProvider.formattedNumber(grandTotal).toString(),
                );

                invoiceService.savePdfFile(
                  'invoice ${getCurrentDate()}',
                  data,
                );
              },
              child: const Text('Generate Invoice',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  )),
              color: Colors.blue,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4)),
              height: 30,
            ),
          if (status == 'Cancelled' ||
              status == 'Refunded' ||
              status == 'Failed' ||
              status == 'Rejected')
            MaterialButton(
              onPressed: null,
              child: const Text('Generate Invoice',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  )),
              color: Colors.blue,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4)),
              height: 30,
              disabledColor: Colors.blue.shade200,
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
                'Store Location',
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
      String itemRowId, image, ptdName, storeLocation, price, qty, lineTotal) {
    var serviceProvider = Provider.of<DataProcessing>(context);
    return Container(
      child: Column(
        children: [
          Table(
            children: [
              TableRow(
                children: [
                  if (image != "${dotenv.env['URL_ENDPOINT']}")
                    Image.network(
                      image,
                      fit: BoxFit.cover,
                    ),
                  if (image == "${dotenv.env['URL_ENDPOINT']}")
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
                    storeLocation,
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
              if ('${detailOrder['status']}' != 'Completed' &&
                  '${detailOrder['status']}' != 'Shipped' &&
                  '${detailOrder['status']}' != 'Cancelled' &&
                  '${detailOrder['status']}' != 'Failed' &&
                  '${detailOrder['status']}' != 'Refunded' &&
                  '${detailOrder['status']}' != 'Rejected')
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
                        'admin_edit_order',
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
                        'admin_edit_order',
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
          MaterialButton(
            onPressed: () {
              Navigator.of(context).pushNamed(RouteManager.refund, arguments: {
                'orderNo': widget.orderNo,
                'token': widget.token
              });
            },
            child: const Text(
              'Refund Order',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            color: Colors.orange[400],
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6.0)),
          ),
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

  getCurrentDate() {
    String currentDate = DateFormat("MMMM, dd, yyyy").format(DateTime.now());
    return currentDate;
  }
}

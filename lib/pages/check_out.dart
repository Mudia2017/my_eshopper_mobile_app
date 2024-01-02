import 'dart:convert';
import 'dart:io';

import 'package:eshopper_mobile_app/componets/data_computation.dart';
import 'package:eshopper_mobile_app/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:flutter_paystack/flutter_paystack.dart';

class CustomerCheckOut extends StatefulWidget {
  final String userName;
  final String token;
  final String userEmail;
  final String custId;

  CustomerCheckOut(
      {required this.userName,
      required this.token,
      required this.userEmail,
      required this.custId});
  @override
  _CustomerCheckOutState createState() => _CustomerCheckOutState();
}

class _CustomerCheckOutState extends State<CustomerCheckOut> {
  // List data = [];
  Map<String, dynamic> shippingRecord = {};
  double totalAmt = 0;
  String custShippingName = '';
  bool isLoading = true;
  String paymentRef = '';
  List allShippingAddresses = [];
  String selectShipAddress = "Select Shipping Address";
  List allShipAddressRecord = [];

  @override
  void initState() {
    plugin.initialize(publicKey: paystackPublicKey);
    super.initState();
    getShippingInfo(widget.userName, widget.token);
  }

  Future getShippingInfo(String cusName, token) async {
    Map data = {"name": cusName};

    var response = await http.post(
        // Uri.parse(
        //     'http://192.168.43.50:8000/apis/v1/homePage/api_getShippingAdd/'),
        Uri.parse(
            'http://Oneluvtoall.pythonanywhere.com/apis/v1/homePage/api_getShippingAdd/'),
        body: json.encode(data),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Token $token"
        });

    if (response.statusCode == 200) {
      var data = json.decode(response.body);

      setState(() {
        shippingRecord = data[1]['shipping_addressRecord'];
        totalAmt = data[0]['grand total'];
      });

      if (shippingRecord['customerName'].toString() != 'null' &&
          shippingRecord['customerName'].toString() != '') {
        custShippingName = shippingRecord['customerName'].toString();
      } else if (shippingRecord['userName'].toString() != 'null' &&
          shippingRecord['userName'].toString() != '') {
        custShippingName = shippingRecord['userName'].toString();
      }
      allShippingAddresses = data[1]['allShipAddresses'];
      allShipAddressRecord = data[1]['allShipAddressRecord'];
      isLoading = false;
    }
  }

  // SINCE I REALLY DON'T KNOW HOW SHIPPING FEE WILL BE CALCULATED,
  // I DECIDED TO JUST PLACE A FLATE RATE OF 900 FOR EVERY SUCCESSFUL TRANSACTION
  double getGrandTotalAmt(double totalAmt) {
    var total = totalAmt + 900.00;
    double grandTotal = double.parse((total).toStringAsFixed(2));
    return grandTotal;
  }

  _showModalBottomSheet(context) {
    return showModalBottomSheet(
        context: context,
        builder: (builder) {
          return StatefulBuilder(builder: (context, setstate) {
            return Container(
              color: const Color(0xFF737373),
              child: Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).canvasColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25),
                    )),
                height: 230,
                child: ListView(
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    Center(
                      child: Text(
                        'Select payment method',
                        style: GoogleFonts.sora().copyWith(
                          color: Colors.cyanAccent.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    displayRadioButton("Debit card", 'instant_payment'),
                    const SizedBox(height: 8),
                    displayRadioButton("Pay on delivery", 'pay_on_delivery'),
                  ],
                ),
              ),
            );
          });
        });
  }

  shippingData(
      String address, city, state, zipcode, mobile, altMobile, optionalNote) {
    var shippingAddress = {
      "address": address,
      "city": city,
      "state": state,
      "zipcode": zipcode,
      "mobile": mobile,
      "altMobile": altMobile,
      "optionalNote": optionalNote
    };
    return shippingAddress;
  }

  // ===== DROP DOWN MENU LIST FOR ALL USER SHIPPING ADDRESS =========
  Container allShipAddressdropdownMenu() {
    var serviceProvider = Provider.of<DataProcessing>(context);
    return Container(
      width: 250,
      child: DropdownButton(
          isExpanded: true,
          value: selectShipAddress,
          onChanged: (newValue) async {
            setState(() {
              selectShipAddress = newValue!.toString();
            });
            if (selectShipAddress != 'Select Shipping Address') {
              //  ONCE AN OPTION IS SELECTED, CALL THIS FUNCTION TO
              // DISPLAY THE SELECTED OPTION ON THE WIDGET

              optionShippingAddress(allShipAddressRecord, selectShipAddress);
            }
            if (selectShipAddress == 'Select Shipping Address') {
              serviceProvider.warningToastMassage('Invalid selection made!');
            }
          },
          items: allShippingAddresses.map((itmList) {
            return DropdownMenuItem(
              child: Text(
                itmList,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xFF2962FF),
                ),
                overflow: TextOverflow.ellipsis,
              ),
              value: itmList,
            );
          }).toList()),
    );
  }

  // LOOP THROUGH TO GET THE SELECTED OPTION, USE IT TO
  // CHANGE THE SELECTED SHIPPING ADDRESS
  optionShippingAddress(List data, selected) {
    for (var record in data) {
      if (record['address'] == selected) {
        setState(() {
          custShippingName = record['customerName'];
          shippingRecord['address'] = record['address'];
          shippingRecord['city'] = record['city'];
          shippingRecord['state'] = record['state'];
          shippingRecord['zipcode'] = record['zipcode'];
          shippingRecord['mobile'] = record['mobile'];
          shippingRecord['altMobile'] = record['altMobile'];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var serviceProvider = Provider.of<DataProcessing>(context);
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
      body: ListView(
        children: [
          !isLoading
              ? Container(
                  padding: const EdgeInsets.all(0),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                _displayDialog_editShippingAdd(context);
                              },
                              child: const Text('Edit'),
                            ),
                            allShipAddressdropdownMenu(),
                          ],
                        ),
                      ),
                      Card(
                          elevation: 5,
                          child: Column(
                            children: [
                              Text(
                                'Ship to:',
                                style: GoogleFonts.sora().copyWith(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Divider(
                                indent: 10,
                                endIndent: 10,
                                color: Colors.black87,
                              ),
                              ListTile(
                                title: Text(
                                  custShippingName.toString() == 'null'
                                      ? ''
                                      : custShippingName.toString(),
                                  style: GoogleFonts.sora().copyWith(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    if ('${shippingRecord['address']}' != '')
                                      Text(
                                          '${shippingRecord['address']}' ==
                                                  'null'
                                              ? ''
                                              : '${shippingRecord['address']}',
                                          style: GoogleFonts.sora().copyWith()),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    if ('${shippingRecord['city']}' != '')
                                      Text(
                                          '${shippingRecord['city']}' == 'null'
                                              ? ''
                                              : '${shippingRecord['city']}',
                                          style: GoogleFonts.sora().copyWith()),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    if ('${shippingRecord['state']}' != '')
                                      Text(
                                          '${shippingRecord['state']}' == 'null'
                                              ? ''
                                              : '${shippingRecord['state']}',
                                          style: GoogleFonts.sora().copyWith()),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    if ('${shippingRecord['zipcode']}' != '' &&
                                        '${shippingRecord['zipcode']}' !=
                                            'null')
                                      Text(
                                          '${shippingRecord['zipcode']}' ==
                                                  'null'
                                              ? ''
                                              : '${shippingRecord['zipcode']}',
                                          style: GoogleFonts.sora().copyWith()),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    if ('${shippingRecord['mobile']}' != '')
                                      Text(
                                          '${shippingRecord['mobile']}' ==
                                                  'null'
                                              ? ''
                                              : '${shippingRecord['mobile']}',
                                          style: GoogleFonts.sora().copyWith()),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    if ('${shippingRecord['altMobile']}' != '')
                                      Text(
                                          '${shippingRecord['altMobile']}' ==
                                                  'null'
                                              ? ''
                                              : '${shippingRecord['altMobile']}',
                                          style: GoogleFonts.sora().copyWith()),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    if ('${shippingRecord['optionalNote']}' !=
                                        '')
                                      Text(
                                          '${shippingRecord['optionalNote']}' ==
                                                  'null'
                                              ? ''
                                              : '${shippingRecord['optionalNote']}',
                                          style: GoogleFonts.sora().copyWith()),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )),
                      const SizedBox(
                        height: 10,
                      ),
                      Card(
                        elevation: 5,
                        child: ListTile(
                          title: Text(
                            'Door Delivery',
                            style: GoogleFonts.sora().copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            children: [
                              Text(
                                'Deliver between this hour and this hour on 05 Nov.',
                                style: GoogleFonts.sora().copyWith(),
                              ),
                              Row(
                                children: [
                                  Text(
                                    'Shipping Fee: ',
                                    style: GoogleFonts.sora().copyWith(),
                                  ),
                                  Text(
                                    '₦ 900',
                                    style: GoogleFonts.publicSans().copyWith(
                                        // fontWeight: FontWeight.bold,
                                        color: Colors.blue.shade800),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Card(
                        elevation: 5,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          child: Column(
                            children: [
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Subtotal',
                                    style: GoogleFonts.sora().copyWith(
                                        fontWeight: FontWeight.normal),
                                  ),
                                  Text(
                                    '₦ ' +
                                        serviceProvider
                                            .formattedNumber(totalAmt),
                                    style: GoogleFonts.publicSans().copyWith(
                                        // fontWeight: FontWeight.bold,
                                        color: Colors.blue.shade800,
                                        fontSize: 14),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Shipping',
                                    style: GoogleFonts.sora().copyWith(
                                        fontWeight: FontWeight.normal),
                                  ),
                                  Text(
                                    '₦ 900.0',
                                    style: GoogleFonts.publicSans().copyWith(
                                        // fontWeight: FontWeight.bold,
                                        color: Colors.blue.shade800,
                                        fontSize: 14),
                                  ),
                                ],
                              ),
                              const Divider(
                                color: Colors.black87,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total',
                                    style: GoogleFonts.sora()
                                        .copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '₦ ' +
                                        serviceProvider.formattedNumber(
                                            getGrandTotalAmt(totalAmt)),
                                    style: GoogleFonts.publicSans().copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue.shade800,
                                        fontSize: 18),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Card(
                        elevation: 5,
                        child: Container(
                          padding: const EdgeInsets.all(0),
                          height: 60,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Colors.orange[300],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text(
                                  "Proceed to Payment",
                                  style: TextStyle(
                                    fontSize: 22,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Icon(
                                  Icons.assistant_direction,
                                  size: 50,
                                  color: Colors.black,
                                ),
                              ],
                            ),
                            onPressed: () {
                              // BEFORE PROCEEDING TO PAYMENT,
                              // CHECK THAT THE CUSTOMER'S SHIPPING NAME AND ADDRESS IS NOT EMPTY
                              // CHECK THAT THE TOTAL AMOUNT IS NOT EMPTY OR ZERO

                              print(convertToInt(totalAmt * 100));
                              if ((custShippingName.isNotEmpty) &&
                                  '${shippingRecord['address']}'.isNotEmpty &&
                                  '${shippingRecord['city']}'.isNotEmpty &&
                                  '${shippingRecord['state']}'.isNotEmpty &&
                                  '${shippingRecord['mobile']}'.isNotEmpty &&
                                  getGrandTotalAmt(totalAmt) > 0) {
                                // PROCEED TO MAKE PAYMENT
                                // Navigator.of(context).pushNamed(
                                //     RouteManager.payment,
                                //     arguments: ({
                                //       "userName": widget.userName,
                                //       "token": widget.token
                                //     }));

                                _showModalBottomSheet(context);
                              } else if (getGrandTotalAmt(totalAmt) <= 0) {
                                serviceProvider
                                    .warningToastMassage('Invalid transaction');
                              } else {
                                serviceProvider.toastMessage(
                                    "Kindly use the 'Edit' button provide all shipping information before proceeding");
                              }
                            },
                          ),
                        ),
                      )
                    ],
                  ),
                )
              : Container(
                  padding: const EdgeInsets.all(0),
                  height: MediaQuery.of(context).size.height,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                )
        ],
      ),
    );
  }

  Container titleSection() {
    return Container(
      margin: const EdgeInsets.all(0.0),
      child: const Text("Check Out",
          style: TextStyle(
              color: Colors.black,
              fontSize: 25.0,
              fontWeight: FontWeight.bold)),
    );
  }

  // THIS CONTROLLERS AND SHOW DIALOG ALERT IS USED TO EDIT SHIPPING ADDRESS
  TextEditingController textfieldControllerName = TextEditingController();
  TextEditingController textfieldControllerAddress = TextEditingController();
  TextEditingController textfieldControllerCity = TextEditingController();
  TextEditingController textfieldControllerState = TextEditingController();
  TextEditingController textfieldControllerZipcode = TextEditingController();
  TextEditingController textfieldControllerMobile = TextEditingController();
  TextEditingController textfieldControllerAltMobile = TextEditingController();
  TextEditingController textfieldControllerOptionalNote =
      TextEditingController();

  _displayDialog_editShippingAdd(BuildContext context) async {
    textfieldControllerName = TextEditingController(text: custShippingName);
    textfieldControllerAddress = TextEditingController(
        text: '${shippingRecord['address']}'.toString() == 'null'
            ? ''
            : '${shippingRecord['address']}'.toString());
    textfieldControllerCity = TextEditingController(
        text: '${shippingRecord['city']}'.toString() == 'null'
            ? ''
            : '${shippingRecord['city']}'.toString());
    textfieldControllerState = TextEditingController(
        text: '${shippingRecord['state']}'.toString() == 'null'
            ? ''
            : '${shippingRecord['state']}'.toString());
    textfieldControllerZipcode = TextEditingController(
        text: '${shippingRecord['zipcode']}'.toString() == 'null'
            ? ''
            : '${shippingRecord['zipcode']}'.toString());
    textfieldControllerMobile = TextEditingController(
        text: '${shippingRecord['mobile']}'.toString() == 'null'
            ? ''
            : '${shippingRecord['mobile']}'.toString());
    textfieldControllerAltMobile = TextEditingController(
        text: '${shippingRecord['altMobile']}'.toString() == 'null'
            ? ''
            : '${shippingRecord['altMobile']}'.toString());
    textfieldControllerOptionalNote = TextEditingController(
        text: '${shippingRecord['optionalNote']}'.toString() == 'null'
            ? ''
            : '${shippingRecord['optionalNote']}'.toString());
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
                  // TEXT-FORM-FIELD FOR CUSTOMER NAME
                  TextFormField(
                    maxLines: null,
                    controller: textfieldControllerName,
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      hintText: 'Customer name',
                      hintStyle: GoogleFonts.sora().copyWith(),
                    ),
                    onSaved: (custName) {
                      custShippingName = custName.toString();
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter customer name';
                      }
                      return null;
                    },
                  ),

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

                  // TEXT-FORM-FIELD FOR ZIPCODE
                  TextFormField(
                    maxLines: null,
                    controller: textfieldControllerZipcode,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Zipcode',
                      hintText: 'zipcode',
                      hintStyle: GoogleFonts.sora().copyWith(),
                    ),
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

                  // TEXT-FORM-FIELD FOR STATE
                  TextFormField(
                    maxLines: null,
                    controller: textfieldControllerOptionalNote,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      labelText: 'Optional note',
                      hintText: 'Shipping note',
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
                    child: const Text('Ok'),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // IF ALL COMPLUSORY FIELDS ARE VALID, UPDATE SHIPPING
                        // INFOMATION, ELSE THE VALIDATOR WILL RAISE AN ERROR
                        // ON INVALID FIELD.

                        setState(() {
                          custShippingName = textfieldControllerName.text;
                          shippingRecord['address'] =
                              textfieldControllerAddress.text;
                          shippingRecord['city'] = textfieldControllerCity.text;
                          shippingRecord['state'] =
                              textfieldControllerState.text;
                          shippingRecord['zipcode'] =
                              textfieldControllerZipcode.text;
                          shippingRecord['mobile'] =
                              textfieldControllerMobile.text;
                          shippingRecord['altMobile'] =
                              textfieldControllerAltMobile.text;
                          shippingRecord['optionalNote'] =
                              textfieldControllerOptionalNote.text;
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

  Widget displayRadioButton(String paymentMethod, String passedValue) {
    bool colorSelected = false;
    var serviceProvider = Provider.of<DataProcessing>(context);
    String selectedRadio = '';
    return StatefulBuilder(builder: (context, setstate) {
      return Card(
          child: RadioListTile(
        title: Text(
          paymentMethod,
          style: GoogleFonts.sora().copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            // color: Colors.deepOrange,
          ),
        ),
        value: passedValue,
        groupValue: selectedRadio,
        // onChanged: (val) => setState(() => radioButton = val as String),
        onChanged: (value) async {
          setstate(() {
            if (value == 'instant_payment') {
              selectedRadio = 'null';
              selectedRadio = value.toString();
              colorSelected = true;
            } else {
              selectedRadio = 'null';
              selectedRadio = value.toString();
              colorSelected = true;
            }
          });

          if (selectedRadio.isNotEmpty &&
              selectedRadio != '' &&
              selectedRadio == 'pay_on_delivery') {
            // ========== PAY ON DELIVERY METHOD =============
            processCustomerOrder(paymentMethod, false);
          }
          // ========== CARD OR BANK TRANSFER PAYMENT ==============
          else if (selectedRadio.isNotEmpty &&
              selectedRadio != '' &&
              selectedRadio == 'instant_payment') {
            chargeCard(paymentMethod);
          }
        },

        selected: colorSelected,
        toggleable: true,
      ));
    });
  }

  // ========== PAYSTACK PAYMENT SYSTEM BEGIN =============================

  String paystackPublicKey = 'pk_test_ba8f7eed26252a042ba331330d205fd0aef1919f';
  bool isGeneratingCode = false;
  final plugin = PaystackPlugin();
  void _showDialog() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return successDialog(context);
      },
    );
  }

  Dialog successDialog(context) {
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0)), //this right here
      child: Container(
        height: 350.0,
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const Icon(
                Icons.check_box,
                color: Colors.green,
                size: 90,
              ),
              const SizedBox(height: 15),
              const Text(
                'Payment has successfully',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 17.0,
                    fontWeight: FontWeight.bold),
              ),
              const Text(
                'been made',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 17.0,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              const Text(
                "Your payment has been successfully",
                style: TextStyle(fontSize: 13),
              ),
              const Text("processed.", style: TextStyle(fontSize: 13)),
              const SizedBox(
                height: 15,
              ),
              ElevatedButton(
                  child: const Text('Ok'),
                  onPressed: () => Navigator.pop(context))
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return errorDialog(context);
      },
    );
  }

  Dialog errorDialog(context) {
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0)), //this right here
      child: Container(
        height: 350.0,
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const <Widget>[
              Icon(
                Icons.cancel,
                color: Colors.red,
                size: 90,
              ),
              SizedBox(height: 15),
              Text(
                'Failed to process payment',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 17.0,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 15),
              Text(
                "Error in processing payment, please try again",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getReference() {
    paymentRef = '';
    String platform;
    if (Platform.isIOS) {
      platform = 'iOS';
    } else {
      platform = 'Android';
    }
    paymentRef =
        'ChargedFrom${platform}_${DateTime.now().millisecondsSinceEpoch}';
    return paymentRef;
  }

  int convertToInt(ranks) {
    return (ranks).round();
  }

  chargeCard(paymentMethod) async {
    setState(() {
      isGeneratingCode = !isGeneratingCode;
    });

    // String accessCode = "sk_test_58e5b7fab484bda3aab4289ce5a50345209c8dac";

    setState(() {
      isGeneratingCode = !isGeneratingCode;
    });

    Charge charge = Charge()
      ..amount = convertToInt(totalAmt * 100)
      ..reference = _getReference()
      // ..accessCode = accessCode
      ..email = widget.userEmail;

    CheckoutResponse response = await plugin.checkout(
      context,
      method: CheckoutMethod.card, // Defaults to CheckoutMethod.selectable
      charge: charge,
    );

    if (response.status == true) {
      // ============ CREATE THE RECORD ON THE SERVER ================
      await processCustomerOrder(paymentMethod, response.status);

      _showDialog();
    } else {
      _showErrorDialog();
    }
  }
  // ===================== PAY STACK PAYMENT ENDS HERE ========================

  processCustomerOrder(paymentMethod, paymentStatus) async {
    var userInfo = {
      'userName': widget.userName,
      'userEmail': widget.userEmail,
      'token': widget.token,
      'custId': widget.custId,
    };
    var serviceProvider = Provider.of<DataProcessing>(context, listen: false);
    // CALL THE DIALOG TO PREVENT USER FROM THE UI UNTIL DATA IS SAVED TO THE SERVER
    setState(() {
      serviceProvider.isLoadDialogBox = true;
      serviceProvider.buildShowDialog(context);
    });

    // PROCEED TO MAKE PAYMENT
    var serverResponse = await serviceProvider.processOrder(
      widget.userName,
      widget.userEmail,
      shippingData(
        '${shippingRecord['address']}',
        '${shippingRecord['city']}',
        '${shippingRecord['state']}',
        '${shippingRecord['zipcode']}',
        '${shippingRecord['mobile']}',
        '${shippingRecord['altMobile']}',
        '${shippingRecord['optionalNote']}',
      ),
      paymentMethod,
      widget.token,
      getGrandTotalAmt(totalAmt - 900),
      paymentRef,
      paymentStatus,
      {}, // THIS IS ONLY REQUIRED FOR GUEST USER
    );
    // CALL THE DIALOG TO ALLOW USER PERFORM OPERATION ON THE UI

    serviceProvider.isLoadDialogBox = false;
    serviceProvider.buildShowDialog(context);

    if (serverResponse == 'transaction completed') {
      serviceProvider.customAlertDialogMsg(
          context,
          'Thanks for shopping with us!',
          "Your order have been received and will be delivered under 24 hrs",
          serverResponse,
          userInfo);
      serviceProvider.isApiLoaded = false;
    } else if (serverResponse == "item(s) not valid") {
      serviceProvider.customAlertDialogMsg(
          context,
          'System message',
          'Process was not complete. Kindly remove invalid item from your cart.',
          serverResponse,
          userInfo);
    } else {
      serviceProvider.customAlertDialogMsg(context, 'System message',
          serverResponse['serverResponse'], serverResponse, userInfo);
    }
  }
}

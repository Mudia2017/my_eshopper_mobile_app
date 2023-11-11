import 'dart:io';

import 'package:eshopper_mobile_app/componets/data_computation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_paystack/flutter_paystack.dart';

class CheckOutGuest extends StatefulWidget {
  @override
  _CheckOutGuestState createState() => _CheckOutGuestState();
}

class _CheckOutGuestState extends State<CheckOutGuest> {
  void initState() {
    plugin.initialize(publicKey: paystackPublicKey);
    super.initState();
  }

  Map<String, dynamic> shippingRecord = {};
  String custShippingName = '';
  Map<String, dynamic> cartPtdData = {};
  List verifyPtdList = [];
  double amt = 0;
  String paymentRef = '';

  var userInfo = {'userName': 'Guest', 'userEmail': '', 'token': ''};

  // SINCE I REALLY DON'T KNOW HOW SHIPPING FEE WILL BE CALCULATED,
  // I DECIDED TO JUST PLACE A FLATE RATE OF 900 FOR EVERY SUCCESSFUL TRANSACTION
  double getGrandTotalAmt(double totalAmt) {
    var total = totalAmt + 900.00;
    double grandTotal = double.parse((total).toStringAsFixed(2));
    return grandTotal;
  }

  shippingData(String name, email, address, city, state, zipcode, mobile,
      altMobile, optionalNote) {
    var shippingAddress = {
      "name": name,
      "email": email,
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

  Widget displayRadioButton(String paymentMethod, String passedValue) {
    String selectedRadio = '';
    bool colorSelected = false;
    var serviceProvider = Provider.of<DataProcessing>(context);
    var userInfo = {
      'userName': textfieldControllerGuestName,
      'userEmail': textfieldControllerGuestEmail,
      'token': ''
    };
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
            // ===== PAY ON DELIVERY METHOD ===========
            await processGuestOrder(
                textfieldControllerGuestName.text,
                textfieldControllerGuestEmail.text,
                shippingData(
                    custShippingName,
                    '${shippingRecord['email']}',
                    '${shippingRecord['address']}',
                    '${shippingRecord['city']}',
                    '${shippingRecord['state']}',
                    '${shippingRecord['zipcode']}',
                    '${shippingRecord['mobile']}',
                    '${shippingRecord['altMobile']}',
                    '${shippingRecord['optionalNote']}'),
                paymentMethod,
                false,
                verifyPtdList);
            // // ===== PAY ON DELIVERY METHOD ===========
            // // CALL THE DIALOG TO PREVENT USER FROM THE UI UNTIL DATA IS SAVED TO THE SERVER
            // setState(() {
            //   serviceProvider.isLoadDialogBox = true;
            //   serviceProvider.buildShowDialog(context);
            // });

            // // PROCEED TO MAKE PAYMENT THROUGH API CALL
            // var serverResponse = await serviceProvider.processOrder(
            //     textfieldControllerGuestName.text,
            //     textfieldControllerGuestEmail.text,
            //     shippingData(
            //       custShippingName,
            //       '${shippingRecord['email']}',
            //       '${shippingRecord['address']}',
            //       '${shippingRecord['city']}',
            //       '${shippingRecord['state']}',
            //       '${shippingRecord['mobile']}',
            //       '${shippingRecord['altMobile']}',
            //       '${shippingRecord['optionalNote']}',
            //     ),
            //     paymentMethod,
            //     '',
            //     getGrandTotalAmt(serviceProvider.totalAmt - 900),
            //     verifyPtdList);
            // // CALL THE DIALOG TO ALLOW USER PERFORM OPERATION ON THE UI

            // serviceProvider.isLoadDialogBox = false;
            // serviceProvider.buildShowDialog(context);

            // if (serverResponse == 'transaction completed') {
            //   serviceProvider.clear();
            //   serviceProvider.removeAllCartRecord();
            //   serviceProvider.customAlertDialogMsg(
            //       context,
            //       'Thanks for shopping with us!',
            //       "Your order have been received and will be delivered under 24 hrs",
            //       serverResponse,
            //       userInfo);
            //   serviceProvider.isApiLoaded = false;
            // } else if (serverResponse == "item(s) not valid") {
            //   serviceProvider.customAlertDialogMsg(
            //       context,
            //       'System message',
            //       'Process was not complete. Kindly remove invalid item from your cart.',
            //       serverResponse,
            //       userInfo);
            // } else {
            //   serviceProvider.customAlertDialogMsg(
            //       context,
            //       'System message',
            //       'Error occurred while processing. Please try again',
            //       serverResponse,
            //       userInfo);
            // }
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

  processGuestOrder(guestName, guestEmail, Map<String, dynamic> shippingData,
      paymentMethod, paymentStatus, verifyPtdList) async {
    var serviceProvider = Provider.of<DataProcessing>(context, listen: false);
    // ===== PAY ON DELIVERY METHOD ===========
    // CALL THE DIALOG TO PREVENT USER FROM THE UI UNTIL DATA IS SAVED TO THE SERVER
    setState(() {
      serviceProvider.isLoadDialogBox = true;
      serviceProvider.buildShowDialog(context);
    });

    // PROCEED TO MAKE PAYMENT THROUGH API CALL
    var serverResponse = await serviceProvider.processOrder(
        textfieldControllerGuestName.text,
        textfieldControllerGuestEmail.text,
        shippingData,
        paymentMethod,
        '',
        getGrandTotalAmt(serviceProvider.totalAmt - 900),
        paymentRef,
        paymentStatus,
        verifyPtdList);
    // CALL THE DIALOG TO ALLOW USER PERFORM OPERATION ON THE UI

    serviceProvider.isLoadDialogBox = false;
    serviceProvider.buildShowDialog(context);

    if (serverResponse == 'transaction completed') {
      serviceProvider.clear();
      serviceProvider.removeAllCartRecord();
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
      serviceProvider.customAlertDialogMsg(
          context,
          'System message',
          'Error occurred while processing. Please try again',
          serverResponse,
          userInfo);
    }
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
      ..amount = convertToInt(amt * 100)
      ..reference = _getReference()
      // ..accessCode = accessCode
      ..email = textfieldControllerGuestEmail.text;

    CheckoutResponse response = await plugin.checkout(
      context,
      method: CheckoutMethod.card, // Defaults to CheckoutMethod.selectable
      charge: charge,
    );
    if (response.status == true) {
      // ============ CREATE THE RECORD ON THE SERVER ================
      await processGuestOrder(
          textfieldControllerGuestName.text,
          textfieldControllerGuestEmail.text,
          shippingData(
              custShippingName,
              '${shippingRecord['email']}',
              '${shippingRecord['address']}',
              '${shippingRecord['city']}',
              '${shippingRecord['state']}',
              '${shippingRecord['zipcode']}',
              '${shippingRecord['mobile']}',
              '${shippingRecord['altMobile']}',
              '${shippingRecord['optionalNote']}'),
          paymentMethod,
          response.status,
          verifyPtdList);

      _showDialog();
    } else {
      _showErrorDialog();
    }
  }
  // ===================== PAY STACK PAYMENT ENDS HERE ========================

  @override
  Widget build(BuildContext context) {
    var serviceProvider = Provider.of<DataProcessing>(context);
    amt = serviceProvider.totalAmt;
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
        padding: const EdgeInsets.symmetric(horizontal: 5),
        children: [
          Container(
            child: Column(
              children: [
                Card(
                  elevation: 5,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Shipping details',
                              style: GoogleFonts.sora().copyWith(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                _displayDialogAddShippingAddress(context);
                              },
                              child: const Text('Add Shipping'),
                            ),
                          ],
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
                            if ('${shippingRecord['email']}' != '')
                              Text(
                                  '${shippingRecord['email']}' == 'null'
                                      ? ''
                                      : '${shippingRecord['email']}',
                                  style: GoogleFonts.sora().copyWith()),
                            const SizedBox(
                              height: 5,
                            ),
                            if ('${shippingRecord['address']}' != '')
                              Text(
                                  '${shippingRecord['address']}' == 'null'
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
                            if ('${shippingRecord['zipcode']}' != '')
                              Text(
                                  '${shippingRecord['zipcode']}' == 'null'
                                      ? ''
                                      : '${shippingRecord['zipcode']}',
                                  style: GoogleFonts.sora().copyWith()),
                            const SizedBox(
                              height: 5,
                            ),
                            if ('${shippingRecord['mobile']}' != '')
                              Text(
                                  '${shippingRecord['mobile']}' == 'null'
                                      ? ''
                                      : '${shippingRecord['mobile']}',
                                  style: GoogleFonts.sora().copyWith()),
                            const SizedBox(
                              height: 5,
                            ),
                            if ('${shippingRecord['altMobile']}' != '')
                              Text(
                                  '${shippingRecord['altMobile']}' == 'null'
                                      ? ''
                                      : '${shippingRecord['altMobile']}',
                                  style: GoogleFonts.sora().copyWith()),
                            const SizedBox(
                              height: 5,
                            ),
                            if ('${shippingRecord['optionalNote']}' != '')
                              Text(
                                  '${shippingRecord['optionalNote']}' == 'null'
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
                  ),
                ),
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Subtotal',
                              style: GoogleFonts.sora()
                                  .copyWith(fontWeight: FontWeight.normal),
                            ),
                            Text(
                              '₦ ' +
                                  serviceProvider.formattedNumber(
                                      serviceProvider.totalAmt),
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Shipping',
                              style: GoogleFonts.sora()
                                  .copyWith(fontWeight: FontWeight.normal),
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total',
                              style: GoogleFonts.sora()
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '₦ ' +
                                  serviceProvider.formattedNumber(
                                      getGrandTotalAmt(
                                          serviceProvider.totalAmt)),
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
                        primary: Colors.orange[400],
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
                      onPressed: () async {
                        // BEFORE PROCEEDING TO PAYMENT,
                        // CHECK THAT THE CUSTOMER'S SHIPPING NAME AND ADDRESS IS NOT EMPTY
                        // CHECK THAT THE TOTAL AMOUNT IS NOT EMPTY OR ZERO

                        if ((custShippingName.isNotEmpty) &&
                            '${shippingRecord['email']}'.isNotEmpty &&
                            '${shippingRecord['address']}'.isNotEmpty &&
                            '${shippingRecord['city']}'.isNotEmpty &&
                            '${shippingRecord['state']}'.isNotEmpty &&
                            '${shippingRecord['mobile']}'.isNotEmpty &&
                            getGrandTotalAmt(serviceProvider.totalAmt) > 0) {
                          // PROCEED TO MAKE PAYMENT
                          // SINCE CART ITEM HAVE BEEN IN THE SHARED PREFERENCE
                          // CHECK FOLLOWING ITEM(S) WITH THE DATABASE:
                          // 1. THAT THE CART ITEM IS CURRENTLY IN STOCK.
                          // 2. THAT THE PRICE OF THE CART ITEM TALLY WITH DB PRICE.
                          // 3. THAT THE ITEM IS ACTIVE
                          // 4. THAT THE STORE ITEM IS ACTIVE
                          verifyPtdList = [];
                          for (var x = 0;
                              x < serviceProvider.items.length;
                              x++) {
                            cartPtdData = {
                              'guestCartPtdId': serviceProvider.items.values
                                  .toList()[x]
                                  .pdtid,
                              'guestCartPtdPrice': serviceProvider.items.values
                                  .toList()[x]
                                  .cartProductPrice,
                              'guestCartPtdQuantity': serviceProvider
                                  .items.values
                                  .toList()[x]
                                  .cartProductQuantity,
                              'guestCartOutOfStock': serviceProvider
                                  .items.values
                                  .toList()[x]
                                  .cartProdOutOfStock,
                              'guestCartActivePtd': serviceProvider.items.values
                                  .toList()[x]
                                  .cartActivePtd,
                              'guestCartActiveStore': serviceProvider
                                  .items.values
                                  .toList()[x]
                                  .cartActiveStore,
                            };
                            verifyPtdList.add(cartPtdData);
                          }

                          // CALL THE DIALOG TO PREVENT USER FROM THE UI UNTIL DATA IS SAVED TO THE SERVER
                          setState(() {
                            serviceProvider.isLoadDialogBox = true;
                            serviceProvider.buildShowDialog(context);
                          });

                          var serverResponse = await serviceProvider
                              .guestVerifyCartItems(verifyPtdList);

                          // CALL THE DIALOG TO ALLOW USER PERFORM OPERATION ON THE UI

                          serviceProvider.isLoadDialogBox = false;
                          serviceProvider.buildShowDialog(context);

                          if (serverResponse[0] == 'valid') {
                            _showModalBottomSheet(context);
                          } else if (serverResponse[0] != 'valid') {
                            // THIS CONDITION EXECUTE ANYTIME ANY OF THE FOUR
                            // CONDITION MENTION ABOVE IS NOT VALID
                            for (var x = 0;
                                x < serviceProvider.items.values.length;
                                x++) {
                              for (var serverResp in serverResponse) {
                                if (int.parse(serviceProvider.items.values
                                        .toList()[x]
                                        .pdtid) ==
                                    serverResp['ptdId']) {
                                  serviceProvider.updateGuestCartItem(
                                      serverResp['ptdId'].toString(),
                                      double.parse(serverResp['unit_price']),
                                      serverResp['out_of_stock'].toString(),
                                      serverResp['activePtd'].toString(),
                                      serverResp['activeStore'].toString());
                                }
                              }
                            }
                            serviceProvider.customAlertDialogMsg(
                                context,
                                'Cart validation error',
                                'Some items in your cart are not valid. Kindly adjust your shopping cart!',
                                'invalid guest cart',
                                userInfo);
                          }
                        } else if (getGrandTotalAmt(serviceProvider.totalAmt) <=
                            0) {
                          serviceProvider
                              .warningToastMassage('Invalid transaction');
                        } else {
                          serviceProvider.warningToastMassage(
                              "Kindly provide shipping information before proceeding");
                        }
                      },
                    ),
                  ),
                )
              ],
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

  // ========== GUEST INFO AND SHIPPING ADDRESS ==============
  TextEditingController textfieldControllerGuestName = TextEditingController();
  TextEditingController textfieldControllerGuestEmail = TextEditingController();
  TextEditingController textfieldControllerAddress = TextEditingController();
  TextEditingController textfieldControllerCity = TextEditingController();
  TextEditingController textfieldControllerState = TextEditingController();
  TextEditingController textfieldControllerZipcode = TextEditingController();
  TextEditingController textfieldControllerMobile = TextEditingController();
  TextEditingController textfieldControllerAltMobile = TextEditingController();
  TextEditingController textfieldControllerOptionalNote =
      TextEditingController();

  _displayDialogAddShippingAddress(BuildContext context) async {
    textfieldControllerGuestName =
        TextEditingController(text: custShippingName);
    textfieldControllerGuestEmail = TextEditingController(
        text: '${shippingRecord['email']}'.toString() == 'null'
            ? ''
            : '${shippingRecord['email']}'.toString());
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
                    controller: textfieldControllerGuestName,
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      hintText: 'Customer full name',
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

                  // TEXT-FORM-FIELD FOR GUEST EMAIL
                  TextFormField(
                    maxLines: null,
                    controller: textfieldControllerGuestEmail,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      hintText: 'Customer email',
                      hintStyle: GoogleFonts.sora().copyWith(),
                    ),
                    onSaved: (custEmail) {
                      custShippingName = custEmail.toString();
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter customer email';
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
                      hintText: 'City address',
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

                  // TEXT-FORM-FIELD FOR STATE
                  TextFormField(
                    maxLines: null,
                    controller: textfieldControllerZipcode,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Zipcode',
                      hintText: 'Zipcode',
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
                      hintText: 'Mobile number',
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
                    keyboardType: TextInputType.multiline,
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
                          custShippingName = textfieldControllerGuestName.text;
                          shippingRecord['email'] =
                              textfieldControllerGuestEmail.text;
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
                      }
                    },
                  )
                ],
              )
            ],
          );
        });
  }
}

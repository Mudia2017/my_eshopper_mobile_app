import 'dart:convert';

import 'package:eshopper_mobile_app/componets/data_computation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class Refund extends StatefulWidget {
  final String orderNo, token;
  Refund({required this.orderNo, required this.token});
  @override
  _RefundState createState() => _RefundState();
}

class _RefundState extends State<Refund> {
  void initState() {
    super.initState();
    loadRefundOrder();
  }

  String selectedValue = '---';
  List refundOrderItem = [];
  double totalAmt = 0;
  bool isDoneLoading = false;
  bool isErrorLoading = false;
  double totalRefundAmt = 0;
  bool checkedValue = false;
  bool isPaidOrder = false;
  String reasonForRefund = '';
  String refundPrivateNote = '';
  // ============= API USED TO GET OF THE ORDER SELECTED ============
  loadRefundOrder() async {
    var data = {'transId': widget.orderNo};
    var response = await http.post(
      Uri.parse(
          '${dotenv.env['URL_ENDPOINT']}/apis/v1/homePage/api_adminProcessRefundOrder/'),
      body: jsonEncode(data),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Token ${widget.token}",
      },
    );

    try {
      if (response.statusCode == 200) {
        var adminRefundOrder = json.decode(response.body);
        setState(() {
          refundOrderItem = adminRefundOrder['refundOrderItem'];
          totalAmt = double.parse(adminRefundOrder['refundInfo']['totalAmt']);
          isPaidOrder = adminRefundOrder['refundInfo']['isPaidOrder'];
          if (adminRefundOrder['refundInfo']['reasonForRefund'] == null) {
            reasonForRefund = '';
          } else {
            reasonForRefund = adminRefundOrder['refundInfo']['reasonForRefund'];
          }
          if (adminRefundOrder['refundInfo']['refundPrivateNote'] == null) {
            refundPrivateNote = '';
          } else {
            refundPrivateNote =
                adminRefundOrder['refundInfo']['refundPrivateNote'];
          }

          if (adminRefundOrder['refundInfo']['totalRefundAmt'] == 0) {
            totalRefundAmt = 0;
            _refundCheckBox();
          } else {
            totalRefundAmt =
                double.parse(adminRefundOrder['refundInfo']['totalRefundAmt']);
            _refundCheckBox();
          }
          if (reasonForRefund.isNotEmpty) {
            selectedValue = reasonForRefund;
          }

          isDoneLoading = true;
        });
      } else {
        isDoneLoading = false;
        isErrorLoading = true;
      }
    } catch (error) {
      isDoneLoading = false;
      isErrorLoading = true;
      // rethrow;
    }
  }

  _refundCheckBox() {
    // I WANT TO CHECK IF THE 'REFUND FLL AMT' CHECKBOX SHOULD BE CHECKED OR NOT
    if (totalRefundAmt == totalAmt) {
      checkedValue = true;
    } else {
      checkedValue = false;
    }
  }

  balanceAmt() {
    double amountBalance = 0;
    amountBalance = totalAmt - totalRefundAmt;
    return amountBalance;
  }

  // CONTROLLER AND SHOW DIALOG ALERT USED TO WRITE REFUND PRIVATE NOTE
  TextEditingController textfieldControllerRefundPrivateNote =
      TextEditingController();
  _dialogFormRefundPrivateNote(BuildContext, context) async {
    final _formKey = GlobalKey<FormState>();

    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            scrollable: true,
            title: Center(
              child: Text(
                'Refund Private Note',
                style: GoogleFonts.sora().copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            content: Form(
              key: _formKey,
              child: Column(
                children: [
                  //
                  if (reasonForRefund != '')
                    TextFormField(
                      controller: textfieldControllerRefundPrivateNote,
                      keyboardType: TextInputType.multiline,
                      maxLines: 7,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Reason for refund',
                        hintText: 'Your reason for refunding payment',
                        hintStyle: GoogleFonts.sora().copyWith(),
                      ),
                    ),
                  if (reasonForRefund == '')
                    TextFormField(
                      controller: textfieldControllerRefundPrivateNote,
                      keyboardType: TextInputType.multiline,
                      maxLines: 7,
                      decoration: InputDecoration(
                        labelText: 'Reason for refund',
                        hintText: 'Your reason for refunding payment',
                        hintStyle: GoogleFonts.sora().copyWith(),
                      ),
                      validator: (value) {
                        if (selectedValue == 'others' &&
                            (value == null || value.isEmpty)) {
                          return "Since 'Others' was selected, please give reason for refund!";
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
                    onPressed: () {
                      setState(() {
                        textfieldControllerRefundPrivateNote.text = '';
                      });
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel'),
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.grey)),
                  ),
                  if (reasonForRefund != '')
                    ElevatedButton(
                      onPressed: null,
                      child: const Text('Ok'),
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Colors.orange.shade100)),
                    ),
                  if (reasonForRefund == '')
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          // IF COMPLUSORY FIELDS ARE VALID, THE INPUT DATA
                          // IS COLLECTED ELSE RAISE AN INVALID FIELD
                          setState(() {
                            textfieldControllerRefundPrivateNote.text;
                          });
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

  // CONTROLLER AND SHOW DIALOG ALERT USED TO ENTER REFUND AMOUNT
  TextEditingController textfieldControllerRefundAmount =
      TextEditingController();
  _dialogFormRefundAmount(BuildContext, context, isAdminUpdateRefund, token,
      itemRowId, transId, lineTotal) async {
    var serviceProvider = Provider.of<DataProcessing>(context, listen: false);
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            scrollable: true,
            title: Center(
              child: Text(
                'Amount to Refund',
                style: GoogleFonts.sora().copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            content: Form(
              child: TextFormField(
                controller: textfieldControllerRefundAmount,
                keyboardType: TextInputType.phone,
                maxLines: 1,
                decoration: InputDecoration(
                  labelText: "Refund amount in 'NGN'",
                  hintText: 'The Amount you wish to refund for an item',
                  hintStyle: GoogleFonts.sora().copyWith(),
                ),
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
                      // CHECKING TO ENSURE AMOUNT FIELD IS NOT EMPTY WHEN UPDATING
                      if (textfieldControllerRefundAmount.text.isNotEmpty) {
                        // CHECKING TO ENSURE THAT AMOUNT ENTERED IS NOT GREATER THAN ITEM PRICE
                        if (double.parse(textfieldControllerRefundAmount.text) >
                            double.parse(lineTotal)) {
                          serviceProvider.warningToastMassage(
                              'Amount entered is more than item price!');
                        } else {
                          // CALL THE DIALOG TO PREVENT USER FROM THE UI UNTIL DATA IS SAVED TO THE SERVER
                          setState(() {
                            serviceProvider.isLoadDialogBox = true;
                            serviceProvider.buildShowDialog(context);
                          });

                          // UPDATE THE AMOUNT IN THE BACKEND DB BEFORE POPPING
                          bool isAdminUpdatedRefundRecord =
                              await serviceProvider.adminUpdateRefundOrder(
                            isAdminUpdateRefund,
                            token,
                            itemRowId,
                            textfieldControllerRefundAmount.text,
                            transId,
                            '',
                            '',
                          );

                          // CALL THE DIALOG TO ALLOW USER PERFORM OPERATION ON THE UI

                          serviceProvider.isLoadDialogBox = false;
                          serviceProvider.buildShowDialog(context);

                          if (isAdminUpdatedRefundRecord == true) {
                            Navigator.pop(context);
                          } else {
                            serviceProvider
                                .warningToastMassage('Refund was not updated!');
                          }
                        }
                      } else {
                        serviceProvider.warningToastMassage(
                            'Amount field most not be empty!');
                      }
                    },
                    child: const Text('Update'),
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

  // ======== ALERT DIALOG USED TO CONFIRM REFUND SUBMITION =========
  Future popDialogConfirmRefundSubmit(
      BuildContext context, titleMsg, contentMsg, refundNote, reasonForRefund) {
    var serviceProvider = Provider.of<DataProcessing>(context, listen: false);
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              scrollable: true,
              title: Center(
                child: Text(
                  titleMsg,
                  style: GoogleFonts.sora()
                      .copyWith(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              content: Text(
                contentMsg,
                style: GoogleFonts.sora().copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade700),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    MaterialButton(
                        color: Colors.grey.shade700,
                        elevation: 0,
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        }),
                    MaterialButton(
                        color: Colors.orange,
                        elevation: 0,
                        child: const Text(
                          'Continue',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        ),
                        onPressed: () async {
                          // CALL THE DIALOG TO PREVENT USER FROM THE UI UNTIL DATA IS SAVED TO THE SERVER
                          setState(() {
                            serviceProvider.isLoadDialogBox = true;
                            serviceProvider.buildShowDialog(context);
                          });

                          var response =
                              await serviceProvider.adminUpdateRefundOrder(
                                  true,
                                  widget.token,
                                  '',
                                  totalRefundAmt,
                                  widget.orderNo,
                                  refundNote,
                                  reasonForRefund);

                          // CALL THE DIALOG TO ALLOW USER PERFORM OPERATION ON THE UI

                          setState(() {
                            serviceProvider.isLoadDialogBox = false;
                            serviceProvider.buildShowDialog(context);
                          });

                          Navigator.pop(context);
                          if (response == true) {
                            serviceProvider
                                .toastMessage('Refund submitted successful.');
                          } else {
                            serviceProvider
                                .warningToastMassage('Fail to submit refund!');
                          }
                        }),
                  ],
                ),
              ],
            );
          });
        });
  }

  // ============= USED TO PERFORM FULL AMOUNT CEHECKBOX ============
  refundCheckBox() async {
    var serviceProvider = Provider.of<DataProcessing>(context, listen: false);

    // CALL THE DIALOG TO PREVENT USER FROM THE UI UNTIL DATA IS SAVED TO THE SERVER
    setState(() {
      serviceProvider.isLoadDialogBox = true;
      serviceProvider.buildShowDialog(context);
    });
    if (checkedValue == true) {
      // FULL AMOUNT IN THIS ORDER WILL BE REFUNDED

      bool isAdminUpdatedRefundRecord =
          await serviceProvider.adminUpdateRefundOrder(
        true,
        widget.token,
        '',
        'full_refund',
        widget.orderNo,
        '',
        '',
      );
      // CALL THE DIALOG TO ALLOW USER PERFORM OPERATION ON THE UI

      serviceProvider.isLoadDialogBox = false;
      serviceProvider.buildShowDialog(context);

      if (isAdminUpdatedRefundRecord == false) {
        serviceProvider.warningToastMassage('Error occur');
      }
    } else if (checkedValue == false) {
      // UNCHECKING THE 'REFUND FULL AMT' WILL RETURN ALL FULL REFUNDED AMT

      bool isAdminUpdatedRefundRecord =
          await serviceProvider.adminUpdateRefundOrder(
        true,
        widget.token,
        '',
        'no_refund',
        widget.orderNo,
        '',
        '',
      );
      // CALL THE DIALOG TO ALLOW USER PERFORM OPERATION ON THE UI

      serviceProvider.isLoadDialogBox = false;
      serviceProvider.buildShowDialog(context);

      if (isAdminUpdatedRefundRecord == false) {
        serviceProvider.warningToastMassage('Error occur');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var serviceProvider = Provider.of<DataProcessing>(context);
    // THIS CONDITION IS PLACE TO UPDATE REFUND ITEMS THE ANY
    // ACTION IS MADE
    if (serviceProvider.isAdminUpdatedRefundRecord == true &&
        isDoneLoading == false) {
      refundOrderItem = serviceProvider.updatedRefundOrderItem;
      totalRefundAmt = serviceProvider.updatedTotalRefundAmt;
      _refundCheckBox(); // CHECKING IF 'FULL REFUND AMT CHECKBOX' SHOULD BE CHECKED OR UNCHECKED
      reasonForRefund = serviceProvider.updatedReasonForRefund;
      refundPrivateNote = serviceProvider.updatedRefundPrivateNote;
    } else {
      isDoneLoading = false;
      serviceProvider.isAdminUpdatedRefundRecord = false;
    }

    // 'WILL_POP_SCOPE' IS USED TO LISTEN TO BACK-ARROW ON THE APPBAR OR
    // BACK BUTTON ON ANDROID PHONE
    return WillPopScope(
      // WILL CHECK IF REFUND FORM WAS PROCESS HALFWAY. IF THIS IS TRUE,
      // A DIALOG BOX IS POP UP TO CONFIRM IF THE USER WANT TO LEAVE THE PAGE
      onWillPop: () async {
        if (totalRefundAmt > 0 && reasonForRefund == '') {
          bool isResponse = await serviceProvider.popWarningConfirmActionYesNo(
              context,
              'Warning',
              'Refund process not completed.\nThe record was not submitted.\nDo you want to leave this page?');
          if (isResponse == true) {
            //trigger leaving and use own data
            Navigator.pop(context, false);
          }
        } else {
          //trigger leaving and use own data
          Navigator.pop(context, false);
        }
        //we need to return a future
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          // automaticallyImplyLeading: false,
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Refund Summary',
                      style: GoogleFonts.sora().copyWith(
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                      ),
                    ),
                    Row(
                      children: [
                        // CHECKING TO KNOW IF REASON FOR REFUND HAVE BEEN SAVED ON
                        // DB. IF IT'S TRUE, IT'S USED TO DISABLE CHECKBOX
                        if (reasonForRefund != '')
                          Checkbox(
                            value: checkedValue,
                            onChanged: null,
                          ),
                        if (reasonForRefund == '')
                          Checkbox(
                            value: checkedValue,
                            onChanged: (newValue) {
                              setState(
                                () {
                                  checkedValue = newValue!;
                                  refundCheckBox();
                                },
                              );
                            },
                          ),
                        Text(
                          'Refund full amt',
                          style: GoogleFonts.sora().copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),
                  ],
                ),

                // USED TO DETERMIN WHICH REFUND STATUS TO DISPLAY
                if (reasonForRefund != '')
                  Row(children: [
                    const Text(
                      'Status:',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      'CLOSED',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Colors.red.shade800,
                      ),
                    )
                  ]),

                if (reasonForRefund == '')
                  Row(children: [
                    const Text(
                      'Status:',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      'OPEN',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Colors.green.shade800,
                      ),
                    )
                  ]),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // REASON FOR REFUND IS USED TO CHECK IF THEIR IS TEXT COMING
                    // FROM THE DB. IF THERE IS COMMENT FROM DB, A COMMENT ICON WILL
                    // DISPLAY ON THE OUTLINE BUTTON
                    if (refundPrivateNote != '')
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            // IF THEIR IS REFUND_PRIVATE_NOTE, ASSIGN THE VALUE
                            // TO TEXTFIELD CONTROLLER SO THAT IT CAN DISPLAY ON
                            // THE DIALOG_FORM_REFUND_PRIVATE_NOTE
                            textfieldControllerRefundPrivateNote.text =
                                refundPrivateNote;
                            _dialogFormRefundPrivateNote(BuildContext, context);
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Private Note',
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
                      ),
                    if (refundPrivateNote == '')
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            _dialogFormRefundPrivateNote(BuildContext, context);
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Private Note',
                                style: GoogleFonts.tinos().copyWith(
                                  fontSize: 10,
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              if (textfieldControllerRefundPrivateNote
                                  .text.isNotEmpty)
                                const Icon(
                                  Icons.comment,
                                  size: 15,
                                )
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(
                      width: 2,
                    ),
                    if (reasonForRefund != '') disableDropDownMenu(),
                    if (reasonForRefund == '') dropDownMenu(),
                  ],
                ),
                refundSummary(),
                const Divider(
                  thickness: 5,
                ),
                detailHeader(),
                const Divider(
                  thickness: 0.5,
                  color: Colors.black54,
                ),
                Flexible(
                  child: refundOrderItem.isNotEmpty
                      ? ListView.builder(
                          itemCount: refundOrderItem.length,
                          itemBuilder: (BuildContext cxt, int x) =>
                              detailContent(
                            refundOrderItem.toList()[x]['itemRowId'].toString(),
                            refundOrderItem.toList()[x]['ptdImage'].toString(),
                            refundOrderItem.toList()[x]['ptdName'].toString(),
                            refundOrderItem.toList()[x]['storeName'].toString(),
                            refundOrderItem.toList()[x]['qty'].toString(),
                            refundOrderItem.toList()[x]['lineTotal'].toString(),
                            refundOrderItem.toList()[x]['refundAmt'].toString(),
                            refundOrderItem.toList()[x]['isRefundAmt'],
                          ),
                        )
                      : const Center(
                          child: CircularProgressIndicator(),
                        ),
                ),
                bottomContent(),
              ],
            )),
      ),
    );
  }

  Container titleSection() {
    return Container(
      child: Center(
        child: Row(
          children: [
            const Text(
              "Refund order: ",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 19.0,
                  fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: Text(
                widget.orderNo,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                style: GoogleFonts.sora().copyWith(
                  color: Colors.grey.shade700,
                  fontSize: 15.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container refundSummary() {
    var serviceProvider = Provider.of<DataProcessing>(context);
    return Container(
      child: Container(
        color: Colors.black12,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Amount',
                    style: GoogleFonts.sora().copyWith(
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '₦ ' + serviceProvider.formattedNumber(totalAmt),
                    style: GoogleFonts.tinos().copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Refund amount',
                    style: GoogleFonts.sora().copyWith(
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '₦ ' + serviceProvider.formattedNumber(totalRefundAmt),
                    style: GoogleFonts.tinos().copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade900),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Balance due',
                    style: GoogleFonts.sora().copyWith(
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '₦ ' + serviceProvider.formattedNumber(balanceAmt()),
                    style: GoogleFonts.tinos().copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber.shade100,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<DropdownMenuItem<String>> get dropdownItems {
    List<DropdownMenuItem<String>> menuItems = [
      const DropdownMenuItem(
        child: Text(
          'Select reason for refund',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        value: '---',
      ),
      const DropdownMenuItem(
        child: Text(
          'Could not ship',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        value: 'Could not ship',
      ),
      const DropdownMenuItem(
        child: Text(
          'Customer return',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        value: 'Customer return',
      ),
      const DropdownMenuItem(
        child: Text(
          'Buyer cancelled',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        value: 'Buyer cancelled',
      ),
      const DropdownMenuItem(
        child: Text(
          'Different item',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        value: 'Different item',
      ),
      const DropdownMenuItem(
        child: Text(
          'Deliver late by carrier',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        value: 'Deliver late by carrier',
      ),
      const DropdownMenuItem(
        child: Text(
          'Product not as described',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        value: 'Product not as described',
      ),
      const DropdownMenuItem(
        child: Text(
          'Shipping address undeliverable',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        value: 'Shipping address undeliverable',
      ),
      const DropdownMenuItem(
        child: Text(
          'No inventory',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        value: 'No inventory',
      ),
      const DropdownMenuItem(
        child: Text(
          'Order not received',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        value: 'Order not received',
      ),
      const DropdownMenuItem(
        child: Text(
          'Pricing error',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        value: 'Pricing error',
      ),
      const DropdownMenuItem(
        child: Text(
          'Others',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        value: 'Others',
      ),
    ];
    return menuItems;
  }

  Container disableDropDownMenu() {
    return Container(
      child: DropdownButton(
        value: selectedValue,
        onChanged: null,
        items: dropdownItems,
      ),
    );
  }

  Container dropDownMenu() {
    return Container(
      child: DropdownButton(
        value: selectedValue,
        onChanged: (String? newValue) {
          setState(() {
            selectedValue = newValue!;
            if (selectedValue == 'others') {
              _dialogFormRefundPrivateNote(BuildContext, context);
            }
          });
        },
        items: dropdownItems,
      ),
    );
  }

  Container detailHeader() {
    return Container(
      child: Table(columnWidths: const {
        0: FlexColumnWidth(3),
        1: FlexColumnWidth(3),
        2: FlexColumnWidth(3),
        3: FlexColumnWidth(1),
        4: FlexColumnWidth(3),
        5: FlexColumnWidth(4),
        6: FlexColumnWidth(3),
      }, children: [
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
            'Store Name',
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
            'Line total',
            style: GoogleFonts.sora().copyWith(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent.shade700,
            ),
          ),
          Text(
            'Amt to refund',
            style: GoogleFonts.sora().copyWith(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent.shade700,
            ),
          ),
          const SizedBox()
        ])
      ]),
    );
  }

  Container detailContent(String itemRowId, image, ptdName, storeName, qty,
      lineTotal, refundAmt, isRefundAmt) {
    var serviceProvider = Provider.of<DataProcessing>(context);
    return Container(
        child: Column(
      children: [
        Table(
          columnWidths: const {
            0: FlexColumnWidth(3),
            1: FlexColumnWidth(3),
            2: FlexColumnWidth(3),
            3: FlexColumnWidth(1),
            4: FlexColumnWidth(3),
            5: FlexColumnWidth(4),
            6: FlexColumnWidth(3),
          },
          children: [
            TableRow(children: [
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
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                storeName,
                overflow: TextOverflow.ellipsis,
                maxLines: 3,
                style: GoogleFonts.sora().copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                qty,
                style: GoogleFonts.sora().copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '₦ ' + serviceProvider.formattedNumber(double.parse(lineTotal)),
                style: GoogleFonts.tinos().copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),

              // CHECKING IF REFUND HAVE BEEN SUBMITTED. IF THIS IS TRUE,
              // DISABLE 'OUTLINE BUTTON' BUTTON
              if (reasonForRefund != '')
                OutlinedButton(
                  onPressed: null,
                  child: Text(
                    isRefundAmt
                        ? '₦ ' +
                            serviceProvider
                                .formattedNumber(double.parse(refundAmt))
                        : '₦ 0.00',
                    style: GoogleFonts.tinos().copyWith(
                      fontSize: 10,
                    ),
                  ),
                ),
              if (reasonForRefund == '')
                OutlinedButton(
                  onPressed: () {
                    _dialogFormRefundAmount(BuildContext, context, true,
                        widget.token, itemRowId, widget.orderNo, lineTotal);
                  },
                  child: Text(
                    isRefundAmt
                        ? '₦ ' +
                            serviceProvider
                                .formattedNumber(double.parse(refundAmt))
                        : '₦ 0.00',
                    style: GoogleFonts.tinos().copyWith(
                      fontSize: 10,
                    ),
                  ),
                ),

              // CHECKING IF REFUND HAVE BEEN SUBMITTED. IF THIS IS TRUE,
              // DISABLE 'COPY MAX' BUTTON
              if (reasonForRefund != '')
                MaterialButton(
                  onPressed: null,
                  child: const Text(
                    'Copy Max',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                      color: Colors.yellow,
                    ),
                  ),
                  disabledColor: Colors.black38,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6.0)),
                ),
              if (reasonForRefund == '')
                MaterialButton(
                  onPressed: () async {
                    // CALL THE DIALOG TO PREVENT USER FROM THE UI UNTIL DATA IS SAVED TO THE SERVER
                    setState(() {
                      serviceProvider.isLoadDialogBox = true;
                      serviceProvider.buildShowDialog(context);
                    });

                    // CALL THE API TO UPDATE REFUND AMOUNT ROW
                    // UPDATE THE AMOUNT IN THE BACKEND DB BEFORE POPPING
                    bool isAdminUpdatedRefundRecord =
                        await serviceProvider.adminUpdateRefundOrder(
                      true,
                      widget.token,
                      itemRowId,
                      lineTotal,
                      widget.orderNo,
                      '',
                      '',
                    );

                    // CALL THE DIALOG TO ALLOW USER PERFORM OPERATION ON THE UI

                    serviceProvider.isLoadDialogBox = false;
                    serviceProvider.buildShowDialog(context);

                    if (isAdminUpdatedRefundRecord == false) {
                      serviceProvider.warningToastMassage('Error occur');
                    }
                  },
                  child: const Text(
                    'Copy Max',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                      color: Colors.yellow,
                    ),
                  ),
                  color: Colors.black87,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6.0)),
                ),
            ]),
          ],
        ),
        const Divider(),
      ],
    ));
  }

  Container bottomContent() {
    var serviceProvider = Provider.of<DataProcessing>(context);
    return Container(
      padding: const EdgeInsets.all(0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          MaterialButton(
            onPressed: () async {
              if (reasonForRefund == '' && totalRefundAmt > 0) {
                // CALL THE DIALOG TO PREVENT USER FROM THE UI UNTIL DATA IS SAVED TO THE SERVER
                setState(() {
                  serviceProvider.isLoadDialogBox = true;
                  serviceProvider.buildShowDialog(context);
                });

                // CALL THE API TO UPDATE REFUND AMOUNT ROW
                // UPDATE THE AMOUNT IN THE BACKEND DB BEFORE POPPING
                bool isAdminUpdatedRefundRecord =
                    await serviceProvider.adminUpdateRefundOrder(
                  true,
                  widget.token,
                  0,
                  'cancelBtn',
                  widget.orderNo,
                  '',
                  '',
                );

                // CALL THE DIALOG TO ALLOW USER PERFORM OPERATION ON THE UI

                serviceProvider.isLoadDialogBox = false;
                serviceProvider.buildShowDialog(context);

                if (isAdminUpdatedRefundRecord == false) {
                  serviceProvider.warningToastMassage('Error occur');
                } else {
                  checkedValue = false;
                  Navigator.pop(context);
                }
              } else {
                Navigator.pop(context);
              }
            },
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            color: Colors.grey,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6.0)),
          ),
          // CHECKING IF REFUND HAVE BEEN SUBMITTED IN OTHER TO DISABLE TO SUBMIT BUTTON...
          if (reasonForRefund != '')
            MaterialButton(
              onPressed: null,
              child: const Text(
                'Submit Refund',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              disabledColor: Colors.orange[100],
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.0)),
            ),
          if (reasonForRefund == '')
            MaterialButton(
              onPressed: () {
                // CHECK IF ALL CONDITIONS HAVE BEEN MEANT. THIS INCLUDE:
                // (1) CHECK IF REASON FOR REFUND WAS SELECTED.
                // (2) CHECK IF AMOUNT TO REFUND IS GREATER THAN ZERO
                // (3) CHECK IF THE ORDER WAS PAID FOR
                // (4) IF SELECTED STATUS IS 'OTHERS' ENSURE REFUND NOTE WAS ENTERED
                if (selectedValue != '---') {
                  if (totalRefundAmt > 0) {
                    if (isPaidOrder == true) {
                      if (selectedValue == 'others' &&
                          textfieldControllerRefundPrivateNote.text.isEmpty) {
                        serviceProvider.warningToastMassage(
                            "Since 'Others' was selected, kindly give reason for refund in the private note.");
                      } else {
                        // USING A POP-UP BOX, GET A CONFIRMATION TO SUBMIT REFUND BEFORE SUBMITING TO THE DATABASE
                        popDialogConfirmRefundSubmit(
                          context,
                          'Confirm Action',
                          'You are about to submit a refund!\nDo note that this operation is irreversible.\nDo you want to continue?',
                          textfieldControllerRefundPrivateNote.text,
                          selectedValue,
                        );
                      }
                    } else {
                      serviceProvider.popDialogMsg(context, 'Warning!',
                          "Payment was not received for this order.\nIf payment was made, kindly update the order status to 'Complete' on the update order page and process refund again.");
                    }
                  } else {
                    serviceProvider.warningToastMassage('No amount to refund');
                  }
                } else {
                  serviceProvider
                      .warningToastMassage('Kindly select reason for refund');
                }
              },
              child: const Text(
                'Submit Refund',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              color: Colors.orange[400],
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.0)),
            ),
        ],
      ),
    );
  }
}

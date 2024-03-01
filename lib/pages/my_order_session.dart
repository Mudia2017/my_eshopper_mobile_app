import 'dart:convert';

import 'package:eshopper_mobile_app/componets/data_computation.dart';
import 'package:eshopper_mobile_app/componets/side_drawer.dart';
import 'package:eshopper_mobile_app/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class MyOrderSession extends StatefulWidget {
  final String token;
  MyOrderSession({required this.token});
  @override
  _MyOrderSessionState createState() => _MyOrderSessionState();
}

class _MyOrderSessionState extends State<MyOrderSession> {
  @override
  void initState() {
    super.initState();

    getMyOrders();
  }

  bool isSearching = false;
  List _myOrderRecords = [];
  List filterMyOrder = [];
  List _filterMyOrder = [];
  String selectedValue = "----";
  List filteredCompleteOrder = [];
  List filteredProcessingOrder = [];
  List filteredOnHoldOrder = [];
  List filteredShipOrder = [];
  List filteredCancelledOrder = [];
  List filteredRefundedOrder = [];
  List filteredRejectedOrder = [];
  List filteredFailedOrder = [];
  bool isCompleteLoading = false;
  String transId = '';

  // ============= API USED TO GET ALL MY ORDERS FOR CUSTOMERS ============
  getMyOrders() async {
    var data = {};
    var response = await http.post(
      Uri.parse(
          '${dotenv.env['URL_ENDPOINT']}/apis/v1/homePage/api_myOrderSession/'),
      body: jsonEncode(data),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Token ${widget.token}",
      },
    );

    try {
      if (response.statusCode == 200) {
        var myOrderRecords = json.decode(response.body);
        setState(() {
          _myOrderRecords = myOrderRecords;

          isCompleteLoading = true;
        });
        filterMyOrderRecord(_myOrderRecords);
        filterCompleteOrder(_myOrderRecords);
        filterProcessOrder(_myOrderRecords);
        filterOnHoldOrder(_myOrderRecords);
        filterShipOrder(_myOrderRecords);
        filterCancelOrder(_myOrderRecords);
        filterRefundOrder(_myOrderRecords);
        filterRejectOrder(_myOrderRecords);
        filterFailOrder(_myOrderRecords);
      }
    } catch (error) {
      rethrow;
    }
  }

  filterMyOrderRecord(List data) {
    for (var record in data) {
      if (record['status'] == 'Processing' ||
          record['status'] == 'On hold' ||
          record['status'] == 'Shipped') {
        filterMyOrder.add(record);
      }
    }
    _filterMyOrder = filterMyOrder;
  }

  void _searchField(value) {
    setState(() {
      filterMyOrder = _filterMyOrder
          .where((element) => element['transaction_id']
              .toLowerCase()
              .contains(value.toLowerCase()))
          .toList();
    });
  }

  filterCompleteOrder(List data) {
    for (var completeOrder in data) {
      if (completeOrder['status'] == 'Completed') {
        filteredCompleteOrder.add(completeOrder);
      }
    }
  }

  filterProcessOrder(List data) {
    for (var processOrder in data) {
      if (processOrder['status'] == 'Processing') {
        filteredProcessingOrder.add(processOrder);
      }
    }
  }

  filterOnHoldOrder(List data) {
    for (var onHoldOrder in data) {
      if (onHoldOrder['status'] == 'On hold') {
        filteredOnHoldOrder.add(onHoldOrder);
      }
    }
  }

  filterShipOrder(List data) {
    for (var shipOrder in data) {
      if (shipOrder['status'] == 'Shipped') {
        filteredShipOrder.add(shipOrder);
      }
    }
  }

  filterCancelOrder(List data) {
    for (var cancelOrder in data) {
      if (cancelOrder['status'] == 'Cancelled') {
        filteredCancelledOrder.add(cancelOrder);
      }
    }
  }

  filterRefundOrder(List data) {
    for (var refundOrder in data) {
      if (refundOrder['status'] == 'Refunded') {
        filteredRefundedOrder.add(refundOrder);
      }
    }
  }

  filterRejectOrder(List data) {
    for (var rejectOrder in data) {
      if (rejectOrder['status'] == 'Rejected') {
        filteredRejectedOrder.add(rejectOrder);
      }
    }
  }

  filterFailOrder(List data) {
    for (var failOrder in data) {
      if (failOrder['status'] == 'Failed') {
        filteredFailedOrder.add(failOrder);
      }
    }
  }

  selectedOrderStatus() {
    if (selectedValue == 'complete') {
      filterMyOrder = filteredCompleteOrder;
    } else if (selectedValue == 'processing') {
      filterMyOrder = filteredProcessingOrder;
    } else if (selectedValue == 'on_hold') {
      filterMyOrder = filteredOnHoldOrder;
    } else if (selectedValue == 'shipped') {
      filterMyOrder = filteredShipOrder;
    } else if (selectedValue == 'cancelled') {
      filterMyOrder = filteredCancelledOrder;
    } else if (selectedValue == 'refunded') {
      filterMyOrder = filteredRefundedOrder;
    } else if (selectedValue == 'rejected') {
      filterMyOrder = filteredRejectedOrder;
    } else if (selectedValue == 'failed') {
      filterMyOrder = filteredFailedOrder;
    } else if (selectedValue == '----') {
      filterMyOrder = _filterMyOrder;
    }
  }

  List<DropdownMenuItem<String>> get dropdownItems {
    List<DropdownMenuItem<String>> menuItems = [
      const DropdownMenuItem(child: Text("Select Status"), value: "----"),
      const DropdownMenuItem(child: Text("Complete"), value: "complete"),
      const DropdownMenuItem(child: Text("Processing"), value: "processing"),
      const DropdownMenuItem(child: Text("On hold"), value: "on_hold"),
      const DropdownMenuItem(child: Text("Shipped"), value: "shipped"),
      const DropdownMenuItem(child: Text("Cancelled"), value: "cancelled"),
      const DropdownMenuItem(child: Text("Refunded"), value: "refunded"),
      const DropdownMenuItem(child: Text("Rejected"), value: "rejected"),
      const DropdownMenuItem(child: Text("Failed"), value: "failed"),
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
            selectedOrderStatus();
          });
        },
        items: dropdownItems,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var serviceProvider = Provider.of<DataProcessing>(context);

    // WE ARE PLACING A CONDITION TO CHECK IF THE ORDER WAS EDITED BY
    // ACCT OWNER. IF THIS IS TRUE, WHILE GOING BACK TO THIS PAGE,
    // GET THE TRANSACTION ID TO UPDATE THE AFFECTED ROW
    if (serviceProvider.isAdminUpdatedRecord == true) {
      transId = serviceProvider.transId;
    }
    return WillPopScope(
      onWillPop: () async {
        bool isResponse = await serviceProvider.popWarningConfirmActionYesNo(
            context, 'Warning', 'Do you want to exit the app?');
        if (isResponse == true) {
          SystemNavigator.pop();
        }
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [
                Color(0xFF40C4FF),
                Color(0xFFA7FFEB),
              ]),
            ),
          ),
          actions: [
            !isSearching
                ? Flexible(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [headerSection()],
                    ),
                  )
                : Flexible(
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(50, 0, 0, 0),
                      child: Column(
                        children: [
                          TextField(
                            autofocus: true,
                            onChanged: (value) => _searchField(value),
                            decoration: const InputDecoration(
                                hintText: 'Search by order No',
                                hintStyle: TextStyle(
                                    color: Colors.black54, fontSize: 13)),
                            style: const TextStyle(
                                color: Colors.white, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
              child: Row(
                children: [
                  isSearching
                      ? IconButton(
                          icon: const Icon(
                            Icons.cancel,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              isSearching = false;
                              filterMyOrder = _filterMyOrder;
                              selectedValue = "----";
                            });
                          })
                      : IconButton(
                          icon: const Icon(
                            Icons.search,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              isSearching = true;
                            });
                          }),
                ],
              ),
            ),
          ],
        ),
        drawer: const SafeArea(
          child: Drawer(
            child: SideDrawer(caller: 'innerSideDrawer'),
          ),
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
          child: filterMyOrder.isNotEmpty
              ? Column(
                  children: [
                    isSearching
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                                dropdownMenu(),
                              ])
                        : const Text(''),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          'Order No/Cus Name',
                          style: GoogleFonts.sora().copyWith(
                              fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Created date/Status',
                          style: GoogleFonts.sora().copyWith(
                              fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Total',
                          style: GoogleFonts.sora().copyWith(
                              fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Expanded(
                      child: ListView.builder(
                          itemCount: filterMyOrder.length,
                          itemBuilder: (BuildContext cxt, int x) => listView(
                                filterMyOrder
                                    .toList()[x]['transaction_id']
                                    .toString(),
                                filterMyOrder
                                    .toList()[x]['customer_name']
                                    .toString(),
                                filterMyOrder
                                    .toList()[x]['date_order']
                                    .toString(),
                                filterMyOrder.toList()[x]['status'].toString(),
                                filterMyOrder
                                    .toList()[x]['line_total']
                                    .toString(),
                              )),
                    )
                  ],
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isCompleteLoading == false)
                        CircularProgressIndicator(),
                      if (isCompleteLoading == true)
                        Text(
                          "No Order Record!",
                          style: TextStyle(
                              color: Colors.red[300],
                              fontWeight: FontWeight.bold),
                        )
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Container headerSection() {
    return Container(
      margin: const EdgeInsets.all(0.0),
      child: const Text("My Order",
          style: TextStyle(
              color: Colors.black,
              fontSize: 25.0,
              fontWeight: FontWeight.bold)),
    );
  }

  Container listView(String orderNo, cusName, orderDate, status, amount) {
    var serviceProvider = Provider.of<DataProcessing>(context);
    if (transId == orderNo) {
      status = serviceProvider.orderStatus;
      amount = serviceProvider.adminUpdateOrderGrandTotal.toString();
    }
    return Container(
      child: Column(
        children: [
          InkWell(
            onTap: () {
              Navigator.of(context).pushNamed(RouteManager.editMyOrder,
                  arguments: {'orderNo': orderNo, 'token': widget.token});
            },
            child: ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    orderNo,
                    style: GoogleFonts.sora()
                        .copyWith(fontSize: 10, color: Colors.blue.shade900),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        orderDate,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: GoogleFonts.sora().copyWith(fontSize: 10),
                      ),
                    ),
                  ),
                ],
              ),
              subtitle: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: Text(
                      cusName,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: GoogleFonts.sora().copyWith(
                        fontSize: 11,
                      ),
                    ),
                  ),
                  if (status == 'Processing')
                    Expanded(
                      child: Text(
                        status,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: GoogleFonts.sora().copyWith(
                          color: Colors.blueAccent.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  if (status == 'On hold')
                    Expanded(
                      child: Text(
                        status,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: GoogleFonts.sora().copyWith(
                          color: Colors.orange.shade900,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  if (status == 'Shipped')
                    Expanded(
                      child: Text(
                        status,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: GoogleFonts.sora().copyWith(
                          color: Colors.purple.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  if (status == 'Completed')
                    Expanded(
                      child: Text(
                        status,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: GoogleFonts.sora().copyWith(
                          color: Colors.green.shade800,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  if (status == 'Cancelled' ||
                      status == 'Refunded' ||
                      status == 'Rejected' ||
                      status == 'Failed')
                    Expanded(
                      child: Text(
                        status,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: GoogleFonts.sora().copyWith(
                          color: Colors.red.shade800,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              trailing: Text(
                '₦ ' + serviceProvider.formattedNumber(double.parse(amount)),
                style: GoogleFonts.tinos()
                    .copyWith(fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const Divider(
            color: Colors.black54,
          )
        ],
      ),
    );
  }
}

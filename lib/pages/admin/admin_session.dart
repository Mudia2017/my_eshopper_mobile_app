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

class AdminSession extends StatefulWidget {
  final String token;
  AdminSession({required this.token});
  @override
  _AdminSessionState createState() => _AdminSessionState();
}

class _AdminSessionState extends State<AdminSession> {
  @override
  void initState() {
    super.initState();

    getCreatedOrders();
  }

  bool isSearching = false;

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

  String selectedValue = "----";
  List orderData = [];
  List filteredOrder = [];
  List _filteredOrder = [];
  List filteredCompleteOrder = [];
  List filteredProcessingOrder = [];
  List filteredOnHoldOrder = [];
  List filteredShipOrder = [];
  List filteredCancelledOrder = [];
  List filteredRefundedOrder = [];
  List filteredRejectedOrder = [];
  List filteredFailedOrder = [];
  var totalCount = 0;
  bool isCompleteLoading = false;
  double adminUpdateOrderGrandTotal = 0;
  String transId = '';

  // ============= API USED TO GET ALL ORDERS CREATED ============
  getCreatedOrders() async {
    var data = {};
    var response = await http.post(
      // Uri.parse('http://192.168.43.50:8000/apis/v1/homePage/api_adminSession/'),
      Uri.parse(
          '${dotenv.env['URL_ENDPOINT']}/apis/v1/homePage/api_adminSession/'),
      body: jsonEncode(data),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Token ${widget.token}",
      },
    );

    try {
      if (response.statusCode == 200) {
        var orderRecords = json.decode(response.body);
        setState(() {
          orderData = orderRecords['order_data'];
          totalCount = orderRecords['totalCount'];
          isCompleteLoading = true;
        });
        filterOrderData(orderData);
        filterCompleteOrder(orderData);
        filterProcessOrder(orderData);
        filterOnHoldOrder(orderData);
        filterShipOrder(orderData);
        filterCancelOrder(orderData);
        filterRefundOrder(orderData);
        filterRejectOrder(orderData);
        filterFailOrder(orderData);
      }
    } catch (error) {
      rethrow;
    }
  }

  filterOrderData(List data) {
    for (var record in data) {
      if (record['status'] == 'Processing' ||
          record['status'] == 'On hold' ||
          record['status'] == 'Shipped') {
        filteredOrder.add(record);
      }
    }
    _filteredOrder = filteredOrder;
  }

  void _searchField(value) {
    setState(() {
      filteredOrder = _filteredOrder
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
      filteredOrder = filteredCompleteOrder;
    } else if (selectedValue == 'processing') {
      filteredOrder = filteredProcessingOrder;
    } else if (selectedValue == 'on_hold') {
      filteredOrder = filteredOnHoldOrder;
    } else if (selectedValue == 'shipped') {
      filteredOrder = filteredShipOrder;
    } else if (selectedValue == 'cancelled') {
      filteredOrder = filteredCancelledOrder;
    } else if (selectedValue == 'refunded') {
      filteredOrder = filteredRefundedOrder;
    } else if (selectedValue == 'rejected') {
      filteredOrder = filteredRejectedOrder;
    } else if (selectedValue == 'failed') {
      filteredOrder = filteredFailedOrder;
    } else if (selectedValue == '----') {
      filteredOrder = _filteredOrder;
    }
  }

  @override
  Widget build(BuildContext context) {
    var serviceProvider = Provider.of<DataProcessing>(context);
    // WE ARE PLACING A CONDITION TO CHECK IF THE ORDER WAS EDITED BY
    // ADMIN. IF THIS IS TRUE, WHILE GOING BACK TO THIS PAGE,
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
          elevation: 0.0,
          // title: headerSection(),
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
                      children: [
                        headerSection(),
                      ],
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
                                hintText: 'Search by order No...',
                                hintStyle: TextStyle(
                                    color: Colors.black54, fontSize: 15)),
                            style: const TextStyle(
                                color: Colors.white, fontSize: 18),
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
                              filteredOrder = _filteredOrder;
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
          child: filteredOrder.isNotEmpty
              ? Column(
                  children: [
                    isSearching
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              dropdownMenu(),
                            ],
                          )
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
                          itemCount: filteredOrder.length,
                          itemBuilder: (BuildContext cxt, int x) => listView(
                                filteredOrder
                                    .toList()[x]['transaction_id']
                                    .toString(),
                                filteredOrder
                                    .toList()[x]['customer_name']
                                    .toString(),
                                filteredOrder
                                    .toList()[x]['date_order']
                                    .toString(),
                                filteredOrder.toList()[x]['status'].toString(),
                                filteredOrder.toList()[x]['total'].toString(),
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
      child: const Text("Admin Session",
          style: TextStyle(
              color: Colors.black,
              fontSize: 25.0,
              fontWeight: FontWeight.bold)),
    );
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

  Container listView(String orderNo, cusName, orderDate, status, amount) {
    var serviceProvider = Provider.of<DataProcessing>(context);
    if (transId == orderNo) {
      status = serviceProvider.orderStatus;
      amount = serviceProvider.adminUpdateOrderGrandTotal.toString();
    }
    return Container(
      child: InkWell(
        onTap: () {
          Navigator.of(context).pushNamed(RouteManager.adminUpdateOrder,
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
    );
  }
}

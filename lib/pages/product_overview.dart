import 'dart:convert';

import 'package:eshopper_mobile_app/componets/data_computation.dart';
import 'package:eshopper_mobile_app/componets/side_drawer.dart';
import 'package:eshopper_mobile_app/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class ProductOverView extends StatefulWidget {
  final String token, userId;
  ProductOverView({required this.token, required this.userId});
  @override
  _ProductOverViewState createState() => _ProductOverViewState();
}

class _ProductOverViewState extends State<ProductOverView> {
  @override
  void initState() {
    super.initState();
    initializingFunctionCall(widget.token, widget.userId);
  }

  bool isSearching = false;
  List filterTraderItmList = [];
  String selectedValue = "----";
  bool checked = false;
  bool isDoneLoading = false;
  List traderItmList = [];
  List selectedList = [];
  Map serverResp = {};

  // ======= API CALL TO GET A TRADER'S ITEM(S) =========
  void initializingFunctionCall(token, userId) async {
    var serviceProvider = Provider.of<DataProcessing>(context, listen: false);
    var response =
        await serviceProvider.getTraderItems(token, userId, '', [], '');

    setState(() {
      traderItmList = response['traderItmList'];
      filterTraderItmList = response['filterTraderItmList'];
      isDoneLoading = response['isDoneLoading'];
    });
    serverResp = response['serverResp'];
  }

  void _searchField(value) {
    setState(() {
      filterTraderItmList = traderItmList
          .where((element) =>
              element['name'].toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
  }

  List<DropdownMenuItem<String>> get dropdownItems {
    List<DropdownMenuItem<String>> menuItems = [
      const DropdownMenuItem(
          child: Text(
            "Select",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          value: "----"),
      const DropdownMenuItem(
          child: Text(
            "Active",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Colors.blue,
            ),
          ),
          value: "active"),
      const DropdownMenuItem(
          child: Text(
            "Inactive",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Colors.blue,
            ),
          ),
          value: "inactive"),
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
            // selectedOrderStatus();
          });
        },
        items: dropdownItems,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var serviceProvider = Provider.of<DataProcessing>(context);
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
                                hintText: 'Search by product name',
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
                              filterTraderItmList = traderItmList;
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
          child: filterTraderItmList.isNotEmpty
              ? RefreshIndicator(
                  onRefresh: () async {
                    initializingFunctionCall(widget.token, widget.userId);
                  },
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            filterTraderItmList.length.toString() + ' Product',
                            style: const TextStyle(fontSize: 12),
                          ),
                          MaterialButton(
                            color: Colors.blue.shade400,
                            height: 25,
                            child: const Text('Add Product'),
                            onPressed: () {
                              Navigator.of(context).pushNamed(
                                  RouteManager.addProduct,
                                  arguments: {
                                    'token': widget.token,
                                    'userId': widget.userId
                                  });
                            },
                          ),
                          Container(
                            padding: const EdgeInsets.all(0),
                            child: Row(
                              children: [
                                dropdownMenu(),
                                const SizedBox(
                                  width: 8,
                                ),
                                OutlinedButton(
                                  onPressed: () async {
                                    if (selectedList.isNotEmpty) {
                                      if (selectedValue != '----') {
                                        // SEND THE SELECTED PRODUCT ID TO THE BACKEND
                                        // AND CARRY OUT OPERATION

                                        // CALL THE DIALOG TO PREVENT USER FROM THE UI UNTIL DATA IS SAVED TO THE SERVER
                                        setState(() {
                                          serviceProvider.isLoadDialogBox =
                                              true;
                                          serviceProvider
                                              .buildShowDialog(context);
                                        });
                                        isDoneLoading = false;
                                        var response = await serviceProvider
                                            .getTraderItems(
                                                widget.token,
                                                widget.userId,
                                                'btnContinue',
                                                selectedList,
                                                selectedValue);

                                        // CALL THE DIALOG TO ALLOW USER PERFORM OPERATION ON THE UI

                                        serviceProvider.isLoadDialogBox = false;
                                        serviceProvider
                                            .buildShowDialog(context);

                                        setState(() {
                                          filterTraderItmList =
                                              response['filterTraderItmList'];
                                        });
                                        if (response['serverResp']
                                                ['serverMsg'] ==
                                            'success') {
                                          serviceProvider
                                              .toastMessage('Successful');
                                        } else if (response['serverResp']
                                                ['serverMsg'] ==
                                            'failed') {
                                          serviceProvider
                                              .warningToastMassage('Failed');
                                        }
                                        FocusManager.instance.primaryFocus
                                            ?.unfocus();
                                        isSearching = false;
                                        selectedValue = '----';
                                        selectedList = [];
                                      } else {
                                        serviceProvider.popWarningErrorMsg(
                                            context,
                                            'Warning',
                                            'Kindly select your action from the drop down menu');
                                      }
                                    } else {
                                      serviceProvider.popWarningErrorMsg(
                                          context,
                                          'Warning',
                                          'Checkbox was not selected!');
                                    }
                                  },
                                  child: const Text('Continue'),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                      const Divider(
                        color: Colors.black,
                      ),
                      detailHeader(),
                      Expanded(
                        child: ListView.builder(
                            itemCount: filterTraderItmList.length,
                            itemBuilder: (context, index) {
                              return Container(
                                child: Column(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        Navigator.of(context).pushNamed(
                                            RouteManager.editProduct,
                                            arguments: {
                                              'token': widget.token,
                                              'ptdId': filterTraderItmList
                                                  .toList()[index]['id']
                                                  .toString(),
                                              'userId': widget.userId,
                                            });
                                      },
                                      child: Table(
                                        columnWidths: const {
                                          0: FixedColumnWidth(40),
                                          2: FixedColumnWidth(65),
                                          3: FixedColumnWidth(37),
                                          4: FixedColumnWidth(70),
                                          5: FixedColumnWidth(50),
                                          6: FixedColumnWidth(38),
                                        },
                                        children: [
                                          TableRow(
                                            children: [
                                              Checkbox(
                                                value: filterTraderItmList
                                                    .toList()[index]['isCheck'],
                                                onChanged: (newValue) {
                                                  checkList(
                                                    newValue!,
                                                    index,
                                                    filterTraderItmList
                                                        .toList()[index]['id']
                                                        .toString(),
                                                  );
                                                },
                                              ),
                                              Text(
                                                filterTraderItmList
                                                    .toList()[index]['name'],
                                                style:
                                                    GoogleFonts.sora().copyWith(
                                                  fontSize: 10,
                                                ),
                                              ),
                                              Text(
                                                '₦ ' +
                                                    serviceProvider.formattedNumber(
                                                        double.parse(
                                                            filterTraderItmList
                                                                    .toList()[
                                                                index]['price'])),
                                                style: GoogleFonts.tinos()
                                                    .copyWith(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                filterTraderItmList
                                                            .toList()[index]
                                                        ['discount'] +
                                                    ' %',
                                                style: GoogleFonts.tinos()
                                                    .copyWith(
                                                  fontSize: 10,
                                                ),
                                              ),
                                              if (filterTraderItmList
                                                          .toList()[index]
                                                      ['expDate'] ==
                                                  null)
                                                Text(
                                                  '',
                                                  style: GoogleFonts.sora()
                                                      .copyWith(),
                                                ),
                                              if (filterTraderItmList
                                                          .toList()[index]
                                                      ['expDate'] !=
                                                  null)
                                                Text(
                                                  filterTraderItmList
                                                          .toList()[index]
                                                      ['expDate'],
                                                  style: GoogleFonts.sora()
                                                      .copyWith(
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              Text(
                                                filterTraderItmList
                                                    .toList()[index]['store'],
                                                style:
                                                    GoogleFonts.sora().copyWith(
                                                  fontSize: 10,
                                                ),
                                              ),
                                              if (filterTraderItmList
                                                          .toList()[index]
                                                      ['active'] ==
                                                  true)
                                                Icon(
                                                  Icons.check_circle_sharp,
                                                  color: Colors
                                                      .greenAccent.shade700,
                                                ),
                                              if (filterTraderItmList
                                                          .toList()[index]
                                                      ['active'] ==
                                                  false)
                                                Icon(
                                                  Icons.cancel_sharp,
                                                  color:
                                                      Colors.redAccent.shade700,
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Divider(
                                      color: Colors.black26,
                                    ),
                                  ],
                                ),
                              );
                            }),
                      ),
                    ],
                  ),
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isDoneLoading == false)
                        const CircularProgressIndicator(),
                      if (isDoneLoading == true)
                        Text(
                          "No Record!",
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
      child: const Text("Product",
          style: TextStyle(
              color: Colors.black,
              fontSize: 25.0,
              fontWeight: FontWeight.bold)),
    );
  }

  // ================ DETAIL HEADER SECTION ============
  Container detailHeader() {
    return Container(
      child: Table(
        columnWidths: const {
          0: FixedColumnWidth(40),
          2: FixedColumnWidth(65),
          3: FixedColumnWidth(37),
          4: FixedColumnWidth(70),
          5: FixedColumnWidth(50),
          6: FixedColumnWidth(38),
        },
        children: [
          TableRow(children: [
            Text(
              '',
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
              'Price',
              style: GoogleFonts.sora().copyWith(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent.shade700,
              ),
            ),
            Text(
              'Discount',
              style: GoogleFonts.sora().copyWith(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent.shade700,
              ),
            ),
            Text(
              'ExpDate',
              style: GoogleFonts.sora().copyWith(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent.shade700,
              ),
            ),
            Text(
              'Store',
              style: GoogleFonts.sora().copyWith(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent.shade700,
              ),
            ),
            Text(
              'Active',
              style: GoogleFonts.sora().copyWith(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent.shade700,
              ),
            ),
          ])
        ],
      ),
    );
  }

  void checkList(bool value, int index, String ptdId) {
    if (value == true) {
      selectedList.add(ptdId);
    } else if (value == false) {
      selectedList.removeWhere((item) => item == ptdId);
    }
    setState(() {
      filterTraderItmList.toList()[index]['isCheck'] = value;
    });
  }
}

// class Service {
//   Future<int> submitSubscription(
//       {File file, String filename, String token}) async {
//     ///MultiPart request
//     var request = http.MultipartRequest(
//       'POST',
//       Uri.parse("https://your api url with endpoint"),
//     );
//     Map<String, String> headers = {
//       "Authorization": "Bearer $token",
//       "Content-type": "multipart/form-data"
//     };
//     request.files.add(
//       http.MultipartFile(
//         'file',
//         file.readAsBytes().asStream(),
//         file.lengthSync(),
//         filename: filename,
//         contentType: MediaType('image', 'jpeg'),
//       ),
//     );
//     request.headers.addAll(headers);
//     request.fields
//         .addAll({"name": "test", "email": "test@gmail.com", "id": "12345"});
//     print("request: " + request.toString());
//     var res = await request.send();
//     print("This is response:" + res.toString());
//     return res.statusCode;
//   }
// }

import 'package:badges/badges.dart';
import 'package:eshopper_mobile_app/componets/data_computation.dart';
import 'package:eshopper_mobile_app/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AllRecentViewItems extends StatefulWidget {
  final String custId;
  final String token;
  final String userName;
  final String userEmail;
  String cartCounter;

  AllRecentViewItems(
      {required this.custId,
      required this.token,
      required this.userName,
      required this.userEmail,
      required this.cartCounter});
  @override
  _AllRecentViewItemsState createState() => _AllRecentViewItemsState();
}

class _AllRecentViewItemsState extends State<AllRecentViewItems> {
  @override
  void initState() {
    // allRecentlyViewedItem('viewAll');
    super.initState();
    initializingFunctionCall('viewAll', widget.token);
  }

  int counter = 0;
  List allRecentViewList = [];
  String status = '';
  String errorMsg = '';
  // allRecentlyViewedItem(call) async {
  //   var response;
  //   Map data = {'call': call};
  //   response = await http.post(
  //     Uri.parse(
  //         "http://192.168.43.50:8000/apis/v1/homePage/api_allRecentView/"),
  //     body: json.encode(data),
  //     headers: {
  //       "Content-Type": "application/json",
  //       "Authorization": "Token ${widget.token}",
  //     },
  //   );
  //   try {
  //     if (response.statusCode == 200) {
  //       var allRecentViewedData = json.decode(response.body);
  //       setState(() {
  //         if (allRecentViewedData['status'] == 'success') {
  //           allRecentViewList = allRecentViewedData['allRecentViewList'];
  //           counter = allRecentViewList.length;
  //           status = allRecentViewedData['status'];
  //           errorMsg = allRecentViewedData['errorMsg'].toString();
  //         } else {
  //           status = allRecentViewedData['status'];
  //           errorMsg = allRecentViewedData['errorMsg'].toString();
  //         }
  //       });
  //     }
  //   } catch (error) {
  //     rethrow;
  //   }
  //   return status;
  // }

  initializingFunctionCall(call, token) async {
    var serviceProvider = Provider.of<DataProcessing>(context, listen: false);
    var response = await serviceProvider.allRecentlyViewedItem(call, token);

    setState(() {
      if (response['status'] == 'success') {
        allRecentViewList = response['allRecentViewList'];
        counter = allRecentViewList.length;
        status = response['status'];
        errorMsg = response['errorMsg'].toString();
      } else {
        status = response['status'];
        errorMsg = response['errorMsg'].toString();
      }
    });
    return status;
  }

  @override
  Widget build(BuildContext context) {
    var serviceProvider = Provider.of<DataProcessing>(context);

    if (serviceProvider.isApiLoaded == true) {
      widget.cartCounter = serviceProvider.counter.toString();
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
        actions: [
          // YOU WILL NOTICE THE ICON-BUTTON ON-PRESS AS WELL AS THE INKWELL
          // ON-TAP HAVE THE SAVE NAVIGATION ROUTE. I JUST DID IT TO MAKE THE
          // UI RESPONSIVE WHEN THE USER CLICK ON THE CART ICON OR BADGE.
          InkWell(
            onTap: () {
              // CART PAGE ROUTE FOR AUTHENTIC USER
              if (widget.userName != 'Guest') {
                Navigator.of(context)
                    .pushNamed(RouteManager.authenticCartPage, arguments: {
                  'name': widget.userName,
                  'email': widget.userEmail,
                  'token': widget.token,
                  'custId': widget.custId,
                });
              }
            },
            child: Badge(
              child: IconButton(
                onPressed: () async {
                  // CART PAGE ROUTE FOR AUTHENTIC USER
                  if (widget.userName != 'Guest') {
                    Navigator.of(context)
                        .pushNamed(RouteManager.authenticCartPage, arguments: {
                      'name': widget.userName,
                      'email': widget.userEmail,
                      'token': widget.token,
                      'custId': widget.custId,
                    });
                  }
                },
                icon: Container(
                  padding: const EdgeInsets.fromLTRB(0, 4, 0, 0),
                  child: const Icon(
                    Icons.shopping_cart_sharp,
                    color: Colors.black54,
                    size: 40,
                  ),
                ),
              ),
              badgeContent: Text(
                widget.cartCounter.toString() == 'null'
                    ? '0'
                    : widget.cartCounter.toString(),
                style: const TextStyle(
                    fontSize: 12.0,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
              // position: badges.BadgePosition.topEnd(top: 0, end: 7),
              // badgeAnimation: badges.BadgeAnimation.slide(),
              // badgeStyle: badges.BadgeStyle(
              //   badgeColor: Colors.redAccent.shade700,
              // ),
              badgeColor: Colors.redAccent.shade700,
              position: BadgePosition.topEnd(top: 0, end: 7),
              animationType: BadgeAnimationType.slide,
            ),
          ),
        ],
      ),
      body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: RefreshIndicator(
            onRefresh: () async {
              initializingFunctionCall('viewAll', widget.token);
            },
            child: Column(children: [
              Row(
                children: [
                  Text(
                    counter.toString(),
                    style: GoogleFonts.sora().copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    ' Items in total',
                    style: GoogleFonts.sora().copyWith(
                      fontSize: 11,
                    ),
                  ),
                  const Expanded(child: SizedBox()),
                  OutlinedButton(
                    onPressed: () async {
                      bool isResponse =
                          await serviceProvider.popWarningConfirmActionYesNo(
                              context,
                              'Warning',
                              'Confirm to delete all recently viewed items');

                      if (isResponse == true) {
                        var serverResponse = await initializingFunctionCall(
                            'deleteAll', widget.token);
                        if (serverResponse == 'success') {
                          serviceProvider.popDialogMsg(
                              context, 'Info', 'Record deleted successful');
                        } else if (serverResponse == 'fail') {
                          serviceProvider.popWarningErrorMsg(
                              context, 'Error message', errorMsg);
                        }
                      }
                    },
                    child: const Text(
                      'Clear all',
                      style: TextStyle(
                        color: Colors.orange,
                      ),
                    ),
                  )
                ],
              ),
              allRecentViewList.isNotEmpty
                  ? Expanded(
                      child: GridView.count(
                      childAspectRatio: 0.65,
                      shrinkWrap: true,
                      crossAxisCount: 2,
                      scrollDirection: Axis.vertical,
                      children:
                          List.generate(allRecentViewList.length, (index) {
                        return InkWell(
                          onTap: () {
                            Navigator.of(context).pushNamed(
                                RouteManager.productDetail,
                                arguments: {
                                  'ptdId': "${allRecentViewList[index]["id"]}",
                                  'category':
                                      "${allRecentViewList[index]["category"]}",
                                  'cartCounter': widget.cartCounter,
                                });
                          },
                          child: Card(
                            child: Column(
                              children: [
                                if (allRecentViewList.toList()[index]
                                        ['imageURL'] !=
                                    "http://192.168.43.50:8000")
                                  Image.network(
                                    allRecentViewList.toList()[index]
                                        ['imageURL'],
                                    fit: BoxFit.contain,
                                    height: 200,
                                  ),
                                if (allRecentViewList.toList()[index]
                                        ['imageURL'] ==
                                    "http://192.168.43.50:8000")
                                  Container(
                                    height: 120,
                                    width: 120,
                                    child: const Icon(
                                      Icons.photo_size_select_actual_sharp,
                                      color: Colors.black26,
                                      size: 100,
                                    ),
                                  ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 5),
                                  child: Text(
                                    allRecentViewList.toList()[index]['name'],
                                    style: GoogleFonts.sora().copyWith(
                                        overflow: TextOverflow.ellipsis,
                                        fontSize: 13,
                                        color: Colors.lightBlueAccent.shade400),
                                    maxLines: 2,
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                if (double.parse(allRecentViewList
                                        .toList()[index]['discount']) >
                                    0)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              '₦ ',
                                              style:
                                                  GoogleFonts.tinos().copyWith(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            Text(
                                              serviceProvider.formattedNumber(
                                                  double.parse(allRecentViewList
                                                          .toList()[index]
                                                      ['price'])),
                                              style:
                                                  GoogleFonts.tinos().copyWith(
                                                overflow: TextOverflow.ellipsis,
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                decoration:
                                                    TextDecoration.lineThrough,
                                                color: Colors.grey,
                                              ),
                                              maxLines: 1,
                                            ),
                                            const Expanded(child: SizedBox()),
                                            Text(
                                              serviceProvider.formattedNumber(
                                                      double.parse(
                                                          allRecentViewList
                                                                      .toList()[
                                                                  index]
                                                              ['discount'])) +
                                                  " off",
                                              style:
                                                  GoogleFonts.tinos().copyWith(
                                                overflow: TextOverflow.ellipsis,
                                                fontSize: 11,
                                              ),
                                              maxLines: 1,
                                            )
                                          ],
                                        ),
                                        Text(
                                          '₦ ' +
                                              serviceProvider.formattedNumber(
                                                  double.parse(allRecentViewList
                                                          .toList()[index]
                                                      ['new_price'])),
                                          style: GoogleFonts.tinos().copyWith(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                if (double.parse(allRecentViewList
                                        .toList()[index]['discount']) ==
                                    0)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: Row(
                                      children: [
                                        Text(
                                          '₦ ' +
                                              serviceProvider.formattedNumber(
                                                  double.parse(allRecentViewList
                                                          .toList()[index]
                                                      ['price'])),
                                          style: GoogleFonts.tinos().copyWith(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                              ],
                            ),
                          ),
                        );
                      }),
                    ))
                  : Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (status == 'fail')
                            Text(
                              'error loading data \n' + errorMsg,
                              style: GoogleFonts.sora().copyWith(
                                fontSize: 12,
                                color: Colors.red.shade200,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          if (status == '') const CircularProgressIndicator(),
                          if (status == 'success' && allRecentViewList.isEmpty)
                            Text(
                              'No record',
                              style: GoogleFonts.sora().copyWith(
                                fontSize: 12,
                                color: Colors.red.shade200,
                                fontWeight: FontWeight.w600,
                              ),
                            )
                        ],
                      ),
                    ),
            ]),
          )),
    );
  }

  Container titleSection() {
    return Container(
      margin: const EdgeInsets.all(0.0),
      child: const Text("All Recently Viewed",
          style: TextStyle(
              color: Colors.black,
              fontSize: 25.0,
              fontWeight: FontWeight.bold)),
    );
  }
}

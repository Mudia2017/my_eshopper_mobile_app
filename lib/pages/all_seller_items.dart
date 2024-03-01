import 'package:badges/badges.dart';
import 'package:eshopper_mobile_app/componets/data_computation.dart';
import 'package:eshopper_mobile_app/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AllSellerItems extends StatefulWidget {
  final String custId;
  final String token;
  final String userName;
  final String userEmail;
  final String storeId;

  AllSellerItems({
    required this.custId,
    required this.token,
    required this.userName,
    required this.userEmail,
    required this.storeId,
  });
  @override
  _AllSellerItemsState createState() => _AllSellerItemsState();
}

class _AllSellerItemsState extends State<AllSellerItems> {
  @override
  void initState() {
    super.initState();
    initializingFunctionCall(widget.storeId, widget.token);
  }

  List productList = []; /* USED TO HOLD PRODUCT DATA RECEIVED FROM API */
  List filteredStoreItems = []; /* USED TO HOLD THE SEARCHED PRODUCT */
  int cartCounter = 0;
  String errorMsg = '';
  String status = '';
  bool isDoneLoading = false;
  bool isFind = false;
  bool isSearching = false;

  initializingFunctionCall(storeId, token) async {
    var serviceProvider = Provider.of<DataProcessing>(context, listen: false);
    var response = await serviceProvider.allSellerItems(storeId, token);

    setState(() {
      if (response['status'] == 'success') {
        status = response['status'];
        productList = filteredStoreItems = response['ptd_data'];
        cartCounter = response['cartCounter'];
        isDoneLoading = true;
      } else {
        errorMsg = response['errorMsg'].toString();
      }
    });
  }

  void _filterStoreItm(value) {
    setState(() {
      filteredStoreItems = productList
          .where((product) =>
              product['name'].toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    var serviceProvider = Provider.of<DataProcessing>(context);

    if (serviceProvider.isApiLoaded == true && isDoneLoading == false) {
      cartCounter = serviceProvider.counter;
    } else {
      isDoneLoading = false;
    }
    return Scaffold(
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [
              Color(0xFF40C4FF),
              Color(0xFFA7FFEB),
            ])),
          ),
          elevation: 0,
          actions: [
            !isSearching
                ? Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [headerSection()],
                    ),
                  )
                : Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 45,
                      ),
                      child: TextField(
                        enableSuggestions: true,
                        autofocus: true,
                        onChanged: (value) {
                          // _filterProduct(value);
                        },
                        decoration: const InputDecoration(
                          hintText: 'Search by product name',
                          hintStyle:
                              TextStyle(color: Colors.white70, fontSize: 15),
                        ),
                        style: const TextStyle(
                            color: Colors.white, fontSize: 16.0),
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
                              // filteredProduct = productList;
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
                      Navigator.of(context).pushNamed(
                          RouteManager.authenticCartPage,
                          arguments: {
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
                      size: 30,
                    ),
                  ),
                ),
                badgeContent: Text(
                  cartCounter.toString() == 'null'
                      ? '0'
                      : cartCounter.toString(),
                  style: const TextStyle(
                      fontSize: 10.0,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
                badgeColor: Colors.redAccent.shade700,
                position: BadgePosition.topEnd(top: 0, end: 7),
                animationType: BadgeAnimationType.slide,
                // position: badges.BadgePosition.topEnd(top: 0, end: 7),
                // badgeAnimation: badges.BadgeAnimation.slide(),
                // badgeStyle: badges.BadgeStyle(
                //   badgeColor: Colors.redAccent.shade700,
                // ),
              ),
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            initializingFunctionCall(widget.storeId, widget.token);
          },
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 7, 10, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    !isFind
                        ? SizedBox(
                            height: 25,
                            child: OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  isFind = true;
                                });
                              },
                              child: const Text('Find'),
                            ),
                          )
                        : Expanded(
                            child: SizedBox(
                              height: 30,
                              child: TextField(
                                enableSuggestions: true,
                                autofocus: true,
                                onChanged: (value) {
                                  _filterStoreItm(value);
                                },
                                decoration: const InputDecoration(
                                  hintText: 'Search store by product name',
                                  hintStyle: TextStyle(
                                      color: Colors.black45, fontSize: 15),
                                ),
                                style: const TextStyle(
                                    color: Colors.black54, fontSize: 16.0),
                              ),
                            ),
                          ),
                    if (isFind)
                      IconButton(
                          icon: const Icon(
                            Icons.cancel,
                            color: Colors.black,
                          ),
                          onPressed: () {
                            setState(() {
                              isFind = false;
                              filteredStoreItems = productList;
                            });
                          })
                  ],
                ),
              ),
              Expanded(
                child: filteredStoreItems.isNotEmpty
                    ? ListView.builder(
                        itemCount: filteredStoreItems.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Column(
                              children: [
                                const Divider(
                                  color: Colors.black38,
                                ),
                                Container(
                                  padding: const EdgeInsets.all(5),
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.of(context).pushNamed(
                                          RouteManager.productDetail,
                                          arguments: {
                                            'ptdId':
                                                "${filteredStoreItems[index]["id"]}",
                                            'category':
                                                "${filteredStoreItems[index]["category"]}",
                                            'cartCounter': cartCounter,
                                          });
                                    },
                                    child: Row(
                                      children: [
                                        // if ("${filteredProduct[index]["imageURL"]}"
                                        //     .contains('images'))
                                        if ("${filteredStoreItems[index]["imageURL"]}" ==
                                            "${dotenv.env['URL_ENDPOINT']}")
                                          Container(
                                            height: 120,
                                            width: 120,
                                            child: const Icon(
                                              Icons
                                                  .photo_size_select_actual_sharp,
                                              color: Colors.black26,
                                              size: 100,
                                            ),
                                          ),
                                        if ("${filteredStoreItems[index]["imageURL"]}" !=
                                            "${dotenv.env['URL_ENDPOINT']}")
                                          Container(
                                            height: 120,
                                            width: 120,
                                            child: Image.network(
                                              "${filteredStoreItems[index]["imageURL"]}",
                                            ),
                                          ),
                                        Flexible(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "${filteredStoreItems[index]["name"]}",
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 2,
                                                style: GoogleFonts.sora()
                                                    .copyWith(
                                                        color: Colors
                                                            .blue.shade700),
                                              ),
                                              if ("${filteredStoreItems[index]['mfgDate']}" !=
                                                  'null')
                                                Text(
                                                  "Mfd Date: ${filteredStoreItems[index]["mfgDate"]}",
                                                  style: GoogleFonts.publicSans(
                                                          fontSize: 11)
                                                      .copyWith(
                                                          color:
                                                              Colors.black45),
                                                ),
                                              if ("${filteredStoreItems[index]['expDate']}" !=
                                                  'null')
                                                Text(
                                                  "Exp Date: ${filteredStoreItems[index]["expDate"]}",
                                                  style: GoogleFonts.publicSans(
                                                          fontSize: 11)
                                                      .copyWith(
                                                          color:
                                                              Colors.black45),
                                                ),
                                              if ("${filteredStoreItems[index]['discount']}" !=
                                                  '0.00')
                                                Row(
                                                  children: [
                                                    Text(
                                                      "${filteredStoreItems[index]["discount"]} % off",
                                                      style: GoogleFonts
                                                              .publicSans()
                                                          .copyWith(
                                                              fontSize: 13),
                                                    ),
                                                    const SizedBox(
                                                      width: 15,
                                                    ),
                                                    Text(
                                                      "was: ",
                                                      style: GoogleFonts
                                                              .publicSans()
                                                          .copyWith(
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                    Text(
                                                      "₦ " +
                                                          serviceProvider
                                                              .formattedNumber(
                                                                  double.parse(
                                                                      "${filteredStoreItems[index]["price"]}")),
                                                      style: GoogleFonts
                                                              .publicSans()
                                                          .copyWith(
                                                        color: Colors.grey,
                                                        decoration:
                                                            TextDecoration
                                                                .lineThrough,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              if ("${filteredStoreItems[index]['discount']}" ==
                                                  '0.00')
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      "₦ " +
                                                          serviceProvider
                                                              .formattedNumber(
                                                                  double.parse(
                                                                      "${filteredStoreItems[index]["price"]}")),
                                                      style: GoogleFonts
                                                              .publicSans()
                                                          .copyWith(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 18,
                                                      ),
                                                    ),
                                                    if ('${filteredStoreItems[index]['out_of_stock']}' ==
                                                        'true')
                                                      Badge(
                                                        // badgeStyle:
                                                        //     badges.BadgeStyle(
                                                        //   badgeColor: Colors
                                                        //       .redAccent
                                                        //       .shade700,
                                                        //   shape: badges
                                                        //       .BadgeShape
                                                        //       .square,
                                                        //   elevation: 3.0,
                                                        //   borderRadius:
                                                        //       BorderRadius
                                                        //           .circular(10),
                                                        // ),
                                                        // badgeAnimation: badges
                                                        //         .BadgeAnimation
                                                        //     .fade(),

                                                        badgeColor: Colors
                                                            .redAccent.shade700,
                                                        animationType:
                                                            BadgeAnimationType
                                                                .fade,
                                                        shape:
                                                            BadgeShape.square,
                                                        elevation: 3.0,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        badgeContent:
                                                            const Center(
                                                          child: Text(
                                                            'Out of stock',
                                                            style: TextStyle(
                                                                fontSize: 12,
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w800),
                                                          ),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              if ("${filteredStoreItems[index]['discount']}" !=
                                                  '0.00')
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      "₦ " +
                                                          serviceProvider
                                                              .formattedNumber(
                                                                  double.parse(
                                                                      "${filteredStoreItems[index]["new_price"]}")),
                                                      style: GoogleFonts
                                                              .publicSans()
                                                          .copyWith(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 18,
                                                      ),
                                                    ),
                                                    if ('${filteredStoreItems[index]['out_of_stock']}' ==
                                                        'true')
                                                      Badge(
                                                        // badgeStyle:
                                                        //     badges.BadgeStyle(
                                                        //   badgeColor: Colors
                                                        //       .redAccent
                                                        //       .shade700,
                                                        //   shape: badges
                                                        //       .BadgeShape
                                                        //       .square,
                                                        //   elevation: 3.0,
                                                        //   borderRadius:
                                                        //       BorderRadius
                                                        //           .circular(10),
                                                        // ),
                                                        // badgeAnimation: badges
                                                        //         .BadgeAnimation
                                                        //     .fade(),
                                                        badgeColor: Colors
                                                            .redAccent.shade700,
                                                        animationType:
                                                            BadgeAnimationType
                                                                .fade,
                                                        shape:
                                                            BadgeShape.square,
                                                        elevation: 3.0,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        badgeContent:
                                                            const Center(
                                                          child: Text(
                                                            'Out of stock',
                                                            style: TextStyle(
                                                                fontSize: 12,
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w800),
                                                          ),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    serviceProvider.displayHorizontalSmallStar(
                                        double.parse(
                                            '${filteredStoreItems[index]['averageStarRated']}')),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      serviceProvider.formattedNumber(double.parse(
                                          '${filteredStoreItems[index]['counter']}')),
                                      style: GoogleFonts.publicSans().copyWith(
                                          color: Colors.grey.shade700,
                                          fontSize: 15),
                                    ),
                                    const SizedBox(width: 20),
                                    InkWell(
                                      onTap: () async {
                                        // CALL THE DIALOG TO PREVENT USER FROM THE UI UNTIL DATA IS SAVED TO THE SERVER
                                        setState(() {
                                          serviceProvider.isLoadDialogBox =
                                              true;
                                          serviceProvider
                                              .buildShowDialog(context);
                                        });
                                        var serverResponse;

                                        // UPDATE WISH LIST FOR AUTHENTICATED USER
                                        if (widget.userName != 'Guest' &&
                                            widget.userEmail != '' &&
                                            filteredStoreItems[index]
                                                    ['isFavorite'] ==
                                                false) {
                                          serverResponse = await serviceProvider
                                              .sendWishListPtdToDB(
                                            "${filteredStoreItems[index]["id"]}",
                                            'heartFill',
                                            widget.token,
                                          );
                                        } else if (widget.userName != 'Guest' &&
                                            widget.userEmail != '' &&
                                            filteredStoreItems[index]
                                                    ['isFavorite'] ==
                                                true) {
                                          serverResponse = await serviceProvider
                                              .sendWishListPtdToDB(
                                            "${filteredStoreItems[index]["id"]}",
                                            'heart',
                                            widget.token,
                                          );
                                        } else {
                                          serviceProvider.toastMessage(
                                              'Favorite item is only for log in user');
                                        }

                                        if (serverResponse == false) {
                                          setState(() {
                                            filteredStoreItems[index]
                                                ['isFavorite'] = false;
                                          });
                                          serviceProvider.toastMessage(
                                              'Product was removed from wish list');
                                        } else if (serverResponse == true) {
                                          setState(() {
                                            filteredStoreItems[index]
                                                ['isFavorite'] = true;
                                          });
                                          serviceProvider.toastMessage(
                                              'Product was added to wish list');
                                        }

                                        // CALL THE DIALOG TO ALLOW USER PERFORM OPERATION ON THE UI
                                        setState(() {
                                          serviceProvider.isLoadDialogBox =
                                              false;
                                          serviceProvider
                                              .buildShowDialog(context);
                                        });
                                      },
                                      child: !filteredStoreItems[index]
                                              ['isFavorite']
                                          ? const Icon(
                                              Icons.favorite_outline_sharp,
                                              color: Colors.blue,
                                            )
                                          : const Icon(
                                              Icons.favorite,
                                              color: Colors.blue,
                                            ),
                                    ),
                                    const SizedBox(
                                      width: 50,
                                    ),
                                    InkWell(
                                      onTap: () async {
                                        // ADD TO CART ICON-BUTTON FOR AUTHENTICATED USER
                                        if ((widget.userName != 'Guest' ||
                                                widget.userEmail != '') &&
                                            '${filteredStoreItems[index]['out_of_stock']}' ==
                                                'false') {
                                          // CALL THE DIALOG TO PREVENT USER FROM THE UI UNTIL DATA IS SAVED TO THE SERVER
                                          setState(() {
                                            serviceProvider.isLoadDialogBox =
                                                true;
                                            serviceProvider
                                                .buildShowDialog(context);
                                          });

                                          await serviceProvider
                                              .apiCartDataUpdate(
                                            widget.userName,
                                            widget.token,
                                            "${filteredStoreItems[index]['id']}",
                                            'add',
                                          );

                                          cartCounter = serviceProvider.counter;

                                          // CALL THE DIALOG TO ALLOW USER PERFORM OPERATION ON THE UI
                                          setState(() {
                                            serviceProvider.isLoadDialogBox =
                                                false;
                                            serviceProvider
                                                .buildShowDialog(context);
                                          });
                                        }
                                        // ====== ADD ITEM TO CART FOR GUEST USER =========
                                        else if (widget.userName == 'Guest' &&
                                            '${filteredStoreItems[index]['out_of_stock']}' ==
                                                'false') {
                                          serviceProvider.addItem(
                                            "${filteredStoreItems[index]["id"]}",
                                            "${filteredStoreItems[index]["name"]}",
                                            "${filteredStoreItems[index]['discount']}" !=
                                                    '0.00'
                                                ? double.parse(
                                                    "${filteredStoreItems[index]["new_price"]}")
                                                : double.parse(
                                                    "${filteredStoreItems[index]["price"]}"),
                                            "${filteredStoreItems[index]["imageURL"]}",
                                            '${filteredStoreItems[index]['out_of_stock']}',
                                            '${filteredStoreItems[index]['active']}',
                                            '${filteredStoreItems[index]['store']['active']}',
                                          );
                                        } else if ('${filteredStoreItems[index]['out_of_stock']}' ==
                                            'true') {
                                          serviceProvider.warningToastMassage(
                                              'Item is currently out of Stock!');
                                        }
                                      },
                                      child: const Icon(
                                        Icons.add_shopping_cart_sharp,
                                        color: Color(0xFF2962FF),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          );
                        },
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (status == '')
                            const Center(
                              child: CircularProgressIndicator(),
                            ),
                          if (status == 'success')
                            Center(
                              child: Text(
                                'No Record!',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.red.shade200,
                                ),
                              ),
                            ),
                          if (status == 'fail')
                            Center(
                              child: Text(
                                errorMsg.toString(),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.red.shade200,
                                ),
                              ),
                            ),
                        ],
                      ),
              ),
            ],
          ),
        ));
  }

  Container headerSection() {
    return Container(
      margin: const EdgeInsets.all(0.0),
      child: const Text("Seller store",
          style: TextStyle(
              color: Colors.black,
              fontSize: 20.0,
              fontWeight: FontWeight.bold)),
    );
  }
}

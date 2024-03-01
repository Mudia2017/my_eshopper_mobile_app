import 'dart:convert';

import 'package:eshopper_mobile_app/componets/data_computation.dart';
import 'package:eshopper_mobile_app/componets/side_drawer.dart';
import 'package:eshopper_mobile_app/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:number_display/number_display.dart';
import 'package:badges/badges.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MarketPlace extends StatefulWidget {
  // const MarketPlace({Key? key}) : super(key: key);
  final String username;
  final String useremail;
  final String token;
  final String custId;
  final String custName;
  final String custEmail;
  MarketPlace({
    required this.username,
    required this.useremail,
    required this.token,
    required this.custId,
    required this.custName,
    required this.custEmail,
  });

  @override
  _MarketPlaceState createState() => _MarketPlaceState();
}

class _MarketPlaceState extends State<MarketPlace> {
  var cartCounter = 0;
  bool isPtdListFrmServer = false;
  late SharedPreferences sharedPref;
  List cartLists = []; /* USED TO HOLD THE ITEM SAVED IN SHARED PREFERENCE */
  bool isLoadFrmPref = false; // USED TO CHECK IF DATA WAS LOAD FROM SHARED PREF
  bool isSearching = false;
  String status = '';
  String errorMsg = '';
  final _formattedNumber = createDisplay(
    length: 12,
    separator: ',',
    decimal: 2,
    decimalPoint: '.',
  );

  List productList = []; /* USED TO HOLD PRODUCT DATA RECEIVED FROM API */
  List filteredProduct = []; /* USED TO HOLD THE SEARCHED PRODUCT */
  Map<String, dynamic> cartPtdData = {};
  List verifyPtdList = [];
  @override
  void initState() {
    var providerData = Provider.of<DataProcessing>(context, listen: false);
    super.initState();

    productData();
    if (widget.username == 'Guest') {
      loadCartDataFrmSharedPref();
    }
  }

  // GET PRODUCT FROM E-SHOP. FOR AUTHENTICATED USER ONLY, THE SERVER CHECK IF
  // AN OPEN ORDER EXIST ELSE IT CREATE ONE
  productData() async {
    var data = ({
      "customer": {"name": widget.custName, "email": widget.custEmail},
      "user": {'name': widget.username}
    });
    // WE HAVE TO DIFFERENTIATE API CALL FOR AUTHENTICATED AND GUEST USER SINCE
    // A GUEST USER DOES NOT HAVE A TOKEN. WITHOUT TOKEN, THEIR IS AN ERROR FROM
    // THE SERVER.
    if (widget.token != '') {
      var response = await http.post(
        Uri.parse('${dotenv.env['URL_ENDPOINT']}/apis/v1/homePage/api_eshop/'),
        body: jsonEncode(data),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Token ${widget.token}",
        },
      );

      try {
        if (response.statusCode == 200) {
          var productData = json.decode(response.body);
          isPtdListFrmServer = true;
          status = productData['status'];
          setState(() {
            if (status == 'fail') {
              errorMsg = productData['errorMsg'].toString();
            } else {
              productList = filteredProduct = productData['productData'];
              cartCounter = productData['cart_counter'];
            }
          });
        }
      } catch (error) {
        rethrow;
      }
    } else {
      var response = await http.post(
        Uri.parse('${dotenv.env['URL_ENDPOINT']}/apis/v1/homePage/api_eshop/'),
      );

      try {
        if (response.statusCode == 200) {
          var productData = json.decode(response.body);
          status = productData['status'];
          setState(() {
            if (status == 'fail') {
              errorMsg = productData['errorMsg'].toString();
            } else {
              productList = filteredProduct = productData['productData'];
            }
          });
        }
      } catch (error) {
        rethrow;
      }
    }
  }

  void _filterProduct(value) {
    setState(() {
      filteredProduct = productList
          .where((product) =>
              product['name'].toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
  }

  // ============== LOAD CART DATA FROM SHARED PREFERENCE ===========
  Future loadCartDataFrmSharedPref() async {
    sharedPref = await SharedPreferences.getInstance();
    final savedCartItem = sharedPref.getStringList('saveCartItem');
    if (savedCartItem != null) {
      cartLists = [];
      cartLists = savedCartItem
          .map((item) => CartItem.fromMap(json.decode(item)))
          .toList();
      isLoadFrmPref = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    var serviceProvider = Provider.of<DataProcessing>(context);

    // THIS HELP TO RELOAD THE CART COUNTER IN CASE USER ADD OR REOMVE ITEM
    // FROM THE CART PAGE. IF THE BACK ARROW IS CLICKED, THE COUNTER IN THE
    // MARKET PAGE IS UPDATED
    if (widget.username == 'Guest') {
      if (isLoadFrmPref == true) {
        for (var cartList in cartLists) {
          // SINCE ITEMS WERE UPLOADED FROM SHARED PREFERENCE, ITS POSSIBLE
          // PRICES AND OUT-OF-STOCK STATUS MIGHT HAVE CHANGED. WE NEED TO
          // VERIFY IF THER IS ANY CHANGES AND PROMPT THE USER.
          // for (var x = 0; x < productList.length; x++) {
          //   if (int.parse(cartList.pdtid) == productList[x]['id']) {
          //     if (productList[x]['discount'] == '0.00') {
          //       if (cartList.cartProductPrice !=
          //           double.parse(productList[x]['price'])) {
          //         cartList.cartProductPrice =
          //             double.parse(productList[x]['price']);
          //         break;
          //       }
          //     } else {
          //       if (cartList.cartProductPrice !=
          //           double.parse(productList[x]['new_price'])) {
          //         cartList =
          //             double.parse(productList[x]['new_price']);
          //         break;
          //       }
          //     }
          //   }
          // }

          serviceProvider.loadCartData(
            cartList.pdtid,
            cartList.cartProductName,
            cartList.cartProductPrice,
            cartList.cartProductImage,
            cartList.cartProductQuantity,
            cartList.cartProdOutOfStock,
            cartList.cartActivePtd,
            cartList.cartActiveStore,
          );
        }
        isLoadFrmPref = false;
      }

      cartCounter = serviceProvider.totalCartItm;
    } else if (serviceProvider.isApiLoaded == true &&
        isPtdListFrmServer == false) {
      cartCounter = serviceProvider.counter;
      // cartData.isApiLoaded = false;
    } else {
      isPtdListFrmServer = false;
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
          flexibleSpace: Container(
            decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [
              Color(0xFF40C4FF),
              Color(0xFFA7FFEB),
            ])),
          ),
          elevation: 0,
          // title: headerSection(),
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
                          _filterProduct(value);
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
                              filteredProduct = productList;
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
                if (widget.username != 'Guest') {
                  Navigator.of(context)
                      .pushNamed(RouteManager.authenticCartPage, arguments: {
                    'name': widget.username,
                    'email': widget.useremail,
                    'token': widget.token,
                    'custId': widget.custId,
                  });
                }
              },
              child: Badge(
                child: IconButton(
                  onPressed: () async {
                    // CART PAGE ROUTE FOR AUTHENTIC USER
                    if (widget.username != 'Guest') {
                      Navigator.of(context).pushNamed(
                          RouteManager.authenticCartPage,
                          arguments: {
                            'name': widget.username,
                            'email': widget.useremail,
                            'token': widget.token,
                            'custId': widget.custId,
                          });
                    } else if (widget.username == 'Guest') {
                      // CHECK IF THERE ARE CART ITEMS IN THE SHOPPING CART
                      if (cartLists.isNotEmpty || cartLists.isEmpty) {
                        // SINCE CART ITEM HAVE BEEN IN THE SHARED PREFERENCE
                        // CHECK FOLLOWING ITEM(S) WITH THE DATABASE:
                        // 1. THAT THE CART ITEM IS CURRENTLY IN STOCK.
                        // 2. THAT THE PRICE OF THE CART ITEM TALLY WITH DB PRICE.
                        // 3. THAT THE ITEM IS ACTIVE
                        // 4. THAT THE STORE ITEM IS ACTIVE
                        verifyPtdList = [];
                        for (var x = 0; x < serviceProvider.items.length; x++) {
                          cartPtdData = {
                            'guestCartPtdId':
                                serviceProvider.items.values.toList()[x].pdtid,
                            'guestCartPtdPrice': serviceProvider.items.values
                                .toList()[x]
                                .cartProductPrice,
                            'guestCartOutOfStock': serviceProvider.items.values
                                .toList()[x]
                                .cartProdOutOfStock,
                            'guestCartActivePtd': serviceProvider.items.values
                                .toList()[x]
                                .cartActivePtd,
                            'guestCartActiveStore': serviceProvider.items.values
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
                        // THIS MEANS THE ITEM IN THE CART TALLY WITH SERVER
                        // FOR PRICE, OUT-OF-STOCK STATUS AND ACTIVE ITEM/STORE
                        // NO CHANGES NEED TO BE MADE
                        if (serverResponse[0] == 'valid') {
                          Navigator.of(context)
                              .pushNamed(RouteManager.guestCart);
                        } else if (serverResponse[0] != 'valid') {
                          // LOOP THROUGH THE CART DATA AND UPDATE THEM WITH
                          // THE RECORD FROM THE SERVER BEFORE NAVIGATING TO
                          // GUEST CART PAGE
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
                          Navigator.of(context)
                              .pushNamed(RouteManager.guestCart);
                        }
                      } else {
                        Navigator.of(context).pushNamed(RouteManager.guestCart);
                      }
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
                  cartCounter.toString() == 'null'
                      ? '0'
                      : cartCounter.toString(),
                  style: const TextStyle(
                      fontSize: 10.0,
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
        drawer: const SafeArea(
          child: Drawer(
            child: SideDrawer(
              caller: 'innerSideDrawer',
            ),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            productData();
          },
          child: filteredProduct.isNotEmpty
              ? ListView.builder(
                  itemCount: filteredProduct.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
                                          "${filteredProduct[index]["id"]}",
                                      'category':
                                          "${filteredProduct[index]["category"]}",
                                      'cartCounter': cartCounter,
                                    });
                              },
                              child: Row(
                                children: [
                                  // if ("${filteredProduct[index]["imageURL"]}"
                                  //     .contains('images'))
                                  if ("${filteredProduct[index]["imageURL"]}" ==
                                      "${dotenv.env['URL_ENDPOINT']}")
                                    Container(
                                      height: 120,
                                      width: 120,
                                      child: const Icon(
                                        Icons.photo_size_select_actual_sharp,
                                        color: Colors.black26,
                                        size: 100,
                                      ),
                                    ),
                                  if ("${filteredProduct[index]["imageURL"]}" !=
                                      "${dotenv.env['URL_ENDPOINT']}")
                                    Container(
                                      height: 120,
                                      width: 120,
                                      child: Image.network(
                                        "${filteredProduct[index]["imageURL"]}",
                                      ),
                                    ),
                                  Flexible(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "${filteredProduct[index]["name"]}",
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                          style: GoogleFonts.sora().copyWith(
                                              color: Colors.blue.shade700),
                                        ),
                                        if ("${filteredProduct[index]['mfgDate']}" !=
                                            'null')
                                          Text(
                                            "Mfd Date: ${filteredProduct[index]["mfgDate"]}",
                                            style: GoogleFonts.publicSans(
                                                    fontSize: 11)
                                                .copyWith(
                                                    color: Colors.black45),
                                          ),
                                        if ("${filteredProduct[index]['expDate']}" !=
                                            'null')
                                          Text(
                                            "Exp Date: ${filteredProduct[index]["expDate"]}",
                                            style: GoogleFonts.publicSans(
                                                    fontSize: 11)
                                                .copyWith(
                                                    color: Colors.black45),
                                          ),
                                        if ("${filteredProduct[index]['discount']}" !=
                                            '0.00')
                                          Row(
                                            children: [
                                              Text(
                                                "${filteredProduct[index]["discount"]} % off",
                                                style: GoogleFonts.publicSans()
                                                    .copyWith(fontSize: 13),
                                              ),
                                              const SizedBox(
                                                width: 15,
                                              ),
                                              Text(
                                                "was: ",
                                                style: GoogleFonts.publicSans()
                                                    .copyWith(
                                                  fontSize: 12,
                                                ),
                                              ),
                                              Text(
                                                "₦ " +
                                                    _formattedNumber(double.parse(
                                                        "${filteredProduct[index]["price"]}")),
                                                style: GoogleFonts.publicSans()
                                                    .copyWith(
                                                  color: Colors.grey,
                                                  decoration: TextDecoration
                                                      .lineThrough,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        if ("${filteredProduct[index]['discount']}" ==
                                            '0.00')
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "₦ " +
                                                    _formattedNumber(double.parse(
                                                        "${filteredProduct[index]["price"]}")),
                                                style: GoogleFonts.publicSans()
                                                    .copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                ),
                                              ),
                                              if ('${filteredProduct[index]['out_of_stock']}' ==
                                                  'true')
                                                Badge(
                                                  // position: badges.BadgePosition
                                                  //     .topEnd(top: 0, end: 7),
                                                  // badgeAnimation: const badges
                                                  //     .BadgeAnimation.slide(),
                                                  // badgeStyle: badges.BadgeStyle(
                                                  //   badgeColor: Colors
                                                  //       .redAccent.shade700,
                                                  //   shape: badges
                                                  //       .BadgeShape.square,
                                                  //   elevation: 3.0,
                                                  //   borderRadius:
                                                  //       BorderRadius.circular(
                                                  //           10),
                                                  // ),
                                                  badgeColor:
                                                      Colors.redAccent.shade700,
                                                  animationType:
                                                      BadgeAnimationType.fade,
                                                  shape: BadgeShape.square,
                                                  elevation: 3.0,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  badgeContent: const Center(
                                                    child: Text(
                                                      'Out of stock',
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.w800),
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        if ("${filteredProduct[index]['discount']}" !=
                                            '0.00')
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "₦ " +
                                                    _formattedNumber(double.parse(
                                                        "${filteredProduct[index]["new_price"]}")),
                                                style: GoogleFonts.publicSans()
                                                    .copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                ),
                                              ),
                                              if ('${filteredProduct[index]['out_of_stock']}' ==
                                                  'true')
                                                Badge(
                                                  // position: badges.BadgePosition
                                                  //     .topEnd(top: 0, end: 7),
                                                  // badgeAnimation: badges
                                                  //     .BadgeAnimation.fade(),
                                                  // badgeStyle: badges.BadgeStyle(
                                                  //   badgeColor: Colors
                                                  //       .redAccent.shade700,
                                                  //   shape: badges
                                                  //       .BadgeShape.square,
                                                  //   elevation: 3.0,
                                                  //   borderRadius:
                                                  //       BorderRadius.circular(
                                                  //           10),
                                                  // ),
                                                  badgeColor:
                                                      Colors.redAccent.shade700,
                                                  animationType:
                                                      BadgeAnimationType.fade,
                                                  shape: BadgeShape.square,
                                                  elevation: 3.0,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  badgeContent: const Center(
                                                    child: Text(
                                                      'Out of stock',
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.w800),
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
                                      '${filteredProduct[index]['averageStarRated']}')),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                serviceProvider.formattedNumber(double.parse(
                                    '${filteredProduct[index]['counter']}')),
                                style: GoogleFonts.publicSans().copyWith(
                                    color: Colors.grey.shade700, fontSize: 15),
                              ),
                              const SizedBox(width: 20),
                              InkWell(
                                onTap: () async {
                                  // CALL THE DIALOG TO PREVENT USER FROM THE UI UNTIL DATA IS SAVED TO THE SERVER
                                  setState(() {
                                    serviceProvider.isLoadDialogBox = true;
                                    serviceProvider.buildShowDialog(context);
                                  });
                                  var serverResponse;

                                  // UPDATE WISH LIST FOR AUTHENTICATED USER
                                  if (widget.username != 'Guest' &&
                                      widget.useremail != '' &&
                                      filteredProduct[index]['isFavorite'] ==
                                          false) {
                                    serverResponse = await serviceProvider
                                        .sendWishListPtdToDB(
                                      "${filteredProduct[index]["id"]}",
                                      'heartFill',
                                      widget.token,
                                    );
                                  } else if (widget.username != 'Guest' &&
                                      widget.useremail != '' &&
                                      filteredProduct[index]['isFavorite'] ==
                                          true) {
                                    serverResponse = await serviceProvider
                                        .sendWishListPtdToDB(
                                      "${filteredProduct[index]["id"]}",
                                      'heart',
                                      widget.token,
                                    );
                                  } else {
                                    serviceProvider.toastMessage(
                                        'Favorite item is only for log in user');
                                  }

                                  if (serverResponse == false) {
                                    setState(() {
                                      filteredProduct[index]['isFavorite'] =
                                          false;
                                    });
                                    serviceProvider.toastMessage(
                                        'Product was removed from wish list');
                                  } else if (serverResponse == true) {
                                    setState(() {
                                      filteredProduct[index]['isFavorite'] =
                                          true;
                                    });
                                    serviceProvider.toastMessage(
                                        'Product was added to wish list');
                                  }

                                  // CALL THE DIALOG TO ALLOW USER PERFORM OPERATION ON THE UI
                                  setState(() {
                                    serviceProvider.isLoadDialogBox = false;
                                    serviceProvider.buildShowDialog(context);
                                  });
                                },
                                child: !filteredProduct[index]['isFavorite']
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
                                  if ((widget.username != 'Guest' ||
                                          widget.useremail != '') &&
                                      '${filteredProduct[index]['out_of_stock']}' ==
                                          'false') {
                                    // CALL THE DIALOG TO PREVENT USER FROM THE UI UNTIL DATA IS SAVED TO THE SERVER
                                    setState(() {
                                      serviceProvider.isLoadDialogBox = true;
                                      serviceProvider.buildShowDialog(context);
                                    });

                                    await serviceProvider.apiCartDataUpdate(
                                      widget.username,
                                      widget.token,
                                      "${filteredProduct[index]['id']}",
                                      'add',
                                    );

                                    cartCounter = serviceProvider.counter;

                                    // CALL THE DIALOG TO ALLOW USER PERFORM OPERATION ON THE UI
                                    setState(() {
                                      serviceProvider.isLoadDialogBox = false;
                                      serviceProvider.buildShowDialog(context);
                                    });
                                  }
                                  // ====== ADD ITEM TO CART FOR GUEST USER =========
                                  else if (widget.username == 'Guest' &&
                                      '${filteredProduct[index]['out_of_stock']}' ==
                                          'false') {
                                    serviceProvider.addItem(
                                      "${filteredProduct[index]["id"]}",
                                      "${filteredProduct[index]["name"]}",
                                      "${filteredProduct[index]['discount']}" !=
                                              '0.00'
                                          ? double.parse(
                                              "${filteredProduct[index]["new_price"]}")
                                          : double.parse(
                                              "${filteredProduct[index]["price"]}"),
                                      "${filteredProduct[index]["imageURL"]}",
                                      '${filteredProduct[index]['out_of_stock']}',
                                      '${filteredProduct[index]['active']}',
                                      '${filteredProduct[index]['store']['active']}',
                                    );
                                  } else if ('${filteredProduct[index]['out_of_stock']}' ==
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
      ),
    );
  }

  Container headerSection() {
    return Container(
      margin: const EdgeInsets.all(0.0),
      child: const Text("Market Place",
          style: TextStyle(
              color: Colors.black,
              fontSize: 25.0,
              fontWeight: FontWeight.bold)),
    );
  }
}

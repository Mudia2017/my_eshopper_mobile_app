import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:badges/badges.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:eshopper_mobile_app/componets/data_computation.dart';
import 'package:eshopper_mobile_app/componets/side_drawer.dart';
import 'package:eshopper_mobile_app/componets/sub_home_page.dart';
import 'package:eshopper_mobile_app/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List recentViewList = [];
  List watchItemList = [];
  List dailyDeals = [];
  List dailyCategory = [];
  List dailyBrands = [];
  String userName = 'Guest';
  String userEmail = '';
  String userToken = '';
  String customerId = '';
  int cartCounter = 0;
  bool isDoneLoading = false;
  List productList = []; /* USED TO HOLD PRODUCT DATA RECEIVED FROM API */
  List cartLists = []; /* USED TO HOLD THE ITEM SAVED IN SHARED PREFERENCE */
  late SharedPreferences sharedPref;
  bool isLoadFrmPref = false; // USED TO CHECK IF DATA WAS LOAD FROM SHARED PREF
  List verifyPtdList = [];
  Map<String, dynamic> cartPtdData = {};
  bool isServerResp = false;
  late StreamSubscription subscription;
  var isDeviceConnected = false;
  bool isAlertSet = false;

  void initState() {
    networkConnectivity();
    super.initState();

    getUserNamePreference();
    getUserEmailPreference();
    getUserTokenPreference();
    getCustomerIdPreference();

    if (userName == 'Guest') {
      loadCartDataFrmSharedPref();
    }

    // clearSharedPreferences();
  }

  networkConnectivity() {
    // var providerData = Provider.of<DataProcessing>(context, listen: false);

    subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) async {
      isDeviceConnected = await InternetConnectionChecker().hasConnection;
      if (isDeviceConnected == true) {
        print('TRUE');
      } else {
        print('FALSE');
      }
    });
  }

  Future getUserNamePreference() async {
    var prefName = await DataProcessing.getUserNamePreference();
    setState(() {
      userName = prefName;
    });
    print(userName);
  }

  Future getUserEmailPreference() async {
    var prefEmail = await DataProcessing.getUserEmailPreference();
    setState(() {
      userEmail = prefEmail;
    });
  }

  Future getUserTokenPreference() async {
    var prefToken = await DataProcessing.getTokenFrmPreference();
    setState(() {
      userToken = prefToken;
    });
  }

  Future getCustomerIdPreference() async {
    var prefCusId = await DataProcessing.getCusIdPreference();
    setState(() {
      customerId = prefCusId;
    });
    // WE CALL THIS FUNCTION HERE SINCE USERNAME, EMAIL, TOKEN ARE ALL
    // FUTURE FUNCTION THAT WILL WAIT FOR RESPONSE BEFORE UPDATING THE VARIBLES
    getHomePageRecords();
  }

  // ====== CLEAR SHARED PREFERENCE ===========
  Future clearSharedPreferences() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.clear();
  }

  // FUNCTION CALL TO GET THE FOLLOWING RECORDS ON THE HOME PAGE:
  // --- RECENTLY VIEWED ITEM; --- YOUR WATCHED LIST; --- DAILY DEALS
  // --- SHOPPING BY CATEGORIES; --- SHOPPING BY BRANDS
  void getHomePageRecords() async {
    isServerResp = false;
    var response;

    Map data = {
      // "customer": {"name": userName}
    };
    try {
      if (userToken != '') {
        response = await http.post(
          // Uri.parse("${dotenv.env['URL_ENDPOINT']}/apis/v1/homePage/api_homePage/"),
          Uri.parse(
              "${dotenv.env['URL_ENDPOINT']}/apis/v1/homePage/api_homePage/"),
          body: json.encode(data),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Token $userToken",
          },
        );
        try {
          if (response.statusCode == 200) {
            var _authUserData = json.decode(response.body);

            setState(() {
              recentViewList = _authUserData['authUserData']['recentViewList'];
              watchItemList = _authUserData['authUserData']['watchItemList'];
              dailyDeals = _authUserData['generalData']['dailyDeals'];
              dailyCategory = _authUserData['generalData']['dailyCat'];
              dailyBrands = _authUserData['generalData']['dailyBrands'];
              productList = _authUserData['generalData']['ptdData'];
              cartCounter = _authUserData['cartCounter'];
            });
            isDoneLoading = true;
          }
        } catch (error) {
          rethrow;
        }
      } else {
        response = await http.post(
          // Uri.parse('${dotenv.env['URL_ENDPOINT']}/apis/v1/homePage/api_homePage/'),
          Uri.parse(
              '${dotenv.env['URL_ENDPOINT']}/apis/v1/homePage/api_homePage/'),
        );

        print(response);
        try {
          if (response.statusCode == 200) {
            var productData = json.decode(response.body);
            setState(() {
              dailyDeals = productData['generalData']['dailyDeals'];
              dailyCategory = productData['generalData']['dailyCat'];
              dailyBrands = productData['generalData']['dailyBrands'];
              productList = productData['generalData']['ptdData'];
            });
          }
        } catch (error) {
          rethrow;
        }
      }
    } catch (error) {
      setState(() {
        isServerResp = true;
      });
    }
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
    if (userName == 'Guest') {
      if (isLoadFrmPref == true) {
        for (var cartList in cartLists) {
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
    } else if (serviceProvider.isApiLoaded == true && isDoneLoading == false) {
      cartCounter = serviceProvider.counter;
    } else {
      isDoneLoading = false;
    }

    if (serviceProvider.isRecentlyViewItmDeleted == true) {
      setState(() {
        recentViewList = [];
      });
      serviceProvider.isRecentlyViewItmDeleted = false;
    }

    if (dailyDeals.isNotEmpty && isServerResp == true) {
      serviceProvider.warningToastMassage('Network error');
    } else if (dailyDeals.isEmpty && isServerResp == true) {
      isServerResp;
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
          actions: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 25.0,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
              child: IconButton(
                  icon: const Icon(
                    Icons.search,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.of(context)
                        .pushNamed(RouteManager.searchTemplate, arguments: {
                      'ptdList': productList,
                    });
                  }),
            ),
            InkWell(
              onTap: () async {
                // CART PAGE ROUTE FOR AUTHENTIC USER
                if (userName != 'Guest') {
                  Navigator.of(context)
                      .pushNamed(RouteManager.authenticCartPage, arguments: {
                    'name': userName,
                    'email': userEmail,
                    'token': userToken,
                    'custId': customerId,
                  });
                } else if (userName == 'Guest') {
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

                  var serverResponse =
                      await serviceProvider.guestVerifyCartItems(verifyPtdList);

                  // CALL THE DIALOG TO ALLOW USER PERFORM OPERATION ON THE UI
                  serviceProvider.isLoadDialogBox = false;
                  serviceProvider.buildShowDialog(context);

                  // THIS MEANS THE ITEM IN THE CART TALLY WITH SERVER
                  // FOR PRICE, OUT-OF-STOCK STATUS AND ACTIVE ITEM/STORE
                  // NO CHANGES NEED TO BE MADE
                  if (serverResponse[0] == 'valid') {
                    Navigator.of(context).pushNamed(RouteManager.guestCart);
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
                    Navigator.of(context).pushNamed(RouteManager.guestCart);
                  }
                } else {
                  Navigator.of(context).pushNamed(RouteManager.guestCart);
                }
              },
              child: Badge(
                child: IconButton(
                  onPressed: () async {
                    // CART PAGE ROUTE FOR AUTHENTIC USER
                    if (userName != 'Guest') {
                      Navigator.of(context).pushNamed(
                          RouteManager.authenticCartPage,
                          arguments: {
                            'name': userName,
                            'email': userEmail,
                            'token': userToken,
                            'custId': customerId,
                          });
                    } else if (userName == 'Guest') {
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
                        Navigator.of(context).pushNamed(RouteManager.guestCart);
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
                        Navigator.of(context).pushNamed(RouteManager.guestCart);
                      }
                    } else {
                      Navigator.of(context).pushNamed(RouteManager.guestCart);
                    }
                  },
                  icon: const Icon(
                    Icons.shopping_cart_sharp,
                    color: Colors.black54,
                    size: 35,
                  ),
                ),
                badgeContent: Text(
                  cartCounter.toString(),
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
            )
          ],
        ),
        drawer: const SafeArea(
          child: Drawer(
              child: SideDrawer(
            caller: 'homeSideDrawer',
          )),
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            getHomePageRecords();
            if (userName == 'Guest') {
              loadCartDataFrmSharedPref();
            }
          },
          child: ListView(
            padding: const EdgeInsets.all(8),
            children: <Widget>[
              Column(
                children: [
                  // ====== HORIZONTAL VIEW OF RECENTLY VIEWED ITEMS ========
                  if (recentViewList.isNotEmpty)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Your recently viewed items',
                            style: GoogleFonts.sora().copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              overflow: TextOverflow.ellipsis,
                            ),
                            maxLines: 1,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.of(context).pushNamed(
                                RouteManager.allRecentVivedItm,
                                arguments: {
                                  'custId': customerId,
                                  'token': userToken,
                                  'userName': userName,
                                  'userEmail': userEmail,
                                  'cartCounter': cartCounter.toString(),
                                });
                          },
                          child: Text(
                            'View all',
                            style: GoogleFonts.sora().copyWith(
                                fontSize: 18,
                                decoration: TextDecoration.underline,
                                color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  if (recentViewList.isNotEmpty)
                    RecentViewItems(recentViewList: recentViewList),

                  // ====== HORIZONTAL VIEW OF WISH LIST ========
                  if (watchItemList.isNotEmpty)
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Your watched items',
                            style: GoogleFonts.sora().copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                overflow: TextOverflow.ellipsis),
                            maxLines: 1,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            if (userToken.isNotEmpty) {
                              Navigator.of(context).pushNamed(
                                  RouteManager.myWishList,
                                  arguments: {
                                    'token': userToken,
                                    'customer_id': customerId,
                                    'customerName': userName,
                                    'custEmail': userEmail,
                                  });
                            } else {
                              serviceProvider.warningToastMassage(
                                  'Only for registered user');
                            }
                          },
                          child: Text(
                            'View all',
                            style: GoogleFonts.sora().copyWith(
                                fontSize: 18,
                                decoration: TextDecoration.underline,
                                color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  if (watchItemList.isNotEmpty)
                    RecentViewItems(recentViewList: watchItemList),

                  // ====== HORIZONTAL VIEW OF DAILY DEALS ========
                  if (dailyDeals.isNotEmpty)
                    Row(
                      children: [
                        Text(
                          'Daily deals',
                          style: GoogleFonts.sora().copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  if (dailyDeals.isNotEmpty)
                    RecentViewItems(recentViewList: dailyDeals),

                  // ====== HORIZONTAL VIEW OF CATEGORY SHOP ========
                  if (dailyDeals.isNotEmpty ||
                      watchItemList.isNotEmpty ||
                      watchItemList.isNotEmpty)
                    Column(
                      children: const [
                        SizedBox(
                          height: 20,
                        ),
                        Divider(
                          color: Colors.black38,
                        ),
                      ],
                    ),
                  if (dailyCategory.isNotEmpty)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Category shopping',
                            style: GoogleFonts.sora().copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              overflow: TextOverflow.ellipsis,
                            ),
                            maxLines: 1,
                          ),
                        ),
                        InkWell(
                          onTap: () {},
                          child: Text(
                            'View all',
                            style: GoogleFonts.sora().copyWith(
                                fontSize: 18,
                                decoration: TextDecoration.underline,
                                color: Colors.black),
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(
                    height: 15,
                  ),
                  if (dailyCategory.isNotEmpty)
                    DailyCategoryList(
                      dailyCategoryList: dailyCategory,
                    ),
                  if (dailyCategory.isNotEmpty || dailyBrands.isNotEmpty)
                    const Divider(
                      color: Colors.black38,
                    ),

                  if (dailyBrands.isNotEmpty)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Shop by brands',
                            style: GoogleFonts.sora().copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              overflow: TextOverflow.ellipsis,
                            ),
                            maxLines: 1,
                          ),
                        ),
                        InkWell(
                          onTap: () {},
                          child: Text(
                            'View all',
                            style: GoogleFonts.sora().copyWith(
                                fontSize: 18,
                                decoration: TextDecoration.underline,
                                color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  if (dailyBrands.isNotEmpty)
                    DailyBrands(dailyBrands: dailyBrands),
                ],
              ),
              if (isServerResp == true && dailyDeals.isEmpty)
                serviceProvider.noServerResponse()
            ],
          ),
        ),
      ),
    );
  }
}

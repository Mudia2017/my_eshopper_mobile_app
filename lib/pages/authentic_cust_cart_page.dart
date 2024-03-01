import 'dart:convert';
// import 'dart:ffi';
import 'dart:io';

import 'package:badges/badges.dart';
import 'package:eshopper_mobile_app/componets/data_computation.dart';
import 'package:eshopper_mobile_app/componets/authentic_sub_cart_page.dart';
import 'package:eshopper_mobile_app/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:number_display/number_display.dart';

class AuthenticCartPage extends StatefulWidget {
  final String name;
  final String email;
  final String userToken;
  final String custId;
  AuthenticCartPage(
      {required this.name,
      required this.email,
      required this.userToken,
      required this.custId});

  @override
  _AuthenticCartPageState createState() => _AuthenticCartPageState();
}

class _AuthenticCartPageState extends State<AuthenticCartPage> {
  List cartData = [];
  String grandTotal = '0.0';
  bool isDoneLoading = false;
  bool isLoadingSpinner = false;
  var cartCounter = 0;
  List myWishListItems = [];
  List recentViewList = [];
  // String customerId = '';

  final _formattedNumber = createDisplay(
    length: 12,
    separator: ',',
    decimal: 2,
    decimalPoint: '.',
  );

  @override
  void initState() {
    super.initState();
    // getCustomerIdPreference();
    apiCartData(widget.name, widget.email, widget.userToken);
    initializingFunctionCall(widget.userToken, widget.custId, '', '');
  }

  Future apiCartData(String name, email, userToken) async {
    Map data = ({
      "customer": {"name": name, "email": email},
    });

    var response = await http.post(
      // Uri.parse("${dotenv.env['URL_ENDPOINT']}/apis/v1/homePage/api_cartData/"),
      Uri.parse("${dotenv.env['URL_ENDPOINT']}/apis/v1/homePage/api_cartData/"),
      body: jsonEncode(data),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Token $userToken"
      },
    );
    if (response.statusCode == 200) {
      var cartRecords = json.decode(response.body);

      setState(() {
        cartData = cartRecords['cartItm']['cart item'];
        grandTotal = (cartRecords['cartItm']['grand total']).toString();
        cartCounter = cartRecords['cartItm']['cart total count'];
        recentViewList = cartRecords['recentViewList'];
        isDoneLoading = true;
        isLoadingSpinner = true;
      });
    }
  }

  void initializingFunctionCall(token, customerId, selectedList, action) async {
    var serviceProvider = Provider.of<DataProcessing>(context, listen: false);
    var response = await serviceProvider.getWishListItem(
        token, customerId, selectedList, action, '');

    setState(() {
      myWishListItems = response['myWishListItems'];
    });
  }

  @override
  Widget build(BuildContext context) {
    var serviceProvider = Provider.of<DataProcessing>(context);

    // THIS CONDITION IS USED TO DISPLAY THE LATEST UPDATE OF WISH-LIST ITEM
    // IF WE DELETE WISH-LIST FROM CART PAGE. MEANING INACTIVE ITEM
    if (isDoneLoading == false && serviceProvider.isSuccess == true) {
      myWishListItems = serviceProvider.result['myWishListItems'];
      serviceProvider.isSuccess = false;
    }

    // CONDITION USED TO UPDATE WISH-LIST WHEN WE ADD WISH-LIST TO CART.
    if (serviceProvider.isWishListData) {
      myWishListItems = serviceProvider.wishListData;
      serviceProvider.isWishListData = false;
    }

    // THIS CONDITION IS PLACED IN CASE THE USER PRESS THE +VE OR -VE SHOPPING CART
    // ICON. IF IT'S PRESSED, THIS CONDITION WILL EXECUTE. OVER RIDING THE INITIAL
    // CART-DATA THAT WAS LOADED TO DISPLAY THE CURRENT CART-DATA.
    if (serviceProvider.isApiLoaded == true && isDoneLoading == false) {
      grandTotal = serviceProvider.grandTotal;
      cartData = serviceProvider.updatedCartItems;
      cartCounter = serviceProvider.counter;
    } else {
      isDoneLoading = false;
    }
    return Scaffold(
      appBar: AppBar(
        title: headerSection(),
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [
              Color(0xFF40C4FF),
              Color(0xFFA7FFEB),
            ]),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: cartData.isNotEmpty || myWishListItems.isNotEmpty
                ? Container(
                    child: ListView(
                      children: [
                        if (cartData.isNotEmpty)
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: cartData.length,
                            itemBuilder: (BuildContext cxt, int x) =>
                                CartPageMainLayOut(
                              '${cartData.toList()[x]['id']}',
                              '${cartData.toList()[x]['id']}',
                              cartData.toList()[x]['price'],
                              cartData.toList()[x]['quantity'],
                              '${cartData.toList()[x]['name']}',
                              '${cartData.toList()[x]['image']}',
                              cartData.toList()[x]['line_total'],
                              widget.name,
                              widget.userToken,
                              '${cartData.toList()[x]['out_of_stock']}',
                              '${cartData.toList()[x]['active']}',
                              '${cartData.toList()[x]['activeStore']}',
                            ),
                          ),
                        if (cartData.isEmpty)
                          Container(
                            child: Column(
                              children: [
                                Image.asset(
                                  'images/empty_cart.png',
                                  height: 80,
                                ),
                                const Text(
                                  "Your shopping cart is empty.",
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold),
                                ),
                                const Text(
                                  "Let's get shopping!",
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                          ),
                        const Divider(
                          thickness: 4,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Text(
                            'Saved Items' ' (${myWishListItems.length})',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        // HORIZONTAL VIEW OF WISH-LIST IN THE CART PAGE
                        if (myWishListItems.isNotEmpty)
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4.0),
                            child: Container(
                              height: 305,
                              width: 300,
                              child: GridView.count(
                                childAspectRatio: 1.75,
                                crossAxisCount: 1,
                                scrollDirection: Axis.horizontal,
                                children: List.generate(myWishListItems.length,
                                    (index) {
                                  // var averageStarRate = 0.0;
                                  // averageStarRate = myWishListItems
                                  //     .toList()[index]['averageStarRate'];
                                  return WishListProduct(
                                    ptdId: myWishListItems.toList()[index]
                                        ['ptdId'],
                                    productName: myWishListItems.toList()[index]
                                        ['ptdName'],
                                    productImage: myWishListItems
                                        .toList()[index]['ptdImage'],
                                    productNewPrice: myWishListItems
                                        .toList()[index]['ptdNewPrice'],
                                    productPrice: myWishListItems
                                        .toList()[index]['ptdPrice'],
                                    discount: myWishListItems.toList()[index]
                                        ['discount'],
                                    category: myWishListItems.toList()[index]
                                        ['category'],
                                    cartCounter: cartCounter,
                                    averageStarRate: myWishListItems
                                        .toList()[index]['averageStarRate']
                                        .toString(),
                                    commentCount: myWishListItems
                                        .toList()[index]['commentCount'],
                                    outOfStock: myWishListItems.toList()[index]
                                        ['out_of_stock'],
                                    isPtdActive: myWishListItems.toList()[index]
                                        ['isActive'],
                                    custId: widget.custId,
                                    token: widget.userToken,
                                    custName: widget.name,
                                    isActiveStore: myWishListItems
                                        .toList()[index]['isActiveStore'],
                                  );
                                }),
                              ),
                            ),
                            // HorizontalWishList(
                            //   wishListData: myWishListItems,
                            // ),
                          ),

                        const Divider(
                          thickness: 15,
                        ),

                        if (recentViewList.isNotEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 15),
                            child: Text(
                              'Items you recently viewed',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                        // HORIZONTAL VIEW OF RECENTLY VIEWED ITEM IN THE CART PAGE
                        if (recentViewList.isNotEmpty)
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4.0),
                            child: Container(
                              height: 250,
                              width: 300,
                              child: GridView.count(
                                childAspectRatio: 1.40,
                                crossAxisCount: 1,
                                scrollDirection: Axis.horizontal,
                                children: List.generate(recentViewList.length,
                                    (index) {
                                  return RecentViewedProduct(
                                    ptdId: recentViewList.toList()[index]['id'],
                                    productName: recentViewList.toList()[index]
                                        ['name'],
                                    productImage: recentViewList.toList()[index]
                                        ['imageURL'],
                                    productPrice: recentViewList.toList()[index]
                                        ['price'],
                                    discount: recentViewList.toList()[index]
                                        ['discount'],
                                    productNewPrice: recentViewList
                                        .toList()[index]['new_price'],
                                    category: recentViewList.toList()[index]
                                        ['category'],
                                    custId: widget.custId,
                                    token: widget.userToken,
                                    custName: widget.name,
                                  );
                                }),
                              ),
                            ),
                          ),
                      ],
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isLoadingSpinner == false)
                        const CircularProgressIndicator()
                      else
                        Image.asset(
                          'images/empty_cart.png',
                          height: 80,
                        ),
                      const Text(
                        "Your shopping cart is empty.",
                        style: TextStyle(
                            color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        "Let's get shopping!",
                        style: TextStyle(
                            color: Colors.red, fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text('Items:',
                        style: GoogleFonts.sora()
                            .copyWith(fontSize: 17.0, color: Colors.grey)),
                    Text(
                      cartCounter.toString() == 'null'
                          ? '0'
                          : cartCounter.toString(),
                      style: GoogleFonts.publicSans().copyWith(
                          fontSize: 17.0, fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text('Total:',
                        style: GoogleFonts.sora()
                            .copyWith(fontSize: 17.0, color: Colors.grey)),
                    Text(
                      "₦ " + _formattedNumber(double.parse(grandTotal)),
                      style: GoogleFonts.publicSans().copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.lightBlueAccent.shade700,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
                MaterialButton(
                  height: 50,
                  elevation: 5,
                  onPressed: () {
                    // CHECK FOR ITEMS THAT OUT OF STOCK,
                    // CHECK FOR INACTIVE ITEMS
                    // CHECK FOR ITEMS IN INACTIVE STORE
                    // CHECK IF USER IS AUTHENTICATED
                    bool isOutOfStock = false;
                    bool isInactiveItem = false;
                    bool isAuthenticated = true;
                    for (int x = 0; x < cartData.length; x++) {
                      if ('${cartData.toList()[x]['out_of_stock']}' == 'true') {
                        isOutOfStock = true;
                        break;
                      } else if ('${cartData.toList()[x]['active']}' ==
                              'false' ||
                          '${cartData.toList()[x]['activeStore']}' == 'false') {
                        isInactiveItem = true;
                        break;
                      }
                    }

                    // PROCEED TO ITEM SUMMARY PAGE
                    if (isOutOfStock == false &&
                        isInactiveItem == false &&
                        isAuthenticated == true &&
                        widget.userToken != '' &&
                        cartData.isNotEmpty) {
                      Navigator.of(context).pushNamed(RouteManager.orderSummary,
                          arguments: ({
                            "userName": widget.name,
                            "userEmail": widget.email,
                            "token": widget.userToken,
                            'custId': widget.custId,
                          }));
                    } else if (isOutOfStock == true) {
                      serviceProvider.warningToastMassage(
                          'Remove out of stock item from your cart before proceeding');
                    } else if (isInactiveItem == true) {
                      serviceProvider.warningToastMassage(
                          'Remove inactive item from your cart before proceeding');
                    } else if (widget.userToken == '') {
                      serviceProvider
                          .warningToastMassage('User is not authenticated');

                      isAuthenticated = false;
                    } else {
                      serviceProvider.warningToastMassage(
                          "You can't check out an empty cart");
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        "Check Out",
                        style: TextStyle(color: Colors.black, fontSize: 20),
                      ),
                    ],
                  ),
                  color: Colors.orange[400],
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.0)),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          )
        ],
      ),
    );
  }

  Container headerSection() {
    return Container(
      margin: const EdgeInsets.all(0.0),
      child: const Text("Shopping Cart",
          style: TextStyle(
              color: Colors.black,
              fontSize: 25.0,
              fontWeight: FontWeight.bold)),
    );
  }
}

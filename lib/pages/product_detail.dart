import 'dart:convert';
import 'dart:ui';

import 'package:badges/badges.dart';
import 'package:eshopper_mobile_app/componets/data_computation.dart';
import 'package:eshopper_mobile_app/componets/ptd_detail_horizontal_view.dart';
import 'package:eshopper_mobile_app/routes/routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';

class ProductDetail extends StatefulWidget {
  final String ptdId;
  final String category;

  ProductDetail({
    Key? key,
    required this.ptdId,
    required this.category,
  }) : super(key: key);

  @override
  State<ProductDetail> createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  var categoryPtd = [];
  var ptdDetailRecord = {};
  var firstFewComments = [];
  var ptdReviewData = [];

  var fewComment = {};
  var firstComment = [];
  var secondComment = [];
  var thirdComment = [];
  var fouthComment = [];
  bool isOut = false;
  var userName = 'Guest';
  var userEmail = '';
  var token = '';
  var custId = '';
  var cartCounter = 0;
  List verifyPtdList = [];
  Map<String, dynamic> cartPtdData = {};
  var isWishList = false;

  getPtdDetailSameCategoryPtd(token) async {
    var serviceProvider = Provider.of<DataProcessing>(context, listen: false);
    var response;
    Map data = {
      "categoryName": widget.category,
      "ptdId": int.parse(widget.ptdId),
      "customer": {"name": userName}
    };
    if (token != '' && token != null) {
      response = await http.post(
        Uri.parse(
            "http://192.168.43.50:8000/apis/v1/homePage/api_get_PtdDetail_SameCategoryPtd/"),
        body: json.encode(data),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Token $token",
        },
      );
    } else {
      response = await http.post(
        Uri.parse(
            "http://192.168.43.50:8000/apis/v1/homePage/api_get_PtdDetail_SameCategoryPtd/"),
        body: json.encode(data),
        headers: {
          "Content-Type": "application/json",
        },
      );
    }

    try {
      if (response.statusCode == 200) {
        var productDetailData = json.decode(response.body);

        setState(() {
          ptdDetailRecord = productDetailData['ptdDetailRecord'];
          categoryPtd = productDetailData['ptd_categoryData'];
          firstFewComments = productDetailData['customLatest_FewComments'];
          ptdReviewData = productDetailData['ptdReviewData'];
          isWishList = productDetailData['isHeartFill'];
          if (userName == 'Guest') {
            cartCounter = 0;
          } else {
            cartCounter = productDetailData['cartData']['cart total count'];
          }
        });
        serviceProvider.isApiLoaded = false;
      }

      // THIS IF STATEMENT IS USED TO DISPLAY THE FIRST LATEST REVIEWS ========
      if (firstFewComments.isNotEmpty) {
        int numOfComment = 0;
        for (int x = 0; x < firstFewComments.length; x++) {
          numOfComment += 1;
          fewComment = {
            'product': firstFewComments[x]['product'],
            'customer': firstFewComments[x]['customer'],
            'subject': firstFewComments[x]['subject'],
            'comment': firstFewComments[x]['comment'],
            'rate': firstFewComments[x]['rate'],
            'createdAt': firstFewComments[x]['created_at'],
            'updatedAt': firstFewComments[x]['updated_at']
          };
          if (numOfComment == 1) {
            firstComment.add(fewComment);
          } else if (numOfComment == 2) {
            secondComment.add(fewComment);
          } else if (numOfComment == 3) {
            thirdComment.add(fewComment);
          } else if (numOfComment == 4) {
            fouthComment.add(fewComment);
          }
        }
      }
    } catch (error) {
      rethrow;
    }
  }

  Future getUserInfoFrmSharePref() async {
    userName = await DataProcessing.getUserNamePreference();
    userEmail = await DataProcessing.getUserEmailPreference();
    token = await DataProcessing.getTokenFrmPreference();
    custId = await DataProcessing.getCusIdPreference();
  }

  @override
  void initState() {
    _load();
    super.initState();
  }

  _load() async {
    await getUserInfoFrmSharePref();
    await getPtdDetailSameCategoryPtd(token);
  }

  @override
  Widget build(BuildContext context) {
    var serviceProvider = Provider.of<DataProcessing>(context);

    // THIS HELP TO RELOAD THE CART COUNTER IN CASE USER ADD OR REOMVE ITEM
    // FROM THE CART PAGE. IF THE BACK ARROW IS CLICKED, THE COUNTER IN THE
    // MARKET PAGE IS UPDATED

    if (serviceProvider.isApiLoaded == true) {
      cartCounter = serviceProvider.counter;
    } else if (userName == 'Guest') {
      cartCounter = serviceProvider.totalCartItm;
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
              if (userName != 'Guest') {
                Navigator.of(context)
                    .pushNamed(RouteManager.authenticCartPage, arguments: {
                  'name': userName,
                  'email': userEmail,
                  'token': token,
                  'custId': custId,
                });
              }
            },
            child: Badge(
              child: IconButton(
                onPressed: () async {
                  // CART PAGE ROUTE FOR AUTHENTIC USER
                  if (userName != 'Guest') {
                    Navigator.of(context)
                        .pushNamed(RouteManager.authenticCartPage, arguments: {
                      'name': userName,
                      'email': userEmail,
                      'token': token,
                      'custId': custId,
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
                cartCounter.toString() == 'null' ? '0' : cartCounter.toString(),
                style: const TextStyle(
                    fontSize: 12.0,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
              // badgeStyle: badges.BadgeStyle(
              //   badgeColor: Colors.redAccent.shade700,
              // ),
              // position: badges.BadgePosition.topEnd(top: 0, end: 7),
              // badgeAnimation: badges.BadgeAnimation.slide(),
              badgeColor: Colors.redAccent.shade700,
              position: BadgePosition.topEnd(top: 0, end: 7),
              animationType: BadgeAnimationType.slide,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: '${ptdDetailRecord['imageURL']}' != 'null'
            ? RefreshIndicator(
                onRefresh: () async {
                  getPtdDetailSameCategoryPtd(token);
                },
                child: ListView(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(0),
                      height: 300,
                      child: GridTile(
                        child: Container(
                          padding: const EdgeInsets.all(0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if ('${ptdDetailRecord['imageURL']}' !=
                                  "http://192.168.43.50:8000")
                                Flexible(
                                  child: Image.network(
                                    '${ptdDetailRecord['imageURL']}',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              if ('${ptdDetailRecord['imageURL']}' ==
                                  "http://192.168.43.50:8000")
                                const Flexible(
                                  child: Icon(
                                    Icons.photo_size_select_actual_sharp,
                                    color: Colors.black26,
                                    size: 100,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        footer: Container(
                          padding: const EdgeInsets.all(0),
                          child: ListTile(
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if ('${ptdDetailRecord['out_of_stock']}' ==
                                    'true')
                                  Badge(
                                    // badgeAnimation:
                                    //     badges.BadgeAnimation.fade(),
                                    // badgeStyle: badges.BadgeStyle(
                                    //   badgeColor: Colors.redAccent.shade700,
                                    //   shape: badges.BadgeShape.square,
                                    //   elevation: 8.0,
                                    //   borderRadius: BorderRadius.circular(10),
                                    // ),
                                    badgeColor: Colors.redAccent.shade700,
                                    animationType: BadgeAnimationType.fade,
                                    shape: BadgeShape.square,
                                    elevation: 8.0,
                                    borderRadius: BorderRadius.circular(10),
                                    badgeContent: const Center(
                                      child: Text(
                                        'Out of stock',
                                        style: TextStyle(
                                            fontSize: 20,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800),
                                      ),
                                    ),
                                  ),
                                if (('${ptdDetailRecord['active_store']}' ==
                                            'false' ||
                                        '${ptdDetailRecord['active']}' ==
                                            'false') &&
                                    '${ptdDetailRecord['out_of_stock']}' ==
                                        'false')
                                  Badge(
                                    // badgeAnimation:
                                    //     badges.BadgeAnimation.slide(),
                                    // badgeStyle: badges.BadgeStyle(
                                    //   badgeColor: Colors.redAccent.shade700,
                                    //   shape: badges.BadgeShape.square,
                                    //   elevation: 3.0,
                                    //   borderRadius: BorderRadius.circular(10),
                                    // ),
                                    badgeColor: Colors.redAccent.shade700,
                                    animationType: BadgeAnimationType.fade,
                                    shape: BadgeShape.square,
                                    elevation: 8.0,
                                    borderRadius: BorderRadius.circular(10),
                                    badgeContent: const Center(
                                      child: Text(
                                        'Unavailable',
                                        style: TextStyle(
                                            fontSize: 20,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // =================== PRODUCT INFOMATION ======================
                    Text(
                      '${ptdDetailRecord['ptdName']}',
                      style: GoogleFonts.sora().copyWith(fontSize: 18),
                    ),

                    // ========== PRICE OF PRODUCT IF NO DISCOUNT ===============
                    if ('${ptdDetailRecord['discount']}' == '0.00')
                      Container(
                        padding: const EdgeInsets.all(0),
                        child: Row(
                          children: [
                            Text(
                              '₦ ' +
                                  serviceProvider.formattedNumber(double.parse(
                                      '${ptdDetailRecord['ptdPrice']}')),
                              style: GoogleFonts.publicSans().copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22.0,
                                  color: Colors.lightBlueAccent.shade700),
                            ),
                          ],
                        ),
                      ),
                    // ===== IF THERE IS PRODUCTION DATE BUT NO DISCOUNT =====
                    // ==== EXECUTE THIS CODE ====
                    if ('${ptdDetailRecord['discount']}' == '0.00' &&
                        '${ptdDetailRecord['mfgDate']}' != 'null')
                      Container(
                        padding: const EdgeInsets.all(0),
                        width: 300,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('Mfd Date: ${ptdDetailRecord['mfgDate']}',
                                style: GoogleFonts.publicSans().copyWith(
                                    fontSize: 11, color: Colors.black45)),
                            Text('Exp Date: ${ptdDetailRecord['expDate']}',
                                style: GoogleFonts.publicSans().copyWith(
                                    fontSize: 11, color: Colors.black45)),
                          ],
                        ),
                      ),

                    // ===== IF THERE IS DISCOUNT AND THEIR IS MANUFACTURING DATE =====
                    // ==== THIS WILL STRIKE OUT PRICE AND DISPLAY THE MANUFACTURING DATE OF PRODUCT ======
                    if ('${ptdDetailRecord['discount']}' != '0.00' &&
                        '${ptdDetailRecord['mfgDate']}' != 'null')
                      Container(
                        padding: const EdgeInsets.all(0),
                        child: SizedBox(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '₦ ' +
                                    serviceProvider.formattedNumber(
                                        double.parse(
                                            '${ptdDetailRecord['ptdPrice']}')),
                                style: GoogleFonts.publicSans().copyWith(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13.0,
                                    decoration: TextDecoration.lineThrough),
                              ),
                              Text(
                                'Mfd Date: ${ptdDetailRecord['mfgDate']}',
                                style: GoogleFonts.publicSans().copyWith(
                                    fontSize: 11, color: Colors.black45),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // === IF THERE IS DISCOUNT AND PRODUCT HAVE EXPIRATION DATE...=======
                    // === THIS WILL DISPLAY DISCOUNTED PRICE, PERCENTAGE DISCOUNTED AND...
                    // === EXPIRATION DATE
                    if ('${ptdDetailRecord['discount']}' != '0.00' &&
                        '${ptdDetailRecord['expDate']}' != 'null')
                      Container(
                        padding: const EdgeInsets.all(0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '₦ ' +
                                  serviceProvider.formattedNumber(double.parse(
                                      '${ptdDetailRecord['newPrice']}')),
                              style: GoogleFonts.publicSans().copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22.0,
                                  color: Colors.lightBlueAccent.shade700),
                            ),
                            Text('${ptdDetailRecord['discount']} Off',
                                style: GoogleFonts.publicSans()
                                    .copyWith(fontSize: 13)),
                            Text(
                              'Exp Date: ${ptdDetailRecord['expDate']}',
                              style: GoogleFonts.publicSans().copyWith(
                                  fontSize: 11, color: Colors.black45),
                            ),
                          ],
                        ),
                      ),

                    // === IF THERE IS DISCOUNT BUT NO EXPIRATION DATE... =====
                    // === STRIKE OUT THE CURRENT PRICE ====
                    if ('${ptdDetailRecord['discount']}' != '0.00' &&
                        '${ptdDetailRecord['expDate']}' == 'null')
                      Container(
                        padding: const EdgeInsets.all(0),
                        child: SizedBox(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '₦ ' +
                                    serviceProvider.formattedNumber(
                                        double.parse(
                                            ptdDetailRecord['ptdPrice'])),
                                style: GoogleFonts.publicSans().copyWith(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13.0,
                                    decoration: TextDecoration.lineThrough),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // ==== IF THERE IS DISCOUNT AND NO EXPIRATION DATE... ====
                    // ==== DISPLAY THE DISCOUNTED PRICE AND THE PERCENTAGE OFF ===
                    if ('${ptdDetailRecord['discount']}' != '0.00' &&
                        '${ptdDetailRecord['expDate']}' == 'null')
                      Container(
                        padding: const EdgeInsets.all(0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '₦ ' +
                                  serviceProvider.formattedNumber(double.parse(
                                      '${ptdDetailRecord['newPrice']}')),
                              style: GoogleFonts.publicSans().copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22.0,
                                  color: Colors.lightBlueAccent.shade700),
                            ),
                            Text(
                              '${ptdDetailRecord['discount']} Off',
                              style: GoogleFonts.publicSans().copyWith(),
                            ),
                          ],
                        ),
                      ),

                    Row(
                      children: [
                        serviceProvider.displayHorizontalSmallStar(double.parse(
                            '${ptdDetailRecord['averageStarRated']}')),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          serviceProvider.formattedNumber(
                              double.parse('${ptdDetailRecord['counter']}')),
                          style: GoogleFonts.publicSans().copyWith(
                              color: Colors.grey.shade700, fontSize: 15),
                        ),
                      ],
                    ),

                    // =========== ADD TO CART BUTTON ===============
                    Row(
                      children: [
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.all(0),
                            child: MaterialButton(
                              height: 50,
                              elevation: 2,
                              onPressed: () async {
                                // CALL THE DIALOG TO PREVENT USER FROM THE UI UNTIL DATA IS SAVED TO THE SERVER
                                setState(() {
                                  serviceProvider.isLoadDialogBox = true;
                                  serviceProvider.buildShowDialog(context);
                                });

                                // ADD TO CART ICON-BUTTON FOR AUTHENTICATED USER
                                if (userName != 'Guest' &&
                                    userEmail != '' &&
                                    "${ptdDetailRecord['out_of_stock']}" ==
                                        'false' &&
                                    "${ptdDetailRecord['active']}" == 'true' &&
                                    "${ptdDetailRecord['active_store']}" ==
                                        'true') {
                                  await serviceProvider.apiCartDataUpdate(
                                    userName,
                                    token,
                                    "${ptdDetailRecord['ptdId']}",
                                    'add',
                                  );

                                  cartCounter = serviceProvider.counter;

                                  // ADD ITEM TO CART FOR GUEST USER
                                } else if (userName == 'Guest' &&
                                    "${ptdDetailRecord['out_of_stock']}" ==
                                        'false' &&
                                    "${ptdDetailRecord['active']}" == 'true' &&
                                    "${ptdDetailRecord['active_store']}" ==
                                        'true') {
                                  serviceProvider.addItem(
                                    "${ptdDetailRecord['ptdId']}",
                                    '${ptdDetailRecord['ptdName']}',
                                    '${ptdDetailRecord['discount']}' != '0.00'
                                        ? double.parse(
                                            '${ptdDetailRecord['newPrice']}')
                                        : double.parse(
                                            ptdDetailRecord['ptdPrice']),
                                    '${ptdDetailRecord['imageURL']}',
                                    ('${ptdDetailRecord['out_of_stock']}'),
                                    '${ptdDetailRecord['active']}',
                                    '${ptdDetailRecord['active_store']}',
                                  );

                                  // EXECUTE IF ITEM IS OUT OF STOCK
                                } else if ("${ptdDetailRecord['out_of_stock']}" ==
                                    'true') {
                                  serviceProvider.warningToastMassage(
                                      'Item is currently out of stock!');
                                } else {
                                  serviceProvider.warningToastMassage(
                                      'Item is currently unavailable!');
                                }

                                // CALL THE DIALOG TO ALLOW USER PERFORM OPERATION ON THE UI
                                setState(() {
                                  serviceProvider.isLoadDialogBox = false;
                                  serviceProvider.buildShowDialog(context);
                                });
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text(
                                    "Add to Cart",
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 25),
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Icon(
                                    Icons.add_shopping_cart_sharp,
                                    size: 35,
                                  ),
                                ],
                              ),
                              color: Colors.orange[400],
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4.0)),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                          width: 60,
                          child: IconButton(
                            onPressed: () async {
                              // CALL THE DIALOG TO PREVENT USER FROM THE UI UNTIL DATA IS SAVED TO THE SERVER
                              setState(() {
                                serviceProvider.isLoadDialogBox = true;
                                serviceProvider.buildShowDialog(context);
                              });
                              var serverResponse;

                              // UPDATE WISH LIST FOR AUTHENTICATED USER
                              if (userName != 'Guest' &&
                                  userEmail != '' &&
                                  isWishList == false) {
                                serverResponse =
                                    await serviceProvider.sendWishListPtdToDB(
                                  "${ptdDetailRecord['ptdId']}",
                                  'heartFill',
                                  token,
                                );
                              } else if (userName != 'Guest' &&
                                  userEmail != '' &&
                                  isWishList == true) {
                                serverResponse =
                                    await serviceProvider.sendWishListPtdToDB(
                                  "${ptdDetailRecord['ptdId']}",
                                  'heart',
                                  token,
                                );
                              } else {
                                serviceProvider.toastMessage(
                                    'Favorite item is only for log in user');
                              }
                              if (serverResponse == false) {
                                setState(() {
                                  isWishList = false;
                                  serviceProvider.toastMessage(
                                      'Product was removed from wish list');
                                });
                              } else if (serverResponse == true) {
                                setState(() {
                                  isWishList = true;
                                  serviceProvider.toastMessage(
                                      'Product was added to wish list');
                                });
                              }

                              // CALL THE DIALOG TO ALLOW USER PERFORM OPERATION ON THE UI
                              setState(() {
                                serviceProvider.isLoadDialogBox = false;
                                serviceProvider.buildShowDialog(context);
                              });
                            },
                            icon: Icon(
                              !isWishList
                                  ? Icons.favorite_border_sharp
                                  : Icons.favorite,
                              color: Colors.red,
                              size: 50,
                            ),
                          ),
                        )
                      ],
                    ),

                    // ====== HORIZONTAL VIEW OF SIMILAR PRODUCT SECTION ========
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                      child: Text(
                        'More similar product like this',
                        style: GoogleFonts.sora().copyWith(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                    ),

                    // ON THE SERVER, THE CATEGORY IS USED TO FILTER THE SAME CATEGORY
                    // PRODUCTS WHILE PRODUCT-ID IS USED TO CHECK THAT THE SAME PRODUT
                    // DOES NOT SHOW IN THE LIST OF CATEGORY PRODUCTS.
                    PtdHorizontalView(categoryData: categoryPtd),

                    // ============= ABOUT THIS ITEM. ===============
                    const Divider(
                      color: Colors.black54,
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Text(
                        'About this item',
                        style: GoogleFonts.sora().copyWith(
                          fontSize: 25,
                          fontWeight: FontWeight.w800,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: Text(
                        '${ptdDetailRecord['ptdDescription']}',
                        style: GoogleFonts.sora().copyWith(fontSize: 16),
                      ),
                    ),

                    // ============= CUSTOMER FEEDBACK SECTION ================
                    const SizedBox(
                      height: 8.0,
                    ),
                    const Divider(
                      endIndent: 5,
                      indent: 5,
                      color: Colors.black54,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Customer Feedback",
                        style: GoogleFonts.sora().copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 25,
                            color: Colors.grey),
                      ),
                    ),

                    // CS HEADER ROW THAT CAN RE-DIRECT USER TO VIEW FULL LIST OF CUSTOMER FEEDBACK
                    const Divider(
                      color: Colors.black45,
                      indent: 5,
                      endIndent: 5,
                    ),

                    Container(
                      padding: const EdgeInsets.all(0),
                      child: InkWell(
                          onTap: () {
                            if (ptdReviewData.isNotEmpty) {
                              Navigator.of(context).pushNamed(
                                RouteManager.allPtdReviws,
                                arguments: ({
                                  'ptdCommentData': ptdReviewData,
                                  'avgRating':
                                      '${ptdDetailRecord['averageStarRated']}',
                                  'totalReview':
                                      '${ptdDetailRecord['counter']}',
                                  'totalOneRate':
                                      '${ptdDetailRecord['percentage star rated']['one star percent']}',
                                  'totalTwoRate':
                                      '${ptdDetailRecord['percentage star rated']['two star percent']}',
                                  'totalThreeRate':
                                      '${ptdDetailRecord['percentage star rated']['three star percent']}',
                                  'totalFourRate':
                                      '${ptdDetailRecord['percentage star rated']['four star percent']}',
                                  'totalFiveRate':
                                      '${ptdDetailRecord['percentage star rated']['five star percent']}',
                                }),
                              );
                            } else {
                              serviceProvider.toastMessage(
                                  'No customer reviews for this product yet!');
                            }
                          },
                          child: ListTile(
                            title: Text(
                              'Product ratings and reviews',
                              style: GoogleFonts.sora().copyWith(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Row(
                              children: [
                                serviceProvider.displayHorizontalStar(double.parse(
                                    '${ptdDetailRecord['averageStarRated']}')),
                                const SizedBox(
                                  width: 1,
                                ),
                                Text(
                                  serviceProvider.formatNumberToOneDecimalPoint(
                                          double.parse(
                                              "${ptdDetailRecord['averageStarRated']}")) +
                                      ' /5',
                                  style: GoogleFonts.sora().copyWith(),
                                ),
                                const SizedBox(
                                  width: 3,
                                ),
                                Text(
                                  "(${ptdDetailRecord['counter']} ratings)",
                                  style: GoogleFonts.sora().copyWith(),
                                ),
                              ],
                            ),
                            trailing: Icon(
                              Icons.chevron_right_sharp,
                              color: Colors.blueAccent.shade700,
                              size: 35,
                            ),
                          )),
                    ),

                    const Divider(
                      color: Colors.black45,
                      indent: 5,
                      endIndent: 5,
                    ),

                    // ===== LIST OF LATEST FEW COMMENT MADE ABOUT THE PRODUCT ==
                    if (firstComment.isNotEmpty)
                      ListTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                firstComment[0]["customer"],
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: (GoogleFonts.sora().copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[600])),
                              ),
                            ),
                            Icon(
                              Icons.how_to_reg,
                              color: Colors.green[500],
                            ),
                            Text(
                              "Verified Purchase",
                              style: GoogleFonts.sora()
                                  .copyWith(fontSize: 12, color: Colors.green),
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            serviceProvider.displayHorizontalSmallStar(
                                firstComment[0]['rate']),
                            Text(firstComment[0]["subject"],
                                style: GoogleFonts.sora().copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Colors.black)),
                            Text(
                              firstComment[0]["createdAt"],
                              style: GoogleFonts.sora().copyWith(),
                            ),
                            Text(firstComment[0]["comment"],
                                style: GoogleFonts.sora()
                                    .copyWith(color: Colors.black)),
                            const Divider(
                              color: Colors.black45,
                            ),
                          ],
                        ),
                      ),

                    if (secondComment.isNotEmpty)
                      ListTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                secondComment[0]["customer"],
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: (GoogleFonts.sora().copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[600])),
                              ),
                            ),
                            Icon(
                              Icons.how_to_reg,
                              color: Colors.green[500],
                            ),
                            Text(
                              "Verified Purchase",
                              style: GoogleFonts.sora()
                                  .copyWith(fontSize: 12, color: Colors.green),
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            serviceProvider.displayHorizontalSmallStar(
                                secondComment[0]['rate']),
                            Text(secondComment[0]["subject"],
                                style: GoogleFonts.sora().copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Colors.black)),
                            Text(
                              secondComment[0]["createdAt"],
                              style: GoogleFonts.sora().copyWith(),
                            ),
                            Text(secondComment[0]["comment"],
                                style: GoogleFonts.sora()
                                    .copyWith(color: Colors.black)),
                            const Divider(
                              color: Colors.black45,
                            ),
                          ],
                        ),
                      ),

                    if (thirdComment.isNotEmpty)
                      ListTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                thirdComment[0]["customer"],
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: (GoogleFonts.sora().copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[600])),
                              ),
                            ),
                            Icon(
                              Icons.how_to_reg,
                              color: Colors.green[500],
                            ),
                            Text(
                              "Verified Purchase",
                              style: GoogleFonts.sora()
                                  .copyWith(fontSize: 12, color: Colors.green),
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            serviceProvider.displayHorizontalSmallStar(
                                thirdComment[0]['rate']),
                            Text(thirdComment[0]["subject"],
                                style: GoogleFonts.sora().copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Colors.black)),
                            Text(
                              thirdComment[0]["createdAt"],
                              style: GoogleFonts.sora().copyWith(),
                            ),
                            Text(thirdComment[0]["comment"],
                                style: GoogleFonts.sora()
                                    .copyWith(color: Colors.black)),
                            const Divider(
                              color: Colors.black45,
                            ),
                          ],
                        ),
                      ),

                    if (fouthComment.isNotEmpty)
                      ListTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                fouthComment[0]["customer"],
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: (GoogleFonts.sora().copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[600])),
                              ),
                            ),
                            Icon(
                              Icons.how_to_reg,
                              color: Colors.green[500],
                            ),
                            Text(
                              "Verified Purchase",
                              style: GoogleFonts.sora()
                                  .copyWith(fontSize: 12, color: Colors.green),
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            serviceProvider.displayHorizontalSmallStar(
                                fouthComment[0]['rate']),
                            Text(fouthComment[0]["subject"],
                                style: GoogleFonts.sora().copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Colors.black)),
                            Text(
                              fouthComment[0]["createdAt"],
                              style: GoogleFonts.sora().copyWith(),
                            ),
                            Text(fouthComment[0]["comment"],
                                style: GoogleFonts.sora()
                                    .copyWith(color: Colors.black)),
                            const Divider(
                              color: Colors.black45,
                            ),
                          ],
                        ),
                      ),

                    // ============= END OF THE FIRST FEW REVIEWS ============

                    if (firstFewComments.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(0),
                        height: 250,
                        child: Center(
                          child: Text(
                            'No review record yet',
                            style: GoogleFonts.sora().copyWith(
                              fontSize: 25,
                              color: Colors.grey.shade400,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),

                    // ===== A LINK THAT CAN ENABLE YOU SEE ALL REVIEWS ======
                    MaterialButton(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'See all product reviews',
                            style: GoogleFonts.sora().copyWith(
                              color: Colors.blueAccent,
                            ),
                          ),
                          const Icon(Icons.chevron_right)
                        ],
                      ),
                      onPressed: () {
                        if (ptdReviewData.isNotEmpty) {
                          Navigator.of(context).pushNamed(
                            RouteManager.allPtdReviws,
                            arguments: ({
                              'ptdCommentData': ptdReviewData,
                              'avgRating':
                                  '${ptdDetailRecord['averageStarRated']}',
                              'totalReview': '${ptdDetailRecord['counter']}',
                              'totalOneRate':
                                  '${ptdDetailRecord['percentage star rated']['one star percent']}',
                              'totalTwoRate':
                                  '${ptdDetailRecord['percentage star rated']['two star percent']}',
                              'totalThreeRate':
                                  '${ptdDetailRecord['percentage star rated']['three star percent']}',
                              'totalFourRate':
                                  '${ptdDetailRecord['percentage star rated']['four star percent']}',
                              'totalFiveRate':
                                  '${ptdDetailRecord['percentage star rated']['five star percent']}',
                            }),
                          );
                        } else {
                          serviceProvider.toastMessage(
                              'No customer reviews for this product yet!');
                        }
                      },
                    ),
                    const Divider(
                      color: Colors.black45,
                    )
                  ],
                ),
              )
            : const Center(
                child: CircularProgressIndicator(),
              ),
      ),
    );
  }

  Container titleSection() {
    return Container(
      margin: const EdgeInsets.all(0.0),
      child: const Text("Detail",
          style: TextStyle(
              color: Colors.black,
              fontSize: 25.0,
              fontWeight: FontWeight.bold)),
    );
  }
}

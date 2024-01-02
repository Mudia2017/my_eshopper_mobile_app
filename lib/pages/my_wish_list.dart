import 'package:badges/badges.dart';
import 'package:eshopper_mobile_app/componets/data_computation.dart';
import 'package:eshopper_mobile_app/componets/side_drawer.dart';
import 'package:eshopper_mobile_app/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class MyWishList extends StatefulWidget {
  final String token, customerId, custName, custEmail;
  MyWishList({
    required this.token,
    required this.customerId,
    required this.custName,
    required this.custEmail,
  });
  @override
  _MyWishListState createState() => _MyWishListState();
}

class _MyWishListState extends State<MyWishList> {
  @override
  void initState() {
    super.initState();
    initializingFunctionCall(widget.token, widget.customerId, '', '');
  }

  bool isCompleteLoading = false;
  bool isLoadingError = false;
  List myWishListItems = [];
  bool isCheck = false;
  List selectedList = [];
  Map selectedListRecord = {};
  String selectedValue = '----';
  var cartCounter = 0;

  void initializingFunctionCall(token, customerId, selectedList, action) async {
    var serviceProvider = Provider.of<DataProcessing>(context, listen: false);
    var response = await serviceProvider.getWishListItem(
        token, customerId, selectedList, action, '');

    setState(() {
      myWishListItems = response['myWishListItems'];
      isCompleteLoading = response['isCompleteLoading'];

      isLoadingError = response['isLoadingError'];
    });
  }

  @override
  Widget build(BuildContext context) {
    var serviceProvider = Provider.of<DataProcessing>(context);

    cartCounter = serviceProvider.counter;

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
          title: appBarTitle(),
          actions: [
            InkWell(
              onTap: () {
                // CART PAGE ROUTE FOR AUTHENTIC USER
                if (widget.custName != 'Guest') {
                  Navigator.of(context)
                      .pushNamed(RouteManager.authenticCartPage, arguments: {
                    'name': widget.custName,
                    'email': widget.custEmail,
                    'token': widget.token,
                    'custId': widget.customerId,
                  });
                }
              },
              child: Badge(
                child: IconButton(
                  onPressed: () {
                    // CART PAGE ROUTE FOR AUTHENTIC USER
                    if (widget.custName != 'Guest') {
                      Navigator.of(context).pushNamed(
                          RouteManager.authenticCartPage,
                          arguments: {
                            'name': widget.custName,
                            'email': widget.custEmail,
                            'token': widget.token,
                            'custId': widget.customerId,
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
            child: SideDrawer(caller: 'innerSideDrawer'),
          ),
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF40C4FF),
                Color(0xFFA7FFEB),
              ],
            ),
          ),
          child: isCompleteLoading
              ? RefreshIndicator(
                  onRefresh: () async {
                    initializingFunctionCall(
                        widget.token, widget.customerId, '', '');
                  },
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Click on the checkbox to perform an action or on the picture to see item detail',
                              style: GoogleFonts.philosopher().copyWith(
                                fontWeight: FontWeight.w100,
                                fontSize: 11,
                                fontStyle: FontStyle.italic,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ),
                          if (selectedList.isNotEmpty) dropDwonMenu(),
                        ],
                      ),
                      myWishListItems.isNotEmpty
                          ? Expanded(
                              child: GridView.count(
                                childAspectRatio: 0.62,
                                shrinkWrap: true,
                                crossAxisCount: 2,
                                scrollDirection: Axis.vertical,
                                children: List.generate(
                                  myWishListItems.length,
                                  (index) {
                                    return Container(
                                      child: Card(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Checkbox(
                                                  value: myWishListItems
                                                          .toList()[index]
                                                      ['isCheck'],
                                                  onChanged: (newValue) {
                                                    itemChange(
                                                      newValue!,
                                                      index,
                                                      myWishListItems
                                                          .toList()[index]
                                                              ['ptdId']
                                                          .toString(),
                                                    );
                                                  },
                                                ),
                                                if ('${myWishListItems[index]['out_of_stock']}' ==
                                                    'true')
                                                  Badge(
                                                    // position: badges
                                                    //         .BadgePosition
                                                    //     .topEnd(top: 0, end: 7),
                                                    // badgeAnimation: badges
                                                    //     .BadgeAnimation.fade(),
                                                    // badgeStyle:
                                                    //     badges.BadgeStyle(
                                                    //   badgeColor: Colors
                                                    //       .redAccent.shade700,
                                                    //   shape: badges
                                                    //       .BadgeShape.square,
                                                    //   elevation: 0,
                                                    //   borderRadius:
                                                    //       BorderRadius.circular(
                                                    //           7),
                                                    // ),
                                                    badgeColor: Colors
                                                        .redAccent.shade700,
                                                    animationType:
                                                        BadgeAnimationType.fade,
                                                    shape: BadgeShape.square,
                                                    elevation: 0,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            7),
                                                    badgeContent: const Center(
                                                      child: Text(
                                                        'Out of Stock',
                                                        style: TextStyle(
                                                            fontSize: 10,
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w800),
                                                      ),
                                                    ),
                                                  ),
                                                if (('${myWishListItems[index]['isActive']}' ==
                                                            'false' ||
                                                        '${myWishListItems[index]['isActiveStore']}' ==
                                                            'false') &&
                                                    '${myWishListItems[index]['out_of_stock']}' ==
                                                        'false')
                                                  Badge(
                                                    // badgeAnimation: badges
                                                    //     .BadgeAnimation.fade(),
                                                    // badgeStyle:
                                                    //     badges.BadgeStyle(
                                                    //   badgeColor: Colors
                                                    //       .redAccent.shade700,
                                                    //   shape: badges
                                                    //       .BadgeShape.square,
                                                    //   elevation: 0,
                                                    //   borderRadius:
                                                    //       BorderRadius.circular(
                                                    //           7),
                                                    // ),
                                                    badgeColor: Colors
                                                        .redAccent.shade700,
                                                    animationType:
                                                        BadgeAnimationType.fade,
                                                    shape: BadgeShape.square,
                                                    elevation: 0,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            7),
                                                    badgeContent: const Center(
                                                      child: Text(
                                                        'Unavailable',
                                                        style: TextStyle(
                                                            fontSize: 10,
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w800),
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            if (myWishListItems.toList()[index]
                                                    ['ptdImage'] !=
                                                "http://Oneluvtoall.pythonanywhere.com")
                                              InkWell(
                                                onTap: () {
                                                  Navigator.of(context)
                                                      .pushNamed(
                                                          RouteManager
                                                              .productDetail,
                                                          arguments: {
                                                        'ptdId':
                                                            "${myWishListItems[index]["ptdId"]}",
                                                        'category':
                                                            "${myWishListItems[index]["category"]}",
                                                      });
                                                },
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(0),
                                                  height: 120,
                                                  child: GridTile(
                                                    child: Image.network(
                                                      myWishListItems
                                                              .toList()[index]
                                                          ['ptdImage'],
                                                      fit: BoxFit.contain,
                                                      height: 120,
                                                    ),
                                                    header: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: [
                                                        if (double.parse(
                                                                myWishListItems
                                                                            .toList()[
                                                                        index][
                                                                    'discount']) >
                                                            0)
                                                          Text(
                                                            ' - '
                                                            '${myWishListItems.toList()[index]['discount']}'
                                                            ' % ',
                                                            style: TextStyle(
                                                              backgroundColor:
                                                                  Colors.orange
                                                                      .shade800,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            if (myWishListItems.toList()[index]
                                                    ['ptdImage'] ==
                                                "http://Oneluvtoall.pythonanywhere.com")
                                              InkWell(
                                                onTap: () {
                                                  Navigator.of(context)
                                                      .pushNamed(
                                                          RouteManager
                                                              .productDetail,
                                                          arguments: {
                                                        'ptdId':
                                                            "${myWishListItems[index]["ptdId"]}",
                                                        'category':
                                                            "${myWishListItems[index]["category"]}",
                                                      });
                                                },
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(0),
                                                  height: 120,
                                                  child: GridTile(
                                                    child: const Icon(
                                                      Icons
                                                          .photo_size_select_actual_sharp,
                                                      color: Colors.black26,
                                                      size: 120,
                                                    ),
                                                    header: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: [
                                                        if (double.parse(
                                                                myWishListItems
                                                                            .toList()[
                                                                        index][
                                                                    'discount']) >
                                                            0)
                                                          Text(
                                                            ' - '
                                                            '${myWishListItems.toList()[index]['discount']}'
                                                            ' % ',
                                                            style: TextStyle(
                                                              backgroundColor:
                                                                  Colors.orange
                                                                      .shade800,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 2),
                                              child: Text(
                                                myWishListItems.toList()[index]
                                                    ['ptdName'],
                                                style: GoogleFonts.sora()
                                                    .copyWith(
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        fontSize: 13,
                                                        color: Colors
                                                            .lightBlueAccent
                                                            .shade400),
                                                maxLines: 2,
                                              ),
                                            ),
                                            if (double.parse(myWishListItems
                                                        .toList()[index]
                                                    ['discount']) ==
                                                0)
                                              Expanded(
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 2.0),
                                                  child: Text(
                                                    '₦ ' +
                                                        serviceProvider.formattedNumber(
                                                            double.parse(
                                                                myWishListItems
                                                                            .toList()[
                                                                        index][
                                                                    'ptdPrice'])),
                                                    style: GoogleFonts.tinos()
                                                        .copyWith(
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors
                                                          .lightBlueAccent
                                                          .shade400,
                                                    ),
                                                    maxLines: 1,
                                                  ),
                                                ),
                                              ),
                                            if (double.parse(myWishListItems
                                                        .toList()[index]
                                                    ['discount']) >
                                                0)
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 2),
                                                child: Text(
                                                  '₦ ' +
                                                      serviceProvider
                                                          .formattedNumber(double
                                                              .parse(myWishListItems
                                                                          .toList()[
                                                                      index][
                                                                  'ptdPrice'])),
                                                  style: GoogleFonts.tinos()
                                                      .copyWith(
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.grey.shade500,
                                                    decoration: TextDecoration
                                                        .lineThrough,
                                                  ),
                                                  maxLines: 1,
                                                ),
                                              ),
                                            if (double.parse(myWishListItems
                                                        .toList()[index]
                                                    ['discount']) >
                                                0)
                                              Expanded(
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 2.0),
                                                  child: Text(
                                                    '₦ ' +
                                                        serviceProvider.formattedNumber(
                                                            double.parse(myWishListItems
                                                                        .toList()[
                                                                    index][
                                                                'ptdNewPrice'])),
                                                    style: GoogleFonts.tinos()
                                                        .copyWith(
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors
                                                          .lightBlueAccent
                                                          .shade400,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                    textAlign: TextAlign.end,
                                                  ),
                                                ),
                                              ),
                                            if (myWishListItems.toList()[index]
                                                    ['mfgData'] !=
                                                null)
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 2.0),
                                                child: Text(
                                                  'Mfg: ' +
                                                      myWishListItems
                                                              .toList()[index]
                                                          ['mfgData'],
                                                  style: GoogleFonts.sora()
                                                      .copyWith(fontSize: 9),
                                                ),
                                              ),
                                            if (myWishListItems.toList()[index]
                                                    ['expData'] !=
                                                null)
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 2.0),
                                                child: Text(
                                                  'Exp: ' +
                                                      myWishListItems
                                                              .toList()[index]
                                                          ['expData'],
                                                  style: GoogleFonts.sora()
                                                      .copyWith(fontSize: 9),
                                                ),
                                              ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                OutlinedButton(
                                                  onPressed: () {
                                                    _showModalBottomSheet(
                                                      context,
                                                      myWishListItems
                                                          .toList()[index]
                                                              ['ptdId']
                                                          .toString(),
                                                      myWishListItems
                                                          .toList()[index]
                                                              ['category']
                                                          .toString(),
                                                    );
                                                  },
                                                  child: const Text(
                                                    'Similar item',
                                                    style:
                                                        TextStyle(fontSize: 9),
                                                  ),
                                                ),
                                                OutlinedButton(
                                                  onPressed: () {
                                                    Navigator.of(context)
                                                        .pushNamed(
                                                            RouteManager
                                                                .allSellerItms,
                                                            arguments: {
                                                          'custId':
                                                              widget.customerId,
                                                          'token': widget.token,
                                                          'userName':
                                                              widget.custName,
                                                          'userEmail':
                                                              widget.custEmail,
                                                          'storeId':
                                                              myWishListItems
                                                                  .toList()[
                                                                      index][
                                                                      'storeId']
                                                                  .toString()
                                                        });
                                                  },
                                                  child: const Text(
                                                    'Seller other item',
                                                    style: TextStyle(
                                                      fontSize: 9,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            )
                          : Expanded(
                              child: Center(
                                child: Text(
                                  "No Record!",
                                  style: TextStyle(
                                      color: Colors.red[300],
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                    ],
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isCompleteLoading == false)
                      const CircularProgressIndicator(),
                    if (isLoadingError == true)
                      Text(
                        'Error occured!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.red.shade200,
                        ),
                      ),
                  ],
                ),
        ),
      ),
    );
  }

  void itemChange(bool val, int index, String ptdId) {
    // THIS IF, ELSE STATEMENT IS USED TO ADD OR REMOVE SELECTED
    // ITEM IN THE LIST. THE LIST IS USED TO KEEP TRACK OF ITEMS
    // THE USER HAVE SELECTED WHICH WILL BE USED TO PERFORM OPRATION
    // IN THE BACKEND.
    if (val == true) {
      selectedListRecord = {'ptdId': ptdId, 'customerId': widget.customerId};
      selectedList.add(selectedListRecord);
    } else if (val == false) {
      selectedList.removeWhere((item) => item['ptdId'] == ptdId);
    }
    setState(() {
      myWishListItems.toList()[index]['isCheck'] = val;
    });
  }

  Container appBarTitle() {
    return Container(
      margin: const EdgeInsets.all(0.0),
      child: const Text(
        "My WishList",
        style: TextStyle(
          color: Colors.black,
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  List<DropdownMenuItem<String>> get dropdownItems {
    List<DropdownMenuItem<String>> menuItems = [
      const DropdownMenuItem(
        child: Text(
          'Select Action',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent,
          ),
        ),
        value: '----',
      ),
      const DropdownMenuItem(
        child: Text(
          'Add to cart',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent,
          ),
        ),
        value: 'addToCart',
      ),
      const DropdownMenuItem(
        child: Text(
          'Delete wish list',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent,
          ),
        ),
        value: 'deleteWishList',
      ),
    ];
    return menuItems;
  }

  Container dropDwonMenu() {
    var serviceProvider = Provider.of<DataProcessing>(context);
    return Container(
      child: DropdownButton(
        value: selectedValue,
        onChanged: (String? newValue) async {
          setState(() {
            selectedValue = newValue!;
          });
          if (selectedValue == 'deleteWishList') {
            var response = await serviceProvider.confirmationPopDialogMsg(
              context,
              'Confirm Action',
              'You are about to delete an item from your wish list.\nDo you want to continue?',
              widget.customerId,
              selectedList,
              'deleteWishList',
              widget.token,
              '',
              '',
              '',
              '',
              '',
              'my_wish_list',
            );

            if (response == 'cancel') {
              setState(() {
                selectedValue = '----';
              });
            } else if (response != '' && response != null) {
              setState(() {
                myWishListItems = response['myWishListItems'];
                isCompleteLoading = response['isCompleteLoading'];
                isLoadingError = response['isLoadingError'];
                selectedValue = '----';
                selectedList = [];
              });
            }
          } else if (selectedValue == 'addToCart') {
            // THIS CALL IS TO ADD SELECTED WISHLIST TO CART.
            //  THE BACKEND IS GOING TO CHECK FOR THE FOLLOWING
            //  (1) IF THE ITEM IS ACTIVE
            // (2) IF THE STORE ITEM IS ACTIVE
            // (3) IF THE ITEM IS IN-STOCK BEFORE ADDING...

            // CALL THE DIALOG TO PREVENT USER FROM THE UI UNTIL DATA IS SAVED TO THE SERVER
            setState(() {
              serviceProvider.isLoadDialogBox = true;
              serviceProvider.buildShowDialog(context);
            });

            var response = await serviceProvider.getWishListItem(
              widget.token,
              widget.customerId,
              selectedList,
              'addToCart',
              widget.custName,
            );

            // CALL THE DIALOG TO ALLOW USER PERFORM OPERATION ON THE UI

            serviceProvider.isLoadDialogBox = false;
            serviceProvider.buildShowDialog(context);

            if (response != '' && response != null) {
              setState(() {
                myWishListItems = response['myWishListItems'];
                isCompleteLoading = response['isCompleteLoading'];
                isLoadingError = response['isLoadingError'];
                selectedValue = '----';
                selectedList = [];
              });
              if (response['inactive_outOfStock'] == true) {
                serviceProvider.popWarningErrorMsg(context, 'System Message',
                    'Some of the selected items in your wish list are either out-of-stock or inactive.\nThis item was not added to your cart.');
              } else {
                serviceProvider.toastMessage('Item was added to your cart');
              }
            }
          }
        },
        items: dropdownItems,
      ),
    );
  }

  _showModalBottomSheet(context, ptdId, category) async {
    var serviceProvider = Provider.of<DataProcessing>(context, listen: false);
    List sameCategoryPtdData = [];
    sameCategoryPtdData = await serviceProvider.getPtdSameCategory(
        widget.token, ptdId, category, 'catPtdFrmModalBottomSheet');
    return showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (builder) {
          return StatefulBuilder(builder: (context, setstate) {
            return Container(
              height: 700,
              color: const Color(0xFF737373),
              child: Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).canvasColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25),
                    )),
                // height: 500,
                child: Column(
                  children: [
                    Center(
                      child: Text(
                        'Similar items',
                        style: GoogleFonts.sora().copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    Expanded(
                      child: sameCategoryPtdData.isNotEmpty
                          ? GridView.builder(
                              shrinkWrap: true,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                childAspectRatio: 0.54,
                                crossAxisCount: 2,
                              ),
                              itemCount: sameCategoryPtdData.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 6.0),
                                  child: Card(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          height: 200,
                                          child: GridTile(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                if (sameCategoryPtdData
                                                                .toList()[index]
                                                            ['imageURL'] !=
                                                        "http://Oneluvtoall.pythonanywhere.com" &&
                                                    sameCategoryPtdData
                                                                .toList()[index]
                                                            ['imageURL'] !=
                                                        '')
                                                  Expanded(
                                                    child: Image.network(
                                                      sameCategoryPtdData
                                                              .toList()[index]
                                                          ['imageURL'],
                                                      fit: BoxFit.contain,
                                                    ),
                                                  ),
                                                if (sameCategoryPtdData
                                                            .toList()[index]
                                                        ['imageURL'] ==
                                                    "")
                                                  const Icon(
                                                    Icons
                                                        .photo_size_select_actual_sharp,
                                                    color: Colors.black26,
                                                    size: 100,
                                                  ),
                                              ],
                                            ),
                                            footer: Row(
                                              children: [
                                                if (sameCategoryPtdData
                                                            .toList()[index]
                                                        ['out_of_stock'] ==
                                                    true)
                                                  Expanded(
                                                    child: Text(
                                                      ' Out of Stock ',
                                                      style: GoogleFonts.sora()
                                                          .copyWith(
                                                        fontWeight:
                                                            FontWeight.w900,
                                                        backgroundColor: Colors
                                                            .redAccent.shade700,
                                                        color: Colors.white,
                                                        fontSize: 11,
                                                      ),
                                                    ),
                                                  )
                                              ],
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 5.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  sameCategoryPtdData
                                                      .toList()[index]['name'],
                                                  style: GoogleFonts.sora()
                                                      .copyWith(
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          fontSize: 13,
                                                          color:
                                                              Colors.black54),
                                                  maxLines: 2,
                                                ),
                                                if (sameCategoryPtdData
                                                            .toList()[index]
                                                        ['discount'] !=
                                                    '0.00')
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        '₦ ' +
                                                            serviceProvider.formattedNumber(double.parse(
                                                                sameCategoryPtdData
                                                                            .toList()[
                                                                        index]
                                                                    ['price'])),
                                                        style: GoogleFonts
                                                                .publicSans()
                                                            .copyWith(
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          fontSize: 12,
                                                          decoration:
                                                              TextDecoration
                                                                  .lineThrough,
                                                          color: Colors.grey,
                                                        ),
                                                        maxLines: 2,
                                                      ),
                                                      Container(
                                                        decoration:
                                                            const BoxDecoration(
                                                          color: Colors.teal,
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          5)),
                                                        ),
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                horizontal:
                                                                    5.0),
                                                        child: Text(
                                                          serviceProvider.formattedNumber(double.parse(
                                                                  sameCategoryPtdData
                                                                              .toList()[
                                                                          index]
                                                                      [
                                                                      'discount'])) +
                                                              ' % off',
                                                          style: GoogleFonts
                                                                  .publicSans()
                                                              .copyWith(
                                                            color: Colors.white,
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                if (sameCategoryPtdData
                                                            .toList()[index]
                                                        ['discount'] ==
                                                    '0.00')
                                                  Text(
                                                    '₦ ' +
                                                        serviceProvider.formattedNumber(
                                                            double.parse(
                                                                sameCategoryPtdData
                                                                            .toList()[
                                                                        index]
                                                                    ['price'])),
                                                    style: GoogleFonts
                                                            .publicSans()
                                                        .copyWith(
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            fontSize: 20,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                    maxLines: 2,
                                                  ),
                                                if (sameCategoryPtdData
                                                            .toList()[index]
                                                        ['discount'] !=
                                                    '0.00')
                                                  Text(
                                                    '₦ ' +
                                                        serviceProvider.formattedNumber(
                                                            double.parse(
                                                                sameCategoryPtdData
                                                                            .toList()[
                                                                        index][
                                                                    'new_price'])),
                                                    style: GoogleFonts
                                                            .publicSans()
                                                        .copyWith(
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            fontSize: 20,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                    maxLines: 2,
                                                  ),
                                                if (sameCategoryPtdData
                                                            .toList()[index]
                                                        ['mfgDate'] !=
                                                    null)
                                                  Text(
                                                    'Mfd Date: ' +
                                                        sameCategoryPtdData
                                                            .toList()[index]
                                                                ['mfgDate']
                                                            .toString(),
                                                    style:
                                                        GoogleFonts.publicSans()
                                                            .copyWith(
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      fontSize: 10,
                                                      color: Colors.grey,
                                                    ),
                                                    maxLines: 1,
                                                  ),
                                                if (sameCategoryPtdData
                                                            .toList()[index]
                                                        ['expDate'] !=
                                                    null)
                                                  Text(
                                                    'Exp Date: ' +
                                                        sameCategoryPtdData
                                                            .toList()[index]
                                                                ['expDate']
                                                            .toString(),
                                                    style:
                                                        GoogleFonts.publicSans()
                                                            .copyWith(
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      fontSize: 10,
                                                      color: Colors.grey,
                                                    ),
                                                    maxLines: 1,
                                                  ),

                                                // HORIZONTAL DISPLAY OF STAR RATING AND COMMNET COUNT
                                                Expanded(
                                                  child: Row(
                                                    children: [
                                                      serviceProvider
                                                          .displayHorizontalSmallStar(
                                                        double.parse(
                                                            sameCategoryPtdData
                                                                .toList()[index]
                                                                    [
                                                                    'averageStarRated']
                                                                .toString()),
                                                      ),
                                                      const SizedBox(
                                                        width: 10,
                                                      ),
                                                      Text(
                                                        serviceProvider
                                                            .formattedNumber(
                                                          double.parse(
                                                            sameCategoryPtdData
                                                                .toList()[index]
                                                                    ['counter']
                                                                .toString(),
                                                          ),
                                                        ),
                                                        style: GoogleFonts
                                                                .publicSans()
                                                            .copyWith(
                                                                color: Colors
                                                                    .grey
                                                                    .shade700,
                                                                fontSize: 15),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
                                                  children: [
                                                    ElevatedButton(
                                                      onPressed: () async {
                                                        // ADD WISH-LIST TO CART BUTTON FOR AUTHENTICATED USER.
                                                        // WE ARE NO LONGER CHECKING IF IT'S AN AUTHENTIC USER
                                                        // WE NEED TO CHECK IF THE ITEM IS IN-STOCK BEFORE ADDING

                                                        if (sameCategoryPtdData
                                                                        .toList()[
                                                                    index][
                                                                'out_of_stock'] ==
                                                            false) {
                                                          // CALL THE DIALOG TO PREVENT USER FROM THE UI UNTIL DATA IS SAVED TO THE SERVER

                                                          serviceProvider
                                                                  .isLoadDialogBox =
                                                              true;
                                                          serviceProvider
                                                              .buildShowDialog(
                                                                  context);

                                                          var response =
                                                              await serviceProvider
                                                                  .apiCartDataUpdate(
                                                            widget.custName,
                                                            widget.token,
                                                            sameCategoryPtdData
                                                                    .toList()[
                                                                index]['id'],
                                                            'add',
                                                          );

                                                          // CALL THE DIALOG TO ALLOW USER PERFORM OPERATION ON THE UI

                                                          serviceProvider
                                                                  .isLoadDialogBox =
                                                              false;
                                                          serviceProvider
                                                              .buildShowDialog(
                                                                  context);

                                                          if (response[
                                                                  'cart total count'] >
                                                              0) {
                                                            serviceProvider
                                                                .toastMessage(
                                                                    'Item was added to cart.');
                                                          }
                                                        } else {
                                                          serviceProvider
                                                              .warningToastMassage(
                                                                  'Out of Stock!');
                                                        }
                                                      },
                                                      child: const Text(
                                                          'Add to cart'),
                                                      style: ButtonStyle(
                                                          backgroundColor:
                                                              MaterialStateProperty
                                                                  .all<Color>(Colors
                                                                      .lightBlue)),
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .popAndPushNamed(
                                                                RouteManager
                                                                    .productDetail,
                                                                arguments: {
                                                              'ptdId':
                                                                  sameCategoryPtdData
                                                                      .toList()[
                                                                          index]
                                                                          ['id']
                                                                      .toString(),
                                                              'category':
                                                                  category,
                                                              'cartCounter':
                                                                  cartCounter,
                                                            });
                                                      },
                                                      child: const Text('View'),
                                                      style: ButtonStyle(
                                                          backgroundColor:
                                                              MaterialStateProperty
                                                                  .all<Color>(
                                                                      Colors
                                                                          .grey)),
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              })
                          : Center(
                              child: Text(
                                'No Record!',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.red.shade200,
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            );
          });
        });
  }
}

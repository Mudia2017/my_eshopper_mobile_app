import 'package:badges/badges.dart';
import 'package:eshopper_mobile_app/componets/data_computation.dart';
import 'package:eshopper_mobile_app/pages/authentic_cust_cart_page.dart';
import 'package:eshopper_mobile_app/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:number_display/number_display.dart';
import 'package:provider/provider.dart';

class CartPageMainLayOut extends StatefulWidget {
  final String id;
  final String productId;
  final double price;
  final int quantity;
  final String name;
  final String image;
  double lineTotal;

  final String userName;
  final String userToken;
  final String out_of_stock;
  final String active;
  final String activeStore;

  CartPageMainLayOut(
    this.id,
    this.productId,
    this.price,
    this.quantity,
    this.name,
    this.image,
    this.lineTotal,
    this.userName,
    this.userToken,
    this.out_of_stock,
    this.active,
    this.activeStore,
  );

  @override
  State<CartPageMainLayOut> createState() => _CartPageMainLayOutState();
}

class _CartPageMainLayOutState extends State<CartPageMainLayOut> {
  final _formattedNumber = createDisplay(
    length: 12,
    separator: ',',
    decimal: 2,
    decimalPoint: '.',
  );

  @override
  Widget build(BuildContext context) {
    var serviceProvider = Provider.of<DataProcessing>(context);

    return Dismissible(
      key: ValueKey(widget.productId),
      direction: DismissDirection.endToStart,
      background: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        alignment: Alignment.centerRight,
        child: const Text(
          'REMOVE',
          style: TextStyle(
              fontSize: 20, color: Colors.white, fontWeight: FontWeight.w800),
        ),
        color: Colors.red,
      ),
      onDismissed: (direction) {
        serviceProvider.apiCartDataUpdate(
            widget.userName, widget.userToken, widget.productId, 'delete');
      },
      child: Card(
        child: Column(
          children: [
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(0),
                width: 60,
                child: Column(
                  children: [
                    if (widget.image != "http://192.168.43.50:8000")
                      Flexible(
                          child: Image.network(
                        widget.image,
                        fit: BoxFit.contain,
                      )),
                    if (widget.image == "http://192.168.43.50:8000")
                      const Icon(
                        Icons.photo_size_select_actual_sharp,
                        color: Colors.black26,
                        size: 40,
                      ),
                  ],
                ),
              ),
              title: Text(
                widget.name,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
              ),
              subtitle: Row(
                children: [
                  Text(
                    '₦ ' + _formattedNumber(double.parse('${widget.price}')),
                    style: GoogleFonts.publicSans()
                        .copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(
                    width: 15.0,
                  ),
                  Text(
                    '₦ ' +
                        _formattedNumber(double.parse('${widget.lineTotal}')),
                    style: GoogleFonts.publicSans()
                        .copyWith(fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              trailing: Text(
                '${widget.quantity} X',
                style: GoogleFonts.publicSans().copyWith(),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // DISPLAY A BADGE ON PRODUCT THAT ARE OUT OF STOCK
                if (widget.out_of_stock == 'true')
                  Badge(
                    // badgeAnimation: badges.BadgeAnimation.slide(),
                    // badgeStyle: badges.BadgeStyle(
                    //   badgeColor: Colors.redAccent.shade700,
                    //   shape: badges.BadgeShape.square,
                    //   elevation: 3.0,
                    //   borderRadius: BorderRadius.circular(10),
                    // ),
                    badgeColor: Colors.redAccent.shade700,
                    animationType: BadgeAnimationType.fade,
                    shape: BadgeShape.square,
                    elevation: 3.0,
                    borderRadius: BorderRadius.circular(10),
                    badgeContent: const Center(
                      child: Text(
                        'Out of stock',
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                // DISPLAY A BADGE ON ITEMS THAT ARE INACTIVE OR ITEMS WITH INACTIVE STORE
                if (widget.active == 'false' || widget.activeStore == 'false')
                  Badge(
                    // badgeAnimation: badges.BadgeAnimation.slide(),
                    // badgeStyle: badges.BadgeStyle(
                    //   badgeColor: Colors.redAccent.shade700,
                    //   shape: badges.BadgeShape.square,
                    //   elevation: 3.0,
                    //   borderRadius: BorderRadius.circular(10),
                    // ),
                    badgeColor: Colors.deepOrange,
                    animationType: BadgeAnimationType.fade,
                    shape: BadgeShape.square,
                    elevation: 3.0,
                    borderRadius: BorderRadius.circular(10),
                    badgeContent: const Center(
                      child: Text(
                        'Inactive item',
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // REMOVE ITEM FROM CART ICON-BUTTON FOR AUTHENTICATED USER
                IconButton(
                  onPressed: () async {
                    // CALL THE DIALOG TO PREVENT USER FROM THE UI UNTIL DATA IS SAVED TO THE SERVER
                    setState(() {
                      serviceProvider.isLoadDialogBox = true;
                      serviceProvider.buildShowDialog(context);
                    });

                    if (widget.userName != 'Guest' && widget.userToken != '') {
                      await serviceProvider.apiCartDataUpdate(
                        widget.userName,
                        widget.userToken,
                        widget.productId,
                        'remove',
                      );
                    }

                    // CALL THE DIALOG TO ALLOW USER PERFORM OPERATION ON THE UI
                    setState(() {
                      serviceProvider.isLoadDialogBox = false;
                      serviceProvider.buildShowDialog(context);
                    });
                  },
                  icon: Icon(
                    Icons.remove_shopping_cart_outlined,
                    color: Colors.redAccent.shade700,
                  ),
                ),

                // ADD ITEM TO CART ICON-BUTTON FOR AUTHENTICATED USER
                IconButton(
                  onPressed: () async {
                    // CALL THE DIALOG TO PREVENT USER FROM THE UI UNTIL DATA IS SAVED TO THE SERVER
                    setState(() {
                      serviceProvider.isLoadDialogBox = true;
                      serviceProvider.buildShowDialog(context);
                    });

                    if (widget.userName != 'Guest' && widget.userToken != '') {
                      // CHECKING IF AN EXISTING ITEM IN CART IS NOW OUT OF STOCK
                      // AND CUSTOMER IS STILL TRING TO INCREASE THE QUANTITY
                      if (widget.out_of_stock == 'false' &&
                          widget.active == 'true' &&
                          widget.activeStore == 'true') {
                        await serviceProvider.apiCartDataUpdate(
                          widget.userName,
                          widget.userToken,
                          widget.productId,
                          'add',
                        );
                      } else if (widget.out_of_stock == 'true') {
                        serviceProvider.warningToastMassage(
                            'Out of stock item. Kindly remove from cart!');
                      } else if (widget.active == 'false' ||
                          widget.activeStore == 'false') {
                        serviceProvider.warningToastMassage(
                            'Inactive item. Kindly remove from cart!');
                      }
                    }

                    // CALL THE DIALOG TO ALLOW USER PERFORM OPERATION ON THE UI

                    setState(() {
                      serviceProvider.isLoadDialogBox = false;
                      serviceProvider.buildShowDialog(context);
                    });
                  },
                  icon: Icon(
                    Icons.add_shopping_cart_sharp,
                    color: Colors.blueAccent.shade700,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

// HORIZONTAL LIST VIEW OF WISH LIST

class WishListProduct extends StatelessWidget {
  final int ptdId;
  final String productName;
  final String productImage;
  final String productNewPrice;
  final String productPrice;
  final String discount;
  final String category;
  final int cartCounter;
  final String averageStarRate;
  final int commentCount;
  final bool outOfStock;
  final bool isPtdActive;
  final String custId;
  final String token;
  final String custName;
  final bool isActiveStore;

  WishListProduct({
    required this.ptdId,
    required this.productName,
    required this.productImage,
    required this.productNewPrice,
    required this.productPrice,
    required this.discount,
    required this.category,
    required this.cartCounter,
    required this.averageStarRate,
    required this.commentCount,
    required this.outOfStock,
    required this.isPtdActive,
    required this.custId,
    required this.token,
    required this.custName,
    required this.isActiveStore,
  });
  @override
  Widget build(BuildContext context) {
    var serviceProvider = Provider.of<DataProcessing>(context);
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.of(context)
              .pushNamed(RouteManager.productDetail, arguments: {
            'ptdId': ptdId.toString(),
            'category': category,
            'cartCounter': cartCounter,
          });
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 150,
              child: GridTile(
                header: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (discount != "0.00")
                      Text(
                        ' $discount % off ',
                        style: GoogleFonts.publicSans().copyWith(
                          fontWeight: FontWeight.w900,
                          backgroundColor: Colors.redAccent.shade700,
                          color: Colors.white,
                        ),
                      ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (productImage != "http://192.168.43.50:8000")
                      Expanded(
                        child: Image.network(
                          productImage,
                          fit: BoxFit.contain,
                        ),
                      ),
                    if (productImage == "http://192.168.43.50:8000")
                      const Icon(
                        Icons.photo_size_select_actual_sharp,
                        color: Colors.black26,
                        size: 100,
                      ),
                  ],
                ),
                footer: Row(
                  children: [
                    if (isPtdActive == false ||
                        outOfStock == true ||
                        isActiveStore == false)
                      Expanded(
                        child: Text(
                          ' Currently unavailable ',
                          style: GoogleFonts.sora().copyWith(
                            fontWeight: FontWeight.w900,
                            backgroundColor: Colors.redAccent.shade700,
                            color: Colors.white,
                            fontSize: 11,
                          ),
                        ),
                      )
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Text(
                productName,
                style: GoogleFonts.sora().copyWith(
                    overflow: TextOverflow.ellipsis,
                    fontSize: 13,
                    color: Colors.black54),
                maxLines: 2,
              ),
            ),
            if (discount != '0.00')
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Text(
                  '₦ ' +
                      serviceProvider
                          .formattedNumber(double.parse(productPrice)),
                  style: GoogleFonts.publicSans().copyWith(
                    overflow: TextOverflow.ellipsis,
                    fontSize: 12,
                    decoration: TextDecoration.lineThrough,
                    color: Colors.grey,
                  ),
                  maxLines: 2,
                ),
              ),
            if (discount == '0.00')
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Text(
                    '₦ ' +
                        serviceProvider
                            .formattedNumber(double.parse(productPrice)),
                    style: GoogleFonts.publicSans().copyWith(
                        overflow: TextOverflow.ellipsis,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                    maxLines: 2,
                  ),
                ),
              ),
            if (discount != '0.00')
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Text(
                    '₦ ' +
                        serviceProvider
                            .formattedNumber(double.parse(productNewPrice)),
                    style: GoogleFonts.publicSans().copyWith(
                        overflow: TextOverflow.ellipsis,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                    maxLines: 2,
                  ),
                ),
              ),
            // HORIZONTAL DISPLAY OF STAR RATING AND COMMNET COUNT
            Expanded(
              child: Row(
                children: [
                  serviceProvider.displayHorizontalSmallStar(
                    double.parse(averageStarRate),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    serviceProvider.formattedNumber(
                      double.parse(
                        commentCount.toString(),
                      ),
                    ),
                    style: GoogleFonts.publicSans()
                        .copyWith(color: Colors.grey.shade700, fontSize: 15),
                  ),
                ],
              ),
            ),
            if (isPtdActive == true &&
                outOfStock == false &&
                isActiveStore == true)
              Center(
                child: MaterialButton(
                  onPressed: () async {
                    // ADD WISH-LIST TO CART BUTTON FOR AUTHENTICATED USER.
                    // WE ARE NO LONGER CHECKING IF IT'S AN AUTHENTIC USER,
                    // IF ITEM IS ACTIVE & IN-STOCK SINCE SINCE THOSE CONDITIONS
                    // HAVE BEEN MEANT BEFORE THIS BUTTON WAS DISPLAYED...

                    // CALL THE DIALOG TO PREVENT USER FROM THE UI UNTIL DATA IS SAVED TO THE SERVER

                    serviceProvider.isLoadDialogBox = true;
                    serviceProvider.buildShowDialog(context);

                    await serviceProvider.apiCartDataUpdate(
                      custName,
                      token,
                      ptdId,
                      'add',
                    );

                    // CALL THE DIALOG TO ALLOW USER PERFORM OPERATION ON THE UI

                    serviceProvider.isLoadDialogBox = false;
                    serviceProvider.buildShowDialog(context);
                  },
                  child: const Text(
                    'Add to Cart',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  color: Colors.blue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                ),
              ),
            if (isPtdActive == false ||
                outOfStock == true ||
                isActiveStore == false)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton(
                    onPressed: () async {
                      var response =
                          await serviceProvider.confirmationPopDialogMsg(
                        context,
                        'Confirm Action',
                        'You are about to delete an item from your wish list.\nDo you want to continue?',
                        custId,
                        ptdId,
                        'deleteWishListFrmBtn',
                        token,
                        '',
                        '',
                        '',
                        '',
                        '',
                        'my_wish_list',
                      );

                      print(response);
                    },
                    child: const Text(
                      'Delete',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      _showModalBottomSheet(context, ptdId, category);
                    },
                    child: const Text(
                      'Similar item',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  _showModalBottomSheet(context, ptdId, category) async {
    var serviceProvider = Provider.of<DataProcessing>(context, listen: false);
    List sameCategoryPtdData = [];
    sameCategoryPtdData = await serviceProvider.getPtdSameCategory(
        token, ptdId, category, 'catPtdFrmModalBottomSheet');
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
                                                        "http://192.168.43.50:8000" &&
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
                                                            custName,
                                                            token,
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

// HORIZONTAL LIST VIEW OF RECENTLY VIEW ITEM
class RecentViewedProduct extends StatelessWidget {
  final int ptdId;
  final String productName;
  final String productImage;
  final String productPrice;
  final String discount;
  final String productNewPrice;
  final String category;
  final String custId;
  final String token;
  final String custName;

  RecentViewedProduct({
    required this.ptdId,
    required this.productName,
    required this.productImage,
    required this.productPrice,
    required this.discount,
    required this.productNewPrice,
    required this.category,
    required this.custId,
    required this.token,
    required this.custName,
  });
  @override
  Widget build(BuildContext context) {
    var serviceProvider = Provider.of<DataProcessing>(context);
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.of(context)
              .pushNamed(RouteManager.productDetail, arguments: {
            'ptdId': ptdId.toString(),
            'category': category,
            'cartCounter': '',
          });
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(0),
              height: 150,
              child: GridTile(
                header: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (discount != "0.00")
                      Text(
                        ' $discount % off ',
                        style: GoogleFonts.publicSans().copyWith(
                          fontWeight: FontWeight.w900,
                          backgroundColor: Colors.redAccent.shade700,
                          color: Colors.white,
                        ),
                      ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (productImage != "http://192.168.43.50:8000" &&
                        productImage != '')
                      Expanded(
                        child: Image.network(
                          "http://192.168.43.50:8000" + productImage,
                          fit: BoxFit.contain,
                        ),
                      ),
                    if (productImage == "")
                      const Icon(
                        Icons.photo_size_select_actual_sharp,
                        color: Colors.black26,
                        size: 100,
                      ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Text(
                productName,
                style: GoogleFonts.sora().copyWith(
                    overflow: TextOverflow.ellipsis,
                    fontSize: 13,
                    color: Colors.black54),
                maxLines: 2,
              ),
            ),
            if (discount != '0.00')
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Text(
                  '₦ ' +
                      serviceProvider
                          .formattedNumber(double.parse(productPrice)),
                  style: GoogleFonts.publicSans().copyWith(
                    overflow: TextOverflow.ellipsis,
                    fontSize: 12,
                    decoration: TextDecoration.lineThrough,
                    color: Colors.grey,
                  ),
                  maxLines: 2,
                ),
              ),
            if (discount == '0.00')
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Text(
                    '₦ ' +
                        serviceProvider
                            .formattedNumber(double.parse(productPrice)),
                    style: GoogleFonts.publicSans().copyWith(
                        overflow: TextOverflow.ellipsis,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                    maxLines: 2,
                  ),
                ),
              ),
            if (discount != '0.00')
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Text(
                    '₦ ' +
                        serviceProvider
                            .formattedNumber(double.parse(productNewPrice)),
                    style: GoogleFonts.publicSans().copyWith(
                        overflow: TextOverflow.ellipsis,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                    maxLines: 2,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

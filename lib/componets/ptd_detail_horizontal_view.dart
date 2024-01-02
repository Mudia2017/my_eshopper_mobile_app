import 'dart:convert';
import 'dart:ui';

import 'package:eshopper_mobile_app/componets/data_computation.dart';
import 'package:eshopper_mobile_app/routes/routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class PtdHorizontalView extends StatefulWidget {
  final List categoryData;

  PtdHorizontalView({required this.categoryData});
  @override
  _PtdHorizontalViewState createState() => _PtdHorizontalViewState();
}

class _PtdHorizontalViewState extends State<PtdHorizontalView> {
  var sameCategoryProducts = [];

  @override
  void initState() {
    super.initState();
    setState(() {
      sameCategoryProducts = widget.categoryData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // alignment: Alignment.topLeft,
      height: 300,
      width: 300,
      child: GridView.count(
        childAspectRatio: 1.75,
        crossAxisCount: 1,
        scrollDirection: Axis.horizontal,
        children: List.generate(sameCategoryProducts.length, (index) {
          return CategorySingleProduct(
            ptdId: sameCategoryProducts.toList()[index]['id'],
            productName: sameCategoryProducts.toList()[index]['name'],
            productImage: sameCategoryProducts.toList()[index]['imageURL'],
            productNewPrice: sameCategoryProducts.toList()[index]['new_price'],
            productPrice: sameCategoryProducts.toList()[index]['price'],
            discount: sameCategoryProducts.toList()[index]['discount'],
            averageStarRated: double.parse(
                '${sameCategoryProducts.toList()[index]['averageStarRated']}'),
            numbOfComments: sameCategoryProducts.toList()[index]['counter'],
            category: sameCategoryProducts.toList()[index]['category'],
            outOfStock: sameCategoryProducts.toList()[index]['out_of_stock'],
          );
        }),
      ),
    );
  }
}

class CategorySingleProduct extends StatelessWidget {
  final int ptdId;
  final String productName;
  final String productImage;
  final String productNewPrice;
  final String productPrice;
  final String discount;
  final double averageStarRated;
  final int numbOfComments;
  final String category;
  final bool outOfStock;

  CategorySingleProduct({
    required this.ptdId,
    required this.productName,
    required this.productImage,
    required this.productNewPrice,
    required this.productPrice,
    required this.discount,
    required this.averageStarRated,
    required this.numbOfComments,
    required this.category,
    required this.outOfStock,
  });
  @override
  Widget build(BuildContext context) {
    var serviceProvider = Provider.of<DataProcessing>(context);
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.of(context)
              .pushReplacementNamed(RouteManager.productDetail, arguments: {
            'ptdId': ptdId.toString(),
            'category': category,
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
                    if (productImage != "http://Oneluvtoall.pythonanywhere.com")
                      Flexible(
                        child: Image.network(
                          productImage,
                          fit: BoxFit.scaleDown,
                        ),
                      ),
                    if (productImage == "http://Oneluvtoall.pythonanywhere.com")
                      const Icon(
                        Icons.photo_size_select_actual_sharp,
                        color: Colors.black26,
                        size: 100,
                      ),
                  ],
                ),
                footer: Row(
                  children: [
                    if (outOfStock == true)
                      Text(
                        ' Out of stock ',
                        style: GoogleFonts.sora().copyWith(
                          fontWeight: FontWeight.w900,
                          backgroundColor: Colors.redAccent.shade700,
                          color: Colors.white,
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
                    color: Colors.lightBlueAccent.shade400),
                maxLines: 3,
              ),
            ),
            Row(
              children: [
                serviceProvider.displayHorizontalSmallStar(averageStarRated),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Text(
                    serviceProvider.formattedNumber(numbOfComments),
                    style: GoogleFonts.sora().copyWith(
                        overflow: TextOverflow.ellipsis, fontSize: 15),
                    maxLines: 2,
                  ),
                ),
              ],
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
              Container(
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
            if (discount != '0.00')
              Container(
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
          ],
        ),
      ),
    );
  }
}

// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_listtile_demo/model/listtilemodel.dart';

class CheckBoxListTileDemo extends StatefulWidget {
  @override
  CheckBoxListTileDemoState createState() => new CheckBoxListTileDemoState();
}

class CheckBoxListTileDemoState extends State<CheckBoxListTileDemo> {
  List<CheckBoxListTileModel> checkBoxListTileModel =
      CheckBoxListTileModel.getUsers();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'CheckBox ListTile Demo',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: ListView.builder(
          itemCount: checkBoxListTileModel.length,
          itemBuilder: (BuildContext context, int index) {
            return Card(
              child: Container(
                padding: EdgeInsets.all(10.0),
                child: Column(
                  children: <Widget>[
                    CheckboxListTile(
                        activeColor: Colors.pink[300],
                        dense: true,
                        //font change
                        title: Text(
                          checkBoxListTileModel[index].title,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5),
                        ),
                        value: checkBoxListTileModel[index].isCheck,
                        secondary: Container(
                          height: 50,
                          width: 50,
                          child: Image.asset(
                            checkBoxListTileModel[index].img,
                            fit: BoxFit.cover,
                          ),
                        ),
                        onChanged: (val) {
                          itemChange(val!, index);
                        })
                  ],
                ),
              ),
            );
          }),
    );
  }

  void itemChange(bool val, int index) {
    setState(() {
      checkBoxListTileModel[index].isCheck = val;
    });
  }
}

class CheckBoxListTileModel {
  int userId;
  String img;
  String title;
  bool isCheck;

  CheckBoxListTileModel(
      {required this.userId,
      required this.img,
      required this.title,
      required this.isCheck});

  static List<CheckBoxListTileModel> getUsers() {
    return <CheckBoxListTileModel>[
      CheckBoxListTileModel(
          userId: 1,
          img: 'assets/images/android_img.png',
          title: "Android",
          isCheck: true),
      CheckBoxListTileModel(
          userId: 2,
          img: 'assets/images/flutter.jpeg',
          title: "Flutter",
          isCheck: false),
      CheckBoxListTileModel(
          userId: 3,
          img: 'assets/images/ios_img.webp',
          title: "IOS",
          isCheck: false),
      CheckBoxListTileModel(
          userId: 4,
          img: 'assets/images/php_img.png',
          title: "PHP",
          isCheck: false),
      CheckBoxListTileModel(
          userId: 5,
          img: 'assets/images/node_img.png',
          title: "Node",
          isCheck: false),
    ];
  }
}

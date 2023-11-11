import 'package:eshopper_mobile_app/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'data_computation.dart';

class RecentViewItems extends StatefulWidget {
  final List recentViewList;

  RecentViewItems({required this.recentViewList});
  @override
  _RecentViewItemsState createState() => _RecentViewItemsState();
}

class _RecentViewItemsState extends State<RecentViewItems> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      // width: 400,
      child: GridView.count(
        childAspectRatio: 1.75,
        crossAxisCount: 1,
        scrollDirection: Axis.horizontal,
        children: List.generate(widget.recentViewList.length, (index) {
          return RecentlyViewTemplateDesign(
            ptdId: widget.recentViewList.toList()[index]['id'],
            productName: widget.recentViewList.toList()[index]['name'],
            productImage: widget.recentViewList.toList()[index]['imageURL'],
            productPrice: widget.recentViewList.toList()[index]['price'],
            discount: widget.recentViewList.toList()[index]['discount'],
            productNewPrice: widget.recentViewList.toList()[index]['new_price'],
            categoryId:
                widget.recentViewList.toList()[index]['category'].toString(),
          );
        }),
      ),
    );
  }
}

class RecentlyViewTemplateDesign extends StatelessWidget {
  final int ptdId;
  final String productName;
  final String productImage;
  final String productPrice;
  final String discount;
  final String productNewPrice;
  final String categoryId;

  RecentlyViewTemplateDesign(
      {required this.ptdId,
      required this.productName,
      required this.productImage,
      required this.productPrice,
      required this.discount,
      required this.productNewPrice,
      required this.categoryId});
  @override
  Widget build(BuildContext context) {
    var serviceProvider = Provider.of<DataProcessing>(context);
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.of(context)
              .pushNamed(RouteManager.productDetail, arguments: {
            'ptdId': ptdId.toString(),
            'category': categoryId,
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
                    if (productImage != "http://192.168.43.50:8000")
                      Flexible(
                        child: Image.network(
                          productImage,
                          fit: BoxFit.scaleDown,
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

// ========= DAILY CATEGORY LIST ==========
class DailyCategoryList extends StatefulWidget {
  List dailyCategoryList;

  DailyCategoryList({required this.dailyCategoryList});
  @override
  _DailyCategoryListState createState() => _DailyCategoryListState();
}

class _DailyCategoryListState extends State<DailyCategoryList> {
  @override
  Widget build(BuildContext context) {
    return Container(
      // color: Colors.lightGreen,
      child: GridView.count(
        childAspectRatio: 0.7,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        // scrollDirection: Axis.vertical,
        crossAxisCount: 3,
        children: List.generate(widget.dailyCategoryList.length, (index) {
          return DailyCatTemplateDesign(
            catId: widget.dailyCategoryList.toList()[index]['id'],
            category: widget.dailyCategoryList.toList()[index]['category'],
            treeId:
                widget.dailyCategoryList.toList()[index]['tree_id'].toString(),
            level: widget.dailyCategoryList.toList()[index]['level'].toString(),
            image: widget.dailyCategoryList.toList()[index]['image'],
            parentId: widget.dailyCategoryList
                .toList()[index]['parent_id']
                .toString(),
          );
        }),
      ),
    );
  }
}

class DailyCatTemplateDesign extends StatelessWidget {
  final int catId;
  final String category;
  final String treeId;
  final String level;
  final String image;
  final String parentId;

  DailyCatTemplateDesign(
      {required this.catId,
      required this.category,
      required this.treeId,
      required this.level,
      required this.image,
      required this.parentId});
  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      children: [
        InkWell(
          onTap: () {},
          child: Row(
            children: [
              const SizedBox(
                width: 5,
                height: 5,
              ),
              if (image != 'http://192.168.43.50:8000')
                CircleAvatar(
                  backgroundColor: Colors.transparent,
                  radius: 60.0,
                  child: Image.network(
                    image,
                    fit: BoxFit.contain,
                  ),
                ),
              if (image == 'http://192.168.43.50:8000')
                const CircleAvatar(
                  radius: 60.0,
                  child: Icon(Icons.photo_size_select_actual_sharp),
                ),
            ],
          ),
        ),
        Text(
          category,
          style: GoogleFonts.sora().copyWith(
            overflow: TextOverflow.ellipsis,
            fontSize: 13,
          ),
          maxLines: 3,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ========== DAILY BRAND LISTING ===========
class DailyBrands extends StatefulWidget {
  List dailyBrands;

  DailyBrands({required this.dailyBrands});
  @override
  _DailyBrandsState createState() => _DailyBrandsState();
}

class _DailyBrandsState extends State<DailyBrands> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(0),
      child: GridView.count(
        childAspectRatio: 3.6,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        crossAxisCount: 2,
        children: List.generate(widget.dailyBrands.length, (index) {
          return DailyBrandTemplate(
            brandId: widget.dailyBrands.toList()[index]['id'],
            brandName: widget.dailyBrands.toList()[index]['brand'],
          );
        }),
      ),
    );
  }
}

class DailyBrandTemplate extends StatelessWidget {
  final int brandId;
  final String brandName;

  DailyBrandTemplate({
    required this.brandId,
    required this.brandName,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(5.0),
        child: OutlinedButton(
          onPressed: () {},
          child: Text(
            brandName,
            style: const TextStyle(overflow: TextOverflow.ellipsis),
            maxLines: 2,
          ),
        ));
  }
}

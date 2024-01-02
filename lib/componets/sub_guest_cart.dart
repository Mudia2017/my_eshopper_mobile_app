import 'package:badges/badges.dart';
import 'package:eshopper_mobile_app/componets/data_computation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SubGuestCartPtd extends StatefulWidget {
  final String id;
  final String productId;
  final double price;
  final int quantity;
  final String name;
  final String image;
  final String outOfStock;
  final String activePtd;
  final String activeStore;

  SubGuestCartPtd(this.id, this.productId, this.price, this.quantity, this.name,
      this.image, this.outOfStock, this.activePtd, this.activeStore);

  @override
  State<SubGuestCartPtd> createState() => _SubGuestCartPtdState();
}

class _SubGuestCartPtdState extends State<SubGuestCartPtd> {
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
        serviceProvider.removeSingleRowItm(widget.productId);
      },
      child: Card(
        child: Column(
          children: [
            ListTile(
              leading: Column(
                children: [
                  if (widget.image != "http://Oneluvtoall.pythonanywhere.com")
                    Flexible(child: Image.network(widget.image)),
                  if (widget.image == "http://Oneluvtoall.pythonanywhere.com")
                    const Icon(
                      Icons.photo_size_select_actual_sharp,
                      color: Colors.black26,
                      size: 40,
                    ),
                ],
              ),
              title: Text(
                widget.name,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
              ),
              subtitle: Row(
                children: [
                  Text(
                    '₦ ' +
                        serviceProvider.formattedNumber(
                            double.parse(widget.price.toString())),
                    style: GoogleFonts.publicSans()
                        .copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(
                    width: 15.0,
                  ),
                  Text(
                    '₦ ' +
                        serviceProvider.formattedNumber(
                            serviceProvider.rowTotalAmt(
                                double.parse(widget.price.toString()),
                                widget.quantity)),
                    style: GoogleFonts.publicSans()
                        .copyWith(fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              trailing: Text(
                widget.quantity.toString() + ' X',
                style: GoogleFonts.publicSans().copyWith(),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // DISPLAY A BADGE ON PRODUCT THAT ARE OUT OF STOCK
                if (widget.outOfStock == 'true')
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
                if (widget.activePtd == 'false' ||
                    widget.activeStore == 'false')
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
                // REMOVE ITEM FROM CART FOR GUEST USER
                IconButton(
                  onPressed: () {
                    if (widget.quantity < 2) {
                      serviceProvider.removeSingleRowItm(widget.productId);
                    } else if (widget.quantity > 1) {
                      serviceProvider.removeSingleItem(widget.productId);
                    }
                  },
                  icon: Icon(
                    Icons.remove_shopping_cart_outlined,
                    color: Colors.redAccent.shade700,
                  ),
                ),

                // ADD ITEM TO CART FOR GUEST USER
                IconButton(
                  onPressed: () {
                    if (widget.outOfStock == 'false' &&
                        widget.activePtd == 'true' &&
                        widget.activeStore == 'true') {
                      serviceProvider.addItem(
                          widget.productId,
                          widget.name,
                          widget.price,
                          widget.image,
                          widget.outOfStock,
                          widget.activePtd,
                          widget.activeStore);
                    } else if (widget.outOfStock == 'true') {
                      serviceProvider.warningToastMassage(
                          'Out of stock item. Kindly remove from cart!');
                    } else if (widget.activePtd == 'false' ||
                        widget.activeStore == 'false') {
                      serviceProvider.warningToastMassage(
                          'Inactive item. Kindly remove from cart!');
                    }
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

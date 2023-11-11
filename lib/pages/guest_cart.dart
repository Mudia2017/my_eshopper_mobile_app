import 'package:eshopper_mobile_app/componets/data_computation.dart';
import 'package:eshopper_mobile_app/componets/sub_guest_cart.dart';
import 'package:eshopper_mobile_app/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class GuestCart extends StatefulWidget {
  const GuestCart({Key? key}) : super(key: key);

  @override
  _GuestCartState createState() => _GuestCartState();
}

class _GuestCartState extends State<GuestCart> {
  int itemRowCounter = 0;
  @override
  Widget build(BuildContext context) {
    var serviceProvider = Provider.of<DataProcessing>(context);
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
            child: serviceProvider.items.isNotEmpty
                ? ListView.builder(
                    itemCount: serviceProvider.items.length,
                    itemBuilder: (BuildContext ctx, int i) => SubGuestCartPtd(
                      serviceProvider.items.values.toList()[i].cartProductID,
                      serviceProvider.items.keys.toList()[i],
                      serviceProvider.items.values.toList()[i].cartProductPrice,
                      serviceProvider.items.values
                          .toList()[i]
                          .cartProductQuantity,
                      serviceProvider.items.values.toList()[i].cartProductName,
                      serviceProvider.items.values.toList()[i].cartProductImage,
                      serviceProvider.items.values
                          .toList()[i]
                          .cartProdOutOfStock,
                      serviceProvider.items.values.toList()[i].cartActivePtd,
                      serviceProvider.items.values.toList()[i].cartActiveStore,
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (serviceProvider.items.isEmpty)
                        Text(
                          "Your shopping cart is empty!",
                          style: TextStyle(
                              color: Colors.red[300],
                              fontWeight: FontWeight.bold),
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
                      serviceProvider.totalCartItm.toString(),
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
                      "₦ " +
                          serviceProvider
                              .formattedNumber(serviceProvider.totalAmt),
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
                    for (int x = 0; x < serviceProvider.items.length; x++) {
                      if (serviceProvider.items.values
                              .toList()[x]
                              .cartProdOutOfStock ==
                          'true') {
                        isOutOfStock = true;
                        break;
                      } else if (serviceProvider.items.values
                                  .toList()[x]
                                  .cartActivePtd ==
                              'false' ||
                          serviceProvider.items.values
                                  .toList()[x]
                                  .cartActiveStore ==
                              'false') {
                        isInactiveItem = true;
                        break;
                      }
                    }

                    // PROCEED TO ITEM SUMMARY PAGE
                    if (isOutOfStock == false &&
                        isInactiveItem == false &&
                        serviceProvider.items.isNotEmpty) {
                      Navigator.of(context)
                          .pushNamed(RouteManager.guestSummary);
                    } else if (isOutOfStock == true) {
                      serviceProvider.warningToastMassage(
                          'Remove out of stock item from your cart before proceeding');
                    } else if (isInactiveItem == true) {
                      serviceProvider.warningToastMassage(
                          'Remove inactive item from your cart before proceeding');
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

import 'package:eshopper_mobile_app/componets/data_computation.dart';
import 'package:eshopper_mobile_app/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class GuestOrderSummary extends StatefulWidget {
  @override
  _GuestOrderSummaryState createState() => _GuestOrderSummaryState();
}

class _GuestOrderSummaryState extends State<GuestOrderSummary> {
  @override
  Widget build(BuildContext context) {
    var serviceProvider = Provider.of<DataProcessing>(context);
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
      ),
      body: Column(
        children: [
          serviceProvider.items.isNotEmpty
              ? Expanded(
                  child: ListView.builder(
                      itemCount: serviceProvider.items.length,
                      itemBuilder: (BuildContext cxt, int x) => listViewSection(
                            serviceProvider.items.values.toList()[x].pdtid,
                            serviceProvider.items.values
                                .toList()[x]
                                .cartProductPrice,
                            serviceProvider.items.values
                                .toList()[x]
                                .cartProductQuantity,
                            serviceProvider.items.values
                                .toList()[x]
                                .cartProductName,
                            serviceProvider.items.values
                                .toList()[x]
                                .cartProductImage,
                            serviceProvider.items.values
                                .toList()[x]
                                .cartProdOutOfStock,
                          )),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (serviceProvider.items.isEmpty)
                      Text(
                        'Your shopping cart is empty!',
                        style: TextStyle(
                            color: Colors.red[300],
                            fontWeight: FontWeight.bold),
                      )
                  ],
                ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0.0, 0.0, 7.0, 0.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      'Items',
                      style: GoogleFonts.sora().copyWith(
                        color: Colors.grey,
                        fontSize: 17,
                      ),
                    ),
                    Text(
                      serviceProvider.totalCartItm.toString(),
                      style: GoogleFonts.publicSans().copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 17,
                      ),
                    )
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
                          .pushNamed(RouteManager.checkOutGuest);
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
                        "Continue",
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

  Container titleSection() {
    return Container(
      margin: const EdgeInsets.all(0.0),
      child: const Text("Order Summary",
          style: TextStyle(
              color: Colors.black,
              fontSize: 25.0,
              fontWeight: FontWeight.bold)),
    );
  }

  Container listViewSection(String ptdId, double price, int quantity,
      String name, image, outOfStock) {
    var serviceProvider = Provider.of<DataProcessing>(context);
    return Container(
      padding: const EdgeInsets.all(0),
      child: Card(
        child: Column(
          children: [
            ListTile(
              leading: Container(
                  width: 50,
                  child: Column(
                    children: [
                      if (image != "http://192.168.43.50:8000")
                        Flexible(child: Image.network(image)),
                      if (image == "http://192.168.43.50:8000")
                        const Icon(
                          Icons.photo_size_select_actual_sharp,
                          color: Colors.black26,
                          size: 40,
                        ),
                    ],
                  )),
              title: Text(
                name,
                style: GoogleFonts.sora().copyWith(
                  fontSize: 13,
                  color: Colors.grey,
                ),
                overflow: TextOverflow.ellipsis,
                softWrap: true,
                maxLines: 2,
              ),
              subtitle: Text('₦ ' + serviceProvider.formattedNumber(price),
                  style: GoogleFonts.publicSans().copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 18,
                  )),
              trailing: Text(
                quantity.toString() + ' X',
                style: GoogleFonts.publicSans()
                    .copyWith(fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
      ),
    );
  }
}

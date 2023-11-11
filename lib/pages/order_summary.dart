import 'dart:convert';

import 'package:eshopper_mobile_app/componets/data_computation.dart';
import 'package:eshopper_mobile_app/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class CustomerOrderSummary extends StatefulWidget {
  String userName = 'Guest';
  String userEmail = '';
  String token = '';
  String custId;

  CustomerOrderSummary(
      {required this.userName,
      required this.userEmail,
      required this.token,
      required this.custId});
  @override
  _CustomerOrderSummaryState createState() => _CustomerOrderSummaryState();
}

class _CustomerOrderSummaryState extends State<CustomerOrderSummary> {
  List<dynamic> cartData = [];
  var cartCounter = 0;
  double grandTotal = 0;
  bool isLoadingCartPtd = true;

  @override
  void initState() {
    super.initState();
    getApiCartData(widget.userName, widget.userEmail, widget.token);
  }

  Future getApiCartData(String userName, userEmail, token) async {
    Map data = {
      "customer": {"name": userName, "email": userEmail},
      "shippingInfo": "getShippingInfo"
    };

    var response = await http.post(
      Uri.parse('http://192.168.43.50:8000/apis/v1/homePage/api_cartData/'),
      body: jsonEncode(data),
      headers: {
        "Content-type": "application/json",
        "Authorization": "Token $token"
      },
    );
    if (response.statusCode == 200) {
      Map<String, dynamic> cartDataSummary = json.decode(response.body);

      setState(() {
        cartData = cartDataSummary['cartItm']['cart item'];
        grandTotal = (cartDataSummary['cartItm']['grand total']);
        cartCounter = cartDataSummary['cartItm']['cart total count'];
        isLoadingCartPtd = false;
      });
    } else {
      // I NEED TO WORK ON THIS ELSE STATEMENT IF THERE IS AN ERROR
      // IN STEAD OF THE SPINNER TURNING, WE STOP THE SPINNER AND DISPLAY
      // AN ERROR MESSAGE
      isLoadingCartPtd = false;
    }

    // return cartDataSummary;
  }

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
          cartData.isNotEmpty
              ? Expanded(
                  child: ListView.builder(
                    itemCount: cartData.length,
                    itemBuilder: (BuildContext cxt, int x) => listViewSection(
                      '${cartData.toList()[x]['id']}',
                      double.parse('${cartData.toList()[x]['price']}'),
                      '${cartData.toList()[x]['quantity']}',
                      '${cartData.toList()[x]['name']}',
                      '${cartData.toList()[x]['image']}',
                      '${cartData.toList()[x]['discount']}',
                    ),
                  ),
                )
              : Flexible(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (cartData.isEmpty && isLoadingCartPtd == true)
                        const Center(child: CircularProgressIndicator())
                      else if (cartData.isEmpty && isLoadingCartPtd == false)
                        Text(
                          "An error occured!",
                          style: TextStyle(
                              color: Colors.red[300],
                              fontWeight: FontWeight.bold),
                        )
                    ],
                  ),
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
                      cartCounter.toString(),
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
                    Text(
                      'Total',
                      style: GoogleFonts.sora().copyWith(
                        color: Colors.grey,
                        fontSize: 17,
                      ),
                    ),
                    Text(
                      '₦ ' + serviceProvider.formattedNumber(grandTotal),
                      style: GoogleFonts.publicSans().copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.lightBlueAccent.shade700,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
                MaterialButton(
                  onPressed: () {
                    if (grandTotal > 0) {
                      Navigator.of(context).pushNamed(
                        RouteManager.checkOut,
                        arguments: ({
                          'userName': widget.userName,
                          'token': widget.token,
                          'userEmail': widget.userEmail,
                          'custId': widget.custId,
                        }),
                      );
                    } else {
                      serviceProvider
                          .warningToastMassage('No item to check out!');
                    }
                  },
                  child: const Text(
                    'Continue',
                    style: TextStyle(fontSize: 20),
                  ),
                  color: Colors.orange.shade400,
                  elevation: 5,
                  height: 50,
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

  Container listViewSection(
      String ptdId, double price, quantity, name, image, discount) {
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
                quantity + ' X',
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

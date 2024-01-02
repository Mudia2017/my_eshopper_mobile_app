import 'dart:convert';

import 'package:eshopper_mobile_app/componets/data_computation.dart';
import 'package:eshopper_mobile_app/componets/side_drawer.dart';
import 'package:eshopper_mobile_app/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class MyPtdReviewSession extends StatefulWidget {
  final String token, userName;
  MyPtdReviewSession({required this.token, required this.userName});
  @override
  _MyPtdReviewSessionState createState() => _MyPtdReviewSessionState();
}

class _MyPtdReviewSessionState extends State<MyPtdReviewSession> {
  @override
  void initState() {
    super.initState();

    getPendingPtdReview();
  }

  bool isCompleteLoading = false;
  bool isLoadingError = false;
  List _myPeningReviewOrders = [];

  // ========= API CALL TO LOAD PENDING PTD REVIEW PER CUSTOMER =======
  getPendingPtdReview() async {
    var data = {'userName': widget.userName};
    var response = await http.post(
      // Uri.parse(
      //     'http://192.168.43.50:8000/apis/v1/homePage/api_pendingReview/'),
      Uri.parse(
          'http://Oneluvtoall.pythonanywhere.com/apis/v1/homePage/api_pendingReview/'),
      body: jsonEncode(data),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Token ${widget.token}",
      },
    );

    try {
      if (response.statusCode == 200) {
        var myPeningReviewOrders = json.decode(response.body);
        setState(() {
          _myPeningReviewOrders = myPeningReviewOrders;
        });
        isCompleteLoading = true;
        isLoadingError = false;
      }
    } catch (error) {
      isLoadingError = true;
      isCompleteLoading = true;
      // rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    var serviceProvider = Provider.of<DataProcessing>(context);
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
        ),
        drawer: const SafeArea(
          child: Drawer(
            child: SideDrawer(caller: 'innerSideDrawer'),
          ),
        ),
        body: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF40C4FF),
                  Color(0xFFA7FFEB),
                ],
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      'Order No',
                      style: GoogleFonts.sora()
                          .copyWith(fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Customer Name',
                      style: GoogleFonts.sora()
                          .copyWith(fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Date',
                      style: GoogleFonts.sora()
                          .copyWith(fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                _myPeningReviewOrders.isNotEmpty
                    ? Expanded(
                        child: ListView.builder(
                          itemCount: _myPeningReviewOrders.length,
                          itemBuilder: (context, x) => listView(
                            _myPeningReviewOrders.toList()[x]['id'].toString(),
                            _myPeningReviewOrders.toList()[x]['transaction_id'],
                            _myPeningReviewOrders.toList()[x]['cus_name'],
                            _myPeningReviewOrders.toList()[x]['order_date'],
                          ),
                        ),
                      )
                    : Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (isCompleteLoading == false)
                              const CircularProgressIndicator(),
                            if (isLoadingError == true)
                              Text(
                                "An Error Occured!",
                                style: TextStyle(
                                    color: Colors.red[300],
                                    fontWeight: FontWeight.bold),
                              ),
                            if (isCompleteLoading == true &&
                                _myPeningReviewOrders.isEmpty)
                              Text(
                                "No Record!",
                                style: TextStyle(
                                    color: Colors.red[300],
                                    fontWeight: FontWeight.bold),
                              ),
                          ],
                        ),
                      ),
              ],
            )),
      ),
    );
  }

  Container appBarTitle() {
    return Container(
      margin: const EdgeInsets.all(0.0),
      child: const Text("Your Pending Review",
          style: TextStyle(
              color: Colors.black,
              fontSize: 20.0,
              fontWeight: FontWeight.bold)),
    );
  }

  Container listView(String id, transactionId, cusName, orderDate) {
    var serviceProvider = Provider.of<DataProcessing>(context);
    return Container(
      child: Column(
        children: [
          InkWell(
            onTap: () {
              Navigator.of(context)
                  .pushNamed(RouteManager.writeMyPtdReview, arguments: {
                'token': widget.token,
                'userName': widget.userName,
                'parentPtdReviewId': id,
                'transId': transactionId
              });
            },
            child: ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    transactionId,
                    style: GoogleFonts.sora()
                        .copyWith(fontSize: 10, color: Colors.blue.shade900),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        cusName,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: GoogleFonts.sora().copyWith(fontSize: 10),
                      ),
                    ),
                  ),
                ],
              ),
              trailing: Text(
                orderDate,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: GoogleFonts.sora().copyWith(fontSize: 10),
              ),
            ),
          ),
          const Divider(
            color: Colors.black54,
          )
        ],
      ),
    );
  }
}

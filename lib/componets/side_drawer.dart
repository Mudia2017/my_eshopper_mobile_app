import 'dart:convert';

import 'package:eshopper_mobile_app/componets/data_computation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eshopper_mobile_app/routes/routes.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class SideDrawer extends StatefulWidget {
  // const SideDrawer({Key? key}) : super(key: key);

  final String caller;
  // ignore: use_key_in_widget_constructors
  const SideDrawer({required this.caller});

  @override
  State<SideDrawer> createState() => _SideDrawerState();
}

class _SideDrawerState extends State<SideDrawer> {
  @override
  void initState() {
    super.initState();
    getUserNamePreference();
    getUserEmailPreference();
    getUserTokenPreference();
    getCustomerIdPreference();
    getCustomerNamePreference();
    getUserIdPreference();
    getCustomerEmailPreference();
  }

  String userName = 'Guest';
  String userEmail = '';
  String userToken = '';
  String customerId = '';
  String custName = '';
  String custEmail = '';
  String userId = '';
  bool logOut = false;
  String systemMsg = 'Kindly login to have full access!';

  Future getUserNamePreference() async {
    var prefName = await DataProcessing.getUserNamePreference();
    setState(() {
      userName = prefName;
    });
  }

  Future getUserEmailPreference() async {
    var prefEmail = await DataProcessing.getUserEmailPreference();
    setState(() {
      userEmail = prefEmail;
    });
  }

  Future getUserTokenPreference() async {
    var prefToken = await DataProcessing.getTokenFrmPreference();
    setState(() {
      userToken = prefToken;
    });
  }

  Future getCustomerIdPreference() async {
    var prefCusId = await DataProcessing.getCusIdPreference();
    setState(() {
      customerId = prefCusId;
    });
  }

  Future getCustomerNamePreference() async {
    var prefCusName = await DataProcessing.getCusNamePreference();
    setState(() {
      custName = prefCusName;
    });
  }

  Future getCustomerEmailPreference() async {
    var prefCusEmail = await DataProcessing.getCusEmailPreference();
    setState(() {
      custEmail = prefCusEmail;
    });
  }

  Future getUserIdPreference() async {
    var prefUserId = await DataProcessing.getUserIdPreference();
    setState(() {
      userId = prefUserId;
    });
  }

  var httpResponse = '';
  logOutUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var response = await http.post(
      // Uri.parse('http://192.168.1.36:8000/apis/v1/homePage/api_logout/'),
      // Uri.parse('http://192.168.43.50:8000/apis/v1/homePage/api_logout/'),
      // Uri.parse("http://127.0.0.1:8000/apis/v1/homePage/api_logout/"),
      // Uri.parse('http://172.20.10.5:8000/apis/v1/homePage/api_logout/'),
      Uri.parse(
          'http://Oneluvtoall.pythonanywhere.com/apis/v1/homePage/api_logout/'),
    );

    if (response.statusCode == 200) {
      httpResponse = response.body;
      // RESPONSE FROM THE SERVER WHEN USER IS SUCCESSFULY LOGGED OUT
      if (httpResponse == "You've been logged out!") {
        setState(() {
          prefs.setString('username', 'Guest');
          prefs.setString('useremail', '');
          prefs.setString('token', '');
          prefs.setString('customerId', '');
          prefs.setString('userId', '');
          prefs.setString('custName', '');
          prefs.setString('custEmail', '');
          logOut = true;
        });
        getUserNamePreference();
      }
    } else {
      setState(() {
        Fluttertoast.showToast(
            msg: 'Fail to log out!',
            timeInSecForIosWeb: 5,
            backgroundColor: Colors.red);
      });
    }
    return httpResponse;
  }

  @override
  Widget build(BuildContext context) {
    final serviceProvider = Provider.of<DataProcessing>(context);
    if (logOut == true) {
      Fluttertoast.showToast(
        msg: httpResponse,
        backgroundColor: Colors.black38,
        timeInSecForIosWeb: 8,
      );

      setState(() {
        getUserNamePreference();
        getUserEmailPreference();
      });
      logOut = false;
      serviceProvider.isApiLoaded = false;
    }
    return Container(
      decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [
        Color(0xFF40C4FF),
        Color(0xFFA7FFEB),
      ])),
      child: ListView(
        children: [
          // HEAD OF THE SIDE DRAWER
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [
              Color(0xFF40C4FF),
              Color(0xFFA7FFEB),
            ])),
            accountName: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.all(0),
                    child: Text(
                      'Hello $userName',
                      style: GoogleFonts.philosopher()
                          .copyWith(fontSize: 18, color: Colors.black),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ),
                if (userEmail == '')
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0.0, 0.0, 7.0, 0.0),
                    child: InkWell(
                      onTap: () {
                        print('pressed');
                        Navigator.of(context).pushNamed(RouteManager.login);
                      },
                      child: Text(
                        'Login',
                        style: GoogleFonts.roboto().copyWith(
                            fontSize: 20,
                            decoration: TextDecoration.underline,
                            color: Colors.black),
                      ),
                    ),
                  ),
                if (userEmail != '' || userName != 'Guest')
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0.0, 0.0, 7.0, 0.0),
                    child: InkWell(
                      onTap: () async {
                        setState(() {
                          serviceProvider.isLoadDialogBox = true;
                          serviceProvider.buildShowDialog(context);
                        });
                        var response = await logOutUser();
                        // THIS RESPONSE IS COMING FROM THE SERVER WHEN THE USER IS LOGGED OUT
                        if (response == "You've been logged out!") {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                              RouteManager.homePage,
                              (Route<dynamic> route) => false);
                        } else {
                          setState(() {
                            serviceProvider.isLoadDialogBox = false;
                          });
                        }
                      },
                      child: Text(
                        'Log out',
                        style: GoogleFonts.roboto().copyWith(
                            fontSize: 20,
                            decoration: TextDecoration.underline,
                            color: Colors.black),
                      ),
                    ),
                  ),
              ],
            ),
            accountEmail: Container(
              padding: const EdgeInsets.all(0),
              child: Text(
                userEmail,
                style: GoogleFonts.nixieOne()
                    .copyWith(fontSize: 15, color: Colors.black),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            currentAccountPicture: GestureDetector(
              child: const CircleAvatar(
                backgroundColor: Colors.black45,
                child: Icon(
                  Icons.person,
                  size: 70.0,
                ),
              ),
            ),
          ),
          const Divider(
            color: Colors.black54,
          ),
          // BODY OF THE SIDE DRAWER
          if (widget.caller == 'innerSideDrawer')
            InkWell(
              onTap: () {
                Navigator.of(context)
                    .pushReplacementNamed((RouteManager.homePage));
              },
              child: ListTile(
                leading: const Icon(
                  Icons.house_outlined,
                  color: Colors.black,
                ),
                title: Text(
                  'Home',
                  style: GoogleFonts.roboto().copyWith(
                    fontSize: 20,
                    color: Colors.black,
                  ),
                ),
              ),
            ),

          InkWell(
            onTap: () {
              Navigator.of(context)
                  .pushReplacementNamed(RouteManager.marketPlace, arguments: {
                'username': userName,
                'useremail': userEmail,
                'usertoken': userToken,
                'custId': customerId,
                'custName': custName,
                'custEmail': custEmail,
              });
            },
            child: ListTile(
              leading: const Icon(
                Icons.store,
                color: Colors.black,
              ),
              title: Text(
                'Store',
                style: GoogleFonts.roboto().copyWith(
                  fontSize: 20,
                  color: Colors.black,
                ),
              ),
            ),
          ),

          InkWell(
            onTap: () {},
            child: ListTile(
              leading: const Icon(
                Icons.category,
                color: Colors.black,
              ),
              title: Text(
                'Category',
                style: GoogleFonts.roboto().copyWith(
                  fontSize: 20,
                  color: Colors.black,
                ),
              ),
            ),
          ),

          const Divider(
            color: Colors.black54,
          ),

          InkWell(
            onTap: () {
              if (userToken.isNotEmpty) {
                Navigator.of(context).pushReplacementNamed(
                    RouteManager.myOrderSession,
                    arguments: {'token': userToken});
              } else {
                serviceProvider.warningToastMassage('Only for registered user');
              }
            },
            child: ListTile(
              leading: const Icon(
                Icons.shopping_basket,
                color: Colors.black,
              ),
              title: Text(
                'My Order',
                style: GoogleFonts.roboto().copyWith(
                  fontSize: 20,
                  color: Colors.black,
                ),
              ),
            ),
          ),

          InkWell(
            onTap: () {
              if (userToken.isNotEmpty) {
                Navigator.of(context).pushReplacementNamed(
                    RouteManager.myPtdReviewSession,
                    arguments: {'token': userToken, 'userName': userName});
              } else {
                serviceProvider.warningToastMassage('Only for registered user');
              }
            },
            child: ListTile(
              leading: const Icon(
                Icons.pending_actions,
                color: Colors.black,
              ),
              title: Text(
                'Pending Reviews',
                style: GoogleFonts.roboto().copyWith(
                  fontSize: 20,
                  color: Colors.black,
                ),
              ),
            ),
          ),

          InkWell(
            onTap: () {
              if (userToken.isNotEmpty) {
                Navigator.of(context)
                    .pushReplacementNamed(RouteManager.myWishList, arguments: {
                  'token': userToken,
                  'customer_id': customerId,
                  'customerName': userName,
                  'custEmail': userEmail,
                });
              } else {
                serviceProvider.warningToastMassage('Only for registered user');
              }
            },
            child: ListTile(
              leading: const Icon(
                Icons.checklist,
                color: Colors.black,
              ),
              title: Text(
                'My Wish List',
                style: GoogleFonts.roboto().copyWith(
                  fontSize: 20,
                  color: Colors.black,
                ),
              ),
            ),
          ),

          // InkWell(
          //   onTap: () {},
          //   child: ListTile(
          //     leading: const Icon(
          //       Icons.add_business_rounded,
          //       color: Colors.black,
          //     ),
          //     title: Text(
          //       'Address',
          //       style: GoogleFonts.roboto().copyWith(
          //         fontSize: 20,
          //         color: Colors.black,
          //       ),
          //     ),
          //   ),
          // ),

          InkWell(
            onTap: () {
              // CHECKING TO ENSURE ONLY ACTIVE USER CAN ACCESS CUSTOMER CARE
              if (userName == 'Guest') {
                Fluttertoast.showToast(
                  msg: systemMsg,
                  backgroundColor: Colors.black45,
                  timeInSecForIosWeb: 10,
                );
              } else {
                Navigator.of(context).pushReplacementNamed(
                    RouteManager.customerService,
                    arguments: {
                      'username': userName,
                      'userId': userId,
                      'token': userToken,
                    });
              }
            },
            child: ListTile(
              leading: const Icon(
                Icons.headset_mic_outlined,
                color: Colors.black,
              ),
              title: Text(
                'Customer Service',
                style: GoogleFonts.roboto().copyWith(
                  fontSize: 20,
                  color: Colors.black,
                ),
              ),
            ),
          ),

          InkWell(
            onTap: () {
              // CHECKING TO ENSURE ONLY ACTIVE USER CAN ACCESS CUSTOMER CARE
              if (userName == 'Guest') {
                Fluttertoast.showToast(
                  msg: systemMsg,
                  backgroundColor: Colors.black45,
                  timeInSecForIosWeb: 10,
                );
              } else {
                Navigator.of(context).pushReplacementNamed(
                    RouteManager.traderStore,
                    arguments: {'token': userToken, 'userId': userId});
              }
            },
            child: ListTile(
              leading: const Icon(
                Icons.storefront,
                color: Colors.black,
              ),
              title: Text(
                'Trader Store',
                style: GoogleFonts.roboto().copyWith(
                  fontSize: 20,
                  color: Colors.black,
                ),
              ),
            ),
          ),

          InkWell(
            onTap: () {
              // CHECKING TO ENSURE ONLY ACTIVE USER CAN ACCESS CUSTOMER CARE
              if (userName == 'Guest') {
                Fluttertoast.showToast(
                  msg: systemMsg,
                  backgroundColor: Colors.black45,
                  timeInSecForIosWeb: 10,
                );
              } else {
                Navigator.of(context).pushReplacementNamed(
                    RouteManager.productOverview,
                    arguments: {'token': userToken, 'userId': userId});
              }
            },
            child: ListTile(
              leading: const Icon(
                Icons.production_quantity_limits,
                color: Colors.black,
              ),
              title: Text(
                'Product',
                style: GoogleFonts.roboto().copyWith(
                  fontSize: 20,
                  color: Colors.black,
                ),
              ),
            ),
          ),

          InkWell(
            onTap: () {
              if (userToken.isNotEmpty) {
                Navigator.of(context).pushReplacementNamed(
                    RouteManager.adminSession,
                    arguments: {'token': userToken});
              } else {
                serviceProvider.warningToastMassage('Only for registered user');
              }
            },
            child: ListTile(
              leading: const Icon(
                Icons.admin_panel_settings,
                color: Colors.black,
              ),
              title: Text(
                'Admin',
                style: GoogleFonts.roboto().copyWith(
                  fontSize: 20,
                  color: Colors.black,
                ),
              ),
            ),
          ),

          InkWell(
            onTap: () {
              // CHECKING TO ENSURE ONLY ACTIVE USER CAN ACCESS SETTINGS
              if (userName == 'Guest') {
                Fluttertoast.showToast(
                  msg: systemMsg,
                  backgroundColor: Colors.black45,
                  timeInSecForIosWeb: 10,
                );
              } else {
                Navigator.of(context).pushReplacementNamed(
                    RouteManager.appSettings,
                    arguments: {'token': userToken, 'userId': userId});
              }
            },
            child: ListTile(
              leading: const Icon(
                Icons.miscellaneous_services,
                color: Colors.black,
              ),
              title: Text(
                'Settings',
                style: GoogleFonts.roboto().copyWith(
                  fontSize: 20,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // void _userName(String name) {
  //   setState(() {
  //     if (name != 'AnonymousUser' && name != null) {
  //       userName = name;
  //     } else {
  //       userName = 'AnonymousUser';
  //     }
  //   });
  // }

  // void _userEmail(String email) {
  //   setState(() {
  //     if (email != 'null' && email != null) {
  //       userEmail = email;
  //     } else {
  //       userEmail = '';
  //     }
  //   });
  // }
}

import 'dart:convert';

import 'package:eshopper_mobile_app/componets/data_computation.dart';
import 'package:eshopper_mobile_app/routes/routes.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:eshopper_mobile_app/componets/side_drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Settings extends StatefulWidget {
  final String userId;
  final String token;

  Settings({
    required this.userId,
    required this.token,
  });
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  void initState() {
    super.initState();

    getDefaultShipAddress();
  }

  var serverData = {};
  Map defaultShipRecord = {};
  String name = '';
  String address = '';
  String city = '';
  String state = '';
  String zipcode = '';
  String mobile = '';
  String altMobile = '';

  // ============= API CALL FOR DEFAULT SHIPPING ADDRESS ============
  getDefaultShipAddress() async {
    var data = {'call': 'defaultShipAddress'};
    var response = await http.post(
      // Uri.parse('http://192.168.43.50:8000/apis/v1/homePage/api_settings/'),
      Uri.parse(
          'http://Oneluvtoall.pythonanywhere.com/apis/v1/homePage/api_settings/'),
      body: jsonEncode(data),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Token ${widget.token}",
      },
    );

    try {
      if (response.statusCode == 200) {
        serverData = json.decode(response.body);
        defaultShipRecord = serverData['cus_defaultAddress'];
        if (defaultShipRecord.isNotEmpty) {
          setState(() {
            name = serverData['cus_defaultAddress']['name'];
            address = serverData['cus_defaultAddress']['address'];
            city = serverData['cus_defaultAddress']['city'];
            state = serverData['cus_defaultAddress']['state'];
            if (serverData['cus_defaultAddress']['zipcode'] != null) {
              zipcode = serverData['cus_defaultAddress']['zipcode'];
            }
            mobile = serverData['cus_defaultAddress']['mobile'];
            if (serverData['cus_defaultAddress']['altMobile'] != null) {
              altMobile = serverData['cus_defaultAddress']['altMobile'];
            }
          });
        }
      }
    } catch (error) {
      rethrow;
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
            ])),
          ),
          title: titleSection(),
        ),
        drawer: const SafeArea(
          child: Drawer(
            child: SideDrawer(caller: 'innerSideDrawer'),
          ),
        ),
        body: Container(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              shipAddress(),
            ],
          ),
        ),
      ),
    );
  }

  Container titleSection() {
    return Container(
      margin: const EdgeInsets.all(0.0),
      child: const Text("Settings",
          style: TextStyle(
              color: Colors.black,
              fontSize: 25.0,
              fontWeight: FontWeight.bold)),
    );
  }

  Container shipAddress() {
    return Container(
      child: Column(
        children: [
          InkWell(
            onTap: () {
              Navigator.of(context).pushNamed(
                RouteManager.allShipAddress,
                arguments: {
                  'token': widget.token,
                },
              );
            },
            child: ListTile(
              title: const Text(
                'Shipping Address',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.lightBlue),
              ),
              subtitle: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      if (defaultShipRecord.isNotEmpty)
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                              ),
                              Text(
                                address,
                                style: const TextStyle(
                                  fontSize: 11,
                                ),
                              ),
                              Text(
                                city,
                                style: const TextStyle(
                                  fontSize: 11,
                                ),
                              ),
                              Text(
                                state + " " + zipcode,
                                style: const TextStyle(
                                  fontSize: 11,
                                ),
                              ),
                              Text(
                                mobile,
                                style: const TextStyle(
                                  fontSize: 11,
                                ),
                              ),
                              if (altMobile.isNotEmpty)
                                Text(
                                  altMobile,
                                  style: const TextStyle(
                                    fontSize: 11,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      if (defaultShipRecord.isEmpty)
                        const Text(
                          'Add Ship Record',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.red,
                          ),
                        ),
                    ],
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: Colors.blue,
                    size: 30,
                  ),
                ],
              ),
            ),
          ),
          Divider(
            color: Colors.grey[900],
          ),
          InkWell(
            onTap: () {
              Navigator.of(context)
                  .pushNamed(RouteManager.adminSetting, arguments: {
                'token': widget.token,
              });
            },
            child: const ListTile(
              title: Text('Admin Setting'),
              trailing: Icon(
                Icons.chevron_right,
                color: Colors.blue,
                size: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:eshopper_mobile_app/componets/data_computation.dart';
import 'package:eshopper_mobile_app/routes/routes.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class OverViewShipAddresses extends StatefulWidget {
  final String token;

  OverViewShipAddresses({required this.token});
  @override
  _OverViewShipAddressesState createState() => _OverViewShipAddressesState();
}

class _OverViewShipAddressesState extends State<OverViewShipAddresses> {
  @override
  void initState() {
    super.initState();

    getAllShipAddresses();
  }

  List allShipAddresses = [];
  bool isDoneLoading = false;
  String selectedRadio = '';

  // ============= API CALL FOR ALL SHIPPING ADDRESSES ============
  getAllShipAddresses() async {
    var data = {'call': 'allShipAddress'};
    var response = await http.post(
      Uri.parse('http://192.168.43.50:8000/apis/v1/homePage/api_settings/'),
      body: jsonEncode(data),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Token ${widget.token}",
      },
    );

    try {
      if (response.statusCode == 200) {
        var serverData = json.decode(response.body);
        setState(() {
          allShipAddresses = serverData['allShipAddressData'];
          isDoneLoading = true;
        });
      }
    } catch (error) {
      setState(() {
        isDoneLoading = true;
      });
      rethrow;
    }
  }

  addressRecord(name, address, city, state, zipcode, mobile, altMobile) {
    var storeInfo = {
      'name': name,
      'address': address,
      'city': city,
      'state': state,
      'zipcode': zipcode,
      'mobile': mobile,
      'altMobile': altMobile,
    };
    return storeInfo;
  }

  processRequest() {}

  @override
  Widget build(BuildContext context) {
    var serviceProvider = Provider.of<DataProcessing>(context);
    return Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          title: titleSection(),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [
              Color(0xFF40C4FF),
              Color(0xFFA7FFEB),
            ])),
          ),
        ),
        body: allShipAddresses.isNotEmpty
            ? ListView.builder(
                itemCount: allShipAddresses.length,
                itemBuilder: (context, x) {
                  String value = allShipAddresses.toList()[x]['id'].toString();
                  if (allShipAddresses.toList()[x]['isDefault'] == true) {
                    // value = allShipAddresses.toList()[x]['id'].toString();
                    selectedRadio =
                        allShipAddresses.toList()[x]['id'].toString();
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            allShipAddresses.toList()[x]['name'].toString(),
                          ),
                          Row(
                            children: [
                              Radio(
                                value: value,
                                groupValue: selectedRadio,
                                onChanged: (val) async {
                                  // CALL THE DIALOG TO PREVENT USER FROM THE UI UNTIL DATA IS SAVED TO THE SERVER
                                  setState(() {
                                    serviceProvider.isLoadDialogBox = true;
                                    serviceProvider.buildShowDialog(context);
                                  });

                                  var response = await serviceProvider
                                      .updateCustomerAddress(
                                    widget.token,
                                    allShipAddresses
                                        .toList()[x]['id']
                                        .toString(),
                                    'setDefault',
                                    '',
                                  );

                                  // CALL THE DIALOG TO ALLOW USER PERFORM OPERATION ON THE UI

                                  serviceProvider.isLoadDialogBox = false;
                                  serviceProvider.buildShowDialog(context);

                                  if (response['isSuccess'] == true) {
                                    await getAllShipAddresses();
                                    setState(() {
                                      selectedRadio = val.toString();
                                    });
                                    serviceProvider.toastMessage('success');
                                  } else {
                                    serviceProvider.popWarningErrorMsg(
                                        context,
                                        'Error',
                                        response['errorMsg'].toString());
                                  }
                                },
                              ),
                              const Text(
                                'set as \ndefault',
                                style: TextStyle(
                                  fontSize: 11,
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            RouteManager.updateShipAddress,
                            arguments: {
                              'token': widget.token,
                              'calling': 'updateShipAddress',
                              'shipAddressId':
                                  allShipAddresses.toList()[x]['id'].toString(),
                              'shipRecord': addressRecord(
                                allShipAddresses.toList()[x]['name'].toString(),
                                allShipAddresses
                                    .toList()[x]['address']
                                    .toString(),
                                allShipAddresses.toList()[x]['city'].toString(),
                                allShipAddresses
                                    .toList()[x]['state']
                                    .toString(),
                                allShipAddresses
                                    .toList()[x]['zipcode']
                                    .toString(),
                                allShipAddresses
                                    .toList()[x]['mobile']
                                    .toString(),
                                allShipAddresses
                                    .toList()[x]['altMobile']
                                    .toString(),
                              )
                            },
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  Text(
                                    allShipAddresses
                                        .toList()[x]['address']
                                        .toString(),
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                  Text(
                                    allShipAddresses
                                        .toList()[x]['city']
                                        .toString(),
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                  if (allShipAddresses
                                              .toList()[x]['zipcode']
                                              .toString() !=
                                          'null' &&
                                      allShipAddresses
                                              .toList()[x]['zipcode']
                                              .toString() !=
                                          '')
                                    Text(
                                      allShipAddresses
                                              .toList()[x]['state']
                                              .toString() +
                                          '  ' +
                                          allShipAddresses
                                              .toList()[x]['zipcode']
                                              .toString(),
                                      style:
                                          const TextStyle(color: Colors.grey),
                                    ),
                                  if (allShipAddresses
                                              .toList()[x]['zipcode']
                                              .toString() ==
                                          'null' ||
                                      allShipAddresses
                                              .toList()[x]['zipcode']
                                              .toString() ==
                                          '')
                                    Text(
                                      allShipAddresses
                                          .toList()[x]['state']
                                          .toString(),
                                      style:
                                          const TextStyle(color: Colors.grey),
                                    ),
                                  Text(
                                    allShipAddresses
                                        .toList()[x]['mobile']
                                        .toString(),
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                  if (allShipAddresses
                                              .toList()[x]['altMobile']
                                              .toString() !=
                                          'null' &&
                                      allShipAddresses
                                              .toList()[x]['altMobile']
                                              .toString() !=
                                          '')
                                    Text(
                                      allShipAddresses
                                          .toList()[x]['altMobile']
                                          .toString(),
                                      style:
                                          const TextStyle(color: Colors.grey),
                                    ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right,
                              color: Colors.blue,
                              size: 30,
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        color: Colors.grey[900],
                      )
                    ]),
                  );
                },
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isDoneLoading)
                    Center(
                      child: Text(
                        'No Record',
                        style: TextStyle(
                          color: Colors.red[300],
                        ),
                      ),
                    ),
                  if (isDoneLoading == false)
                    const Center(
                      child: CircularProgressIndicator(),
                    ),
                ],
              ));
  }

  Container titleSection() {
    return Container(
      margin: const EdgeInsets.all(0.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Shipping Address",
            style: TextStyle(
                color: Colors.black,
                fontSize: 25.0,
                fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context)
                  .pushNamed(RouteManager.updateShipAddress, arguments: {
                'token': widget.token,
                'calling': 'addShipAddress',
                'shipAddressId': '',
                'shipRecord': '',
              });
            },
            iconSize: 40.0,
            color: Colors.black,
          )
        ],
      ),
    );
  }
}

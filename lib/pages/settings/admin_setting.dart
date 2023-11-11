import 'package:eshopper_mobile_app/componets/data_computation.dart';
import 'package:eshopper_mobile_app/routes/routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AdminSetting extends StatefulWidget {
  final String token;
  AdminSetting({required this.token});
  @override
  _AdminSettingState createState() => _AdminSettingState();
}

class _AdminSettingState extends State<AdminSetting> {
  @override
  void initState() {
    super.initState();
    initializingFunctionCall();
  }

  String storeId = "0";
  List storeMenuList = [];
  bool isActiveSwitch = false;

  initializingFunctionCall() async {
    var serviceProvider = Provider.of<DataProcessing>(context, listen: false);
    var response = await serviceProvider.adminSetting(
      widget.token,
      '',
      '',
      '',
      '',
    );
    if (response['isSuccess'] == true) {
      setState(() {
        storeMenuList = response['storeData'];
      });
    }
  }

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
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.red,
                          ),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Store Verification',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              dropdownMenu(),
                              Container(
                                child: Row(
                                  children: [
                                    CupertinoSwitch(
                                      value: isActiveSwitch,
                                      activeColor: Colors.blueAccent.shade700,
                                      onChanged: (newValue) async {
                                        print(isActiveSwitch);
                                        setState(() {
                                          isActiveSwitch = newValue;
                                        });

                                        if (storeId != '0') {
                                          // CALL THE DIALOG TO PREVENT USER FROM THE UI UNTIL DATA IS SAVED TO THE SERVER
                                          setState(() {
                                            serviceProvider.isLoadDialogBox =
                                                true;
                                            serviceProvider
                                                .buildShowDialog(context);
                                          });

                                          var response = await serviceProvider
                                              .adminSetting(
                                            widget.token,
                                            isActiveSwitch,
                                            storeId,
                                            'updateBtn',
                                            '',
                                          );

                                          // CALL THE DIALOG TO ALLOW USER PERFORM OPERATION ON THE UI

                                          serviceProvider.isLoadDialogBox =
                                              false;
                                          serviceProvider
                                              .buildShowDialog(context);

                                          if (response['isSuccess'] == true) {
                                            setState(() {
                                              storeMenuList =
                                                  response['storeData'];
                                            });
                                            serviceProvider
                                                .toastMessage('Success');
                                          } else {
                                            serviceProvider.popWarningErrorMsg(
                                                context,
                                                'Error',
                                                response['errorMsg']
                                                    .toString());
                                          }
                                        } else {
                                          serviceProvider.warningToastMassage(
                                              'Select a valid store');
                                          isActiveSwitch = false;
                                        }
                                      },
                                    ),
                                    Text(
                                      'Verify\nStore',
                                      style: GoogleFonts.sora().copyWith(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      height: 8.0,
                    ),
                    // PRODUCT CATEGORY SETUP LINK
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.lightBlue,
                          ),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10))),
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).pushNamed(
                              RouteManager.categorySetup,
                              arguments: {
                                'token': widget.token,
                                'call': 'category',
                              });
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Product Category',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              ),
                            ),
                            SizedBox(
                              height: 5.0,
                            ),
                            Text(
                              'Edit or add product category',
                              style: TextStyle(
                                fontWeight: FontWeight.w100,
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 8.0,
                    ),

                    // PRODUCT BRAND SETUP LINK
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.lightBlue,
                          ),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10))),
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context)
                              .pushNamed(RouteManager.brandSetup, arguments: {
                            'token': widget.token,
                            'call': 'brand',
                          });
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Product Brand',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              ),
                            ),
                            SizedBox(
                              height: 5.0,
                            ),
                            Text(
                              'Edit or add product brand',
                              style: TextStyle(
                                fontWeight: FontWeight.w100,
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 8.0,
                    ),

                    // COMPANY ADDRESS SETUP LINK
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.lightBlue,
                          ),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10))),
                      child: InkWell(
                        onTap: () {},
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Company Address',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              ),
                            ),
                            SizedBox(
                              height: 5.0,
                            ),
                            Text(
                              'Address will display on the waybill & invoice',
                              style: TextStyle(
                                fontWeight: FontWeight.w100,
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  Container titleSection() {
    return Container(
      margin: const EdgeInsets.all(0.0),
      child: Row(
        children: const [
          Text(
            "Admin Setting",
            style: TextStyle(
                color: Colors.black,
                fontSize: 25.0,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // ===== DROP DOWN MENU LIST FOR LIST OF STORES =========
  Container dropdownMenu() {
    var serviceProvider = Provider.of<DataProcessing>(context);
    return Container(
      child: Expanded(
        child: DropdownButton(
            isExpanded: true,
            value: storeId,
            onChanged: (newValue) async {
              setState(() {
                storeId = newValue!.toString();
              });

              if (storeId == '0') {
                serviceProvider.warningToastMassage('Select a valid store!');
              }
            },
            items: storeMenuList.map((itmList) {
              return DropdownMenuItem(
                onTap: () {
                  setState(() {
                    isActiveSwitch = itmList['verified'];
                  });
                },
                child: Text(
                  itmList['name'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Color(0xFF2962FF),
                  ),
                ),
                value: itmList['id'].toString(),
              );
            }).toList()),
      ),
    );
  }

  Container contentDetail(String id, category) {
    return Container(
      child: Column(
        children: [
          AlertDialog(
            scrollable: true,
            title: Text(
              'Product Category',
              style: GoogleFonts.sora().copyWith(fontWeight: FontWeight.bold),
            ),
            content: Text(category),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.grey)),
                  ),
                  ElevatedButton(
                    child: const Text('Update'),
                    onPressed: () async {},
                  )
                ],
              )
            ],
          ),
        ],
      ),
    );
  }
}

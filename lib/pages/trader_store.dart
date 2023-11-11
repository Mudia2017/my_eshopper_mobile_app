import 'package:eshopper_mobile_app/componets/data_computation.dart';
import 'package:eshopper_mobile_app/componets/side_drawer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class TraderStore extends StatefulWidget {
  final token, userId;
  TraderStore({required this.token, required this.userId});
  @override
  _TraderStoreState createState() => _TraderStoreState();
}

class _TraderStoreState extends State<TraderStore> {
  @override
  void initState() {
    super.initState();
    initializingFunctionCall(widget.token, widget.userId, '', '', '');
  }

  bool isAdminSwitch = false;
  bool isActiveSwitch = true;
  var counter = 0;
  bool isCompleteLoading = false;
  bool isLoadingError = false;
  String selectStore = "Select Store";
  bool isDropdownButton = false;
  List storeMenuList = [];
  bool isUpdateRequest = false;
  int storeDbId = 0;

  void initializingFunctionCall(
      token, userId, storeRecord, isActive, action) async {
    var serviceProvider = Provider.of<DataProcessing>(context, listen: false);
    var response = await serviceProvider.traderStore(
        token, userId, storeRecord, isActive, action);

    setState(() {
      counter = response['counter'];
      isCompleteLoading = response['isCompleteLoading'];
      isLoadingError = response['isLoadingError'];
      storeMenuList = response['storeMenuList'];
    });
  }

  storeRecord(name, address, city, lga, state, email, mobile, altMobile) {
    var storeInfo = {
      'userId': widget.userId,
      'storeName': name,
      'storeAddress': address,
      'city': city,
      'LGA': lga,
      'state': state,
      'email': email,
      'mobile': mobile,
      'altMobile': altMobile,
      'storeDbId': storeDbId,
      'isActiveSwitch': isActiveSwitch,
    };
    return storeInfo;
  }

  // List<Map> _myJson = [
  //   {'id': 0, 'name': '<New>'},
  //   {'id': 1, 'name': 'Test Practice'}
  // ];

  // ===== DROP DOWN MENU LIST FOR USER LIST OF STORES =========
  Container dropdownMenu() {
    var serviceProvider = Provider.of<DataProcessing>(context);
    return Container(
      height: 50,
      child: DropdownButton(
          isExpanded: true,
          value: selectStore,
          onChanged: (newValue) async {
            setState(() {
              selectStore = newValue!.toString();
            });
            if (selectStore != 'Select Store') {
              // QUERY THE DATABASE TO GET RECORD OF STORE SELECTED AND
              // DISPLAY THEM ON THE TEXT-EDIT-FORM FIELD FOR THE USER TO UPDATE

              // CALL THE DIALOG TO PREVENT USER FROM THE UI UNTIL DATA IS SAVED TO THE SERVER
              setState(() {
                serviceProvider.isLoadDialogBox = true;
                serviceProvider.buildShowDialog(context);
              });

              var response = await serviceProvider.traderStore(
                  widget.token, widget.userId, selectStore, '', 'updateStore');

              // CALL THE DIALOG TO ALLOW USER PERFORM OPERATION ON THE UI

              serviceProvider.isLoadDialogBox = false;
              serviceProvider.buildShowDialog(context);

              if (response['response'] == 'storeRecordPulled') {
                // DISPLAY THE RESPONSE FROM DB ON THE TEXT FORM FIELD
                // FOR USER TO EDIT AND UPDATE
                var storeData = response['storeData'];

                storeNameController.text = storeData['storeName'];
                storeAddressController.text = storeData['storeAddress'];
                storeCityController.text = storeData['city'];
                storeLGAController.text = storeData['LGA'];
                storeStateController.text = storeData['state'];
                storeEmailController.text = storeData['email'];
                storeMobileController.text = storeData['mobile'];
                storeAltMobileController.text = storeData['altMobile'];
                isActiveSwitch = storeData['isActive'];
                storeDbId = storeData['id'];
                isAdminSwitch = storeData['isVerified'];
                setState(() {
                  counter = 0;
                  isUpdateRequest = true;
                });
              } else if (response['response'] == 'errorPullingStoreRecord') {
                serviceProvider
                    .warningToastMassage('Error\n${response['serverMsg']}');
              }
            } else if (selectStore == 'Select Store') {
              // POP A DIALOG BOX FOR ADMIN TO GIVE REASON FOR CLOSING AN ORDER
              serviceProvider.warningToastMassage('Select a valid store!');
            }
          },
          items: storeMenuList.map((itmList) {
            return DropdownMenuItem(
              child: Text(
                itmList,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Color(0xFF2962FF),
                ),
              ),
              value: itmList,
            );
          }).toList()

          // _myJson.map((Map map) {
          //   return DropdownMenuItem<String>(
          //     value: map['id'].toString(),
          //     child: Text(
          //       map['name'],
          //     ),
          //   );
          // }).toList(),
          ),
    );
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
            // height: MediaQuery.of(context).size.height,
            // width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF40C4FF),
                  Color(0xFFA7FFEB),
                ],
              ),
            ),
            child: isCompleteLoading
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (counter == 0) activeButton(),
                      const Divider(
                        color: Colors.black87,
                      ),
                      if (counter == 0)
                        Expanded(
                          child: ListView(
                            children: [
                              textFieldLayout(),
                              const SizedBox(
                                height: 40,
                              ),
                              if (isUpdateRequest == false) saveButton(),
                              if (isUpdateRequest == true) updateButton(),
                              const SizedBox(
                                height: 12,
                              ),
                            ],
                          ),
                        ),
                      if (counter > 0)
                        Expanded(child: optionToAddOrUpdateStore()),
                    ],
                  )
                : Center(child: CircularProgressIndicator())),
      ),
    );
  }

  Container appBarTitle() {
    return Container(
      margin: const EdgeInsets.all(0.0),
      child: Column(
        children: [
          if (counter == 0 && isUpdateRequest == false)
            const Text(
              "Trader Store - Add",
              style: TextStyle(
                color: Colors.black,
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          if (counter > 0)
            const Text(
              "Trader Store",
              style: TextStyle(
                color: Colors.black,
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          if (counter == 0 && isUpdateRequest == true)
            const Text(
              "Trader Store - Update",
              style: TextStyle(
                color: Colors.black,
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }

  Container activeButton() {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            child: Row(
              children: [
                CupertinoSwitch(
                  value: isAdminSwitch,
                  onChanged: null,
                  activeColor: Colors.blueAccent.shade700,
                ),
                Column(
                  children: [
                    Text(
                      'Verified Store',
                      style: GoogleFonts.sora().copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black38,
                      ),
                    ),
                    Text(
                      '(Verify by Admin)',
                      style: GoogleFonts.sora().copyWith(
                        fontSize: 9,
                        color: Colors.black38,
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
          Container(
            child: Row(
              children: [
                CupertinoSwitch(
                  value: isActiveSwitch,
                  activeColor: Colors.blueAccent.shade700,
                  onChanged: (newValue) {
                    setState(() {
                      isActiveSwitch = newValue;
                    });

                    // _value = newValue;
                  },
                ),
                Text(
                  'Active',
                  style: GoogleFonts.sora()
                      .copyWith(fontSize: 12, fontWeight: FontWeight.bold),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  TextEditingController storeNameController = TextEditingController();
  TextEditingController storeAddressController = TextEditingController();
  TextEditingController storeCityController = TextEditingController();
  TextEditingController storeLGAController = TextEditingController();
  TextEditingController storeStateController = TextEditingController();
  TextEditingController storeEmailController = TextEditingController();
  TextEditingController storeMobileController = TextEditingController();
  TextEditingController storeAltMobileController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Container textFieldLayout() {
    return Container(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              keyboardType: TextInputType.name,
              controller: storeNameController,
              decoration: InputDecoration(
                labelText: 'Store Name',
                hintStyle: GoogleFonts.sora().copyWith(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Store name is required';
                }
                return null;
              },
            ),

            // ====== STORE ADDRESS FIELD =====
            TextFormField(
              keyboardType: TextInputType.name,
              controller: storeAddressController,
              decoration: InputDecoration(
                labelText: 'Store Address',
                hintStyle: GoogleFonts.sora().copyWith(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Store address is required';
                }
                return null;
              },
            ),

            // ======== CITY FIELD ==========
            TextFormField(
              keyboardType: TextInputType.name,
              controller: storeCityController,
              decoration: InputDecoration(
                labelText: 'City',
                hintStyle: GoogleFonts.sora().copyWith(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'City field is required';
                }
                return null;
              },
            ),

            // ======== LOCAL GOVERNMENT AREA FIELD ========
            TextFormField(
              keyboardType: TextInputType.name,
              controller: storeLGAController,
              decoration: InputDecoration(
                labelText: 'Local Government Area',
                hintStyle: GoogleFonts.sora().copyWith(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Local government area is required';
                }
                return null;
              },
            ),

            // =========== STATE FIELD ==========
            TextFormField(
              keyboardType: TextInputType.name,
              controller: storeStateController,
              decoration: InputDecoration(
                labelText: 'State',
                hintStyle: GoogleFonts.sora().copyWith(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'State field is required';
                }
                return null;
              },
            ),

            // ======= EMAIL FIELD =========
            TextFormField(
              keyboardType: TextInputType.emailAddress,
              controller: storeEmailController,
              decoration: InputDecoration(
                labelText: 'Email',
                hintStyle: GoogleFonts.sora().copyWith(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Email is required';
                }
                return null;
              },
            ),

            // ====== MOBILE FIELD =======
            TextFormField(
              keyboardType: TextInputType.phone,
              controller: storeMobileController,
              decoration: InputDecoration(
                labelText: 'Mobile',
                hintStyle: GoogleFonts.sora().copyWith(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Mobile number is required';
                }
                return null;
              },
            ),

            // ======= ALTERNATIVE MOBILE FIELD =========
            TextField(
              keyboardType: TextInputType.phone,
              controller: storeAltMobileController,
              decoration: InputDecoration(
                labelText: 'Alt Mobile',
                hintStyle: GoogleFonts.sora().copyWith(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container saveButton() {
    var serviceProvider = Provider.of<DataProcessing>(context);
    return Container(
      child: Row(
        children: [
          Expanded(
            child: MaterialButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  // CALL THE DIALOG TO PREVENT USER FROM THE UI UNTIL DATA IS SAVED TO THE SERVER
                  setState(() {
                    serviceProvider.isLoadDialogBox = true;
                    serviceProvider.buildShowDialog(context);
                  });

                  var response = await serviceProvider.traderStore(
                      widget.token,
                      widget.userId,
                      storeRecord(
                        storeNameController.text,
                        storeAddressController.text,
                        storeCityController.text,
                        storeLGAController.text,
                        storeStateController.text,
                        storeEmailController.text,
                        storeMobileController.text,
                        storeAltMobileController.text,
                      ),
                      isActiveSwitch,
                      'addStore');

                  // CALL THE DIALOG TO ALLOW USER PERFORM OPERATION ON THE UI

                  serviceProvider.isLoadDialogBox = false;
                  serviceProvider.buildShowDialog(context);

                  if (response['response'] == 'storeCreated') {
                    storeNameController.clear();
                    storeAddressController.clear();
                    storeCityController.clear();
                    storeLGAController.clear();
                    storeStateController.clear();
                    storeEmailController.clear();
                    storeMobileController.clear();
                    storeAltMobileController.clear();
                    isActiveSwitch = true;

                    serviceProvider.toastMessage('Store saved successful');
                  } else if (response['response'] == 'storeAlreadyExist') {
                    serviceProvider.popWarningErrorMsg(
                        context,
                        'Warning Message',
                        'Store was not saved.\nStore name already exist in the system');
                  } else if (response['response'] == 'errorCreatingStore') {
                    serviceProvider.popWarningErrorMsg(context, 'Error Message',
                        'Store not saved!\nError creating store\n${response['serverMsg']}');
                  }
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    'Save',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Icon(
                    Icons.save_alt,
                    size: 50,
                    color: Colors.black,
                  ),
                ],
              ),
              color: Colors.orange.shade300,
              height: 45,
            ),
          ),
        ],
      ),
    );
  }

  Container updateButton() {
    var serviceProvider = Provider.of<DataProcessing>(context);
    return Container(
      child: Row(
        children: [
          Expanded(
            child: MaterialButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  // CALL THE DIALOG TO PREVENT USER FROM THE UI UNTIL DATA IS SAVED TO THE SERVER
                  setState(() {
                    serviceProvider.isLoadDialogBox = true;
                    serviceProvider.buildShowDialog(context);
                  });

                  FocusManager.instance.primaryFocus?.unfocus();
                  FocusScope.of(context)
                      .requestFocus(FocusNode()); //remove focus

                  var response = await serviceProvider.traderStore(
                      widget.token,
                      widget.userId,
                      storeRecord(
                        storeNameController.text,
                        storeAddressController.text,
                        storeCityController.text,
                        storeLGAController.text,
                        storeStateController.text,
                        storeEmailController.text,
                        storeMobileController.text,
                        storeAltMobileController.text,
                      ),
                      isActiveSwitch,
                      'updateButton');

                  // CALL THE DIALOG TO ALLOW USER PERFORM OPERATION ON THE UI

                  serviceProvider.isLoadDialogBox = false;
                  serviceProvider.buildShowDialog(context);

                  if (response['response'] == 'storeUpdateSuccessful') {
                    storeNameController.clear();
                    storeAddressController.clear();
                    storeCityController.clear();
                    storeLGAController.clear();
                    storeStateController.clear();
                    storeEmailController.clear();
                    storeMobileController.clear();
                    storeAltMobileController.clear();
                    isActiveSwitch = true;
                    storeDbId = 0;
                    setState(() {
                      counter = 0;
                      isUpdateRequest = false;
                    });
                    serviceProvider
                        .toastMessage('Store Record Update Successful');
                  } else if (response['response'] == 'storeNotUpdated') {
                    serviceProvider.popWarningErrorMsg(context, 'Error Message',
                        'An error occured.\n${response['serverMsg']}');
                  }
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    'Update',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Icon(
                    Icons.save_alt,
                    size: 50,
                    color: Colors.black,
                  ),
                ],
              ),
              color: Colors.orange.shade300,
              height: 45,
            ),
          ),
        ],
      ),
    );
  }

  Container optionToAddOrUpdateStore() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Text(
              'Do you want to add a new store or update an existing store?',
              style: GoogleFonts.sora().copyWith(fontSize: 18),
            ),
          ),
          const SizedBox(
            height: 60,
          ),
          if (isDropdownButton == true) dropdownMenu(),
          const SizedBox(
            height: 60,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              MaterialButton(
                onPressed: () async {
                  setState(() {
                    counter = 0;
                    selectStore = 'Select Store';
                  });
                },
                child: const Text(
                  'Add Store',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                  ),
                ),
                color: Colors.blue.shade300,
                height: 45,
              ),
              MaterialButton(
                onPressed: () async {
                  setState(() {
                    isDropdownButton = true;
                  });
                },
                child: const Text(
                  'Update Store',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                  ),
                ),
                color: Colors.orange.shade200,
                height: 45,
              ),
            ],
          )
        ],
      ),
    );
  }
}

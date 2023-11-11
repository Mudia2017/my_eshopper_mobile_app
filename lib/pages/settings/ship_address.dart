import 'package:eshopper_mobile_app/componets/data_computation.dart';
import 'package:eshopper_mobile_app/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ShipAddress extends StatefulWidget {
  final token, calling, shipAddressId, shipRecord;
  ShipAddress({
    required this.token,
    required this.calling,
    required this.shipAddressId,
    required this.shipRecord,
  });
  @override
  _ShipAddressState createState() => _ShipAddressState();
}

class _ShipAddressState extends State<ShipAddress> {
  @override
  void initState() {
    super.initState();
    if (widget.calling == 'updateShipAddress') {
      updateFields();
      // initializingFunctionCall(
      //   widget.token,
      //   widget.shipAddressId,
      //   'updateShipAddress',
      // );
    } else if (widget.calling == 'addShipAddress') {
      print('NEW SHIP ADDRESS');
    }
  }

  // initializingFunctionCall(token, shipAddId, call) async {
  //   var serviceProvider = Provider.of<DataProcessing>(context, listen: false);
  //   var response =
  //       await serviceProvider.updateCustomerAddress(token, shipAddId, call);
  //   print(widget.shipRecord['name']);
  // }

  updateFields() {
    nameController.text = widget.shipRecord['name'];
    addressController.text = widget.shipRecord['address'];
    cityController.text = widget.shipRecord['city'];
    stateController.text = widget.shipRecord['state'];
    if (widget.shipRecord['zipcode'] != 'null') {
      zipcodeController.text = widget.shipRecord['zipcode'];
    }
    mobileController.text = widget.shipRecord['mobile'];
    if (widget.shipRecord['altMobile'] != 'null') {
      altMobileController.text = widget.shipRecord['altMobile'];
    }
  }

  getAddressRecord(name, address, city, state, zipcode, mobile, altMobile) {
    var addressInfo = {
      'name': name,
      'address': address,
      'city': city,
      'state': state,
      'zipcode': zipcode,
      'mobile': mobile,
      'altMobile': altMobile,
    };
    return addressInfo;
  }

  @override
  Widget build(BuildContext context) {
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
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(
          children: [
            Expanded(
                child: ListView(
              children: [
                const SizedBox(
                  height: 5.0,
                ),
                textFieldLayout(),
                const SizedBox(
                  height: 40,
                ),
                if (widget.calling == 'addShipAddress') saveButton(),
                if (widget.calling == 'updateShipAddress') updateButton(),
              ],
            ))
          ],
        ),
      ),
    );
  }

  Container titleSection() {
    return Container(
      margin: const EdgeInsets.all(0.0),
      child: Row(
        children: [
          if (widget.calling == 'addShipAddress')
            const Text(
              "Add Address",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 25.0,
                  fontWeight: FontWeight.bold),
            ),
          if (widget.calling == 'updateShipAddress')
            const Text(
              "Update Address",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 25.0,
                  fontWeight: FontWeight.bold),
            ),
        ],
      ),
    );
  }

  TextEditingController nameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController zipcodeController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController altMobileController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Container textFieldLayout() {
    return Container(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              keyboardType: TextInputType.name,
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                hintStyle: GoogleFonts.sora().copyWith(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return ' Name is required';
                }
                return null;
              },
            ),

            // ====== ADDRESS FIELD =====
            TextFormField(
              keyboardType: TextInputType.name,
              controller: addressController,
              decoration: InputDecoration(
                labelText: 'Address',
                hintStyle: GoogleFonts.sora().copyWith(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Field is required';
                }
                return null;
              },
            ),

            // ======== CITY FIELD ==========
            TextFormField(
              keyboardType: TextInputType.name,
              controller: cityController,
              decoration: InputDecoration(
                labelText: 'City',
                hintStyle: GoogleFonts.sora().copyWith(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Field is required';
                }
                return null;
              },
            ),

            // ======== STATE FIELD ========
            TextFormField(
              keyboardType: TextInputType.name,
              controller: stateController,
              decoration: InputDecoration(
                labelText: 'State',
                hintStyle: GoogleFonts.sora().copyWith(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Field is required';
                }
                return null;
              },
            ),

            // =========== ZIPCODE FIELD ==========
            TextFormField(
              keyboardType: TextInputType.phone,
              controller: zipcodeController,
              decoration: InputDecoration(
                labelText: 'Zipcode',
                hintStyle: GoogleFonts.sora().copyWith(),
              ),
            ),

            // ======= MOBILE FIELD =========
            TextFormField(
              keyboardType: TextInputType.phone,
              controller: mobileController,
              decoration: InputDecoration(
                labelText: 'Mobile',
                hintStyle: GoogleFonts.sora().copyWith(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Field is required';
                }
                return null;
              },
            ),

            // ====== ALTERNATIVE MOBILE FIELD =======
            TextFormField(
              keyboardType: TextInputType.phone,
              controller: altMobileController,
              decoration: InputDecoration(
                labelText: 'AltMobile',
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

                  FocusManager.instance.primaryFocus?.unfocus();
                  FocusScope.of(context)
                      .requestFocus(FocusNode()); //remove focus

                  var response = await serviceProvider.updateCustomerAddress(
                    widget.token,
                    widget.shipAddressId,
                    'addShipAddress',
                    getAddressRecord(
                      nameController.text,
                      addressController.text,
                      cityController.text,
                      stateController.text,
                      zipcodeController.text,
                      mobileController.text,
                      altMobileController.text,
                    ),
                  );

                  // CALL THE DIALOG TO ALLOW USER PERFORM OPERATION ON THE UI

                  serviceProvider.isLoadDialogBox = false;
                  serviceProvider.buildShowDialog(context);

                  if (response['isSuccess'] == true) {
                    Navigator.of(context).pop(context);
                    Navigator.of(context).popAndPushNamed(
                      RouteManager.allShipAddress,
                      arguments: {
                        'token': widget.token,
                      },
                    );
                    serviceProvider.toastMessage('Success');
                  } else {
                    serviceProvider.popWarningErrorMsg(
                        context, 'Error', response['errorMsg'].toString());
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

                  var response = await serviceProvider.updateCustomerAddress(
                    widget.token,
                    widget.shipAddressId,
                    'updateShipAddress',
                    getAddressRecord(
                      nameController.text,
                      addressController.text,
                      cityController.text,
                      stateController.text,
                      zipcodeController.text,
                      mobileController.text,
                      altMobileController.text,
                    ),
                  );

                  // CALL THE DIALOG TO ALLOW USER PERFORM OPERATION ON THE UI

                  serviceProvider.isLoadDialogBox = false;
                  serviceProvider.buildShowDialog(context);

                  if (response['isSuccess'] == true) {
                    Navigator.of(context).pop(context);
                    Navigator.of(context).popAndPushNamed(
                      RouteManager.allShipAddress,
                      arguments: {
                        'token': widget.token,
                      },
                    );
                    serviceProvider.toastMessage('Success');
                  } else {
                    serviceProvider.popWarningErrorMsg(
                        context, 'Error', response['errorMsg'].toString());
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
}

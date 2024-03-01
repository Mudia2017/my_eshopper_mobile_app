import 'dart:convert';
import 'dart:io';

import 'package:eshopper_mobile_app/componets/data_computation.dart';
import 'package:eshopper_mobile_app/routes/routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class EditProduct extends StatefulWidget {
  final String token, ptdId, userId;
  EditProduct({required this.token, required this.ptdId, required this.userId});
  @override
  _EditProductState createState() => _EditProductState();
}

class _EditProductState extends State<EditProduct> {
  @override
  void initState() {
    super.initState();
    initializingFunctionCall();
  }

  List categoryList = [];
  List brandList = [];
  List storeList = [];
  String selectCategoryId = '0';
  String selectBrand = '0';
  String selectStoreId = '0';
  String outOfStock = 'no';
  String imageUrl = '';
  String imageName = '';
  DateTime mfgDate = DateTime(0);
  DateTime expDate = DateTime(0);
  Map myEditableRecord = {};
  bool isDoneLoading = false;
  bool isErrorLoading = false;
  bool isExpDate = false;
  bool isMfgDate = false;
  // bool isChecked = false;
  bool isActivePtd = false;
  TextEditingController ptdNameController = TextEditingController();
  TextEditingController ptdDescriptionController = TextEditingController();
  TextEditingController ptdPriceController = TextEditingController();
  TextEditingController ptdDiscountController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  // ============= API CALL TO DISPLAY EDITABLE PRODUCT ============

  void initializingFunctionCall() async {
    var serviceProvider = Provider.of<DataProcessing>(context, listen: false);
    var response = await serviceProvider.getEditablePtd(
        widget.token, widget.ptdId, widget.userId, 'loadPage', []);

    ptdNameController.text =
        response['myEditableRecord']['ptdRecord']['ptdName'];
    ptdDescriptionController.text =
        response['myEditableRecord']['ptdRecord']['ptdDescription'];
    ptdPriceController.text =
        response['myEditableRecord']['ptdRecord']['price'];
    ptdDiscountController.text =
        response['myEditableRecord']['ptdRecord']['discount'];
    setState(() {
      categoryList =
          response['myEditableRecord']['ptdRecord']['categoryMenuList'];
      selectCategoryId =
          response['myEditableRecord']['ptdRecord']['ptdCagetoryId'].toString();
      brandList = response['myEditableRecord']['ptdRecord']['brandMenuList'];
      selectBrand =
          response['myEditableRecord']['ptdRecord']['ptdBrand'].toString();
      storeList = response['myEditableRecord']['ptdRecord']['storeMenuList'];
      selectStoreId =
          response['myEditableRecord']['ptdRecord']['store'].toString();
      isActivePtd = response['myEditableRecord']['ptdRecord']['active'];
      if (response['myEditableRecord']['ptdRecord']['out_of_stock'] == false) {
        outOfStock = 'no';
      } else if (response['myEditableRecord']['ptdRecord']['out_of_stock'] ==
          true) {
        outOfStock = 'yes';
      }
      if (response['myEditableRecord']['ptdRecord']['mfgDate'] != null) {
        mfgDate = DateTime.parse(
            response['myEditableRecord']['ptdRecord']['mfgDate']);
      }
      if (response['myEditableRecord']['ptdRecord']['expDate'] != null) {
        expDate = DateTime.parse(
            response['myEditableRecord']['ptdRecord']['expDate']);
      }
      imageUrl = response['myEditableRecord']['ptdRecord']['image'];
      imageName = response['myEditableRecord']['ptdRecord']['imageName'];
    });
    isDoneLoading = response['isDoneLoading'];
    isErrorLoading = response['isErrorLoading'];
    myEditableRecord = response['myEditableRecord']['ptdRecord'];
  }

  List<DropdownMenuItem<String>> get dropdownItems {
    List<DropdownMenuItem<String>> menuItems = [
      const DropdownMenuItem(
        child: Text(
          'No',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: Color(0xFF5D4037),
          ),
        ),
        value: 'no',
      ),
      const DropdownMenuItem(
        child: Text(
          'Yes',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: Color(0xFF5D4037),
          ),
        ),
        value: 'yes',
      ),
    ];
    return menuItems;
  }

  editPtd(name, desc, categoryId, brand, price, img, mfgDate, expDate, discount,
      outOfStock, storeId, bool active) {
    var editPrdRecord = {
      'name': name,
      'description': desc,
      'categoryId': categoryId,
      'brand': brand,
      'price': price,
      'imageName': img,
      'mfgDate': mfgDate,
      'expDate': expDate,
      'discount': discount,
      'outOfStock': getOutOfStock(outOfStock),
      'storeId': storeId,
      'isActive': active
    };
    return editPrdRecord;
  }

  getOutOfStock(outOfStock) {
    bool isOutOfStock = false;
    if (outOfStock == 'yes') {
      isOutOfStock = true;
    }
    return isOutOfStock;
  }

  @override
  Widget build(BuildContext context) {
    var serviceProvider = Provider.of<DataProcessing>(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: title(),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [
            Color(0xFF40C4FF),
            Color(0xFFA7FFEB),
          ])),
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
            myEditableRecord.isNotEmpty
                ? Expanded(
                    child: ListView(
                      children: [
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                keyboardType: TextInputType.name,
                                controller: ptdNameController,
                                decoration: InputDecoration(
                                  labelText: 'Product Name',
                                  hintStyle: GoogleFonts.sora().copyWith(),
                                ),
                                style: TextStyle(
                                  color: Colors.brown.shade700,
                                  fontSize: 12,
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Product name is required';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              Row(
                                children: const [
                                  Text(
                                    'Category',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Container(
                                  padding: const EdgeInsets.only(right: 12),
                                  height: 30,
                                  width: MediaQuery.of(context).size.width,
                                  child: DropdownButton(
                                    isExpanded: true,
                                    value: selectCategoryId,
                                    onChanged: (newValue) async {
                                      setState(() {
                                        selectCategoryId = newValue!.toString();
                                      });
                                    },
                                    items: categoryList.map((itemList) {
                                      return DropdownMenuItem(
                                        child: Text(
                                          itemList['category'],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10,
                                            color: Color(0xFF5D4037),
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        value: itemList['id'].toString(),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                              TextFormField(
                                keyboardType: TextInputType.multiline,
                                controller: ptdDescriptionController,
                                maxLines: 4,
                                decoration: InputDecoration(
                                  labelText: 'Product description',
                                  hintStyle: GoogleFonts.sora().copyWith(),
                                ),
                                style: TextStyle(
                                  color: Colors.brown.shade700,
                                  fontSize: 12,
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Product description is required';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Flexible(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Brand:',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.black54,
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 8,
                                        ),
                                        SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Container(
                                            height: 30,
                                            width: 200,
                                            child: DropdownButton(
                                              isExpanded: true,
                                              value: selectBrand,
                                              onChanged: (newValue) async {
                                                setState(() {
                                                  selectBrand =
                                                      newValue!.toString();
                                                });
                                              },
                                              items: brandList.map((itemList) {
                                                return DropdownMenuItem(
                                                  child: Text(
                                                    itemList['brand'],
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 10,
                                                      color: Color(0xFF5D4037),
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  value:
                                                      itemList['id'].toString(),
                                                );
                                              }).toList(),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Flexible(
                                    child: TextFormField(
                                      keyboardType: TextInputType.phone,
                                      controller: ptdPriceController,
                                      decoration: InputDecoration(
                                        labelText: 'Price',
                                        hintStyle:
                                            GoogleFonts.sora().copyWith(),
                                      ),
                                      style: TextStyle(
                                        color: Colors.brown.shade700,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Price is required';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Flexible(
                                    child: TextFormField(
                                      keyboardType: TextInputType.phone,
                                      controller: ptdDiscountController,
                                      style: TextStyle(
                                        color: Colors.brown.shade700,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      decoration: InputDecoration(
                                        labelText: 'Percentage discount off',
                                        hintStyle:
                                            GoogleFonts.sora().copyWith(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Store:',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.black54,
                                          ),
                                        ),
                                        SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Container(
                                            height: 30,
                                            width: 160,
                                            child: DropdownButton(
                                              isExpanded: true,
                                              value: selectStoreId,
                                              onChanged: (newValue) async {
                                                setState(() {
                                                  selectStoreId =
                                                      newValue!.toString();
                                                });
                                              },
                                              items: storeList.map((itemList) {
                                                return DropdownMenuItem(
                                                  child: Text(
                                                    itemList['store'],
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 10,
                                                      color: Color(0xFF5D4037),
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  value:
                                                      itemList['id'].toString(),
                                                );
                                              }).toList(),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  Flexible(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Out of Stock:',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.black54,
                                          ),
                                        ),
                                        DropdownButton(
                                          value: outOfStock,
                                          onChanged: (newValue) async {
                                            setState(() {
                                              outOfStock = newValue!.toString();
                                            });
                                          },
                                          items: dropdownItems,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Manufacture Date:',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.black54,
                                          ),
                                        ),
                                        if (myEditableRecord['mfgDate'] ==
                                                null &&
                                            isMfgDate == false)
                                          OutlinedButton(
                                            onPressed: () {
                                              _selectCupertinoDate('mfgDate');
                                            },
                                            child: const Text(''),
                                          ),
                                        if (myEditableRecord['mfgDate'] !=
                                                null ||
                                            isMfgDate == true)
                                          OutlinedButton(
                                            onPressed: () {
                                              _selectCupertinoDate('mfgDate');
                                            },
                                            child: Text(
                                              DateFormat('yyyy-MM-dd')
                                                  .format(mfgDate),
                                              style: TextStyle(
                                                color: Colors.brown.shade700,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Flexible(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Expire Date:',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.black54,
                                          ),
                                        ),
                                        if (myEditableRecord['expDate'] ==
                                                null &&
                                            isExpDate == false)
                                          OutlinedButton(
                                            onPressed: () {
                                              _selectCupertinoDate('expDate');
                                            },
                                            child: const Text(''),
                                          ),
                                        if (myEditableRecord['expDate'] !=
                                                null ||
                                            isExpDate == true)
                                          OutlinedButton(
                                            onPressed: () {
                                              _selectCupertinoDate('expDate');
                                            },
                                            child: Text(
                                              DateFormat('yyyy-MM-dd')
                                                  .format(expDate),
                                              style: TextStyle(
                                                color: Colors.brown.shade700,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  activeSwitchButton(),
                                  Container(
                                    child: Row(
                                      children: [
                                        if (imageUrl !=
                                                "${dotenv.env['URL_ENDPOINT']}" &&
                                            imageUrl != '')
                                          Column(
                                            children: [
                                              InkWell(
                                                child: const Icon(
                                                  Icons.cancel_sharp,
                                                ),
                                                onTap: () {
                                                  setState(() {
                                                    imageUrl = '';
                                                    imageName = '';
                                                  });
                                                },
                                              ),
                                              Image.network(
                                                imageUrl,
                                                height: 60,
                                                width: 60,
                                                fit: BoxFit.contain,
                                              ),
                                            ],
                                          ),
                                        if (imageFile != null)
                                          Column(
                                            children: [
                                              InkWell(
                                                child: const Icon(
                                                  Icons.cancel_sharp,
                                                ),
                                                onTap: () {
                                                  setState(() {
                                                    imageFile = null;
                                                  });
                                                },
                                              ),
                                              Image.file(
                                                imageFile!,
                                                fit: BoxFit.contain,
                                                width: 70,
                                                height: 100,
                                              ),
                                            ],
                                          ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        MaterialButton(
                                          onPressed: () {
                                            pickImage();
                                          },
                                          child: const Text(
                                            'Change Image File',
                                            style: TextStyle(
                                              fontSize: 10,
                                            ),
                                          ),
                                          color: Colors.grey,
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isDoneLoading == false)
                          const CircularProgressIndicator(),
                        if (isDoneLoading == true)
                          Text(
                            "No Record!",
                            style: TextStyle(
                                color: Colors.red[300],
                                fontWeight: FontWeight.bold),
                          ),
                        if (isErrorLoading == true)
                          Text(
                            "Error occured!",
                            style: TextStyle(
                                color: Colors.red[300],
                                fontWeight: FontWeight.bold),
                          ),
                      ],
                    ),
                  ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: MaterialButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate() &&
                          imageFile == null) {
                        if (selectStoreId == '0') {
                          serviceProvider.popWarningErrorMsg(context, 'Warning',
                              'Kindly select a store where item belong to before saving');
                        } else if (selectCategoryId == '0') {
                          serviceProvider.popWarningErrorMsg(context, 'Warning',
                              'Kindly select a category where item belong to before saving');
                        } else if (selectBrand == '0') {
                          serviceProvider.popWarningErrorMsg(context, 'Warning',
                              'Kindly select the brand of the item before saving');
                        } else if (imageUrl == '') {
                          var value = await serviceProvider
                              .popWarningConfirmActionYesNo(context, 'Warning',
                                  'You are about to save a product without an image! \nDo you want to continue?');
                          if (value == true) {
                            // CALL THE DIALOG TO PREVENT USER FROM THE UI UNTIL DATA IS SAVED TO THE SERVER
                            setState(() {
                              serviceProvider.isLoadDialogBox = true;
                              serviceProvider.buildShowDialog(context);
                            });

                            var response = await serviceProvider.getEditablePtd(
                              widget.token,
                              widget.ptdId,
                              widget.userId,
                              'updateBtn',
                              editPtd(
                                  ptdNameController.text,
                                  ptdDescriptionController.text,
                                  selectCategoryId,
                                  selectBrand,
                                  ptdPriceController.text,
                                  imageName,
                                  DateFormat('yyyy-MM-dd').format(mfgDate),
                                  DateFormat('yyyy-MM-dd').format(expDate),
                                  ptdDiscountController.text,
                                  outOfStock,
                                  selectStoreId,
                                  isActivePtd),
                            );

                            // CALL THE DIALOG TO ALLOW USER PERFORM OPERATION ON THE UI

                            serviceProvider.isLoadDialogBox = false;
                            serviceProvider.buildShowDialog(context);

                            if (response['myEditableRecord']['serverMsg'] ==
                                'success') {
                              Navigator.of(context).popAndPushNamed(
                                  RouteManager.productOverview,
                                  arguments: {
                                    'token': widget.token,
                                    'userId': widget.userId
                                  });
                              serviceProvider.toastMessage('Successful');
                            } else if (response['myEditableRecord']
                                    ['serverMsg'] ==
                                'failed') {
                              serviceProvider.popWarningErrorMsg(
                                context,
                                'Error message',
                                (response['myEditableRecord']['errorMsg'])
                                    .toString(),
                              );
                            }
                          }
                        } else {
                          // CALL THE DIALOG TO PREVENT USER FROM THE UI UNTIL DATA IS SAVED TO THE SERVER
                          setState(() {
                            serviceProvider.isLoadDialogBox = true;
                            serviceProvider.buildShowDialog(context);
                          });

                          var response = await serviceProvider.getEditablePtd(
                            widget.token,
                            widget.ptdId,
                            widget.userId,
                            'updateBtn',
                            editPtd(
                                ptdNameController.text,
                                ptdDescriptionController.text,
                                selectCategoryId,
                                selectBrand,
                                ptdPriceController.text,
                                imageName,
                                DateFormat('yyyy-MM-dd').format(mfgDate),
                                DateFormat('yyyy-MM-dd').format(expDate),
                                ptdDiscountController.text,
                                outOfStock,
                                selectStoreId,
                                isActivePtd),
                          );

                          // CALL THE DIALOG TO ALLOW USER PERFORM OPERATION ON THE UI

                          serviceProvider.isLoadDialogBox = false;
                          serviceProvider.buildShowDialog(context);

                          if (response['myEditableRecord']['serverMsg'] ==
                              'success') {
                            Navigator.of(context).popAndPushNamed(
                                RouteManager.productOverview,
                                arguments: {
                                  'token': widget.token,
                                  'userId': widget.userId
                                });
                            serviceProvider.toastMessage('Successful');
                          } else if (response['myEditableRecord']
                                  ['serverMsg'] ==
                              'failed') {
                            serviceProvider.popWarningErrorMsg(
                              context,
                              'Error message',
                              (response['myEditableRecord']['errorMsg'])
                                  .toString(),
                            );
                          }
                        }
                      } else if (_formKey.currentState!.validate() &&
                          imageFile != null)
                      // === THERE IS A CHANGE OF IMAGE. IMAGE FILE
                      // HAVE TO BE UPLOADED. I AM CREATING ANOTHER
                      // FUNCTION TO CARRY OUT THIS OPERATION.
                      {
                        if (selectCategoryId == '0') {
                          serviceProvider.popWarningErrorMsg(context, 'Warning',
                              'Kindly select a category where item belong to before saving');
                        } else if (selectStoreId == '0') {
                          serviceProvider.popWarningErrorMsg(context, 'Warning',
                              'Kindly select a store where item belong to before saving');
                        } else if (selectBrand == '0') {
                          serviceProvider.popWarningErrorMsg(context, 'Warning',
                              'Kindly select the brand of the item before saving');
                        } else {
                          // CALL THE DIALOG TO PREVENT USER FROM THE UI UNTIL DATA IS SAVED TO THE SERVER
                          setState(() {
                            serviceProvider.isLoadDialogBox = true;
                            serviceProvider.buildShowDialog(context);
                          });

                          var response = await serviceProvider.editPtdImage(
                              widget.token,
                              widget.ptdId,
                              widget.userId,
                              'editImgRequest',
                              ptdNameController.text,
                              ptdDescriptionController.text,
                              selectCategoryId,
                              selectBrand,
                              ptdPriceController.text,
                              DateFormat('yyyy-MM-dd').format(mfgDate),
                              DateFormat('yyyy-MM-dd').format(expDate),
                              ptdDiscountController.text,
                              outOfStock,
                              selectStoreId,
                              isActivePtd,
                              imageFile!);

                          // CALL THE DIALOG TO ALLOW USER PERFORM OPERATION ON THE UI

                          serviceProvider.isLoadDialogBox = false;
                          serviceProvider.buildShowDialog(context);

                          if (response == '"success"') {
                            Navigator.of(context).popAndPushNamed(
                                RouteManager.productOverview,
                                arguments: {
                                  'token': widget.token,
                                  'userId': widget.userId
                                });
                            serviceProvider.toastMessage('Successful');
                          } else {
                            serviceProvider.popWarningErrorMsg(
                              context,
                              'Error message',
                              (response).toString(),
                            );
                            // serviceProvider.warningToastMassage('Failed');
                          }
                        }
                      }
                    },
                    child: const Text(
                      'Save',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                    color: Colors.orange[400],
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6.0)),
                  ),
                ),
                Flexible(
                  child: MaterialButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate() &&
                          imageFile == null) {
                        if (selectStoreId == '0') {
                          serviceProvider.popWarningErrorMsg(context, 'Warning',
                              'Kindly select a store where item belong to before saving');
                        } else if (selectCategoryId == '0') {
                          serviceProvider.popWarningErrorMsg(context, 'Warning',
                              'Kindly select a category where item belong to before saving');
                        } else if (selectBrand == '0') {
                          serviceProvider.popWarningErrorMsg(context, 'Warning',
                              'Kindly select the brand of the item before saving');
                        } else if (imageUrl == '') {
                          var value = await serviceProvider
                              .popWarningConfirmActionYesNo(context, 'Warning',
                                  'You are about to save a product without an image! \nDo you want to continue?');
                          if (value == true) {
                            // CALL THE DIALOG TO PREVENT USER FROM THE UI UNTIL DATA IS SAVED TO THE SERVER
                            setState(() {
                              serviceProvider.isLoadDialogBox = true;
                              serviceProvider.buildShowDialog(context);
                            });

                            var response = await serviceProvider.getEditablePtd(
                              widget.token,
                              widget.ptdId,
                              widget.userId,
                              'updateBtn',
                              editPtd(
                                  ptdNameController.text,
                                  ptdDescriptionController.text,
                                  selectCategoryId,
                                  selectBrand,
                                  ptdPriceController.text,
                                  imageName,
                                  DateFormat('yyyy-MM-dd').format(mfgDate),
                                  DateFormat('yyyy-MM-dd').format(expDate),
                                  ptdDiscountController.text,
                                  outOfStock,
                                  selectStoreId,
                                  isActivePtd),
                            );

                            // CALL THE DIALOG TO ALLOW USER PERFORM OPERATION ON THE UI

                            serviceProvider.isLoadDialogBox = false;
                            serviceProvider.buildShowDialog(context);

                            if (response['myEditableRecord']['serverMsg'] ==
                                'success') {
                              Navigator.of(context).popAndPushNamed(
                                  RouteManager.addProduct,
                                  arguments: {
                                    'token': widget.token,
                                    'userId': widget.userId
                                  });
                              serviceProvider.toastMessage('Successful');
                            } else if (response['myEditableRecord']
                                    ['serverMsg'] ==
                                'failed') {
                              // serviceProvider.warningToastMassage('Failed');
                              serviceProvider.popWarningErrorMsg(
                                context,
                                'Error message',
                                (response['myEditableRecord']['errorMsg'])
                                    .toString(),
                              );
                            }
                          }
                        } else {
                          // CALL THE DIALOG TO PREVENT USER FROM THE UI UNTIL DATA IS SAVED TO THE SERVER
                          setState(() {
                            serviceProvider.isLoadDialogBox = true;
                            serviceProvider.buildShowDialog(context);
                          });

                          var response = await serviceProvider.getEditablePtd(
                            widget.token,
                            widget.ptdId,
                            widget.userId,
                            'updateBtn',
                            editPtd(
                                ptdNameController.text,
                                ptdDescriptionController.text,
                                selectCategoryId,
                                selectBrand,
                                ptdPriceController.text,
                                imageName,
                                DateFormat('yyyy-MM-dd').format(mfgDate),
                                DateFormat('yyyy-MM-dd').format(expDate),
                                ptdDiscountController.text,
                                outOfStock,
                                selectStoreId,
                                isActivePtd),
                          );

                          // CALL THE DIALOG TO ALLOW USER PERFORM OPERATION ON THE UI

                          serviceProvider.isLoadDialogBox = false;
                          serviceProvider.buildShowDialog(context);

                          if (response['myEditableRecord']['serverMsg'] ==
                              'success') {
                            Navigator.of(context).popAndPushNamed(
                                RouteManager.addProduct,
                                arguments: {
                                  'token': widget.token,
                                  'userId': widget.userId
                                });
                            serviceProvider.toastMessage('Successful');
                          } else if (response['myEditableRecord']
                                  ['serverMsg'] ==
                              'failed') {
                            // serviceProvider.warningToastMassage('Failed');
                            serviceProvider.popWarningErrorMsg(
                              context,
                              'Error message',
                              (response['myEditableRecord']['errorMsg'])
                                  .toString(),
                            );
                          }
                        }
                      } else if (_formKey.currentState!.validate() &&
                          imageFile != null)
                      // === THERE IS A CHANGE OF IMAGE. IMAGE FILE
                      // HAVE TO BE UPLOADED. I AM CREATING ANOTHER
                      // FUNCTION TO CARRY OUT THIS OPERATION.
                      {
                        if (selectCategoryId == '0') {
                          serviceProvider.popWarningErrorMsg(context, 'Warning',
                              'Kindly select a category where item belong to before saving');
                        } else if (selectStoreId == '0') {
                          serviceProvider.popWarningErrorMsg(context, 'Warning',
                              'Kindly select a store where item belong to before saving');
                        } else if (selectBrand == '0') {
                          serviceProvider.popWarningErrorMsg(context, 'Warning',
                              'Kindly select the brand of the item before saving');
                        } else {
                          // CALL THE DIALOG TO PREVENT USER FROM THE UI UNTIL DATA IS SAVED TO THE SERVER
                          setState(() {
                            serviceProvider.isLoadDialogBox = true;
                            serviceProvider.buildShowDialog(context);
                          });

                          var response = await serviceProvider.editPtdImage(
                              widget.token,
                              widget.ptdId,
                              widget.userId,
                              'editImgRequest',
                              ptdNameController.text,
                              ptdDescriptionController.text,
                              selectCategoryId,
                              selectBrand,
                              ptdPriceController.text,
                              DateFormat('yyyy-MM-dd').format(mfgDate),
                              DateFormat('yyyy-MM-dd').format(expDate),
                              ptdDiscountController.text,
                              outOfStock,
                              selectStoreId,
                              isActivePtd,
                              imageFile!);

                          // CALL THE DIALOG TO ALLOW USER PERFORM OPERATION ON THE UI

                          serviceProvider.isLoadDialogBox = false;
                          serviceProvider.buildShowDialog(context);

                          if (response == '"success"') {
                            Navigator.of(context).popAndPushNamed(
                                RouteManager.addProduct,
                                arguments: {
                                  'token': widget.token,
                                  'userId': widget.userId
                                });
                            serviceProvider.toastMessage('Successful');
                          } else {
                            // serviceProvider.warningToastMassage('Failed');
                            serviceProvider.popWarningErrorMsg(
                              context,
                              'Error message',
                              (response).toString(),
                            );
                          }
                        }
                      }
                    },
                    child: const Text(
                      'Save & add another',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                    color: Colors.orange[400],
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6.0)),
                  ),
                ),
                Flexible(
                  child: MaterialButton(
                    child: const Text(
                      'Save & continue editing',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                    color: Colors.orange[400],
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6.0)),
                    onPressed: () async {
                      if (_formKey.currentState!.validate() &&
                          imageFile == null) {
                        if (selectCategoryId == '0') {
                          serviceProvider.popWarningErrorMsg(context, 'Warning',
                              'Kindly select a category where item belong to before saving');
                        } else if (selectStoreId == '0') {
                          serviceProvider.popWarningErrorMsg(context, 'Warning',
                              'Kindly select a store where item belong to before saving');
                        } else if (selectBrand == '0') {
                          serviceProvider.popWarningErrorMsg(context, 'Warning',
                              'Kindly select the brand of the item before saving');
                        } else if (imageUrl == '') {
                          var value = await serviceProvider
                              .popWarningConfirmActionYesNo(context, 'Warning',
                                  'You are about to save a product without an image! \nDo you want to continue?');
                          if (value == true) {
                            // CALL THE DIALOG TO PREVENT USER FROM THE UI UNTIL DATA IS SAVED TO THE SERVER
                            setState(() {
                              serviceProvider.isLoadDialogBox = true;
                              serviceProvider.buildShowDialog(context);
                            });

                            var response = await serviceProvider.getEditablePtd(
                              widget.token,
                              widget.ptdId,
                              widget.userId,
                              'updateBtn',
                              editPtd(
                                  ptdNameController.text,
                                  ptdDescriptionController.text,
                                  selectCategoryId,
                                  selectBrand,
                                  ptdPriceController.text,
                                  imageName,
                                  DateFormat('yyyy-MM-dd').format(mfgDate),
                                  DateFormat('yyyy-MM-dd').format(expDate),
                                  ptdDiscountController.text,
                                  outOfStock,
                                  selectStoreId,
                                  isActivePtd),
                            );

                            // CALL THE DIALOG TO ALLOW USER PERFORM OPERATION ON THE UI

                            serviceProvider.isLoadDialogBox = false;
                            serviceProvider.buildShowDialog(context);

                            if (response['myEditableRecord']['serverMsg'] ==
                                'success') {
                              FocusManager.instance.primaryFocus?.unfocus();
                              serviceProvider.toastMessage('Successful');
                            } else if (response['myEditableRecord']
                                    ['serverMsg'] ==
                                'failed') {
                              // serviceProvider.warningToastMassage('Failed');
                              serviceProvider.popWarningErrorMsg(
                                context,
                                'Error message',
                                (response['myEditableRecord']['errorMsg'])
                                    .toString(),
                              );
                            }
                          }
                        } else {
                          // CALL THE DIALOG TO PREVENT USER FROM THE UI UNTIL DATA IS SAVED TO THE SERVER
                          setState(() {
                            serviceProvider.isLoadDialogBox = true;
                            serviceProvider.buildShowDialog(context);
                          });

                          var response = await serviceProvider.getEditablePtd(
                            widget.token,
                            widget.ptdId,
                            widget.userId,
                            'updateBtn',
                            editPtd(
                                ptdNameController.text,
                                ptdDescriptionController.text,
                                selectCategoryId,
                                selectBrand,
                                ptdPriceController.text,
                                imageName,
                                DateFormat('yyyy-MM-dd').format(mfgDate),
                                DateFormat('yyyy-MM-dd').format(expDate),
                                ptdDiscountController.text,
                                outOfStock,
                                selectStoreId,
                                isActivePtd),
                          );

                          // CALL THE DIALOG TO ALLOW USER PERFORM OPERATION ON THE UI

                          serviceProvider.isLoadDialogBox = false;
                          serviceProvider.buildShowDialog(context);

                          if (response['myEditableRecord']['serverMsg'] ==
                              'success') {
                            FocusManager.instance.primaryFocus?.unfocus();
                            serviceProvider.toastMessage('Successful');
                          } else if (response['myEditableRecord']
                                  ['serverMsg'] ==
                              'failed') {
                            // serviceProvider.warningToastMassage('Failed');
                            serviceProvider.popWarningErrorMsg(
                              context,
                              'Error message',
                              (response['myEditableRecord']['errorMsg'])
                                  .toString(),
                            );
                          }
                        }
                      }
                      if (_formKey.currentState!.validate() &&
                          imageFile != null)
                      // === THERE IS A CHANGE OF IMAGE. IMAGE FILE
                      // HAVE TO BE UPLOADED. I AM CREATING ANOTHER
                      // FUNCTION TO CARRY OUT THIS OPERATION.
                      {
                        if (selectCategoryId == '0') {
                          serviceProvider.popWarningErrorMsg(context, 'Warning',
                              'Kindly select a category where item belong to before saving');
                        } else if (selectStoreId == '0') {
                          serviceProvider.popWarningErrorMsg(context, 'Warning',
                              'Kindly select a store where item belong to before saving');
                        } else if (selectBrand == '0') {
                          serviceProvider.popWarningErrorMsg(context, 'Warning',
                              'Kindly select the brand of the item before saving');
                        } else {
                          // CALL THE DIALOG TO PREVENT USER FROM THE UI UNTIL DATA IS SAVED TO THE SERVER
                          setState(() {
                            serviceProvider.isLoadDialogBox = true;
                            serviceProvider.buildShowDialog(context);
                          });

                          var response = await serviceProvider.editPtdImage(
                              widget.token,
                              widget.ptdId,
                              widget.userId,
                              'editImgRequest',
                              ptdNameController.text,
                              ptdDescriptionController.text,
                              selectCategoryId,
                              selectBrand,
                              ptdPriceController.text,
                              DateFormat('yyyy-MM-dd').format(mfgDate),
                              DateFormat('yyyy-MM-dd').format(expDate),
                              ptdDiscountController.text,
                              outOfStock,
                              selectStoreId,
                              isActivePtd,
                              imageFile!);

                          // CALL THE DIALOG TO ALLOW USER PERFORM OPERATION ON THE UI

                          serviceProvider.isLoadDialogBox = false;
                          serviceProvider.buildShowDialog(context);

                          if (response == '"success"') {
                            FocusManager.instance.primaryFocus?.unfocus();
                            serviceProvider.toastMessage('Successful');
                          } else {
                            // serviceProvider.warningToastMassage('Failed');
                            serviceProvider.popWarningErrorMsg(
                              context,
                              'Error message',
                              (response).toString(),
                            );
                          }
                        }
                      }
                    },
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Container title() {
    return Container(
      margin: const EdgeInsets.all(0.0),
      child: const Text("Edit Product",
          style: TextStyle(
              color: Colors.black,
              fontSize: 20.0,
              fontWeight: FontWeight.bold)),
    );
  }

  // ========= CUPERTINO DATE SELECTOR IN MODAL BOTTOM SHEET FORMAT =========
  DateTime? pickedDate;
  _selectCupertinoDate(String caller) async {
    await showModalBottomSheet<DateTime>(
      context: context,
      builder: (context) {
        return Container(
          height: 250,
          child: Column(
            children: <Widget>[
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    CupertinoButton(
                      child: const Text('Cancel'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    CupertinoButton(
                      child: const Text('Clear date'),
                      onPressed: () {
                        if (caller == 'mfgDate') {
                          setState(() {
                            mfgDate = DateTime(0);
                            isMfgDate = false;
                          });
                        } else if (caller == 'expDate') {
                          setState(() {
                            expDate = DateTime(0);
                            isExpDate = false;
                          });
                        }

                        Navigator.of(context).pop();
                      },
                    ),
                    CupertinoButton(
                      child: const Text('Done'),
                      onPressed: () {
                        setState(() {
                          if (caller == 'mfgDate' && pickedDate != null) {
                            mfgDate = DateTime.parse(pickedDate.toString());
                            isMfgDate = true;
                            Navigator.of(context).pop(mfgDate);
                          } else if (caller == 'expDate' &&
                              pickedDate != null) {
                            expDate = DateTime.parse(pickedDate.toString());
                            isExpDate = true;
                            Navigator.of(context).pop(expDate);
                          }
                        });
                      },
                    ),
                  ],
                ),
              ),
              const Divider(
                height: 0,
                thickness: 1,
              ),
              Expanded(
                child: Container(
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    onDateTimeChanged: (DateTime dateTime) {
                      setState(() {
                        pickedDate = dateTime;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
    // print(pickedDate);
    // if (pickedDate != null && pickedDate != mfgDate) {
    //   setState(() {
    //     mfgDate = pickedDate;
    //     // _textEditingController.text = pickedDate.toString();
    //   });
    // }
  }

  // =========== ACTIVE SWITCH BUTTON ============
  Container activeSwitchButton() {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            child: Row(
              children: [
                CupertinoSwitch(
                  value: isActivePtd,
                  activeColor: Colors.blueAccent.shade700,
                  onChanged: (newValue) {
                    setState(() {
                      isActivePtd = newValue;
                    });
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

  // ====== IMAGE FILE PICKER ========
  File? imageFile;
  Future pickImage() async {
    var serviceProvider = Provider.of<DataProcessing>(context, listen: false);
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;
      final imageTemperary = File(image.path);
      setState(() {
        imageFile = imageTemperary;
        imageUrl = '';
      });
    } on PlatformException catch (error) {
      // rethrow;
      serviceProvider.warningToastMassage('Failed to pick image: $error');
    }
  }
}

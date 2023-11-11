import 'package:eshopper_mobile_app/componets/data_computation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CategorySetup extends StatefulWidget {
  final token, call;
  CategorySetup({required this.token, required this.call});
  @override
  _CategorySetupState createState() => _CategorySetupState();
}

class _CategorySetupState extends State<CategorySetup> {
  void initState() {
    super.initState();
    initializingFunctionCall(
      widget.token,
      widget.call,
    );
  }

  List categories = [];
  TextEditingController textEditingControllerVal = TextEditingController();
  TextEditingController textEditingControllerAddVal = TextEditingController();
  int counter = 0;

  initializingFunctionCall(token, call) async {
    var serviceProvider = Provider.of<DataProcessing>(context, listen: false);
    var response = await serviceProvider.getCategoryBrand(token, call);
    if (response['isSuccess'] == true) {
      setState(() {
        categories = response['menuList'];
      });
    }
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
        body: categories.isNotEmpty
            ? ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, x) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      children: [
                        ListTile(
                          title: Text(
                            categories.toList()[x]['category'].toString(),
                            style: const TextStyle(
                              color: Colors.lightBlue,
                              fontSize: 12,
                            ),
                          ),
                          onTap: () async {
                            var response =
                                await _displayDialog_updateCategoryList(
                              context,
                              categories.toList()[x]['id'].toString(),
                              categories.toList()[x]['category'].toString(),
                            );
                            if (response != null) {
                              setState(() {
                                categories.toList()[x]['category'] = response;
                              });
                            }
                          },
                        ),
                        const Divider(
                          color: Colors.black54,
                        ),
                      ],
                    ),
                  );
                })
            : const Center(
                child: CircularProgressIndicator(),
              ));
  }

  Widget titleSection() {
    return Container(
      margin: const EdgeInsets.all(0.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Product Category Setup",
            style: TextStyle(
                color: Colors.black,
                fontSize: 18.0,
                fontWeight: FontWeight.bold),
          ),
          IconButton(
            onPressed: () {
              _displayDialog_addCategoryList(context);
            },
            icon: const Icon(Icons.add),
            iconSize: 40.0,
            color: Colors.black,
          )
        ],
      ),
    );
  }

  // POP DIALOG
  _displayDialog_updateCategoryList(BuildContext context, id, value) async {
    var serviceProvider = Provider.of<DataProcessing>(context, listen: false);
    textEditingControllerVal = TextEditingController(
      text: value.toString(),
    );

    final _formKey = GlobalKey<FormState>();
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            scrollable: true,
            title: Text(
              'Edit Category',
              style: GoogleFonts.sora().copyWith(fontWeight: FontWeight.bold),
            ),
            content: Form(
              key: _formKey,
              child: // TEXT-FORM-FIELD FOR ADDRESS
                  TextFormField(
                maxLines: null,
                controller: textEditingControllerVal,
                keyboardType: TextInputType.streetAddress,
                decoration: InputDecoration(
                  labelText: 'Category',
                  hintText: 'Category field',
                  hintStyle: GoogleFonts.sora().copyWith(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Field cannot be empty';
                  }
                  return null;
                },
              ),
            ),
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
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        // CALL THE DIALOG TO PREVENT USER FROM THE UI UNTIL DATA IS SAVED TO THE SERVER
                        setState(() {
                          serviceProvider.isLoadDialogBox = true;
                          serviceProvider.buildShowDialog(context);
                        });

                        var response = await serviceProvider.adminSetting(
                          widget.token,
                          '',
                          id,
                          'updateCategory',
                          textEditingControllerVal.text,
                        );

                        // CALL THE DIALOG TO ALLOW USER PERFORM OPERATION ON THE UI

                        serviceProvider.isLoadDialogBox = false;
                        serviceProvider.buildShowDialog(context);

                        if (response['isSuccess'] == true) {
                          Navigator.pop(context, textEditingControllerVal.text);
                          serviceProvider.toastMessage('update successful');
                        } else {
                          serviceProvider.warningToastMassage('Error');
                        }
                      }
                    },
                  )
                ],
              )
            ],
          );
        });
  }

  // POP DIALOG TO ADD CATEGORY
  _displayDialog_addCategoryList(BuildContext context) async {
    var serviceProvider = Provider.of<DataProcessing>(context, listen: false);

    final _formKey = GlobalKey<FormState>();
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            scrollable: true,
            title: Text(
              'Add Category',
              style: GoogleFonts.sora().copyWith(fontWeight: FontWeight.bold),
            ),
            content: Form(
              key: _formKey,
              child: // TEXT-FORM-FIELD FOR ADDRESS
                  TextFormField(
                maxLines: null,
                controller: textEditingControllerAddVal,
                keyboardType: TextInputType.streetAddress,
                decoration: InputDecoration(
                  labelText: 'Category',
                  hintText: 'Category field',
                  hintStyle: GoogleFonts.sora().copyWith(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Field cannot be empty';
                  }
                  return null;
                },
              ),
            ),
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
                    child: const Text('Add'),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        // CALL THE DIALOG TO PREVENT USER FROM THE UI UNTIL DATA IS SAVED TO THE SERVER
                        setState(() {
                          serviceProvider.isLoadDialogBox = true;
                          serviceProvider.buildShowDialog(context);
                        });

                        var response = await serviceProvider.adminSetting(
                          widget.token,
                          '',
                          '',
                          'addCategory',
                          textEditingControllerAddVal.text,
                        );

                        // CALL THE DIALOG TO ALLOW USER PERFORM OPERATION ON THE UI

                        serviceProvider.isLoadDialogBox = false;
                        serviceProvider.buildShowDialog(context);

                        if (response['isSuccess'] == true) {
                          textEditingControllerAddVal.text = '';
                          Navigator.pop(context);
                          serviceProvider.toastMessage('successful');
                          initializingFunctionCall(widget.token, 'category');
                        } else {
                          serviceProvider.warningToastMassage('Error');
                        }
                      }
                    },
                  )
                ],
              )
            ],
          );
        });
  }
}

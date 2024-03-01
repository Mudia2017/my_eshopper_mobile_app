import 'dart:convert';

import 'package:eshopper_mobile_app/componets/data_computation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class ChangePassword extends StatefulWidget {
  final String userName, userId, token;

  const ChangePassword(
      {required this.userName, required this.userId, required this.token});

  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  bool _hidePassword = true;

  // ============= API USED TO GET OF THE ORDER SELECTED ============
  changePassword() async {
    Map serverResp = {};
    var data = {
      'old_password': oldPassword.text,
      'new_password1': newPassword1.text,
      'new_password2': newPassword2.text,
      'userId': widget.userId,
    };
    var response = await http.post(
      Uri.parse(
          '${dotenv.env['URL_ENDPOINT']}/apis/v1/homePage/api_changePassword/'),
      body: jsonEncode(data),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Token ${widget.token}",
      },
    );

    try {
      if (response.statusCode == 200) {
        var serverResponse = json.decode(response.body);
        serverResp = serverResponse;
        // setState(() {
        //   detailOrder = adminDetailOrder['order_obj'];
        //   isVerifiedPayment = adminDetailOrder['isVerifiedPayment'];
        //   orderItemData = adminDetailOrder['orderItemData'];
        //   if (adminDetailOrder['grandTotal'] == 0) {
        //     grandTotal = 0;
        //   } else {
        //     grandTotal = double.parse(adminDetailOrder['grandTotal']);
        //   }

        //   isDoneLoading = true;
        // });
      }
    } catch (error) {
      rethrow;
    }
    return serverResp;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: headerSection(),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [
            Color(0xFF40C4FF),
            Color(0xFFA7FFEB),
          ])),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF40C4FF),
              Color(0xFFA7FFEB),
            ],
          ),
        ),
        child: ListView(
          children: [
            const SizedBox(
              height: 12,
            ),
            info(),
            textInputSection(),
            buttonSection(),
          ],
        ),
      ),
    );
  }

  Container headerSection() {
    return Container(
      margin: const EdgeInsets.all(0.0),
      child: const Text("Change Password",
          style: TextStyle(
              color: Colors.black,
              fontSize: 25.0,
              fontWeight: FontWeight.bold)),
    );
  }

  Container info() {
    return Container(
      padding: const EdgeInsets.all(0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.userName}, kindly feel to change your account password',
              style: GoogleFonts.nixieOne().copyWith(
                fontSize: 20,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Text(
                  'Note: ',
                  style: GoogleFonts.nixieOne().copyWith(
                      fontSize: 20,
                      color: Colors.red.shade900,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  'Password is case sensitive!',
                  style: GoogleFonts.nixieOne()
                      .copyWith(fontSize: 20, fontStyle: FontStyle.italic),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  final TextEditingController oldPassword = TextEditingController();
  final TextEditingController newPassword1 = TextEditingController();
  final TextEditingController newPassword2 = TextEditingController();
  Container textInputSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
      child: Column(
        children: [
          TextFormField(
            controller: oldPassword,
            cursorColor: Colors.black,
            decoration: InputDecoration(
              icon: const Icon(
                Icons.lock_open_sharp,
                color: Colors.black45,
              ),
              labelText: 'Old password',
              suffixIcon: GestureDetector(
                onTap: () {
                  setState(() {
                    _hidePassword = !_hidePassword;
                  });
                },
                child: Icon(
                    _hidePassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.black),
              ),
              border: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white)),
              hintStyle: const TextStyle(color: Colors.black54),
            ),
            obscureText: _hidePassword,
          ),
          const SizedBox(
            height: 50.0,
          ),
          TextFormField(
            controller: newPassword1,
            cursorColor: Colors.black,
            decoration: InputDecoration(
              icon: const Icon(
                Icons.lock_sharp,
                color: Colors.black45,
              ),
              labelText: 'New password',
              suffixIcon: GestureDetector(
                onTap: () {
                  setState(() {
                    _hidePassword = !_hidePassword;
                  });
                },
                child: Icon(
                  _hidePassword ? Icons.visibility_off : Icons.visibility,
                  color: Colors.black,
                ),
              ),
              border: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white)),
              hintStyle: const TextStyle(color: Colors.black45),
            ),
            obscureText: _hidePassword,
          ),
          TextFormField(
            controller: newPassword2,
            cursorColor: Colors.black,
            decoration: InputDecoration(
              icon: const Icon(
                Icons.lock_sharp,
                color: Colors.black45,
              ),
              labelText: 'Confirm password',
              suffixIcon: GestureDetector(
                onTap: () {
                  setState(() {
                    _hidePassword = !_hidePassword;
                  });
                },
                child: Icon(
                  _hidePassword ? Icons.visibility_off : Icons.visibility,
                  color: Colors.black,
                ),
              ),
              border: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white)),
              hintStyle: const TextStyle(color: Colors.black45),
            ),
            obscureText: _hidePassword,
          )
        ],
      ),
    );
  }

  Container buttonSection() {
    var serviceProvider = Provider.of<DataProcessing>(context);
    return Container(
      padding: const EdgeInsets.all(0),
      height: 100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          MaterialButton(
            height: 50,
            elevation: 5,
            onPressed: () async {
              if (oldPassword.text.isNotEmpty &&
                  newPassword1.text.isNotEmpty &&
                  newPassword2.text.isNotEmpty) {
                // CALL THE DIALOG TO PREVENT USER FROM THE UI UNTIL DATA IS SAVED TO THE SERVER
                setState(() {
                  serviceProvider.isLoadDialogBox = true;
                  serviceProvider.buildShowDialog(context);
                });

                var response = await changePassword();

                // CALL THE DIALOG TO ALLOW USER PERFORM OPERATION ON THE UI

                serviceProvider.isLoadDialogBox = false;
                serviceProvider.buildShowDialog(context);

                if (response['serverMsg'] == 'Password change successful') {
                  serviceProvider.popDialogMsg(
                      context, 'System Message', 'Password change successful');
                  oldPassword.text = '';
                  newPassword1.text = '';
                  newPassword2.text = '';
                  FocusScope.of(context)
                      .unfocus(); // REMOVE CURSOR FROM TEXT FIELD
                  FocusManager.instance.primaryFocus
                      ?.unfocus(); // REMOVE KEYPAD
                } else if (response['serverMsg'] != '' &&
                    response['serverMsg'] != 'Password change successful') {
                  serviceProvider.popWarningErrorMsg(
                      context,
                      'Error Message!',
                      response['serverMsg']['password_mismatch'] +
                          '\n' +
                          response['serverMsg']['password_incorrect']);
                } else if (response['errorMsg'] != '' &&
                    response['errorMsg'] != null) {
                  serviceProvider.popWarningErrorMsg(
                      context, 'Error Message!', '${response['errorMsg']}');
                }
              } else {
                serviceProvider
                    .warningToastMassage('All field most be properly filled');
              }
            },
            child: Row(
              children: const [
                Text(
                  "Save Password",
                  style: TextStyle(color: Colors.black, fontSize: 25),
                ),
                SizedBox(
                  width: 20,
                ),
                Icon(
                  Icons.save,
                  size: 35,
                ),
              ],
            ),
            color: Colors.orange[400],
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.0)),
          ),
        ],
      ),
    );
  }
}

import 'dart:convert';

import 'package:eshopper_mobile_app/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  // static const routeName = '/register';

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  bool _hidePassword = true;
  bool _isLoading = false;
  String _jsonResponse = '';
  bool register = false;
  bool failure = false;

  signIn(String userName, email, pass1, pass2) async {
    Map data = {
      "username": userName,
      "email": email,
      "password1": pass1,
      "password2": pass2
    };

    var response = await http.post(
        // Uri.parse('http://192.168.1.36:8000/apis/v1/homePage/api_register/'),
        // Uri.parse("http://127.0.0.1:8000/apis/v1/homePage/api_register/"),
        Uri.parse('http://192.168.43.50:8000/apis/v1/homePage/api_register/'),
        body: json.encode(data),
        headers: {"Content-Type": "application/json"},
        encoding: Encoding.getByName("utf-8"));

    if (response.statusCode == 200 && response.body == '{}') {
      setState(() {
        _isLoading = false;
        register = true;
      });
      Navigator.of(context).pushReplacementNamed(RouteManager.login);
    } else if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      List<dynamic> responseList = [];
      if (jsonResponse.keys.first == 'password2') {
        responseList = jsonResponse['password2'];
      } else {
        responseList = jsonResponse['username'];
      }

      setState(() {
        _isLoading = false;
        failure = true;
        _jsonResponse = responseList[0];
      });
    } else {
      List<dynamic> jsonResponseList = json.decode(response.body);
      setState(() {
        _isLoading = false;
        failure = true;
        _jsonResponse = jsonResponseList[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (register == true) {
      Fluttertoast.showToast(
          msg: 'Account was successfully registered',
          timeInSecForIosWeb: 8,
          backgroundColor: Colors.green);
      register = false;
    }
    if (failure == true) {
      Fluttertoast.showToast(
          msg: _jsonResponse,
          timeInSecForIosWeb: 8,
          backgroundColor: Colors.redAccent);
      failure = false;
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [
          Color(0xFF40C4FF),
          Color(0xFFA7FFEB),
        ], begin: Alignment.topCenter, end: Alignment.center)),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black45),
                ),
              )
            : ListView(
                children: [
                  headerSection(),
                  info(),
                  textSection(),
                  buttonSection(),
                ],
              ),
      ),
    );
  }

  Container headerSection() {
    return Container(
      margin: const EdgeInsets.only(top: 10.0),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
      child: const Text("Register",
          style: TextStyle(
              color: Colors.black,
              fontSize: 40.0,
              fontWeight: FontWeight.bold)),
    );
  }

  Container info() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
      child: Row(
        children: [
          Text(
            'Note: ',
            style: GoogleFonts.philosopher().copyWith(
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          Text(
            'Username and passwork are case sensitive',
            style: GoogleFonts.philosopher().copyWith(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFB71C1C),
            ),
          )
        ],
      ),
    );
  }

  final TextEditingController userNameController = TextEditingController();
  final TextEditingController userEmailController = TextEditingController();
  final TextEditingController userPasswordController = TextEditingController();
  final TextEditingController userPassword2Controller = TextEditingController();

  Container textSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
      child: Column(
        children: <Widget>[
          TextFormField(
            controller: userNameController,
            cursorColor: Colors.black45,
            style: const TextStyle(color: Colors.black),
            decoration: const InputDecoration(
              icon: Icon(Icons.person, color: Colors.black45),
              hintText: "UserName",
              border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70)),
              hintStyle: TextStyle(color: Colors.black45),
            ),
          ),
          const SizedBox(height: 30.0),
          TextFormField(
            controller: userEmailController,
            cursorColor: Colors.black45,
            style: const TextStyle(color: Colors.black),
            decoration: const InputDecoration(
              icon: Icon(Icons.email, color: Colors.black45),
              hintText: "Email",
              border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70)),
              hintStyle: TextStyle(color: Colors.black45),
            ),
          ),
          const SizedBox(height: 30.0),
          TextFormField(
            controller: userPasswordController,
            cursorColor: Colors.black45,
            // obscureText: true,
            style: const TextStyle(color: Colors.black),
            decoration: InputDecoration(
              icon: const Icon(Icons.lock, color: Colors.black45),
              hintText: "Password",
              suffixIcon: GestureDetector(
                onTap: () {
                  setState(() {
                    _hidePassword = !_hidePassword;
                  });
                },
                child: Icon(
                    _hidePassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.black45),
              ),
              border: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70)),
              hintStyle: const TextStyle(color: Colors.black45),
            ),
            obscureText: _hidePassword,
          ),
          const SizedBox(height: 30.0),
          TextFormField(
            controller: userPassword2Controller,
            cursorColor: Colors.black45,
            // obscureText: true,
            style: const TextStyle(color: Colors.black),
            decoration: InputDecoration(
              icon: const Icon(Icons.lock, color: Colors.black45),
              hintText: "Password",
              suffixIcon: GestureDetector(
                onTap: () {
                  setState(() {
                    _hidePassword = !_hidePassword;
                  });
                },
                child: Icon(
                    _hidePassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.black45),
              ),
              border: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70)),
              hintStyle: const TextStyle(color: Colors.black45),
            ),
            obscureText: _hidePassword,
          ),
        ],
      ),
    );
  }

  Container buttonSection() {
    // final userProvider = Provider.of<CartAuthenticUser>(context);
    return Container(
      // width: MediaQuery.of(context).size.width,
      height: 40.0,
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      margin: const EdgeInsets.only(top: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          MaterialButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.black, fontSize: 25),
            ),
            color: Colors.grey[400],
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.0)),
          ),
          MaterialButton(
            onPressed: () {
              userNameController.text == "" ||
                      userPasswordController.text == "" ||
                      userEmailController.text == ""
                  ? Fluttertoast.showToast(
                      msg:
                          "Username, Email or Password field must not be empty",
                      // toastLength: Toast.LENGTH_SHORT,
                      timeInSecForIosWeb: 4,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 16.0)
                  : setState(() {
                      _isLoading = true;
                      signIn(
                          userNameController.text,
                          userEmailController.text,
                          userPasswordController.text,
                          userPassword2Controller.text);
                    });
            },
            child: const Text(
              "Create Account",
              style: TextStyle(color: Colors.black, fontSize: 25),
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

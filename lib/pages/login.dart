import 'dart:convert';

import 'package:eshopper_mobile_app/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _isLoading = false;
  bool loginFailure = false;
  bool _hidePassword = true;

  signIn(String userName, password) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    // Future<SharedPreferences> sharedPreferences = SharedPreferences.getInstance();
    Map data = {'username': userName, 'password': password};
    var jsonResponse;

    var response = await http.post(
        // Uri.parse('http://192.168.1.36:8000/apis/v1/homePage/api_login/'),
        // Uri.parse('http://127.0.0.1:8000/apis/v1/homePage/api_login/'),
        // Uri.parse('http://192.168.43.50:8000/apis/v1/homePage/api_login/'),
        Uri.parse('${dotenv.env['URL_ENDPOINT']}/apis/v1/homePage/api_login/'),
        body: json.encode(data),
        headers: {"Content-Type": "application/json"},
        encoding: Encoding.getByName("utf-8"));

    if (response.statusCode == 200) {
      jsonResponse = json.decode(response.body);
      if (jsonResponse != null && jsonResponse['isSuccessLogin'] == true) {
        _isLoading = false;

        sharedPreferences.setString("token", jsonResponse['token']);
        sharedPreferences.setString("username", jsonResponse['username']);
        sharedPreferences.setString("useremail", jsonResponse['email']);
        sharedPreferences.setString(
            'customerId', jsonResponse['customer_id'].toString());
        sharedPreferences.setString(
            "userId", jsonResponse['user_id'].toString());
        sharedPreferences.setString("custName", jsonResponse['custName']);
        sharedPreferences.setString("custEmail", jsonResponse['custEmail']);
        Fluttertoast.showToast(
            msg: 'Login successful',
            timeInSecForIosWeb: 5,
            backgroundColor: Colors.green);
        Navigator.of(context).pushReplacementNamed(RouteManager.homePage);
      } else if (jsonResponse['isSuccessLogin'] == false) {
        var errorMsg = jsonResponse['error_msg'];
        setState(() {
          Fluttertoast.showToast(
              msg: errorMsg,
              timeInSecForIosWeb: 5,
              backgroundColor: Colors.red);
          _isLoading = false;
          loginFailure = true;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
        loginFailure = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: const Color(0xFF40C4FF),
      //   elevation: 0,
      // ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [
            Color(0xFF40C4FF),
            Color(0xFFA7FFEB),
          ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                children: [
                  headerSection(),
                  info(),
                  textSection(),
                  buttonSection(),
                  const SizedBox(
                    height: 8,
                  ),
                  forgotLoginPassword(),
                  const SizedBox(
                    height: 15,
                  ),
                  Center(
                    child: Text('Don\'t have an account?',
                        style:
                            GoogleFonts.philosopher().copyWith(fontSize: 16)),
                  ),
                  register()
                ],
              ),
      ),
    );
  }

  Container forgotLoginPassword() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
      child: InkWell(
        onTap: () {
          // Navigator.of(context).pushNamed(RouteManager.register);
        },
        child: const Center(
          child: Text(
            'forgot your login password?',
            style: TextStyle(
              decoration: TextDecoration.underline,
              fontSize: 18,
              fontStyle: FontStyle.italic,
              color: Color(0xFFB71C1C),
            ),
          ),
        ),
      ),
    );
  }

  Container register() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
      child: InkWell(
        onTap: () {
          Navigator.of(context).pushNamed(RouteManager.register);
        },
        child: const Center(
          child: Text(
            'create an account...',
            style: TextStyle(
              decoration: TextDecoration.underline,
              fontSize: 18,
              fontStyle: FontStyle.italic,
              color: Color(0xFFB71C1C),
            ),
          ),
        ),
      ),
    );
  }

  Container info() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'NOTE: ',
                style: GoogleFonts.philosopher().copyWith(
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              Flexible(
                child: Text("Username and password are case sensitive!",
                    style: GoogleFonts.philosopher().copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFB71C1C),
                    )),
              ),
            ],
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
              userNameController.text == "" || passwordController.text == ""
                  ? Fluttertoast.showToast(
                      msg: "User name or Password is empty",
                      timeInSecForIosWeb: 5,
                      backgroundColor: Colors.red,
                    )
                  : setState(() {
                      _isLoading = true;
                      signIn(userNameController.text, passwordController.text);
                    });
            },
            child: const Text(
              "Sign In",
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

  final TextEditingController userNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Container textSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
      child: Column(
        children: <Widget>[
          TextFormField(
            controller: userNameController,
            cursorColor: Colors.black,
            style: const TextStyle(color: Colors.black),
            decoration: const InputDecoration(
              icon: Icon(Icons.person, color: Colors.black45),
              hintText: "UserName",
              border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white)),
              hintStyle: TextStyle(color: Colors.black54),
            ),
          ),
          const SizedBox(height: 50.0),
          TextFormField(
            controller: passwordController,
            cursorColor: Colors.black,
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
                    color: Colors.black),
              ),
              border: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white)),
              hintStyle: const TextStyle(color: Colors.black54),
            ),
            obscureText: _hidePassword,
          ),
        ],
      ),
    );
  }

  Container headerSection() {
    return Container(
      margin: const EdgeInsets.only(top: 10.0),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
      child: const Text("Login",
          style: TextStyle(
              color: Colors.black,
              fontSize: 40.0,
              fontWeight: FontWeight.bold)),
    );
  }
}

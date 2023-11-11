import 'package:eshopper_mobile_app/componets/data_computation.dart';
import 'package:eshopper_mobile_app/componets/side_drawer.dart';
import 'package:eshopper_mobile_app/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CustomerService extends StatefulWidget {
  final String userName, userId, token;
  // const CustomerService({Key? key, required this.userName}) : super(key: key);
  const CustomerService(
      {required this.userName, required this.userId, required this.token});

  @override
  State<CustomerService> createState() => _CustomerServiceState();
}

class _CustomerServiceState extends State<CustomerService> {
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
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [
                Color(0xFF40C4FF),
                Color(0xFFA7FFEB),
              ])),
            ),
            title: headerSection(),
            elevation: 0,
            actions: [
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.shopping_cart,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
          drawer: const SafeArea(
            child: Drawer(
              child: SideDrawer(caller: 'innerSideDrawer'),
            ),
          ),
          body: Container(
            decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [
              Color(0xFF40C4FF),
              Color(0xFFA7FFEB),
            ])),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  info(),
                  linkSection(),
                ],
              ),
            ),
          )),
    );
  }

  Container headerSection() {
    return Container(
      margin: const EdgeInsets.all(0.0),
      child: const Text("Customer Service",
          style: TextStyle(
              color: Colors.black,
              fontSize: 25.0,
              fontWeight: FontWeight.bold)),
    );
  }

  Container info() {
    return Container(
      padding: const EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hello ${widget.userName}! How can we help you?',
            style: GoogleFonts.philosopher().copyWith(
              fontSize: 25,
              // fontWeight: FontWeight.w100,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          Text(
            "Manage your orders",
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.red[800]),
          ),
        ],
      ),
    );
  }

  Container linkSection() {
    return Container(
      padding: const EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(
            color: Colors.grey[900],
          ),
          InkWell(
            onTap: () {},
            child: const ListTile(
              leading: Icon(Icons.shopping_bag),
              title: Text('Returns and Refunds'),
              subtitle: Text('Return or exchange items'),
              trailing: Icon(
                Icons.chevron_right,
                color: Colors.blue,
                size: 30,
              ),
            ),
          ),
          Divider(
            color: Colors.grey[900],
          ),
          InkWell(
            onTap: () {
              Navigator.of(context).pushNamed(
                RouteManager.changePassword,
                arguments: {
                  'username': widget.userName,
                  'userId': widget.userId,
                  'token': widget.token,
                },
              );
            },
            child: const ListTile(
              leading: Icon(Icons.security),
              title: Text('Login and Security'),
              subtitle: Text('Change password'),
              trailing: Icon(
                Icons.chevron_right,
                color: Colors.blue,
                size: 30,
              ),
            ),
          ),
          Divider(
            color: Colors.grey[900],
          ),
          const SizedBox(
            height: 20,
          ),
          const Text(
            "More assistance?",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          Divider(
            color: Colors.grey[900],
          ),
          InkWell(
            onTap: () {
              Navigator.of(context).pushNamed(RouteManager.contactUs);
            },
            child: const ListTile(
              title: Text(
                "Contact Us",
              ),
              trailing: Icon(
                Icons.chevron_right,
                color: Colors.blue,
                size: 30,
              ),
            ),
          ),
          Divider(
            color: Colors.grey[900],
          ),
        ],
      ),
    );
  }
}

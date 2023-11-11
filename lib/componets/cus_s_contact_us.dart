import 'package:eshopper_mobile_app/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

class ContactUs extends StatefulWidget {
  const ContactUs({Key? key}) : super(key: key);

  @override
  State<ContactUs> createState() => _ContactUsState();
}

class _ContactUsState extends State<ContactUs> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [
            Color(0xFF40C4FF),
            Color(0xFFA7FFEB),
          ])),
        ),
        elevation: 0,
        title: headerSection(),
      ),
      body: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [
          Color(0xFF40C4FF),
          Color(0xFFA7FFEB),
        ])),
        child: ListView(
          children: [
            bodyLink(),
          ],
        ),
      ),
    );
  }

  Container headerSection() {
    return Container(
      margin: const EdgeInsets.only(top: 10.0),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
      child: Text("Questions about an issue?",
          style: GoogleFonts.philosopher().copyWith(
              color: Colors.black,
              fontSize: 18.0,
              fontWeight: FontWeight.bold)),
    );
  }

  Container bodyLink() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          Divider(
            color: Colors.grey.shade900,
          ),
          InkWell(
            onTap: () {
              Navigator.of(context)
                  .pushNamed(RouteManager.sendEmailToCusService);
            },
            child: const ListTile(
              leading: Icon(Icons.email),
              title: Text('E-mail'),
              subtitle: Text('Customer Service'),
              trailing: Icon(
                Icons.chevron_right,
                color: Colors.blue,
              ),
            ),
          ),
          Divider(
            color: Colors.grey.shade900,
          ),
          const SizedBox(
            height: 20.0,
          ),
          Text(
            'Have any suggestions for the app?',
            style: GoogleFonts.philosopher().copyWith(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          Divider(
            color: Colors.grey.shade900,
          ),
          InkWell(
            onTap: () {},
            child: const ListTile(
              leading: Icon(Icons.email),
              title: Text('Feedback about the app'),
              subtitle: Text(
                  'Your feedback or suggestions about the app is important to us'),
              trailing: Icon(
                Icons.chevron_right,
                color: Colors.blue,
              ),
            ),
          ),
          Divider(
            color: Colors.grey.shade900,
          ),
        ],
      ),
    );
  }
}

// class Utils {
//   static Future openLink({
//     @required String url,
//   }) =>
//       _launchUrl(url);

//   static Future openEmail({
//     @required String toEmail,
//     @required String subject,
//     @required String body,
//   }) async {
//     final url =
//         'mailto:$toEmail?subject=${Uri.encodeFull(subject)}&body=${Uri.encodeFull(body)}';

//     await _launchUrl(url);
//   }

//   static Future _launchUrl(String url) async {
//     if (await canLaunch(url)) {
//       await launch(url);
//     }
//   }
// }

// ======================== EMAIL CUSTOMER SERVICE PAGE ========================

class SendEmailToCusService extends StatefulWidget {
  const SendEmailToCusService({Key? key}) : super(key: key);

  @override
  _SendEmailToCusServiceState createState() => _SendEmailToCusServiceState();
}

class _SendEmailToCusServiceState extends State<SendEmailToCusService> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [
            Color(0xFF40C4FF),
            Color(0xFFA7FFEB),
          ])),
        ),
        elevation: 0.0,
        title: headerSection(),
      ),
      body: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [
          Color(0xFF40C4FF),
          Color(0xFFA7FFEB),
        ])),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            children: [
              bodySection(),
              info(),
            ],
          ),
        ),
      ),
    );
  }

  Container headerSection() {
    return Container(
      margin: const EdgeInsets.only(top: 10.0),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
      child: Text("E-mail",
          style: GoogleFonts.philosopher().copyWith(
              color: Colors.black,
              fontSize: 18.0,
              fontWeight: FontWeight.bold)),
    );
  }

  final _subjectController = TextEditingController();
  final _bodyController = TextEditingController();
  final _recipientController = TextEditingController();

  Container bodySection() {
    return Container(
      padding: const EdgeInsets.all(0),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                enabled: false,
                controller: _recipientController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Recipient',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                keyboardType: TextInputType.multiline,
                controller: _subjectController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Subject',
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                "Tell us about your issue",
                style: GoogleFonts.nixieOne().copyWith(
                  fontSize: 20,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.bottomRight,
                child: TextField(
                  maxLines: 10,
                  keyboardType: TextInputType.multiline,
                  controller: _bodyController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Body',
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                children: [
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: ButtonTheme(
                        height: 55,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Colors.orange[400],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                "Send E-Mail",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Icon(
                                Icons.send,
                                size: 35,
                                color: Colors.black,
                              ),
                            ],
                          ),
                          onPressed: () {},
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ]),
    );
  }

  Container info() {
    return Container(
      padding: const EdgeInsets.all(0),
      child: Column(
        children: [
          const SizedBox(
            height: 8,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              "You will receive a response under 24 hours",
              style: GoogleFonts.nixieOne().copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w300,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

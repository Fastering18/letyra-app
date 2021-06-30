//import 'package:firebase_analytics/firebase_analytics.dart';
//import 'package:firebase_analytics/observer.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../src/apiRequest.dart' as APIreq;

class LoginPage extends StatefulWidget {
  LoginPage({Key? key, required this.title}) : super(key: key);

  final String title;
  //final FirebaseAnalytics analytics;
  //final FirebaseAnalyticsObserver observer;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late TextEditingController _emailTeksController;
  late TextEditingController _passwordTeksController;
  late SharedPreferences prefsDisk;

  void dataPreferencesKeLoad(SharedPreferences shr) {
    if ((shr.getString("loginToken") ?? "").isNotEmpty) {
      Navigator.pushReplacementNamed(
        context,
        '/chat',
      );
    }
  }

  @override
  void initState() {
    _emailTeksController = TextEditingController();
    _passwordTeksController = TextEditingController();

    SharedPreferences.getInstance().then((shr) {
      prefsDisk = shr;
      dataPreferencesKeLoad(shr);
    });

    final FirebaseMessaging messaging = FirebaseMessaging.instance;
    
    messaging.requestPermission(
      provisional: true,
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(children: <Widget>[
              Text("login"),
              Form(
                child: TextFormField(
                  controller: _emailTeksController,
                  decoration: InputDecoration(
                      labelText: 'Email', hintText: "Email akun"),
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.emailAddress,
                  key: Key("input_alamat_email"),
                ),
              ),
              Form(
                child: TextFormField(
                  controller: _passwordTeksController,
                  decoration: InputDecoration(
                      labelText: 'Password', hintText: "Password akun"),
                  onFieldSubmitted: (value) => _validasiLogin(),
                  keyboardType: TextInputType.visiblePassword,
                  //onChanged: (value) {},
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    textStyle: const TextStyle(fontSize: 20)),
                onPressed: _validasiLogin,
                child: const Text('Login'),
                key: Key("tombol_submit_login")
              ),
            ])));
  }

  showAlertDialog(BuildContext context,
      {String alasan = "Dialog box...",
      String judul = "Notice",
      List<Widget> childLain = const [],
      required Function ketikaOk}) {
    // set up the button
    Widget okButton = TextButton(
      child: Text("Oke"),
      onPressed: () {
        ketikaOk();
        Navigator.of(context).pop();
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text(judul),
      content: Text(alasan),
      actions: [okButton, ...childLain],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  /*Future<void> _sendAnalyticsEvent(String nama, Map<String, dynamic> d) async {
    await widget.analytics.logEvent(
      name: nama,
      parameters: d
    );
    print('logEvent berhasil');
  }*/

  void _validasiLogin() {
    String emailForm = _emailTeksController.text.trim();
    String passwordForm = _passwordTeksController.text.trim();
    if (emailForm.isEmpty)
      return showAlertDialog(context,
          judul: "Data belum valid",
          alasan: "Form email belum di isi",
          ketikaOk: () {});
    if (passwordForm.isEmpty)
      return showAlertDialog(context,
          judul: "Data belum valid",
          alasan: "Form password belum di isi",
          ketikaOk: () {});

    APIreq.login(emailForm, passwordForm).then((data) async {
      print(data.respon.code == 200);
      print(data.pengguna?.token);
      if (data.pengguna != null && data.respon.code == 200) {
        prefsDisk.setString("loginToken", data.pengguna?.token ?? "");
        prefsDisk.setStringList("loginData", [
          data.pengguna?.email ?? "",
          data.pengguna?.user?.id.toString() ?? "0"
        ]);
        //await _sendAnalyticsEvent("User terlogin", {"email": data.pengguna?.email ?? "", "id": data.pengguna?.user?.id.toString() ?? "0"});
        Navigator.pushReplacementNamed(
          context,
          '/chat',
        );
      }
    }).catchError((err) {
      showAlertDialog(context,
          judul: "Gagal login",
          alasan: err.toString().substring(11),
          ketikaOk: () {});
      print(err.toString());
    });
  }
}

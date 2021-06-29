
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../src/apiRequest.dart' as APIreq;

class LoginPage extends StatefulWidget {
  LoginPage({Key? key, required this.title}) : super(key: key);

  final String title;

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
        child: Column(
          children: <Widget>[
            Text("login"),
            Form(
              child: TextFormField(
                controller: _emailTeksController,
                decoration: InputDecoration(labelText: 'Email', hintText: "Email akun"),
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.emailAddress,
              ),
            ),
            Form(
              child: TextFormField(
                controller: _passwordTeksController,
                decoration: InputDecoration(labelText: 'Password', hintText: "Password akun"),
                onFieldSubmitted: (value) => _validasiLogin(),
                keyboardType: TextInputType.visiblePassword,
                //onChanged: (value) {},
              ),
            ),
            ElevatedButton(
            style: ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 20)),
            onPressed: _validasiLogin,
            child: const Text('Login'),
            ),
          ]
        )
      )
    );
  }

  showAlertDialog(BuildContext context, {String alasan = "Dialog box...", String judul = "Notice"}) {
  // set up the button
  Widget okButton = TextButton(
    child: Text("Oke"),
    onPressed: () { Navigator.of(context).pop(); },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text(judul),
    content: Text(alasan),
    actions: [
      okButton,
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

  void _validasiLogin() {
    String emailForm = _emailTeksController.text.trim();
    String passwordForm = _passwordTeksController.text.trim();
    if (emailForm.isEmpty) return showAlertDialog(context, judul: "Data belum valid", alasan: "Form email belum di isi");
    if (passwordForm.isEmpty) return showAlertDialog(context, judul: "Data belum valid", alasan: "Form password belum di isi");

    APIreq.login(emailForm, passwordForm).then((data) {
      print(data.respon.code==200);
      print(data.pengguna?.token);
       if (data.pengguna != null && data.respon.code == 200) {
        prefsDisk.setString("loginToken", data.pengguna?.token ?? "");
        prefsDisk.setStringList("loginData", [data.pengguna?.email ?? "", data.pengguna?.user?.id.toString() ?? "0"]);
        Navigator.pushReplacementNamed(
        context,
        '/chat',
         ); 
       }
    }).catchError((err) {
       showAlertDialog(context, judul: "Gagal login", alasan: err.toString().substring(11));
       print(err.toString());
    });
  }
}
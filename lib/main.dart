import 'dart:io';
import 'package:flutter/material.dart';
import './halaman/login.dart';
import './halaman/chat.dart';

void main() {
  HttpOverrides.global = new MyHttpOverrides();
  runApp(MyApp());
}

class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext? context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}

class MyApp extends StatelessWidget {
  // Widget Utama
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Letyra',
      theme: ThemeData(
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(title: 'Login'),
      routes:  <String, WidgetBuilder> {
      '/login': (BuildContext context) => LoginPage(title: 'Login'),
      '/chat': (BuildContext context) => MainChatPage(title: 'Main chat page'),
      },
    );
  }
}

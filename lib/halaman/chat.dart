//import 'package:firebase_analytics/observer.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
//import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as socketio;
import '../src/utilities.dart';
import '../src/apiRequest.dart';

socketio.Socket connectAndListen() {
  socketio.Socket socket = socketio.io(
      'https://letyra.tk',
      socketio.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .enableForceNew()
          .build());

  socket.onConnect((_) {
    print('connected');
    //socket.emit('msg', 'test');
  });

  socket.onConnectError((data) {
    print(data.toString());
  });

  socket.onDisconnect((_) => print('disconnect'));
  return socket;
}

class MainChatPage extends StatefulWidget {
  MainChatPage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;
  /*final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;*/

  @override
  _MainChatPageState createState() => _MainChatPageState();
}

class _MainChatPageState extends State<MainChatPage> {
  late socketio.Socket socketIO;
  late List<Map<String, dynamic>> messages;
  late double height, width;
  late TextEditingController _inputChatController;
  late TextEditingController _inputNewUsernameController;
  late ScrollController _scrollController;
  late SharedPreferences prefsDisk;
  late int clientId;
  late FirebaseMessaging messaging;

  void setStateku(fn) {
    if (mounted) {
      super.setState(fn);
    } else {
      setState(fn);
    }
  }

  void dataPreferencesKeLoad(SharedPreferences shr) {
    if ((shr.getString("loginToken") ?? "").isEmpty) {
      Navigator.pushReplacementNamed(
        context,
        '/login',
      );
    }
    clientId = int.parse(shr.getStringList("loginData")?[1] ?? "0");
  }

  @override
  void dispose() {
    socketIO.dispose();
    super.dispose();
  }

  @override
  void initState() {
    messages = [];
    _inputChatController = TextEditingController();
    _inputNewUsernameController = TextEditingController();
    _scrollController = ScrollController();

    SharedPreferences.getInstance().then((shr) {
      prefsDisk = shr;
      dataPreferencesKeLoad(shr);
    });

    socketIO = connectAndListen();
    socketIO.on("message", (data) {
      print(data);
      setState(() {
        messages.add(data);
      });
      if (_scrollController.hasClients) _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 100),
        curve: Curves.ease,
      );
    });

    messaging = FirebaseMessaging.instance;
    messaging.requestPermission(
      provisional: true,
    );
    messaging.getToken().then((value){
      // token perangkat untuk cloud messaging 
      print(value);
    });
    FirebaseMessaging.onMessage.listen((RemoteMessage event) {
        print("nemu notif");
        print(event.notification!.body);
    });
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print('applikasi kebuka lewat notif');
    });
    if (!kIsWeb) {
      messaging.subscribeToTopic("global_messages");
    }

    super.initState();
  }

  void _logOut() {
    prefsDisk.clear();
    Navigator.pushReplacementNamed(context, "/login");
  }

  void _onFabKlik() {
    setState(() {
      _sendMessage();
    });
  }

  Widget buildMessageList() {
    return Container(
      height: height * 0.8,
      width: width,
      margin: EdgeInsets.only(left: 25, right: 25),
      child: ListView.builder(
        controller: _scrollController,
        itemCount: messages.length,
        itemBuilder: (BuildContext context, int index) {
          return buildSingleMessage(index);
        },
      ),
    );
  }

  Widget buildSingleMessage(int index) {
    final Map<String, dynamic> pesan = messages[index];
    final pengirim = pesan["author"];
    final bool sayaSendiri = pengirim["userId"] == clientId;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
          crossAxisAlignment:
              sayaSendiri ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(sayaSendiri ? "You" : pengirim["username"] ?? "",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black)),
            Row(
                mainAxisAlignment: sayaSendiri
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.start,
                children: [
                  Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      //constraints: BoxConstraints(maxHeight: 500, minHeight: 30, maxWidth: 750, minWidth: 50),
                      padding: EdgeInsets.all(15),
                      //width: 750,
                      child: Center(
                          child: Text(pesan["content"] ?? '',
                              softWrap: true,
                              style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black
                                      .withOpacity(sayaSendiri ? 1 : 0.8)))))
                ]),
            Text(
              '${timeAgoSinceDate(DateTime.fromMillisecondsSinceEpoch(pesan["createdAt"] ?? DateTime.now().millisecond))}',
              style: TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
                  fontWeight: FontWeight.w300),
            ),
          ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    // by the _onFabKlik method above.
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        child: Column(
          children: [
            Text("baka chat logs"),
            TextButton(onPressed: () => showAlertDialog(context, judul: "Change name", ketikaOk: _gantiNama, konten: TextField(
            controller: _inputNewUsernameController,
            decoration: InputDecoration(hintText: "New username"),
          )), 
          child: Text("Account", style: TextStyle(fontSize: 15),)),
            TextButton(onPressed: _logOut, child: Text("Log out")),
            SizedBox(height: height * 0.05),
            Flexible(
              child: buildMessageList(),
            ),
            Container(
                height: 50,
                margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: TextFormField(
                    controller: _inputChatController,
                    decoration: InputDecoration(
                        labelText: 'Send message',
                        hintText: "Send a message",
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(
                          9.0,
                        )),
                    onFieldSubmitted: (value) => _sendMessage(),
                    onChanged: (value) {},
                    textInputAction: TextInputAction.send,
                  ),
                )),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onFabKlik,
        tooltip: 'Send',
        child: Icon(Icons.send),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  showAlertDialog(BuildContext context,
      {String alasan = "Dialog box...", String judul = "Notice", List<Widget> childLain = const [], Widget? konten, Function? ketikaOk }) {
    // default
    Widget okButton = TextButton(
      child: Text("Oke"),
      onPressed: () {
        (ketikaOk??(){})();
        Navigator.of(context).pop();
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text(judul),
      content: konten ?? Text(alasan),
      actions: [
        okButton,
        ...childLain
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

  _gantiNama() async {
    if (_inputNewUsernameController.text.trim().isNotEmpty) {
      final prefsDisk = await SharedPreferences.getInstance();
      gantiNama(_inputNewUsernameController.text, prefsDisk.getString("loginToken") ?? "nothing").then((value) {
          print(value);
      }).onError((error, stackTrace) {
        print(error);
      });
    }
  }

  void _sendMessage() async {
    final prefsDisk = await SharedPreferences.getInstance();
    if (_inputChatController.text.trim().isNotEmpty) {
      print("sending");
      socketIO.emit("message", {
        "content": _inputChatController.text.trim(),
        "_clientToken": prefsDisk.getString("loginToken") ?? "nothing"
      });
      _inputChatController.text = "";
      //streamSocket.sink.add(_textController.text);
    }
  }

  /*void _updateTyping() {

  }*/
}

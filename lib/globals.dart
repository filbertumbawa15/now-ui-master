library my_prj.globals;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:material_dialogs/material_dialogs.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:now_ui_flutter/api/notification_api.dart';
import 'package:pusher_client/pusher_client.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';

bool loggedIn = false;
SharedPreferences prefs;
SharedPreferences prefsPassword;
String merchantid;
String merchantpassword;
String merchantidInvoice;
String merchantpasswordInvoice;
var loggedinId;
String loggedinName;
String loggedinUser;
String loggedinTelp;
String condition = "false";
String url = 'https://web.transporindo.com';
String fcmToken;
String verificationStatus;
String loggedinEmail;
String accessToken;
// int user_id;
String password;
bool hasConnection = false;
String apikey;
DateTime dateAus;

//user Verification Denied
File npwpPath;
File ktpPath;
String nik;
String nama;
String alamatdetail;
String tglLahir;
String npwp;
String keteranganverifikasi;

Route createRoute(Widget parameters) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => parameters,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 1.0);
      const end = Offset.zero;
      const curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

NotificationService notificationService = NotificationService();

Widget badges(String condition) {
  if (condition == "false") {
    return new Positioned(
        top: -1.0,
        right: -1.0,
        child: new Stack(
          children: <Widget>[
            new Icon(
              Icons.brightness_1,
              size: 12.0,
              color: Color.fromARGB(255, 9, 134, 236),
            ),
          ],
        ));
  } else {
    return new Positioned(
        top: -1.0,
        right: -1.0,
        child: new Stack(
          children: <Widget>[
            new Icon(
              Icons.brightness_1,
              size: 12.0,
              color: Color.fromARGB(255, 223, 7, 7),
            ),
          ],
        ));
  }
}

Future<void> alertBerhasilPesan(
    BuildContext context, String keterangan, String title, String path) {
  return Dialogs.materialDialog(
      color: Colors.white,
      msg: keterangan,
      title: title,
      lottieBuilder: Lottie.asset(
        path,
        fit: BoxFit.contain,
      ),
      context: context,
      actions: [
        IconsButton(
          onPressed: () {
            Navigator.pop(context);
          },
          text: 'Ok',
          iconData: Icons.done,
          color: Colors.blue,
          textStyle: TextStyle(color: Colors.white),
          iconColor: Colors.white,
        ),
      ]);
}

Future<void> checkConnection(
    BuildContext context, String keterangan, String title, String path) {
  Dialogs.materialDialog(
      color: Colors.white,
      msg: keterangan,
      title: title,
      lottieBuilder: Lottie.asset(
        path,
        fit: BoxFit.contain,
      ),
      context: context,
      actions: [
        IconsButton(
          onPressed: () {
            Navigator.pop(context);
          },
          text: 'Coba Lagi',
          iconData: Icons.done,
          color: Colors.blue,
          textStyle: TextStyle(color: Colors.white),
          iconColor: Colors.white,
        ),
      ]);
}

Widget triggerActions(BuildContext context, String keterangan, String title,
    String path, List<Widget> actions) {
  Dialogs.materialDialog(
      color: Colors.white,
      msg: keterangan,
      title: title,
      lottieBuilder: Lottie.asset(
        path,
        fit: BoxFit.contain,
      ),
      context: context,
      actions: actions);
}

PusherClient pusher = PusherClient(
  'fb913a9aba0a5bb3e326',
  PusherOptions(
    cluster: 'ap1',
  ),
);
Channel channel = pusher.subscribe("data-channel");

Widget alert(BuildContext context, String message) {
  Alert(
    context: context,
    type: AlertType.error,
    title: "Error",
    desc: message,
    buttons: [
      DialogButton(
        child: Text(
          "OK",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        onPressed: () => Navigator.pop(context),
        width: 120,
      )
    ],
  ).show();
}

Widget alertReqButtons(
    BuildContext context, String message, List<DialogButton> buttons) {
  Alert(
    context: context,
    type: AlertType.error,
    title: "Error",
    desc: message,
    buttons: buttons,
  ).show();
}

void printWrapped(String text) {
  final pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
  pattern.allMatches(text).forEach((match) => print(match.group(0)));
}

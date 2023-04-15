import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:material_dialogs/material_dialogs.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:now_ui_flutter/constants/Theme.dart';
import 'dart:async';
import 'package:now_ui_flutter/globals.dart' as globals;
import 'package:now_ui_flutter/screens/home.dart';
import 'package:now_ui_flutter/services/UserService.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Onboarding extends StatefulWidget {
  @override
  _OnboardingState createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  @override
  Future<void> setupInteractedMessage() async {
    RemoteMessage initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  @override
  @override
  void _handleMessage(RemoteMessage message) {
    if (message.data['type'] == '/list_pesanan') {
      Navigator.pushNamed(context, '/list_pesanan');
    }
  }

  @override
  void initState() {
    super.initState();
    onboarding();
    setupInteractedMessage();
  }

  void onboarding() async {
    globals.prefsPassword = await SharedPreferences.getInstance();
    globals.password = globals.prefsPassword.getString('password');
    globals.prefs = await SharedPreferences.getInstance();
    if (globals.prefs.getString('user') != null) {
      globals.pusher.connect();
      globals.pusher.onConnectionStateChange((state) {
        print("currentState: ${state?.currentState} -- -- ");
      });
      globals.pusher.onConnectionError((error) {
        print("error: ${error.message}");
      });
      globals.loggedinEmail =
          jsonDecode(globals.prefs.getString('user'))['email'];
      globals.loggedinUser =
          jsonDecode(globals.prefs.getString('user'))['user'];
      globals.loggedinId = jsonDecode(globals.prefs.getString('user'))['id'];
      await checkVerification(globals.loggedinEmail).then((value) async {
        await apikey().then((value) async {
          await getToken(context).then((value) async {
            await editVerifikasi();
            Navigator.pushReplacementNamed(context, '/home');
          });
        });
      });
    } else {
      await apikey().then((value) async {
        Timer(const Duration(seconds: 2), () {
          Navigator.pushReplacementNamed(context, '/home');
        });
      });
    }
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Color(0xFFF1F1EF),
          ),
        ),
        SafeArea(
          child: Container(
            padding: EdgeInsets.only(
              left: 16.0,
              right: 16.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Image.asset(
                      "assets/imgs/taslogo.png",
                      scale: 3.5,
                      width: 94.0,
                      height: 84.0,
                    ),
                    SizedBox(height: 6.0),
                    Container(
                        child: Center(
                            child: Column(
                      children: [
                        Container(
                            child: Text("PT.TRANSPORINDO AGUNG SEJAHTERA",
                                style: TextStyle(
                                    color: NowUIColors.black,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Nunito-ExtraBold',
                                    fontSize: 15.0))),
                      ],
                    ))),
                  ],
                ),
              ],
            ),
          ),
        )
      ],
    ));
  }
}

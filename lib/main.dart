import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mask_for_camera_view/mask_for_camera_view.dart';
import 'package:now_ui_flutter/api/notification_api.dart';
import 'package:now_ui_flutter/providers/scanner_provider.dart';
import 'package:now_ui_flutter/screens/CekOngkir/asal_ongkir.dart';
import 'package:now_ui_flutter/screens/CekOngkir/tujuan_ongkir.dart';
import 'package:now_ui_flutter/screens/Chats/chats.dart';
import 'package:now_ui_flutter/screens/VerificationData/home_verifikasi.dart';
import 'package:now_ui_flutter/screens/asal.dart';
import 'package:now_ui_flutter/screens/faq.dart';
import 'package:now_ui_flutter/screens/favorites_list.dart';
import 'package:now_ui_flutter/screens/notifications.dart';
import 'package:now_ui_flutter/screens/otp_verification.dart';
import 'package:now_ui_flutter/screens/listpesanan.dart';
import 'package:now_ui_flutter/screens/payment_success.dart';
import 'package:now_ui_flutter/screens/syaratketentuan.dart';
import 'package:now_ui_flutter/screens/tujuan.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:now_ui_flutter/providers/services.dart';
// import 'package:now_ui_flutter/screens/asal.dart';
import 'package:now_ui_flutter/screens/bayar.dart';
import 'package:now_ui_flutter/screens/CekOngkir/harga.dart';

// screens
import 'package:now_ui_flutter/screens/onboarding.dart';
import 'package:now_ui_flutter/screens/home.dart';
import 'package:now_ui_flutter/screens/register.dart';
import 'package:now_ui_flutter/screens/CekOngkir/ongkir.dart';
import 'package:now_ui_flutter/screens/order.dart';
import 'package:now_ui_flutter/screens/Login/login.dart';
import 'package:now_ui_flutter/screens/total.dart';
// import 'package:now_ui_flutter/screens/tujuan.dart';
import 'globals.dart' as globals;
import 'package:firebase_core/firebase_core.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling background message ${message.messageId}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MaskForCameraView.initialize();
  await Firebase.initializeApp();
  await FirebaseMessaging.instance.getInitialMessage();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  NotificationService().init();
  HttpOverrides.global = new MyHttpOverrides();
  runApp(new MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
    super.initState();
    _isAndroidPermissionGranted();
    requestPermission();
    initInfo();
  }

  Future<void> _isAndroidPermissionGranted() async {
    if (Platform.isAndroid) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
    }
  }

  initInfo() {
    var androidInitialize =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    var iOSInitialize = const IOSInitializationSettings();
    var initInitializationSettings =
        InitializationSettings(android: androidInitialize, iOS: iOSInitialize);
    flutterLocalNotificationsPlugin.initialize(initInitializationSettings,
        onSelectNotification: (String payload) async {
      try {
        if (payload != null && payload.isNotEmpty) {
        } else {}
      } catch (e) {}
      return;
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print("----------------------onMessage----------------------");
      print(
          'onMessage : ${message.notification?.title}/${message.notification?.body}');

      BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
        message.notification.body.toString(),
        htmlFormatBigText: true,
        contentTitle: message.notification.title.toString(),
        htmlFormatContentTitle: true,
      );
      AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'dbfood',
        'dbfood',
        importance: Importance.max,
        styleInformation: bigTextStyleInformation,
        priority: Priority.max,
        playSound: false,
      );
      NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);
      await flutterLocalNotificationsPlugin.show(0, message.notification?.title,
          message.notification?.body, platformChannelSpecifics,
          payload: message.data['body']);
    });
  }

  void requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print("User granted permission");
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print("User granted provosional permission");
    } else {
      print("User declined or has not accepted permission");
    }
  }

  @override
  Widget build(BuildContext context) {
    return OverlaySupport.global(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => MasterProvider(),
          ),
          ChangeNotifierProvider(
            create: (_) => ScannerProvider(),
          )
        ],
        child: MaterialApp(
            title: 'TAS Orderan',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              fontFamily: 'Nunito-Medium',
              primarySwatch: Colors.blue,
              inputDecorationTheme: InputDecorationTheme(
                contentPadding: EdgeInsets.symmetric(vertical: 15),
              ),
            ),
            initialRoute: '/onboarding',
            routes: <String, WidgetBuilder>{
              '/home': (BuildContext context) => new Home(),
              '/harga': (BuildContext context) => new Harga(),
              "/onboarding": (BuildContext context) => new Onboarding(),
              "/profiles": (BuildContext context) => new Profiles(),
              "/ongkir": (BuildContext context) => new Ongkir(),
              "/order": (BuildContext context) => new Order(),
              "/asal_ongkir": (BuildContext context) => new Asal_Ongkir(),
              "/tujuan_ongkir": (BuildContext context) => new Tujuan_Ongkir(),
              "/login": (BuildContext context) => new Login(),
              "/register": (BuildContext context) => new Register(),
              "/total": (BuildContext context) => new Total(),
              "/bayar": (BuildContext context) => new Bayar(),
              "/otp_verification": (BuildContext context) =>
                  new OtpVerification(),
              "/payment_success": (BuildContext context) =>
                  new PaymentSuccess(),
              "/list_pesanan": (BuildContext context) => new ListPesanan(),
              "/chats": (BuildContext context) => new Chats(),
              "/syaratdanketentuan": (BuildContext context) =>
                  new SyaratKetentuanWidget(),
              "/faq": (BuildContext context) => new Faq(),
              "/favoritesList": (BuildContext context) => new FavoritesList(),
              "/notifications": (BuildContext context) => new Notifications(),
              "/homeverifikasi": (BuildContext context) => new HomeVerifikasi(),
              "/asal": (BuildContext context) => new Asal(),
              "/tujuan": (BuildContext context) => new Tujuan(),
            }),
      ),
    );
  }
}

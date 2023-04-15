import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:material_dialogs/material_dialogs.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:now_ui_flutter/screens/Login/email_verification.dart';
import 'package:now_ui_flutter/screens/otp_verification.dart';
import 'package:now_ui_flutter/widgets/transition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:now_ui_flutter/globals.dart' as globals;
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

final _auth = FirebaseAuth.instance;

void authUser(
  context,
  String email,
  String password,
  SimpleFontelicoProgressDialog _dialog,
) async {
  try {
    final response = await http.post(
      Uri.parse('${globals.url}/api-orderemkl/public/api/auth/login'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        'email': email,
        'password': password,
        'fcm_token': globals.fcmToken,
      }),
    );

    final decodedResponse = jsonDecode(response.body);

    if (response.statusCode == 200) {
      _dialog.hide();
      globals.prefsPassword.setString('password', password);
      globals.prefs.setString('user', jsonEncode(decodedResponse['user']));
      // globals.loggedinId = jsonEncode(decodedResponse['user']['id']);
      // globals.loggedinUser = decodedResponse['user']['user'];
      // globals.loggedinName = jsonEncode(decodedResponse['user']['name']);
      // globals.verificationStatus =
      //     jsonEncode(decodedResponse['user']['statusverifikasi']);
    } else if (response.statusCode == 401) {
      _dialog.hide();
      globals.alert(context, decodedResponse["message"]);
    } else if (decodedResponse['errors']['email'] != null) {
      if (decodedResponse['errors']['email'][0] ==
          "email belum terverifikasi") {
        final response = await http.post(
          Uri.parse('${globals.url}/api-orderemkl/public/api/auth/resend'),
          headers: {
            'Accept': 'application/json',
          },
          body: {
            'data': jsonEncode({"email": email})
          },
        );

        final decodedResponse = jsonDecode(response.body);

        if (response.statusCode == 200) {
          _dialog.hide();
          await Navigator.of(context).pushReplacement(
            new MaterialPageRoute(
              settings: const RouteSettings(name: '/otp_verification'),
              builder: (context) => new OtpVerification(
                identifier: email,
                sendOTPVia: "email",
                email: email,
              ),
            ),
          );
        } else {
          _dialog.hide();
          Alert(
            context: context,
            type: AlertType.error,
            title: "Error",
            desc: decodedResponse['errors']['email'][0],
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
      } else {
        _dialog.hide();
        globals.alert(context, decodedResponse['errors']['email'][0]);
      }
    } else {
      _dialog.hide();
      globals.alert(context, decodedResponse["message"]);
    }
  } catch (e) {
    print(e);
  } finally {
    _dialog.hide();
  }
}

void register(
  context,
  String name,
  String phone,
  String email,
  String password,
  String sendOTPVia,
  SimpleFontelicoProgressDialog _dialog,
) async {
  String identifier;

  if (sendOTPVia == 'email') {
    identifier = email;
  } else if (sendOTPVia == 'wa') {
    identifier = phone;
  }

  try {
    final response = await http.post(
        Uri.parse('${globals.url}/api-orderemkl/public/api/auth/register'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json'
        },
        body: jsonEncode(
          {
            'name': name,
            'telp': phone,
            'email': email,
            'password': password,
            'send_otp_via': sendOTPVia,
          },
        ));

    final decodedResponse = jsonDecode(response.body);

    if (response.statusCode == 200) {
      _dialog.hide();
      // Navigator.of(context).pushReplacement(globals.createRoute(Login()));
      await Navigator.of(context).pushReplacement(
        new MaterialPageRoute(
          settings: const RouteSettings(name: '/otp_verification'),
          builder: (context) => new OtpVerification(
            identifier: identifier,
            sendOTPVia: sendOTPVia,
            email: email,
          ),
        ),
      );
    } else if (decodedResponse['errors']['email'] != null) {
      _dialog.hide();
      globals.alert(context, decodedResponse['errors']['email'][0]);
    } else if (decodedResponse['errors']['telp'] != null) {
      _dialog.hide();
      globals.alert(context, decodedResponse['errors']['telp'][0]);
    }
  } catch (e) {
    print(e);
  }
}

void verifyOtp(
  context,
  String otp,
  String identifier,
  String sendOTPVia,
  SimpleFontelicoProgressDialog _dialog,
) async {
  try {
    final response = await http.post(
      Uri.parse('${globals.url}/api-orderemkl/public/api/auth/verify_otp'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        'otp': otp,
        'identifier': identifier,
      }),
    );

    if (response.statusCode == 200) {
      _dialog.hide();
      Dialogs.materialDialog(
          color: Colors.white,
          msg:
              "Akun anda berhasil ter-verifikasi, silahkan login untuk melakukan pemesanan.",
          title: "Register Berhasil",
          lottieBuilder: Lottie.asset(
            'assets/imgs/updated-transaction.json',
            fit: BoxFit.contain,
          ),
          context: context,
          actions: [
            IconsButton(
              onPressed: () async {
                await Navigator.pushReplacementNamed(context, "/login");
              },
              text: 'Ok',
              iconData: Icons.done,
              color: Colors.blue,
              textStyle: TextStyle(color: Colors.white),
              iconColor: Colors.white,
            ),
          ]);
    } else {
      _dialog.hide();
      globals.alert(context, 'OTP tidak valid');
    }
  } catch (e) {
    print(e);
  } finally {
    _dialog.hide();
  }
}

void forgotPassword(
  context,
  String email,
  SimpleFontelicoProgressDialog _dialog,
) async {
  try {
    final response = await http.post(
      Uri.parse('${globals.url}/api-orderemkl/public/api/forgot-password'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        'email': email,
      }),
    );

    final decodedResponse = jsonDecode(response.body);

    if (response.statusCode == 200) {
      _dialog.hide();
      // EmailVerification
      Navigator.of(context).pushReplacement(EnterExitRoute(
          enterPage: EmailVerification(
        email: email,
      )));
    } else {
      _dialog.hide();
      Alert(
        context: context,
        type: AlertType.error,
        title: "Error",
        desc: decodedResponse['errors']['email'][0],
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
  } catch (e) {
    print(e);
  } finally {
    _dialog.hide();
  }
}

Future<void> getToken(context) async {
  try {
    final response = await http.post(
      Uri.parse('${globals.url}/api-orderemkl/public/api/token'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'user': globals.loggedinUser,
        'password': globals.password,
      }),
    );
    final getToken = jsonDecode(response.body);
    if (response.statusCode == 200) {
      globals.accessToken = getToken['access_token'];
    } else {
      globals.alert(context, getToken["message"]);
    }
  } catch (e) {
    print(e.toString());
  }
}

void editVerifikasi() async {
  try {
    final response = await http.get(
        Uri.parse(
            'http://web.transporindo.com/api-orderemkl/public/api/user/getdataverifikasi?id=${globals.loggedinId}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${globals.accessToken}',
        });
    final result = jsonDecode(response.body);
    if (response.statusCode == 200) {
      globals.npwpPath = await getnpwpImage(result['data']['foto_npwp']);
      globals.ktpPath = await getKtpImage(result['data']['foto_ktp']);
      globals.nik = result['data']['nik'];
      globals.nama = result['data']['name'];
      globals.alamatdetail = result['data']['alamatdetail'];
      globals.tglLahir = result['data']['tgl_lahir'];
      globals.npwp = result['data']['no_npwp'];
      globals.keteranganverifikasi =
          result['data']['keteranganverifikasi'] ?? "";
    } else {
      print("gagal");
      print(response.body);
    }
  } catch (e) {
    print(e.toString());
  }
}

Future<File> getnpwpImage(String npwp) async {
  var rng = new Random();
  Directory tempDir = await getTemporaryDirectory();
  String tempPath = tempDir.path;
  File file_npwp =
      new File('$tempPath' + (rng.nextInt(100)).toString() + '.jpg');
  http.Response response = await http.get(
      Uri.parse(
          '${globals.url}/api-orderemkl/public/api/user/image/npwp/$npwp'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${globals.accessToken}',
      });
  await file_npwp.writeAsBytes(response.bodyBytes);
  return file_npwp;
}

Future<File> getKtpImage(String ktp) async {
  var rng = new Random();
  Directory tempDir = await getTemporaryDirectory();
  String tempPath = tempDir.path;
  File file_ktp =
      new File('$tempPath' + (rng.nextInt(100)).toString() + '.jpg');
  http.Response response = await http.get(
      Uri.parse('${globals.url}/api-orderemkl/public/api/user/image/ktp/$ktp'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${globals.accessToken}',
      });
  await file_ktp.writeAsBytes(response.bodyBytes);
  return file_ktp;
}

Future<void> checkVerification(String email) async {
  try {
    final response = await http.get(
      Uri.parse(
          '${globals.url}/api-orderemkl/public/api/auth/getDataUser?email=$email'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${globals.accessToken}',
      },
    );
    var result = jsonDecode(response.body)['data'];
    globals.verificationStatus = result['statusverifikasi'].toString();
  } catch (e) {
    print(e.toString());
  }
}

void resend(
  context,
  String email,
  SimpleFontelicoProgressDialog _dialog,
) async {
  var data = {"email": email};
  try {
    final response = await http.post(
      Uri.parse('${globals.url}/api-orderemkl/public/api/auth/resend'),
      headers: {
        'Accept': 'application/json',
      },
      body: {'data': jsonEncode(data)},
    );

    final decodedResponse = jsonDecode(response.body);

    if (response.statusCode == 200) {
      _dialog.hide();
      globals.alertBerhasilPesan(
          context,
          "Pesan telah dikirim ke email anda, silahkan cek kode verifikasi ke email anda",
          'Kirim Pesan Email',
          'assets/imgs/send-email.json');
    } else {
      _dialog.hide();
      Alert(
        context: context,
        type: AlertType.error,
        title: "Error",
        desc: decodedResponse['errors']['email'][0],
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
  } catch (e) {
    print(e.toString());
  } finally {
    _dialog.hide();
  }
}

Future<void> apikey() async {
  final response = await http
      .get(Uri.parse('${globals.url}/api-orderemkl/public/api/auth/apiKey'));

  final result = jsonDecode(response.body);

  globals.apikey = result['apikey'];
}

import 'package:flutter/material.dart';
import 'package:now_ui_flutter/screens/Login/forgot_password.dart';
import 'package:now_ui_flutter/screens/register.dart';
import 'package:now_ui_flutter/services/UserService.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:now_ui_flutter/globals.dart' as globals;
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';

class Login extends StatefulWidget {
  SimpleFontelicoProgressDialog _dialog;
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool loggedIn = false;
  bool _passwordVisible;
  bool _isButtonDisabled;

  // get prefs => null;

  @override
  void initState() {
    super.initState();
    _setPrefs();
    _passwordVisible = true;
    _isButtonDisabled = true;
  }

  _setPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('user') != null) {
      await setState(() {
        loggedIn = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/imgs/bg-login.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      child: Container(
                        child: Image.asset(
                          "assets/imgs/taslogo.png",
                          fit: BoxFit.contain,
                          width: 100,
                        ),
                      ),
                    ),
                    Text(
                      'Selamat Datang',
                      style: TextStyle(
                          fontSize: 28.0, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      'Masuk ke Akun Anda',
                      style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Email",
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 1),
                          child: TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                hintStyle: TextStyle(color: Color(0xFF938D8D)),
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 10.0),
                                hintText: "Masukkan Email",
                                filled: true,
                                fillColor: Color(0xFFAEAEAE).withOpacity(0.65),
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8.0)),
                                  borderSide:
                                      BorderSide(color: Color(0xFFAEAEAE)),
                                ),
                              ),
                              onChanged: (val) {
                                if (val.isNotEmpty &&
                                    _passwordController.text.isNotEmpty) {
                                  setState(() {
                                    _isButtonDisabled = false;
                                  });
                                } else {
                                  setState(() {
                                    _isButtonDisabled = true;
                                  });
                                }
                              }),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Password",
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 1),
                          child: TextFormField(
                              controller: _passwordController,
                              decoration: InputDecoration(
                                hintStyle: TextStyle(color: Color(0xFF938D8D)),
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 10.0),
                                hintText: 'Masukkan Password',
                                filled: true,
                                fillColor: Color(0xFFAEAEAE).withOpacity(0.65),
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8.0)),
                                  borderSide:
                                      BorderSide(color: Color(0xFFAEAEAE)),
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    // Based on passwordVisible state choose the icon
                                    _passwordVisible
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Color(0xFF938D8D),
                                    size: 20.0,
                                  ),
                                  onPressed: () {
                                    // Update the state i.e. toogle the state of passwordVisible variable
                                    setState(() {
                                      _passwordVisible = !_passwordVisible;
                                    });
                                  },
                                ),
                              ),
                              obscureText: _passwordVisible,
                              onChanged: (val) {
                                if (val.isNotEmpty &&
                                    _emailController.text.isNotEmpty) {
                                  setState(() {
                                    _isButtonDisabled = false;
                                  });
                                } else {
                                  setState(() {
                                    _isButtonDisabled = true;
                                  });
                                }
                              }),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: EdgeInsets.only(top: 15),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF5599E9),
                          ),
                          onPressed: _isButtonDisabled
                              ? null
                              : () async {
                                  _showDialog(
                                      context,
                                      SimpleFontelicoProgressDialogType.normal,
                                      'Normal');
                                  await authUser(
                                    context,
                                    _emailController.text,
                                    _passwordController.text,
                                    widget._dialog,
                                  );

                                  await _setPrefs();

                                  if (loggedIn) {
                                    Navigator.of(context)
                                        .pushNamedAndRemoveUntil('/onboarding',
                                            (Route<dynamic> route) => false);
                                  } else {
                                    print('user logged out');
                                  }
                                },
                          child: Text(
                            'Login',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Belum punya akun? ",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          GestureDetector(
                            child: Text(
                              "Register",
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                                color: Color(0xFF5599E9),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            onTap: () {
                              Navigator.of(context).pushReplacement(
                                  globals.createRoute(Register()));
                            },
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            child: Text(
                              "Lupa Password",
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                                color: Color(0xFF5599E9),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            onTap: () {
                              Navigator.of(context).pushReplacement(
                                  globals.createRoute(ForgotPassword()));
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showDialog(BuildContext context, SimpleFontelicoProgressDialogType type,
      String text) async {
    if (widget._dialog == null) {
      widget._dialog = SimpleFontelicoProgressDialog(
          context: context, barrierDimisable: false);
    }
    if (type == SimpleFontelicoProgressDialogType.custom) {
      widget._dialog.show(
          message: text,
          type: type,
          width: 150.0,
          height: 75.0,
          loadingIndicator: Text(
            'C',
            style: TextStyle(fontSize: 24.0),
          ));
    } else {
      widget._dialog.show(
          message: text,
          type: type,
          horizontal: true,
          width: 150.0,
          height: 75.0,
          hideText: true,
          indicatorColor: Colors.blue);
    }
  }
}

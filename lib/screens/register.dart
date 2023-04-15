import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:now_ui_flutter/screens/Login/login.dart';
import 'package:now_ui_flutter/services/UserService.dart';
import 'package:now_ui_flutter/globals.dart' as globals;
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';

class Register extends StatefulWidget {
  SimpleFontelicoProgressDialog _dialog;
  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final TextEditingController _controllerName = TextEditingController();

  final TextEditingController _controllerPhone = TextEditingController();

  final TextEditingController _controllerEmail = TextEditingController();

  final TextEditingController _controllerPassword = TextEditingController();

  bool _isButtonDisabled;

  bool _passwordVisible;

  @override
  void initState() {
    super.initState();
    _passwordVisible = true;
    _isButtonDisabled = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.grey.shade50,
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
          image: AssetImage('assets/imgs/bg-login.jpg'),
          fit: BoxFit.cover,
        )),
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
                      'Register',
                      style: TextStyle(
                          fontSize: 28.0, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      'Buat Akun Baru',
                      style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Nama",
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 1),
                          child: TextFormField(
                              controller: _controllerName,
                              decoration: InputDecoration(
                                hintStyle: TextStyle(color: Color(0xFF938D8D)),
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 10.0),
                                hintText: "Masukkan Nama",
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
                                    _controllerPhone.text.isNotEmpty &&
                                    _controllerEmail.text.isNotEmpty &&
                                    _controllerPassword.text.isNotEmpty) {
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
                      height: 12.0,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "No. Telepon",
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 1),
                          child: TextFormField(
                              controller: _controllerPhone,
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(13),
                              ],
                              decoration: InputDecoration(
                                hintStyle: TextStyle(color: Color(0xFF938D8D)),
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 10.0),
                                hintText: "Masukkan Nomor Telepon",
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
                                    _controllerName.text.isNotEmpty &&
                                    _controllerEmail.text.isNotEmpty &&
                                    _controllerPassword.text.isNotEmpty) {
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
                      height: 12.0,
                    ),
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
                            controller: _controllerEmail,
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
                                  _controllerName.text.isNotEmpty &&
                                  _controllerEmail.text.isNotEmpty &&
                                  _controllerPassword.text.isNotEmpty) {
                                setState(() {
                                  _isButtonDisabled = false;
                                });
                              } else {
                                setState(() {
                                  _isButtonDisabled = true;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 12.0,
                    ),
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
                              controller: _controllerPassword,
                              decoration: InputDecoration(
                                hintStyle: TextStyle(color: Color(0xFF938D8D)),
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 10.0),
                                hintText: "Masukkan Password",
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
                                    _controllerName.text.isNotEmpty &&
                                    _controllerEmail.text.isNotEmpty &&
                                    _controllerPassword.text.isNotEmpty) {
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
                                  register(
                                    context,
                                    _controllerName.text,
                                    _controllerPhone.text,
                                    _controllerEmail.text,
                                    _controllerPassword.text,
                                    'email',
                                    widget._dialog,
                                  );
                                },
                          child: Text(
                            'Register',
                            style: TextStyle(fontWeight: FontWeight.bold),
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
                            "Sudah punya akun? ",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          GestureDetector(
                            child: Text(
                              "login",
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                                color: Color(0xFF5599E9),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            onTap: () {
                              Navigator.of(context).pushReplacement(
                                  globals.createRoute(Login()));
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

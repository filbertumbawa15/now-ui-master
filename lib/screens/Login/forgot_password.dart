import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:now_ui_flutter/constants/Theme.dart';
import 'package:http/http.dart' as http;
import 'package:now_ui_flutter/globals.dart' as globals;
import 'package:now_ui_flutter/services/UserService.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';

class ForgotPassword extends StatefulWidget {
  SimpleFontelicoProgressDialog _dialog;
  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  TextEditingController _selectedalamatemail = new TextEditingController();
  bool _isButtonDisabled;

  @override
  void initState() {
    super.initState();
    _isButtonDisabled = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(15.0),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/imgs/bg-login.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "Lupa Password",
                style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 30.0,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Masukkan Email Anda",
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 1),
                    child: TextFormField(
                        controller: _selectedalamatemail,
                        decoration: InputDecoration(
                          hintStyle: TextStyle(color: Color(0xFF938D8D)),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 10.0),
                          hintText: "Email",
                          filled: true,
                          fillColor: Color(0xFFAEAEAE).withOpacity(0.65),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(8.0)),
                            borderSide: BorderSide(color: Color(0xFFAEAEAE)),
                          ),
                        ),
                        onChanged: (val) {
                          if (val.isNotEmpty) {
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
                height: 5.0,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.height / 2.15,
                child: Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 15),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      textStyle: TextStyle(
                        color: NowUIColors.white,
                      ),
                      backgroundColor: Color(0xFF5599E9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                    ),
                    onPressed: _isButtonDisabled
                        ? null
                        : () async {
                            _showDialog(
                                context,
                                SimpleFontelicoProgressDialogType.normal,
                                'Normal');
                            forgotPassword(
                              context,
                              _selectedalamatemail.text,
                              widget._dialog,
                            );
                          },
                    //  () async {
                    //   _isButtonDisabled == true
                    //       ? null
                    //       : _showDialog(context,
                    //           SimpleFontelicoProgressDialogType.normal, 'Normal');
                    //   forgotPassword(
                    //     context,
                    //     _selectedalamatemail.text,
                    //     widget._dialog,
                    //   );
                    // },
                    child: Padding(
                      padding: EdgeInsets.only(
                          left: 16.0, right: 16.0, top: 12, bottom: 12),
                      child: Text(
                        "Kirim Email",
                        style: TextStyle(
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
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

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:now_ui_flutter/constants/Theme.dart';
import 'package:now_ui_flutter/constants/constant.dart';
import 'package:now_ui_flutter/screens/VerificationData/data_verifikasi.dart';
import 'package:now_ui_flutter/screens/VerificationData/ktp_verifikasi.dart';

class HomeVerifikasi extends StatefulWidget {
  const HomeVerifikasi({Key key}) : super(key: key);

  @override
  State<HomeVerifikasi> createState() => _HomeVerifikasiState();
}

class _HomeVerifikasiState extends State<HomeVerifikasi> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFF1F1EF),
        elevation: 0,
        centerTitle: true,
        leading: new IconButton(
          icon: new Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      backgroundColor: Color(0xFFF1F1EF),
      body: Container(
        alignment: Alignment.topCenter,
        child: Column(
          children: <Widget>[
            SizedBox(height: 15.0),
            Text("Verifikasi User",
                style:
                    TextStyle(fontFamily: 'Nunito-ExtraBold', fontSize: 18.0)),
            Padding(
              padding: EdgeInsets.all(3.0),
              child: Text(
                'Untuk menjalankan pesanan, ada 3 tahap agar dapat mengidentifikasi user anda. ',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF9F9F9F)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(35.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(15.0)),
                  color: Colors.white,
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              child: const Icon(
                                Icons.credit_card,
                                color: Color(0xFF5599E9),
                                size: 50.0,
                              ),
                            ),
                            Container(
                              height: 50.0,
                              child: VerticalDivider(
                                color: Color(0xFFAEAEAE),
                                thickness: 1,
                              ),
                            ),
                            Container(
                              child: const Icon(
                                Icons.credit_card,
                                color: Color(0xFF5599E9),
                                size: 50.0,
                              ),
                            ),
                            Container(
                              height: 50.0,
                              child: VerticalDivider(
                                color: Color(0xFFAEAEAE),
                                thickness: 1,
                              ),
                            ),
                            Container(
                              child: const Icon(
                                Icons.account_box,
                                color: Color(0xFF5599E9),
                                size: 50.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              child: const Text(
                                "Scan Foto KTP",
                                style: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Container(
                              height: 80.0,
                            ),
                            Container(
                              child: const Text(
                                "Scan Foto npwp",
                                style: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Container(
                              height: 80.0,
                            ),
                            Container(
                              child: const Text(
                                "Perlengkapan Data Diri",
                                style: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          width: 300,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF5599E9),
              textStyle: TextStyle(
                color: NowUIColors.white,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.0),
              ),
            ),
            onPressed: () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: ((context) => KtpVerification())));
            },
            child: Padding(
                padding: EdgeInsets.only(
                    left: 16.0, right: 16.0, top: 12, bottom: 12),
                child: Text("Mulai Sekarang",
                    style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Nunito-Medium'))),
          ),
        ),
      ),
    );
  }
}

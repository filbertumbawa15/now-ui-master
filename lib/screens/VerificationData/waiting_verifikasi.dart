import 'package:flutter/material.dart';
import 'package:now_ui_flutter/screens/home.dart';

class WaitingVerifikasi extends StatefulWidget {
  const WaitingVerifikasi({Key key}) : super(key: key);

  @override
  State<WaitingVerifikasi> createState() => _WaitingVerifikasiState();
}

class _WaitingVerifikasiState extends State<WaitingVerifikasi> {
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
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: ((context) => Home())));
          },
        ),
      ),
      backgroundColor: Color(0xFFF1F1EF),
      body: Container(
        child: Center(
          child: Column(
            children: <Widget>[
              SizedBox(height: MediaQuery.of(context).size.height / 10),
              Image.asset(
                'assets/imgs/process-file.png',
                width: 300.0,
                height: 230.0,
              ),
              Text(
                'Terima Kasih',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25.0),
              ),
              Padding(
                padding: EdgeInsets.only(
                    left: 15.0, top: 5.0, right: 15.0, bottom: 18.0),
                child: Text(
                  'Data anda sedang diproses oleh pihak admin, \n silahkan menunggu sampai pihak Transporindo mengonfirmasi anda kembali',
                  textAlign: TextAlign.center,
                  // style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25.0),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                width: 350.0,
                child: Padding(
                  padding: EdgeInsets.only(top: 15),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF5599E9),
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: ((context) => Home())));
                    },
                    child: Text('OK'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

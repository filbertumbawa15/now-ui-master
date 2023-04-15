import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:now_ui_flutter/constants/Theme.dart';
import 'package:now_ui_flutter/constants/constant.dart';

class RefundDetailBiaya extends StatefulWidget {
  final double nominaltransaksi;
  final double nominalrefund;
  const RefundDetailBiaya({
    Key key,
    this.nominaltransaksi,
    this.nominalrefund,
  }) : super(key: key);

  @override
  State<RefundDetailBiaya> createState() => _RefundDetailBiayaState();
}

class _RefundDetailBiayaState extends State<RefundDetailBiaya> {
  int biayakeluar;

  @override
  void initState() {
    super.initState();
    biayakeluar =
        widget.nominaltransaksi.toInt() - widget.nominalrefund.toInt();
    // print(int.parse(widget.nominaltransaksi));
    // print(int.parse(widget.nominaltransaksi) - int.parse(widget.nominalrefund));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_outlined,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Refund Detail Biaya",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            SizedBox(height: 30.0),
            Padding(
              padding: EdgeInsets.all(6.0),
              child: Text(
                "Biaya refund sudah dipotong biaya admin, berikut informasinya",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(),
              ),
            ),
            Container(
              height: 90.0,
              width: deviceWidth(context),
              margin: EdgeInsets.only(
                  left: 10.0, right: 10.0, top: 16.0, bottom: 0.0),
              child: new Column(
                children: <Widget>[
                  Container(
                    height: 90.0,
                    width: deviceWidth(context),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 12.0),
                        Column(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(left: 15.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    "Biaya Transaksi",
                                    style: GoogleFonts.poppins(
                                      fontSize: 15.0,
                                    ),
                                  ),
                                  SizedBox(height: 10.0),
                                  Text(
                                    NumberFormat.currency(
                                            locale: 'id',
                                            symbol: 'Rp. ',
                                            decimalDigits: 00)
                                        .format(double.tryParse(widget
                                            .nominaltransaksi
                                            .toInt()
                                            .toString())),
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 25.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    decoration: new BoxDecoration(
                      color: Color.fromARGB(255, 255, 255, 255),
                      shape: BoxShape.rectangle,
                      borderRadius: new BorderRadius.circular(10.0),
                      boxShadow: <BoxShadow>[
                        new BoxShadow(
                          color: Colors.black12,
                          blurRadius: 5.0,
                          offset: new Offset(0.0, 3.0),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 90.0,
              width: deviceWidth(context),
              margin: EdgeInsets.only(
                  left: 10.0, right: 10.0, top: 16.0, bottom: 0.0),
              child: new Column(
                children: <Widget>[
                  Container(
                    height: 90.0,
                    width: deviceWidth(context),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 12.0),
                        Column(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(left: 15.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    "Biaya yang keluar",
                                    style: GoogleFonts.poppins(
                                      fontSize: 15.0,
                                    ),
                                  ),
                                  SizedBox(height: 10.0),
                                  Text(
                                    NumberFormat.currency(
                                            locale: 'id',
                                            symbol: 'Rp. ',
                                            decimalDigits: 00)
                                        .format(double.tryParse(
                                            biayakeluar.toString())),
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 25.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    decoration: new BoxDecoration(
                      color: Color.fromARGB(255, 255, 255, 255),
                      shape: BoxShape.rectangle,
                      borderRadius: new BorderRadius.circular(10.0),
                      boxShadow: <BoxShadow>[
                        new BoxShadow(
                          color: Colors.black12,
                          blurRadius: 5.0,
                          offset: new Offset(0.0, 3.0),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30.0),
            Text(
              "Biaya yang dikembalikan",
              style: GoogleFonts.poppins(
                fontSize: 16.0,
              ),
            ),
            Text(
              NumberFormat.currency(
                      locale: 'id', symbol: 'Rp. ', decimalDigits: 00)
                  .format(
                      double.tryParse(widget.nominalrefund.toInt().toString())),
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 40.0,
              ),
            ),
            SizedBox(height: 30.0),
            Padding(
              padding: const EdgeInsets.all(3.0),
              child: Text(
                "Biaya yang sudah dikeluarkan adalah biaya pemesanan container, dan tidak dapat dikembalikan lagi.",
                style: GoogleFonts.poppins(),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 15.0),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child:
                  Icon(Icons.arrow_back_ios_new_outlined, color: Colors.white),
              style: ElevatedButton.styleFrom(
                shape: CircleBorder(),
                padding: EdgeInsets.all(15),
                primary: NowUIColors.info,
              ),
            )
          ],
        ),
      ),
    );
  }
}

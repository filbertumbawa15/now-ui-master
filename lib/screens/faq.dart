import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Faq extends StatefulWidget {
  const Faq({Key key}) : super(key: key);

  @override
  State<Faq> createState() => _FaqState();
}

class _FaqState extends State<Faq> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: Color(0xFFB7B7B7),
            )),
        title: Text(
          "Bantuan",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18.0,
            fontFamily: 'Nunito-Medium',
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      backgroundColor: Color(0xFFF1F1EF),
      body: Container(
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 30.0),
            Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                    ),
                    child: const ExpansionTile(
                      title: Text(
                        'Bagaimana cara pembayaran orderan tersebut',
                      ),
                      children: <Widget>[
                        ListTile(
                            title: Padding(
                          padding: EdgeInsets.all(3.0),
                          child: Text(
                            'Pembayaran tersebut dilakukan setelah shipper memilih jenis pembayaran yang dilakukan. Setelah itu, shipper akan diberikan No. Virtual Account yang digunakan untuk melakukan pembayaran sesuai dengan jenis VA yang dipilih oleh shipper sebelumnya',
                            textAlign: TextAlign.justify,
                          ),
                        )),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                    ),
                    child: const ExpansionTile(
                      title: Text(
                        'Bagaimana cara menggunakan sistem cek ongkir',
                      ),
                      children: <Widget>[
                        ListTile(
                            title: Text(
                          'Cek ongkir berfungsi untuk mengecek harga dari lokasi muat hingga lokasi tujuan tanpa harus login terlebih dahulu',
                          textAlign: TextAlign.justify,
                        )),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                    ),
                    child: const ExpansionTile(
                      title: Text('Kenapa harus verifikasi data KTP dan npwp'),
                      children: <Widget>[
                        ListTile(
                            title: Text(
                          'Fungsi verifikasi KTP dan npwp adalah untuk pengecekan data terhadap pihak Transporindo. Jika sudah di verifikasi, maka shipper sudah bisa melakukan orderan',
                          textAlign: TextAlign.justify,
                        )),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

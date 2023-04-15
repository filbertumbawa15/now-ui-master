import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:now_ui_flutter/providers/services.dart';
import 'package:now_ui_flutter/screens/home.dart';
import 'package:now_ui_flutter/screens/payment_success.dart';
import 'package:provider/provider.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';

class SuccessPay extends StatefulWidget {
  final String harga_bayar;
  final String noVA;
  final String nobukti;
  final int payment_status;
  final String alamat_asal;
  final String note_pengirim;
  final String pengirim;
  final String notelppengirim;
  final String alamat_tujuan;
  final String note_penerima;
  final String penerima;
  final String notelppenerima;
  final String order_date;
  final String payment_date;
  final String payment_code;
  final String link;
  final String latitude_pelabuhan_asal;
  final String longitude_pelabuhan_asal;
  final String latitude_pelabuhan_tujuan;
  final String longitude_pelabuhan_tujuan;
  final String latitude_muat;
  final String longitude_muat;
  final String latitude_bongkar;
  final String longitude_bongkar;
  final double nominalrefund;
  final String buktipdf;
  final String lampiraninvoice;
  final String placeidasal;
  final String pelabuhanidasal;
  final String jarak_asal;
  final String waktu_asal;
  final String namapelabuhanmuat;
  final String namapelabuhanbongkar;
  final String placeidtujuan;
  final String pelabuhanidtujuan;
  final String jarak_tujuan;
  final String waktu_tujuan;
  final String container_id;
  final String nilaibarang;
  final String qty;
  final String jenisbarang;
  final String namabarang;
  final String keterangantambahan;
  final List<dynamic> invoicetambahan;
  const SuccessPay({
    Key key,
    this.harga_bayar,
    this.noVA,
    this.payment_status,
    this.alamat_asal,
    this.alamat_tujuan,
    this.order_date,
    this.payment_date,
    this.payment_code,
    this.link,
    this.latitude_pelabuhan_asal,
    this.longitude_pelabuhan_asal,
    this.latitude_pelabuhan_tujuan,
    this.longitude_pelabuhan_tujuan,
    this.latitude_muat,
    this.longitude_muat,
    this.latitude_bongkar,
    this.longitude_bongkar,
    this.nobukti,
    this.note_pengirim,
    this.pengirim,
    this.notelppengirim,
    this.note_penerima,
    this.penerima,
    this.notelppenerima,
    this.nominalrefund,
    this.buktipdf,
    this.lampiraninvoice,
    this.placeidasal,
    this.pelabuhanidasal,
    this.jarak_asal,
    this.waktu_asal,
    this.namapelabuhanmuat,
    this.namapelabuhanbongkar,
    this.placeidtujuan,
    this.pelabuhanidtujuan,
    this.jarak_tujuan,
    this.waktu_tujuan,
    this.container_id,
    this.nilaibarang,
    this.qty,
    this.jenisbarang,
    this.namabarang,
    this.keterangantambahan,
    this.invoicetambahan,
  }) : super(key: key);

  @override
  State<SuccessPay> createState() => _SuccessPayState();
}

class _SuccessPayState extends State<SuccessPay> {
  SimpleFontelicoProgressDialog _dialog;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(widget.nobukti);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFF1F1EF),
        elevation: 0,
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => Home(),
                  ),
                  (route) => false);
            },
            child: Padding(
              padding: EdgeInsets.only(right: 15.0),
              child: Icon(
                Icons.close,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Color(0xFFF1F1EF),
      body: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: Color(0xFF5599E9),
              radius: 60.0,
              child: Icon(
                Icons.check,
                size: 90.0,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 10.0),
            Text(
              "Payment Success !",
              style: TextStyle(
                color: Colors.black,
                fontFamily: 'Nunito-Extrabold',
                fontSize: 30.0,
              ),
            ),
            SizedBox(height: 180.0),
            // InkWell(
            //   onTap: () async {
            //     _showDialog(context, SimpleFontelicoProgressDialogType.normal,
            //         'Normal');
            //     await Provider.of<MasterProvider>(context, listen: false)
            //         .listPesananRow(widget.nobukti)
            //         .then((value) async {
            //       _dialog.hide();
            //       Navigator.pushAndRemoveUntil(
            //           context,
            //           MaterialPageRoute(
            //               builder: (context) => PaymentSuccess(
            //                     harga_bayar: value.harga,
            //                     noVA: value.nobukti,
            //                     nobukti: value.nobukti,
            //                     payment_status: int.parse(value.payment_status),
            //                     alamat_asal: value.alamat_asal,
            //                     alamat_tujuan: value.alamat_tujuan,
            //                     order_date: value.order_date,
            //                     payment_date: value.payment_date,
            //                     payment_code: widget.payment_code,
            //                     link: 'Orderan',
            //                     latitude_pelabuhan_asal:
            //                         value.latitude_pelabuhan_asal,
            //                     longitude_pelabuhan_asal:
            //                         value.longitude_pelabuhan_asal,
            //                     latitude_pelabuhan_tujuan:
            //                         value.latitude_pelabuhan_tujuan,
            //                     longitude_pelabuhan_tujuan:
            //                         value.longitude_pelabuhan_tujuan,
            //                     latitude_muat: value.latitude_muat,
            //                     longitude_muat: value.longitude_muat,
            //                     latitude_bongkar: value.latitude_bongkar,
            //                     longitude_bongkar: value.longitude_bongkar,
            //                     notelppengirim: value.notelppengirim,
            //                     pengirim: value.pengirim,
            //                     penerima: value.penerima,
            //                     notelppenerima: value.notelppenerima,
            //                     buktipdf: value.buktipdf,
            //                     note_pengirim: value.notepengirim,
            //                     note_penerima: value.notepenerima,
            //                     invoicetambahan: value.invoiceTambahan,
            //                   )),
            //           (route) => false);
            //     });
            //   },
            //   child: Text(
            //     "Check Detail Order",
            //     style: TextStyle(
            //       color: Color(0xFF5599E9),
            //       fontFamily: 'Nunito-Medium',
            //       fontWeight: FontWeight.bold,
            //       decoration: TextDecoration.underline,
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  void _showDialog(BuildContext context, SimpleFontelicoProgressDialogType type,
      String text) async {
    if (_dialog == null) {
      _dialog = SimpleFontelicoProgressDialog(
          context: context, barrierDimisable: false);
    }
    if (type == SimpleFontelicoProgressDialogType.custom) {
      _dialog.show(
          message: text,
          type: type,
          width: 150.0,
          height: 75.0,
          loadingIndicator: Text(
            'C',
            style: TextStyle(fontSize: 24.0),
          ));
    } else {
      _dialog.show(
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

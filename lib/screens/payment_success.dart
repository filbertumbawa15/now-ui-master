import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:now_ui_flutter/api/Invoice/pdf_invoice_api.dart';
import 'package:now_ui_flutter/api/Invoice/pdf_invoicetambah_api.dart';
import 'package:now_ui_flutter/api/pdf_api.dart';
import 'package:now_ui_flutter/constants/Theme.dart';
import 'package:now_ui_flutter/models/dart_models.dart';
import 'package:now_ui_flutter/screens/CekOngkir/map_asal.dart';
import 'package:now_ui_flutter/screens/home.dart';
import 'package:now_ui_flutter/screens/payment_invoice_tambahan.dart';
import 'package:now_ui_flutter/screens/list_qty.dart';
import 'package:now_ui_flutter/screens/order.dart';
import 'package:now_ui_flutter/screens/pdfviewer.dart';
import 'package:now_ui_flutter/screens/refund_form.dart';
import 'package:now_ui_flutter/screens/tracking.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:now_ui_flutter/globals.dart' as globals;
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';

class PaymentSuccess extends StatefulWidget {
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
  final String merchant_id;
  final String merchant_password;
  final int totalNominal;

  const PaymentSuccess({
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
    this.merchant_id,
    this.merchant_password,
    this.totalNominal,
  }) : super(key: key);

  @override
  _PaymentSuccessState createState() => _PaymentSuccessState();
}

class _PaymentSuccessState extends State<PaymentSuccess> {
  final double circleRadius = 120.0;
  String payment;
  File pdfFile;
  double invoiceTambahanSum = 0;
  SimpleFontelicoProgressDialog _dialog;
  List<dynamic> invoicetambahan;

  @override
  void initState() {
    super.initState();
    getBuktiPdf(widget.buktipdf);
    invoicetambahan = widget.invoicetambahan;
  }

  Future<File> getBuktiPdf(String buktiPdf) async {
    var rng = new Random();
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    File bukti_pdf =
        new File('$tempPath' + (rng.nextInt(10000000)).toString() + '.pdf');
    http.Response response = await http.get(
      Uri.parse(
          '${globals.url}/api-orderemkl/public/api/syaratdanketentuan/bukti_pdf/$buktiPdf'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${globals.accessToken}',
      },
    );
    await bukti_pdf.writeAsBytes(response.bodyBytes);
    pdfFile = bukti_pdf;
  }

  void getStatusOrderan(String nobukti, String qty) async {
    var data = {"nobukti": nobukti, "qty": qty};
    final response = await http.get(
        Uri.parse(
            '${globals.url}/api-orderemkl/public/api/pesanan/getstatusorderan?data=${jsonEncode(data)}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${globals.accessToken}',
        });
    final result = jsonDecode(response.body);
    if (response.statusCode == 200) {
      await Future.delayed(Duration(seconds: 2));
      _dialog.hide();
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Tracking(
                    kode_container: result['data'][0]['nocont'],
                    nobukti: result['data'][0]['nobukti'],
                    qty: result['data'][0]['qty'],
                  )));
    }
  }

  void openPdf(BuildContext context, File file) {
    Navigator.push(context,
        MaterialPageRoute(builder: ((context) => PdfViewer(pdfUrl: file))));
  }

  Future<String> getPembayaran(String payment_code) async {
    try {
      final response = await http.get(
        Uri.parse(
            '${globals.url}/api-orderemkl/public/api/faspay/listofpayment'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${globals.accessToken}',
        },
      );
      final result = jsonDecode(response.body);
      List<dynamic> pg_data = result['payment_channel'];
      List<dynamic> payment_name =
          pg_data.where((el) => el['pg_code'] == payment_code).toList();
      return payment_name[0]['pg_name'];
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (widget.link == "ListPesanan") {
          Navigator.pop(context);
        } else {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => Home(),
              ),
              (route) => false);
        }
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: Color(0xFF747474),
            ),
          ),
          title: Text(
            "Detail Order",
            style: TextStyle(
              color: Color(0xFF747474),
              fontWeight: FontWeight.bold,
              fontSize: 18.0,
              fontFamily: 'Nunito-Medium',
            ),
          ),
          backgroundColor: Colors.white,
          actions: [
            if (widget.payment_status == 2) ...[
              InkWell(
                onTap: () {
                  Future.delayed(const Duration(seconds: 0), (() async {
                    final data_refund = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RefundForm(
                          nobukti: widget.nobukti,
                          harga: widget.harga_bayar,
                        ),
                      ),
                    );
                    // if (data_refund != null) {
                    //   Future.delayed(Duration.zero, () {
                    //     _showDialog(context,
                    //         SimpleFontelicoProgressDialogType.normal, 'Normal');
                    //     getDataMaster();
                    //   });
                    // }
                  }));
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.money,
                      color: Color(0xFF747474),
                    ), // <-- Icon
                    Text(
                      "Refund",
                      style: TextStyle(
                        color: Color(0xFF747474),
                      ),
                    ), // <-- Text
                  ],
                ),
              ),
              SizedBox(width: 15.0),
              InkWell(
                onTap: () async {
                  if (int.parse(widget.qty) > 1) {
                    _showDialog(context,
                        SimpleFontelicoProgressDialogType.normal, 'Normal');
                    _dialog.hide();
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: ((context) => ListQty(
                              nobukti: widget.nobukti,
                            )),
                      ),
                    );
                  } else {
                    _showDialog(context,
                        SimpleFontelicoProgressDialogType.normal, 'Normal');
                    getStatusOrderan(widget.nobukti, widget.qty);
                  }
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.local_shipping,
                      color: Color(0xFF747474),
                    ), // <-- Icon
                    Text(
                      "Status",
                      style: TextStyle(
                        color: Color(0xFF747474),
                      ),
                    ), // <-- Text
                  ],
                ),
              ),
            ],
            SizedBox(width: 15.0),
            InkWell(
              onTap: () async {
                if (globals.verificationStatus == "0" ||
                    globals.verificationStatus == "12" ||
                    globals.verificationStatus == "14") {
                  globals.alertBerhasilPesan(
                      context,
                      "Anda belum menyelesaikan status verifikasi anda/belum login",
                      'Orderan',
                      'assets/imgs/updated-transaction.json');
                } else {
                  _showDialog(context, SimpleFontelicoProgressDialogType.normal,
                      'Normal');
                  await Future.delayed(const Duration(seconds: 2));
                  _dialog.hide();
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Order(
                                placeidasal: widget.placeidasal,
                                latitude_place_asal: widget.latitude_muat,
                                longitude_place_asal: widget.longitude_muat,
                                pelabuhanidasal: widget.pelabuhanidasal,
                                latitude_pelabuhan_asal:
                                    widget.latitude_pelabuhan_asal,
                                longitude_pelabuhan_asal:
                                    widget.longitude_pelabuhan_asal,
                                jarak_asal: widget.jarak_asal,
                                waktu_asal: widget.waktu_asal,
                                alamatasal: widget.alamat_asal,
                                pengirim: widget.pengirim,
                                notelppengirim: widget.notelppengirim,
                                notepengirim: widget.note_pengirim,
                                namapelabuhanmuat: widget.namapelabuhanmuat,
                                //Tujuan
                                placeidtujuan: widget.placeidtujuan,
                                latitude_place_tujuan: widget.latitude_bongkar,
                                longitude_place_tujuan:
                                    widget.longitude_bongkar,
                                pelabuhanidtujuan: widget.pelabuhanidtujuan,
                                latitude_pelabuhan_tujuan:
                                    widget.latitude_pelabuhan_tujuan,
                                longitude_pelabuhan_tujuan:
                                    widget.longitude_pelabuhan_tujuan,
                                jarak_tujuan: widget.jarak_tujuan,
                                waktu_tujuan: widget.waktu_tujuan,
                                alamattujuan: widget.alamat_tujuan,
                                penerima: widget.penerima,
                                notelppenerima: widget.notelppenerima,
                                notepenerima: widget.note_penerima,
                                namapelabuhanbongkar:
                                    widget.namapelabuhanbongkar,
                                //Lainnya
                                container_id: widget.container_id,
                                nilaibarang: widget.nilaibarang,
                                qty: widget.qty,
                                jenisbarang: widget.jenisbarang,
                                namabarang: widget.namabarang,
                                keterangantambahan: widget.keterangantambahan,
                              )));
                }
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.replay,
                    color: Color(0xFF747474),
                  ), // <-- Icon
                  Text(
                    "Re-Order",
                    style: TextStyle(
                      color: Color(0xFF747474),
                    ),
                  ), // <-- Text
                ],
              ),
            ),
            SizedBox(width: 15.0),
          ],
        ),
        backgroundColor: Color(0xFFE6E6E6),
        body: Container(
          child: ListView(
            children: [
              SizedBox(height: 10.0),
              Container(
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child: Column(
                  children: [
                    Column(
                      children: <Widget>[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(width: 0.0),
                            Expanded(
                                // Wrap this column inside an expanded widget so that framework allocates max width for this column inside this row
                                child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'Lokasi Muat',
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    color: Color(0xFF666666),
                                    fontFamily: 'Nunito-Medium',
                                  ),
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Expanded(
                                      child: GestureDetector(
                                          onTap: () {
                                            // setMap(
                                            //     '${widget.latitude_pelabuhan_asal},${widget.longitude_pelabuhan_asal}',
                                            //     widget.origincontroller);
                                            // setState(() {
                                            //   distance = widget.jarakasal;
                                            //   duration = widget.waktuasal;
                                            // });
                                          },
                                          // Then wrap your text widget with expanded
                                          child: Text(
                                            widget.alamat_asal,
                                            style: TextStyle(
                                              fontFamily: 'Nunito-Medium',
                                              fontWeight: FontWeight.bold,
                                            ),
                                            softWrap: true,
                                          )),
                                    ),
                                  ],
                                ),
                              ],
                            )),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 10.0),
                    Column(
                      children: <Widget>[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(width: 0.0),
                            Expanded(
                                // Wrap this column inside an expanded widget so that framework allocates max width for this column inside this row
                                child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'Lokasi Bongkar',
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    color: Color(0xFF666666),
                                    fontFamily: 'Nunito-Medium',
                                  ),
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Expanded(
                                      child: GestureDetector(
                                          onTap: () {
                                            // setMap(
                                            //     '${widget.latitude_pelabuhan_asal},${widget.longitude_pelabuhan_asal}',
                                            //     widget.origincontroller);
                                            // setState(() {
                                            //   distance = widget.jarakasal;
                                            //   duration = widget.waktuasal;
                                            // });
                                          },
                                          // Then wrap your text widget with expanded
                                          child: Text(
                                            widget.alamat_tujuan,
                                            style: TextStyle(
                                              fontFamily: 'Nunito-Medium',
                                              fontWeight: FontWeight.bold,
                                            ),
                                            softWrap: true,
                                          )),
                                    ),
                                  ],
                                ),
                              ],
                            )),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 6.0),
              if (widget.payment_status == 2) ...[
                Padding(
                  padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                  child: Card(
                    elevation: 2,
                    child: ClipPath(
                      child: Container(
                        height: 30,
                        decoration: BoxDecoration(
                            color: Color(0xFFD2FFD9),
                            border: Border(
                                left: BorderSide(
                                    color: Color(0xFF039600), width: 8))),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                          child: Text(
                            "Pembayaran Berhasil",
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Color(0xFF039600),
                            ),
                          ),
                        ),
                      ),
                      clipper: ShapeBorderClipper(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(3))),
                    ),
                  ),
                ),
              ] else if (widget.payment_status == 8) ...[
                Padding(
                  padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                  child: Card(
                    elevation: 2,
                    child: ClipPath(
                      child: Container(
                        height: 30,
                        decoration: BoxDecoration(
                            color: Color(0xFFFFD2D2),
                            border: Border(
                                left: BorderSide(
                                    color: Color(0xFFE95555), width: 8))),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                          child: Text(
                            "Pembayaran Dibatalkan",
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Color(0xFF960000),
                            ),
                          ),
                        ),
                      ),
                      clipper: ShapeBorderClipper(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(3))),
                    ),
                  ),
                ),
              ],
              SizedBox(height: 10.0),
              Container(
                padding: EdgeInsets.only(left: 15.0, right: 8.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RichText(
                      text: TextSpan(
                        // Note: Styles for TextSpans must be explicitly defined.
                        // Child text spans will inherit styles from parent
                        style: const TextStyle(
                          fontSize: 14.0,
                          color: Colors.black,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: 'No. Order: ',
                            style: const TextStyle(
                              fontSize: 16.0,
                              fontFamily: 'Nunito-Medium',
                            ),
                          ),
                          TextSpan(
                            text: '',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                              fontFamily: 'Nunito-Medium',
                            ),
                            children: [
                              new TextSpan(
                                text: '${widget.nobukti}',
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.local_phone),
                    )
                  ],
                ),
              ),
              SizedBox(height: 10.0),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child: ExpansionTile(
                  title: RichText(
                    text: TextSpan(
                      // Note: Styles for TextSpans must be explicitly defined.
                      // Child text spans will inherit styles from parent
                      style: const TextStyle(
                        fontSize: 14.0,
                        color: Colors.black,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: 'Total Invoice: ',
                          style: const TextStyle(
                            fontSize: 16.0,
                            fontFamily: 'Nunito-Medium',
                          ),
                        ),
                        TextSpan(
                          text: '',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                            fontFamily: 'Nunito-Medium',
                          ),
                          children: [
                            new TextSpan(
                              text:
                                  '${NumberFormat.currency(locale: 'id', symbol: 'Rp. ', decimalDigits: 00).format(
                                double.tryParse(widget.harga_bayar) +
                                    (widget.totalNominal ?? 0),
                              )}',
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 18.0, top: 5.0, bottom: 5.0, right: 18.0),
                      child: Column(
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(width: 0.0),
                              Expanded(
                                  // Wrap this column inside an expanded widget so that framework allocates max width for this column inside this row
                                  child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    'INVOICE UTAMA',
                                    style: TextStyle(
                                      fontSize: 17.0,
                                      fontFamily: 'Nunito-Medium',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Expanded(
                                        child: GestureDetector(
                                            onTap: () {
                                              // setMap(
                                              //     '${widget.latitude_pelabuhan_asal},${widget.longitude_pelabuhan_asal}',
                                              //     widget.origincontroller);
                                              // setState(() {
                                              //   distance = widget.jarakasal;
                                              //   duration = widget.waktuasal;
                                              // });
                                            },
                                            // Then wrap your text widget with expanded
                                            child: Text(
                                              "Biaya tersebut adalah biaya utama yang sudah dibayarkan pada saat ingin melakukan orderan",
                                              style: TextStyle(
                                                fontFamily: 'Nunito-Medium',
                                              ),
                                              softWrap: true,
                                            )),
                                      ),
                                    ],
                                  ),
                                ],
                              )),
                            ],
                          ),
                          SizedBox(height: 10.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Invoice Utama"),
                              Text(
                                NumberFormat.currency(
                                        locale: 'id',
                                        symbol: 'Rp. ',
                                        decimalDigits: 00)
                                    .format(double.tryParse(
                                        widget.harga_bayar.toString())),
                              ),
                            ],
                          ),
                          SizedBox(height: 5.0),
                          if (widget.payment_status == 2) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  height: 28,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      textStyle: TextStyle(
                                        color: NowUIColors.white,
                                      ),
                                      backgroundColor: Color(0xFFD9D9D9),
                                    ),
                                    onPressed: () async {
                                      _showDialog(
                                          context,
                                          SimpleFontelicoProgressDialogType
                                              .normal,
                                          'Normal');
                                      var data = {
                                        "nobukti": "${widget.nobukti}"
                                      };
                                      final response = await http.get(
                                        Uri.parse(
                                            '${globals.url}/api-orderemkl/public/api/pesanan/getDataInvoiceUtama?data=${jsonEncode(data)}'),
                                        headers: {
                                          'Content-Type': 'application/json',
                                          'Accept': 'application/json',
                                          'Authorization':
                                              'Bearer ${globals.accessToken}',
                                        },
                                      );
                                      final result = jsonDecode(response.body);
                                      print(result['lampiran']);
                                      Future.delayed(
                                        const Duration(seconds: 0),
                                        (() async {
                                          _dialog.hide();
                                          if (result['lampiran'] == "") {
                                            globals.alert(context,
                                                'Invoice Belum Terbit');
                                          } else {
                                            final url =
                                                'https://web.transporindo.com/api-orderemkl/public/api/pesanan/bukti_pdf/' +
                                                    result['lampiran'];
                                            final file = await PdfApi()
                                                .loadNetworkFile(url);
                                            openPdf(context, file);
                                          }
                                        }),
                                      );
                                    },
                                    child: Text(
                                      "Lihat Invoice",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontFamily: 'Nunito-Medium'),
                                    ),
                                  ),
                                ),
                                Container(
                                  height: 28,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      textStyle: TextStyle(
                                        color: NowUIColors.white,
                                      ),
                                      backgroundColor: Color(0xFFD9D9D9),
                                    ),
                                    onPressed: () async {
                                      _showDialog(
                                          context,
                                          SimpleFontelicoProgressDialogType
                                              .normal,
                                          'Normal');
                                      final date = DateTime.now();
                                      final dueDate =
                                          date.add(Duration(days: 7));

                                      final invoice = Invoice(
                                        pengirim: Pengirim(
                                          name: widget.pengirim,
                                          address: widget.alamat_asal,
                                          notelp: widget.notelppengirim,
                                          paymentInfo: widget.payment_code,
                                        ),
                                        penerima: Penerima(
                                          name: widget.penerima,
                                          address: widget.alamat_tujuan,
                                          notelp: widget.notelppenerima,
                                        ),
                                        info: InvoiceInfo(
                                          date: widget.order_date,
                                          payDate: widget.payment_date,
                                          number: widget.nobukti,
                                          payment: widget.payment_code,
                                        ),
                                        items: [
                                          InvoiceItem(
                                            pengirim:
                                                '${widget.pengirim}\n${widget.alamat_asal}\n${widget.notelppengirim}',
                                            penerima:
                                                '${widget.penerima}\n${widget.alamat_tujuan}\n${widget.notelppenerima}',
                                            quantity: int.parse(widget.qty),
                                            uk_container:
                                                widget.container_id == "1"
                                                    ? '20 ft'
                                                    : '40 ft',
                                            total: NumberFormat.currency(
                                                    locale: 'id',
                                                    symbol: 'Rp. ',
                                                    decimalDigits: 00)
                                                .format(double.tryParse(widget
                                                    .harga_bayar
                                                    .toString())),
                                          ),
                                        ],
                                      );

                                      final pdfFile =
                                          await PdfInvoiceApi.generate(invoice);

                                      _dialog.hide();

                                      PdfApi.openFile(pdfFile);
                                    },
                                    child: Text(
                                      "Lihat Bukti Bayar",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontFamily: 'Nunito-Medium'),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                          SizedBox(height: 5.0),
                          Divider(
                            color: Color(0xFFD6D6D6),
                            thickness: 1,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(width: 0.0),
                              Expanded(
                                // Wrap this column inside an expanded widget so that framework allocates max width for this column inside this row
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      'INVOICE TAMBAHAN',
                                      style: TextStyle(
                                        fontSize: 17.0,
                                        fontFamily: 'Nunito-Medium',
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Expanded(
                                          child: GestureDetector(
                                              onTap: () {},
                                              // Then wrap your text widget with expanded
                                              child: Text(
                                                "Biaya tersebut adalah biaya yang ditambahkan pada saat proses perjalanan bongkar muat",
                                                style: TextStyle(
                                                  fontFamily: 'Nunito-Medium',
                                                ),
                                                softWrap: true,
                                              )),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10.0),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("Invoice Tambahan"),
                                        Text(
                                          NumberFormat.currency(
                                                  locale: 'id',
                                                  symbol: 'Rp. ',
                                                  decimalDigits: 00)
                                              .format(widget.totalNominal ?? 0),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 5.0),
                                    ListView.builder(
                                      physics: NeverScrollableScrollPhysics(),
                                      scrollDirection: Axis.vertical,
                                      shrinkWrap: true,
                                      itemCount: invoicetambahan.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        String tglbayar =
                                            DateFormat("dd-MM-yyyy").format(
                                                DateFormat(
                                                        "yyyy-MM-dd HH:mm:ss")
                                                    .parse(
                                                        invoicetambahan[index]
                                                            ["paymentdate"]));
                                        invoiceTambahanSum += double.tryParse(
                                            invoicetambahan[index]['nominal']);
                                        return GestureDetector(
                                          onTap: () async {
                                            if (tglbayar == "01-01-1900") {
                                              final data_invoice =
                                                  await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      PaymentInvoiceTambahan(
                                                    harga:
                                                        invoicetambahan[index]
                                                            ['nominal'],
                                                    tglinvoice:
                                                        invoicetambahan[index]
                                                            ['tglinvoice'],
                                                    keterangan:
                                                        invoicetambahan[index]
                                                            ['keterangan'],
                                                    lampiran1:
                                                        invoicetambahan[index]
                                                            ['lampiran1'],
                                                    lampiran2:
                                                        invoicetambahan[index]
                                                            ['lampiran2'],
                                                    paymentstatus:
                                                        invoicetambahan[index]
                                                            ['paymentstatus'],
                                                    noinvoice:
                                                        invoicetambahan[index]
                                                            ['noinvoice'],
                                                    nobukti:
                                                        invoicetambahan[index]
                                                            ['nobukti'],
                                                    trxid:
                                                        invoicetambahan[index]
                                                            ['trxid'],
                                                    tglbayar:
                                                        invoicetambahan[index]
                                                            ['paymentdate'],
                                                    tglexpired:
                                                        invoicetambahan[index]
                                                            ['billexpired'],
                                                    billno:
                                                        invoicetambahan[index]
                                                            ['billno'],
                                                    norekap:
                                                        invoicetambahan[index]
                                                            ['norekap'],
                                                    paymentcode:
                                                        invoicetambahan[index]
                                                            ['paymentcode'],
                                                    merchant_id:
                                                        widget.merchant_id,
                                                    merchant_password: widget
                                                        .merchant_password,
                                                  ),
                                                ),
                                              );
                                              // if (data_invoice != null) {
                                              //   _showDialog(
                                              //       context,
                                              //       SimpleFontelicoProgressDialogType
                                              //           .normal,
                                              //       'Normal');
                                              //   print(jsonDecode(jsonEncode(
                                              //           data_invoice))[
                                              //       'data_invoiceTambahan']);
                                              //   print(invoicetambahan);
                                              //   print(invoicetambahanLength);
                                              //   setState(() {
                                              //     invoicetambahan.clear();
                                              //     for (var i = 0;
                                              //         i < invoicetambahanLength;
                                              //         i++) {
                                              //       invoicetambahan.add(jsonDecode(
                                              //               jsonEncode(
                                              //                   data_invoice))[
                                              //           'data_invoiceTambahan'][i]);
                                              //     }
                                              //     // invoicetambahan[0];
                                              //   });
                                              //   print(invoicetambahan);
                                              //   _dialog.hide();
                                              // }
                                            }
                                          },
                                          child: Column(
                                            children: [
                                              Divider(
                                                color: Color(0xFFD6D6D6),
                                                thickness: 1,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text("No. Invoice"),
                                                  Text(
                                                      "${invoicetambahan[index]["noinvoice"]}"),
                                                ],
                                              ),
                                              SizedBox(height: 5.0),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 15.0),
                                                    child: Text(
                                                        "${invoicetambahan[index]["keterangan"]}"),
                                                  ),
                                                  Text(
                                                      "${NumberFormat.currency(locale: 'id', symbol: 'Rp. ', decimalDigits: 00).format(double.tryParse(invoicetambahan[index]["nominal"]))}"),
                                                ],
                                              ),
                                              SizedBox(height: 5.0),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 15.0),
                                                    child:
                                                        Text("Tanggal Bayar"),
                                                  ),
                                                  Text(
                                                    tglbayar != "01-01-1900"
                                                        ? DateFormat(
                                                                "dd-MM-yyyy")
                                                            .format(DateFormat(
                                                                    "yyyy-MM-dd HH:mm:ss")
                                                                .parse(widget
                                                                            .invoicetambahan[
                                                                        index][
                                                                    "paymentdate"]))
                                                        : "",
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 5.0),
                                              if (tglbayar != "01-01-1900") ...[
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Container(
                                                      height: 28,
                                                      child: ElevatedButton(
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          textStyle: TextStyle(
                                                            color: NowUIColors
                                                                .white,
                                                          ),
                                                          backgroundColor:
                                                              Color(0xFFD9D9D9),
                                                        ),
                                                        onPressed: () async {
                                                          Future.delayed(
                                                              const Duration(
                                                                  seconds: 0),
                                                              (() async {
                                                            if (invoicetambahan[
                                                                        index][
                                                                    "lampiraninvoice"] ==
                                                                "") {
                                                              globals.alert(
                                                                  context,
                                                                  'Invoice Belum Terbit');
                                                            } else {
                                                              var url = 'https://web.transporindo.com/api-orderemkl/public/api/pesanan/bukti_pdfInvoiceTambahan/' +
                                                                  invoicetambahan[
                                                                          index]
                                                                      [
                                                                      "lampiraninvoice"];
                                                              final file =
                                                                  await PdfApi()
                                                                      .loadNetworkFile(
                                                                          url);
                                                              openPdf(context,
                                                                  file);
                                                            }
                                                          }));
                                                        },
                                                        child: Text(
                                                          "Lihat Invoice",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontFamily:
                                                                  'Nunito-Medium'),
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      height: 28,
                                                      child: ElevatedButton(
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          textStyle: TextStyle(
                                                            color: NowUIColors
                                                                .white,
                                                          ),
                                                          backgroundColor:
                                                              Color(0xFFD9D9D9),
                                                        ),
                                                        onPressed: () async {
                                                          _showDialog(
                                                              context,
                                                              SimpleFontelicoProgressDialogType
                                                                  .normal,
                                                              'Normal');
                                                          payment = await getPembayaran(
                                                              invoicetambahan[
                                                                      index][
                                                                  "paymentcode"]);
                                                          final date =
                                                              DateTime.now();
                                                          final dueDate =
                                                              date.add(Duration(
                                                                  days: 7));

                                                          final invoice =
                                                              Invoice(
                                                            penerima: Penerima(
                                                              name:
                                                                  widget.invoicetambahan[
                                                                          index]
                                                                      [
                                                                      'norekap'],
                                                              address: widget
                                                                  .nobukti,
                                                            ),
                                                            info: InvoiceInfo(
                                                              date: DateFormat(
                                                                      'dd MMM yyyy')
                                                                  .format(DateFormat(
                                                                          'yyyy-MM-dd')
                                                                      .parse(widget
                                                                              .invoicetambahan[index]
                                                                          [
                                                                          'tglinvoice'])),
                                                              payDate: DateFormat(
                                                                      'dd MMM yyyy HH:mm:ss')
                                                                  .format(DateFormat(
                                                                          'yyyy-MM-dd HH:mm:ss')
                                                                      .parse(widget
                                                                              .invoicetambahan[index]
                                                                          [
                                                                          'paymentdate'])),
                                                              payment: payment,
                                                            ),
                                                            items: [
                                                              InvoiceItem(
                                                                pengirim:
                                                                    '${widget.pengirim}\n${widget.alamat_asal}\n${widget.notelppengirim}',
                                                                penerima:
                                                                    '${widget.penerima}\n${widget.alamat_tujuan}\n${widget.notelppenerima}',
                                                                uk_container: widget
                                                                            .invoicetambahan[
                                                                        index][
                                                                    'keterangan'],
                                                                total: NumberFormat.currency(
                                                                        locale:
                                                                            'id',
                                                                        symbol:
                                                                            'Rp. ',
                                                                        decimalDigits:
                                                                            00)
                                                                    .format(double.tryParse(widget
                                                                        .invoicetambahan[
                                                                            index]
                                                                            [
                                                                            'nominal']
                                                                        .toString())),
                                                              ),
                                                            ],
                                                          );

                                                          final pdfFile =
                                                              await PdfInvoiceTambahApi
                                                                  .generate(
                                                                      invoice);

                                                          _dialog.hide();

                                                          PdfApi.openFile(
                                                              pdfFile);
                                                        },
                                                        child: Text(
                                                          "Lihat Bukti Bayar",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontFamily:
                                                                  'Nunito-Medium'),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ]
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                    SizedBox(height: 15.0),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10.0),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child: ExpansionTile(
                  title: Text("Data Orderan"),
                  children: <Widget>[
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                child: const CircleAvatar(
                                  radius: 13.0,
                                  backgroundColor: Color(0xFF8BC8F4),
                                  child: const CircleAvatar(
                                    radius: 10.0,
                                    backgroundColor: Color(0xFF0A5B96),
                                  ),
                                ),
                              ),
                              Container(
                                height: 60.0,
                                child: VerticalDivider(
                                  color: Color(0xFFAEAEAE),
                                  thickness: 1,
                                ),
                              ),
                              Container(
                                child: const Icon(
                                  Icons.flag,
                                  size: 30.0,
                                  color: Color(0xFF219C02),
                                ),
                              ),
                              Container(
                                height: 105.0,
                                child: VerticalDivider(
                                  color: Color(0xFFAEAEAE),
                                  thickness: 1,
                                ),
                              ),
                              Container(
                                child: const CircleAvatar(
                                  radius: 13.0,
                                  backgroundColor: Color(0xFF8BC8F4),
                                  child: const CircleAvatar(
                                    radius: 10.0,
                                    backgroundColor: Color(0xFF0A5B96),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: <Widget>[
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Data Muat",
                                    style: TextStyle(fontSize: 17.0),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Table(
                                      defaultColumnWidth:
                                          FixedColumnWidth(120.0),
                                      border: null,
                                      children: [
                                        TableRow(children: [
                                          Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text('Nama Pengirim')
                                              ]),
                                          Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  widget.pengirim,
                                                  style: TextStyle(
                                                      fontSize: 14.0,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                )
                                              ]),
                                        ]),
                                        TableRow(children: [
                                          Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [Text('No. Telepon')]),
                                          Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  widget.notelppengirim,
                                                  style: TextStyle(
                                                      fontSize: 14.0,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                )
                                              ]),
                                        ]),
                                        TableRow(children: [
                                          Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text('Note Pengirim')
                                              ]),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                widget.note_pengirim,
                                                style: TextStyle(
                                                    fontSize: 14.0,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ]),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 15.0),
                                  Container(
                                    height: 28,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        textStyle: TextStyle(
                                          color: NowUIColors.white,
                                        ),
                                        backgroundColor: Color(0xFFD9D9D9),
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => MapAsal(
                                                      origincontroller:
                                                          '${widget.latitude_pelabuhan_asal},${widget.longitude_pelabuhan_asal}',
                                                      destinationcontroller:
                                                          '${widget.latitude_muat},${widget.longitude_muat}',
                                                    )));
                                      },
                                      child: Text(
                                        "Tampilkan Peta Lokasi Muat",
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(height: 10.0),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Data Bongkar",
                                    style: TextStyle(fontSize: 17.0),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Table(
                                      defaultColumnWidth:
                                          FixedColumnWidth(120.0),
                                      border: null,
                                      children: [
                                        TableRow(children: [
                                          Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text('Nama Penerima')
                                              ]),
                                          Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  widget.penerima,
                                                  style: TextStyle(
                                                      fontSize: 14.0,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                )
                                              ]),
                                        ]),
                                        TableRow(children: [
                                          Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [Text('No. Telepon')]),
                                          Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  widget.notelppenerima,
                                                  style: TextStyle(
                                                      fontSize: 14.0,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                )
                                              ]),
                                        ]),
                                        TableRow(children: [
                                          Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text('Note Penerima')
                                              ]),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                widget.note_penerima,
                                                style: TextStyle(
                                                    fontSize: 14.0,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ]),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 10.0),
                                  Container(
                                    height: 28,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        textStyle: TextStyle(
                                          color: NowUIColors.white,
                                        ),
                                        backgroundColor: Color(0xFFD9D9D9),
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => MapAsal(
                                                      origincontroller:
                                                          '${widget.latitude_pelabuhan_tujuan},${widget.longitude_pelabuhan_tujuan}',
                                                      destinationcontroller:
                                                          '${widget.latitude_bongkar},${widget.longitude_bongkar}',
                                                    )));
                                      },
                                      child: Text(
                                        "Tampilkan Peta Lokasi Bongkar",
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.0),
                    Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(3.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                "Tanggal Order",
                                style: TextStyle(fontSize: 14.0),
                              ),
                              Text(
                                widget.order_date,
                                style: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(3.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                widget.payment_status == 2
                                    ? "Tanggal Bayar"
                                    : "Tanggal Batal",
                                style: TextStyle(fontSize: 14.0),
                              ),
                              Text(
                                widget.payment_date,
                                style: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(3.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                "Pembayaran",
                                style: TextStyle(fontSize: 14.0),
                              ),
                              Text(
                                widget.payment_code,
                                style: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.0),
                  ],
                ),
              ),
              SizedBox(height: 20.0),
            ],
          ),
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

class _IndicatorExample extends StatelessWidget {
  const _IndicatorExample({Key key, this.color}) : super(key: key);

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.fromBorderSide(
          BorderSide(
            color: Colors.green,
            width: 4,
          ),
        ),
      ),
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
      ),
    );
  }
}

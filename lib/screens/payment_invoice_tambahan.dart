import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:now_ui_flutter/constants/Theme.dart';
import 'package:now_ui_flutter/models/dart_models.dart';
import 'package:now_ui_flutter/providers/services.dart';
import 'package:now_ui_flutter/screens/payment_success.dart';
import 'package:now_ui_flutter/globals.dart' as globals;
import 'package:provider/provider.dart';
import 'package:pusher_client/pusher_client.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
import 'package:http/http.dart' as http;

class Skeleton extends StatelessWidget {
  const Skeleton({
    Key key,
    this.height,
    this.width,
  }) : super(key: key);

  final double height, width;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      // padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.04),
      ),
    );
  }
}

class PaymentInvoiceTambahan extends StatefulWidget {
  static var size = 90.0;
  final String harga;
  final String tglinvoice;
  final String keterangan;
  final String lampiran1;
  final String lampiran2;
  final String paymentstatus;
  final String noinvoice;
  final String nobukti;
  final String trxid;
  final String tglbayar;
  final String tglexpired;
  final String billno;
  final String merchant_id;
  final String merchant_password;
  final String norekap;
  final String paymentcode;
  const PaymentInvoiceTambahan({
    Key key,
    this.harga,
    this.tglinvoice,
    this.keterangan,
    this.lampiran1,
    this.lampiran2,
    this.paymentstatus,
    this.noinvoice,
    this.nobukti,
    this.trxid,
    this.tglbayar,
    this.tglexpired,
    this.billno,
    this.merchant_id,
    this.merchant_password,
    this.norekap,
    this.paymentcode,
  }) : super(key: key);

  @override
  State<PaymentInvoiceTambahan> createState() => _PaymentInvoiceTambahanState();
}

class _PaymentInvoiceTambahanState extends State<PaymentInvoiceTambahan> {
  String _selectedpembayaran;
  String trxid;
  String billexpired;
  String billno;
  String paymentstatus;
  bool show = true;
  bool hide = false;
  SimpleFontelicoProgressDialog _dialog;
  String paymentcode = "";
  Object dataInvoice;

  @override
  void initState() {
    setState(() {
      trxid = widget.trxid;
      billexpired = widget.tglexpired;
      billno = widget.billno;
      paymentstatus = widget.paymentstatus;
    });
    if (widget.trxid == "") {
      setState(() {
        show = true;
        hide = false;
      });
    } else {
      if (widget.paymentstatus == "0") {
        getPembayaran(widget.paymentcode);
        checkStatusPayment();
        _initCheckStatus();
      }
      setState(() {
        show = false;
        hide = true;
      });
    }
    print(widget.merchant_id);
  }

  void checkStatusPayment() async {
    try {
      var data_pembayaran = {
        'noVA': trxid,
        'bill_no': billno,
        "merchantid": widget.merchant_id,
        "merchantpassword": widget.merchant_password,
      };
      final response = await http.post(
          Uri.parse(
            // '${globals.url}/faspay/status.php',
            '${globals.url}/api-orderemkl/public/api/faspay/statuspayment',
          ),
          body: {'data_pembayaran': json.encode(data_pembayaran)});
      var hasil = json.decode(response.body);
      print(hasil['payment_status_code']);
      if (hasil['payment_status_code'] == '2') {
        _showDialog(
            context, SimpleFontelicoProgressDialogType.normal, 'Normal');
        await Provider.of<MasterProvider>(context, listen: false)
            .updateStatusInvoiceTambahan(trxid, 2)
            .then((value) async {
          setState(() {
            paymentstatus = "2";
          });
          _dialog.hide();
          globals.triggerActions(
            context,
            "Pembayaran berhasil dibayar, silahkan cek kembali status orderan anda.",
            'Invoice Tambahan',
            'assets/imgs/updated-transaction.json',
            [
              IconsButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await Provider.of<MasterProvider>(context, listen: false)
                      .listPesananRow(widget.nobukti)
                      .then((value) async {
                    getPembayaran(value.payment_code);
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PaymentSuccess(
                                  harga_bayar: value.harga,
                                  noVA: value.trx_id,
                                  nobukti: value.nobukti,
                                  payment_status:
                                      int.parse(value.payment_status),
                                  alamat_asal: value.alamat_asal,
                                  alamat_tujuan: value.alamat_tujuan,
                                  order_date: value.order_date,
                                  payment_date: value.payment_date,
                                  payment_code: paymentcode,
                                  link: 'ListPesanan',
                                  latitude_pelabuhan_asal:
                                      value.latitude_pelabuhan_asal,
                                  longitude_pelabuhan_asal:
                                      value.longitude_pelabuhan_asal,
                                  latitude_pelabuhan_tujuan:
                                      value.latitude_pelabuhan_tujuan,
                                  longitude_pelabuhan_tujuan:
                                      value.longitude_pelabuhan_tujuan,
                                  latitude_muat: value.latitude_muat,
                                  longitude_muat: value.longitude_muat,
                                  latitude_bongkar: value.latitude_bongkar,
                                  longitude_bongkar: value.longitude_bongkar,
                                  notelppengirim: value.notelppengirim,
                                  pengirim: value.pengirim,
                                  penerima: value.penerima,
                                  notelppenerima: value.notelppenerima,
                                  buktipdf: value.buktipdf,
                                  note_pengirim: value.notepengirim,
                                  note_penerima: value.notepenerima,
                                  lampiraninvoice: value.lampiraninvoice,
                                  placeidasal: value.placeidasal,
                                  pelabuhanidasal: value.pelabuhanidasal,
                                  jarak_asal: value.jarak_asal,
                                  waktu_asal: value.waktu_asal,
                                  namapelabuhanmuat: value.namapelabuhanmuat,
                                  placeidtujuan: value.placeidtujuan,
                                  pelabuhanidtujuan: value.pelabuhanidtujuan,
                                  jarak_tujuan: value.jarak_tujuan,
                                  waktu_tujuan: value.waktu_tujuan,
                                  namapelabuhanbongkar:
                                      value.namapelabuhanbongkar,
                                  container_id: value.container_id,
                                  nilaibarang: value.nilaibarang,
                                  qty: value.qty,
                                  jenisbarang: value.jenisbarang,
                                  namabarang: value.namabarang,
                                  keterangantambahan: value.keterangantambahan,
                                  invoicetambahan: value.invoiceTambahan,
                                  merchant_id: value.merchant_id,
                                  merchant_password: value.merchant_password,
                                  totalNominal: value.totalNominal,
                                )));
                  });
                },
                text: 'OK',
                iconData: Icons.done,
                color: Colors.blue,
                textStyle: TextStyle(color: Colors.white),
                iconColor: Colors.white,
              ),
            ],
          );
        });
      } else if (hasil['payment_status_code'] == '7') {
        _showDialog(
            context, SimpleFontelicoProgressDialogType.normal, 'Normal');
        Provider.of<MasterProvider>(context, listen: false)
            .updateStatusInvoiceTambahan(trxid, 0)
            .then((value) async {
          _dialog.hide();
          globals.alertBerhasilPesan(
              context,
              "Waktu pembayaran telah habis, silahkan lakukan pembayaran ulang agar dapat melanjutkan cek status orderan",
              'Invoice Tambahan',
              'assets/imgs/updated-transaction.json');
          setState(() {
            show = true;
            hide = false;
          });
        });
      } else {
        print(hasil['payment_status_desc']);
      }
    } catch (e) {
      print(e);
    }
  }

  void _initCheckStatus() async {
    globals.channel.bind('App\\Events\\CheckStatusInvoice',
        (PusherEvent event) async {
      print(jsonDecode(jsonDecode(event.data)['message']));
      dataInvoice =
          jsonDecode(jsonDecode(event.data)['message'])['data_invoice'];
      checkStatusPayment();
    });
  }

  @override
  void dispose() {
    super.dispose();
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

  void getPembayaran(String payment_code) async {
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
      setState(() {
        paymentcode = payment_name[0]['pg_name'];
      });
    } catch (e) {
      print(e.toString());
    }
  }

  void BayarInvoiceFunction() async {
    var data = {
      "nobukti": "${widget.nobukti}",
      "pembayaran": "$_selectedpembayaran",
      "harga": "${widget.harga}",
      "noinvoice": "${widget.noinvoice}",
      "user_id": "${globals.loggedinId}",
      "accessToken": "${globals.accessToken}",
      "merchantid": "${widget.merchant_id}",
      "merchantpassword": "${widget.merchant_password}",
      "norekap": "${widget.norekap}",
    };
    try {
      final response = await http.post(
        Uri.parse('${globals.url}/faspay/index2.php'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'data_invoice': jsonEncode(data)}),
      );
      final result = jsonDecode(response.body);
      // print(response.statusCode);
      // print(response.request);
      // print(response.bodyBytes);
      // print(response.body);
      if (response.statusCode == 200) {
        await getPembayaran(result['data']['paymentcode']);
        setState(() {
          trxid = result['data']['trxid'];
          billexpired = result['data']['billexpired'];
          billno = result['data']['billno'];
          show = false;
          hide = true;
        });

        await Future.delayed(const Duration(seconds: 3));
        _dialog.hide();
        _initCheckStatus();
      } else if (response.statusCode == 500) {
        debugPrint(response.body);
      } else {
        print("error");
        _dialog.hide();
        print('asdf');
      }
    } on SocketException catch (_) {
      _dialog.hide();
      globals.alertBerhasilPesan(
          context,
          "Mohon cek kembali koneksi internet WiFi/Data anda",
          'Tidak ada koneksi',
          'assets/imgs/no-internet.json');
    } catch (e) {
      _dialog.hide();
      debugPrint(e.toString());
    }
  }

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
          "Invoice Tambahan",
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
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 15.0),
            child: Container(
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
                          SizedBox(height: 10.0),
                          Expanded(
                              // Wrap this column inside an expanded widget so that framework allocates max width for this column inside this row
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(height: 10.0),
                              Text(
                                'Keterangan Invoice',
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
                                        onTap: () {},
                                        // Then wrap your text widget with expanded
                                        child: Text(
                                          widget.keterangan.toUpperCase(),
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
                          onPressed: () async {},
                          child: Text(
                            "Lampiran 1",
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
                          onPressed: () async {},
                          child: Text(
                            "Lampiran 2",
                            style: TextStyle(
                                color: Colors.black,
                                fontFamily: 'Nunito-Medium'),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30.0),
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
                                'Pembayaran',
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
                                        onTap: () {},
                                        // Then wrap your text widget with expanded
                                        child: Text(
                                          paymentcode != "" ? paymentcode : "-",
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
                                'No. Transaksi',
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
                                        onTap: () {},
                                        // Then wrap your text widget with expanded
                                        child: Text(
                                          trxid != "" ? trxid : "-",
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
                  SizedBox(height: 15.0),
                  Column(
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(width: 0.0),
                          Expanded(
                              // Wrap this column inside an expanded widget so that framework allocates max width for this column inside this row
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                'Total Harga',
                                style: TextStyle(
                                  fontSize: 18.0,
                                  color: Color(0xFF666666),
                                  fontFamily: 'Nunito-Medium',
                                ),
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Expanded(
                                    child: GestureDetector(
                                        onTap: () {},
                                        child: Text(
                                          NumberFormat.currency(
                                                  locale: 'id',
                                                  symbol: 'Rp. ',
                                                  decimalDigits: 00)
                                              .format(double.tryParse(
                                                  widget.harga)),
                                          style: TextStyle(
                                            fontSize: 18.0,
                                            fontFamily: 'Nunito-Medium',
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                          softWrap: true,
                                        )),
                                  ),
                                ],
                              ),
                              SizedBox(height: 7.0),
                            ],
                          )),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 10.0),
                  Divider(
                    thickness: 5,
                    color: Color(0xFFE6E6E6),
                  ),
                  Visibility(
                    visible: show,
                    child: Text(
                      "Jenis Pembayaran",
                      style:
                          TextStyle(fontSize: 16.0, color: Color(0xFF666666)),
                    ),
                  ),
                  Visibility(
                    visible: hide,
                    child: Text(
                      "Batas Waktu Pembayaran",
                      style:
                          TextStyle(fontSize: 16.0, color: Color(0xFF666666)),
                    ),
                  ),
                  Visibility(
                    visible: show,
                    child: Padding(
                      padding: const EdgeInsets.all(13.0),
                      child: SizedBox(
                        height: 40,
                        child: DropdownSearch<Pembayaran>(
                          showAsSuffixIcons: true,
                          mode: Mode.BOTTOM_SHEET,
                          dropdownBuilder: (context, _selectedpembayaran) {
                            return Text(
                              _selectedpembayaran == null
                                  ? "Pembayaran"
                                  : _selectedpembayaran.toString(),
                              style: TextStyle(
                                fontSize: 13.0,
                                fontWeight: FontWeight.bold,
                                color: _selectedpembayaran == null
                                    ? Color.fromARGB(255, 114, 114, 114)
                                    : Colors.black,
                              ),
                            );
                          },
                          dropdownSearchDecoration: InputDecoration(
                            hintText: "Pembayaran",
                            hintStyle: TextStyle(
                              fontSize: 13.0,
                              fontWeight: FontWeight.bold,
                            ),
                            prefixIcon: Icon(
                              Icons.credit_card_rounded,
                              color: Color(0xFF5599E9),
                            ),
                            contentPadding: EdgeInsets.fromLTRB(12, 12, 0, 0),
                            border: OutlineInputBorder(),
                          ),
                          onFind: (String filter) async {
                            final url =
                                '${globals.url}/api-orderemkl/public/api/faspay/listofpayment';
                            var response = await Dio().get(
                              url,
                              queryParameters: {"filter": filter},
                              options: Options(
                                headers: {
                                  'Accept': 'application/json',
                                  'Content-type': 'application/json',
                                  'Authorization':
                                      'Bearer ${globals.accessToken}',
                                },
                              ),
                            );
                            // print(jsonDecode(response.data)['payment_channel']);
                            var models = Pembayaran.fromJsonList(
                                jsonDecode(response.data)['payment_channel']);
                            return models;
                          },
                          onChanged: (data) {
                            _selectedpembayaran = data.pg_code;
                          },
                          showSearchBox: true,
                          searchFieldProps: TextFieldProps(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.fromLTRB(12, 12, 8, 0),
                              labelText: "Cari Pembayaran",
                            ),
                          ),
                          popupTitle: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColorDark,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(0),
                                topRight: Radius.circular(0),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'Pembayaran',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          popupShape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(0),
                              topRight: Radius.circular(0),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: hide,
                    child: Padding(
                      padding: EdgeInsets.only(left: 13.0, right: 13.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            (DateFormat.jms().format(
                                DateFormat("yyyy-MM-dd HH:mm:ss")
                                    .parse(billexpired))),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontFamily: 'Oxanium-Reguler',
                              fontSize: 30.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Text(
                    "NB: Nomor VA akan hangus setelah waktu pembayaran telah dilewati, maka lakukan pembayaran dan anda dapat mengecek status pesanan anda.",
                    style: TextStyle(
                      fontSize: 13.0,
                      fontFamily: "Nunito-Medium",
                      color: Color(0xFF666666),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10.0),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Visibility(
        visible: show,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: new Container(
            height: 40.0,
            padding:
                EdgeInsets.only(left: 8.0, bottom: 5.0, top: 0.0, right: 8.0),
            child: ElevatedButton(
              onPressed: () async {
                _showDialog(context, SimpleFontelicoProgressDialogType.normal,
                    'Normal');
                await BayarInvoiceFunction();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF5599E9),
              ),
              child: Text(
                "Bayar",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Nunito-Medium',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_dialogs/material_dialogs.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:now_ui_flutter/providers/services.dart';
import 'package:now_ui_flutter/screens/bayar.dart';
import 'package:now_ui_flutter/screens/payment_success.dart';
import 'package:now_ui_flutter/screens/payment_success_refund.dart';
import 'package:now_ui_flutter/screens/refund_detail.dart';
import 'package:now_ui_flutter/screens/tracking.dart';
import 'package:now_ui_flutter/globals.dart' as globals;
import 'package:provider/provider.dart';
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
      margin: EdgeInsets.only(left: 5.0, right: 5.0, top: 10.0, bottom: 10.0),
      decoration: new BoxDecoration(
        color: Colors.black.withOpacity(0.08),
        shape: BoxShape.rectangle,
        borderRadius: new BorderRadius.circular(14.28),
      ),
    );
  }
}

class ListPesanan extends StatefulWidget {
  @override
  _ListPesananState createState() => _ListPesananState();
}

class _ListPesananState extends State<ListPesanan> {
  SimpleFontelicoProgressDialog _dialog;
  String payment;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getDataMaster();
    });
  }

  void getDataMaster() async {
    await Provider.of<MasterProvider>(context, listen: false)
        .callSkeletonListPesanan(context, globals.loggedinId);
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
    // result['data'][0]['trx_id']
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

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFFFFFF),
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: Color(0xFFB7B7B7),
            )),
        elevation: 0,
        title: Text(
          "List Pesanan",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
              icon: Icon(
                Icons.search,
                color: Color(0xFFBFBFBF),
              ),
              onPressed: () {}),
          IconButton(
              icon: Icon(
                Icons.filter_alt,
                color: Color(0xFFBFBFBF),
              ),
              onPressed: () {}),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          getDataMaster();
        },
        child: Container(
          color: Color(0xFFF3F3F3),
          child: Consumer<MasterProvider>(builder: (context, data, _) {
            if (data.onSearch == true) {
              // return Expanded(
              return ListView.builder(
                itemCount: 5,
                itemBuilder: (context, i) {
                  SizedBox(height: 15.0);
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                    child: Skeleton(
                      height: 300.0,
                      width: 880.0,
                    ),
                  );
                },
              );
              // );
            } else if (data.dataPesanan.length == 0) {
              return Align(
                alignment: Alignment.topCenter,
                child: Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 5,
                    ),
                    Container(
                      child: Image.asset(
                        "assets/imgs/trucking.png",
                        width: 200,
                        height: 200,
                      ),
                    ),
                    Text(
                      "TIDAK ADA PESANAN",
                      style: TextStyle(
                          color: Color.fromARGB(255, 187, 187, 187),
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    )
                  ],
                ),
              );
            } else {
              return ListView.builder(
                  itemCount: data.dataPesanan.length,
                  itemBuilder: (context, i) {
                    return Container(
                      height: 300.0,
                      width: 880.0,
                      margin: EdgeInsets.only(
                          left: 5.0, right: 5.0, top: 10.0, bottom: 10.0),
                      child: new Column(
                        children: <Widget>[
                          Container(
                            height: 300.0,
                            width: 880.0,
                            child: Container(
                              margin: new EdgeInsets.only(
                                left: 0.0,
                                top: 0.0,
                                right: 0.0,
                                bottom: 0.0,
                              ),
                              // color: NowUIColors.error,
                              child: ClipPath(
                                child: Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                    border: Border(
                                      left: BorderSide(
                                          color: data.dataPesanan[i]
                                                      .payment_status ==
                                                  "2"
                                              ? Color(0xFF5ACA16)
                                              : data.dataPesanan[i]
                                                          .payment_status ==
                                                      "0"
                                                  ? Color(0xFFE1B30D)
                                                  : data.dataPesanan[i]
                                                              .payment_status ==
                                                          "10"
                                                      ? Color(0xFFF9B691)
                                                      : data.dataPesanan[i]
                                                                  .payment_status ==
                                                              '11'
                                                          ? Color(0xFF005796)
                                                          : Color(0xFFE95555),
                                          width: 15),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        height: 55.0,
                                        child: ListTile(
                                          title: Text(
                                            'No. Pesanan',
                                            style: TextStyle(
                                              fontSize: 12.0,
                                              color: Colors.black,
                                            ),
                                          ),
                                          subtitle:
                                              Text(data.dataPesanan[i].nobukti,
                                                  style: TextStyle(
                                                    fontSize: 14.0,
                                                    fontWeight: FontWeight.w900,
                                                    color: Colors.black,
                                                  )),
                                          trailing: Container(
                                              width: 126,
                                              height: 38,
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  width: 1,
                                                  color: data.dataPesanan[i]
                                                              .payment_status ==
                                                          "2"
                                                      ? Color(0xFF5ACA16)
                                                      : data.dataPesanan[i]
                                                                  .payment_status ==
                                                              "0"
                                                          ? Color(0xFFE1B30D)
                                                          : data.dataPesanan[i]
                                                                      .payment_status ==
                                                                  "10"
                                                              ? Color(
                                                                  0xFFF9B691)
                                                              : data
                                                                          .dataPesanan[
                                                                              i]
                                                                          .payment_status ==
                                                                      '11'
                                                                  ? Color(
                                                                      0xFF005796)
                                                                  : Color(
                                                                      0xFFE95555),
                                                ),
                                                // You can use like this way or like the below line
                                                borderRadius:
                                                    new BorderRadius.circular(
                                                        100.0),
                                              ),
                                              child: Text(
                                                data.dataPesanan[i]
                                                            .payment_status ==
                                                        "0"
                                                    ? "Belum Diproses"
                                                    : data.dataPesanan[i]
                                                                .payment_status ==
                                                            "8"
                                                        ? "Batal Dibayar"
                                                        : data.dataPesanan[i]
                                                                    .payment_status ==
                                                                "7"
                                                            ? "Pemb. Expired"
                                                            : data
                                                                        .dataPesanan[
                                                                            i]
                                                                        .payment_status ==
                                                                    "10"
                                                                ? "Proses Refund"
                                                                : data.dataPesanan[i]
                                                                            .payment_status ==
                                                                        "11"
                                                                    ? "Refund Berhasil"
                                                                    : "Berhasil Dibayar",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: 12.0,
                                                ),
                                              )),
                                          isThreeLine: true,
                                        ),
                                      ),
                                      Divider(
                                        thickness: 0.5,
                                        color: Colors.black,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 17.0),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text(
                                                  'Nama Pengirim',
                                                  style: TextStyle(
                                                    fontSize: 12.0,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                Text(
                                                  data.dataPesanan[i].pengirim
                                                      .toUpperCase(),
                                                  style: TextStyle(
                                                    fontSize: 14.0,
                                                    fontWeight: FontWeight.w900,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 17.0),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text(
                                                  'Nama Penerima',
                                                  style: TextStyle(
                                                    fontSize: 12.0,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                Text(
                                                  data.dataPesanan[i].penerima
                                                      .toUpperCase(),
                                                  style: TextStyle(
                                                    fontSize: 14.0,
                                                    fontWeight: FontWeight.w900,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10.0),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 17.0),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              'Provinsi Muat',
                                              style: TextStyle(
                                                fontSize: 12.0,
                                                color: Colors.black,
                                              ),
                                            ),
                                            Text(data.dataPesanan[i].prov_asal,
                                                style: TextStyle(
                                                  fontSize: 12.0,
                                                  fontWeight: FontWeight.w900,
                                                  color: Colors.black,
                                                )),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 10.0),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 17.0),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              'Provinsi Bongkar',
                                              style: TextStyle(
                                                fontSize: 12.0,
                                                color: Colors.black,
                                              ),
                                            ),
                                            Text(
                                                data.dataPesanan[i].prov_tujuan,
                                                style: TextStyle(
                                                  fontSize: 12.0,
                                                  fontWeight: FontWeight.w900,
                                                  color: Colors.black,
                                                )),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 10.0),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 17.0),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text(
                                                  'Tgl Pesan',
                                                  style: TextStyle(
                                                    fontSize: 12.0,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                Text(
                                                    DateFormat("dd-MM-yyyy")
                                                        .format(DateFormat(
                                                                "dd-MM-yyyy")
                                                            .parse(data
                                                                .dataPesanan[i]
                                                                .order_date)),
                                                    style: TextStyle(
                                                      fontSize: 12.0,
                                                      fontWeight:
                                                          FontWeight.w900,
                                                      color: Colors.black,
                                                    )),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 17.0),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text(
                                                  data.dataPesanan[i]
                                                              .payment_status ==
                                                          "8"
                                                      ? 'Tgl Batal'
                                                      : "Tgl Bayar",
                                                  style: TextStyle(
                                                    fontSize: 12.0,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                Text(
                                                    data.dataPesanan[i]
                                                                .payment_status ==
                                                            "0"
                                                        ? "-"
                                                        : DateFormat(
                                                                "dd-MM-yyyy")
                                                            .format(DateFormat(
                                                                    "dd-MM-yyyy")
                                                                .parse(data
                                                                    .dataPesanan[
                                                                        i]
                                                                    .payment_date)),
                                                    style: TextStyle(
                                                      fontSize: 12.0,
                                                      fontWeight:
                                                          FontWeight.w900,
                                                      color: Colors.black,
                                                    )),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 17.0),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text(
                                                  'Uk. Container',
                                                  style: TextStyle(
                                                    fontSize: 12.0,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                Text(
                                                    data.dataPesanan[i]
                                                                .container_id ==
                                                            "1"
                                                        ? '20" (ft)'
                                                        : '40" (ft)',
                                                    style: TextStyle(
                                                      fontSize: 12.0,
                                                      fontWeight:
                                                          FontWeight.w900,
                                                      color: Colors.black,
                                                    )),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 17.0),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text(
                                                  'Qty',
                                                  style: TextStyle(
                                                    fontSize: 12.0,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                Text(data.dataPesanan[i].qty,
                                                    style: TextStyle(
                                                      fontSize: 12.0,
                                                      fontWeight:
                                                          FontWeight.w900,
                                                      color: Colors.black,
                                                    )),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10.0),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        margin: EdgeInsets.only(
                                            left: 17.0, right: 17.0),
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            side: BorderSide(
                                              color: Color(0xFFB8B8B8),
                                            ),
                                            textStyle: TextStyle(
                                              color: Colors.white,
                                            ),
                                            primary: Color(0xFFF4F4F4),
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                            ),
                                          ),
                                          onPressed: () async {
                                            if (data.dataPesanan[i]
                                                    .payment_status ==
                                                '0') {
                                              _showDialog(
                                                  context,
                                                  SimpleFontelicoProgressDialogType
                                                      .normal,
                                                  'Normal');
                                              await Provider.of<MasterProvider>(
                                                      context,
                                                      listen: false)
                                                  .showTanggalBayar(data
                                                      .dataPesanan[i].nobukti)
                                                  .then((value) async {
                                                payment = await getPembayaran(
                                                    value.payment_name);
                                                print(value);
                                                _dialog.hide();
                                                Future.delayed(
                                                    const Duration(seconds: 0),
                                                    () async {
                                                  final returndata =
                                                      await Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder:
                                                                  (context) =>
                                                                      Bayar(
                                                                        lokasiMuat:
                                                                            value.lokasiMuat,
                                                                        lokasiBongkar:
                                                                            value.lokasiBongkar,
                                                                        harga_bayar:
                                                                            value.harga,
                                                                        noVA: value
                                                                            .noVA,
                                                                        payment_name:
                                                                            payment,
                                                                        waktu_bayar:
                                                                            value.waktu_bayar,
                                                                        bill_no:
                                                                            value.bill_no,
                                                                        endDate:
                                                                            value.endDate,
                                                                        link:
                                                                            "ListPesanan",
                                                                        nobukti:
                                                                            value.nobukti,
                                                                      )));
                                                  print(returndata);
                                                  if (returndata ==
                                                      "ListPesanan") {
                                                    Future.delayed(
                                                        Duration.zero, () {
                                                      _showDialog(
                                                          context,
                                                          SimpleFontelicoProgressDialogType
                                                              .normal,
                                                          'Normal');
                                                      getDataMaster();
                                                    });
                                                  }
                                                });
                                              });
                                            } else if (data.dataPesanan[i]
                                                    .payment_status ==
                                                '2') {
                                              _showDialog(
                                                  context,
                                                  SimpleFontelicoProgressDialogType
                                                      .normal,
                                                  'Normal');
                                              await Provider.of<MasterProvider>(
                                                      context,
                                                      listen: false)
                                                  .listPesananRow(data
                                                      .dataPesanan[i].nobukti)
                                                  .then((value) async {
                                                payment = await getPembayaran(
                                                    value.payment_code);
                                                _dialog.hide();
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            PaymentSuccess(
                                                              harga_bayar:
                                                                  value.harga,
                                                              noVA:
                                                                  value.trx_id,
                                                              nobukti:
                                                                  value.nobukti,
                                                              payment_status:
                                                                  int.parse(data
                                                                      .dataPesanan[
                                                                          i]
                                                                      .payment_status),
                                                              alamat_asal: value
                                                                  .alamat_asal,
                                                              alamat_tujuan: value
                                                                  .alamat_tujuan,
                                                              order_date: value
                                                                  .order_date,
                                                              payment_date: value
                                                                  .payment_date,
                                                              payment_code:
                                                                  payment,
                                                              link:
                                                                  'ListPesanan',
                                                              latitude_pelabuhan_asal:
                                                                  value
                                                                      .latitude_pelabuhan_asal,
                                                              longitude_pelabuhan_asal:
                                                                  value
                                                                      .longitude_pelabuhan_asal,
                                                              latitude_pelabuhan_tujuan:
                                                                  value
                                                                      .latitude_pelabuhan_tujuan,
                                                              longitude_pelabuhan_tujuan:
                                                                  value
                                                                      .longitude_pelabuhan_tujuan,
                                                              latitude_muat: value
                                                                  .latitude_muat,
                                                              longitude_muat: value
                                                                  .longitude_muat,
                                                              latitude_bongkar:
                                                                  value
                                                                      .latitude_bongkar,
                                                              longitude_bongkar:
                                                                  value
                                                                      .longitude_bongkar,
                                                              notelppengirim: value
                                                                  .notelppengirim,
                                                              pengirim: value
                                                                  .pengirim,
                                                              penerima: value
                                                                  .penerima,
                                                              notelppenerima: value
                                                                  .notelppenerima,
                                                              buktipdf: value
                                                                  .buktipdf,
                                                              note_pengirim: value
                                                                  .notepengirim,
                                                              note_penerima: value
                                                                  .notepenerima,
                                                              lampiraninvoice: value
                                                                  .lampiraninvoice,
                                                              placeidasal: value
                                                                  .placeidasal,
                                                              pelabuhanidasal: value
                                                                  .pelabuhanidasal,
                                                              jarak_asal: value
                                                                  .jarak_asal,
                                                              waktu_asal: value
                                                                  .waktu_asal,
                                                              namapelabuhanmuat:
                                                                  value
                                                                      .namapelabuhanmuat,
                                                              placeidtujuan: value
                                                                  .placeidtujuan,
                                                              pelabuhanidtujuan:
                                                                  value
                                                                      .pelabuhanidtujuan,
                                                              jarak_tujuan: value
                                                                  .jarak_tujuan,
                                                              waktu_tujuan: value
                                                                  .waktu_tujuan,
                                                              namapelabuhanbongkar:
                                                                  value
                                                                      .namapelabuhanbongkar,
                                                              container_id: value
                                                                  .container_id,
                                                              nilaibarang: value
                                                                  .nilaibarang,
                                                              qty: value.qty,
                                                              jenisbarang: value
                                                                  .jenisbarang,
                                                              namabarang: value
                                                                  .namabarang,
                                                              keterangantambahan:
                                                                  value
                                                                      .keterangantambahan,
                                                              invoicetambahan: value
                                                                  .invoiceTambahan,
                                                              merchant_id: value
                                                                  .merchant_id,
                                                              merchant_password:
                                                                  value
                                                                      .merchant_password,
                                                              totalNominal: value
                                                                  .totalNominal,
                                                            )));
                                              });
                                            } else if (data.dataPesanan[i]
                                                    .payment_status ==
                                                '8') {
                                              _showDialog(
                                                  context,
                                                  SimpleFontelicoProgressDialogType
                                                      .normal,
                                                  'Normal');
                                              await Provider.of<MasterProvider>(
                                                      context,
                                                      listen: false)
                                                  .listPesananRow(data
                                                      .dataPesanan[i].nobukti)
                                                  .then((value) async {
                                                payment = await getPembayaran(
                                                    value.payment_code);
                                                print(value.payment_code);
                                                _dialog.hide();
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        PaymentSuccess(
                                                      harga_bayar: value.harga,
                                                      noVA: data.dataPesanan[i]
                                                          .trx_id,
                                                      nobukti: value.nobukti,
                                                      payment_status: int.parse(
                                                          data.dataPesanan[i]
                                                              .payment_status),
                                                      alamat_asal:
                                                          value.alamat_asal,
                                                      alamat_tujuan:
                                                          value.alamat_tujuan,
                                                      order_date:
                                                          value.order_date,
                                                      payment_date:
                                                          value.payment_date,
                                                      payment_code: payment,
                                                      link: 'ListPesanan',
                                                      latitude_pelabuhan_asal: value
                                                          .latitude_pelabuhan_asal,
                                                      longitude_pelabuhan_asal:
                                                          value
                                                              .longitude_pelabuhan_asal,
                                                      latitude_pelabuhan_tujuan:
                                                          value
                                                              .latitude_pelabuhan_tujuan,
                                                      longitude_pelabuhan_tujuan:
                                                          value
                                                              .longitude_pelabuhan_tujuan,
                                                      latitude_muat:
                                                          value.latitude_muat,
                                                      longitude_muat:
                                                          value.longitude_muat,
                                                      latitude_bongkar: value
                                                          .latitude_bongkar,
                                                      longitude_bongkar: value
                                                          .longitude_bongkar,
                                                      notelppengirim:
                                                          value.notelppengirim,
                                                      pengirim: value.pengirim,
                                                      penerima: value.penerima,
                                                      notelppenerima:
                                                          value.notelppenerima,
                                                      buktipdf: value.buktipdf,
                                                      note_pengirim:
                                                          value.notepengirim,
                                                      note_penerima:
                                                          value.notepenerima,
                                                      lampiraninvoice:
                                                          value.lampiraninvoice,
                                                      placeidasal:
                                                          value.placeidasal,
                                                      pelabuhanidasal:
                                                          value.pelabuhanidasal,
                                                      jarak_asal:
                                                          value.jarak_asal,
                                                      waktu_asal:
                                                          value.waktu_asal,
                                                      namapelabuhanmuat: value
                                                          .namapelabuhanmuat,
                                                      placeidtujuan:
                                                          value.placeidtujuan,
                                                      pelabuhanidtujuan: value
                                                          .pelabuhanidtujuan,
                                                      jarak_tujuan:
                                                          value.jarak_tujuan,
                                                      waktu_tujuan:
                                                          value.waktu_tujuan,
                                                      namapelabuhanbongkar: value
                                                          .namapelabuhanbongkar,
                                                      container_id:
                                                          value.container_id,
                                                      nilaibarang:
                                                          value.nilaibarang,
                                                      qty: value.qty,
                                                      jenisbarang:
                                                          value.jenisbarang,
                                                      namabarang:
                                                          value.namabarang,
                                                      keterangantambahan: value
                                                          .keterangantambahan,
                                                      invoicetambahan:
                                                          value.invoiceTambahan,
                                                      merchant_id:
                                                          value.merchant_id,
                                                      merchant_password: value
                                                          .merchant_password,
                                                      totalNominal:
                                                          value.totalNominal,
                                                    ),
                                                  ),
                                                );
                                              });
                                            } else if (data.dataPesanan[i]
                                                        .payment_status ==
                                                    '10' ||
                                                data.dataPesanan[i]
                                                        .payment_status ==
                                                    '11') {
                                              _showDialog(
                                                  context,
                                                  SimpleFontelicoProgressDialogType
                                                      .normal,
                                                  'Normal');
                                              await Provider.of<MasterProvider>(
                                                      context,
                                                      listen: false)
                                                  .listPesananRow(data
                                                      .dataPesanan[i].nobukti)
                                                  .then((value) async {
                                                payment = await getPembayaran(
                                                    value.payment_code);
                                                print(value.payment_code);
                                                _dialog.hide();
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        PaymentSuccessRefund(
                                                      harga_bayar: value.harga,
                                                      noVA: data.dataPesanan[i]
                                                          .trx_id,
                                                      nobukti: value.nobukti,
                                                      payment_status: int.parse(
                                                          data.dataPesanan[i]
                                                              .payment_status),
                                                      alamat_asal:
                                                          value.alamat_asal,
                                                      alamat_tujuan:
                                                          value.alamat_tujuan,
                                                      order_date:
                                                          value.order_date,
                                                      payment_date:
                                                          value.payment_date,
                                                      payment_code: payment,
                                                      link: 'ListPesanan',
                                                      latitude_pelabuhan_asal: value
                                                          .latitude_pelabuhan_asal,
                                                      longitude_pelabuhan_asal:
                                                          value
                                                              .longitude_pelabuhan_asal,
                                                      latitude_pelabuhan_tujuan:
                                                          value
                                                              .latitude_pelabuhan_tujuan,
                                                      longitude_pelabuhan_tujuan:
                                                          value
                                                              .longitude_pelabuhan_tujuan,
                                                      latitude_muat:
                                                          value.latitude_muat,
                                                      longitude_muat:
                                                          value.longitude_muat,
                                                      latitude_bongkar: value
                                                          .latitude_bongkar,
                                                      longitude_bongkar: value
                                                          .longitude_bongkar,
                                                      notelppengirim:
                                                          value.notelppengirim,
                                                      pengirim: value.pengirim,
                                                      penerima: value.penerima,
                                                      notelppenerima:
                                                          value.notelppenerima,
                                                      buktipdf: value.buktipdf,
                                                      note_pengirim:
                                                          value.notepengirim,
                                                      note_penerima:
                                                          value.notepenerima,
                                                      lampiraninvoice:
                                                          value.lampiraninvoice,
                                                      placeidasal:
                                                          value.placeidasal,
                                                      pelabuhanidasal:
                                                          value.pelabuhanidasal,
                                                      jarak_asal:
                                                          value.jarak_asal,
                                                      waktu_asal:
                                                          value.waktu_asal,
                                                      namapelabuhanmuat: value
                                                          .namapelabuhanmuat,
                                                      placeidtujuan:
                                                          value.placeidtujuan,
                                                      pelabuhanidtujuan: value
                                                          .pelabuhanidtujuan,
                                                      jarak_tujuan:
                                                          value.jarak_tujuan,
                                                      waktu_tujuan:
                                                          value.waktu_tujuan,
                                                      namapelabuhanbongkar: value
                                                          .namapelabuhanbongkar,
                                                      container_id:
                                                          value.container_id,
                                                      nilaibarang:
                                                          value.nilaibarang,
                                                      qty: value.qty,
                                                      jenisbarang:
                                                          value.jenisbarang,
                                                      namabarang:
                                                          value.namabarang,
                                                      keterangantambahan: value
                                                          .keterangantambahan,
                                                      invoicetambahan:
                                                          value.invoiceTambahan,
                                                      merchant_id:
                                                          value.merchant_id,
                                                      merchant_password: value
                                                          .merchant_password,
                                                      totalNominal:
                                                          value.totalNominal,
                                                      namabankrefund:
                                                          value.namabankrefund,
                                                      norekening:
                                                          value.norekening,
                                                      namarekening:
                                                          value.namarekening,
                                                      cabangbankrefund: value
                                                          .cabangbankrefund,
                                                      nominalrefund:
                                                          value.nominalrefund,
                                                      keteranganrefund: value
                                                          .keteranganrefund,
                                                      tglrefund:
                                                          value.tglrefund,
                                                    ),
                                                  ),
                                                );
                                              });
                                            }
                                          },
                                          child: Padding(
                                              padding: EdgeInsets.only(
                                                  left: 16.0,
                                                  right: 16.0,
                                                  top: 12,
                                                  bottom: 12),
                                              child: Text(
                                                "Lihat Detail",
                                                style: TextStyle(
                                                    fontSize: 14.0,
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              )),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                clipper: ShapeBorderClipper(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(14.28))),
                              ),
                            ),
                            decoration: new BoxDecoration(
                              color: new Color(0xFFFFFFFF),
                              shape: BoxShape.rectangle,
                              borderRadius: new BorderRadius.circular(14.28),
                              border: Border(
                                top: BorderSide(color: Color(0xFFBDBDBD)),
                                bottom: BorderSide(color: Color(0xFFBDBDBD)),
                                left: BorderSide(color: Color(0xFFBDBDBD)),
                                right: BorderSide(color: Color(0xFFBDBDBD)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  });
            }
          }),
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

  Widget alertBerhasilPesan() {
    Dialogs.materialDialog(
        color: Colors.white,
        msg:
            'Anda belum bisa melakukan pemesanan orderan,silahkan menyelesaikan pembayaran yang sebelum terlebih dahulu',
        title: 'Gagal',
        lottieBuilder: Lottie.asset(
          'assets/imgs/updated-transaction.json',
          fit: BoxFit.contain,
        ),
        context: context,
        actions: [
          IconsButton(
            onPressed: () {
              Navigator.pop(context);
            },
            text: 'Ok',
            iconData: Icons.done,
            color: Colors.blue,
            textStyle: TextStyle(color: Colors.white),
            iconColor: Colors.white,
          ),
        ]);
  }
}

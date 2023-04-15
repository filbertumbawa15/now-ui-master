import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:now_ui_flutter/constants/Theme.dart';
import 'package:now_ui_flutter/screens/payment_success.dart';
import 'package:now_ui_flutter/screens/refund_detail_biaya.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';

class RefundDetail extends StatefulWidget {
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
  final String nominalrefund;
  final String namarekening;
  final String bankrekening;
  final String cabangrekening;
  final String norekening;
  final String tglrefund;
  final String statusapproval;
  final String buktipdfrefund;

  const RefundDetail({
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
    this.note_pengirim,
    this.pengirim,
    this.notelppengirim,
    this.note_penerima,
    this.penerima,
    this.notelppenerima,
    this.nobukti,
    this.nominalrefund,
    this.namarekening,
    this.bankrekening,
    this.cabangrekening,
    this.norekening,
    this.tglrefund,
    this.statusapproval,
    this.buktipdfrefund,
  }) : super(key: key);

  @override
  State<RefundDetail> createState() => _RefundDetailState();
}

class _RefundDetailState extends State<RefundDetail> {
  SimpleFontelicoProgressDialog _dialog;

  @override
  initState() {
    super.initState();
    print(widget.statusapproval);
  }

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
          "Refund Detail",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Container(
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 0.0),
            Container(
              height: 150.0,
              margin: EdgeInsets.only(
                  left: 10.0, right: 10.0, top: 16.0, bottom: 0.0),
              child: new Column(
                children: <Widget>[
                  Container(
                    height: 150.0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 12.0),
                        Column(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(left: 15.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        padding: EdgeInsets.all(6.0),
                                        decoration: BoxDecoration(
                                            color: NowUIColors.info,
                                            borderRadius:
                                                BorderRadius.circular(6.0)),
                                        child: Text(
                                          "Nominal Refund",
                                          style: TextStyle(
                                            fontSize: 20.0,
                                            color: Color.fromARGB(
                                                255, 255, 255, 255),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 25.0),
                                  widget.statusapproval == "10"
                                      ? Text(
                                          "Sedang diproses",
                                          style: TextStyle(
                                            fontSize: 40.0,
                                            color: Color.fromARGB(
                                                255, 255, 255, 255),
                                          ),
                                        )
                                      : new Text(
                                          NumberFormat.currency(
                                                  locale: 'id',
                                                  symbol: 'Rp.',
                                                  decimalDigits: 00)
                                              .format(double.tryParse(
                                                  widget.nominalrefund)),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 40.0,
                                            color: Color.fromARGB(
                                                255, 255, 255, 255),
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
                      gradient: LinearGradient(
                        begin: Alignment.bottomRight,
                        end: Alignment.bottomLeft,
                        stops: [
                          0.2,
                          1.2,
                        ],
                        colors: [
                          NowUIColors.info,
                          Color.fromARGB(255, 240, 240, 240),
                        ],
                      ),
                      shape: BoxShape.rectangle,
                      borderRadius: new BorderRadius.circular(10.0),
                      boxShadow: <BoxShadow>[
                        new BoxShadow(
                          color: Color.fromARGB(255, 0, 149, 255),
                          blurRadius: 0.0,
                          offset: new Offset(6.0, -8.0),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 15.0),
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Text(
                "Detail Data Refund",
                style: TextStyle(fontSize: 28.0),
              ),
            ),
            SizedBox(height: 15.0),
            GestureDetector(
              onTap: () async {
                _showDialog(context, SimpleFontelicoProgressDialogType.normal,
                    'Normal');
                await Future.delayed(const Duration(seconds: 2));
                _dialog.hide();
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PaymentSuccess(
                              harga_bayar: widget.harga_bayar,
                              noVA: widget.noVA,
                              nobukti: widget.nobukti,
                              payment_status: widget.payment_status,
                              alamat_asal: widget.alamat_asal,
                              note_pengirim: widget.note_pengirim,
                              pengirim: widget.pengirim,
                              notelppengirim: widget.notelppengirim,
                              alamat_tujuan: widget.alamat_tujuan,
                              note_penerima: widget.note_penerima,
                              penerima: widget.penerima,
                              notelppenerima: widget.notelppenerima,
                              order_date: widget.order_date,
                              payment_date: widget.payment_date,
                              payment_code: widget.payment_code,
                              link: 'ListPesanan',
                              latitude_pelabuhan_asal:
                                  widget.latitude_pelabuhan_asal,
                              longitude_pelabuhan_asal:
                                  widget.longitude_pelabuhan_asal,
                              latitude_pelabuhan_tujuan:
                                  widget.latitude_pelabuhan_tujuan,
                              longitude_pelabuhan_tujuan:
                                  widget.longitude_pelabuhan_tujuan,
                              latitude_muat: widget.latitude_muat,
                              longitude_muat: widget.longitude_muat,
                              latitude_bongkar: widget.latitude_bongkar,
                              longitude_bongkar: widget.longitude_bongkar,
                              nominalrefund: double.parse(widget.nominalrefund),
                              buktipdf: widget.buktipdfrefund,
                            )));
              },
              child: Container(
                height: 90.0,
                margin: EdgeInsets.only(
                    left: 10.0, right: 10.0, top: 16.0, bottom: 0.0),
                child: new Column(
                  children: <Widget>[
                    Container(
                      height: 90.0,
                      child: Column(
                        children: [
                          SizedBox(height: 12.0),
                          Column(
                            children: <Widget>[
                              SizedBox(height: 15.0),
                              Padding(
                                padding: const EdgeInsets.only(left: 15.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      child: Icon(
                                        Icons.list_alt_outlined,
                                        size: 40,
                                        color: Color.fromARGB(255, 6, 134, 238),
                                      ),
                                      decoration: BoxDecoration(
                                          color: NowUIColors.info,
                                          borderRadius:
                                              BorderRadius.circular(6.0)),
                                    ),
                                    SizedBox(width: 16.0),
                                    Expanded(
                                      // Wrap this column inside an expanded widget so that framework allocates max width for this column inside this row
                                      child: Text(
                                          "Tampilkan data pesanan (lokasi muat,bongkar, dll) "),
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 15.0),
                                      child: Icon(
                                        Icons.arrow_forward_ios_outlined,
                                        color: NowUIColors.info,
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
                        borderRadius: new BorderRadius.circular(3.0),
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
            ),
            SizedBox(height: 15.0),
            widget.statusapproval == "11"
                ? GestureDetector(
                    onTap: () async {
                      _showDialog(context,
                          SimpleFontelicoProgressDialogType.normal, 'Normal');
                      await Future.delayed(const Duration(seconds: 2));
                      _dialog.hide();
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: ((context) => RefundDetailBiaya(
                                    nominaltransaksi:
                                        double.parse(widget.harga_bayar),
                                    nominalrefund:
                                        double.parse(widget.nominalrefund),
                                  ))));
                    },
                    child: Container(
                      height: 90.0,
                      margin: EdgeInsets.only(
                          left: 10.0, right: 10.0, top: 16.0, bottom: 0.0),
                      child: new Column(
                        children: <Widget>[
                          Container(
                            height: 90.0,
                            child: Column(
                              children: [
                                SizedBox(height: 12.0),
                                Column(
                                  children: <Widget>[
                                    SizedBox(height: 15.0),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(left: 15.0),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Container(
                                            child: Icon(
                                              Icons.attach_money_outlined,
                                              size: 40,
                                              color: Color.fromARGB(
                                                  255, 6, 134, 238),
                                            ),
                                            decoration: BoxDecoration(
                                                color: NowUIColors.info,
                                                borderRadius:
                                                    BorderRadius.circular(6.0)),
                                          ),
                                          SizedBox(width: 16.0),
                                          Expanded(
                                            // Wrap this column inside an expanded widget so that framework allocates max width for this column inside this row
                                            child: Text(
                                                "Tampilkan biaya refund (nominal refund, selisih, note) "),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 15.0),
                                            child: Icon(
                                              Icons.arrow_forward_ios_outlined,
                                              color: NowUIColors.info,
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
                              borderRadius: new BorderRadius.circular(3.0),
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
                  )
                : SizedBox(
                    height: 5.0,
                  ),
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

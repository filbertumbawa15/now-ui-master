import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:now_ui_flutter/providers/services.dart';
import 'package:provider/provider.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:pusher_client/pusher_client.dart';
import 'package:now_ui_flutter/globals.dart' as globals;

class Tracking extends StatefulWidget {
  final String kode_container;
  final String nobukti;
  final String qty;
  final String jobemkl;
  const Tracking({
    Key key,
    this.kode_container,
    this.nobukti,
    this.qty,
    this.jobemkl,
  }) : super(key: key);

  @override
  State<Tracking> createState() => _TrackingState();
}

class _TrackingState extends State<Tracking> {
  SimpleFontelicoProgressDialog _dialog;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration.zero, () {
      _showDialog(context, SimpleFontelicoProgressDialogType.normal, 'Normal');
      getStatusBarang();
    });
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
    // await Future.delayed(Duration(seconds: 2));
    // _dialog.hide();
  }

  void getStatusBarang() async {
    await Provider.of<MasterProvider>(context, listen: false)
        .getStatusBarang(widget.nobukti, widget.qty, widget.jobemkl)
        .then((value) {
      setState(() {});
    });
    setState(() {
      _dialog.hide();
    });
  }

  void _initStatusTracking() async {
    globals.channel.bind('App\\Events\\CheckTrackingOrder',
        (PusherEvent event) async {
      print(event.data);
      final result =
          jsonDecode(jsonDecode(event.data)["message"])['status_pesanan'];
      if (result == widget.nobukti) {
        Future.delayed(Duration.zero, () {
          _showDialog(
              context, SimpleFontelicoProgressDialogType.normal, 'Normal');
          getStatusBarang();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: SafeArea(
        child: DefaultTabController(
          length: 2, //numbers of tab
          child: Scaffold(
            backgroundColor: Color(0xFFF1F1EF),
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
                "Status Barang",
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
            body: Center(
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 15.0),
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
                                      'No. Pesanan',
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        color: Color(0xFF666666),
                                        fontFamily: 'Nunito-Medium',
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
                                                widget.nobukti,
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
                        SizedBox(height: 8.0),
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
                                      'No. Container',
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        color: Color(0xFF666666),
                                        fontFamily: 'Nunito-Medium',
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
                                                widget.kode_container,
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
                  SizedBox(height: 15.0),
                  Expanded(
                    child:
                        Consumer<MasterProvider>(builder: (context, data, _) {
                      return ListView.builder(
                        itemCount: data.dataStatus.length,
                        itemBuilder: (context, i) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                            ),
                            child: TimelineTile(
                              alignment: TimelineAlign.manual,
                              lineXY: 0.1,
                              isFirst: i == 0,
                              isLast: i == data.dataStatus.length - 1,
                              indicatorStyle: IndicatorStyle(
                                padding: EdgeInsets.only(
                                    right: 30.0, top: 1.0, bottom: 1.0),
                                width: 40,
                                height: 20,
                                indicator:
                                    _IndicatorExample(color: Color(0xFF039600)),
                                iconStyle: IconStyle(
                                  color: Colors.white,
                                  iconData: Icons.insert_emoticon,
                                ),
                              ),
                              beforeLineStyle: LineStyle(
                                color: Color(0xFFAEAEAE),
                                thickness: 1,
                              ),
                              endChild: Padding(
                                padding: const EdgeInsets.only(
                                    left: 0, top: 25, right: 0, bottom: 0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Expanded(
                                        // Wrap this column inside an expanded widget so that framework allocates max width for this column inside this row
                                        child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        SizedBox(height: 5.0),
                                        Container(
                                          padding: EdgeInsets.only(
                                              left: 5.0,
                                              right: 5.0,
                                              top: 2.0,
                                              bottom: 2.0),
                                          decoration: BoxDecoration(
                                              color: Color(0xFFD2E9FF),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(6.0))),
                                          child: Text(
                                            DateFormat.yMMMEd('en_US').format(
                                                        DateFormat("yyyy-MM-dd")
                                                            .parse(data
                                                                .dataStatus[i]
                                                                .tgl_status)) ==
                                                    DateFormat.yMMMEd('en_US')
                                                        .format(DateTime.now())
                                                ? "Hari Ini"
                                                : DateFormat.yMMMEd('en_US')
                                                    .format(
                                                        DateFormat("yyyy-MM-dd")
                                                            .parse(data
                                                                .dataStatus[i]
                                                                .tgl_status)),
                                            style: TextStyle(
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF003C96),
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        Card(
                                          elevation: 2,
                                          child: Padding(
                                            padding: const EdgeInsets.all(3.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  data.dataStatus[i]
                                                      .kode_status,
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                    fontSize: 17.0,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                SizedBox(height: 7.0),
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Expanded(
                                                        // Then wrap your text widget with expanded
                                                        child: Text(
                                                      data.dataStatus[i]
                                                          .keterangan,
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 14.0,
                                                      ),
                                                      textAlign: TextAlign.left,
                                                      softWrap: true,
                                                    )),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    )),
                                    // ],
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
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
            color: Color(0xFF039600),
            width: 3,
          ),
        ),
      ),
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

class Example {
  const Example(this.image, this.name, this.description, this.date);

  final String image;
  final String name;
  final String description;
  final String date;
}

List<Example> examples = [
  Example('assets/imgs/order.png', 'Pesan', 'Shipper memesan orderan container',
      '05 April 2022'),
  Example('assets/imgs/booking_proccess.png', 'Proses Booking',
      'Orderan sedang di proses', '05 April 2022'),
  Example('assets/imgs/trucking.png', 'Stuffing',
      'Container sudah menuju ke gudang shipper', '07 April 2022'),
  Example('assets/imgs/warehouse_container.png', 'Masuk Gudang Pengiriman',
      'Container masuk ke gudang dan siap untuk dimuat', '07 April 2022'),
  Example(
      'assets/imgs/stuffing.png',
      'Keluar Gudang Pengiriman',
      'Container keluar dari gudang dan sudah selesai pemuatan dan siap menuju depo',
      '07 April 2022'),
  Example(
      'assets/imgs/shipping_container.png',
      'Turun Depo',
      'Container sampai di depo dan siap berangkat ke tujuan penerima',
      '07 April 2022'),
  Example('assets/imgs/kapal-tiba.png', 'Kapal Tiba',
      'Kapal sudah tiba di pelabuhan tujuan', ''),
  Example('assets/imgs/kapal-sandar.png', 'Kapal Sandar',
      'Kapal sudah sandar di pelabuhan tujuan', ''),
  Example(
      'assets/imgs/out-depo.png',
      'Out Depo',
      'Container sudah di turunkan ke kapal dan siap diantar ke gudang penerima',
      ''),
  Example('assets/imgs/warehouse_container.png', 'Masuk Gudang Penerima',
      'Container masuk ke gudang dan siap untuk pembongkaran', ''),
  Example('assets/imgs/stuffing.png', 'Keluar Gudang Penerima',
      'Container keluar dari gudang dan sudah selesai pembongkaran', ''),
];

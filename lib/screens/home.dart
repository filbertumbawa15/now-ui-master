// ignore_for_file: unrelated_type_equality_checks

import 'dart:convert';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:intl/intl.dart';
import 'package:material_dialogs/material_dialogs.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:material_dialogs/widgets/buttons/icon_outline_button.dart';
import 'package:now_ui_flutter/models/dart_models.dart';
import 'package:now_ui_flutter/screens/Chats/chats.dart';
import 'package:now_ui_flutter/screens/VerificationData/data_verifikasi.dart';
import 'package:now_ui_flutter/screens/VerificationData/home_verifikasi.dart';
import 'package:now_ui_flutter/screens/faq.dart';
import 'package:now_ui_flutter/screens/favorites_list.dart';
import 'package:now_ui_flutter/screens/notifications.dart';
import 'package:now_ui_flutter/screens/syaratketentuan.dart';
import 'package:now_ui_flutter/services/UserService.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:now_ui_flutter/globals.dart' as globals;
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
import 'package:pusher_client/pusher_client.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';

class Home extends StatefulWidget {
  final String dataDitolak;

  const Home({Key key, this.dataDitolak}) : super(key: key);
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  SimpleFontelicoProgressDialog _dialog;
  int selectedIndex = 0;

  @override
  void initState() {
    FirebaseMessaging.instance.getToken().then((newToken) {
      globals.fcmToken = newToken;
    });
    _setPrefs();
    _widgetOptions();
    InternetConnectionChecker().onStatusChange.listen(
      (status) {
        globals.hasConnection = status == InternetConnectionStatus.connected;
        print(globals.hasConnection);
        print("koneksinya");
      },
    );
    // print(globals.merchantid);
  }

  List<Widget> _widgetOptions() {
    return [
      Dashboard(
        selectednik: globals.nik,
        selectednpwp: globals.npwp,
        selectedalamatdetail: globals.alamatdetail,
        selectedktpPath: globals.ktpPath,
        selectednama: globals.nama,
        selectednpwpPath: globals.npwpPath,
        selectedtglLahir: globals.tglLahir,
      ),
      Profiles(
        selectednik: globals.nik,
        selectednpwp: globals.npwp,
        selectedalamatdetail: globals.alamatdetail,
        selectedktpPath: globals.ktpPath,
        selectednama: globals.nama,
        selectednpwpPath: globals.npwpPath,
        selectedtglLahir: globals.tglLahir,
      ),
      Settings(
        selectednik: globals.nik,
        selectednpwp: globals.npwp,
        selectedalamatdetail: globals.alamatdetail,
        selectedktpPath: globals.ktpPath,
        selectednama: globals.nama,
        selectednpwpPath: globals.npwpPath,
        selectedtglLahir: globals.tglLahir,
      ),
    ];
  }

  // void editVerifikasi() async {
  //   try {
  //     final response = await http.get(
  //         Uri.parse(
  //             'http://web.transporindo.com/api-orderemkl/public/api/user/getdataverifikasi?id=${globals.loggedinId}'),
  //         headers: {
  //           'Content-Type': 'application/json',
  //           'Accept': 'application/json',
  //           'Authorization': 'Bearer ${globals.accessToken}',
  //         });
  //     if (response.statusCode == 200) {
  //       final result = jsonDecode(response.body);
  //       await getnpwpImage(result['data']['foto_npwp']);
  //       await getKtpImage(result['data']['foto_ktp']);
  //       nik = result['data']['nik'];
  //       nama = result['data']['name'];
  //       alamatdetail = result['data']['alamatdetail'];
  //       tglLahir = result['data']['tgl_lahir'];
  //       npwp = result['data']['no_npwp'];
  //       print("done");
  //     } else {
  //       print("
  // ");
  //       print(response.body);
  //     }
  //   } catch (e) {
  //     print(e.toString());
  //   }
  // }

  // Future<File> getnpwpImage(String npwp) async {
  //   var rng = new Random();
  //   Directory tempDir = await getTemporaryDirectory();
  //   String tempPath = tempDir.path;
  //   File file_npwp =
  //       new File('$tempPath' + (rng.nextInt(100)).toString() + '.jpg');
  //   http.Response response = await http.get(
  //       Uri.parse(
  //           '${globals.url}/api-orderemkl/public/api/user/image/npwp/$npwp'),
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Accept': 'application/json',
  //         'Authorization': 'Bearer ${globals.accessToken}',
  //       });
  //   await file_npwp.writeAsBytes(response.bodyBytes);
  //   npwpPath = file_npwp;
  // }

  // Future<File> getKtpImage(String ktp) async {
  //   var rng = new Random();
  //   Directory tempDir = await getTemporaryDirectory();
  //   String tempPath = tempDir.path;
  //   File file_ktp =
  //       new File('$tempPath' + (rng.nextInt(100)).toString() + '.jpg');
  //   http.Response response = await http.get(
  //       Uri.parse(
  //           '${globals.url}/api-orderemkl/public/api/user/image/ktp/$ktp'),
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Accept': 'application/json',
  //         'Authorization': 'Bearer ${globals.accessToken}',
  //       });
  //   await file_ktp.writeAsBytes(response.bodyBytes);
  //   ktpPath = file_ktp;
  // }

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

  // void getDataMaster() async {
  //   await Provider.of<MasterProvider>(context, listen: false)
  //       .callSkeletonListPesanan(context, globals.loggedinId);
  // }

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
      if (selectedIndex == 2) {
        setState(() {
          globals.condition = "false";
        });
      }
    });
  }

  void _setPrefs() async {
    globals.prefs = await SharedPreferences.getInstance();
    if (globals.prefs.getString('user') != null) {
      globals.loggedIn = true;
      globals.loggedinName =
          jsonDecode(globals.prefs.getString('user'))['name'];
      globals.loggedinEmail =
          jsonDecode(globals.prefs.getString('user'))['email'];
      globals.loggedinTelp =
          jsonDecode(globals.prefs.getString('user'))['telp'];
      globals.channel.bind("App\\Events\\UserVerified",
          (PusherEvent event) async {
        final result =
            jsonDecode(jsonDecode(event.data)["message"])['verifikasiuser'];
        if (result['id'] == globals.loggedinId) {
          _showDialog(
              context, SimpleFontelicoProgressDialogType.normal, 'Normal');
          print(result);
          await checkVerification(globals.loggedinEmail);
          await editVerifikasi();
          setState(() {
            Future.delayed(const Duration(seconds: 3));
            _dialog.hide();
          });
        }
      });
      if (globals.verificationStatus == "14") {
        print(widget.dataDitolak);
      }
    } else {
      globals.loggedinId = null;
      globals.loggedIn = false;
    }
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   getDataMaster();
    // });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // ignore: missing_return
      onWillPop: () async {
        SystemNavigator.pop();
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        extendBody: true,
        // key: _scaffoldKey,
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: _widgetOptions().elementAt(selectedIndex),
        ),
        bottomNavigationBar: Theme(
          data: ThemeData(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: Material(
            elevation: 10,
            child: BottomNavigationBar(
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Beranda',
                  tooltip: '',
                ),
                new BottomNavigationBarItem(
                  icon: new Stack(
                    children: <Widget>[
                      new Icon(Icons.account_circle_sharp),
                    ],
                  ),
                  label: "Profil",
                  tooltip: '',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings),
                  label: 'Pengaturan',
                  tooltip: '',
                ),
              ],
              currentIndex: selectedIndex,
              selectedLabelStyle: TextStyle(
                fontFamily: 'Nunito-Medium',
              ),
              unselectedLabelStyle: TextStyle(
                fontFamily: 'Nunito-Medium',
                fontSize: 14.0,
              ),
              fixedColor: Color(0xFF5599E9),
              onTap: onItemTapped,
            ),
          ),
        ),
      ),
    );
  }
}

class Dashboard extends StatefulWidget {
  @override
  final File selectednpwpPath;
  final File selectedktpPath;
  final String selectednik;
  final String selectedalamatdetail;
  final String selectednama;
  final String selectedtglLahir;
  final String selectednpwp;
  final int selecteduserid;

  const Dashboard({
    Key key,
    this.selectednpwpPath,
    this.selectedktpPath,
    this.selectednik,
    this.selectedalamatdetail,
    this.selectednama,
    this.selectedtglLahir,
    this.selectednpwp,
    this.selecteduserid,
  }) : super(key: key);
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  void initState() {
    super.initState();
    globals.dateAus = DateTime.now().toUtc().toLocal();
  }

  Future<bool> checkOrderan(var user_id) async {
    var data = {"id": user_id};
    var encode = jsonEncode(data);
    final response = await http.get(
        Uri.parse(
            '${globals.url}/api-orderemkl/public/api/pesanan/validasiorderan?data=$encode'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${globals.accessToken}',
        });

    return jsonDecode(response.body)['data'].length > 0;
  }

  List<Whatsapp> whatsapp = <Whatsapp>[
    Whatsapp(name: 'Medan', notelp: '6281321232720'),
    Whatsapp(name: 'Jakarta', notelp: '62895611340514'),
    Whatsapp(name: 'Surabaya', notelp: '6285233534605'),
    Whatsapp(name: 'Makassar', notelp: '6285233534605'),
  ];

  int currentPos = 0;
  final List<String> imgList = [
    'https://www.transporindo.com/wp-content/uploads/2020/06/truckmin.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFFFFFF),
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Image.asset(
            'assets/imgs/taslogo.png',
          ),
        ),
        actions: [
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: Size(15.0, 15.0),
                backgroundColor: Color(0xFFE7E7E7),
                splashFactory: NoSplash.splashFactory,
                elevation: 0,
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/notifications');
              },
              child: Icon(
                Icons.notifications,
                color: Color(0xFF5599E9),
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Color(0xFFF1F1EF),
      body: ListView(
        padding: EdgeInsets.all(8.0),
        children: [
          SizedBox(height: 15.0),
          Column(
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(width: 10.0),
                  Expanded(
                      // Wrap this column inside an expanded widget so that framework allocates max width for this column inside this row
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "PT. TRANSPORINDO AGUNG SEJAHTERA",
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                            softWrap: true,
                          ),
                        ],
                      ),
                    ],
                  )),
                ],
              ),
            ],
          ),
          CarouselSlider.builder(
            itemCount: imgList.length,
            options: CarouselOptions(
                viewportFraction: 1.0,
                enlargeCenterPage: false,
                autoPlay: false,
                onPageChanged: (index, reason) {
                  // setState(() {
                  //   currentPos = index;
                  // });
                }),
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15.0),
                  child: Image.asset(
                    'assets/imgs/carousel.jpg',
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.width / 2.5,
                    fit: BoxFit.fill,
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 18.0),
          Text(
            'Categories',
            textAlign: TextAlign.start,
            style: TextStyle(
              fontFamily: 'Nunito-Medium',
              fontSize: 20.0,
              color: Color(0xFF313131),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 14.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Column(
                children: [
                  Container(
                    width: 60,
                    margin:
                        EdgeInsets.only(bottom: 10.0, right: 30.0, left: 30.0),
                    decoration: BoxDecoration(
                      color: Color(0xFFFCFCFC),
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(
                        color: Color(0xFFAEAEAE),
                      ),
                    ),
                    child: new InkWell(
                      onTap: () {
                        if (globals.hasConnection == false) {
                          globals.checkConnection(
                            context,
                            "Mohon cek kembali koneksi internet WiFi/Data anda",
                            'Tidak ada koneksi',
                            'assets/imgs/no-internet.json',
                          );
                        } else {
                          Navigator.pushNamed(context, '/ongkir');
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 15.0,
                          bottom: 15.0,
                        ),
                        child: Center(
                            child: Icon(
                          Icons.fact_check,
                          size: 30.0,
                          color: Color(0xFF5599E9),
                        )),
                      ),
                    ),
                  ),
                  new Center(
                    child: new Text("Cek Ongkir",
                        style: new TextStyle(
                            fontSize: 14.0, color: Color(0xFF313131))),
                  )
                ],
              ),
              Column(
                children: [
                  Container(
                    width: 60,
                    margin:
                        EdgeInsets.only(bottom: 10.0, right: 30.0, left: 30.0),
                    decoration: BoxDecoration(
                      color: Color(0xFFFCFCFC),
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(
                        color: Color(0xFFAEAEAE),
                      ),
                    ),
                    child: new InkWell(
                      onTap: () async {
                        if (globals.hasConnection == false) {
                          globals.checkConnection(
                            context,
                            "Mohon cek kembali koneksi internet WiFi/Data anda",
                            'Tidak ada koneksi',
                            'assets/imgs/no-internet.json',
                          );
                        } else {
                          if (globals.loggedIn == false) {
                            Dialogs.materialDialog(
                              color: Colors.white,
                              msg:
                                  "Anda belum menyelesaikan status verifikasi anda/belum login",
                              title: 'Orderan',
                              lottieBuilder: Lottie.asset(
                                'assets/imgs/updated-transaction.json',
                                fit: BoxFit.contain,
                              ),
                              context: context,
                              actions: [
                                IconsButton(
                                  onPressed: () async {
                                    await Navigator.pop(context);
                                    Navigator.pushNamed(context, '/login');
                                  },
                                  text: 'Login Sekarang',
                                  iconData: Icons.account_box_outlined,
                                  color: Colors.blue,
                                  textStyle: TextStyle(
                                      color: Colors.white, fontSize: 12),
                                  iconColor: Colors.white,
                                ),
                                IconsButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  text: 'Nanti Saja',
                                  iconData: Icons.done,
                                  color: Colors.white,
                                  textStyle:
                                      TextStyle(color: Color(0xFF313131)),
                                  iconColor: Color(0xFF313131),
                                ),
                              ],
                            );
                          } else if (globals.verificationStatus == "12" ||
                              globals.verificationStatus == "14" ||
                              globals.verificationStatus == "0") {
                            Dialogs.materialDialog(
                              color: Colors.white,
                              msg:
                                  "Anda belum menyelesaikan status verifikasi anda/belum login",
                              title: 'Orderan',
                              lottieBuilder: Lottie.asset(
                                'assets/imgs/updated-transaction.json',
                                fit: BoxFit.contain,
                              ),
                              context: context,
                              actions: [
                                if (globals.verificationStatus == "14" ||
                                    globals.verificationStatus == "0") ...[
                                  IconsButton(
                                    onPressed: () async {
                                      if (globals.verificationStatus == "14") {
                                        await Navigator.pop(context);
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    DataVerifikasi(
                                                      npwpPath: widget
                                                          .selectednpwpPath,
                                                      ktpPath: widget
                                                          .selectedktpPath,
                                                      nik: widget.selectednik,
                                                      nama: widget.selectednama,
                                                      alamatdetail: widget
                                                          .selectedalamatdetail,
                                                      tglLahir: widget
                                                          .selectedtglLahir,
                                                      npwp: widget.selectednpwp,
                                                      isEdit: true,
                                                    )));
                                      } else if (globals.verificationStatus ==
                                          "0") {
                                        await Navigator.pop(context);
                                        Navigator.pushNamed(
                                            context, '/homeverifikasi');
                                      }
                                    },
                                    text: 'Verifikasi User',
                                    iconData: Icons.account_box_outlined,
                                    color: Colors.blue,
                                    textStyle: TextStyle(
                                        color: Colors.white, fontSize: 13),
                                    iconColor: Colors.white,
                                  ),
                                ],
                                IconsButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  text: 'Nanti Saja',
                                  iconData: Icons.done,
                                  color: Color.fromARGB(255, 206, 206, 206),
                                  textStyle:
                                      TextStyle(color: Color(0xFF313131)),
                                  iconColor: Color(0xFF313131),
                                ),
                              ],
                            );
                            //   Navigator.pushNamed(context, '/login');
                          } else if (await checkOrderan(globals.loggedinId) ==
                              true) {
                            globals.alertBerhasilPesan(
                              context,
                              "Mohon selesaikan orderan awal terlebih dahulu agar dapat melanjutkan pemesanan kembali.",
                              'Orderan masih belum selesai',
                              'assets/imgs/shipping-truck.json',
                            );
                          } else {
                            Navigator.pushNamed(context, '/order');
                          }
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 15.0,
                          bottom: 15.0,
                        ),
                        child: Center(
                            child: Icon(
                          Icons.local_shipping,
                          size: 30.0,
                          color: Color(0xFF5599E9),
                        )),
                      ),
                    ),
                  ),
                  new Center(
                    child: new Text("Pesanan",
                        style: new TextStyle(
                            fontSize: 14.0, color: Color(0xFF313131))),
                  )
                ],
              ),
              Column(
                children: [
                  Container(
                    width: 60,
                    margin:
                        EdgeInsets.only(bottom: 10.0, right: 30.0, left: 30.0),
                    decoration: BoxDecoration(
                      color: Color(0xFFFCFCFC),
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(
                        color: Color(0xFFAEAEAE),
                      ),
                    ),
                    child: new InkWell(
                      onTap: () {
                        if (globals.hasConnection == false) {
                          globals.checkConnection(
                            context,
                            "Mohon cek kembali koneksi internet WiFi/Data anda",
                            'Tidak ada koneksi',
                            'assets/imgs/no-internet.json',
                          );
                        } else {
                          if (globals.loggedIn == false) {
                            Dialogs.materialDialog(
                              color: Colors.white,
                              msg:
                                  "Anda belum menyelesaikan status verifikasi anda/belum login",
                              title: 'Orderan',
                              lottieBuilder: Lottie.asset(
                                'assets/imgs/updated-transaction.json',
                                fit: BoxFit.contain,
                              ),
                              context: context,
                              actions: [
                                IconsButton(
                                  onPressed: () async {
                                    await Navigator.pop(context);
                                    Navigator.pushNamed(context, '/login');
                                  },
                                  text: 'Login Sekarang',
                                  iconData: Icons.account_box_outlined,
                                  color: Colors.blue,
                                  textStyle: TextStyle(
                                      color: Colors.white, fontSize: 12),
                                  iconColor: Colors.white,
                                ),
                                IconsButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  text: 'Nanti Saja',
                                  iconData: Icons.done,
                                  color: Colors.white,
                                  textStyle:
                                      TextStyle(color: Color(0xFF313131)),
                                  iconColor: Color(0xFF313131),
                                ),
                              ],
                            );
                          } else {
                            Navigator.pushNamed(context, '/list_pesanan');
                          }
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 15.0,
                          bottom: 15.0,
                        ),
                        child: Center(
                            child: Icon(
                          Icons.list,
                          size: 30.0,
                          color: Color(0xFF5599E9),
                        )),
                      ),
                    ),
                  ),
                  new Center(
                    child: new Text("List Pesanan",
                        style: new TextStyle(
                            fontSize: 14.0, color: Color(0xFF313131))),
                  )
                ],
              ),
            ],
          ),
        ],
      ),
    );
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

class Profiles extends StatefulWidget {
  final File selectednpwpPath;
  final File selectedktpPath;
  final String selectednik;
  final String selectedalamatdetail;
  final String selectednama;
  final String selectedtglLahir;
  final String selectednpwp;
  final int selecteduserid;

  const Profiles({
    Key key,
    this.selectednpwpPath,
    this.selectedktpPath,
    this.selectednik,
    this.selectedalamatdetail,
    this.selectednama,
    this.selectedtglLahir,
    this.selectednpwp,
    this.selecteduserid,
  }) : super(key: key);

  @override
  _ProfilesState createState() => _ProfilesState();
}

class _ProfilesState extends State<Profiles>
    with SingleTickerProviderStateMixin {
  TabController tabController;
  int selectedIndex = 0;

  @override
  void initState() {
    tabController = TabController(
        initialIndex: selectedIndex,
        length: globals.loggedIn == false || globals.verificationStatus == "0"
            ? 1
            : 2,
        vsync: this);
    super.initState();
    Change();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  var size, height, width;

  Change() {
    if (globals.loggedIn == true) {
      return alreadyLogin();
    } else {
      return notLogin();
    }
  }

  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    height = size.height;
    width = size.width;
    return DefaultTabController(
      length: globals.loggedIn == false || globals.verificationStatus == "0"
          ? 1
          : 2,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        extendBody: true,
        body: Container(
          height: height,
          width: width,
          child: Change(),
          // child: alreadyLogin(),
        ),
      ),
    );
  }

  Widget notLogin() {
    return ListView(
      children: <Widget>[
        Container(
          height: 250,
          decoration: BoxDecoration(
              color: Color(
            0xFFF1F1EF,
          )),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  CircleAvatar(
                    backgroundColor: Color(0xFFD9D9D9),
                    minRadius: 45.0,
                    child: CircleAvatar(
                      radius: 40.0,
                      backgroundImage: AssetImage('assets/imgs/user.png'),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                'USER',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF313131),
                ),
              ),
              Text(
                'email@example.com',
                style: TextStyle(
                  color: Color(0xFFA1A19C),
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        TabBar(
          controller: tabController,
          indicatorColor: Color(0xFF5599E9),
          labelColor: Color(0xFF5599E9),
          splashFactory: NoSplash.splashFactory,
          unselectedLabelColor: Color(0xFF313131),
          tabs: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Data User",
                style: TextStyle(
                  fontFamily: 'Nunito-Medium',
                ),
              ),
            ),
          ],
        ),
        Container(
          child: Column(
            children: <Widget>[
              ListTile(
                title: Text(
                  'Name',
                  style: TextStyle(
                    color: Color(0xFF777777),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  'USER',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF313131),
                  ),
                ),
              ),
              Divider(
                color: Color(0xFF999999),
                thickness: 2.0,
                indent: 15.0,
                endIndent: 15.0,
              ),
              ListTile(
                title: Text(
                  'Tanggal Lahir',
                  style: TextStyle(
                    color: Color(0xFF777777),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  'XX-XX-XXXX',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF313131),
                  ),
                ),
              ),
              Divider(
                color: Color(0xFF999999),
                thickness: 2.0,
                indent: 15.0,
                endIndent: 15.0,
              ),
              ListTile(
                title: Text(
                  'No. Telp',
                  style: TextStyle(
                    color: Color(0xFF777777),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  'XXXX-XXXX-XXXX',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF313131),
                  ),
                ),
              ),
              Divider(
                color: Color(0xFF999999),
                thickness: 2.0,
                indent: 15.0,
                endIndent: 15.0,
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget alreadyLogin() {
    return ListView(
      // shrinkWrap: true,
      children: <Widget>[
        Container(
          height: 250,
          decoration: BoxDecoration(
              color: Color(
            0xFFF1F1EF,
          )),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  CircleAvatar(
                    backgroundColor: Color(0xFFD9D9D9),
                    minRadius: 45.0,
                    child: CircleAvatar(
                      radius: 40.0,
                      backgroundImage: AssetImage('assets/imgs/user.png'),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                '${globals.loggedinName.toUpperCase()}',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF313131),
                ),
              ),
              Text(
                '${globals.loggedinEmail}',
                style: TextStyle(
                  color: Color(0xFFA1A19C),
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        if (globals.verificationStatus == "0") ...[
          TabBar(
            controller: tabController,
            indicatorColor: Color(0xFF5599E9),
            labelColor: Color(0xFF5599E9),
            splashFactory: NoSplash.splashFactory,
            unselectedLabelColor: Color(0xFF313131),
            tabs: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Data User",
                  style: TextStyle(
                    fontFamily: 'Nunito-Medium',
                  ),
                ),
              ),
            ],
            onTap: (int index) {
              setState(() {
                selectedIndex = index;
                tabController.animateTo(index);
              });
            },
          ),
          IndexedStack(
            children: <Widget>[
              Visibility(
                child: dataUser(),
                maintainState: true,
                visible: selectedIndex == 0,
              ),
            ],
            index: selectedIndex,
          ),
        ] else ...[
          TabBar(
            controller: tabController,
            indicatorColor: Color(0xFF5599E9),
            labelColor: Color(0xFF5599E9),
            splashFactory: NoSplash.splashFactory,
            unselectedLabelColor: Color(0xFF313131),
            tabs: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Data User",
                  style: TextStyle(
                    fontFamily: 'Nunito-Medium',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Data Identitas",
                  style: TextStyle(
                    fontFamily: 'Nunito-Medium',
                  ),
                ),
              ),
            ],
            onTap: (int index) {
              setState(() {
                selectedIndex = index;
                tabController.animateTo(index);
              });
            },
          ),
          IndexedStack(
            children: <Widget>[
              Visibility(
                child: dataUser(),
                maintainState: true,
                visible: selectedIndex == 0,
              ),
              Visibility(
                child: dataIdentitas(),
                maintainState: true,
                visible: selectedIndex == 1,
              ),
            ],
            index: selectedIndex,
          ),
        ],
      ],
    );
  }

  Widget dataUser() {
    return Container(
      child: Column(
        children: <Widget>[
          ListTile(
            title: Text(
              'Name',
              style: TextStyle(
                color: Color(0xFF777777),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              '${globals.loggedinName.toUpperCase()}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF313131),
              ),
            ),
          ),
          Divider(
            color: Color(0xFF999999),
            thickness: 2.0,
            indent: 15.0,
            endIndent: 15.0,
          ),
          ListTile(
            title: Text(
              'Tanggal Lahir',
              style: TextStyle(
                color: Color(0xFF777777),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              globals.tglLahir == null
                  ? "1 Januari 1990"
                  : DateFormat("dd-MM-yyyy")
                      .format(DateFormat("yyyy-MM-dd").parse(globals.tglLahir)),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF313131),
              ),
            ),
          ),
          Divider(
            color: Color(0xFF999999),
            thickness: 2.0,
            indent: 15.0,
            endIndent: 15.0,
          ),
          ListTile(
            title: Text(
              'No. Telp',
              style: TextStyle(
                color: Color(0xFF777777),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              '${globals.loggedinTelp}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF313131),
              ),
            ),
          ),
          Divider(
            color: Color(0xFF999999),
            thickness: 2.0,
            indent: 15.0,
            endIndent: 15.0,
          ),
          SizedBox(
            height: 15.0,
          ),
          if (globals.verificationStatus == "0") ...[
            Padding(
              padding: const EdgeInsets.only(
                  left: 25.0, top: 0.0, bottom: 0.0, right: 25.0),
              child: ElevatedButton.icon(
                label: Text(
                  'Verifikasi Akun',
                  style: TextStyle(
                      color: Colors.white, fontFamily: 'Nunito-Medium'),
                ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.all(8.0),
                  minimumSize: const Size.fromHeight(30),
                  backgroundColor: Color(0xFF5599E9),
                  splashFactory: NoSplash.splashFactory,
                  elevation: 0,
                ),
                icon: Icon(
                  Icons.security,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/homeverifikasi');
                },
              ),
            ),
          ] else if (globals.verificationStatus == "12") ...[
            Padding(
              padding: const EdgeInsets.only(
                  left: 25.0, top: 0.0, bottom: 0.0, right: 25.0),
              child: ElevatedButton.icon(
                label: Text(
                  'Data sedang diproses',
                  style: TextStyle(
                      color: Colors.white, fontFamily: 'Nunito-Medium'),
                ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.all(8.0),
                  minimumSize: const Size.fromHeight(30),
                  backgroundColor: Color.fromARGB(255, 245, 165, 36),
                  splashFactory: NoSplash.splashFactory,
                  elevation: 0,
                ),
                icon: Icon(
                  Icons.security,
                  color: Colors.white,
                ),
                onPressed: () {},
              ),
            ),
          ] else if (globals.verificationStatus == "13") ...[
            Padding(
              padding: const EdgeInsets.only(
                  left: 25.0, top: 0.0, bottom: 0.0, right: 25.0),
              child: ElevatedButton.icon(
                label: Text(
                  'Akun terverifikasi',
                  style: TextStyle(
                      color: Colors.white, fontFamily: 'Nunito-Medium'),
                ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.all(8.0),
                  backgroundColor: Color(0xFF409658),
                  minimumSize: const Size.fromHeight(30),
                  splashFactory: NoSplash.splashFactory,
                  elevation: 0,
                ),
                icon: Icon(
                  Icons.check_circle,
                  color: Colors.white,
                ),
                onPressed: () {},
              ),
            ),
          ] else if (globals.verificationStatus == "14") ...[
            Padding(
              padding: const EdgeInsets.only(
                  left: 25.0, top: 0.0, bottom: 0.0, right: 25.0),
              child: ElevatedButton.icon(
                label: Text(
                  'Data akun ditolak',
                  style: TextStyle(
                      color: Colors.white, fontFamily: 'Nunito-Medium'),
                ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.all(8.0),
                  backgroundColor: Color.fromARGB(255, 221, 0, 0),
                  minimumSize: const Size.fromHeight(30),
                  splashFactory: NoSplash.splashFactory,
                  elevation: 0,
                ),
                icon: Icon(
                  Icons.cancel,
                  color: Colors.white,
                ),
                onPressed: () {
                  return showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text(
                            'Data Verifikasi Anda Ditolak',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          content: SingleChildScrollView(
                              child: ListBody(
                            children: <Widget>[
                              Text(
                                "Data anda ditolak karena tidak memenuhi syarat, silahkan lakukan verifikasi data sekali lagi. \n\nKeterangan : ${globals.keteranganverifikasi.toLowerCase()}",
                              ),
                            ],
                          )),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context, 'OK');
                              },
                              child: const Text('OK'),
                            ),
                            TextButton(
                                onPressed: () async {
                                  Navigator.pop(context, 'Verifikasi Ulang');
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => DataVerifikasi(
                                                npwpPath:
                                                    widget.selectednpwpPath,
                                                ktpPath: widget.selectedktpPath,
                                                user_id: widget.selecteduserid,
                                                nik: widget.selectednik,
                                                nama: widget.selectednama,
                                                alamatdetail:
                                                    widget.selectedalamatdetail,
                                                tglLahir:
                                                    widget.selectedtglLahir,
                                                npwp: widget.selectednpwp,
                                                isEdit: true,
                                              )));
                                },
                                child: const Text('Verifikasi Ulang')),
                          ],
                        );
                      });
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget dataIdentitas() {
    return ListView(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 25.0, right: 25.0, top: 10.0),
          child: Image.file(
            globals.ktpPath,
            fit: BoxFit.contain,
            width: 170,
            height: 170,
          ),
        ),
        ListTile(
          title: Text(
            'nik',
            style: TextStyle(
              color: Color(0xFF777777),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            '${globals.nik}',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF313131),
            ),
          ),
        ),
        Divider(
          color: Color(0xFF999999),
          thickness: 2.0,
          indent: 15.0,
          endIndent: 15.0,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 25.0, right: 25.0, top: 10.0),
          child: Image.file(
            globals.npwpPath,
            fit: BoxFit.contain,
            width: 170,
            height: 170,
          ),
        ),
        ListTile(
          title: Text(
            'npwp',
            style: TextStyle(
              color: Color(0xFF777777),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            '${globals.npwp}',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF313131),
            ),
          ),
        ),
        Divider(
          color: Color(0xFF999999),
          thickness: 2.0,
          indent: 15.0,
          endIndent: 15.0,
        ),
      ],
    );
  }
}

class Settings extends StatefulWidget {
  final File selectednpwpPath;
  final File selectedktpPath;
  final String selectednik;
  final String selectedalamatdetail;
  final String selectednama;
  final String selectedtglLahir;
  final String selectednpwp;
  final int selecteduserid;

  const Settings({
    Key key,
    this.selectednpwpPath,
    this.selectedktpPath,
    this.selectednik,
    this.selectedalamatdetail,
    this.selectednama,
    this.selectedtglLahir,
    this.selectednpwp,
    this.selecteduserid,
  }) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  var size, height, width;
  final _controller01 = ValueNotifier<bool>(false);

  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    height = size.height;
    width = size.width;
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: Container(
        height: height,
        width: width,
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                "Pengaturan",
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Nunito-ExtraBold',
                ),
              ),
            ),
            // ListTile(
            //   title: Text(
            //     'Mode Gelap',
            //     style: TextStyle(
            //       color: Color(0xFF313131),
            //       fontSize: 20,
            //       fontFamily: 'Nunito-Medium',
            //     ),
            //   ),
            //   trailing: AdvancedSwitch(
            //     controller: _controller01,
            //   ),
            // ),
            ListTile(
                title: Text(
                  'Hubungi Kami',
                  style: TextStyle(
                    color: Color(0xFF313131),
                    fontSize: 20,
                    fontFamily: 'Nunito-Medium',
                  ),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  color: Color(0xFF313131),
                ),
                onTap: () {
                  Navigator.pushNamed(context, '/chats');
                }),
            ListTile(
              title: Text(
                'Syarat dan Ketentuan',
                style: TextStyle(
                  color: Color(0xFF313131),
                  fontSize: 20,
                  fontFamily: 'Nunito-Medium',
                ),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                color: Color(0xFF313131),
              ),
              onTap: () {
                Navigator.pushNamed(context, '/syaratdanketentuan');
              },
            ),
            ListTile(
              title: Text(
                'Bantuan',
                style: TextStyle(
                  color: Color(0xFF313131),
                  fontSize: 20,
                  fontFamily: 'Nunito-Medium',
                ),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                color: Color(0xFF313131),
              ),
              onTap: () {
                Navigator.pushNamed(context, '/faq');
              },
            ),
            ListTile(
              title: Text(
                'Favorit',
                style: TextStyle(
                  color: Color(0xFF313131),
                  fontSize: 20,
                  fontFamily: 'Nunito-Medium',
                ),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                color: Color(0xFF313131),
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => FavoritesList(param: 'List')));
                // Navigator.pushNamed(
                //   context,
                //   '/favoritesList',
                //   arguments: FavoritesList(param: 'List'),
                // );
              },
            ),
            SizedBox(height: 20.0),
            if (globals.loggedIn == true) ...[
              ListTile(
                onTap: () {
                  alert();
                },
                title: Text(
                  'Logout',
                  style: TextStyle(
                    color: Color(0xFFE95555),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Nunito-Medium',
                  ),
                ),
                leading: Icon(
                  Icons.logout_outlined,
                  color: Color(0xFFE95555),
                ),
              ),
            ] else ...[
              InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '/login');
                },
                child: ListTile(
                  title: Text(
                    'Login',
                    style: TextStyle(
                      color: Color(0xFF5599E9),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Nunito-Medium',
                    ),
                  ),
                  leading: Icon(
                    Icons.login_outlined,
                    color: Color(0xFF5599E9),
                  ),
                ),
              ),
            ],
          ],
        ),
        // child: alreadyLogin(),
      ),
    );
  }

  Widget alert() {
    Dialogs.bottomMaterialDialog(
        msg: 'Apakah anda yakin? kamu tidak mengembalikan tindakan ini',
        title: 'Logout',
        context: context,
        actions: [
          IconsOutlineButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            text: 'Cancel',
            iconData: Icons.cancel_outlined,
            textStyle: TextStyle(color: Colors.grey),
            iconColor: Colors.grey,
          ),
          IconsButton(
            onPressed: () async {
              await _auth.signOut();
              globals.prefs.remove('user');
              globals.pusher.disconnect();
              Navigator.of(context).pushNamedAndRemoveUntil(
                  '/onboarding', (Route<dynamic> route) => false);
            },
            text: 'Logout',
            iconData: Icons.logout,
            color: Colors.red,
            textStyle: TextStyle(color: Colors.white),
            iconColor: Colors.white,
          ),
        ]);
  }
}

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
        color: Color(0xFF313131).withOpacity(0.04),
      ),
    );
  }
}

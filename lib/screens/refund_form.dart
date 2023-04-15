import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:material_dialogs/material_dialogs.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:now_ui_flutter/api/s&k/pdf_sk_refund_api.dart';
import 'package:now_ui_flutter/constants/Theme.dart';
import 'package:now_ui_flutter/globals.dart' as globals;
import 'package:now_ui_flutter/models/dart_models.dart';
import 'package:now_ui_flutter/screens/home.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
import 'package:http/http.dart' as http;

class RefundForm extends StatefulWidget {
  final String nobukti;
  final String harga;
  const RefundForm({Key key, this.nobukti, this.harga}) : super(key: key);

  @override
  State<RefundForm> createState() => _RefundFormState();
}

class _RefundFormState extends State<RefundForm> {
  SimpleFontelicoProgressDialog _dialog;
  @override
  int isSyarat = 0;
  bool _isSyarat = false;
  bool _isButtonDisabled = true;

  TextEditingController namarekeningcontroller = new TextEditingController();
  TextEditingController norekeningcontroller = new TextEditingController();
  TextEditingController cbgrekeningcontroller = new TextEditingController();
  String bankrekeningcontroller;

  Future<List<dynamic>> createPdfSyaratKetentuan() async {
    final response = await http.get(
        Uri.parse(
            'http://web.transporindo.com/api-orderemkl/public/api/syaratdanketentuanrefund/getdatasyaratdanketentuanrefund'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${globals.accessToken}',
        });

    final result = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return result['data'];
    } else {
      _dialog.hide();
      await globals.alertBerhasilPesan(
          context,
          "Mohon cek kembali koneksi internet WiFi/Data anda",
          'Tidak ada koneksi',
          'assets/imgs/no-internet.json');
    }
  }

  void refund(String namarekening, String norekening, String bankrekening,
      String cbgrekening, int userinput, int isSyarat) async {
    _showDialog(context, SimpleFontelicoProgressDialogType.normal, 'Normal');
    List<dynamic> sk_refund = await createPdfSyaratKetentuan();
    try {
      final syaratketentuan = sk_refund.asMap().entries.map((val) {
        int idx = val.key;
        return sk_refund[idx]['syaratketentuan'];
      }).toList();
      final syarat = SyaratKetentuanRefund(
        nama: globals.loggedinName,
        nobukti: widget.nobukti,
        notelp: '085233534605',
        tanggal: DateFormat('dd MMMM yyyy').format(DateTime.now()),
        syaratketentuan: syaratketentuan,
      );
      final pdfFile = await PdfSKRefundApi.generate(syarat);
      String buktiPdf = pdfFile.path.split('/').last;
      var data = FormData.fromMap({
        'namarekening': namarekening,
        'norekening': norekening,
        'bankrekening': bankrekening,
        'cbgrekening': cbgrekening,
        'nominaltransaksi': widget.harga,
        'nobukti': widget.nobukti,
        'userinput': userinput,
        'ischeck': isSyarat,
        "buktipdfrefund": await MultipartFile.fromFile(
          pdfFile.path,
          filename: buktiPdf,
        ),
      });
      Dio dio = new Dio();
      dio.options.headers['Accept'] = 'application/json';
      dio.options.headers['Content-Type'] = 'application/json';
      dio.options.headers['Authorization'] = 'Bearer ${globals.accessToken}';
      try {
        var response = await dio
            .post('${globals.url}/api-orderemkl/public/api/refund', data: data);
        _dialog.hide();
        Dialogs.materialDialog(
            color: Colors.white,
            msg:
                "Data berhasil di refund, silahkan ditunggu sampai pihak admin memproses pengembalian dana anda",
            title: 'Refund Berhasil',
            lottieBuilder: Lottie.asset(
              'assets/imgs/refund-animation.json',
              fit: BoxFit.contain,
            ),
            context: context,
            actions: [
              IconsButton(
                onPressed: () async {
                  await Navigator.pop(context, 'Ok');
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: ((context) => Home())),
                      (route) => false);
                },
                text: 'Ok',
                iconData: Icons.done,
                color: Colors.blue,
                textStyle: TextStyle(color: Colors.white),
                iconColor: Colors.white,
              ),
            ]);
      } on DioError catch (e) {
        if (e.response.statusCode == 500) {
          print(e.response.data);
          print(e.response.headers);
          print(e.response.requestOptions);
        }
      } on SocketException catch (e) {
        _dialog.hide();
        globals.alertBerhasilPesan(
            context,
            "Mohon cek kembali koneksi internet WiFi/Data anda",
            'Tidak ada koneksi',
            'assets/imgs/no-internet.json');
      }
    } on SocketException catch (_) {
      globals.alertBerhasilPesan(
          context,
          "Mohon cek kembali koneksi internet WiFi/Data anda",
          'Tidak ada koneksi',
          'assets/imgs/no-internet.json');
    }
  }

  @override
  void initState() {
    super.initState();
  }

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
          "Refund",
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
          SizedBox(height: 20.0),
          Container(
            width: MediaQuery.of(context).size.width,
            // height: MediaQuery.of(context).size.height,
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.5),
                  child: Text(
                    "Isi Data Rekening",
                    style:
                        TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      top: 15.0, left: 15.0, right: 15.0, bottom: 15.0),
                  child: TextFormField(
                      controller: namarekeningcontroller,
                      decoration: InputDecoration(
                        labelText: "Nama Rekening",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(
                          Icons.person,
                          color: Color(0xFF5599E9),
                        ),
                      ),
                      onChanged: (val) {
                        if (val.isNotEmpty &&
                            bankrekeningcontroller != null &&
                            norekeningcontroller.text.isNotEmpty &&
                            cbgrekeningcontroller.text.isNotEmpty &&
                            isSyarat != 0) {
                          setState(() {
                            _isButtonDisabled = false;
                          });
                        } else {
                          _isButtonDisabled = true;
                        }
                      }),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      top: 15.0, left: 15.0, right: 15.0, bottom: 15.0),
                  child: TextFormField(
                      keyboardType: TextInputType.number,
                      controller: norekeningcontroller,
                      decoration: InputDecoration(
                        labelText: "No Rekening",
                        border: OutlineInputBorder(),
                        prefixIcon:
                            Icon(Icons.credit_card, color: Color(0xFF5599E9)),
                      ),
                      onChanged: (val) {
                        if (val.isNotEmpty &&
                            namarekeningcontroller.text.isNotEmpty &&
                            bankrekeningcontroller != null &&
                            cbgrekeningcontroller.text.isNotEmpty &&
                            isSyarat != 0) {
                          setState(() {
                            _isButtonDisabled = false;
                          });
                        } else {
                          _isButtonDisabled = true;
                        }
                      }),
                ),
                Padding(
                  padding: const EdgeInsets.all(13.0),
                  child: SizedBox(
                    height: 50,
                    child: DropdownSearch<ListBank>(
                      showAsSuffixIcons: true,
                      mode: Mode.BOTTOM_SHEET,
                      // items: _datacontainer,
                      dropdownSearchDecoration: InputDecoration(
                        labelText: "Bank Rekening",
                        contentPadding: EdgeInsets.fromLTRB(12, 12, 0, 0),
                        prefixIcon: Icon(
                          Icons.backpack_outlined,
                          color: Color(0xFF5599E9),
                        ),
                        border: OutlineInputBorder(),
                      ),
                      onFind: (String filter) async {
                        final url =
                            '${globals.url}/api-orderemkl/public/api/pesanan/getListBank';
                        var response = await Dio().get(
                          url,
                          queryParameters: {"filter": filter},
                          options: Options(
                            headers: {
                              'Accept': 'application/json',
                              'Content-type': 'application/json',
                              'Authorization': 'Bearer ${globals.accessToken}',
                            },
                          ),
                        );
                        var models =
                            ListBank.fromJsonList(response.data['data']);
                        return models;
                      },
                      onChanged: (data) {
                        bankrekeningcontroller = data.kodebank;
                        if (bankrekeningcontroller != null &&
                            namarekeningcontroller.text.isNotEmpty &&
                            norekeningcontroller.text.isNotEmpty &&
                            cbgrekeningcontroller.text.isNotEmpty &&
                            isSyarat != 0) {
                          setState(() {
                            _isButtonDisabled = false;
                          });
                        } else {
                          _isButtonDisabled = true;
                        }
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
                Padding(
                  padding: const EdgeInsets.only(
                      top: 15.0, left: 15.0, right: 15.0, bottom: 15.0),
                  child: TextFormField(
                      controller: cbgrekeningcontroller,
                      decoration: InputDecoration(
                        labelText: "Cabang Rekening",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(
                          Icons.my_library_books_outlined,
                          color: Color(0xFF5599E9),
                        ),
                      ),
                      onChanged: (val) {
                        if (val.isNotEmpty &&
                            namarekeningcontroller.text.isNotEmpty &&
                            norekeningcontroller.text.isNotEmpty &&
                            bankrekeningcontroller != null &&
                            isSyarat != 0) {
                          setState(() {
                            _isButtonDisabled = false;
                          });
                        } else {
                          _isButtonDisabled = true;
                        }
                      }),
                ),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 35.0),
                      child: Checkbox(
                        value: _isSyarat,
                        onChanged: (bool value) {
                          setState(() {
                            _isSyarat = value;
                            if (value == false) {
                              setState(() {
                                isSyarat = 0;
                              });
                            } else {
                              setState(() {
                                isSyarat = 1;
                              });
                            }
                          });
                          if (bankrekeningcontroller != null &&
                              namarekeningcontroller.text.isNotEmpty &&
                              norekeningcontroller.text.isNotEmpty &&
                              cbgrekeningcontroller.text.isNotEmpty &&
                              isSyarat != 0) {
                            setState(() {
                              _isButtonDisabled = false;
                            });
                          } else {
                            _isButtonDisabled = true;
                          }
                        },
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 10.0, bottom: 15.0, right: 8.0, left: 8.0),
                        child: RichText(
                          text: TextSpan(
                            // Note: Styles for TextSpans must be explicitly defined.
                            // Child text spans will inherit styles from parent
                            style: const TextStyle(
                              fontSize: 14.0,
                              color: Colors.black,
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                  text:
                                      'Dengan menyetujui pengajuan refund sesuai dengan data informasi rekening yang benar, anda setuju untuk '),
                              TextSpan(
                                  text: '',
                                  style: const TextStyle(
                                      color: Color(0xFF5599E9),
                                      decoration: TextDecoration.underline),
                                  children: [
                                    new TextSpan(
                                      text:
                                          'Syarat dan Ketentuan dan Pernyataan Privasi ',
                                      recognizer: new TapGestureRecognizer()
                                        ..onTap = () => alert(),
                                    )
                                  ]),
                              TextSpan(text: 'kami.'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF5599E9),
                    ),
                    onPressed: _isButtonDisabled
                        ? null
                        : () {
                            return showDialog<void>(
                              context: context,
                              barrierDismissible:
                                  false, // user must tap button!
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Apakah Kamu Yakin?'),
                                  content: SingleChildScrollView(
                                    child: ListBody(
                                      children: const <Widget>[
                                        Text(
                                            'Apakah anda yakin ingin melakukan proses refund?'),
                                        // Text('Would you like to approve of this message?'),
                                      ],
                                    ),
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop('Cancel');
                                      },
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      child: const Text('OK'),
                                      onPressed: () async {
                                        await Navigator.of(context).pop('OK');
                                        refund(
                                            namarekeningcontroller.text,
                                            norekeningcontroller.text,
                                            bankrekeningcontroller,
                                            cbgrekeningcontroller.text,
                                            globals.loggedinId,
                                            isSyarat);
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50.0),
                      ),
                      constraints:
                          BoxConstraints(maxHeight: 40.0, maxWidth: 300.0),
                      alignment: Alignment.center,
                      child: Text(
                        'AJUKAN REFUND',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget alert() {
    showModalBottomSheet(
        // isScrollControlled: true,
        context: context,
        builder: (context) {
          return FractionallySizedBox(
            heightFactor: 0.9,
            child: Scaffold(
              appBar: PreferredSize(
                preferredSize: Size.fromHeight(100.0),
                child: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  automaticallyImplyLeading: false,
                  titleSpacing: 15.0,
                  title: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Syarat dan Ketentuan",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 25.0,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          "Last Updated 12 Juli 2022",
                          style: TextStyle(
                            fontSize: 15.0,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  bottom: PreferredSize(
                    preferredSize: Size.fromHeight(0.0),
                    child: Divider(
                      color: Color.fromARGB(255, 145, 145, 145),
                      indent: 0,
                      endIndent: 0,
                      height: 10.0,
                    ),
                  ),
                ),
              ),
              body: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Adapun pengajuan refund berlaku atas kondisi sebagai berikut:",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                      "1. REFUND TIDAK BISA DIAJUKAN JIKA STATUS TELAH TURUN DEPO"),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                      "2. NILAI YANG DI REFUND AKAN DISESUAIKAN DENGAN BIAYA YANG DIKELUARKAN"),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                      "3. PENGAJUAN REFUND BISA DILAKUKAN JIKA UANG YANG DIBAYARKAN TELAH DITERIMA OLEH PIHAK TRANSPORINDO"),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
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
  }
}

import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:material_dialogs/material_dialogs.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:now_ui_flutter/constants/Theme.dart';
import 'package:now_ui_flutter/constants/constant.dart';
import 'package:image_picker/image_picker.dart' as picker;
import 'package:now_ui_flutter/providers/scanner_provider.dart';
import 'package:now_ui_flutter/screens/VerificationData/camera_verifikasi.dart';
import 'package:now_ui_flutter/screens/VerificationData/waiting_verifikasi.dart';
import 'package:now_ui_flutter/services/UserService.dart';
import 'package:now_ui_flutter/widgets/transition.dart';
import 'package:now_ui_flutter/widgets/uppercase.dart';
import 'package:provider/provider.dart';
import 'package:now_ui_flutter/globals.dart' as globals;
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:photo_view/photo_view.dart';

class DataVerifikasi extends StatefulWidget {
  final File npwpPath;
  final File ktpPath;
  final String nik;
  final String nama;
  final String alamatdetail;
  final String tglLahir;
  final String npwp;
  final int user_id;
  final bool isEdit;
  const DataVerifikasi(
      {Key key,
      this.npwpPath,
      this.ktpPath,
      this.isEdit,
      this.nik,
      this.nama,
      this.alamatdetail,
      this.tglLahir,
      this.npwp,
      this.user_id})
      : super(key: key);

  @override
  State<DataVerifikasi> createState() => _DataVerifikasiState();
}

class _DataVerifikasiState extends State<DataVerifikasi> {
  @override
  //Data npwp
  File imageFile_npwp;
  File npwpPath;
  bool npwp = false;
  TextEditingController _selectednpwp = new TextEditingController();
  FocusNode _focusednpwp = new FocusNode();

  //Data Ktp
  File imageFile_ktp;
  File ktpPath;
  bool ktp = false;
  TextEditingController _selectednik = new TextEditingController();
  FocusNode _focusednik = new FocusNode();
  TextEditingController _selectedtgllahir = new TextEditingController();
  FocusNode _focusedtgllahir = new FocusNode();
  TextEditingController _selectedalamat = new TextEditingController();
  FocusNode _focusedalamat = new FocusNode();
  TextEditingController _selectednama = new TextEditingController();
  FocusNode _focusednama = new FocusNode();
  DateTime tgllahir = DateFormat("dd-MM-yyyy").parse("01-01-2004");

  SimpleFontelicoProgressDialog _dialog;
  bool _isButtonDisabled;

  void initState() {
    // TODO: implement initState
    super.initState();
    _isButtonDisabled = true;
    if (widget.isEdit == true) {
      setState(() {
        _selectednik.text = widget.nik;
        _selectednama.text = widget.nama;
        _selectedalamat.text = widget.alamatdetail;
        _selectedtgllahir.text = DateFormat("dd-MM-yyyy")
            .format(DateFormat("yyyy-MM-dd").parse(widget.tglLahir));
        _selectednpwp.text = widget.npwp;
      });
    }
    setState(() {
      imageFile_npwp = File(widget.npwpPath.path);
      imageFile_ktp = widget.ktpPath;
    });
  }

  void scanImage(XFile imageKtp) async {
    try {
      final scannerProv = await ScannerProvider.instance(context);
      if (imageKtp != null) {
        await scannerProv.scan(imageKtp);
        setState(() {
          imageFile_ktp = scannerProv.image;
          ktp = true;
        });
        await Future.delayed(Duration(seconds: 5), () async {
          if (scannerProv.nik == null) {
            print("null");
            return false;
          } else {
            if (scannerProv.nik.isEmpty) {
              setState(() {
                ktp = true;
              });
              print("isempty");
              if (_selectednik.text.isNotEmpty &&
                  _selectednpwp.text.isNotEmpty &&
                  imageFile_ktp != null &&
                  imageFile_npwp != null) {
                setState(() {
                  _isButtonDisabled = false;
                });
              } else {
                _isButtonDisabled = true;
              }
              return false;
            } else {
              print("masuk");
              if (_selectednik.text.isNotEmpty &&
                  _selectednpwp.text.isNotEmpty &&
                  imageFile_ktp != null &&
                  imageFile_npwp != null) {
                setState(() {
                  _isButtonDisabled = false;
                });
              } else {
                _isButtonDisabled = true;
              }
              setState(() {
                ktp = true;
              });
              _selectednik.text = scannerProv.nik[0].nik;
              _selectedalamat.text =
                  "${scannerProv.nik[0].subdistrict}, ${scannerProv.nik[0].city}, ${scannerProv.nik[0].province}";
              _selectedtgllahir.text = DateFormat("dd-MM-yyyy").format(
                  DateFormat("yyyy-MM-dd").parse(scannerProv.nik[0].bornDate));
              tgllahir = DateFormat("dd-MM-yyyy").parse(DateFormat("dd-MM-yyyy")
                  .format(DateFormat("yyyy-MM-dd")
                      .parse(scannerProv.nik[0].bornDate)));
            }
          }
        });
      }
    } on SocketException catch (_) {
      Dialogs.materialDialog(
          color: Colors.white,
          msg: "Mohon cek kembali koneksi internet WiFi/Data anda",
          title: 'Tidak ada koneksi',
          lottieBuilder: Lottie.asset(
            'assets/imgs/no-internet.json',
            fit: BoxFit.contain,
          ),
          context: context,
          actions: [
            IconsButton(
              onPressed: () async {
                Navigator.of(context).pop();
              },
              text: 'Coba Lagi',
              iconData: Icons.done,
              color: Colors.blue,
              textStyle: TextStyle(color: Colors.white),
              iconColor: Colors.white,
            ),
          ]);
    }
  }

  Future getImage(context, File imagenpwp) async {
    if (imagenpwp != null) {
      setState(() {
        imageFile_npwp = File(imagenpwp.path);
        npwp = true;
      });
      if (_selectednik.text.isNotEmpty &&
          _selectednpwp.text.isNotEmpty &&
          imageFile_ktp != null &&
          imageFile_npwp != null) {
        setState(() {
          _isButtonDisabled = false;
        });
      }
    }
  }

  _uploadFile(File ktp, File npwp, String nik, String name, String alamat,
      String tgllahir, String no_npwp) async {
    _showDialog(context, SimpleFontelicoProgressDialogType.normal, 'Normal');
    String ktpPath = ktp.path.split('/').last;
    String npwpPath = npwp.path.split('/').last;
    var data = FormData.fromMap({
      "foto_ktp": await MultipartFile.fromFile(
        ktp.path,
        filename: ktpPath,
      ),
      "foto_npwp": await MultipartFile.fromFile(
        npwp.path,
        filename: npwpPath,
      ),
      "nik": nik,
      "name": name,
      "alamatdetail": alamat,
      "tgl_lahir": DateFormat("dd-MM-yyyy").parse(tgllahir),
      "no_npwp": no_npwp,
      "user_id": globals.loggedinId,
    });
    Dio dio = new Dio();

    try {
      var response = await dio.post(
        "https://web.transporindo.com/api-orderemkl/public/api/user/upload_gambar",
        data: data,
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Content-type': 'application/json',
            'Authorization': 'Bearer ${globals.accessToken}',
          },
        ),
      );
      globals.prefs
          .setString('user', jsonEncode(response.data['statusverifikasi']));
      setState(() {
        globals.verificationStatus =
            response.data['statusverifikasi']['statusverifikasi'].toString();
      });
      await editVerifikasi();
      await _dialog.hide();
      // authUser(context, globals.loggedinEmail, password, _dialog, fcmToken)
      Navigator.of(context)
          .pushReplacement(EnterExitRoute(enterPage: WaitingVerifikasi()));
    } on DioError catch (e) {
      if (e.response.statusCode == 500) {
        await _dialog.hide();
        globals.alertBerhasilPesan(context, "Mohon untuk dicoba kembali lagi",
            'Internal Server Error', 'assets/imgs/no-internet.json');
        print(e.response.data);
        print(e.response.headers);
        print(e.response.requestOptions);
      } else if (e.response.statusCode == 442) {
        await _dialog.hide();
        globals.alertBerhasilPesan(
            context,
            "Tidak bisa memasukkan nik yang sudah terdaftar",
            'nik sudah ada',
            'assets/imgs/user-denied.json');
      } else {
        await _dialog.hide();
        print('not connected');
        globals.alertBerhasilPesan(
            context,
            "Mohon cek kembali koneksi internet WiFi/Data anda",
            'Tidak ada koneksi',
            'assets/imgs/no-internet.json');
      }
    } on SocketException catch (_) {
      await _dialog.hide();
      print('not connected');
      globals.alertBerhasilPesan(
          context,
          "Mohon cek kembali koneksi internet WiFi/Data anda",
          'Tidak ada koneksi',
          'assets/imgs/no-internet.json');
    }
  }

  @override
  void dispose() {
    super.dispose();
    _focusednpwp.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFF1F1EF),
        elevation: 0,
        centerTitle: true,
        leading: new IconButton(
          icon: new Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      backgroundColor: Color(0xFFF1F1EF),
      body: Container(
        alignment: Alignment.topCenter,
        child: ListView(
          children: [
            Column(
              children: [
                SizedBox(height: 15.0),
                Text("Pengisian Data Diri",
                    style: TextStyle(
                        fontFamily: 'Nunito-ExtraBold', fontSize: 18.0)),
                Padding(
                  padding: EdgeInsets.all(3.0),
                  child: Text(
                    'Isi data diri dari nik, Nama, Alamat sesuai dengan \n KTP, Tgl Lahir, serta no. npwp, dan mohon di cek \n kembali sebelum menekan tombol submit.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF9F9F9F)),
                  ),
                ),
                SizedBox(height: 15.0),
                Container(
                  padding: EdgeInsets.only(top: 12.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 3.0, bottom: 8.0, left: 17.0, right: 17.0),
                        child: SizedBox(
                          height: 36.0,
                          child: TextField(
                            style: TextStyle(
                              fontSize: 13.0,
                            ),
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(16),
                            ],
                            keyboardType: TextInputType.number,
                            controller: _selectednik,
                            focusNode: _focusednik,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.only(left: 15.0),
                              border: OutlineInputBorder(),
                              hintText: 'nik',
                              hintStyle: TextStyle(
                                fontSize: 13.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 3.0, bottom: 8.0, left: 17.0, right: 17.0),
                        child: SizedBox(
                          height: 36.0,
                          child: TextField(
                            style: TextStyle(
                              fontSize: 13.0,
                            ),
                            inputFormatters: [
                              UpperCaseTextFormatter(),
                            ],
                            controller: _selectednama,
                            focusNode: _focusednama,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.only(left: 15.0),
                              border: OutlineInputBorder(),
                              hintText: 'Nama',
                              hintStyle: TextStyle(
                                fontSize: 13.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 3.0, bottom: 8.0, left: 17.0, right: 17.0),
                        child: SizedBox(
                          height: 36.0,
                          child: TextField(
                            style: TextStyle(
                              fontSize: 13.0,
                            ),
                            inputFormatters: [
                              UpperCaseTextFormatter(),
                            ],
                            textCapitalization: TextCapitalization.sentences,
                            controller: _selectedalamat,
                            focusNode: _focusedalamat,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.only(left: 15.0),
                              border: OutlineInputBorder(),
                              hintText: 'Alamat Detail (Sesuai KTP)',
                              hintStyle: TextStyle(
                                fontSize: 13.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 3.0, bottom: 8.0, left: 17.0, right: 17.0),
                        child: SizedBox(
                          height: 36.0,
                          child: TextField(
                            keyboardType: TextInputType.number,
                            controller: _selectedtgllahir,
                            focusNode: _focusedtgllahir,
                            readOnly: true,
                            textCapitalization: TextCapitalization.sentences,
                            style: TextStyle(
                              fontSize: 13.0,
                            ),
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.only(left: 15.0),
                              border: OutlineInputBorder(),
                              hintText: 'Tgl Lahir',
                              hintStyle: TextStyle(
                                fontSize: 13.0,
                              ),
                            ),
                            onTap: () async {
                              DateTime pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: widget.isEdit == true
                                      ? new DateFormat("dd-MM-yyyy").parse(
                                          DateFormat("dd-MM-yyyy").format(
                                              DateFormat("yyyy-MM-dd")
                                                  .parse(widget.tglLahir)))
                                      : tgllahir,
                                  firstDate: DateTime(
                                      1942), //DateTime.now() - not to allow to choose before today.
                                  lastDate: DateTime(2005));

                              if (pickedDate != null) {
                                String formattedDate =
                                    DateFormat('dd-MM-yyyy').format(pickedDate);
                                setState(() {
                                  _selectedtgllahir.text = formattedDate;
                                });
                              } else {
                                print("Date is not selected");
                              }
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 3.0, bottom: 8.0, left: 17.0, right: 17.0),
                        child: SizedBox(
                          height: 36.0,
                          child: TextFormField(
                            controller: _selectednpwp,
                            focusNode: _focusednpwp,
                            inputFormatters: [
                              MaskTextInputFormatter(
                                mask: "##.###.###.#-###.###",
                                type: MaskAutoCompletionType.lazy,
                              )
                            ],
                            autocorrect: false,
                            keyboardType: TextInputType.number,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            style: TextStyle(
                              fontSize: 13.0,
                            ),
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.only(left: 15.0),
                              border: OutlineInputBorder(),
                              hintText: 'npwp',
                              hintStyle: TextStyle(
                                fontSize: 13.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 3.0, bottom: 8.0, left: 17.0, right: 17.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10.0),
                                  child: GestureDetector(
                                    onTap: () => Navigator.of(context)
                                        .push(MaterialPageRoute(
                                            builder: ((context) => PhotoViews(
                                                  imageFile: imageFile_ktp,
                                                  name: 'ktp',
                                                )))),
                                    child: Container(
                                      child: CustomPaint(
                                        child: Hero(
                                          tag: 'image1',
                                          child: Image.file(
                                            imageFile_ktp,
                                            fit: BoxFit.contain,
                                            width: 158,
                                            height: 100,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                if (widget.isEdit == true) ...[
                                  TextButton(
                                    onPressed: () async {
                                      var image_ktp =
                                          await Navigator.push<XFile>(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      CameraVerifikasi(
                                                        param: 'ktp',
                                                        title:
                                                            'Posisikan foto KTP anda sesuai dengan garis pembantu yang ada di kamera.',
                                                      )));
                                      scanImage(image_ktp);
                                    },
                                    child: Text("Edit Foto KTP"),
                                  ),
                                ],
                              ],
                            ),
                            Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10.0),
                                  child: GestureDetector(
                                    onTap: () => Navigator.of(context)
                                        .push(MaterialPageRoute(
                                            builder: ((context) => PhotoViews(
                                                  imageFile: imageFile_npwp,
                                                  name: 'npwp',
                                                )))),
                                    child: Container(
                                      child: CustomPaint(
                                        child: Hero(
                                          tag: 'image2',
                                          child: Image.file(
                                            imageFile_npwp,
                                            fit: BoxFit.contain,
                                            width: 158,
                                            height: 100,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                if (widget.isEdit == true) ...[
                                  TextButton(
                                    onPressed: () async {
                                      var image_npwp = await Navigator.push<
                                              File>(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  CameraVerifikasi(
                                                      param: 'npwp',
                                                      title:
                                                          'Posisikan foto npwp anda sesuai dengan garis pembantu yang ada di kamera.')));
                                      getImage(context, image_npwp);
                                    },
                                    child: Text("Edit Foto npwp"),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          width: 300,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF5599E9),
              textStyle: TextStyle(
                color: Colors.white,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.0),
              ),
            ),
            onPressed: () async {
              if (_selectednpwp.text.isEmpty) {
                await globals.alertReqButtons(
                  context,
                  'npwp Tidak boleh kosong',
                  [
                    DialogButton(
                      child: Text(
                        "OK",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      onPressed: () async {
                        await Navigator.pop(context);
                        _focusednpwp.requestFocus();
                      },
                      width: 120,
                    )
                  ],
                );
              } else if (_selectednpwp.text.length < 20) {
                await globals.alertReqButtons(
                  context,
                  'npwp harus 20 angka',
                  [
                    DialogButton(
                      child: Text(
                        "OK",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      onPressed: () async {
                        await Navigator.pop(context);
                        _focusednpwp.requestFocus();
                      },
                      width: 120,
                    )
                  ],
                );
              } else if (_selectednik.text.isEmpty) {
                await globals.alertReqButtons(
                  context,
                  'nik Tidak boleh kosong',
                  [
                    DialogButton(
                      child: Text(
                        "OK",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      onPressed: () async {
                        await Navigator.pop(context);
                        _focusednik.requestFocus();
                      },
                      width: 120,
                    )
                  ],
                );
              } else if (_selectednik.text.length < 16) {
                await globals.alertReqButtons(
                  context,
                  'nik harus 16 angka',
                  [
                    DialogButton(
                      child: Text(
                        "OK",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      onPressed: () async {
                        await Navigator.pop(context);
                        _focusednik.requestFocus();
                      },
                      width: 120,
                    )
                  ],
                );
              } else if (_selectednama.text.isEmpty) {
                await globals.alertReqButtons(
                  context,
                  'Nama tidak boleh kosong',
                  [
                    DialogButton(
                      child: Text(
                        "OK",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      onPressed: () async {
                        await Navigator.pop(context);
                        _focusednama.requestFocus();
                      },
                      width: 120,
                    )
                  ],
                );
              } else if (_selectedalamat.text.isEmpty) {
                await globals.alertReqButtons(
                  context,
                  'Alamat tidak boleh kosong',
                  [
                    DialogButton(
                      child: Text(
                        "OK",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      onPressed: () async {
                        await Navigator.pop(context);
                        _focusedalamat.requestFocus();
                      },
                      width: 120,
                    )
                  ],
                );
              } else if (_selectedtgllahir.text.isEmpty) {
                await globals.alertReqButtons(
                  context,
                  'Tgl Lahir tidak boleh kosong',
                  [
                    DialogButton(
                      child: Text(
                        "OK",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      onPressed: () async {
                        await Navigator.pop(context);
                        _focusedtgllahir.requestFocus();
                      },
                      width: 120,
                    )
                  ],
                );
              } else {
                showDialog<String>(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    title: const Text(
                      'Apakah Kamu Yakin?',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    content: const Text(
                      'Apakah anda yakin?, karena data yang dikirim akan langsung dicek pihak Transporindo',
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.pop(context, 'Cancel'),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          await Navigator.pop(context, 'Ok');
                          _uploadFile(
                            imageFile_ktp,
                            imageFile_npwp,
                            _selectednik.text,
                            _selectednama.text,
                            _selectedalamat.text,
                            _selectedtgllahir.text,
                            _selectednpwp.text,
                          );
                        },
                        child: const Text(
                          'OK',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
            child: Padding(
                padding: EdgeInsets.only(
                    left: 16.0, right: 16.0, top: 12, bottom: 12),
                child: Text("Submit",
                    style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Nunito-Medium'))),
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

class PhotoViews extends StatelessWidget {
  final File imageFile;
  final String name;
  const PhotoViews({Key key, this.imageFile, this.name}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (name == 'ktp') {
      return Container(
        child: Hero(
          tag: 'image1',
          child: PhotoView(
            imageProvider: FileImage(imageFile),
            maxScale: 10.0,
            minScale: 0.68,
          ),
        ),
      );
    } else if (name == 'npwp') {
      return Container(
        child: Hero(
          tag: 'image2',
          child: PhotoView(
            imageProvider: FileImage(imageFile),
            maxScale: 10.0,
            minScale: 0.68,
          ),
        ),
      );
    }
  }
}

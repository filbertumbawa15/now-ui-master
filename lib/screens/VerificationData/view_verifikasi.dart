import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:now_ui_flutter/constants/constant.dart';
import 'package:now_ui_flutter/providers/scanner_provider.dart';
import 'package:now_ui_flutter/widgets/uppercase.dart';
import 'package:provider/provider.dart';
import 'package:now_ui_flutter/globals.dart' as globals;
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:photo_view/photo_view.dart';

class ViewVerifikasi extends StatefulWidget {
  final File npwpPath;
  final File ktpPath;
  final String nik;
  final String nama;
  final String alamatdetail;
  final String tglLahir;
  final String npwp;
  final int user_id;
  final bool isEdit;
  const ViewVerifikasi(
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
  State<ViewVerifikasi> createState() => _ViewVerifikasiState();
}

class _ViewVerifikasiState extends State<ViewVerifikasi> {
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
  TextEditingController _selectedtgllahir = new TextEditingController();
  TextEditingController _selectedalamat = new TextEditingController();
  TextEditingController _selectednama = new TextEditingController();
  DateTime tgllahir = DateFormat("dd-MM-yyyy").parse("01-01-2004");

  SimpleFontelicoProgressDialog _dialog;
  bool _isButtonDisabled;

  void initState() {
    // TODO: implement initState
    super.initState();
    _isButtonDisabled = true;
    if (widget.isEdit == true) {
      setState(() {
        imageFile_npwp = File(widget.npwpPath.path);
        imageFile_ktp = widget.ktpPath;
        _selectednik.text = widget.nik;
        _selectednama.text = widget.nama;
        _selectedalamat.text = widget.alamatdetail;
        _selectedtgllahir.text = DateFormat("dd-MM-yyyy")
            .format(DateFormat("yyyy-MM-dd").parse(widget.tglLahir));
        _selectednpwp.text = widget.npwp;
        ktp = true;
        npwp = true;
        _isButtonDisabled = false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // ignore: missing_return
      onWillPop: () {
        if (_selectednpwp.text.isNotEmpty ||
            _selectednik.text.isNotEmpty ||
            _selectednama.text.isNotEmpty ||
            _selectedalamat.text.isNotEmpty ||
            _selectedtgllahir.text.isNotEmpty ||
            imageFile_ktp != null ||
            imageFile_npwp != null) {
          showDialog<String>(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: const Text('Apakah Kamu Yakin?'),
              content: const Text(
                  'Data Yang diisi tidak bisa dikembalikan kembali.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context, 'Cancel'),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    await Navigator.pop(context, 'Ok');
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        } else {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(60.0), // here the desired height
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: Column(
              children: <Widget>[
                SizedBox(height: 8.0),
                Image.asset(
                  'assets/imgs/taslogo.png',
                  height: 50.0,
                  width: 50.0,
                ),
              ],
            ),
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
        ),
        body: SingleChildScrollView(
          child: Container(
            child: Column(
              children: <Widget>[
                // SingleChildScrollView(
                //   scrollDirection: Axis.horizontal,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    ktpresultwidget(),
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 5.0, left: 8.0, right: 8.0, bottom: 0.0),
                          child: Column(
                            children: [
                              imageFile_npwp == null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(15.0),
                                      child: Container(
                                        width: deviceHeight(context) / 2,
                                        height: deviceHeight(context) * 0.35,
                                        color:
                                            Color.fromARGB(255, 218, 218, 218),
                                        child: GestureDetector(
                                          child: Container(
                                            alignment: Alignment.center,
                                            height: deviceHeight(context) / 2,
                                            // padding: const EdgeInsets.all(13),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: <Widget>[
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom: 8.0),
                                                  child: CircleAvatar(
                                                    radius: 21,
                                                    backgroundColor:
                                                        Color.fromARGB(
                                                            255, 172, 172, 172),
                                                    child: CircleAvatar(
                                                      backgroundColor:
                                                          Color.fromARGB(255,
                                                              218, 218, 218),
                                                      child: Icon(
                                                        Icons.add,
                                                        color: Color.fromARGB(
                                                            255, 172, 172, 172),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    "Silahkan Masukkan Foto npwp anda",
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(15.0),
                                      child: GestureDetector(
                                        onTap: () => Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: ((context) =>
                                                    PhotoViews(
                                                      imageFile: imageFile_npwp,
                                                      name: 'npwp',
                                                    )))),
                                        child: Container(
                                            color: Colors.black,
                                            child: CustomPaint(
                                              child: Hero(
                                                tag: 'image2',
                                                child: Image.file(
                                                  imageFile_npwp,
                                                  fit: BoxFit.contain,
                                                ),
                                              ),
                                            )
                                            // : Image.file(
                                            //     scannerProv.image,
                                            //     fit: BoxFit.contain,
                                            //   ),
                                            ),
                                      ),
                                    ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.only(
                        top: 15.0, left: 15.0, right: 15.0, bottom: 15.0),
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 15.0, bottom: 15.0, left: 2.0, right: 2.0),
                          child: SizedBox(
                            height: 50,
                            child: TextField(
                              decoration: InputDecoration(
                                labelText: 'nik',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(16),
                              ],
                              controller: _selectednik,
                              textCapitalization: TextCapitalization.sentences,
                              enabled: false,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 15.0, bottom: 15.0, left: 2.0, right: 2.0),
                          child: SizedBox(
                            height: 50,
                            child: TextField(
                              decoration: InputDecoration(
                                labelText: 'Nama',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.text,
                              controller: _selectednama,
                              textCapitalization: TextCapitalization.sentences,
                              inputFormatters: [
                                UpperCaseTextFormatter(),
                              ],
                              enabled: false,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 15.0, bottom: 15.0, left: 2.0, right: 2.0),
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Alamat Detail',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 5,
                            keyboardType: TextInputType.multiline,
                            controller: _selectedalamat,
                            textCapitalization: TextCapitalization.sentences,
                            inputFormatters: [
                              UpperCaseTextFormatter(),
                            ],
                            enabled: false,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 15.0, bottom: 15.0, left: 2.0, right: 2.0),
                          child: SizedBox(
                            height: 50,
                            child: TextField(
                              decoration: InputDecoration(
                                labelText: 'Tgl Lahir',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              controller: _selectedtgllahir,
                              readOnly: true,
                              textCapitalization: TextCapitalization.sentences,
                              enabled: false,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 15.0, bottom: 15.0, left: 2.0, right: 2.0),
                          child: SizedBox(
                            height: 50,
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
                              enabled: false,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              // ignore: missing_return
                              decoration: InputDecoration(
                                labelText: "npwp",
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget ktpresultwidget() {
    return Consumer<ScannerProvider>(
      builder: (context, scannerProv, _) {
        return Padding(
          padding: const EdgeInsets.only(
              top: 5.0, left: 8.0, right: 8.0, bottom: 0.0),
          child: Column(
            children: [
              imageFile_ktp != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(15.0),
                      child: GestureDetector(
                        onTap: () =>
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: ((context) => PhotoViews(
                                      imageFile: imageFile_ktp,
                                      name: 'ktp',
                                    )))),
                        child: Container(
                          color: Colors.black,
                          child: CustomPaint(
                            child: Hero(
                              tag: 'image1',
                              child: Image.file(
                                File(imageFile_ktp.path),
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(15.0),
                      child: Container(
                        width: deviceHeight(context) / 2,
                        height: deviceHeight(context) * 0.35,
                        color: Color.fromARGB(255, 218, 218, 218),
                        child: GestureDetector(
                          child: Container(
                            alignment: Alignment.center,
                            height: deviceHeight(context) / 2,
                            // padding: const EdgeInsets.all(13),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: CircleAvatar(
                                    radius: 21,
                                    backgroundColor:
                                        Color.fromARGB(255, 172, 172, 172),
                                    child: CircleAvatar(
                                      backgroundColor:
                                          Color.fromARGB(255, 218, 218, 218),
                                      child: Icon(
                                        Icons.add,
                                        color:
                                            Color.fromARGB(255, 172, 172, 172),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    "Silahkan Masukkan Foto KTP anda",
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
            ],
          ),
        );
      },
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
          ),
        ),
      );
    } else if (name == 'npwp') {
      return Container(
        child: Hero(
          tag: 'image2',
          child: PhotoView(
            imageProvider: FileImage(imageFile),
          ),
        ),
      );
    }
  }
}

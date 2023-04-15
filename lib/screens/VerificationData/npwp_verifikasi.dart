import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:lottie/lottie.dart';
import 'package:now_ui_flutter/screens/VerificationData/camera_verifikasi.dart';
import 'package:now_ui_flutter/screens/VerificationData/data_verifikasi.dart';
import 'package:photo_view/photo_view.dart';

class npwpVerifikasi extends StatefulWidget {
  final File ktpPath;
  const npwpVerifikasi({
    Key key,
    this.ktpPath,
  }) : super(key: key);

  @override
  State<npwpVerifikasi> createState() => _npwpVerifikasiState();
}

class _npwpVerifikasiState extends State<npwpVerifikasi> {
  File imageFile_npwp;
  File npwpPath;
  bool npwp = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(widget.ktpPath);
  }

  Future getImage(context, File imagenpwp) async {
    if (imagenpwp != null) {
      setState(() {
        imageFile_npwp = File(imagenpwp.path);
        npwp = true;
      });
    }
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
        child: Column(
          children: <Widget>[
            SizedBox(height: 15.0),
            Text("Scan Foto npwp",
                style:
                    TextStyle(fontFamily: 'Nunito-ExtraBold', fontSize: 18.0)),
            Padding(
              padding: EdgeInsets.all(3.0),
              child: Text(
                'Taruh foto npwp anda dan sesuaikan nantinya \n dengan garis pembantu yang telah disediakan di \n kamera.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF9F9F9F)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(35.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(15.0)),
                  color: Colors.white,
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                  child: imageFile_npwp == null
                      ? Lottie.asset('assets/imgs/idcard-scan.json')
                      : Padding(
                          padding: const EdgeInsets.all(35.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15.0),
                            child: GestureDetector(
                              onTap: () =>
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: ((context) => PhotoViews(
                                            imageFile: imageFile_npwp,
                                            name: 'npwp',
                                          )))),
                              child: Container(
                                color: Colors.black,
                                child: CustomPaint(
                                  child: Hero(
                                    tag: 'image1',
                                    child: Image.file(
                                      File(imageFile_npwp.path),
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: imageFile_npwp == null
          ? Padding(
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
                    var image_npwp = await Navigator.push<File>(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CameraVerifikasi(
                                param: 'npwp',
                                title:
                                    'Posisikan foto npwp anda sesuai dengan garis pembantu yang ada di kamera.')));
                    getImage(context, image_npwp);
                  },
                  child: Padding(
                      padding: EdgeInsets.only(
                          left: 16.0, right: 16.0, top: 12, bottom: 12),
                      child: Text("Lakukan Scan",
                          style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Nunito-Medium'))),
                ),
              ),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                  child: new Container(
                    width: MediaQuery.of(context).size.width,
                    child: ElevatedButton(
                      onPressed: () async {
                        var image_npwp = await Navigator.push<File>(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CameraVerifikasi(
                                    param: 'npwp',
                                    title:
                                        'Posisikan foto npwp anda sesuai dengan garis pembantu yang ada di kamera.')));
                        getImage(context, image_npwp);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF5599E9),
                      ),
                      child: Text(
                        "Ambil Ulang",
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Nunito-Medium',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                  child: new Container(
                    width: MediaQuery.of(context).size.width,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DataVerifikasi(
                                      ktpPath: widget.ktpPath,
                                      npwpPath: imageFile_npwp,
                                    )));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF5599E9),
                      ),
                      child: Text(
                        "Lanjutkan ke Pengisian Diri",
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Nunito-Medium',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
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

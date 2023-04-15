import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewer extends StatefulWidget {
  final File pdfUrl;
  const PdfViewer({Key key, this.pdfUrl}) : super(key: key);

  @override
  State<PdfViewer> createState() => _PdfViewerState();
}

class _PdfViewerState extends State<PdfViewer> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final name = basename(widget.pdfUrl.path);
    return SafeArea(
      child: Scaffold(
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
            name,
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
        body: Container(
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 184, 184, 184),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SfPdfViewer.file(File(widget.pdfUrl.path)),
          ),
        ),
      ),
    );
  }
}

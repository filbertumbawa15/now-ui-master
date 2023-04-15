import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:now_ui_flutter/constants/constant.dart';
import 'package:nik_validator/nik_validator.dart';
import 'package:provider/provider.dart';

class ScannerProvider extends ChangeNotifier {
  File _image;
  File get image => _image;

  Size _imageSize;
  Size get imageSize => _imageSize;

  List<TextElement> _textElements;
  List<TextElement> get textElements => _textElements;

  TextDetector _textDetector;

  List<NIKModel> _nik;
  List<NIKModel> get nik => _nik;

  bool _onSearch = false;
  bool get onSearch => _onSearch;

  static ScannerProvider instance(BuildContext context) =>
      Provider.of(context, listen: false);

  void scan(XFile _xImage) async {
    if (_xImage != null) {
      _image = File(_xImage.path);
      recognizeImage();
    }
  }

  Future<List<NIKModel>> recognizeImage() async {
    setOnSearch(true);

    _textDetector = GoogleMlKit.vision.textDetector();
    _getImageSize(_image);

    /// Creating an InputImage object using the image path
    final inputImage = InputImage.fromFilePath(_image.path);

    /// Retrieving the RecognisedText from the InputImage
    final text = await _textDetector.processImage(inputImage);

    RegExp regEx = RegExp(nikPattern);
    _nik = [];
    _textElements = [];

    /// Finding matching value with nik pattern and store to list
    for (TextBlock block in text.blocks) {
      for (TextLine line in block.lines) {
        String _text = line.text.trim().replaceAll(" ", "");
        if (regEx.hasMatch(_text)) {
          /// Parsing raw text and find nik Informations
          var _result = await parse(regEx.stringMatch(_text));
          if (_result != null) {
            _nik.add(_result);
          }

          for (TextElement element in line.elements) {
            _textElements.add(element);
          }
        }
      }
    }
    setOnSearch(false);
  }

  Future<NIKModel> parse(String text) async {
    NIKModel result = await NIKValidator.instance.parse(nik: text);
    if (result.valid == true) {
      return result;
    }
    return null;
  }

  void _getImageSize(File imageFile) async {
    final completer = Completer<Size>();

    final Image image = Image.file(imageFile);
    image.image.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener((ImageInfo info, bool _) {
        completer.complete(Size(
          info.image.width.toDouble(),
          info.image.height.toDouble(),
        ));
      }),
    );

    final Size size = await completer.future;
    _imageSize = size;
    notifyListeners();
  }

  void disposing() {
    print(_textDetector);
    _textDetector.close();
    notifyListeners();
  }

  /// Set event search
  void setOnSearch(bool value) {
    _onSearch = value;
    notifyListeners();
  }
}

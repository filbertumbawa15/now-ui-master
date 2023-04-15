import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mask_for_camera_view/mask_for_camera_view.dart';
import 'package:mask_for_camera_view/mask_for_camera_view_border_type.dart';
import 'package:mask_for_camera_view/mask_for_camera_view_result.dart';
import 'package:now_ui_flutter/constants/Theme.dart';
import 'package:path_provider/path_provider.dart';

class CameraVerifikasi extends StatefulWidget {
  final String param;
  final String title;
  const CameraVerifikasi({Key key, this.param, this.title}) : super(key: key);

  @override
  State<CameraVerifikasi> createState() => _CameraVerifikasiState();
}

class _CameraVerifikasiState extends State<CameraVerifikasi> {
  void initState() {
    super.initState();
  }

  Future<XFile> initializeFileKtp(Uint8List imageBytes) async {
    Uint8List imageInUnit8List = imageBytes;
    Directory root = await getTemporaryDirectory();
    String directoryPath = '${root.path}';
    File file =
        await File('$directoryPath/${DateTime.now().millisecondsSinceEpoch}')
            .create();
    file.writeAsBytesSync(imageInUnit8List);
    print(file.path);
    return XFile(file.path);
  }

  Future<File> initializeFilenpwp(Uint8List imageBytes) async {
    Uint8List imageInUnit8List = imageBytes;
    Directory root = await getTemporaryDirectory();
    String directoryPath = '${root.path}';
    File file =
        await File('$directoryPath/${DateTime.now().millisecondsSinceEpoch}')
            .create();
    file.writeAsBytesSync(imageInUnit8List);
    print(file.path);
    return File(file.path);
  }

  // CameraController controller;
  // bool _cameraVisible;

  // SimpleFontelicoProgressDialog _dialog;

  // @override
  // void initState() {
  //   super.initState();
  //   _cameraVisible = true;
  // }

  // void _showDialog(BuildContext context, SimpleFontelicoProgressDialogType type,
  //     String text) async {
  //   if (_dialog == null) {
  //     _dialog = SimpleFontelicoProgressDialog(
  //         context: context, barrierDimisable: false);
  //   }
  //   if (type == SimpleFontelicoProgressDialogType.custom) {
  //     _dialog.show(
  //         message: text,
  //         type: type,
  //         width: 150.0,
  //         height: 75.0,
  //         loadingIndicator: Text(
  //           'C',
  //           style: TextStyle(fontSize: 24.0),
  //         ));
  //   } else {
  //     _dialog.show(
  //         message: text,
  //         type: type,
  //         horizontal: true,
  //         width: 150.0,
  //         height: 75.0,
  //         hideText: true,
  //         indicatorColor: Colors.blue);
  //   }
  // }

  // Future<File> takePicturenpwp() async {
  //   Directory root = await getTemporaryDirectory();
  //   String directoryPath = '${root.path}';
  //   await Directory(directoryPath).create(recursive: true);
  //   String filePath =
  //       '$directoryPath/${DateTime.now().millisecondsSinceEpoch}.jpg';
  //   print(directoryPath);

  //   try {
  //     await controller.takePicture();
  //   } catch (e) {
  //     return null;
  //   }
  //   ImageProperties properties =
  //       await FlutterNativeImage.getImageProperties(filePath);

  //   int width = properties.width;
  //   var offset = (properties.height - properties.width) / 2;
  //   File croppedFile = await FlutterNativeImage.cropImage(
  //       filePath, 10.round(), 150.round(), 450, 300);
  //   return File(croppedFile.path);
  // }

  // Future<XFile> takePictureKtp() async {
  //   Directory root = await getTemporaryDirectory();
  //   String directoryPath = '${root.path}';
  //   await Directory(directoryPath).create(recursive: true);
  //   String filePath =
  //       '$directoryPath/${DateTime.now().millisecondsSinceEpoch}.jpg';

  //   print(filePath);

  //   try {
  //     await controller.takePicture();
  //   } catch (e) {
  //     return null;
  //   }
  //   ImageProperties properties =
  //       await FlutterNativeImage.getImageProperties(filePath);

  //   var width = MediaQuery.of(context).size.width;
  //   double height = MediaQuery.of(context).size.width / 2;
  //   var cropSize = min(properties.width, properties.height);
  //   print(properties.width);
  //   print(properties.height);
  //   print("baca");
  //   print(cropSize);
  //   int offsetX =
  //       (properties.width - min(properties.width, properties.height)) ~/ 2;
  //   int offsetY =
  //       (properties.height - min(properties.width, properties.height)) ~/ 2;
  //   File croppedFile = await FlutterNativeImage.cropImage(
  //       filePath, offsetX, offsetY, height.round(), width.round());
  //   return XFile(croppedFile.path);
  // }

  @override
  Widget build(BuildContext context) {
    return MaskForCameraView(
      title: widget.title,
      visiblePopButton: false,
      boxBorderWidth: 4.0,
      boxBorderRadius: 20,
      boxWidth: MediaQuery.of(context).size.width / 1.15,
      boxHeight: MediaQuery.of(context).size.width / 2,
      appBarColor: NowUIColors.info,
      borderType: MaskForCameraViewBorderType.solid,
      onTake: (MaskForCameraViewResult res) async {
        if (widget.param == "ktp") {
          XFile gambar_ktp = await initializeFileKtp(res.croppedImage);
          Navigator.pop(context, gambar_ktp);
        } else if (widget.param == "npwp") {
          File gambar_npwp = await initializeFilenpwp(res.croppedImage);
          Navigator.pop(context, gambar_npwp);
        }
        // showModalBottomSheet(
        //   context: context,
        //   isScrollControlled: true,
        //   backgroundColor: Colors.transparent,
        //   builder: (context) => Container(
        //     padding:
        //         const EdgeInsets.symmetric(vertical: 12.0, horizontal: 14.0),
        //     decoration: const BoxDecoration(
        //       color: Colors.white,
        //       borderRadius: BorderRadius.only(
        //         topLeft: Radius.circular(26.0),
        //         topRight: Radius.circular(26.0),
        //       ),
        //     ),
        //     child: Column(
        //       mainAxisSize: MainAxisSize.min,
        //       children: [
        //         const Text(
        //           "Cropped Images",
        //           style: TextStyle(
        //             fontSize: 24.0,
        //             fontWeight: FontWeight.w600,
        //           ),
        //         ),
        //         const SizedBox(height: 12.0),
        //         res.croppedImage != null
        //             ? ClipRRect(
        //                 borderRadius: BorderRadius.circular(4.0),
        //                 child: SizedBox(
        //                   width: double.infinity,
        //                   child: Image.file(
        //                     gambar!,
        //                     fit: BoxFit.contain,
        //                   ),
        //                 ),
        //               )
        //             : Container(),
        //         const SizedBox(height: 8.0),
        //       ],
        //     ),
        //   ),
        // );
      },
    );
  }
}

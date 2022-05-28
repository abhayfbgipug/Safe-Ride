//importing neccessary files and packages
import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/foundation.dart';

//defining the utilities for the scanner
class ScannerUtils {
  static Future<CameraDescription> camGet(CameraLensDirection dir) async {
    return await availableCameras().then(
      (List<CameraDescription> cameras) => cameras.firstWhere(
        (CameraDescription camera) => camera.lensDirection == dir,
      ),
    );
  }

  //constructing an image from the bytes recieved
  //and concatenating the planes of the image
  //in different format to the required format
  static Future<dynamic> detect({
    @required CameraImage image,
    @required Future<dynamic> Function(FirebaseVisionImage image) detectInImage,
    @required int imageRotation,
  }) async {
    return detectInImage(
      FirebaseVisionImage.fromBytes(
        _planesConcatenated(image.planes),
        _buildMetaData(image, _rotateImage(imageRotation)),
      ),
    );
  }

  static Uint8List _planesConcatenated(List<Plane> planes) {
    final WriteBuffer allBytes = WriteBuffer();
    for (Plane plane in planes) {
      allBytes.putUint8List(plane.bytes);
    }
    return allBytes.done().buffer.asUint8List();
  }

  //image metadata used by FirebaseVision detector
  static FirebaseVisionImageMetadata _buildMetaData(
    CameraImage image,
    ImageRotation rotation,
  ) {
    return FirebaseVisionImageMetadata(
      rawFormat: image.format.raw,
      size: Size(image.width.toDouble(), image.height.toDouble()),
      rotation: rotation,
      planeData: image.planes.map(
        (Plane plane) {
          return FirebaseVisionImagePlaneMetadata(
            bytesPerRow: plane.bytesPerRow,
            height: plane.height,
            width: plane.width,
          );
        },
      ).toList(),
    );
  }

  //indicates the image rotation
  static ImageRotation _rotateImage(int rotation) {
    switch (rotation) {
      case 0:
        return ImageRotation.rotation0;
      case 90:
        return ImageRotation.rotation90;
      case 180:
        return ImageRotation.rotation180;
      default:
        assert(rotation == 270);
        return ImageRotation.rotation270;
    }
  }
}

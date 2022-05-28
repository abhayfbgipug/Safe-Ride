//importing neccessary files and packages
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:ringtone_player/ringtone_player.dart';
import 'package:alert/alert.dart';

final navigatorK = GlobalKey<NavigatorState>();
var count = 0; //Declaring variable

class EyeDetector extends CustomPainter {
  EyeDetector(this.absoluteImageSize, this.faces);
  //setting the deafult color of the rectangle to red
  int colorInt = 1;
  final Size absoluteImageSize;
  final List<Face> faces;
  List<Color> colors = [
    Colors.red,
    Colors.green,
  ];

  @override
  //paint the canvas
  void paint(Canvas canvas, Size size) {
    final double scalex = size.width / absoluteImageSize.width;
    final double scaley = size.height / absoluteImageSize.height;

    try {
      Face face = faces[0];
      // Calculating the average probability of eyes which are safe for driving
      double eyeOpenAvg =
          (face.leftEyeOpenProbability + face.rightEyeOpenProbability) / 2.0;
      print("Hi user");
      print("lefteye${face.leftEyeOpenProbability}");
      print("righteye${face.rightEyeOpenProbability}");

      print(eyeOpenAvg);
      if (eyeOpenAvg < 0.4) {
        //Condition below which alert will be activated
        print("Alert");

        count++;
        if (count > 2) {
          // To give alarm signal after specific intervals
          RingtonePlayer.ringtone();
          Alert(message: 'Warning').show();
        }
        colorInt = 0;
      } else {
        colorInt = 1;
        count = 0;
        RingtonePlayer.stop(); // To stop the sound as soon as eyes are opened
      }

      //painting the rectangle around the detected face
      canvas.drawRect(
          Rect.fromLTRB(
            face.boundingBox.left * scalex,
            face.boundingBox.top * scaley,
            face.boundingBox.right * scalex,
            face.boundingBox.bottom * scaley,
          ),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 4.0
            ..color = colors[colorInt]);
    } catch (e) {
      print("no Face Detected");
    }
  }

  @override
  //returns true if the new face detected a repaint is needed
  bool shouldRepaint(EyeDetector oldDelegate) {
    return oldDelegate.absoluteImageSize != absoluteImageSize ||
        oldDelegate.faces != faces;
  }
}

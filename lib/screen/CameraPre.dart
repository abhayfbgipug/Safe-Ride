//importing neccessary files and packages
import 'package:camera/camera.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:driverassistant/widgets/sidePanel.dart';
import 'package:driverassistant/utils/detectorPainters.dart';
import 'package:driverassistant/utils/scanner.dart';

class CamDirScan extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _CamDirScanState();
}

// Forming a class named CamDirScanState for
class _CamDirScanState extends State<CamDirScan> {
  //_scanResults is declared dynamic to take any value during running the program
  dynamic _scanResults;
  CameraController _camera;
  bool _isDetecting = false;
  //setting camera direction rear by default
  CameraLensDirection _direction = CameraLensDirection.back;

//  firebase vision to detect face in my apps
  final FaceDetector _faceDetector = FirebaseVision.instance.faceDetector(
      //configuring the face detector options
      FaceDetectorOptions(
          mode: FaceDetectorMode.accurate,
          enableLandmarks: true,
          enableClassification: true,
          enableContours: true));

  @override
  void initState() {
    super.initState();
    _initializeCam(); //initializing..
  }

  // intialiazing the camera
  void _initializeCam() async {
    final CameraDescription description = await ScannerUtils.camGet(_direction);
    setState(() {});
    _camera = CameraController(
      description,
      //setting the camera resolution according to the target device
      defaultTargetPlatform == TargetPlatform.android
          ? ResolutionPreset.veryHigh
          : ResolutionPreset.high,
    );
    await _camera.initialize().catchError((onError) => print(onError));

    _camera.startImageStream((CameraImage image) {
      if (_isDetecting) return;

      _isDetecting = true;
      //scanning the image and detecting the faces
      ScannerUtils.detect(
        image: image,
        detectInImage: _faceDetector.processImage,
        imageRotation: description.sensorOrientation,
      ).then(
        (dynamic results) {
          setState(() {
            _scanResults = results;
          });
        },
      ).whenComplete(() => _isDetecting = false);
    });
  }

  //_buildResults() returning the widget according to the result
  //if a face is detected during the scan then returns the scanned face
  //if no face detected then returns a Text widget indicating 'No Face detected !'
  Widget _buildResults() {
    Text noResultsText = Text(
      'No Face detected !',
      textAlign: TextAlign.center,
      style: TextStyle(color: Colors.blue, fontSize: 20),
    );
    //when no face detected
    if (_scanResults == null ||
        _camera == null ||
        !_camera.value.isInitialized) {
      return noResultsText;
    }

    CustomPainter painter;

    final Size imageSize = Size(
      _camera.value.previewSize.height,
      _camera.value.previewSize.width,
    );
    //if no list of faces detected then return the Text widget
    if (_scanResults is! List<Face>) return noResultsText;
    painter = EyeDetector(imageSize, _scanResults);

    return CustomPaint(
      painter: painter,
    );
  }

  //widget returning the image built
  //when none returned from CameraController then return
  //Text widget conatining text 'Initializing Camera...'
  Widget _imageBuilder() {
    return Container(
      constraints: BoxConstraints.expand(),
      color: Colors.white,
      child: _camera == null
          ? Center(
              child: Text(
                'Initializing Camera...',
                style: TextStyle(
                  color: Color.fromARGB(255, 6, 84, 227),
                  fontSize: 30.0,
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  //creates a preview widgetfor the given camera controller
                  CameraPreview(_camera),
                  _buildResults(),
                ],
              ),
            ),
    );
  }

  // function to change the camera direction
  // gives functionality to the floating action button on the main screen
  void _changeCamDir() async {
    if (_direction == CameraLensDirection.back) {
      _direction = CameraLensDirection.front;
    } else {
      _direction = CameraLensDirection.back;
    }

    await _camera.stopImageStream();
    await _camera.dispose();

    setState(() {
      _camera = null;
    });

    _initializeCam();
  }

  // building the elements of the main screen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Safe Ride',
        ),
      ),
      //sliding drawer
      drawer: SidePanel(),
      body: _imageBuilder(),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 25,
          ),
          FloatingActionButton(
            onPressed: _changeCamDir,
            child: _direction == CameraLensDirection.front
                ? Icon(Icons.camera_rear)
                : Icon(Icons.camera_front),
          ),
          Text(
            "  Have a safe ride",
            style: TextStyle(
                color: Color.fromARGB(255, 15, 189, 242),
                fontWeight: FontWeight.bold,
                fontSize: 20),
          ),
        ],
      ),
    );
  }

  //Disposing camera controller
  @override
  void dispose() {
    _camera.dispose().then((_) {
      _faceDetector.close();
    });

    super.dispose();
  }
}

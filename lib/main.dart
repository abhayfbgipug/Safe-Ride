import 'package:flutter/material.dart';
import 'package:driverassistant/screen/CameraPre.dart';

void main() {
  runApp(
    MaterialApp(
      home: CamDirScan(),
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
    ),
  );
}

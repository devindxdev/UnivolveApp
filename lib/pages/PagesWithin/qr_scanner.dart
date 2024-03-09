import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:univolve_app/pages/PagesWithin/view_profile.dart';

class QRScannerPage extends StatefulWidget {
  @override
  _QRScannerPageState createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  final qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  @override
  void reassemble() {
    super.reassemble();
    controller!.pauseCamera();
    // controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(alignment: Alignment.center, children: [
        QRView(
          key: qrKey,
          onQRViewCreated: _onQRViewCreated,
        ),
      ]),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      controller.pauseCamera(); // Pause camera after a successful scan

      if (scanData.code!.length == 9) {
        // Perform Firebase search and navigation
        final userDoc = await FirebaseFirestore.instance
            .collection('user')
            .doc(scanData.code)
            .get();
        if (userDoc.exists) {
          // Assuming ViewProfilePage() takes a user object as an argument
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => ViewProfilePage(user: userDoc.data())),
          );
        } else {
          _showError("User not found.");
        }
      } else {
        _showError("Invalid QR code.");
      }
    });
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Error"),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
              controller?.resumeCamera();
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}

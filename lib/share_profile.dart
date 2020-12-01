import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qrscan/qrscan.dart' as scanner;

class ShareProfile extends StatefulWidget {
  ShareProfile({Key key}) : super(key: key);

  @override
  _ShareProfileState createState() => _ShareProfileState();
}

class _ShareProfileState extends State<ShareProfile> {
  final _auth = FirebaseAuth.instance;
  FirebaseUser loggedInUser;
  String cameraScanResult, email = '';

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        setState(() {
          loggedInUser = user;
          email = loggedInUser.email;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          RaisedButton(
              child: Text('Scan a QR Code'),
              onPressed: () async {
                cameraScanResult = await scanner.scan();
                final profileData = await Firestore.instance
                    .collection('users')
                    .document(cameraScanResult)
                    .get();
                Firestore.instance
                    .collection("users")
                    .document(loggedInUser.email)
                    .collection("contacts")
                    .document()
                    .setData({
                  'hasProfile': true,
                  'email': cameraScanResult,
                  'name': profileData.data['name'],
                  'company': profileData.data['company'],
                  'card': profileData.data['card'],
                });
                setState(() {});
              }),
          SizedBox(
            height: 25.0,
          ),
          QrImage(
            data: email,
            version: QrVersions.auto,
            size: 200.0,
          ),
        ],
      ),
    );
  }
}

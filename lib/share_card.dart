import 'package:business_card_manager/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class ScanCard extends StatefulWidget {
  ScanCard({Key key}) : super(key: key);

  @override
  _ScanCardState createState() => _ScanCardState();
}

class _ScanCardState extends State<ScanCard> {
  String _uploadedFileURL;
  File _image;
  final _auth = FirebaseAuth.instance;
  FirebaseUser loggedInUser;
  String card = '', name = '', company = '';
  bool spinner = true;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        loggedInUser = user;
      }
      final profileData = await Firestore.instance
          .collection('users')
          .document(loggedInUser.email)
          .get();
      card = profileData.data['card'];
      setState(() {
        spinner = false;
      });
    } catch (e) {
      print(e);
    }
  }

  Future uploadFile() async {
    var uuid = new Uuid();
    StorageReference storageReference = FirebaseStorage.instance
        .ref()
        .child('${loggedInUser.email}/cards/${uuid.v1()}');
    StorageUploadTask uploadTask = storageReference.putFile(_image);
    await uploadTask.onComplete;
    await storageReference.getDownloadURL().then((fileURL) {
      setState(() {
        _uploadedFileURL = fileURL;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          RaisedButton(
              child: Text('Add a Business Card'),
              onPressed: () async {
                _image = await getImage(true);
                setState(() {
                  spinner = true;
                });
                await uploadFile();

                final userInfo = await getCardInfo(_image);
                final docRef = await Firestore.instance
                    .collection("users")
                    .document(loggedInUser.email)
                    .collection('contacts')
                    .add({
                  'name': userInfo['name'],
                  'company': userInfo['company'],
                  'card': _uploadedFileURL,
                  'hasProfile': false,
                });

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditCardPage(doc: docRef),
                  ),
                );

                setState(() {
                  spinner = false;
                });
              }),
          SizedBox(
            height: 25.0,
          ),
          ModalProgressHUD(
            inAsyncCall: spinner,
            child: QrImage(
              data: card,
              version: QrVersions.auto,
              size: 200.0,
            ),
          ),
        ],
      ),
    );
  }
}

class EditCardPage extends StatefulWidget {
  final doc;

  EditCardPage({Key key, this.doc}) : super(key: key);

  @override
  _EditCardPageState createState() => _EditCardPageState();
}

class _EditCardPageState extends State<EditCardPage> {
  final _auth = FirebaseAuth.instance;
  bool spinner = false;
  FirebaseUser loggedInUser;
  String name, company;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        loggedInUser = user;
      }
      final profileData = await widget.doc.get();
      name = profileData.data['name'];
      company = profileData.data['company'];
      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Verify Details',
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: ListView(
        children: <Widget>[
          ModalProgressHUD(
            inAsyncCall: spinner,
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  TextField(
                    textAlign: TextAlign.center,
                    controller: TextEditingController(text: name),
                    onChanged: (value) {
                      name = value;
                    },
                    decoration: const InputDecoration(
                      labelText: 'Name',
                    ),
                  ),
                  SizedBox(
                    height: 15.0,
                  ),
                  TextField(
                    textAlign: TextAlign.center,
                    controller: TextEditingController(text: company),
                    onChanged: (value) {
                      company = value;
                    },
                    decoration: const InputDecoration(
                      labelText: 'Company',
                    ),
                  ),
                  SizedBox(
                    height: 15.0,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Material(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.all(Radius.circular(30.0)),
                      elevation: 5.0,
                      child: MaterialButton(
                        onPressed: () async {
                          setState(() {
                            spinner = true;
                          });
                          widget.doc.updateData({
                            'name': name,
                            'company': company,
                          });
                          Navigator.pop(context);

                          setState(() {
                            spinner = false;
                          });
                        },
                        minWidth: 200.0,
                        height: 42.0,
                        child: Text(
                          'Save',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

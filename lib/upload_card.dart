import 'package:business_card_manager/edit_account.dart';
import 'package:business_card_manager/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'edit_account.dart';

class UploadCardPage extends StatefulWidget {
  @override
  _UploadCardPageState createState() => _UploadCardPageState();
}

class _UploadCardPageState extends State<UploadCardPage> {
  final _firestore = Firestore.instance;
  final _auth = FirebaseAuth.instance;
  File _image;
  bool spinner = false;
  FirebaseUser loggedInUser;
  String _uploadedFileURL = '';

  String name = '', company = '', phNum = '', website = '', comAddr = '';

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  Future uploadFile() async {
    StorageReference storageReference =
        FirebaseStorage.instance.ref().child('${loggedInUser.email}/usercard');
    StorageUploadTask uploadTask = storageReference.putFile(_image);
    await uploadTask.onComplete;
    await storageReference.getDownloadURL().then((fileURL) {
      setState(() {
        _uploadedFileURL = fileURL;
      });
    });
  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        loggedInUser = user;
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Upload Business Card',
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: spinner,
        child: ListView(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  RaisedButton(
                    child: Text('Upload Business Card'),
                    onPressed: () async {
                      _image = await getImage(false);
                      setState(() {
                        spinner = true;
                      });
                      await uploadFile();
                      setState(() {
                        spinner = false;
                      });
                    },
                  ),
                  RaisedButton(
                      child: Text('Take a Picture of your Business Card'),
                      onPressed: () async {
                        _image = await getImage(true);
                        setState(() {
                          spinner = true;
                        });
                        await uploadFile();
                        setState(() {
                          spinner = false;
                        });
                      }),
                  SizedBox(
                    height: 25.0,
                  ),
                  Center(
                    child: _image == null
                        ? Text('No image selected.')
                        : Image.file(_image),
                  ),
                  SizedBox(
                    height: 25.0,
                  ),
                  _image == null
                      ? SizedBox(
                          height: 0,
                        )
                      : Material(
                          color: Colors.blueAccent,
                          borderRadius: BorderRadius.all(Radius.circular(30.0)),
                          elevation: 5.0,
                          child: MaterialButton(
                            onPressed: () async {
                              setState(() {
                                spinner = true;
                              });

                              final userInfo = await getCardInfo(_image);
                              _firestore
                                  .collection("users")
                                  .document(loggedInUser.email)
                                  .setData({
                                'name': userInfo['name'],
                                'company': userInfo['company'],
                                'companyAddress': userInfo['comAddr'],
                                'phoneNumber': userInfo['phNum'],
                                'website': userInfo['website'],
                                'user': loggedInUser.email,
                                'card': _uploadedFileURL,
                                'bio': '',
                                'job': '',
                                'profilepic': '',
                              });

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditAccountPage(),
                                ),
                              );

                              setState(() {
                                spinner = false;
                              });
                            },
                            minWidth: 200.0,
                            height: 42.0,
                            child: Text(
                              'Continue',
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

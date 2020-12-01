import 'package:business_card_manager/home.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class EditAccountPage extends StatefulWidget {
  @override
  _EditAccountPageState createState() => _EditAccountPageState();
}

class _EditAccountPageState extends State<EditAccountPage> {
  final _firestore = Firestore.instance;
  final _auth = FirebaseAuth.instance;
  File _image;
  bool spinner = false;
  FirebaseUser loggedInUser;
  String _uploadedFileURL = '';
  String name, company, job, phNum, website, comAddr, bio, email, card;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  Future uploadFile() async {
    StorageReference storageReference = FirebaseStorage.instance
        .ref()
        .child('${loggedInUser.email}/profilepic');
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
      final profileData = await Firestore.instance
          .collection('users')
          .document(loggedInUser.email)
          .get();
      name = profileData.data['name'];
      company = profileData.data['company'];
      comAddr = profileData.data['companyAddress'];
      job = profileData.data['job'];
      phNum = profileData.data['phoneNumber'];
      website = profileData.data['website'];
      email = profileData.data['user'];
      card = profileData.data['card'];
      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  Future getImageCamera() async {
    var image =
        await ImagePicker.pickImage(source: ImageSource.camera, maxWidth: 1000);

    setState(() {
      _image = image;
    });
  }

  Future getImagePhone() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Account',
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
                      labelText: 'Enter where you work',
                    ),
                  ),
                  SizedBox(
                    height: 15.0,
                  ),
                  TextField(
                    textAlign: TextAlign.center,
                    controller: TextEditingController(text: job),
                    onChanged: (value) {
                      job = value;
                    },
                    decoration: const InputDecoration(
                      labelText: 'Job Title',
                    ),
                  ),
                  SizedBox(
                    height: 15.0,
                  ),
                  TextField(
                    textAlign: TextAlign.center,
                    controller: TextEditingController(text: phNum),
                    onChanged: (value) {
                      phNum = value;
                    },
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                    ),
                  ),
                  SizedBox(
                    height: 15.0,
                  ),
                  TextField(
                    textAlign: TextAlign.center,
                    controller: TextEditingController(text: website),
                    onChanged: (value) {
                      website = value;
                    },
                    decoration: const InputDecoration(
                      labelText: 'Website',
                    ),
                  ),
                  SizedBox(
                    height: 15.0,
                  ),
                  TextField(
                    textAlign: TextAlign.center,
                    controller: TextEditingController(text: comAddr),
                    onChanged: (value) {
                      comAddr = value;
                    },
                    decoration: const InputDecoration(
                      labelText: 'Address',
                    ),
                  ),
                  SizedBox(
                    height: 15.0,
                  ),
                  TextField(
                    textAlign: TextAlign.center,
                    onChanged: (value) {
                      bio = value;
                    },
                    decoration: const InputDecoration(
                      labelText: 'Bio',
                    ),
                  ),
                  RaisedButton(
                      child: Text('Upload Profile Picture'),
                      onPressed: () {
                        getImagePhone();
                        setState(() {});
                      }),
                  RaisedButton(
                      child: Text('Take a Profile Picture'),
                      onPressed: () {
                        getImageCamera();
                        setState(() {});
                      }),
                  Center(
                    child: _image == null
                        ? Text('No image selected.')
                        : CircleAvatar(
                            radius: 50,
                            backgroundImage: Image.file(_image).image,
                          ),
                  ),
                  SizedBox(
                    height: 24.0,
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
                          await uploadFile();

                          _firestore
                              .collection("users")
                              .document(loggedInUser.email)
                              .setData({
                            'name': name,
                            'bio': bio,
                            'job': job,
                            'company': company,
                            'companyAddress': comAddr,
                            'phoneNumber': phNum,
                            'website': website,
                            'user': loggedInUser.email,
                            'profilepic': _uploadedFileURL,
                            'card': card
                          });
                          email = loggedInUser.email;
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HomePage()),
                              (_) => false);

                          setState(() {
                            spinner = false;
                          });
                        },
                        minWidth: 200.0,
                        height: 42.0,
                        child: Text(
                          'Register',
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

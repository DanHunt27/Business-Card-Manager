import 'package:business_card_manager/profile.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Contacts extends StatefulWidget {
  Contacts({
    Key key,
  }) : super(key: key);

  @override
  _ContactsState createState() => _ContactsState();
}

class _ContactsState extends State<Contacts> {
  final _auth = FirebaseAuth.instance;
  FirebaseUser loggedInUser;
  String filter = '';
  var _firestore;
  int filterType = 0;
  String hintText = "Enter A Person's Name";

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void _filterTypeChange(int value) {
    setState(() {
      filterType = value;
      if (filterType == 0) {
        hintText = "Enter A Person's Name";
      } else {
        hintText = "Enter A Company Name";
      }
    });
  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        loggedInUser = user;
        setState(() {
          _firestore = Firestore.instance
              .collection('users')
              .document(loggedInUser.email)
              .collection('contacts')
              .snapshots();
        });
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        TextField(
          textAlign: TextAlign.center,
          onChanged: (value) {
            filter = value;
          },
          decoration: InputDecoration(
            hintText: hintText,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Radio(
              value: 0,
              groupValue: filterType,
              onChanged: _filterTypeChange,
            ),
            Text(
              'Name',
              style: TextStyle(fontSize: 16.0),
            ),
            Radio(
              value: 1,
              groupValue: filterType,
              onChanged: _filterTypeChange,
            ),
            Text(
              'Company',
              style: TextStyle(
                fontSize: 16.0,
              ),
            ),
          ],
        ),
        RaisedButton(
            child: Text('Filter'),
            onPressed: () {
              if (filter == '') {
                _firestore = Firestore.instance
                    .collection('users')
                    .document(loggedInUser.email)
                    .collection('contacts')
                    .snapshots();
              } else {
                if (filterType == 0)
                  _firestore = Firestore.instance
                      .collection('users')
                      .document(loggedInUser.email)
                      .collection('contacts')
                      .where('firstName', isEqualTo: filter)
                      .snapshots();
                else if (filterType == 1)
                  _firestore = Firestore.instance
                      .collection('users')
                      .document(loggedInUser.email)
                      .collection('contacts')
                      .where('company', isEqualTo: filter)
                      .snapshots();
              }
              setState(() {});
            }),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
              stream: _firestore,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Text("Loading..");
                }
                return ListView.separated(
                  itemCount: snapshot.data.documents.length,
                  separatorBuilder: (context, index) {
                    return Divider();
                  },
                  itemBuilder: (context, index) {
                    if (snapshot.data.documents[index]['hasProfile']) {
                      return Center(
                        child: GestureDetector(
                          child: Stack(children: <Widget>[
                            Container(
                                width: 350,
                                height: 200,
                                child: Image.network(
                                    snapshot.data.documents[index]['card'])),
                            Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Icon(Icons.person),
                            )
                          ]),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProfilePage(
                                      email: snapshot.data.documents[index]
                                          ['email'],
                                      appBar: AppBar(
                                        title: Text(snapshot
                                            .data.documents[index]['name']),
                                        centerTitle: true,
                                      )),
                                ));
                          },
                          onDoubleTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Image.network(snapshot
                                        .data.documents[index]['card'])));
                          },
                        ),
                      );
                    }
                    return GestureDetector(
                      child: Container(
                          width: 350,
                          height: 200,
                          child: Image.network(
                              snapshot.data.documents[index]['card'])),
                      onDoubleTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Image.network(
                                    snapshot.data.documents[index]['card'])));
                      },
                    );
                  },
                );
              }),
        ),
      ],
    );
  }
}

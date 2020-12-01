import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class ProfilePage extends StatefulWidget {
  final email;
  final AppBar appBar;

  ProfilePage({Key key, this.email, this.appBar}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String name = '',
      company = '',
      job = '',
      phNum = '',
      website = '',
      comAddr = '',
      bio = '',
      card = '',
      profilepic = '';
  bool spinner = false;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    try {
      setState(() {
        spinner = true;
      });
      final profileData = await Firestore.instance
          .collection('users')
          .document(widget.email)
          .get();
      name = profileData.data['name'];
      bio = profileData.data['bio'];
      company = profileData.data['company'];
      comAddr = profileData.data['companyAddress'];
      job = profileData.data['job'];
      phNum = profileData.data['phoneNumber'];
      website = profileData.data['website'];
      card = profileData.data['card'];
      profilepic = profileData.data['profilepic'];
      setState(() {
        spinner = false;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: spinner,
      child: Scaffold(
        appBar: widget.appBar,
        body: ListView(
          children: <Widget>[
            Center(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 30.0,
                      right: 30,
                      top: 15,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: NetworkImage(profilepic),
                        ),
                        Column(
                          children: <Widget>[
                            Text(
                              '$name',
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                            Text(widget.email),
                            Text(phNum),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  GestureDetector(
                    child: Container(
                      width: 350,
                      height: 200,
                      color: Colors.white,
                      child: Image.network(card),
                    ),
                    onDoubleTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Image.network(card)));
                    },
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      bio,
                    ),
                  ),
                  ListTile(
                    title: Text('Company:'),
                    trailing: Text(company),
                  ),
                  ListTile(
                    title: Text('Company Address:'),
                    trailing: Text(comAddr),
                  ),
                  ListTile(
                    title: Text('Job Title:'),
                    trailing: Text(job),
                  ),
                  ListTile(
                    title: Text('Website:'),
                    trailing: Text(website),
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

import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:messenger/components/rounded_button.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:messenger/components/user_info.dart';

TextEditingController controller;

String _profileImageUrl = '';
String _userName = '';
String _userStatus = '';
Firestore _firestore = Firestore.instance;
FirebaseUser loggedInUser;

class SettingsScreen extends StatefulWidget {
  static const String id = 'settings_screen';
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _auth = FirebaseAuth.instance;
  Future<void> getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        setState(() {
          loggedInUser = user;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  FirebaseStorage _storage = FirebaseStorage.instance;

  File _image;
  final picker = ImagePicker();

  final databaseReference = Firestore.instance;

  Future _changeImage(ImageSource source) async {
    final pickedFile = await picker.getImage(source: source);
    if (pickedFile != null) {
      File cropped = await ImageCropper.cropImage(
        compressFormat: ImageCompressFormat.jpg,
        sourcePath: pickedFile.path,
        aspectRatio: CropAspectRatio(
          ratioX: 1,
          ratioY: 1,
        ),
        compressQuality: 50,
        androidUiSettings: AndroidUiSettings(
          toolbarColor: Colors.indigo,
          toolbarWidgetColor: Colors.white,
          activeControlsWidgetColor: Colors.white,
        ),
      );

      setState(() {
        _image = cropped;
        _uploadImage(context);
      });
    }
  }

  void _uploadImage(context) async {
    final ProgressDialog pr = ProgressDialog(context, isDismissible: false);
    pr.style(
      message: 'Uploading',
      textAlign: TextAlign.start,
      borderRadius: 20.0,
      messageTextStyle: TextStyle(
        fontSize: 16.0,
      ),
      progressWidget: Container(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircularProgressIndicator(),
        ),
      ),
    );
    _image != null ? await pr.show() : await pr.hide();
    StorageReference _reference =
        _storage.ref().child('profile_images').child('${loggedInUser.uid}.jpg');
    StorageUploadTask task = _reference.putFile(_image);
    StorageTaskSnapshot taskSnapshot = await task.onComplete;
    String url = await taskSnapshot.ref.getDownloadURL();

    _firestore
        .collection('Users')
        .document(loggedInUser.uid)
        .updateData({'profile': url});

    setState(() {
      _profileImageUrl = url;
    });
    await pr.hide();
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream:
          _firestore.collection('Users').document(loggedInUser.uid).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.indigo,
            ),
          );
        }
        final user = snapshot.data;

        user['profile'] != null
            ? _profileImageUrl = user['profile']
            : _profileImageUrl = null;

        _userName = user['name'];
        _userStatus = user['status'];

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.indigo,
          ),
          body: SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 30.0,
                  ),
                  UserInformation(
                    profileImageUrl: _profileImageUrl,
                    username: _userName,
                    status: _userStatus,
                    color: Colors.black87,
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        RoundedButton(
                          title: 'Change Image',
                          onPressed: () {
                            _changeImage(ImageSource.gallery);
                          },
                          color: Colors.deepOrange,
                        ),
                        RoundedButton(
                          title: 'Change Status',
                          onPressed: () async {
                            await statusUpdateDialog(context);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  statusUpdateDialog(BuildContext context) async {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              'Your status',
              textAlign: TextAlign.center,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(20.0),
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: TextEditingController(text: _userStatus),
                  maxLength: 100,
                  maxLines: null,
                  onChanged: (value) {
                    _userStatus = value;
                  },
                ),
                RoundedButton(
                  title: 'Update',
                  color: Colors.indigo,
                  onPressed: () async {
                    _firestore
                        .collection('Users')
                        .document(loggedInUser.uid)
                        .updateData({'status': _userStatus});

                    setState(() {
                      Navigator.pop(context);
                    });
                  },
                ),
              ],
            ),
          );
        });
  }
}

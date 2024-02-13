import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../widget/user_image_picker.dart';

final _firebase = FirebaseAuth.instance;

class AuthSCreen extends StatefulWidget {
  const AuthSCreen({super.key});

  @override
  State<AuthSCreen> createState() => _AuthSCreenState();
}

class _AuthSCreenState extends State<AuthSCreen> {
  final _form = GlobalKey<FormState>();

  var _isLogin = true;
  var _isAuthenticating = false;

  var _enteredUsername = "";
  var _enteredEmail = "";
  var _enteredPassword = "";

  File? _selectedImage;

  void _submit() async {
    final isValid = _form.currentState!.validate();

    if (!isValid || !_isLogin && _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Invalid Sign Up Credentials.Upload a image")),
      );
      return;
    }

    _form.currentState!.save();
    print(_enteredEmail);
    print(_enteredPassword);

    try {
      setState(() {
        _isAuthenticating = true;
      });

      if (_isLogin) {
        final _userCredentials = await _firebase.signInWithEmailAndPassword(
            email: _enteredEmail, password: _enteredPassword);
        print("user_credentials :  $_userCredentials");
      } else {
        final _userCredentials = await _firebase.createUserWithEmailAndPassword(
            email: _enteredEmail, password: _enteredPassword);

        print("user_credentials :  $_userCredentials");

        final storageRef = FirebaseStorage.instance
            .ref()
            .child("user_images")
            .child("${_userCredentials.user!.uid}.jpg");

        await storageRef.putFile(_selectedImage!);

        final imageUrl = await storageRef.getDownloadURL();

        print(imageUrl);

        await FirebaseFirestore.instance
            .collection("users")
            .doc(_userCredentials.user!.uid)
            .set({
          "username": _enteredUsername,
          "email": _enteredEmail,
          "image_url": imageUrl,
        });
      }
    } on FirebaseAuthException catch (error) {
      // if (error.code == "email-already-in-use") {
      //  //..
      // }

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message ?? "Authentication failed")));

      setState(() {
        _isAuthenticating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
          child: SingleChildScrollView(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            margin: EdgeInsets.only(top: 30, bottom: 20, left: 20, right: 20),
            width: 200,
            child: Image.asset("lib/chatApp/assets/images/logo-chatter.png"),
          ),
          Card(
            margin: EdgeInsets.all(20),
            child: SingleChildScrollView(
                child: Padding(
              padding: EdgeInsets.all(16),
              child: Form(
                  key: _form,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!_isLogin)
                        UserImagePicker(
                          onPickImage: (pickedyImage) {
                            _selectedImage = pickedyImage;
                          },
                        ),
                      if (!_isLogin)
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: "username",
                          ),
                          enableSuggestions: false,
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                value.trim().length < 4) {
                              return "Please enter a valid Username ( at least 4 characters).";
                            }
                            return null;
                          },
                          onSaved: (newValue) {
                            _enteredUsername = newValue!;
                          },
                        ),
                      TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        autocorrect: false,
                        textCapitalization: TextCapitalization.none,
                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty ||
                              !value.contains("@")) {
                            return "Please enter a valid email address";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: "e-mail",
                        ),
                        onSaved: (newValue) {
                          _enteredEmail = newValue!;
                        },
                      ),
                      TextFormField(
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: "password",
                        ),
                        validator: (value) {
                          if (value == null || value.trim().length < 6) {
                            return "Password must be greater than 6 cheractor long";
                          }
                          return null;
                        },
                        onSaved: (newValue) {
                          _enteredPassword = newValue!;
                        },
                      ),
                      SizedBox(height: 12),
                      if (_isAuthenticating) const CircularProgressIndicator(),
                      if (!_isAuthenticating)
                        ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor: MaterialStatePropertyAll(
                                    Colors.pinkAccent)),
                            onPressed: _submit,
                            child: Text(
                              _isLogin ? "Log in" : "Signup",
                              style: TextStyle(color: Colors.white),
                            )),
                      if (!_isAuthenticating)
                        TextButton(
                            onPressed: () {
                              setState(() {
                                _isLogin = !_isLogin;
                              });
                            },
                            child: Text(_isLogin
                                ? "Create an account"
                                : "Already have an account")),
                    ],
                  )),
            )),
          )
        ]),
      )),
    );
  }
}

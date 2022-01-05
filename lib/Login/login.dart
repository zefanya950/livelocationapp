import 'dart:convert';

import 'package:flutter/material.dart';
import '../main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sweetalert/sweetalert.dart';
import 'package:http/http.dart' as http;

String userId;
String pass;

class MyLogin extends StatefulWidget {
  @override
  _MyLoginState createState() => _MyLoginState();
}

class _MyLoginState extends State<MyLogin> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login page',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Login(),
    );
  }
}

// ignore: non_constant_identifier_names
void TampilkanAlert(context, String s) {
  SweetAlert.show(context,
      title: "Alert!", subtitle: s, style: SweetAlertStyle.error);
}

// ignore: non_constant_identifier_names
void TampilkanAlertLoginGagal(context) {
  SweetAlert.show(context,
      title: "Login Gagal !",
      subtitle: "Check again username or password !!",
      style: SweetAlertStyle.error);
}

Future checklogin(context) async {
  final response = await http.post(
      Uri.http('10.0.2.2:8080', "/gomap/login.php"),
      body: {'username': userId, 'password': pass});

  // final response = await http.post(
  //     Uri.http('192.168.1.7:8080', "/gomap/login.php"),
  //     body: {'username': userId, 'password': pass});

  if (response.statusCode == 200) {
    Map<String, dynamic> hasil = jsonDecode(response.body);
    // If the server did return a 200 OK response, then parse the JSON.
    if (hasil['result'] == 'success') {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // ignore: unnecessary_statements
      prefs.setString("userId", userId) ?? "";
      // ignore: unnecessary_statements
      prefs.setString("wkt_con", "semua") ?? "";
      main();
    } else {
      TampilkanAlertLoginGagal(context);
    }
  } else {
    TampilkanAlertLoginGagal(context);
  }
}

class Login extends StatefulWidget {
  Login({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Login Page"),
        ),
        body: ListView(
          children: [
            Container(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Image(
                          image: AssetImage('assets/images/logo.png'),
                          fit: BoxFit.cover,
                          width: 300,
                          height: 300),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: TextField(
                        onChanged: (value) {
                          userId = value;
                        },
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Username',
                            hintText: 'Enter Username'),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      //padding: EdgeInsets.symmetric(horizontal: 15),
                      child: TextField(
                        onChanged: (value) {
                          pass = value;
                        },
                        obscureText: true,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Password',
                            hintText: 'Enter secure password'),
                      ),
                    ),
                    Padding(
                        padding: EdgeInsets.all(10),
                        child: Container(
                          height: 50,
                          width: 300,
                          decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(20)),
                          child: FlatButton(
                            onPressed: () {
                              checklogin(context);
                            },
                            child: Text(
                              'Login',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 25),
                            ),
                          ),
                        )),
                  ],
                ),
              ),
            ),
          ],
        ));
  }
}

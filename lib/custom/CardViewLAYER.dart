import 'dart:convert';
import 'package:ui_livelocation/custom/icon.dart';
import 'package:flutter/cupertino.dart';
import '../google_map_page.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:sweetalert/sweetalert.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../main.dart';

class CardViewLayetState extends StatefulWidget {
  CardViewLayetState(
      this.nama_tabel,
      this.is_liveLocation,
      this.id,
      this.oleh,
      this.kab,
      this.nama,
      this.namaData,
      this.filter,
      this.tipe,
      this.kelLayer,
      this.icon,
      this.metaId);

  String nama_tabel;
  String is_liveLocation;
  String oleh;
  String icon;
  String kab;
  String nama;
  String namaData;
  String filter;
  String tipe;
  String kelLayer;
  String id;
  String metaId;

  @override
  _CardViewLayetStateState createState() => _CardViewLayetStateState(
      nama_tabel,
      is_liveLocation,
      id,
      oleh,
      kab,
      nama,
      namaData,
      filter,
      tipe,
      kelLayer,
      icon,
      metaId);
}

// ignore: non_constant_identifier_names
void TampilkanAlertGagal(context) {
  SweetAlert.show(context,
      subtitle: "Checking...", style: SweetAlertStyle.loading);
  new Future.delayed(new Duration(seconds: 2), () {
    SweetAlert.show(context,
        title: "Token Invalid!",
        subtitle: "Check Your token again!!",
        style: SweetAlertStyle.error);
  });
}

void TampilkanAlertBerhasil(context, String pNamaTbl, String pIcon) {
  SweetAlert.show(context,
      subtitle: "Checking...", style: SweetAlertStyle.loading);
  new Future.delayed(new Duration(seconds: 2), () {
    SweetAlert.show(context,
        title: "Success!",
        subtitle: "Ntapsssssss!!",
        style: SweetAlertStyle.success);
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => GoogleMapPage(
                  newNama_tabel: pNamaTbl,
                  newToken: inputToken,
                  icons: pIcon,
                )));
  });
}

Future CekToken(context, String pNamaTbl, String pIcon) async {
  // final response = await http.post(
  //     Uri.http('10.0.2.2:8080', "/gomap/bacaDetailObjek.php"),
  //     body: {'token': inputToken, 'nama_tabel': pNamaTbl});

  final response = await http.post(
      Uri.http('192.168.1.7:8080', "/gomap/bacaDetailObjek.php"),
      body: {'token': inputToken, 'nama_tabel': pNamaTbl});

  if (response.statusCode == 200) {
    Map<String, dynamic> hasil = jsonDecode(response.body);
    // If the server did return a 200 OK response, then parse the JSON.
    if (hasil['result'] == 'success') {
      // TampilkanAlertBerhasil(context, pNamaTbl, pIcon);
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => GoogleMapPage(
                    newNama_tabel: pNamaTbl,
                    newToken: inputToken,
                    icons: pIcon,
                  )));
      // runApp(ChooseLiveLocObj(inputToken, pNamaTbl));
    } else {
      TampilkanAlertGagal(context);
    }
  } else {
    TampilkanAlertGagal(context);
  }
}

var inputToken = "";
void _openPopup(context, String pNamaTbl, String pIcon) {
  Alert(
      context: context,
      title: "INPUT TOKEN!",
      content: Column(
        children: <Widget>[
          TextField(
            onChanged: (value) {
              inputToken = value;
            },
            decoration: InputDecoration(
              labelText: 'Please input your live location token',
            ),
          ),
        ],
      ),
      buttons: [
        DialogButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            "CANCEL",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
        DialogButton(
          onPressed: () => CekToken(context, pNamaTbl, pIcon),
          child: Text(
            "GO LIVE",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        )
      ]).show();
}

class _CardViewLayetStateState extends State<CardViewLayetState> {
  _CardViewLayetStateState(
      this.nama_tabel,
      this.is_liveLocation,
      this.id,
      this.oleh,
      this.kab, //Nama Kota
      this.nama, //Nama Objek
      this.namaData,
      this.filter,
      this.tipe,
      this.kelLayer,
      this.icon,
      this.metaId);

  String nama_tabel;
  String is_liveLocation;
  String oleh;
  String icon;
  String kab;
  String nama;
  String namaData;
  String filter;
  String tipe;
  String kelLayer;
  String id;
  TextEditingController nama_con = TextEditingController();
  String _imageVal;
  int data_con;
  String kel_con;
  String metaId;

  var iconClass = iconLayer();
  Map<int, String> kelLayers = {};
  Map<String, int> metadata = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {
      // getKelLayer();
      // getData();
    });
  }

  @override
  void initinitState() {
    super.initState();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    inputToken = "";
    _imageVal = icon.split('/')[4];
    nama_con.text = nama;
    data_con = int.parse(metaId);

    kel_con = kelLayer;
    Size size = MediaQuery.of(context).size;
    return Container(
        padding: EdgeInsets.all(15.0),
        child: Card(
          color: Colors.red[200],
          child: InkWell(
            splashColor: Colors.blue.withAlpha(30),
            onTap: () {
              if (is_liveLocation.toString() == "1") {
                _openPopup(context, nama_tabel, icon);
              } else {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => GoogleMapPage(
                              newNama_tabel: nama_tabel,
                              icons: icon,
                            )));
              }
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  leading: Image.asset('assets/images/icons8-bus-64.png'),
                  // leading: Image.network(icon, fit: BoxFit.fill),
                  title: Text(nama,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  subtitle: Row(
                    children: [
                      Text(oleh,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                  trailing: is_liveLocation.toString() == "1"
                      ? Icon(Icons.location_on)
                      : Icon(Icons.location_off),
                ),
              ],
            ),
          ),
        ));
  }
}

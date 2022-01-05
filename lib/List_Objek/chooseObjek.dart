import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ui_livelocation/main.dart';
import 'package:ui_livelocation/provider/location_provider.dart';
import '../google_map_page.dart';
import 'package:flutter/cupertino.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ui_livelocation/custom/CardViewLAYER.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserObj {
  String id;
  String nama;
  String button;
  UserObj(this.id, this.nama, this.button);
}

class MyUserObject extends StatefulWidget {
  @override
  _MyUserObjectState createState() => _MyUserObjectState();
}

class _MyUserObjectState extends State<MyUserObject> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => LocationProvider(),
          child: GoogleMapPage(),
        )
      ],
      child: MaterialApp(
        title: 'Choose Objek',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.red,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: ChooseObjek(),
        routes: {
          'googleMap': (context) => GoogleMapPage(),
          'myapp': (context) => MyApp(),
        },
      ),
    );
  }
}

class ChooseObjek extends StatefulWidget {
  ChooseObjek({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _ChooseObjekState createState() => _ChooseObjekState();
}

class _ChooseObjekState extends State<ChooseObjek> {
  // ignore: non_constant_identifier_names
  String wkt_con = "semua";

  Future<String> getWKTfromSF() async {
    final prefs = await SharedPreferences.getInstance();
    wkt_con = prefs.getString("wkt_con") ?? "";
    return wkt_con;
  }

  Future addWKTToSF(String pWktCon) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // ignore: unnecessary_statements
    prefs.setString("wkt_con", pWktCon) ?? "";
  }

  int idx = 0;
  List<Widget> lw = [];
  // ignore: missing_return
  Future<List<Widget>> loadProcess() async {
    if (wkt_con != "semua") {
      final respon = await http.post(
          Uri.http('10.0.2.2:8080', "/gomap/layer.php"),
          body: {'idx': idx.toString(), 'cat': wkt_con});

      // final respon = await http.post(
      //     Uri.http('192.168.1.7:8080', "/gomap/layer.php"),
      //     body: {'idx': idx.toString(), 'cat': wkt_con});
      List<Widget> temp = [];
      if (respon.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(respon.body);
        if (data['result'] == 'success') {
          for (int i = 0; i < data['data'].length; i++) {
            Map<String, dynamic> details = data['data'][i];
            setState(() {
              lw.add(CardViewLayetState(
                  details['nama_tabel'].toString(),
                  details['is_liveloc'].toString(),
                  details['id'].toString(),
                  details["oleh"],
                  details['kab'],
                  details["nama_layer"],
                  details['nama_data'],
                  details["filter"],
                  details["tipe"],
                  details["kel_layer"],
                  details['icon'],
                  details['id_metadata'].toString()));
            });
          }
          return temp;
        }
      }
    }
  }

  Map<String, String> kelWkt = {
    "semua": "semua",
  };

  Future getKab() async {
    final respon = await http
        .post(Uri.http('10.0.2.2:8080', "/gomap/filterDropDown.php"), body: {});
    // final respon = await http.post(
    //     Uri.http('192.168.1.7:8080', "/gomap/filterDropDown.php"),
    //     body: {});
    List<Widget> temp = [];
    if (respon.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(respon.body);
      if (data['result'] == 'success') {
        for (int i = 0; i < data['data'].length; i++) {
          Map<String, dynamic> details = data['data'][i];
          setState(() {
            var x = details['provinsi'] + "_" + i.toString();
            kelWkt[x] = details['kabupaten'];
          });
        }
        return temp;
      }
    }
  }

  // ignore: missing_return
  Future<List<Widget>> loadMore() async {
    final respon = await http.post(
        Uri.http('10.0.2.2:8080', "/gomap/layer.php"),
        body: {'idx': idx.toString(), 'cat': wkt_con});

    // final respon = await http.post(
    //     Uri.http('192.168.1.7:8080', "/gomap/layer.php"),
    //     body: {'idx': idx.toString(), 'cat': wkt_con});
    List<Widget> temp = [];
    if (respon.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(respon.body);
      if (data['result'] == 'success') {
        for (int i = 0; i < data['data'].length; i++) {
          Map<String, dynamic> details = data['data'][i];
          setState(() {
            lw.add(CardViewLayetState(
                details['nama_tabel'].toString(),
                details['is_liveloc'].toString(),
                details['id'].toString(),
                details["oleh"],
                details['kab'],
                details["nama_layer"],
                details['nama_data'],
                details["filter"],
                details["tipe"],
                details["kel_layer"],
                details['icon'],
                details['id_metadata'].toString()));
          });
        }
        return temp;
      }
    }
  }

  ScrollController _controller;
  _scrollListener() {
    if (_controller.offset >= _controller.position.maxScrollExtent &&
        !_controller.position.outOfRange) {
      setState(() {
        idx = idx + 1;
      });
    }
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    //loadProcess();
    getKab();
    _controller = ScrollController();
    _controller.addListener(_scrollListener);
  }

  @override
  void initinitState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    getWKTfromSF();
    // loadProcess();
    Size size = MediaQuery.of(context).size;
    return new Scaffold(
      drawer: ClipRRect(
        child: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              UserAccountsDrawerHeader(
                  accountName: Text(user_aktif),
                  accountEmail: Text(user_aktif + "@gmail.com"),
                  currentAccountPicture: CircleAvatar(
                      backgroundImage:
                          NetworkImage("https://i.pravatar.cc/150"))),
              ListTile(
                title: Text('Logout'),
                leading: new Icon(
                  Icons.exit_to_app,
                  color: Colors.orangeAccent,
                ),
                onTap: () {
                  logout();
                },
              ),
            ],
          ),
        ),
      ),
      appBar: new AppBar(
        elevation: 0,
        title: new Text(
          "Object",
          style: TextStyle(fontSize: 40),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        controller: _controller,
        child: Column(
          children: <Widget>[
            Container(
              height: size.height * 0.12,
              child: Stack(
                children: <Widget>[
                  Container(
                    height: size.height * 0.08,
                    decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(25),
                          bottomRight: Radius.circular(25),
                        )),
                  ),
                  Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 20.0),
                          padding: EdgeInsets.symmetric(horizontal: 20.0),
                          height: size.height * 0.08,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.all(
                                Radius.circular(15),
                              ),
                              boxShadow: [
                                BoxShadow(
                                    offset: Offset(0, 4),
                                    blurRadius: 30,
                                    color: Colors.black.withOpacity(0.73))
                              ]),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                  child: DropdownButton<String>(
                                value: wkt_con,
                                isExpanded: true,
                                items: kelWkt
                                    .map((description, value) {
                                      return MapEntry(
                                          description,
                                          DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(description
                                                    .split("_")[0]
                                                    .toString() +
                                                " - " +
                                                value.toString()),
                                          ));
                                    })
                                    .values
                                    .toList(),
                                onChanged: (String newValue) {
                                  setState(() {
                                    wkt_con = newValue;
                                    addWKTToSF(wkt_con);
                                    lw.removeRange(0, lw.length);
                                    idx = 0;
                                    loadProcess();
                                  });
                                },
                              )),
                              Icon(
                                Icons.search,
                                size: 25,
                              )
                            ],
                          ))),
                ],
              ),
            ),
            Column(
              children: lw,
            )
          ],
        ),
      ),
    );
  }
}

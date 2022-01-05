import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Login/login.dart';
import 'List_Objek/chooseObjek.dart';
import 'google_map_page.dart';

String user_aktif = "";

Future<String> isLogin() async {
  final prefs = await SharedPreferences.getInstance();
  String userId = prefs.getString("userId") ?? "";
  return userId;
}

void logout() async {
  final prefs = await SharedPreferences.getInstance();
  prefs.remove("userId");
  runApp(MyLogin());
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  isLogin().then((String result) {
    if (result == "")
      runApp(MyLogin());
    else {
      user_aktif = result;
      runApp(MyUserObject());
    }
  });
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gomap LiveTracking',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: MyHomePage(title: 'Gomap Livetracking Home Page'),
      routes: {
        'chooseObj': (context) => MyUserObject(),
        'mapPage': (context) => GoogleMapPage(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
          drawer: ClipRRect(
            child: Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  UserAccountsDrawerHeader(
                      accountName: Text(userId ?? ''),
                      accountEmail: Text(userId ?? '' + "@gmail.com"),
                      currentAccountPicture: CircleAvatar(
                          backgroundImage:
                              NetworkImage("https://i.pravatar.cc/150"))),
                  ListTile(
                    title: Text('Choose Object'),
                    leading: new Icon(
                      Icons.airport_shuttle,
                      color: Colors.orangeAccent,
                    ),
                    onTap: () {
                      Navigator.popAndPushNamed(context, 'chooseObj');
                    },
                  ),
                  ListTile(
                    title: Text('Map'),
                    leading: new Icon(
                      Icons.add_location_sharp,
                      color: Colors.orangeAccent,
                    ),
                    onTap: () {
                      Navigator.popAndPushNamed(context, 'mapPage');
                    },
                  ),
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
          appBar: AppBar(
            title: Text("Gomap"),
          ), //body nanti ditaruh sini
          body: ListView(
            children: [
              Container(
                margin: EdgeInsets.all(10),
                child: Column(
                  children: [
                    Text('Home',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20)),
                  ],
                ),
              )
            ],
          )),
    );
  }
}

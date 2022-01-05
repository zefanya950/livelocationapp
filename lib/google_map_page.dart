import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:ui_livelocation/provider/location_provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'List_Objek/chooseObjek.dart';
import 'package:http/http.dart' as http;
import 'package:sweetalert/sweetalert.dart';
import 'package:background_location/background_location.dart';

var token = "";
var nama_tabel = "";
var id = "";
var wkt = "";
var status = "";

Uint8List markerIcon = markerIcon;

http.Response responseImage;

class GoogleMapPage extends StatefulWidget {
  final LocationData location;
  final String newNama_tabel;
  final String newToken;
  final String icons;
  GoogleMapPage({this.location, this.newNama_tabel, this.newToken, this.icons});

  @override
  _GoogleMapPageState createState() => _GoogleMapPageState();
}

class _GoogleMapPageState extends State<GoogleMapPage> {
  // ignore: unused_field
  LocationData _locationData;
  LatLng _point;
  String servStatus = "online";
  // maps
  Set<Marker> _markers = HashSet<Marker>();
  Set<Polygon> _polygons = HashSet<Polygon>();
  Set<Circle> _circles = HashSet<Circle>();
  List<LatLng> polygonLatlngs = <LatLng>[];

  var polylineCoords = <LatLng>[];
  var polylineSet = Set<Polyline>();

  double radius;
  List<LatLng> latlngSegment = <LatLng>[];
  LatLng varLoc2 = LatLng(0, 0);

  //ids
  var _polygonIdCounter = 1;
  int _circleIdCounter = 1;
  int _markerIdCounter = 1;

  //type controllers
  bool _isPolygon = false;
  bool _isMarker = true;
  bool _isCircle = false;

  BitmapDescriptor mapMarker;

  @override
  void initState() {
    super.initState();
    setCustomMarker();
    Provider.of<LocationProvider>(context, listen: false).initialization();
    _locationData = widget.location;
    if (widget.newToken == null) {
      AmbilSemuaData(context, widget.newNama_tabel);
    }
  }

  void backservice(context) async {
    if (servStatus == "offline") {
      BackgroundLocation.stopLocationService();
    } else {
      await BackgroundLocation.setAndroidNotification(
        title: 'Gomap Live Tracking',
        message: 'Gomap is running',
        icon: '@mipmap/ic_launcher',
      );
      await BackgroundLocation.startLocationService(distanceFilter: 20);
      BackgroundLocation.getLocationUpdates((location) {
        setState(() {
          String newWkt = "POINT(" +
              location.longitude.toString() +
              " " +
              location.latitude.toString() +
              ")";
          wkt = newWkt;
          UpdateData(context, "online", newWkt);
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Gomap Live Tracking"),
        backgroundColor: Colors.red,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            if (widget.newToken == null) {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => ChooseObjek()));
            } else {
              UpdateData(context, "offline", wkt).then((String result) {
                if (result == "success") {
                  servStatus = "offline";
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => ChooseObjek()));
                }
              });
            }
          },
        ),
      ),
      body: googleMapUI(_point),
    );
  }

  Future<ui.Image> loadImage(List<int> img) async {
    final Completer<ui.Image> completer = new Completer();
    ui.decodeImageFromList(img, (ui.Image img) {
      return completer.complete(img);
    });
    return completer.future;
  }

  void setCustomMarker() {
    BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(50, 50)),
            'assets/images/icons8-bus-64.png')
        .then((d) {
      mapMarker = d;
    });
  }

  void _setMarkers(LatLng point) {
    final String markerIdVal = 'marker_id_$_markerIdCounter';
    _markerIdCounter++;
    if (this.mounted) {
      setState(() {
        _markers.add(Marker(
            markerId: MarkerId(markerIdVal), position: point, icon: mapMarker));
        // icon: BitmapDescriptor.fromBytes(responseImage.bodyBytes)));
      });
    }
  }

  void _setCircles(LatLng point) {
    final String circleIdVal = 'circle_id_$_circleIdCounter';
    _circleIdCounter++;
    _circles.add(Circle(
        circleId: CircleId(circleIdVal),
        center: point,
        radius: radius,
        fillColor: Colors.redAccent.withOpacity(0.5),
        strokeWidth: 3,
        strokeColor: Colors.redAccent));
  }

  void _setPolygon() {
    final String polygonIdVal = 'polygon_id_$_polygonIdCounter';
    _polygonIdCounter++;
    _polygons.add(Polygon(
      polygonId: PolygonId(polygonIdVal),
      points: polygonLatlngs,
      strokeWidth: 2,
      strokeColor: Colors.red,
      fillColor: Colors.pink,
    ));
  }

  Future AmbilSemuaData(context, String pNamaTable) async {
    final response = await http.post(
        Uri.http('10.0.2.2:8080', "/gomap/bacaAllDetailObj.php"),
        body: {'nama_tabel': pNamaTable});

    // final response = await http.post(
    //     Uri.http('192.168.1.7:8080', "/gomap/bacaAllDetailObj.php"),
    //     body: {'nama_tabel': pNamaTable});
    //responseImage = await http.get(widget.icons);
    // markerIcon = await getBytesFromCanvas(80, 98, widget.icons);
    if (response.statusCode == 200) {
      Map<String, dynamic> hasil = jsonDecode(response.body);
      // If the server did return a 200 OK response, then parse the JSON.
      if (hasil['result'] == 'success') {
        var _wkt = hasil['data'];
        _markers.clear();
        for (var i = 0; i < _wkt.length; i++) {
          if (_wkt[i]["wkt"].toString().split("(")[0] == "POINT") {
            String split = _wkt[i]["wkt"].toString().split("(")[1];
            String split2 = split.split(")")[0];
            String latitude = split2.split(" ")[1];
            String longitude = split2.split(" ")[0];
            LatLng mark =
                new LatLng(double.parse(latitude), double.parse(longitude));
            _setMarkers(mark);
          } else if (_wkt[i]["wkt"].toString().split("(")[0] == "LINESTRING") {
            String split = _wkt[i]["wkt"].toString().split("(")[1];
            String split2 = split.split(")")[0];
            List<String> split3 = split2.split(",");
            int counterpoly = 1;
            final String polylineIdVal = 'polyline_id_$counterpoly';
            for (var j = 0; j < split3.length; j++) {
              String latlng1 = split3[j].toString();
              List<String> split4 = latlng1.split(" ");
              double lat1 = double.parse(split4[0]);
              String lng1 = split4[1];
              LatLng polyline = LatLng(double.parse(lng1), lat1);
              polylineCoords.add(polyline);
              counterpoly++;
            }
            polylineSet.add(
              Polyline(
                  polylineId: PolylineId(polylineIdVal),
                  points: polylineCoords,
                  width: 2,
                  color: Colors.blue),
            );
          } else if (_wkt[i]["wkt"].toString().split("(")[0] ==
              "MULTIPOLYGON") {
            String split = _wkt[i]["wkt"].toString().split("(((")[1];
            String split2 = split.split(")))")[0];
            List<String> split3 = split2.split(",");
            for (var j = 0; j < split3.length; j++) {
              String latlng1 = split3[j].toString();
              List<String> split4 = latlng1.split(" ");
              String lat1 = split4[1];
              String lng1 = split4[0];
              LatLng polygon = LatLng(double.parse(lat1), double.parse(lng1));
              polygonLatlngs.add(polygon);
            }
            _setPolygon();
          }
        }
      } else {
        TampilkanAlertGagal(context, hasil['result']);
      }
    } else {
      TampilkanAlertGagal(context, response.statusCode.toString());
    }
  }

  void TampilkanAlertGagal(context, String err) {
    SweetAlert.show(context,
        subtitle: "Loading data...", style: SweetAlertStyle.loading);
    new Future.delayed(new Duration(seconds: 2), () {
      SweetAlert.show(context,
          title: "Error!", subtitle: err, style: SweetAlertStyle.error);
    });
  }

  void TampilkanAlertLoading(context, String pId, String pWkt, String pStat) {
    SweetAlert.show(context,
        subtitle: "Loading data...", style: SweetAlertStyle.loading);
    new Future.delayed(new Duration(seconds: 2), () {
      SweetAlert.show(context,
          title: "Success!", style: SweetAlertStyle.success);
    });
  }

  Future CekToken(context) async {
    final response = await http.post(
        Uri.http('10.0.2.2:8080', "/gomap/bacaDetailObjek.php"),
        body: {'token': token, 'nama_tabel': widget.newNama_tabel});

    // final response = await http.post(
    //     Uri.http('192.168.1.7:8080', "/gomap/bacaDetailObjek.php"),
    //     body: {'token': token, 'nama_tabel': widget.newNama_tabel});

    if (response.statusCode == 200) {
      Map<String, dynamic> hasil = jsonDecode(response.body);
      // If the server did return a 200 OK response, then parse the JSON.
      if (hasil['result'] == 'success') {
        id = hasil['data'][0]['id'].toString();
        wkt = hasil['data'][0]['wkt'].toString();
        status = hasil['data'][0]['status'].toString();
        AmbilDataSelainLive(context, widget.newNama_tabel, id);
      } else {
        TampilkanAlertGagal(context, hasil['result']);
      }
    } else {
      TampilkanAlertGagal(context, response.statusCode.toString());
    }
  }

  // ignore: non_constant_identifier_names
  Future AmbilDataSelainLive(context, String pNamaTable, String pId) async {
    final response = await http.post(
        Uri.http('10.0.2.2:8080', "/gomap/dataSelainLiveLoc.php"),
        body: {'nama_tabel': pNamaTable, 'id': pId});

    // final response = await http.post(
    //     Uri.http('192.168.1.7:8080', "/gomap/dataSelainLiveLoc.php"),
    //     body: {'nama_tabel': pNamaTable, 'id': pId});
    //responseImage = await http.get(widget.icons);
    if (response.statusCode == 200) {
      Map<String, dynamic> hasil = jsonDecode(response.body);
      // If the server did return a 200 OK response, then parse the JSON.
      if (hasil['result'] == 'success') {
        _markers.clear();
        var _wkt = hasil['data'];
        for (var i = 0; i < _wkt.length; i++) {
          if (_wkt[i]["wkt"].toString().split("(")[0] == "POINT") {
            String split = _wkt[i]["wkt"].toString().split("(")[1];
            String split2 = split.split(")")[0];
            String latitude = split2.split(" ")[1];
            String longitude = split2.split(" ")[0];
            LatLng mark =
                new LatLng(double.parse(latitude), double.parse(longitude));
            _setMarkers(mark);
          }
        }
      } else {
        TampilkanAlertGagal(context, hasil['result']);
      }
    } else {
      TampilkanAlertGagal(context, response.statusCode.toString());
    }
  }

  Future<String> DeleteLog(context) async {
    final response = await http
        .post(Uri.http('10.0.2.2:8080', "/gomap/deleteLog.php"), body: {
      'nama_tabel': nama_tabel,
      'id': id,
      'token': token,
    });

    // final response = await http
    //     .post(Uri.http('192.168.1.7:8080', "/gomap/deleteLog.php"), body: {
    //   'nama_tabel': nama_tabel,
    //   'id': id,
    //   'token': token,
    // });

    if (response.statusCode == 200) {
      Map<String, dynamic> hasil = jsonDecode(response.body);
      // If the server did return a 200 OK response, then parse the JSON.
      if (hasil['result'] == 'success') {
        return "success";
      } else {
        TampilkanAlertGagal(context, hasil['Error'].toString());
      }
    } else {
      TampilkanAlertGagal(context, response.statusCode.toString());
    }
  }

  Future<String> UpdateData(context, String pStatus, String newWkt) async {
    final response = await http
        .post(Uri.http('10.0.2.2:8080', "/gomap/updateDetailObjek.php"), body: {
      'nama_tabel': nama_tabel,
      'id': id,
      'wkt': newWkt,
      'status': pStatus,
      'token': token,
    });

    // final response = await http.post(
    //     Uri.http('192.168.1.7:8080', "/gomap/updateDetailObjek.php"),
    //     body: {
    //       'nama_tabel': nama_tabel,
    //       'id': id,
    //       'wkt': newWkt,
    //       'status': pStatus,
    //       'token': token,
    //     });

    if (response.statusCode == 200) {
      Map<String, dynamic> hasil = jsonDecode(response.body);
      // If the server did return a 200 OK response, then parse the JSON.
      if (hasil['result'] == 'success') {
        return "success";
      } else {
        TampilkanAlertGagal(context, hasil['Error'].toString());
      }
    } else {
      TampilkanAlertGagal(context, response.statusCode.toString());
    }
  }

  Widget googleMapUI(LatLng point) {
    return Consumer<LocationProvider>(builder: (consumerContext, model, child) {
      if (model.locationPosition != null) {
        nama_tabel = widget.newNama_tabel;
        if (widget.newToken != null) {
          token = widget.newToken;
          CekToken(context);
          wkt = "POINT(" +
              model.locationPosition.longitude.toString() +
              " " +
              model.locationPosition.latitude.toString() +
              ")";
          backservice(context);
        }
        return Column(
          children: [
            Expanded(
              child: GoogleMap(
                mapType: MapType.normal,
                initialCameraPosition:
                    CameraPosition(target: model.locationPosition, zoom: 16),
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                markers: _markers,
                polylines: polylineSet,
                polygons: _polygons,
                onMapCreated: (GoogleMapController controller) {},
              ),
            )
          ],
        );
      }

      return Container(
          child: Center(
        child: CircularProgressIndicator(),
      ));
    });
  }
}

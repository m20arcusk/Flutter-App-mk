import 'dart:io';
//import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

void main() {
  runApp(MyApp());
}

/*
Future<BusInfo> OneBusInfo(BusInfo lobi) async {
  List<String> stopNos = [];
  for (int i = 0; i < 78; i++) {
    stopNos.add(snapshot.data!.stopNo.toString());
  }
}
*/
Future<List<BusInfo>> fetchBusInfo() async {
  final response = await http.get(
    Uri.parse(
        'https://api.translink.ca/rttiapi/v1/stops?apikey=rqFAxDROV4jA0mvKlaaj&lat=49.268425&long=-123.248165&radius=200'),
    headers: {
      //HttpHeaders.authorizationHeader: 'rqFAxDROV4jA0mvKlaaj',
      'Content-Type': 'application/JSON'
    },
  );

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    List<BusInfo> lobi = [];
    List<dynamic> json = jsonDecode(response.body);
    for (int i = 0; i < json.length; i++) {
      lobi.add(BusInfo.fromJson(jsonDecode(response.body)[i]));
    }

    //final busInforesponse = BusInfo.fromJson(jsonDecode(response.body)[0]);
    //print(jsonDecode(response.body)[0]);
    return lobi;
    //final responseJson = jsonDecode(response.body);

    //return Album.fromJson(responseJson);
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}
//---------------------------------------------

Future<List<NextBus>> fetchBusStopInfo(String busStop) async {
  final response = await http.get(
    Uri.parse(
        'https://api.translink.ca/rttiapi/v1/stops/$busStop/estimates?apikey=rqFAxDROV4jA0mvKlaaj&count=3&timeframe=30'),
    headers: {
      //HttpHeaders.authorizationHeader: 'rqFAxDROV4jA0mvKlaaj',
      'Content-Type': 'application/JSON'
    },
  );

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    List<NextBus> lobs = [];
    List<dynamic> json = jsonDecode(response.body);
    for (int i = 0; i < json.length; i++) {
      lobs.add(NextBus.fromJson(jsonDecode(response.body)[i]));
    }

    //final busInforesponse = BusInfo.fromJson(jsonDecode(response.body)[0]);
    //print(jsonDecode(response.body)[0]);
    return lobs;
    //final responseJson = jsonDecode(response.body);

    //return Album.fromJson(responseJson);
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}

List<Future<List<NextBus>>> findNextBusses(List<String> lobs) {
  List<Future<List<NextBus>>> lolobs = [];
  for (int i = 0; i < lobs.length; i++) {
    lolobs.add(fetchBusStopInfo(lobs[i]));
  }
  return lolobs;
}

//------------------------------------------------

/*
///
/// When the location services are not enabled or permissions
/// are denied the `Future` will return an error.
Future<Position> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;
// Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the
    // App to enable the location services.
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high);
  return position;
}
*/
/*
class GeolocatorWidget extends StatefulWidget {
  /// Creates a new GeolocatorWidget.
  const GeolocatorWidget({Key? key}) : super(key: key);

  @override
  _GeolocatorWidgetState createState() => _GeolocatorWidgetState();
}

class _GeolocatorWidgetState extends State<GeolocatorWidget> {
*/

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<List<BusInfo>> futureBusInfo;
  //late Future<List<BusInfo>> futureBusStopInfo;
  //late Future<Position> position;

  @override
  void initState() {
    super.initState();
    futureBusInfo = fetchBusInfo();
    //position = _determinePosition();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Displaying Bus Routes...',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Displaying Bus Routes...'),
        ),
        body: Center(
          child: FutureBuilder<List<BusInfo>>(
            future: futureBusInfo,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<String> stopNos = [];
                for (int i = 0; i < snapshot.data!.length; i++) {
                  stopNos.add(snapshot.data![i].stopNo.toString());
                }
                String info = "";
                List<String> infoList = [];
                for (int i = 0; i < snapshot.data!.length; i++) {
                  info += " ${stopNos[i]}";
                  infoList.add(stopNos[i]);
                }
                List<Future<List<NextBus>>> lolobs = findNextBusses(infoList);
                print(lolobs);
                return Text(info);
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }

              // By default, show a loading spinner.
              return const CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }
}

class BusInfo {
  final int stopNo;
  final String name;
  final String bayNo;
  //final City? city;
  final String city;
  final String onStreet;
  final String atStreet;
  final double latitude;
  final double longitude;
  final int wheelchairAccess;
  final int distance;
  final String routes;

  const BusInfo({
    required this.stopNo,
    required this.name,
    required this.bayNo,
    required this.city,
    required this.onStreet,
    required this.atStreet,
    required this.latitude,
    required this.longitude,
    required this.wheelchairAccess,
    required this.distance,
    required this.routes,
  });

  factory BusInfo.fromJson(Map<String, dynamic> json) => BusInfo(
        stopNo: json["StopNo"],
        name: json["Name"],
        bayNo: json["BayNo"],
        //city: cityValues.map[json["City"]],\
        city: json["City"],
        onStreet: json["OnStreet"],
        atStreet: json["AtStreet"],
        latitude: json["Latitude"].toDouble(),
        longitude: json["Longitude"].toDouble(),
        wheelchairAccess: json["WheelchairAccess"],
        distance: json["Distance"],
        routes: json["Routes"],
      );

  Map<String, dynamic> toJson() => {
        "StopNo": stopNo,
        "Name": name,
        "BayNo": bayNo,
        //"City": cityValues.reverse![city],
        "City": city,
        "OnStreet": onStreet,
        "AtStreet": atStreet,
        "Latitude": latitude,
        "Longitude": longitude,
        "WheelchairAccess": wheelchairAccess,
        "Distance": distance,
        "Routes": routes,
      };
}

class NextBus {
    NextBus({
        required this.routeNo,
        required this.routeName,
        required this.direction,
        required this.routeMap,
        required this.schedules,
    });

    String routeNo;
    String routeName;
    String direction;
    RouteMap routeMap;
    Schedules schedules;

    factory NextBus.fromJson(Map<String, dynamic> json) => NextBus(
        routeNo: json["RouteNo"],
        routeName: json["RouteName"],
        direction: json["Direction"],
        routeMap: RouteMap.fromJson(json["RouteMap"]),
        schedules: Schedules.fromJson(json["Schedules"]),
    );

    Map<String, dynamic> toJson() => {
        "RouteNo": routeNo,
        "RouteName": routeName,
        "Direction": direction,
        "RouteMap": routeMap.toJson(),
        "Schedules": schedules.toJson(),
    };
}

class RouteMap {
    RouteMap({
        required this.href,
    });

    String href;

    factory RouteMap.fromJson(Map<String, dynamic> json) => RouteMap(
        href: json["Href"],
    );

    Map<String, dynamic> toJson() => {
        "Href": href,
    };
}

class Schedules {
    Schedules({
        required this.schedule,
    });

    List<Schedule> schedule;

    factory Schedules.fromJson(Map<String, dynamic> json) => Schedules(
        schedule: List<Schedule>.from(json["Schedule"].map((x) => Schedule.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "Schedule": List<dynamic>.from(schedule.map((x) => x.toJson())),
    };
}

class Schedule {
    Schedule({
        required this.pattern,
        required this.destination,
        required this.expectedLeaveTime,
        required this.expectedCountdown,
        required this.scheduleStatus,
        required this.cancelledTrip,
        required this.cancelledStop,
        required this.addedTrip,
        required this.addedStop,
        required this.lastUpdate,
    });

    String pattern;
    String destination;
    String expectedLeaveTime;
    int expectedCountdown;
    String scheduleStatus;
    bool cancelledTrip;
    bool cancelledStop;
    bool addedTrip;
    bool addedStop;
    String lastUpdate;

    factory Schedule.fromJson(Map<String, dynamic> json) => Schedule(
        pattern: json["Pattern"],
        destination: json["Destination"],
        expectedLeaveTime: json["ExpectedLeaveTime"],
        expectedCountdown: json["ExpectedCountdown"],
        scheduleStatus: json["ScheduleStatus"],
        cancelledTrip: json["CancelledTrip"],
        cancelledStop: json["CancelledStop"],
        addedTrip: json["AddedTrip"],
        addedStop: json["AddedStop"],
        lastUpdate: json["LastUpdate"],
    );

    Map<String, dynamic> toJson() => {
        "Pattern": pattern,
        "Destination": destination,
        "ExpectedLeaveTime": expectedLeaveTime,
        "ExpectedCountdown": expectedCountdown,
        "ScheduleStatus": scheduleStatus,
        "CancelledTrip": cancelledTrip,
        "CancelledStop": cancelledStop,
        "AddedTrip": addedTrip,
        "AddedStop": addedStop,
        "LastUpdate": lastUpdate,
    };
} 

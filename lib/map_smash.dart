import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:graphql/client.dart';
import 'package:maps_gg/maker_layer_tournament.dart';

Future<List<dynamic>> _requestApi(double latitude, double longitude) async {
  final httpLink = HttpLink(
    'https://api.start.gg/gql/alpha',
  );
  final authLink = AuthLink(
    getToken: () async => 'Bearer 7896090b713048a15a1df5eacdc2d260',
  );
  Link link = authLink.concat(httpLink);
  final GraphQLClient client = GraphQLClient(
    cache: GraphQLCache(),
    link: link,
  );
  const String readTournamentsAroud = r'''
    query SocalTournaments($perPage: Int, $coordinates: String!, $radius: String!) {
      tournaments(query: {
        perPage: $perPage
        filter: {
          location: {
            distanceFrom: $coordinates,
            distance: $radius
          }
        }
      }) {
        nodes {
          id
          name
          city
          lat
          lng
        }
      }
    }
  ''';

  const int perPage = 10;
  String coordinates = "$latitude,$longitude";
  const String radius = "50mi";

  final QueryOptions options = QueryOptions(
    document: gql(readTournamentsAroud),
    variables: <String, dynamic>{
      'perPage': perPage,
      'coordinates': coordinates,
      'radius': radius
    },
  );
  final QueryResult result = await client.query(options);

  List<dynamic> coordinatesTournaments = [];
  if (result.hasException) {
    debugPrint(result.exception.toString());
  } else {
    for (var element in result.data!['tournaments']['nodes']) {
      coordinatesTournaments
          .add({'lat': element['lat'], 'lng': element['lng']});
    }
  }
  debugPrint(coordinatesTournaments.toString());
  return coordinatesTournaments;
}

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
  return await Geolocator.getCurrentPosition();
}

class MapSmash extends StatelessWidget {
  final latitude = 48.729024;
  final longitude = -3.463714;

  const MapSmash({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Maps.gg"),
      ),
      body: FutureBuilder(
          future: _requestApi(latitude, longitude),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              /*_requestApi(snapshot.data!.latitude, snapshot.data!.longitude);*/

              return FlutterMap(
                options: MapOptions(
                  center: LatLng(latitude, longitude), // Coordonnées de Paris
                  zoom: 13.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    subdomains: const ['a', 'b', 'c'],
                  ),
                  MarkerLayerTournaments(coordonates: snapshot.data),
                  MarkerLayer(
                    markers: [
                      Marker(
                        width: 80.0,
                        height: 80.0,
                        point: LatLng(latitude, longitude),
                        builder: (ctx) => const Icon(
                          Icons.location_pin,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  )
                ],
              );
            } else {
              return const CircularProgressIndicator();
            }
          }),
      /*FlutterMap(
        options: MapOptions(
          center: LatLng(48.8566, 2.3522), // Coordonnées de Paris
          zoom: 13.0,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: const ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: [
              Marker(
                width: 80.0,
                height: 80.0,
                point: LatLng(48.8566, 2.3522), // Coordonnées de Paris
                builder: (ctx) => const Icon(
                  Icons.location_pin,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),*/
    );
  }
}

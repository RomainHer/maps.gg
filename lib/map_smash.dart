import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:graphql/client.dart';
import 'package:maps_gg/marker_layer_tournament.dart';
import 'package:maps_gg/tournament_info.dart';

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
    query SocalTournaments($perPage: Int, $coordinates: String!, $radius: String!, $timestampNow: Timestamp) {
      tournaments(query: {
        perPage: $perPage
        filter: {
          location: {
            distanceFrom: $coordinates,
            distance: $radius
          },
          afterDate: $timestampNow
        }
      }) {
        nodes {
          id
          name
          images {
            type
            url
            ratio
          }
          lat
          lng
          numAttendees
          startAt
          registrationClosesAt
          events(limit: 10) {
            name
            competitionTier
            numEntrants
            videogame {
              images (type: "primary") {
                url
                ratio
              }
            }
          }
          venueAddress
          url(relative: false)
          links {
            facebook
            discord
          }
          primaryContact
          primaryContactType
          rules
        }
      }
    }
  ''';

  const int perPage = 500;
  String coordinates = "$latitude,$longitude";
  const String radius = "100mi";
  //const int timestampNowtest = 1680699455;

  DateTime datetimeNow = DateTime.now();
  double tmp = datetimeNow.millisecondsSinceEpoch / 1000;
  int timestampNow = tmp.round();

  /*debugPrint(timestampNow.toString());
  DateTime dateTmp = DateTime.fromMillisecondsSinceEpoch(timestampNow * 1000);
  String formattedDateTmp = DateFormat('dd/MM/yyyy H:mm:ss').format(dateTmp);
  debugPrint(formattedDateTmp);*/

  final QueryOptions options = QueryOptions(
    document: gql(readTournamentsAroud),
    variables: <String, dynamic>{
      'perPage': perPage,
      'coordinates': coordinates,
      'radius': radius,
      'timestampNow': timestampNow
    },
  );
  final QueryResult result = await client.query(options);

  List<dynamic> dataTournaments = [];
  if (result.hasException) {
    debugPrint(result.exception.toString());
  } else {
    for (var tournament in result.data!['tournaments']['nodes']) {
      var tournamentDetail = {
        'id': tournament['id'],
        'name': tournament['name'],
        'lat': tournament['lat'],
        'lng': tournament['lng'],
        'date': tournament['startAt'],
        'registrationEnd': tournament['registrationClosesAt'],
        'numAttendees': tournament['numAttendees'],
        'venueAddress': tournament['venueAddress'],
        'url': tournament['url'],
        'facebook': tournament['links']['facebook'],
        'discord': tournament['links']['discord'],
        'contact': {
          'link': tournament['primaryContact'],
          'type': tournament['primaryContactType'],
        },
        'rules': tournament['rules']
      };

      for (var image in tournament['images']) {
        if (image['type'] == 'profile') {
          tournamentDetail['profileImage'] = {
            'url': image['url'],
            'ratio': image['ratio']
          };
        }
      }

      var eventsData = [];
      for (var event in tournament['events']) {
        eventsData.add({
          'name': event['name'],
          'image': event['videogame']['images'][0]['url'],
          'competitionTier': event['competitionTier'],
          'numEntrants': event['numEntrants'],
        });
      }
      tournamentDetail['events'] = eventsData;

      dataTournaments.add(tournamentDetail);
    }
  }
  //debugPrint(coordinatesTournaments.toString());
  return dataTournaments;
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

class MapSmash extends StatefulWidget {
  final latitude = 48.729024;
  final longitude = -3.463714;
  const MapSmash({super.key});

  @override
  State<MapSmash> createState() => _MapSmashState();
}

class _MapSmashState extends State<MapSmash> {
  final tournamentInfoWidgetKey = GlobalKey<TournamentInfoState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Maps.gg"),
      ),
      body: Stack(
        children: [
          FutureBuilder(
            future: _determinePosition(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return FutureBuilder(
                    future: _requestApi(
                        snapshot.data!.latitude, snapshot.data!.longitude),
                    builder: (context, snapshot2) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        /*_requestApi(snapshot.data!.latitude, snapshot.data!.longitude);*/

                        return FlutterMap(
                          options: MapOptions(
                            center: LatLng(
                                snapshot.data!.latitude,
                                snapshot
                                    .data!.longitude), // Coordonnées de Paris
                            zoom: 8.0,
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                              subdomains: const ['a', 'b', 'c'],
                            ),
                            MarkerLayerTournaments(
                              tournamentsData: snapshot2.data,
                              showInfoWidget: tournamentInfoWidgetKey,
                            ),
                            MarkerLayer(
                              markers: [
                                Marker(
                                  width: 80.0,
                                  height: 80.0,
                                  point: LatLng(snapshot.data!.latitude,
                                      snapshot.data!.longitude),
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
                    });
              } else {
                return const CircularProgressIndicator();
              }
            },
          ),
          TournamentInfo(key: tournamentInfoWidgetKey),
        ],
      ),
    );
  }
}

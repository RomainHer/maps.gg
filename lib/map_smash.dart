import 'package:flutter/material.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:geolocator/geolocator.dart';
import 'package:graphql/client.dart';
import 'package:maps_gg/map/custom_map.dart';

Future<Map<String, dynamic>> _getLocationAndTournaments() async {
  try {
    Position position = await _determinePosition();
    List<dynamic> tournaments =
        await _requestApi(position.latitude, position.longitude);
    return {
      'position': position,
      'tournaments': tournaments,
    };
  } catch (e) {
    return Future.error(e);
  }
}

Future<List<dynamic>> _requestApi(double latitude, double longitude) async {
  final httpLink = HttpLink(
    'https://api.start.gg/gql/alpha',
  );
  final authLink = AuthLink(
    getToken: () async => 'Bearer d5d8a776d10a680ffa26d2893243b31a',
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
  const String radius = "200mi";
  DateTime datetimeNow = DateTime.now();
  double tmp = datetimeNow.millisecondsSinceEpoch / 1000;
  int timestampNow = tmp.round();

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

  return dataTournaments;
}

Future<Position> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  return await Geolocator.getCurrentPosition();
}

class MapSmash extends StatefulWidget {
  MapSmash({super.key});

  final latitude = 48.729024;
  final longitude = -3.463714;

  final PopupController _popupController = PopupController();

  @override
  State<MapSmash> createState() => _MapSmashState();
}

class _MapSmashState extends State<MapSmash> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _getLocationAndTournaments(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              var data = snapshot.data as Map<String, dynamic>;
              return PopupScope(
                popupController: widget._popupController,
                child: CustomMap(
                  location: data['position'],
                  tournaments: data['tournaments'],
                  popupController: widget._popupController,
                ),
              );
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
          }
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/pikachu.gif",
                      height: 50,
                      width: 50,
                    ),
                    Container(
                      padding: const EdgeInsets.only(
                          left: 12.5, right: 12.5, top: 25),
                      child: Image.asset(
                        "assets/kirby.gif",
                        height: 25,
                        width: 25,
                      ),
                    ),
                    Image.asset(
                      "assets/mario.gif",
                      height: 50,
                      width: 50,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: const LinearProgressIndicator(),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

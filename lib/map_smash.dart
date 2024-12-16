import 'package:flutter/material.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:geolocator/geolocator.dart';
import 'package:graphql/client.dart';
import 'package:maps_gg/class/event.dart';
import 'package:maps_gg/map/custom_map.dart';
import 'package:maps_gg/class/videogame.dart';

final String startGGApiToken = const String.fromEnvironment('API_KEY');

Future<Map<String, dynamic>> _getLocationAndTournaments() async {
  try {
    Position position = await _determinePosition();
    List<dynamic> tournaments;
    Map<VideoGame, int> videoGames;
    (tournaments, videoGames) =
        await _requestApi(position.latitude, position.longitude);
    return {
      'position': position,
      'tournaments': tournaments,
      'videoGames': videoGames
    };
  } catch (e) {
    return Future.error(e);
  }
}

Future<(List, Map<VideoGame, int>)> _requestApi(
    double latitude, double longitude) async {
  final httpLink = HttpLink(
    'https://api.start.gg/gql/alpha',
  );
  final authLink = AuthLink(
    getToken: () async => 'Bearer $startGGApiToken',
  );
  Link link = authLink.concat(httpLink);
  final GraphQLClient client = GraphQLClient(
    cache: GraphQLCache(),
    link: link,
  );

  const String readTournamentsAround = r'''
    query localTournaments($perPage: Int, $coordinates: String!, $radius: String!, $timestampNow: Timestamp) {
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
              id
              displayName
              name          
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
  debugPrint(coordinates);
  const String radius = "200mi";
  DateTime datetimeNow = DateTime.now();
  double tmp = datetimeNow.millisecondsSinceEpoch / 1000;
  int timestampNow = tmp.round();
  debugPrint(timestampNow.toString());

  final QueryOptions options = QueryOptions(
    document: gql(readTournamentsAround),
    variables: <String, dynamic>{
      'perPage': perPage,
      'coordinates': coordinates,
      'radius': radius,
      'timestampNow': timestampNow
    },
  );

  final QueryResult result = await client.query(options);
  List<dynamic> dataTournaments = [];
  Map<VideoGame, int> dataVideoGames = {};

  if (result.hasException) {
    debugPrint(result.exception.toString());
  } else {
    for (var tournament in result.data!['tournaments']['nodes']) {
      double distanceInMeters = Geolocator.distanceBetween(
        latitude,
        longitude,
        tournament['lat'],
        tournament['lng'],
      );

      var tournamentDetail = {
        'id': tournament['id'],
        'name': tournament['name'],
        'lat': tournament['lat'],
        'lng': tournament['lng'],
        'distanceKm': distanceInMeters / 1000,
        'distanceMi': distanceInMeters / 1609.344,
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

      /*debugPrint(
          "num entrants : ${tournament['events'][0]["numEntrants"].toString()}");*/

      var eventsData = <Event>[];
      var videoGamesData = <VideoGame>[];
      for (var event in tournament['events']) {
        eventsData.add(Event(
          name: event['name'],
          competitionTier: event['competitionTier'],
          numEntrants:
              (event['numEntrants'] != null) ? event['numEntrants'] : 0,
          videoGame: VideoGame(
            id: event['videogame']['id'],
            displayName: event['videogame']['displayName'],
            name: event['videogame']['name'],
            imageUrl: event['videogame']['images'][0]['url'],
            imageRatio: event['videogame']['images'][0]['ratio'].toDouble(),
          ),
        ));
        if (!videoGamesData.contains(VideoGame(
          id: event['videogame']['id'],
          displayName: event['videogame']['displayName'],
          name: event['videogame']['name'],
          imageUrl: event['videogame']['images'][0]['url'],
          imageRatio: event['videogame']['images'][0]['ratio'].toDouble(),
        ))) {
          videoGamesData.add(VideoGame(
            id: event['videogame']['id'],
            displayName: event['videogame']['displayName'],
            name: event['videogame']['name'],
            imageUrl: event['videogame']['images'][0]['url'],
            imageRatio: event['videogame']['images'][0]['ratio'].toDouble(),
          ));
        }
        VideoGame newVideoGame = VideoGame(
          id: event['videogame']['id'],
          displayName: event['videogame']['displayName'],
          name: event['videogame']['name'],
          imageUrl: event['videogame']['images'][0]['url'],
          imageRatio: event['videogame']['images'][0]['ratio'].toDouble(),
        );
        if (dataVideoGames.containsKey(newVideoGame)) {
          dataVideoGames[newVideoGame] =
              (dataVideoGames[newVideoGame] ?? 0) + 1;
        } else {
          dataVideoGames[newVideoGame] = 1;
        }
      }

      tournamentDetail['events'] = eventsData;
      tournamentDetail['videoGames'] = videoGamesData;

      dataTournaments.add(tournamentDetail);
    }
  }

  //return dataVideoGames;
  return (dataTournaments, dataVideoGames);
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
                  videoGames: data['videoGames'],
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

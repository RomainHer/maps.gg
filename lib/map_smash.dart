import 'dart:async';

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
    debugPrint("Error while getting location and tournaments: $e");
    return Future.error(e);
  }
}

Future<(List<dynamic>, Map<VideoGame, int>)> _requestApi(
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
    query localTournaments($perPage: Int, $page: Int, $coordinates: String!, $radius: String!, $timestampNow: Timestamp) {
      tournaments(query: {
        perPage: $perPage,
        page: $page,
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
        pageInfo {
          totalPages
        }
      }
    }
  ''';

  const int perPage = 20; // Nombre d'éléments par page
  String coordinates = "$latitude,$longitude";
  debugPrint(coordinates);
  const String radius = "200mi";
  DateTime datetimeNow = DateTime.now();
  int timestampNow = (datetimeNow.millisecondsSinceEpoch / 1000).round();
  debugPrint(timestampNow.toString());

  // 1. Récupérez le nombre total de pages avec un appel initial
  final QueryOptions initialOptions = QueryOptions(
    document: gql(readTournamentsAround),
    variables: <String, dynamic>{
      'perPage': perPage,
      'page': 1,
      'coordinates': coordinates,
      'radius': radius,
      'timestampNow': timestampNow,
    },
  );

  final QueryResult initialResult = await client.query(initialOptions);
  if (initialResult.hasException) {
    debugPrint('GraphQL Exception (Initial): ${initialResult.exception}');
    return ([], <VideoGame, int>{});
  }

  final int totalPages =
      initialResult.data?['tournaments']['pageInfo']['totalPages'] ?? 1;

  // 2. Créez une fonction pour récupérer une page spécifique
  Future<List<dynamic>> fetchPage(int page) async {
    final QueryOptions pageOptions = QueryOptions(
      document: gql(readTournamentsAround),
      variables: <String, dynamic>{
        'perPage': perPage,
        'page': page,
        'coordinates': coordinates,
        'radius': radius,
        'timestampNow': timestampNow,
      },
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final QueryResult pageResult = await client.query(pageOptions).timeout(
      Duration(seconds: 15),
      onTimeout: () {
        throw TimeoutException(
            "La requête pour la page $page a dépassé le délai de 15 secondes");
      },
    );

    if (pageResult.hasException) {
      debugPrint('GraphQL Exception (Page $page): ${pageResult.exception}');
      return [];
    }

    return pageResult.data?['tournaments']['nodes'] ?? [];
  }

  // 3. Lancez tous les appels en parallèle
  List<Future<List<dynamic>>> futures = List.generate(
    totalPages,
    (index) => fetchPage(index + 1),
  );

  // 4. Attendez les résultats
  final List<List<dynamic>> results = await Future.wait(futures);

  // 5. Combinez toutes les données
  List<dynamic> allTournaments = [];
  Map<VideoGame, int> dataVideoGames = {};

  for (var pageNodes in results) {
    for (var tournament in pageNodes) {
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

      var eventsData = <Event>[];
      for (var event in tournament['events']) {
        eventsData.add(Event(
          name: event['name'],
          competitionTier: event['competitionTier'],
          numEntrants: event['numEntrants'] ?? 0,
          videoGame: VideoGame(
            id: event['videogame']['id'],
            displayName: event['videogame']['displayName'],
            name: event['videogame']['name'],
            imageUrl: event['videogame']['images'][0]['url'],
            imageRatio: event['videogame']['images'][0]['ratio'].toDouble(),
          ),
        ));
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
      allTournaments.add(tournamentDetail);
    }
  }

  return (allTournaments, dataVideoGames);
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

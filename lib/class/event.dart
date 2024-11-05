import 'package:maps_gg/class/videogame.dart';

class Event {
  String name;
  VideoGame videoGame;
  int competitionTier;
  int numEntrants;

  Event({
    required this.name,
    required this.videoGame,
    required this.competitionTier,
    required this.numEntrants,
  });
}

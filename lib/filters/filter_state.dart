import 'package:flutter/material.dart';
import 'package:maps_gg/class/videogame.dart';

class FilterState {
  FilterState(
    this.distance,
    this.measureUnit,
    this.selectedVideoGames,
    this.selectedDateRange,
    this.selectedRangeParticpants,
  );

  FilterState.empty();

  double distance = 200;
  String measureUnit = 'km';
  List<VideoGame> selectedVideoGames = [];
  DateTimeRange? selectedDateRange;
  RangeValues selectedRangeParticpants = const RangeValues(0, 12);

  bool isEmpty() {
    return distance == 200 &&
        measureUnit == 'km' &&
        selectedVideoGames.isEmpty &&
        selectedDateRange == null &&
        selectedRangeParticpants.start == 0 &&
        selectedRangeParticpants.end == 12;
  }

  bool isDistanceChanged() {
    return distance != 200 || measureUnit != 'km';
  }

  bool isVideoGamesChanged() {
    return selectedVideoGames.isNotEmpty;
  }

  bool isDateRangeChanged() {
    return selectedDateRange != null;
  }

  bool isRangeParticipantsChanged() {
    return selectedRangeParticpants.start != 0 &&
        selectedRangeParticpants.end != 12;
  }
}

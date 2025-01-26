import 'package:flutter/material.dart';
import 'package:maps_gg/class/videogame.dart';

class FilterState {
  FilterState(
    this.searchText,
    this.distance,
    this.measureUnit,
    this.selectedVideoGames,
    this.selectedDateRange,
    this.minParticipants,
    this.maxParticipants,
  );

  FilterState.empty() {
    searchText = '';
    distance = 200;
    measureUnit = 'km';
    selectedVideoGames = [];
    selectedDateRange = null;
    minParticipants = null;
    maxParticipants = null;
  }

  String searchText = '';
  double distance = 200;
  String measureUnit = 'km';
  int? minParticipants;
  int? maxParticipants;
  List<VideoGame> selectedVideoGames = [];
  DateTimeRange? selectedDateRange;

  bool isEmpty() {
    return searchText == '' &&
        distance == 200 &&
        measureUnit == 'km' &&
        selectedVideoGames.isEmpty &&
        selectedDateRange == null &&
        maxParticipants == null &&
        minParticipants == null;
  }

  bool isSearchTextChanged() {
    return searchText.isNotEmpty;
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
    return minParticipants != null || maxParticipants != null;
  }
}

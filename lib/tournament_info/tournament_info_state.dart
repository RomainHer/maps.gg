import 'package:maps_gg/class/event.dart';

class TournamentInfoState {
  TournamentInfoState(
    this.isTournamentSelected,
    this.tournamentId,
    this.tournamentName,
    this.tournamentDate,
    this.tournamentUrlImage,
    this.tournamentEvents,
    this.tournamentVenueAddress,
    this.tournamentVenueLat,
    this.tournamentVenueLng,
    this.tournamentUrl,
    this.tournamentNumAttendees,
  );

  TournamentInfoState.empty();

  bool isTournamentSelected = false;
  int? tournamentDate;
  List<Event>? tournamentEvents;
  int? tournamentId;
  String? tournamentName;
  int? tournamentNumAttendees;
  String? tournamentUrl;
  String? tournamentUrlImage;
  String? tournamentVenueAddress;
  double? tournamentVenueLat;
  double? tournamentVenueLng;
}

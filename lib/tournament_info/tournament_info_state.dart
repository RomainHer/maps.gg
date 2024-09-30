class TournamentInfoState {
  bool isTournamentSelected = false;
  String? tournamentName;
  int? tournamentDate;
  String? tournamentUrlImage;
  List<dynamic>? tournamentEvents;
  String? tournamentVenueAddress;
  double? tournamentVenueLat;
  double? tournamentVenueLng;
  String? tournamentUrl;
  int? tournamentNumAttendees;

  TournamentInfoState(
      this.isTournamentSelected,
      this.tournamentName,
      this.tournamentDate,
      this.tournamentUrlImage,
      this.tournamentEvents,
      this.tournamentVenueAddress,
      this.tournamentVenueLat,
      this.tournamentVenueLng,
      this.tournamentUrl,
      this.tournamentNumAttendees);

  TournamentInfoState.empty();
}

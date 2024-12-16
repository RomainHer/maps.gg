import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:maps_gg/class/event.dart';
import 'package:maps_gg/tournament_info/tournament_info_state.dart';

class MarkerContentTournament extends StatefulWidget {
  const MarkerContentTournament({
    super.key,
    required this.tournamentId,
    required this.tournamentName,
    required this.tournamentDate,
    required this.tournamentUrlImage,
    required this.tournamentEvents,
    required this.tournamentVenueAddress,
    required this.tournamentVenueLat,
    required this.tournamentVenueLng,
    required this.tournamentUrl,
    required this.tournamentNumAttendees,
    required this.updateTournamentInfoState,
    required this.getSelectedTournamentId,
  });

  final Function getSelectedTournamentId;
  final int tournamentDate;
  final List<Event> tournamentEvents;
  final int tournamentId;
  final String tournamentName;
  final int tournamentNumAttendees;
  final String tournamentUrl;
  final String tournamentUrlImage;
  final String tournamentVenueAddress;
  final double tournamentVenueLat;
  final double tournamentVenueLng;
  final Function updateTournamentInfoState;

  @override
  State<MarkerContentTournament> createState() =>
      _MarkerContentTournamentState();
}

class _MarkerContentTournamentState extends State<MarkerContentTournament> {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Column(
        children: [
          SizedBox(
            height: 70,
            width: 140,
            child: InkWell(
              onTap: () async {
                if (widget.tournamentId != widget.getSelectedTournamentId()) {
                  widget.updateTournamentInfoState(
                    TournamentInfoState(
                      true,
                      widget.tournamentId,
                      widget.tournamentName,
                      widget.tournamentDate,
                      widget.tournamentUrlImage,
                      widget.tournamentEvents,
                      widget.tournamentVenueAddress,
                      widget.tournamentVenueLat,
                      widget.tournamentVenueLng,
                      widget.tournamentUrl,
                      widget.tournamentNumAttendees,
                    ),
                  );
                } else {
                  widget.updateTournamentInfoState(TournamentInfoState.empty());
                }
                if (!kDebugMode) {
                  await FirebaseAnalytics.instance.logEvent(
                      name: 'tournament_selected',
                      parameters: <String, Object>{
                        'tournament_id': widget.tournamentId,
                        'tournament_name': widget.tournamentName,
                      });
                } else {
                  debugPrint('Analytics not logged in debug mode');
                }
              },
              child: Container(
                padding: const EdgeInsets.only(bottom: 10),
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.bottomCenter,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: widget.tournamentId ==
                                  widget.getSelectedTournamentId()
                              ? Color(0xFF3F7FFD)
                              : Colors.white,
                          width: 3,
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: Image.network(
                          widget.tournamentUrlImage,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            height: 50,
                            width: 50,
                            color: Color(0xFFD8D8D8),
                          ),
                          loadingBuilder: (_, child, loadingProgress) =>
                              loadingProgress == null
                                  ? child
                                  : const SizedBox(
                                      height: 50,
                                      width: 50,
                                      child: CircularProgressIndicator()),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -10,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned(
                            top: 4,
                            child: Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.location_pin,
                            size: 20,
                            color: Color(0xFF3F7FFD),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 70, width: 140),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:maps_gg/tournament_info.dart';

class MarkerContentTournament extends StatefulWidget {
  final int tournamentId;
  final String tournamentName;
  final int tournamentDate;
  final String tournamentUrlImage;

  const MarkerContentTournament({
    super.key,
    required this.tournamentId,
    required this.tournamentName,
    required this.tournamentDate,
    required this.tournamentUrlImage,
  });

  @override
  State<MarkerContentTournament> createState() =>
      _MarkerContentTournamentState();
}

class _MarkerContentTournamentState extends State<MarkerContentTournament> {
  @override
  Widget build(BuildContext context) {
    double textFactor = widget.tournamentName.length > 45 ? 0.7 : 1;
    return Container(
        alignment: Alignment.center,
        child: Column(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => {
                  showModalBottomSheet<void>(
                    context: context,
                    showDragHandle: true,
                    builder: (BuildContext context) {
                      return TournamentInfo(
                        tournamentName: widget.tournamentName, 
                        tournamentDate: widget.tournamentDate, 
                        tournamentUrlImage: widget.tournamentUrlImage
                      );
                    },
                  )
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        widget.tournamentName,
                        overflow: TextOverflow.ellipsis,
                        textScaler: TextScaler.linear(textFactor),
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.location_pin,
                      color: Colors.red,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 70, width: 140),
          ],
        )

        /*Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              children: [
                Text(
                  widget.tournamentName,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.location_pin,
            color: Colors.red,
          ),
        ],
      ),*/
        );
  }
}

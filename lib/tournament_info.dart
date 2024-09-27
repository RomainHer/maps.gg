import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:maps_gg/tournament_info_state.dart';
import 'package:url_launcher/url_launcher.dart';

String capitalizeFirstLetterOfEachWord(String input) {
  List<String> words = input.split(' ');
  List<String> wordsWithCapitalizedFirstLetter = [];

  for (String word in words) {
    if (word.isNotEmpty) {
      wordsWithCapitalizedFirstLetter
          .add(word[0].toUpperCase() + word.substring(1));
    }
  }
  String result = wordsWithCapitalizedFirstLetter.join(' ');

  return result;
}

class TournamentInfo extends StatefulWidget {
  const TournamentInfo({super.key, required this.tournamentInfoState});

  final TournamentInfoState tournamentInfoState;

  getNumberDaysBeforeTournament() {
    var daysBefore = getDifferenceInDays(
        DateTime.now(),
        DateTime.fromMillisecondsSinceEpoch(
            (tournamentInfoState.tournamentDate ?? 0) * 1000));
    var hoursAfterNextMidnight = getDifferenceInHours(
        DateTime.fromMillisecondsSinceEpoch(
            (tournamentInfoState.tournamentDate ?? 0) * 1000),
        getNextMidnight(DateTime.now()));
    var extraDays = hoursAfterNextMidnight > 0 ? 1 : 0;
    if (hoursAfterNextMidnight < 0) {
      return "Aujourd'hui";
    } else if (hoursAfterNextMidnight < 24) {
      return "Demain";
    } else if (daysBefore < 7) {
      return "Dans ${daysBefore + extraDays} jours";
    } else if (daysBefore < 30) {
      return "Dans ${daysBefore ~/ 7} semaines";
    } else if (daysBefore < 365) {
      return "Dans ${daysBefore ~/ 30} mois";
    } else {
      return "Dans ${daysBefore ~/ 365} ans";
    }
  }

  getDifferenceInDays(DateTime date1, DateTime date2) {
    return date1.difference(date2).inDays.abs();
  }

  getDifferenceInHours(DateTime date1, DateTime date2) {
    return date1.difference(date2).inHours;
  }

  getNextMidnight(DateTime date) {
    return DateTime(date.year, date.month, date.day + 1);
  }

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(Uri.encodeFull(url)))) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  State<TournamentInfo> createState() => _TournamentInfoState();
}

class _TournamentInfoState extends State<TournamentInfo> {
  bool isTournamentLiked = false;

  @override
  Widget build(BuildContext context) {
    var tournamentDateTime = DateTime.fromMillisecondsSinceEpoch(
        (widget.tournamentInfoState.tournamentDate ?? 0) * 1000);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: [
              Text(
                widget.tournamentInfoState.tournamentName ?? 'no-name',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              const Spacer(),
              IconButton(
                color: Colors.black,
                isSelected: isTournamentLiked,
                selectedIcon: const Icon(Icons.favorite),
                icon: const Icon(Icons.favorite_border),
                onPressed: () {
                  setState(() {
                    isTournamentLiked = !isTournamentLiked;
                  });
                },
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                clipBehavior: Clip.antiAlias,
                elevation: 10,
                child: Image.network(
                  widget.tournamentInfoState.tournamentUrlImage ?? '',
                  width: 70,
                  height: 70,
                  loadingBuilder: (context, child, loadingProgress) =>
                      loadingProgress == null
                          ? child
                          : const SizedBox(
                              height: 70,
                              width: 70,
                              child: CircularProgressIndicator()),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.place,
                          color: Color(0xFF3F7FFD),
                          size: 20,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (var i in (widget.tournamentInfoState
                                        .tournamentVenueAddress ??
                                    "")
                                .split(","))
                              Text(
                                i.toString(),
                                style: const TextStyle(
                                  fontSize: 12,
                                ),
                              )
                          ],
                        )
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          color: Color(0xFF3F7FFD),
                          size: 20,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              capitalizeFirstLetterOfEachWord(
                                  DateFormat.yMMMMEEEEd('fr')
                                      .format(tournamentDateTime)),
                              style: const TextStyle(
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              "(${widget.getNumberDaysBeforeTournament()})",
                              style: const TextStyle(
                                fontSize: 12,
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule,
                          color: Color(0xFF3F7FFD),
                          size: 20,
                        ),
                        Text(
                          "A ${tournamentDateTime.hour}h${tournamentDateTime.minute == 0 ? '' : tournamentDateTime.minute}",
                          style: const TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.group,
                          color: Color(0xFF3F7FFD),
                          size: 20,
                        ),
                        Text(
                          "${widget.tournamentInfoState.tournamentNumAttendees} participants",
                          style: const TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          /*Text(widget.tournamentInfoState.tournamentVenueAddress ??
              'no-adress'), //TODO: copy tournament venue address to clipboard when clicked
          Row(children: [
            TextButton(
              style: ButtonStyle(
                foregroundColor: WidgetStateProperty.all<Color>(Colors.blue),
              ),
              onPressed: () {
                //Open the address in a maps app
                //https://www.google.com/maps/search/?api=1&query=$tournamentVenueAddress
                widget._launchUrl(
                    "https://www.google.com/maps/search/?api=1&query=${widget.tournamentInfoState.tournamentVenueAddress}");
              },
              child: const Text('On Google Maps'),
            ),
            TextButton(
              style: ButtonStyle(
                foregroundColor: WidgetStateProperty.all<Color>(Colors.blue),
              ),
              onPressed: () {
                //Open the address in a waze app
                //https://www.waze.com/ul?ll=$lat,$lng&navigate=yes
                //https://waze.com/ul?q=$tournamentVenueAddress
                widget._launchUrl(
                    "https://www.waze.com/ul?ll=${widget.tournamentInfoState.tournamentVenueLat},${widget.tournamentInfoState.tournamentVenueLng}&navigate=yes");
              },
              child: const Text('On Waze'),
            ),
          ]),
          TextButton(
            style: ButtonStyle(
              foregroundColor: WidgetStateProperty.all<Color>(Colors.blue),
            ),
            onPressed: () {
              //Open the tournament URL in a browser
              widget._launchUrl(widget.tournamentInfoState.tournamentUrl ?? '');
            },
            child: const Text('Go to start.gg'),
          ),
          Text(
              "${widget.tournamentInfoState.tournamentNumAttendees} participants"),*/
        ],
      ),
    );
  }
}

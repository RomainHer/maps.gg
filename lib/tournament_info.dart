import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

class TournamentInfo extends StatelessWidget {
  const TournamentInfo(
    {
      super.key, 
      required this.tournamentName, 
      required this.tournamentDate, 
      required this.tournamentUrlImage, 
      required this.tournamentEvents, 
      required this.tournamentVenueAddress,
      required this.tournamentVenueLat,
      required this.tournamentVenueLng,
      required this.tournamentUrl, 
      required this.tournamentNumAttendees
    }
  );

  final String tournamentName;
  final int tournamentDate;
  final String tournamentUrlImage;
  final List<dynamic> tournamentEvents;
  final String tournamentVenueAddress;
  final double tournamentVenueLat;
  final double tournamentVenueLng;
  final String tournamentUrl;
  final int tournamentNumAttendees;

  getNumberDaysBeforeTournament() {
    var daysBefore = getDifferenceInDays(DateTime.now(), DateTime.fromMillisecondsSinceEpoch(tournamentDate*1000));
    var hoursAfterNextMidnight = getDifferenceInHours(DateTime.fromMillisecondsSinceEpoch(tournamentDate * 1000),getNextMidnight(DateTime.now()));
    var extraDays = hoursAfterNextMidnight > 0 ? 1 : 0;
    if(hoursAfterNextMidnight < 0) {
      return "Aujourd'hui";
    } else if(hoursAfterNextMidnight < 24) {
      return "Demain";
    } else if(daysBefore < 7) {
      return "Dans ${daysBefore+extraDays} jours";
    } else if(daysBefore < 30) {
      return "Dans ${daysBefore ~/ 7} semaines";
    } else if(daysBefore < 365){
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
  Widget build(BuildContext context) {
    var tournamentDateTime = DateTime.fromMillisecondsSinceEpoch(tournamentDate * 1000);

    return Container(
        width: double.infinity,
        padding: const EdgeInsets.only(bottom: 30, top: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
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
                    tournamentUrlImage, 
                    width: 70, 
                    height: 70,
                    loadingBuilder: (context, child, loadingProgress) => loadingProgress == null ? child : const SizedBox(height: 70, width: 70, child: CircularProgressIndicator()),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tournamentName),
                      Text("${capitalizeFirstLetterOfEachWord(DateFormat.yMMMMEEEEd('fr').format(tournamentDateTime))} à ${tournamentDateTime.hour}h${tournamentDateTime.minute == 0 ? '' : tournamentDateTime.minute}"),
                      Text(getNumberDaysBeforeTournament()),
                    ],
                  )
                )
              ],
            ),
            Text(tournamentVenueAddress), //TODO: copy tournament venue address to clipboard when clicked
            Row(
              children: [
                TextButton(
                  style: ButtonStyle(
                    foregroundColor: WidgetStateProperty.all<Color>(Colors.blue),
                  ),
                  onPressed: () {
                    //Open the address in a maps app
                    //https://www.google.com/maps/search/?api=1&query=$tournamentVenueAddress
                    _launchUrl("https://www.google.com/maps/search/?api=1&query=$tournamentVenueAddress");
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
                    _launchUrl("https://www.waze.com/ul?ll=$tournamentVenueLat,$tournamentVenueLng&navigate=yes");
                  },
                  child: const Text('On Waze'),
                ),
              ]
            ),
            TextButton(
              style: ButtonStyle(
                foregroundColor: WidgetStateProperty.all<Color>(Colors.blue),
              ),
              onPressed: () {
                //Open the tournament URL in a browser                
                _launchUrl(tournamentUrl);
              },
              child: const Text('Go to start.gg'),
            ),
            Text("$tournamentNumAttendees participants"),
          ],
        ),
    );
  }
}

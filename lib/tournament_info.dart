import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
  const TournamentInfo({super.key, required this.tournamentName, required this.tournamentDate, required this.tournamentUrlImage});

  final String tournamentName;
  final int tournamentDate;
  final String tournamentUrlImage;

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
                  child: Image.network(tournamentUrlImage, width: 70, height: 70),
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
          ],
        ),
    );
  }
}

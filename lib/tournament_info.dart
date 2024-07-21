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

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(tournamentName),
            Text(capitalizeFirstLetterOfEachWord(DateFormat.yMMMMEEEEd('fr').format(DateTime.fromMillisecondsSinceEpoch(tournamentDate * 1000)))),
            Image.network(tournamentUrlImage, width: 30, height: 30),
          ],
        ),
      ),
    );
  }
}

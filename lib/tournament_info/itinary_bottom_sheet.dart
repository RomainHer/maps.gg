import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class ItinaryBottomSheet extends StatelessWidget {
  const ItinaryBottomSheet(
      {super.key,
      required this.tournamentVenueAddress,
      required this.tournamentVenueLat,
      required this.tournamentVenueLng});

  final String tournamentVenueAddress;
  final double tournamentVenueLat;
  final double tournamentVenueLng;

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(Uri.encodeFull(url)))) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.transparent,
              textStyle: GoogleFonts.heebo(
                fontSize: 17,
                fontWeight: FontWeight.normal,
              ),
            ),
            onPressed: () {
              _launchUrl(
                  "https://www.google.com/maps/search/?api=1&query=$tournamentVenueAddress");
            },
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  padding: const EdgeInsets.all(5),
                  child: Image.asset(
                    "assets/google_maps_logo.png",
                    height: 40,
                    width: 40,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Google Maps',
                  style: TextStyle(color: Colors.black),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.transparent,
              textStyle: GoogleFonts.heebo(
                color: Colors.black,
                fontSize: 17,
                fontWeight: FontWeight.normal,
              ),
            ),
            onPressed: () {
              _launchUrl(
                  "https://www.waze.com/ul?ll=$tournamentVenueLat,$tournamentVenueLng&navigate=yes");
            },
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Image.asset(
                    "assets/waze_logo.png",
                    height: 50,
                    width: 50,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Waze',
                  style: TextStyle(color: Colors.black),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.transparent,
              textStyle: GoogleFonts.heebo(
                color: Colors.black,
                fontSize: 17,
                fontWeight: FontWeight.normal,
              ),
            ),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: tournamentVenueAddress));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('address-copied').tr()),
              );
              Navigator.pop(context);
            },
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  padding: const EdgeInsets.all(10),
                  child: const Icon(
                    Icons.copy,
                    color: Colors.black,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'copy-address',
                  style: TextStyle(color: Colors.black),
                ).tr(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

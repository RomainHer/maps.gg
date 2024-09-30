import 'package:flutter/material.dart';

class ItinaryBottomSheet extends StatelessWidget {
  const ItinaryBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextButton(
            onPressed: () {
              // TODO: Implement Google Maps navigation
            },
            child: Row(
              children: [
                Card(
                  child: Image.asset(
                    "google_maps_logo.png",
                    height: 25,
                  ),
                ),
                const Text('Google Maps'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              // TODO: Implement Waze navigation
            },
            child: Row(
              children: [
                Card(
                  child: Image.asset(
                    "waze_logo.png",
                    height: 25,
                    width: 25,
                  ),
                ),
                const Text('Waze'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              // TODO: Implement Waze navigation
            },
            child: const Row(
              children: [
                Icon(Icons.copy),
                Text('Copy Address'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

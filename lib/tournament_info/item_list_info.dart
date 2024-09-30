import 'package:flutter/material.dart';

class ItemListInfo extends StatelessWidget {
  const ItemListInfo(
      {super.key,
      required this.icon,
      required this.text,
      this.padding = const EdgeInsets.all(0)});

  final IconData icon;
  final String text;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.only(right: 5),
            child: Icon(
              icon,
              color: const Color(0xFF3F7FFD),
              size: 20,
            ),
          ),
          Expanded(
            child: Text(
              text,
              softWrap: true,
              style: const TextStyle(
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

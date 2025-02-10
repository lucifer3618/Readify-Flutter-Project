import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EmptyDataPage extends StatelessWidget {
  final String imgPath, title, description;
  final double wdithFactor;
  const EmptyDataPage(
      {super.key,
      required this.imgPath,
      required this.title,
      required this.description,
      required this.wdithFactor});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            imgPath,
            width: MediaQuery.of(context).size.width * wdithFactor,
          ),
          const SizedBox(
            height: 30,
          ),
          Text(
            title,
            style: GoogleFonts.rowdies(fontSize: 30, fontWeight: FontWeight.w200),
          ),
          const SizedBox(
            height: 15,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Text(
              description,
              style: GoogleFonts.aDLaMDisplay(
                fontSize: 16,
                fontWeight: FontWeight.w100,
                color: Colors.black.withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.09,
          ),
        ],
      ),
    );
  }
}

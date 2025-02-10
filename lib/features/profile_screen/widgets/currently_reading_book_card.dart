import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CurrentlyReadingBookCard extends StatefulWidget {
  const CurrentlyReadingBookCard({super.key});

  @override
  State<CurrentlyReadingBookCard> createState() => _CurrentlyReadingBookCardState();
}

class _CurrentlyReadingBookCardState extends State<CurrentlyReadingBookCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.grey.withValues(alpha: 0.07),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  "assets/images/book_categories/book.jpg",
                  width: 70,
                ),
              ),
              const SizedBox(
                width: 15,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "The Davinci Code",
                          style: GoogleFonts.firaSans(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "By Dan Brown",
                          style: TextStyle(color: Colors.black.withValues(alpha: 0.6)),
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        const SizedBox(
                          width: 3,
                        ),
                        Text.rich(
                          TextSpan(
                            children: [
                              const TextSpan(
                                text: '4.5',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, color: Colors.black, fontSize: 16),
                              ),
                              TextSpan(
                                text: ' /5',
                                style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  color: Colors.black.withValues(alpha: 0.7),
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Remaining time"),
                            Text.rich(
                              TextSpan(
                                children: [
                                  const TextSpan(
                                    text: '27',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  TextSpan(
                                    text: '/30',
                                    style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      color: Colors.black.withValues(alpha: 0.7),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        LinearProgressIndicator(
                          value: 0.7,
                          minHeight: 7,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

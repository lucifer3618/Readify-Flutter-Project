import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:readify/shared/widgets/bookmark_button.dart';
import 'package:readify/utils/app_style.dart';

class NearbyBookCard extends StatefulWidget {
  final Map<String, dynamic> bookData;
  const NearbyBookCard({super.key, required this.bookData});

  @override
  State<NearbyBookCard> createState() => _NearbyBookCardState();
}

class _NearbyBookCardState extends State<NearbyBookCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      key: Key(widget.bookData["id"]),
      margin: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            CachedNetworkImage(
              imageUrl: widget.bookData["image_path"],
              placeholder: (context, url) => const SizedBox(
                  width: 50, height: 50, child: Center(child: CircularProgressIndicator())),
              errorWidget: (context, url, error) => const Icon(Icons.error),
              width: 120,
              height: 180,
              fit: BoxFit.fill,
            ),
            Container(
              width: 120,
              height: 180,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black, Colors.transparent],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
            SizedBox(
              width: 120,
              height: 180,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 10, right: 10),
                        child: SizedBox(
                          width: 40,
                          height: 40,
                          child: BookmarkButton(
                            bookId: widget.bookData["id"],
                            iconSize: 24,
                            selected: AppStyle.sunsetOrange,
                            nonSelected: const Color.fromARGB(167, 158, 158, 158),
                            padding: 0,
                          ),
                        ),
                      )
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                    child: Column(
                      children: [
                        Text(
                          widget.bookData["name"],
                          maxLines: 1,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: AppStyle.primaryColor,
                              size: 17,
                            ),
                            Text(
                              "${(widget.bookData["distance"].toStringAsFixed(1))} km away",
                              style: const TextStyle(color: Colors.white),
                            )
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

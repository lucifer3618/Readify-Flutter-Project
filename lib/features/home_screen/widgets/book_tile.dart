import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class BookTile extends StatelessWidget {
  final String imageURL, name, category;
  const BookTile({super.key, required this.imageURL, required this.name, required this.category});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: CachedNetworkImage(
            imageUrl: imageURL,
            placeholder: (context, url) => const SizedBox(
                width: 50, height: 50, child: Center(child: CircularProgressIndicator())),
            errorWidget: (context, url, error) => const Icon(Icons.error),
            width: 100,
          ),
          // child: Image.asset(
          //   imageURL,
          //   width: 100,
          //   fit: BoxFit.cover,
          // ),
        ),
        const SizedBox(
          height: 5,
        ),
        Text(
          name,
          maxLines: 1,
          style: const TextStyle(fontSize: 16, overflow: TextOverflow.ellipsis),
        ),
        const SizedBox(
          height: 3,
        ),
        Text(
          category,
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
      ],
    );
  }
}

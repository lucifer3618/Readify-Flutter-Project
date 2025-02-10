import 'package:flutter/material.dart';
import 'package:readify/services/database_service.dart';

class BookmarkButton extends StatefulWidget {
  final String bookId;
  final double iconSize;
  final Color selected, nonSelected;
  final double padding;
  const BookmarkButton({
    super.key,
    required this.bookId,
    required this.iconSize,
    required this.selected,
    required this.nonSelected,
    required this.padding,
  });

  @override
  State<BookmarkButton> createState() => _BookmarkButtonState();
}

class _BookmarkButtonState extends State<BookmarkButton> {
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: DatabaseService().checkIsFavorite(widget.bookId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text("Erro");
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            width: 30,
            height: 30,
            child:
                Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator())),
          );
        } else {
          isFavorite = snapshot.data!;
          return IconButton.filled(
            onPressed: () {
              setState(() {
                isFavorite = !isFavorite;
              });
              if (isFavorite) {
                DatabaseService().addBookToFavorite(widget.bookId);
              } else {
                DatabaseService().removeBookFromFavorite(widget.bookId);
              }
            },
            icon: Padding(
              padding: EdgeInsets.all(widget.padding),
              child: Icon(
                isFavorite ? Icons.bookmark_add_rounded : Icons.bookmark,
                size: widget.iconSize,
              ),
            ),
            style: IconButton.styleFrom(
                backgroundColor: isFavorite ? widget.selected : widget.nonSelected),
          );
        }
      },
    );
  }
}

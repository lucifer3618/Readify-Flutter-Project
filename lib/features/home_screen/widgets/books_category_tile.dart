import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:readify/features/book_screen/book_screen.dart';
import 'package:readify/services/database_service.dart';
import 'package:readify/utils/app_style.dart';

class BooksCategoryTile extends StatefulWidget {
  const BooksCategoryTile({super.key});

  @override
  State<BooksCategoryTile> createState() => _BooksCategoryTileState();
}

class _BooksCategoryTileState extends State<BooksCategoryTile> {
  // Book Categories
  List<String> categories = [
    "All",
    "Biography",
    "Fantasy",
    "Fiction",
    "History",
    "Mystery",
    "Non-Fiction",
    "Poetry",
    "Romance",
  ];

  //
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ListView.builder(
            itemCount: categories.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 5),
                child: FilterChip(
                  label: Text(
                    categories[index],
                    style: TextStyle(color: (selectedIndex == index) ? Colors.white : Colors.grey),
                  ),
                  selected: selectedIndex == index,
                  backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                  onSelected: (bool isSelected) {
                    setState(() {
                      selectedIndex = isSelected ? index : 0;
                    });
                  },
                  selectedColor: AppStyle.primaryColor,
                  checkmarkColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(
          height: 30,
        ),
        _booksCategorySection(),
        const SizedBox(
          height: 30,
        ),
      ],
    );
  }

  Widget _booksCategorySection() {
    return StreamBuilder(
      stream: selectedIndex == 0
          ? DatabaseService().booksStream()
          : DatabaseService().filterBooksStreamByCategory(categories[selectedIndex]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text(snapshot.error.toString()),
          );
        } else if (!snapshot.hasData) {
          return const Center(
            child: Text("No data to display!"),
          );
        } else {
          return GridView.builder(
            scrollDirection: Axis.vertical,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 10,
              childAspectRatio: 1 / 2,
              crossAxisSpacing: 20,
            ),
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookScreen(
                          bookId: snapshot.data![index]["id"],
                          bookName: snapshot.data![index]["name"],
                          author: snapshot.data![index]["author"],
                          imagePath: snapshot.data![index]["image_path"],
                          currentOwnerId: snapshot.data![index]["currentOwnerId"],
                        ),
                      ),
                    );
                    DatabaseService().setRecentlyVisitedBook(
                      snapshot.data![index]["id"],
                      snapshot.data![index]["name"],
                      snapshot.data![index]["author"],
                      snapshot.data![index]["image_path"],
                      snapshot.data![index]["currentOwnerId"],
                      snapshot.data![index]["category"],
                    );
                  },
                  child: _bookCard(snapshot.data![index]));
            },
          );
        }
      },
    );
  }

  // Book Card
  Widget _bookCard(Map<String, dynamic> bookData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: CachedNetworkImage(
            imageUrl: bookData["image_path"],
            placeholder: (context, url) => const SizedBox(
                width: 50, height: 50, child: Center(child: CircularProgressIndicator())),
            errorWidget: (context, url, error) => const Icon(Icons.error),
            width: 110,
            height: 140,
            fit: BoxFit.fill,
          ),
        ),
        Text(
          bookData["name"],
          style: const TextStyle(fontSize: 18),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          'By ${bookData["author"]}',
          style: const TextStyle(fontSize: 14, color: Colors.grey),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

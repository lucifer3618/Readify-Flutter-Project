import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:readify/features/book_screen/book_screen.dart';
import 'package:readify/services/database_service.dart';
import 'package:readify/shared/widgets/empty_data_page.dart';
import 'package:readify/utils/app_style.dart';
import 'package:skeletonizer/skeletonizer.dart';

class AddedBooksScreen extends StatelessWidget {
  const AddedBooksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Added Books",
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
          padding: AppStyle.pagePadding.add(const EdgeInsets.only(top: 20)),
          child: StreamBuilder(
            stream: DatabaseService().getAddedBooks(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text(snapshot.error.toString()),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const EmptyDataPage(
                  imgPath: "assets/images/empty-added-books.jpg",
                  title: "No Books Found!",
                  description:
                      "You haven't added any books yet. Share a book now and connect with fellow readers!",
                  wdithFactor: 0.7,
                );
              } else {
                return Skeletonizer(
                  enabled: snapshot.connectionState == ConnectionState.waiting,
                  child: GridView.builder(
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
                  ),
                );
              }
            },
          )),
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

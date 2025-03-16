import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:readify/features/book_screen/book_screen.dart';
import 'package:readify/services/database_service.dart';

class CustomSearchBar extends StatefulWidget {
  final FocusScopeNode searchFocusNode;
  const CustomSearchBar({super.key, required this.searchFocusNode});

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  // Initialize an search controller
  final SearchController controller = SearchController();

  List<Map<String, dynamic>> suggestions = [];

  @override
  void dispose() {
    widget.searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FocusScope(
      node: widget.searchFocusNode,
      child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.25),
                offset: Offset.zero,
                spreadRadius: 6,
                blurRadius: 10,
              ),
            ],
            borderRadius: BorderRadius.circular(10),
          ),
          child: SearchAnchor.bar(
            searchController: controller,
            isFullScreen: false,
            barBackgroundColor: const WidgetStatePropertyAll(Colors.white),
            barElevation: const WidgetStatePropertyAll(0),
            barShape: WidgetStatePropertyAll(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            viewBackgroundColor: Colors.white,
            viewConstraints: BoxConstraints(
                maxWidth: double.infinity - 40,
                maxHeight: MediaQuery.of(context).size.height * 0.4),
            viewElevation: 3,
            viewShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            barHintText: "Search",
            onChanged: (value) {
              DatabaseService().searchBooksStream(value).listen((data) {
                setState(() {
                  suggestions = data;
                });
              });
            },
            suggestionsBuilder: (context, controller) {
              return suggestions.map((suggestion) {
                return ListTile(
                  title: Text(suggestion["name"]),
                  trailing: const Icon(
                    FluentIcons.arrow_up_left_16_filled,
                    size: 18,
                    color: Colors.grey,
                  ),
                  onTap: () {
                    setState(
                      () {
                        controller.closeView("");
                        controller.clear();
                        FocusScope.of(context).unfocus();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookScreen(
                                bookId: suggestion["id"],
                                bookName: suggestion["name"],
                                author: suggestion["author"],
                                imagePath: suggestion["image_path"],
                                currentOwnerId: suggestion["currentOwnerId"]),
                          ),
                        );
                      },
                    );
                  },
                );
              }).toList();
            },
          )),
    );
  }
}

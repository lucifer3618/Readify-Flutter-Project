import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path/path.dart';
import 'package:readify/features/home_screen/data/category_data.dart';
import 'package:readify/features/home_screen/models/category_icon_model.dart';
import 'package:readify/features/home_screen/widgets/category_tile.dart';
import 'package:readify/services/database_service.dart';
import 'package:readify/services/helper_function.dart';
import 'package:readify/services/notification_service.dart';
import 'package:readify/shared/widgets/widgets.dart';
import 'package:readify/utils/app_style.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddBookForm extends StatefulWidget {
  const AddBookForm({super.key});

  @override
  State<AddBookForm> createState() => _AddBookFormState();
}

class _AddBookFormState extends State<AddBookForm> {
  // Variables
  File? image;

  // Book Category Data
  final List<CategoryIconModel> _categories = CategoryData.categoryData;
  final List<bool> isSelected = [
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
  ];

  // FormKeys
  final List<GlobalKey<FormState>> _formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
  ];

  // Validate each step
  bool _validateStep(int step) {
    switch (step) {
      case 0:
        return true;
      case 1:
        return _formKeys[0].currentState?.validate() ?? false;
      case 2:
        return _formKeys[1].currentState?.validate() ?? false;
      case 3:
        return _formKeys[2].currentState?.validate() ?? false;
      case 4:
        return true;
      default:
        return false;
    }
  }

  // Form values
  String isbn = "", name = "", author = "";

  // Check for loading
  bool _isLoading = false;

  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return FocusScope(
      node: FocusScopeNode(),
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.75,
          width: double.infinity,
          child: Scrollbar(
            interactive: true,
            thickness: 5,
            radius: const Radius.circular(10),
            thumbVisibility: true,
            child: SafeArea(
              child: Theme(
                data: ThemeData(
                    textTheme: GoogleFonts.lexendDecaTextTheme(Theme.of(context).textTheme),
                    scaffoldBackgroundColor: Colors.white,
                    primaryColor: AppStyle.primaryColor.withValues(alpha: 0.5),
                    colorScheme: ColorScheme.fromSeed(
                        seedColor: AppStyle.primaryColor.withValues(alpha: 0.5))),
                child: Scaffold(
                  appBar: AppBar(
                    title: Text(
                      "Add a Book",
                      style: GoogleFonts.aDLaMDisplay(
                          fontSize: 30, fontWeight: FontWeight.w900, color: AppStyle.primaryColor),
                    ),
                    actions: [
                      Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(
                            FluentIcons.arrow_exit_20_filled,
                            size: 30,
                            color: AppStyle.sunsetOrange,
                          ),
                        ),
                      )
                    ],
                    centerTitle: true,
                    automaticallyImplyLeading: false,
                    forceMaterialTransparency: true,
                  ),
                  body: _isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            color: Theme.of(context).primaryColor,
                            strokeWidth: 4,
                          ),
                        )
                      : SingleChildScrollView(
                          child: Column(
                            children: [
                              const SizedBox(
                                height: 10,
                              ),
                              Image.asset(
                                "assets/images/add-books.webp",
                                width: MediaQuery.of(context).size.width,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              const Padding(
                                padding: AppStyle.pagePadding,
                                child: Text(
                                  "Turn the pages of your story into someone else’s adventure—add your finished books here and let the magic of sharing begin on Readify!",
                                  style: TextStyle(color: AppStyle.subtextColor, fontSize: 16),
                                  textAlign: TextAlign.justify,
                                ),
                              ),
                              _stepperBookAppForm(context),
                            ],
                          ),
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Set Imagge
  setImage() async {
    await HelperFunction().pickImage().then(
      (value) async {
        if (value != null) {
          setState(() {
            image = value;
          });
        }
      },
    );
  }

  // Stepper form
  Widget _stepperBookAppForm(BuildContext context) {
    return Stepper(
      currentStep: _index,
      physics: const NeverScrollableScrollPhysics(),
      onStepCancel: () {
        if (_index > 0) {
          setState(() {
            _index -= 1;
          });
        } else if (_index == 0) {
          Navigator.pop(context);
        }
      },
      onStepContinue: () {
        if (_index < 4) {
          if (_validateStep(_index)) {
            setState(() {
              _index += 1;
            });
          }
        } else if (_index == 4) {
          addBookToApp(context);
        }
      },
      // onStepTapped: (value) {
      //   setState(() {
      //     _index = value;
      //   });
      // },
      connectorColor: const WidgetStatePropertyAll(AppStyle.primaryColor),
      elevation: 3,
      controlsBuilder: (BuildContext context, ControlsDetails controlsDetails) {
        return Padding(
          padding: const EdgeInsets.only(top: 15),
          child: Row(
            children: <Widget>[
              ElevatedButton(
                onPressed: controlsDetails.onStepContinue,
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                    backgroundColor: AppStyle.primaryColor.withValues(alpha: 0.7)),
                child: Text(
                  _index == 4 ? "Submit" : "Next",
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(width: 15),
              ElevatedButton(
                onPressed: controlsDetails.onStepCancel,
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                    backgroundColor: AppStyle.errorColor.withValues(alpha: 0.7)),
                child: const Text(
                  "Back",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
      steps: <Step>[
        Step(
          title: Text(
            "Add A Cover Image",
            style: TextStyle(
              fontWeight: _index == 0 ? FontWeight.bold : FontWeight.normal,
              color: _index == 0 ? Colors.teal : Colors.grey,
            ),
          ),
          content: GestureDetector(
            onTap: () {
              setImage();
            },
            child: Container(
              width: double.infinity,
              height: 100,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 230, 230, 230),
                borderRadius: BorderRadius.circular(20),
              ),
              child: (image != null)
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.file(
                        image!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : const Icon(
                      FluentIcons.camera_16_filled,
                      size: 50,
                      color: Colors.white,
                    ),
            ),
          ),
        ),
        Step(
          title: Text(
            "Give a name for the book",
            style: TextStyle(
              fontWeight: _index == 1 ? FontWeight.bold : FontWeight.normal,
              color: _index == 1 ? Colors.teal : Colors.grey,
            ),
          ),
          content: Form(
            key: _formKeys[0],
            child: Padding(
              padding: const EdgeInsets.only(top: 5),
              child: TextFormField(
                decoration: InputDecoration(
                    labelText: "Book Name",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                validator: (value) {
                  if (value!.isEmpty) {
                    return "This field is required!";
                  } else {
                    return null;
                  }
                },
                onChanged: (value) {
                  name = value;
                },
              ),
            ),
          ),
        ),
        Step(
          title: Text(
            "Who wrote your book?",
            style: TextStyle(
              fontWeight: _index == 2 ? FontWeight.bold : FontWeight.normal,
              color: _index == 2 ? Colors.teal : Colors.grey,
            ),
          ),
          content: Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Form(
              key: _formKeys[1],
              child: TextFormField(
                decoration: InputDecoration(
                    labelText: "Author",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                validator: (value) {
                  if (value!.isEmpty) {
                    return "This field is required!";
                  } else {
                    return null;
                  }
                },
                onChanged: (value) {
                  author = value;
                },
              ),
            ),
          ),
        ),
        Step(
          title: Text(
            "Provide the ISBN",
            style: TextStyle(
              fontWeight: _index == 3 ? FontWeight.bold : FontWeight.normal,
              color: _index == 3 ? Colors.teal : Colors.grey,
            ),
          ),
          content: Form(
            key: _formKeys[2],
            child: Padding(
              padding: const EdgeInsets.only(top: 5),
              child: TextFormField(
                decoration: InputDecoration(
                    labelText: "ISBN",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                validator: (value) {
                  if (value!.isEmpty) {
                    return "This field is required!";
                  } else {
                    return null;
                  }
                },
                onChanged: (value) {
                  isbn = value;
                },
              ),
            ),
          ),
        ),
        Step(
          title: Text(
            "Select a book category",
            style: TextStyle(
              fontWeight: _index == 4 ? FontWeight.bold : FontWeight.normal,
              color: _index == 4 ? Colors.teal : Colors.grey,
            ),
          ),
          content: SizedBox(
            height: 220,
            width: double.infinity,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 10 / 14,
              ),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                CategoryIconModel item = _categories[index];
                return CategoryTile(
                    isSelected: isSelected[index],
                    image: item.imagePath,
                    name: item.name,
                    onTap: () {
                      setState(() {
                        int indexValue = isSelected.indexWhere((element) => element == true);
                        if (indexValue != -1) {
                          isSelected[indexValue] = false;
                        }
                        isSelected[index] = !isSelected[index];
                      });
                    });
              },
            ),
          ),
        )
      ],
    );
  }

  // Add book to the app
  addBookToApp(BuildContext context) async {
    if (_formKeys[2].currentState!.validate() == true) {
      setState(() {
        _isLoading = true;
      });
      String bookId = HelperFunction().generateRandomBookId(10);

      if (isSelected.indexWhere(
                (element) => element == true,
              ) ==
              -1 &&
          mounted) {
        Widgets.showSnackbar(context, Colors.red, "Set a category");
      } else {
        String category = CategoryData
            .categoryData[isSelected.indexWhere(
          (element) => element == true,
        )]
            .name;
        String extention = extension(image!.path);
        await DatabaseService().uploadImageToSupaBase(image!, "uploads/$bookId$extention");
        String fileURL = Supabase.instance.client.storage
            .from("images")
            .getPublicUrl("uploads/$bookId$extention");
        await DatabaseService()
            .savingBookData(bookId, name, isbn.replaceAll("-", ""), author, fileURL, category)
            .then(
          (value) {
            if (value == true && mounted) {
              // ignore: use_build_context_synchronously
              Navigator.of(context).pop();
              // ignore: use_build_context_synchronously
              Widgets.showSnackbar(context, Colors.green, "Book entered");
              NotificationService().broadcastNotification(
                "New book added!",
                "${FirebaseAuth.instance.currentUser!.displayName!} has added $name for you to see.",
                "book",
                bookId,
              );
            }
          },
        );
      }
      setState(() {
        _isLoading = false;
      });
    }
  }
}

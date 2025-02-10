import 'dart:convert';
import 'dart:developer';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class WebService {
  Future<Map<String, dynamic>?> getBookData(String bookName, String authorName) async {
    try {
      // &key=${dotenv.env["GOOGLE_API_KEY"]}
      var url = Uri.parse(
          "https://www.googleapis.com/books/v1/volumes?q=intitle:${Uri.encodeQueryComponent(bookName)}&author=${Uri.encodeQueryComponent(authorName)}&printType=books");
      log(url.toString());
      final response = await http.get(url);
      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        return data["items"][0] as Map<String, dynamic>;
      } else {
        return null;
      }
    } catch (e) {
      log(e.toString());
      return null;
    }
  }
}

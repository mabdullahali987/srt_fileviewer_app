import 'package:translator/translator.dart';

class TranslationService {
  static final translator = GoogleTranslator();

  static Future<String> translateText(String text, String toLong) async {
    try {
      final translation = await translator
          .translate(
          text,
          to: toLong
      );

      return translation.text;
    } catch (e) {
      return "Translation Failed";
    }
  }
}
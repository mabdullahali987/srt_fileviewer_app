import 'package:translator/translator.dart';

class TranslationService {
  static final GoogleTranslator _translator = GoogleTranslator();

  static Future<String> translateText(String text, String toLang) async {
    try {
      if (text.trim().isEmpty) {
        return text;
      }

      final translation = await _translator.translate(text, to: toLang);

      return translation.text;
    } catch (e) {
      print("Translation error: $e");
      return "[Translation Error]";
    }
  }

  static Future<List<String>> translateBatch(
    List<String> texts,
    String toLang,
  ) async {
    final List<String> results = [];

    for (final text in texts) {
      final translated = await translateText(text, toLang);

      results.add(translated);
    }

    return results;
  }
}

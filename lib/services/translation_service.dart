import 'package:translator/translator.dart';

class TranslationService {
  static final _translator = GoogleTranslator();
  static const int _batchSize = 10;

  static Future<String> translateText(String text, String toLang) async {
    try {
      final translation = await _translator.translate(text, to: toLang);
      return translation.text;
    } catch (e) {
      return "Translation Error";
    }
  }

  static Future<List<String>> translateBatch(List<String> texts, String toLang) async {
    List<String> results = [];

    for (var i = 0; i < texts.length; i += _batchSize) {
  
      int end = (i + _batchSize < texts.length) ? i + _batchSize : texts.length;
      List<String> chunk = texts.sublist(i, end);

      String combinedText = chunk.join(' ||| ');

      try {
        final translation = await _translator.translate(combinedText, to: toLang);

        List<String> translatedChunk = translation.text.split(' ||| ');
        results.addAll(translatedChunk);
      } catch (e) {
        results.addAll(chunk.map((_) => "[Translation Error]"));
      }
    }
    return results;
  }
}

import '../models/subtitle_model.dart';

class FileParserService {
  static List<Subtitle> parseSrt(String content) {
    if (content.isEmpty) return [];

    final List<String> blocks = content
        .trim()
        .split(RegExp(r'(\r?\n){2,}'));

    final List<Subtitle> subtitles = [];

    for (var block in blocks) {
      final List<String> lines = block.trim().split(RegExp(r'\r?\n'));

      if (lines.length >= 3) {
        final index = int.tryParse(lines[0].trim()) ?? 0;
        final timeLine = lines[1];
        if (!timeLine.contains(' --> ')) continue;

        final times = timeLine.split(' --> ');
        if (times.length < 2) continue;

        String rawText = lines.sublist(2).join(' ').trim();
        String cleanedText = _stripHtmlTags(rawText);

        subtitles.add(
          Subtitle(
            index: index,
            startTime: times[0].trim(),
            endTime: times[1].trim(),
            text: cleanedText,
          ),
        );
      }
    }

    return subtitles;
  }

  static String _stripHtmlTags(String htmlString) {
    return htmlString
        .replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), '') 
        .replaceAll(RegExp(r'\s+'), ' ')    
        .trim();
  }
}

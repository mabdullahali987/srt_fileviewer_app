import '../models/subtitle_model.dart';

class FileParserService {
  static List<Subtitle> parseSrt(String content) {
    final blocks = content
        .trim()
        .split(
        RegExp(r'\r?\n\r?\n'
        )
    );
    List<Subtitle> subtitles = [];

    for (var block in blocks) {
      final lines = block.split('\n');
      if (lines.length >= 3) {
        final index = int.tryParse(lines[0]) ?? 0;
        final times = lines[1]
            .split(' --> ');
        final text = lines
            .sublist(2)
            .join(' ');
        subtitles.add(
            Subtitle(
                index,
                times[0],
                times[1],
                text)
        );
      }
    }

    return subtitles;
  }
}

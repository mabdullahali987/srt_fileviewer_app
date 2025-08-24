class SummarizerService {
  static String summarizeSubtitles(List<String> lines) {
    final allText = lines.join(' ');
    final words = allText.split(RegExp(r'\s+'));

    final freq = <String, int>{};
    for (var word in words) {
      if (word.length > 3){
        freq [word] = (freq[word] ?? 0) + 1;
      }
    }

    final topWords = freq.entries.toList()
      ..sort((a,b) => b.value
          .compareTo(a.value)
      );

    final keywords = topWords
        .take(5)
        .map((e) => e.key)
        .toList();

    final summary = lines
        .where((line) => keywords
        .any((word) => line
        .contains(word)))
        .take(5)
        .join('\n');

    return summary;
  }
}
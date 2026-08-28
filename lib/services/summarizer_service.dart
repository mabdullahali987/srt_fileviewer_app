class SummarizerService {
  static const Set<String> _stopWords = {
    'this', 'that', 'with', 'from', 'they', 'have', 'would', 'there', 'their',
    'what', 'about', 'which', 'when', 'make', 'like', 'just', 'know', 'think'
  };

  static String summarizeSubtitles(List<String> lines) {
    if (lines.isEmpty) return "No content to summarize.";

    final allText = lines.join(' ').toLowerCase();
    final words = allText.split(RegExp(r'\W+'));

    final freq = <String, int>{};
    for (var word in words) {
      if (word.length > 3 && !_stopWords.contains(word)) {
        freq[word] = (freq[word] ?? 0) + 1;
      }
    }

    final topKeywords = freq.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final keywords = topKeywords.take(5).map((e) => e.key).toSet();

    final lineScores = <String, int>{};
    for (var line in lines) {
      int score = 0;
      final lineWords = line.toLowerCase().split(RegExp(r'\W+'));
      for (var word in lineWords) {
        if (keywords.contains(word)) score++;
      }
      lineScores[line] = score;
    }

    final sortedLines = lineScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final bestLines = sortedLines
        .where((e) => e.value > 0) 
        .take(4)
        .map((e) => "• ${e.key.trim()}")
        .toList();

    return bestLines.isNotEmpty
        ? "Key Highlights:\n${bestLines.join('\n')}"
        : "Could not identify key highlights.";
  }
}

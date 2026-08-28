class ToneService {
  static const Map<String, List<String>> _emotionMap = {
    'Positive': [
      'love', 'happy', 'joy', 'great', 'awesome', 'amazing', 'good', 'thanks',
      'excited', 'wonderful', 'perfect', 'yes', 'smile', 'glad'
    ],
    'Angry': [
      'hate', 'angry', 'mad', 'kill', 'shut', 'stop', 'annoying', 'stupid',
      'worst', 'hell', 'crazy', 'disgusting', 'furious'
    ],
    'Sad': [
      'cry', 'sad', 'unhappy', 'sorry', 'miss', 'alone', 'depressed',
      'pain', 'hurt', 'lost', 'tears', 'goodbye'
    ],
    'Fear': [
      'fear', 'scared', 'afraid', 'panic', 'dark', 'run', 'hide', 'terror',
      'danger', 'worry', 'anxious', 'ghost'
    ],
    'Questioning': [
      'why', 'how', 'who', 'what', 'where', '?', 'really', 'perhaps'
    ],
  };

  static String detectTone(String text) {
    if (text.isEmpty) return "Neutral";

    final words = text.toLowerCase().split(RegExp(r'\W+'));
    final scores = <String, int>{};

    _emotionMap.keys.forEach((tone) => scores[tone] = 0);

    for (var word in words) {
      _emotionMap.forEach((tone, keywords) {
        if (keywords.contains(word)) {
          scores[tone] = (scores[tone] ?? 0) + 1;
        }
      });
    }

    var detectedTone = scores.entries.reduce((a, b) => a.value >= b.value ? a : b);

    return detectedTone.value > 0 ? detectedTone.key : "Neutral";
  }
}

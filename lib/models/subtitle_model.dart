class Subtitle {
  final int index;
  final String startTime;
  final String endTime;
  final String text;

  const Subtitle({
    required this.index,
    required this.startTime,
    required this.endTime,
    required this.text,
  });

  Subtitle copyWith({
    int? index,
    String? startTime,
    String? endTime,
    String? text,
  }) {
    return Subtitle(
      index: index ?? this.index,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      text: text ?? this.text,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'index': index,
      'startTime': startTime,
      'endTime': endTime,
      'text': text,
    };
  }

  factory Subtitle.fromJson(Map<String, dynamic> json) {
    return Subtitle(
      index: json['index'] as int,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      text: json['text'] as String,
    );
  }

  String get cleanText => text.trim().replaceAll(RegExp(r'\s+'), ' ');

  @override
  String toString() => '$index: $startTime -> $endTime | $text';
}

import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class HistoryEntry {
  final String filename;
  final String filePath;
  final String date;

  HistoryEntry({
    required this.filename,
    required this.filePath,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
    'filename': filename,
    'filePath': filePath,
    'date': date,
  };

  factory HistoryEntry.fromJson(Map<String, dynamic> json) => HistoryEntry(
    filename: json['filename'],
    filePath: json['filePath'],
    date: json['date'],
  );
}

class HistoryService {
  static const String _historyFileName = 'history.json';

  // Get the file to store history
  static Future<File> _getHistoryFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$_historyFileName';
    return File(filePath);
  }

  /// Add a new entry to history
  static Future<void> addToHistory(String filename, String filePath) async {
    final historyFile = await _getHistoryFile();
    List<HistoryEntry> entries = [];

    if (await historyFile.exists()) {
      final content = await historyFile.readAsString();
      entries = (jsonDecode(content) as List)
          .map((e) => HistoryEntry.fromJson(e))
          .toList();
    }

    final now = DateTime.now();
    final formattedDate = "${now.year}-"
        "${now.month
        .toString()
        .padLeft(2, '0')}-"
        "${now.day
        .toString()
        .padLeft(2, '0')}";

    final newEntry = HistoryEntry(
      filename: filename,
      filePath: filePath,
      date: formattedDate,
    );

    entries
        .removeWhere((entry) => entry
        .filePath == filePath);
    entries
        .insert(0, newEntry);

    await historyFile.writeAsString(jsonEncode(entries));
  }

  /// Retrieve all history entries
  static Future<List<HistoryEntry>> getHistory() async {
    final historyFile = await _getHistoryFile();

    if (!await historyFile.exists()) return [];

    final content = await historyFile.readAsString();
    final data = jsonDecode(content) as List;

    return data.map((e) => HistoryEntry.fromJson(e)).toList();
  }

  /// Clear history file
  static Future<void> clearHistory() async {
    final historyFile = await _getHistoryFile();
    if (await historyFile.exists()) {
      await historyFile.writeAsString(jsonEncode([]));
    }
  }
}

import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class HistoryEntry {
  final String filename;
  final String filePath;
  final String date;

  HistoryEntry({required this.filename, required this.filePath, required this.date});

  Map<String, dynamic> toJson() => {'filename': filename, 'filePath': filePath, 'date': date};

  factory HistoryEntry.fromJson(Map<String, dynamic> json) => HistoryEntry(
    filename: json['filename'] ?? 'Unknown',
    filePath: json['filePath'] ?? '',
    date: json['date'] ?? '',
  );
}

class HistoryService {
  static const String _historyFileName = 'history_v2.json';
  static const int _maxEntries = 50;

  static Future<File> _getHistoryFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_historyFileName');
  }

  static Future<void> addToHistory(String filePath, String filename) async {
    try {
      final entries = await getHistory();

      entries.removeWhere((entry) => entry.filePath == filePath);

      final newEntry = HistoryEntry(
        filename: filename,
        filePath: filePath,
        date: DateTime.now().toIso8601String().split('T')[0],
      );

      entries.insert(0, newEntry);

      if (entries.length > _maxEntries) entries.removeLast();

      final file = await _getHistoryFile();
      await file.writeAsString(jsonEncode(entries.map((e) => e.toJson()).toList()));
    } catch (e) {
      print("History Error: $e");
    }
  }

  static Future<List<HistoryEntry>> getHistory() async {
    try {
      final file = await _getHistoryFile();
      if (!await file.exists()) return [];

      final content = await file.readAsString();
      final List<dynamic> data = jsonDecode(content);
      return data.map((e) => HistoryEntry.fromJson(e)).toList();
    } catch (e) {
      return []; 
    }
  }

  static Future<void> deleteEntry(String filePath) async {
    final entries = await getHistory();
    entries.removeWhere((e) => e.filePath == filePath);
    final file = await _getHistoryFile();
    await file.writeAsString(jsonEncode(entries.map((e) => e.toJson()).toList()));
  }

  static Future<void> clearHistory() async {
    final file = await _getHistoryFile();
    if (await file.exists()) await file.delete();
  }
}

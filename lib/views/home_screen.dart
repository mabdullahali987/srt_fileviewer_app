import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../models/subtitle_model.dart';
import '../services/file_parser_service.dart';
import '../services/translation_service.dart';
import '../services/summarizer_service.dart';
import '../services/export_service.dart';
import '../services/history_service.dart';
import 'history_screen.dart';
import '../widgets/subtitle_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Subtitle> subtitles = [];
  String selectedLang = 'en';
  String summaryResult = '';
  bool isTranslating = false;
  String? currentFilename;

  List<String> languages = ['en', 'ur', 'es', 'fr', 'de', 'hi'];

  Future<void> pickSrtFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['srt'],
    );
    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final content = await file.readAsString();
      final parsed = FileParserService.parseSrt(content);
      final filename = result.files.single.name;

      setState(() {
        subtitles = parsed;
        currentFilename = filename;
        summaryResult = '';
      });

      await HistoryService.addToHistory(result.files.single.path!, filename);
    }
  }

  Future<void> translateAllSubtitles() async {
    setState(() => isTranslating = true);
    List<Subtitle> translatedSubs = [];
    for (var sub in subtitles) {
      final translatedText = await TranslationService.translateText(
        sub.text,
        selectedLang,
      );
      translatedSubs.add(
        Subtitle(sub.index, sub.startTime, sub.endTime, translatedText),
      );
    }
    setState(() {
      subtitles = translatedSubs;
      isTranslating = false;
    });
  }

  void summarize() {
    final lines = subtitles.map((e) => e.text).toList();
    final result = SummarizerService.summarizeSubtitles(lines);
    setState(() => summaryResult = result);
  }

  Future<void> exportToPdf() async {
    if (subtitles.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("No subtitles to export.")));
      return;
    }
    await ExportService.exportSubtitlesAsPdf(subtitles);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Exported successfully!")));
  }

  Future<void> openHistory() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const HistoryScreen()),
    );

    if (result != null && result is HistoryEntry) {
      final content = await File(result.filePath).readAsString();
      final parsed = FileParserService.parseSrt(content);
      setState(() {
        subtitles = parsed;
        currentFilename = result.filename;
        summaryResult = '';
      });
    }
  }

  Widget buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    Color? color,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: color ?? Colors.indigo,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      icon: Icon(icon, size: 20),
      label: Text(label),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasLoadedFile = subtitles.isNotEmpty;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "SRT File Viewer",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
        actions: [
          if (currentFilename != null)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  currentFilename!,
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              buildActionButton(
                icon: Icons.file_open,
                label: "Open .SRT File",
                onPressed: pickSrtFile,
                color: Colors.red,
              ),
              buildActionButton(
                icon: Icons.translate,
                label: "Translate",
                onPressed: hasLoadedFile ? translateAllSubtitles : null,
                color: Colors.red,
              ),
              buildActionButton(
                icon: Icons.summarize,
                label: "Summarize",
                onPressed: hasLoadedFile ? summarize : null,
                color: Colors.red,
              ),
              buildActionButton(
                icon: Icons.picture_as_pdf,
                label: "Export PDF",
                onPressed: hasLoadedFile ? exportToPdf : null,
                color: Colors.red,
              ),
              buildActionButton(
                icon: Icons.history,
                label: "View History",
                onPressed: openHistory,
                color: Colors.red,
              ),
              DropdownButton<String>(
                value: selectedLang,
                onChanged: (val) => setState(() => selectedLang = val!),
                items: languages
                    .map(
                      (lang) => DropdownMenuItem(
                        value: lang,
                        child: Text(lang.toLowerCase()),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
          const Divider(thickness: 1, height: 30),
          if (isTranslating)
            const Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          if (summaryResult.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 6,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Summary",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 39, 107, 12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      summaryResult,
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: hasLoadedFile
                ? ListView.builder(
                    itemCount: subtitles.length,
                    itemBuilder: (_, i) => SubtitleCard(subtitle: subtitles[i]),
                  )
                : const Center(
                    child: Padding(
                      padding: EdgeInsets.all(30.0),
                      child: Text(
                        "No subtitles loaded yet.\nPlease select a .SRT file to begin.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

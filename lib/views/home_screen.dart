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
  List<Subtitle> _subtitles = [];
  String _selectedLang = 'en';
  String _summaryResult = '';
  bool _isLoading = false;
  double _processingProgress = 0.0;
  String? _currentFilename;

  final List<String> _languages = ['en', 'ur', 'es', 'fr', 'de', 'hi'];

  // --- Logic Methods ---

  Future<void> _handleFileSelection() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['srt'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() => _isLoading = true);

        final file = File(result.files.single.path!);
        final content = await file.readAsString();
        final parsed = FileParserService.parseSrt(content);
        final filename = result.files.single.name;

        setState(() {
          _subtitles = parsed;
          _currentFilename = filename;
          _summaryResult = '';
        });

        await HistoryService.addToHistory(result.files.single.path!, filename);
      }
    } catch (e) {
      _showSnackBar("Failed to load SRT: $e", isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _translateAll() async {
    if (_subtitles.isEmpty) return;

    setState(() {
      _isLoading = true;
      _processingProgress = 0.0;
    });

    try {
      final List<String> originalTexts = _subtitles.map((s) => s.text).toList();

      final List<String> translatedTexts = await TranslationService.translateBatch(
        originalTexts,
        _selectedLang,
      );

      final List<Subtitle> translatedSubs = [];
      for (int i = 0; i < _subtitles.length; i++) {
        translatedSubs.add(_subtitles[i].copyWith(text: translatedTexts[i]));
        if (i % 5 == 0) {
          setState(() => _processingProgress = (i + 1) / _subtitles.length);
        }
      }

      setState(() {
        _subtitles = translatedSubs;
        _processingProgress = 1.0;
      });
      _showSnackBar("Translation complete!");
    } catch (e) {
      _showSnackBar("Translation error: $e", isError: true);
    } finally {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) setState(() => _isLoading = false);
      });
    }
  }

  void _generateSummary() {
    final lines = _subtitles.map((e) => e.text).toList();
    final result = SummarizerService.summarizeSubtitles(lines);
    setState(() => _summaryResult = result);
  }

  Future<void> _openHistory() async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const HistoryScreen())
    );

    if (result != null && result is HistoryEntry) {
      final file = File(result.filePath);
      if (await file.exists()) {
        final content = await file.readAsString();
        setState(() {
          _subtitles = FileParserService.parseSrt(content);
          _currentFilename = result.filename;
          _summaryResult = '';
        });
      } else {
        _showSnackBar("Original file missing", isError: true);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.indigo,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // --- UI Sections ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFD),
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              const SliverToBoxAdapter(child: SizedBox(height: 120)),

              SliverToBoxAdapter(child: _buildControlPanel()),

              if (_isLoading)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: LinearProgressIndicator(
                      value: _processingProgress > 0 ? _processingProgress : null,
                      borderRadius: BorderRadius.circular(10),
                      minHeight: 4,
                      backgroundColor: Colors.indigo.withOpacity(0.1),
                    ),
                  ),
                ),

              if (_summaryResult.isNotEmpty)
                SliverToBoxAdapter(child: _buildSummaryCard()),

              _subtitles.isEmpty
                  ? SliverFillRemaining(hasScrollBody: false, child: _buildEmptyState())
                  : SliverPadding(
                padding: const EdgeInsets.only(bottom: 40),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, i) => SubtitleCard(subtitle: _subtitles[i]),
                    childCount: _subtitles.length,
                  ),
                ),
              ),
            ],
          ),

          _buildFloatingHeader(),
        ],
      ),
    );
  }

  Widget _buildFloatingHeader() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.1))),
        ),
        padding: const EdgeInsets.only(top: 50, left: 20, right: 10),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _currentFilename != null ? "EDITOR MODE" : "SRT MATE",
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.indigo.shade300, letterSpacing: 1.5),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: Text(
                    _currentFilename ?? "No file loaded",
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1A1A1A)),
                  ),
                ),
              ],
            ),
            const Spacer(),
            IconButton(
              onPressed: _openHistory,
              icon: const Icon(Icons.history_rounded, color: Colors.black87),
            ),
            if (_subtitles.isNotEmpty)
              IconButton(
                onPressed: () => ExportService.exportSubtitlesAsPdf(_subtitles),
                icon: const Icon(Icons.picture_as_pdf_outlined, color: Colors.black87),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlPanel() {
    final bool hasData = _subtitles.isNotEmpty;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _actionTile(
                    Icons.add_circle_outline_rounded,
                    "Open File",
                    _handleFileSelection,
                    isPrimary: true
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _actionTile(
                    Icons.tips_and_updates_outlined,
                    "Summary",
                    hasData ? _generateSummary : null
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.translate_rounded, size: 20, color: Colors.indigo),
                const SizedBox(width: 12),
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedLang,
                    onChanged: (val) => setState(() => _selectedLang = val!),
                    items: _languages.map((l) => DropdownMenuItem(
                        value: l,
                        child: Text(l.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold))
                    )).toList(),
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: hasData ? _translateAll : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text("Translate"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionTile(IconData icon, String label, VoidCallback? onTap, {bool isPrimary = false}) {
    final bool enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isPrimary ? Colors.indigo : (enabled ? Colors.white : Colors.grey.shade50),
          borderRadius: BorderRadius.circular(20),
          border: isPrimary ? null : Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Icon(icon, color: isPrimary ? Colors.white : (enabled ? Colors.indigo : Colors.grey)),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: isPrimary ? Colors.white : (enabled ? Colors.black87 : Colors.grey))),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9C4).withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome_rounded, color: Colors.amber.shade800, size: 18),
              const SizedBox(width: 8),
              const Text("AI SUMMARY", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.2)),
            ],
          ),
          const SizedBox(height: 12),
          Text(_summaryResult, style: const TextStyle(fontSize: 15, height: 1.5, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open_rounded, size: 60, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text("Ready to analyze", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54)),
          const Text("Import an SRT file to start", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

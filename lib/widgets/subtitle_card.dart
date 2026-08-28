import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/subtitle_model.dart';
import '../services/tone_service.dart';
import '../services/translation_service.dart';

class SubtitleCard extends StatefulWidget {
  final Subtitle subtitle;

  const SubtitleCard({super.key, required this.subtitle});

  @override
  State<SubtitleCard> createState() => _SubtitleCardState();
}

class _SubtitleCardState extends State<SubtitleCard> {
  bool _isExpanded = false;
  String? _inlineTranslation;
  bool _isLoadingTranslation = false;

  Color _getToneColor(String tone) {
    switch (tone.toLowerCase()) {
      case 'positive': return Colors.teal;
      case 'negative': return Colors.blueGrey;
      case 'angry': return Colors.redAccent;
      case 'fear': return Colors.deepPurpleAccent;
      case 'questioning': return Colors.orange;
      default: return Colors.grey;
    }
  }

  Future<void> _translateSingleLine() async {
    setState(() => _isLoadingTranslation = true);
    final result = await TranslationService.translateText(widget.subtitle.text, 'ur'); // Defaulting to Spanish for example
    setState(() {
      _inlineTranslation = result;
      _isLoadingTranslation = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tone = ToneService.detectTone(widget.subtitle.text);
    final accentColor = _getToneColor(tone);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: accentColor.withOpacity(0.2)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(height: 4, color: accentColor),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(tone, accentColor),
                    const SizedBox(height: 12),

                    // Main Subtitle Text
                    Text(
                      widget.subtitle.text,
                      style: TextStyle(
                        fontSize: 17,
                        height: 1.5,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    // Inline Translation Section
                    if (_inlineTranslation != null) ...[
                      const Divider(height: 24),
                      Text(
                        _inlineTranslation!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          color: Colors.indigo,
                        ),
                      ),
                    ],

                    // Expandable Action Menu
                    if (_isExpanded) _buildActionMenu(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String tone, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            mainAxisSize: MainAxisSize.min, 
            children: [
              const Icon(Icons.access_time_rounded, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Flexible( 
                child: Text(
                  "${widget.subtitle.startTime} - ${widget.subtitle.endTime}",
                  overflow: TextOverflow.ellipsis, // Add ellipsis if it still overflows
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.blueGrey,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8), 
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            tone.toUpperCase(),
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: color
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionMenu() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _iconButton(Icons.copy, "Copy", () {
            Clipboard.setData(ClipboardData(text: widget.subtitle.text));
          }),
          const SizedBox(width: 8),
          _iconButton(
            _isLoadingTranslation ? Icons.hourglass_empty : Icons.translate,
            "Quick Translate",
            _translateSingleLine,
          ),
        ],
      ),
    );
  }

  Widget _iconButton(IconData icon, String tooltip, VoidCallback onTap) {
    return IconButton.filledTonal(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      tooltip: tooltip,
      style: IconButton.styleFrom(
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

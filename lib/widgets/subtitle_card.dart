import 'package:flutter/material.dart';
import '../models/subtitle_model.dart';
import '../services/tone_service.dart';

class SubtitleCard extends StatelessWidget {
  final Subtitle subtitle;

  const SubtitleCard({super.key, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final tone = ToneService.detectTone(subtitle.text);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${subtitle.startTime} ➝ ${subtitle.endTime}",
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey
                )
            ),
            const SizedBox(height: 5),
            Text(subtitle.text,
                style: const TextStyle(
                    fontSize: 16
                )
            ),
            const SizedBox(height: 5),
            Text("Tone: $tone",
                style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey
                )
            ),
          ],
        ),
      ),
    );
  }
}
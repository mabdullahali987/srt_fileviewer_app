import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/subtitle_model.dart';

class ExportService {
  static Future<void> exportSubtitlesAsPdf(List<Subtitle> subtitles) async {
    // Let the user pick a folder
    String? directoryPath = await FilePicker.platform.getDirectoryPath();

    if (directoryPath == null) {
      // User cancelled the folder selection
      return;
    }

    // Create a PDF document

    final pdf = pw.Document();
    final now = DateTime.now();
    final formatter = DateFormat('yyyy-MM-dd_HH-mm-ss');
    final fileName = 'SRT_Export_${formatter.format(now)}.pdf';

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Text('Subtitles Export', style: pw.TextStyle(fontSize: 20)),
          pw.SizedBox(height: 10),
          ...subtitles.map(
                (s) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('${s.index}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text('${s.startTime} --> ${s.endTime}'),
                pw.Text(s.text),
                pw.SizedBox(height: 10),
              ],
            ),
          )
        ],
      ),
    );

    final file = File('$directoryPath/$fileName');
    await file.writeAsBytes(await pdf.save());
  }
}

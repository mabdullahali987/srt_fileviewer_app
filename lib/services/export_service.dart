import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/subtitle_model.dart';
import '../services/tone_service.dart';

class ExportService {
  static Future<void> exportSubtitlesAsPdf(List<Subtitle> subtitles) async {
    String? directoryPath = await FilePicker.platform.getDirectoryPath();
    if (directoryPath == null) return;

    final pdf = pw.Document();
    final now = DateTime.now();
    final dateStr = DateFormat('MMMM dd, yyyy').format(now);
    final fileName = 'SRT_Transcript_${DateFormat('yyyyMMdd_HHmm').format(now)}.pdf';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        // Header that appears on every page
        header: (context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          margin: const pw.EdgeInsets.only(bottom: 20),
          child: pw.Text('Subtitle Transcript - $dateStr',
              style: pw.TextStyle(color: PdfColors.grey700, fontSize: 10)),
        ),
        // Footer with page numbers
        footer: (context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          margin: const pw.EdgeInsets.only(top: 20),
          child: pw.Text('Page ${context.pageNumber} of ${context.pagesCount}',
              style: pw.TextStyle(color: PdfColors.grey700, fontSize: 10)),
        ),
        build: (context) => [
          _buildTitleSection(subtitles.length),
          pw.SizedBox(height: 20),
          ...subtitles.asMap().entries.map((entry) {
            final index = entry.key;
            final s = entry.value;
            final tone = ToneService.detectTone(s.text);

            return _buildSubtitleRow(index, s, tone);
          }),
        ],
      ),
    );

    final file = File('$directoryPath/$fileName');
    await file.writeAsBytes(await pdf.save());
  }

  static pw.Widget _buildTitleSection(int count) {
    return pw.Header(
      level: 0,
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Subtitles Transcript',
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo)),
              pw.Text('Total entries: $count lines processed',
                  style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey600)),
            ],
          ),
          pw.PdfLogo(), 
        ],
      ),
    );
  }

  static pw.Widget _buildSubtitleRow(int i, Subtitle s, String tone) {
  
    final bgColor = i % 2 == 0 ? PdfColors.white : PdfColors.grey100;

    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        color: bgColor,
        border: const pw.Border(left: pw.BorderSide(color: PdfColors.indigo, width: 2)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('${s.startTime} --> ${s.endTime}',
                  style: pw.TextStyle(fontSize: 9, color: PdfColors.blueGrey700, fontWeight: pw.FontWeight.bold)),
              pw.Text(tone.toUpperCase(),
                  style: pw.TextStyle(fontSize: 8, color: PdfColors.indigo, fontWeight: pw.FontWeight.bold)),
            ],
          ),
          pw.SizedBox(height: 4),
          pw.Text(s.text, style: const pw.TextStyle(fontSize: 11, lineSpacing: 2)),
        ],
      ),
    );
  }
}

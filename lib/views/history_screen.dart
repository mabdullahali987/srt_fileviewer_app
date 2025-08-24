import 'package:flutter/material.dart';
import '../services/history_service.dart';
import 'dart:io';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<HistoryEntry> history = [];

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  Future<void> loadHistory() async {
    final entries = await HistoryService.getHistory();
    setState(() => history = entries);
  }

  String formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM d, yyyy – hh:mm a').format(date);
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "Subtitle History",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        elevation: 2,
        backgroundColor: Colors.red,
      ),
      body: history.isEmpty
          ? const Center(
              child: Text(
                "No history available.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final entry = history[index];
                final fileExists = File(entry.filePath).existsSync();

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      radius: 26,
                      backgroundColor: fileExists
                          ? Colors.green.shade100
                          : Colors.red.shade100,
                      child: Icon(
                        fileExists
                            ? Icons.check_circle
                            : Icons.warning_amber_rounded,
                        color: fileExists ? Colors.green : Colors.red,
                        size: 30,
                      ),
                    ),
                    title: Text(
                      entry.filename,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      "${formatDate(entry.date)} • ${fileExists ? 'Available' : 'Missing'}",
                      style: TextStyle(
                        color: fileExists
                            ? Colors.black54
                            : Colors.red.shade600,
                        fontSize: 13,
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    onTap: () {
                      if (fileExists) {
                        Navigator.pop(context, entry);
                      }
                    },
                  ),
                );
              },
            ),
    );
  }
}

import 'package:flutter/material.dart';
import '../services/history_service.dart';
import 'dart:io';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<HistoryEntry> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshHistory();
  }

  Future<void> _refreshHistory() async {
    final entries = await HistoryService.getHistory();
    setState(() {
      _history = entries;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Recent Files"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () => _confirmClearHistory(),
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _history.isEmpty
          ? _buildEmptyState()
          : _buildHistoryList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_toggle_off, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text("No recent files found", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    return ListView.builder(
      itemCount: _history.length,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) {
        final entry = _history[index];
        final exists = File(entry.filePath).existsSync();

        return Dismissible(
          key: Key(entry.filePath),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (_) => HistoryService.deleteEntry(entry.filePath),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: exists ? Colors.indigo.shade50 : Colors.red.shade50,
              child: Icon(
                exists ? Icons.description : Icons.error_outline,
                color: exists ? Colors.indigo : Colors.red,
              ),
            ),
            title: Text(entry.filename, style: TextStyle(
              fontWeight: FontWeight.bold,
              color: exists ? Colors.black87 : Colors.grey,
            )),
            subtitle: Text("${entry.date} • ${exists ? 'Available' : 'File Missing'}"),
            onTap: exists ? () => Navigator.pop(context, entry) : null,
          ),
        );
      },
    );
  }

  void _confirmClearHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Clear History?"),
        content: const Text("This will remove all recent file shortcuts."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
              onPressed: () async {
                await HistoryService.clearHistory();
                Navigator.pop(context);
                _refreshHistory();
              },
              child: const Text("Clear All", style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );
  }
}

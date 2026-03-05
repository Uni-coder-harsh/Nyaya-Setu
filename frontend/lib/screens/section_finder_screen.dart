import 'package:flutter/material.dart';

import '../services/mapping_service.dart';

class SectionFinderScreen extends StatefulWidget {
  const SectionFinderScreen({super.key});

  @override
  State<SectionFinderScreen> createState() => _SectionFinderScreenState();
}

class _SectionFinderScreenState extends State<SectionFinderScreen> {
  final TextEditingController _searchController = TextEditingController();
  Map<String, String>? _result;

  void _search(String value) {
    setState(() {
      _result = MappingService.getNewSection(value.trim());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: "Enter IPC Section (e.g., 420)",
              suffixIcon: IconButton(
                icon: const Icon(Icons.search),
                onPressed: () => _search(_searchController.text),
              ),
              border: const OutlineInputBorder(),
            ),
            keyboardType: TextInputType.text,
            onSubmitted: _search,
          ),
          const SizedBox(height: 20),
          if (_result != null)
            Card(
              color: Colors.orange[50],
              child: ListTile(
                title: Text(
                  "New Section: ${_result!['new']}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                subtitle: Text("${_result!['old']}\n\n${_result!['desc']}"),
                isThreeLine: true,
              ),
            )
          else if (_searchController.text.isNotEmpty)
            const Text("Section not found in local database."),
        ],
      ),
    );
  }
}

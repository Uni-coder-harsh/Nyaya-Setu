import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/pdf_service.dart';
import '../services/storage_service.dart';
import '../models/draft_document.dart';

class DraftScreen extends StatefulWidget {
  final String userProblem;
  const DraftScreen({super.key, required this.userProblem});

  @override
  State<DraftScreen> createState() => _DraftScreenState();
}

class _DraftScreenState extends State<DraftScreen> {
  DraftDocument? _document;
  final Map<String, TextEditingController> _controllers = {};
  bool _isGenerating = true;
  bool _showForm = true;

  @override
  void initState() {
    super.initState();
    _initDraft();
  }

  Future<void> _initDraft() async {
    try {
      final response = await ApiService.generateDraft(widget.userProblem, "Legal Complaint");
      final doc = DraftDocument.fromRaw(response.advice);
      
      // MNC Optimization: Pre-fill fields from local history
      for (var p in doc.placeholders) {
        final savedValue = await StorageService.getField(p);
        _controllers[p] = TextEditingController(text: savedValue ?? "");
      }

      setState(() {
        _document = doc;
        _isGenerating = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Future<void> _finalizeAndSync() async {
    // Sync identity fields to local storage for future use
    for (var entry in _controllers.entries) {
      if (StorageService.isIdentityField(entry.key) && entry.value.text.isNotEmpty) {
        await StorageService.saveField(entry.key, entry.value.text);
      }
    }
    setState(() => _showForm = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isGenerating) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Legal Drafter"),
        actions: [
          if (!_showForm) IconButton(icon: const Icon(Icons.edit), onPressed: () => setState(() => _showForm = true))
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _showForm ? _buildForm() : _buildPreview(),
      ),
    );
  }

  Widget _buildForm() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text("Verify Details", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const Text("Identity fields are saved automatically for next time.", 
            style: TextStyle(fontSize: 12, color: Colors.grey)),
          const Divider(),
          Expanded(
            child: ListView(
              children: _document!.placeholders.map((p) => Padding(
                padding: const EdgeInsets.only(top: 15),
                child: TextField(
                  controller: _controllers[p],
                  decoration: InputDecoration(
                    labelText: p.replaceAll('[', '').replaceAll(']', ''),
                    prefixIcon: StorageService.isIdentityField(p) ? const Icon(Icons.history, size: 16) : null,
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              )).toList(),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _finalizeAndSync,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text("Generate Final Document"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    final values = _controllers.map((key, value) => MapEntry(key, value.text));
    final finalContent = _document!.applyValues(values);
    
    final hindiPart = finalContent.split("English:")[0].replaceAll("Hindi:", "").trim();
    final englishPart = finalContent.contains("English:") ? finalContent.split("English:")[1].trim() : "";

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Expanded(child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[300]!)),
            child: SingleChildScrollView(child: Text(finalContent, style: const TextStyle(fontFamily: 'monospace'))),
          )),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: ActionButton(label: "Hindi PDF", color: Colors.redAccent, icon: Icons.picture_as_pdf, 
                  onTap: () => PdfService.generateLegalPdf(hindiPart, "Hindi"))),
              const SizedBox(width: 12),
              Expanded(child: ActionButton(label: "English PDF", color: Colors.blueAccent, icon: Icons.picture_as_pdf, 
                  onTap: () => PdfService.generateLegalPdf(englishPart, "English"))),
            ],
          ),
        ],
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;
  const ActionButton({super.key, required this.label, required this.color, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color, 
        foregroundColor: Colors.white, 
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
      ),
    );
  }
}
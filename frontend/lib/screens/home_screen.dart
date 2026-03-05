import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../models/legal_response.dart';
import '../services/api_service.dart';
import '../widgets/avatar_glow.dart';
import '../widgets/loading_indicator.dart'; // ✅ New Import
import 'draft_screen.dart';

class LegalHomePage extends StatefulWidget {
  const LegalHomePage({super.key});

  @override
  State<LegalHomePage> createState() => _LegalHomePageState();
}

class _LegalHomePageState extends State<LegalHomePage> {
  // --- NAVIGATION & HISTORY ---
  final List<Map<String, dynamic>> _chatHistory = [
    {"title": "New Chat", "messages": []},
  ];
  int _currentChatIndex = 0;

  // --- CONSULTATION STATE ---
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  bool _isListening = false;
  bool _isSpeaking = false;

  late stt.SpeechToText _speech;
  late FlutterTts _flutterTts;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _flutterTts = FlutterTts();
    _initTts();
  }

  void _initTts() async {
    try {
      await _flutterTts.setLanguage("hi-IN");
      await _flutterTts.setPitch(1.0);
      await _flutterTts.setSpeechRate(0.5);

      _flutterTts.setStartHandler(() => setState(() => _isSpeaking = true));
      _flutterTts.setCompletionHandler(
        () => setState(() => _isSpeaking = false),
      );
      _flutterTts.setCancelHandler(() => setState(() => _isSpeaking = false));
    } catch (e) {
      developer.log("TTS Initialization failed", error: e, name: 'LegalHome');
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ✅ NEW: Source Preview Bottom Sheet
  void _showSourcePreview(String sourceName) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.description, color: Colors.orange),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Source: $sourceName",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 10),
            const Text(
              "This information was retrieved from the official BNS knowledge base documents. Nyaya-Setu uses these verified PDFs to ensure legal accuracy.",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Integration logic for PDF viewer can be added here
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.open_in_new),
                label: const Text("View Full Document"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[800],
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- VOICE LOGIC ---
  Future<void> _listen() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      status = await Permission.microphone.request();
      if (!status.isGranted) return;
    }

    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) =>
              setState(() => _controller.text = val.recognizedWords),
          localeId: "hi_IN",
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  // --- BRAIN LOGIC ---
  Future<void> _sendMessage({String? editedText}) async {
    final text = editedText ?? _controller.text.trim();
    if (text.isEmpty) return;

    if (editedText == null) _controller.clear();

    setState(() {
      _isListening = false;
      _isLoading = true;
      _chatHistory[_currentChatIndex]['messages'].add({
        "role": "user",
        "text": text,
      });

      if (_chatHistory[_currentChatIndex]['messages'].length == 1) {
        _chatHistory[_currentChatIndex]['title'] = text.length > 20
            ? "${text.substring(0, 20)}..."
            : text;
      }
    });
    _scrollToBottom();

    try {
      final LegalResponse result = await ApiService.getLegalAdvice(text);

      setState(() {
        _chatHistory[_currentChatIndex]['messages'].add({
          "role": "ai",
          "text": result.advice,
          "citations": result.citations,
        });
        _isLoading = false;
      });
      _scrollToBottom();
      await _flutterTts.speak(result.advice);
    } catch (e) {
      setState(() {
        _chatHistory[_currentChatIndex]['messages'].add({
          "role": "ai",
          "text": "Error: $e",
        });
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  // --- UI COMPONENTS ---

  Widget _buildChatBubble(int index) {
    final msg = _chatHistory[_currentChatIndex]['messages'][index];
    bool isUser = msg['role'] == "user";

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            padding: const EdgeInsets.all(14),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.85,
            ),
            decoration: BoxDecoration(
              color: isUser ? Colors.orange[800] : Colors.grey[100],
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isUser ? 16 : 0),
                bottomRight: Radius.circular(isUser ? 0 : 16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MarkdownBody(
                  data: msg['text'],
                  styleSheet: MarkdownStyleSheet(
                    p: TextStyle(
                      color: isUser ? Colors.white : Colors.black87,
                      fontSize: 15,
                    ),
                  ),
                ),
                if (msg['citations'] != null &&
                    (msg['citations'] as List).isNotEmpty) ...[
                  const Divider(),
                  Wrap(
                    spacing: 6,
                    children: (msg['citations'] as List)
                        .map(
                          (cite) => ActionChip(
                            label: Text(
                              cite.toString(),
                              style: const TextStyle(fontSize: 10),
                            ),
                            avatar: const Icon(Icons.picture_as_pdf, size: 14),
                            visualDensity: VisualDensity.compact,
                            onPressed: () => _showSourcePreview(
                              cite.toString(),
                            ), // ✅ MNC-Grade Action
                          ),
                        )
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isUser)
                  IconButton(
                    icon: const Icon(
                      Icons.edit_note,
                      size: 18,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      _controller.text = msg['text'];
                      setState(() {
                        _chatHistory[_currentChatIndex]['messages'].removeRange(
                          index,
                          _chatHistory[_currentChatIndex]['messages'].length,
                        );
                      });
                    },
                  ),
                if (!isUser) ...[
                  IconButton(
                    icon: const Icon(Icons.copy, size: 16, color: Colors.grey),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: msg['text']));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Copied to clipboard")),
                      );
                    },
                  ),
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DraftScreen(userProblem: msg['text']),
                      ),
                    ),
                    child: const Text(
                      "Generate Draft",
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List messages = _chatHistory[_currentChatIndex]['messages'];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Nyaya-Setu 🇮🇳",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          if (_isSpeaking)
            IconButton(
              icon: const Icon(Icons.stop_circle, color: Colors.red),
              onPressed: () => _flutterTts.stop(),
            ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            const DrawerHeader(
              child: Center(
                child: Text(
                  "History",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.add_comment),
              title: const Text("Start New Chat"),
              onTap: () {
                setState(() {
                  _chatHistory.add({"title": "New Chat", "messages": []});
                  _currentChatIndex = _chatHistory.length - 1;
                });
                Navigator.pop(context);
              },
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: _chatHistory.length,
                itemBuilder: (context, index) => ListTile(
                  leading: const Icon(Icons.chat_bubble_outline),
                  title: Text(
                    _chatHistory[index]['title'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  selected: _currentChatIndex == index,
                  onTap: () {
                    setState(() => _currentChatIndex = index);
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? const Center(
                    child: Text(
                      "Ask me about BNS Laws",
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    itemCount:
                        messages.length +
                        (_isLoading ? 1 : 0), // ✅ Handle Skeleton
                    itemBuilder: (context, index) {
                      if (index == messages.length) {
                        return const NyayaLoadingIndicator(); // ✅ MNC-Grade Loading UI
                      }
                      return _buildChatBubble(index);
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                AvatarGlow(
                  animate: _isListening,
                  glowColor: Colors.red,
                  child: IconButton(
                    icon: Icon(
                      _isListening ? Icons.mic : Icons.mic_none,
                      color: _isListening ? Colors.red : Colors.blue,
                    ),
                    onPressed: _listen,
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Type your query...",
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.orange),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

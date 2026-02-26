import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // For .env
import 'package:flutter_tts/flutter_tts.dart'; // For Mouth
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart'; // For Permissions
import 'package:speech_to_text/speech_to_text.dart' as stt; // For Ears

// --- 1. SETUP MAIN ---
Future<void> main() async {
  // Ensure Flutter bindings are initialized before loading .env
  WidgetsFlutterBinding.ensureInitialized();

  // Load the .env file
  await dotenv.load(fileName: ".env");

  runApp(const NyayaSetuApp());
}

class NyayaSetuApp extends StatelessWidget {
  const NyayaSetuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nyaya-Setu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      home: const LegalHomePage(),
    );
  }
}

class LegalHomePage extends StatefulWidget {
  const LegalHomePage({super.key});

  @override
  State<LegalHomePage> createState() => _LegalHomePageState();
}

class _LegalHomePageState extends State<LegalHomePage> {
  // --- STATE VARIABLES ---
  final TextEditingController _controller = TextEditingController();
  String _legalAdvice = "";
  bool _isLoading = false;
  bool _isListening = false;

  // --- PLUGINS ---
  late stt.SpeechToText _speech;
  late FlutterTts _flutterTts;

  // --- GET URL FROM .ENV ---
  // If .env fails, it defaults to empty string to prevent crash
  final String _apiUrl = dotenv.env['API_URL'] ?? '';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _flutterTts = FlutterTts();
    _initTts();
  }

  // Initialize Text-to-Speech settings
  void _initTts() async {
    await _flutterTts.setLanguage("hi-IN"); // Hindi India
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.5); // Slower speed for clarity
  }

  // --- VOICE INPUT (EARS) ---
  Future<void> _listen() async {
    if (!_isListening) {
      // Check Permission
      var status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) return;

      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );

      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) {
            setState(() {
              _controller.text = val.recognizedWords;
            });
          },
          localeId: "hi_IN", // Listen for Hindi/English mix
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  // --- API CALL (BRAIN) ---
  Future<void> _getAdvice() async {
    if (_controller.text.isEmpty) return;

    // Safety check for URL
    if (_apiUrl.isEmpty) {
      setState(() => _legalAdvice = "Error: API_URL not found in .env file!");
      return;
    }

    FocusScope.of(context).unfocus();
    _speech.stop();

    setState(() {
      _isLoading = true;
      _isListening = false;
      _legalAdvice = "";
    });

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"text": _controller.text}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _legalAdvice = data['legal_advice'] ?? "No advice received.";
        });

        // Auto-speak result (Hybrid Edge-Cloud Strategy)
        _speakAdvice(_legalAdvice);
      } else {
        setState(() => _legalAdvice = "Server Error: ${response.statusCode}");
      }
    } catch (e) {
      setState(() => _legalAdvice = "Connection Error: Check internet.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // --- VOICE OUTPUT (MOUTH) ---
  Future<void> _speakAdvice(String text) async {
    await _flutterTts.speak(text);
  }

  Future<void> _stopSpeaking() async {
    await _flutterTts.stop();
  }

  // --- UI BUILD ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nyaya-Setu 🇮🇳"),
        backgroundColor: Colors.orange[100],
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_off),
            onPressed: _stopSpeaking,
            tooltip: "Stop Speaking",
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AvatarGlow(
        animate: _isListening,
        glowColor: Colors.red,
        child: FloatingActionButton(
          onPressed: _listen,
          backgroundColor: _isListening ? Colors.red : Colors.blue,
          child: Icon(
            _isListening ? Icons.mic : Icons.mic_none,
            size: 30,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _controller,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: "Speak or Type your problem...",
                  border: OutlineInputBorder(),
                  hintText:
                      "Example: My landlord is refusing to return my deposit...",
                  suffixIcon: Icon(Icons.edit),
                ),
              ),
              const SizedBox(height: 15),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _getAdvice,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                icon: _isLoading
                    ? const SizedBox.shrink()
                    : const Icon(Icons.gavel),
                label: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        "Get Legal Advice",
                        style: TextStyle(fontSize: 18),
                      ),
              ),
              const SizedBox(height: 20),
              if (_legalAdvice.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "AI Legal Advice:",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.volume_up, color: Colors.blue),
                      onPressed: () => _speakAdvice(_legalAdvice),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Text(
                    _legalAdvice,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// Simple Glow Animation Widget for Mic
class AvatarGlow extends StatelessWidget {
  final bool animate;
  final Color glowColor;
  final Widget child;
  const AvatarGlow({
    super.key,
    required this.animate,
    required this.glowColor,
    required this.child,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: animate
          ? BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: glowColor.withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            )
          : null,
      child: child,
    );
  }
}

import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatMessage {
  final String role;
  final String text;
  final String? imageBase64;
  final String? pdfText;
  final String? fileName;
  final DateTime timestamp;

  ChatMessage({
    required this.role,
    required this.text,
    this.imageBase64,
    this.pdfText,
    this.fileName,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'role': role,
    'text': text,
    'imageBase64': imageBase64,
    'pdfText': pdfText,
    'fileName': fileName,
    'timestamp': timestamp.toIso8601String(),
  };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    role: json['role'],
    text: json['text'],
    imageBase64: json['imageBase64'],
    pdfText: json['pdfText'],
    fileName: json['fileName'],
    timestamp: DateTime.parse(json['timestamp']),
  );
}

class ChatAiScreen extends StatefulWidget {
  final String userName; // Pass from login/profile
  const ChatAiScreen({super.key, this.userName = 'Nikhil'});

  @override
  State<ChatAiScreen> createState() => _ChatAiScreenState();
}

class _ChatAiScreenState extends State<ChatAiScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _showGreeting = true;

  // Attachment
  File? _selectedImage;
  String? _selectedImageBase64;
  String? _selectedPdfText;
  String? _selectedFileName;

  // Image limit
  static const int _dailyImageLimit = 5;
  int _imagesTodayCount = 0;
  String _todayKey = '';

  static const String _apiKey =
      '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';
  static const String _apiUrl =
      'https://api.groq.com/openai/v1/chat/completions';
  static const String _textModel = 'llama-3.3-70b-versatile';
  static const String _visionModel =
      'meta-llama/llama-4-scout-17b-16e-instruct';

  @override
  void initState() {
    super.initState();
    _todayKey = _getTodayKey();
    _loadHistory();
    _loadImageCount();
  }

  String _getTodayKey() {
    final now = DateTime.now();
    return 'img_count_${now.year}_${now.month}_${now.day}';
  }

  // ─── Load / Save History ─────────────────────────────────────
  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString('chat_history_${widget.userName}');
    if (historyJson != null) {
      final List decoded = jsonDecode(historyJson);
      setState(() {
        _messages = decoded.map((e) => ChatMessage.fromJson(e)).toList();
        _showGreeting = _messages.isEmpty;
      });
      _scrollToBottom();
    }
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_messages.map((m) => m.toJson()).toList());
    await prefs.setString('chat_history_${widget.userName}', encoded);
  }

  Future<void> _clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('chat_history_${widget.userName}');
    setState(() {
      _messages = [];
      _showGreeting = true;
    });
  }

  // ─── Image Daily Limit ───────────────────────────────────────
  Future<void> _loadImageCount() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _imagesTodayCount = prefs.getInt(_todayKey) ?? 0;
    });
  }

  Future<void> _incrementImageCount() async {
    final prefs = await SharedPreferences.getInstance();
    _imagesTodayCount++;
    await prefs.setInt(_todayKey, _imagesTodayCount);
  }

  bool get _isImageLimitReached => _imagesTodayCount >= _dailyImageLimit;
  int get _imagesRemaining => _dailyImageLimit - _imagesTodayCount;

  // ─── Greeting ────────────────────────────────────────────────
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return '🌅 Good Morning, ${widget.userName}!';
    if (hour >= 12 && hour < 17) return '☀️ Good Afternoon, ${widget.userName}!';
    if (hour >= 17 && hour < 21) return '🌆 Good Evening, ${widget.userName}!';
    return '🌙 Good Night, ${widget.userName}!';
  }

  String _getGreetingSubtitle() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'Hope you have a wonderful day ahead!';
    if (hour >= 12 && hour < 17) return 'How\'s your day going?';
    if (hour >= 17 && hour < 21) return 'Hope your evening is going well!';
    return 'Working late? I\'m here to help!';
  }

  // ─── Pick Image ──────────────────────────────────────────────
  Future<void> _pickFromCamera() async {
    Navigator.pop(context);
    if (_isImageLimitReached) {
      _showLimitDialog();
      return;
    }
    final picker = ImagePicker();
    final XFile? photo =
    await picker.pickImage(source: ImageSource.camera, imageQuality: 80);
    if (photo != null) await _processImage(File(photo.path), photo.name);
  }

  Future<void> _pickFromGallery() async {
    Navigator.pop(context);
    if (_isImageLimitReached) {
      _showLimitDialog();
      return;
    }
    final picker = ImagePicker();
    // Single image only
    final XFile? image =
    await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (image != null) await _processImage(File(image.path), image.name);
  }

  Future<void> _processImage(File file, String name) async {
    final bytes = await file.readAsBytes();
    final base64Str = base64Encode(bytes);
    setState(() {
      _selectedImage = file;
      _selectedImageBase64 = base64Str;
      _selectedPdfText = null;
      _selectedFileName = name;
    });
  }

  void _showLimitDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.lock_outline, color: Color(0xFFFF4A4A)),
            SizedBox(width: 8),
            Text('Daily Limit Reached',
                style: TextStyle(color: Colors.white, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Aapne aaj ki 5 image limit use kar li hai.',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF7B2FFF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: const Color(0xFF7B2FFF).withOpacity(0.4)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('🚀 Premium Plan mein upgrade karo:',
                      style: TextStyle(
                          color: Color(0xFF7B2FFF),
                          fontWeight: FontWeight.bold,
                          fontSize: 13)),
                  SizedBox(height: 6),
                  Text('• Unlimited image analysis',
                      style:
                      TextStyle(color: Colors.white70, fontSize: 12)),
                  Text('• Priority responses',
                      style:
                      TextStyle(color: Colors.white70, fontSize: 12)),
                  Text('• Advanced features',
                      style:
                      TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Baad mein',
                style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7B2FFF),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(context);
              // TODO: Navigate to payment screen
              _showSnack('Payment screen coming soon!');
            },
            child: const Text('Upgrade karo',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ─── Pick PDF ────────────────────────────────────────────────
  Future<void> _pickPDF() async {
    Navigator.pop(context);
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final fileName = result.files.single.name;
      try {
        final bytes = await file.readAsBytes();
        final PdfDocument doc = PdfDocument(inputBytes: bytes);
        final extractor = PdfTextExtractor(doc);
        String text = '';
        for (int i = 0; i < doc.pages.count; i++) {
          text += extractor.extractText(startPageIndex: i) + '\n';
        }
        doc.dispose();
        setState(() {
          _selectedPdfText = text.trim();
          _selectedImage = null;
          _selectedImageBase64 = null;
          _selectedFileName = fileName;
        });
        _showSnack('PDF ready: $fileName');
      } catch (e) {
        _showSnack('PDF error: $e');
      }
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  void _clearAttachment() {
    setState(() {
      _selectedImage = null;
      _selectedImageBase64 = null;
      _selectedPdfText = null;
      _selectedFileName = null;
    });
  }

  // ─── Attachment Sheet ────────────────────────────────────────
  void _showAttachmentSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 16),
            const Text('Attachment bhejo',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            // Image limit indicator
            const SizedBox(height: 8),
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _isImageLimitReached
                    ? const Color(0xFFFF4A4A).withOpacity(0.1)
                    : const Color(0xFF4CAF50).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _isImageLimitReached
                    ? '🔒 Aaj ki image limit khatam (5/5)'
                    : '📸 Aaj ${_imagesRemaining} image baaki hain',
                style: TextStyle(
                  color: _isImageLimitReached
                      ? const Color(0xFFFF4A4A)
                      : const Color(0xFF4CAF50),
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _attachOption(
                  icon: Icons.camera_alt_rounded,
                  label: 'Camera',
                  color: _isImageLimitReached
                      ? Colors.grey
                      : const Color(0xFF7B2FFF),
                  onTap: _pickFromCamera,
                ),
                _attachOption(
                  icon: Icons.photo_library_rounded,
                  label: 'Gallery',
                  color: _isImageLimitReached
                      ? Colors.grey
                      : const Color(0xFF4A90FF),
                  onTap: _pickFromGallery,
                ),
                _attachOption(
                  icon: Icons.picture_as_pdf_rounded,
                  label: 'PDF',
                  color: const Color(0xFFFF4A4A),
                  onTap: _pickPDF,
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _attachOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.5)),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 13)),
        ],
      ),
    );
  }

  // ─── Send Message ────────────────────────────────────────────
  Future<void> _sendMessage() async {
    final userText = _controller.text.trim();
    final hasImage = _selectedImage != null;
    final hasPdf = _selectedPdfText != null;
    if (userText.isEmpty && !hasImage && !hasPdf) return;
    if (_isLoading) return;

    final imageBase64 = _selectedImageBase64;
    final pdfText = _selectedPdfText;
    final fileName = _selectedFileName;
    final question = userText.isNotEmpty
        ? userText
        : (hasImage ? 'Is image ko analyze karo' : 'Is PDF ka summary do');

    setState(() {
      _showGreeting = false;
      _messages.add(ChatMessage(
        role: 'user',
        text: question,
        imageBase64: imageBase64,
        pdfText: pdfText,
        fileName: fileName,
      ));
      _isLoading = true;
      _selectedImage = null;
      _selectedImageBase64 = null;
      _selectedPdfText = null;
      _selectedFileName = null;
    });
    _controller.clear();
    _scrollToBottom();

    // Increment image count if image was sent
    if (hasImage) await _incrementImageCount();

    try {
      String aiReply = '';
      if (hasImage && imageBase64 != null) {
        aiReply = await _sendImageMessage(imageBase64, question);
      } else if (hasPdf && pdfText != null) {
        aiReply = await _sendPdfMessage(pdfText, question);
      } else {
        aiReply = await _sendTextMessage(question);
      }
      setState(() {
        _messages.add(ChatMessage(role: 'assistant', text: aiReply));
      });
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
            role: 'assistant', text: '❌ Error: $e'));
      });
    } finally {
      setState(() => _isLoading = false);
      _scrollToBottom();
      await _saveHistory(); // Save after every message
    }
  }

  Future<String> _sendTextMessage(String text) async {
    final history = _messages
        .where((m) => m.imageBase64 == null && m.pdfText == null)
        .map((m) => {'role': m.role, 'content': m.text})
        .toList();

    final res = await http.post(
      Uri.parse(_apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode({
        'model': _textModel,
        'messages': [
          {
            'role': 'system',
            'content':
            'You are a helpful AI assistant. User\'s name is ${widget.userName}. Be friendly and helpful. Use markdown when needed.'
          },
          ...history,
        ],
        'temperature': 0.7,
        'max_tokens': 1024,
      }),
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body)['choices'][0]['message']['content'];
    }
    throw Exception('Error ${res.statusCode}');
  }

  Future<String> _sendImageMessage(String base64Image, String question) async {
    // Detect mime type from base64 header (default jpeg)
    final mimeType = 'image/jpeg';
    final res = await http.post(
      Uri.parse(_apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode({
        'model': _visionModel,
        'messages': [
          {
            'role': 'system',
            'content':
            'You are a helpful vision AI. User\'s name is ${widget.userName}. Analyze images carefully.'
          },
          {
            'role': 'user',
            'content': [
              {
                'type': 'image_url',
                'image_url': {
                  'url': 'data:$mimeType;base64,$base64Image'
                },
              },
              {'type': 'text', 'text': question},
            ],
          }
        ],
        'temperature': 0.7,
        'max_tokens': 1024,
      }),
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body)['choices'][0]['message']['content'];
    }
    throw Exception('Image Error ${res.statusCode}: ${res.body}');
  }

  Future<String> _sendPdfMessage(String pdfText, String question) async {
    final limited = pdfText.length > 6000
        ? pdfText.substring(0, 6000) + '...'
        : pdfText;
    final res = await http.post(
      Uri.parse(_apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode({
        'model': _textModel,
        'messages': [
          {
            'role': 'system',
            'content':
            'You are a helpful AI assistant. User\'s name is ${widget.userName}. Answer based on PDF content. Use markdown.'
          },
          {
            'role': 'user',
            'content': 'PDF Content:\n\n$limited\n\n---\nSawaal: $question',
          }
        ],
        'temperature': 0.5,
        'max_tokens': 1500,
      }),
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body)['choices'][0]['message']['content'];
    }
    throw Exception('PDF Error ${res.statusCode}');
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

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ─── BUILD ────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            // User avatar
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFF7B2FFF),
              child: Text(
                widget.userName.isNotEmpty
                    ? widget.userName[0].toUpperCase()
                    : 'U',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.userName, // User name in AppBar
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF4CAF50))),
                    const SizedBox(width: 4),
                    const Text('AI Assistant',
                        style: TextStyle(
                            color: Color(0xFF9E9E9E), fontSize: 11)),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Image limit badge
          if (!_isImageLimitReached)
            Container(
              margin: const EdgeInsets.only(right: 4),
              padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.image_outlined,
                      color: Color(0xFF4CAF50), size: 14),
                  const SizedBox(width: 3),
                  Text(
                    '${_imagesRemaining}/5',
                    style: const TextStyle(
                        color: Color(0xFF4CAF50), fontSize: 12),
                  ),
                ],
              ),
            )
          else
            GestureDetector(
              onTap: _showLimitDialog,
              child: Container(
                margin: const EdgeInsets.only(right: 4),
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF4A4A).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.lock_outline,
                        color: Color(0xFFFF4A4A), size: 14),
                    SizedBox(width: 3),
                    Text('0/5',
                        style: TextStyle(
                            color: Color(0xFFFF4A4A), fontSize: 12)),
                  ],
                ),
              ),
            ),
          // Clear history button
          IconButton(
            icon: const Icon(Icons.delete_outline,
                color: Colors.white54, size: 20),
            onPressed: () => _showClearHistoryDialog(),
            tooltip: 'History clear karo',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _showGreeting && _messages.isEmpty
                ? _buildGreetingView()
                : ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isLoading) {
                  return _buildTypingIndicator();
                }
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),
          if (_selectedImage != null || _selectedPdfText != null)
            _buildAttachmentPreview(),
          _buildInputBar(),
        ],
      ),
    );
  }

  void _showClearHistoryDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2E),
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('History Delete?',
            style: TextStyle(color: Colors.white)),
        content: const Text('Saari chat history permanently delete ho jayegi.',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF4A4A),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(context);
              _clearHistory();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentPreview() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 4, 12, 0),
      padding:
      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(12),
        border:
        Border.all(color: const Color(0xFF7B2FFF).withOpacity(0.4)),
      ),
      child: Row(
        children: [
          if (_selectedImage != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(_selectedImage!,
                  width: 48, height: 48, fit: BoxFit.cover),
            )
          else
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFFF4A4A).withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.picture_as_pdf_rounded,
                  color: Color(0xFFFF4A4A), size: 28),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _selectedFileName ?? 'File selected',
              style: const TextStyle(color: Colors.white70, fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white54, size: 18),
            onPressed: _clearAttachment,
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    final isUser = msg.role == 'user';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
        isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser)
            Container(
              width: 32, height: 32,
              margin: const EdgeInsets.only(right: 8),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                    colors: [Color(0xFF7B2FFF), Color(0xFF4A90FF)]),
              ),
              child: const Icon(Icons.auto_awesome,
                  color: Colors.white, size: 16),
            ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 10),
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.72),
              decoration: BoxDecoration(
                gradient: isUser
                    ? const LinearGradient(
                    colors: [Color(0xFF7B2FFF), Color(0xFF5B4FFF)])
                    : null,
                color: isUser ? null : const Color(0xFF1E1E2E),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image in bubble
                  if (msg.imageBase64 != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.memory(
                        base64Decode(msg.imageBase64!),
                        width: double.infinity,
                        height: 180,
                        fit: BoxFit.cover,
                      ),
                    ),
                    if (msg.text.isNotEmpty) const SizedBox(height: 8),
                  ],
                  // PDF badge
                  if (msg.pdfText != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color:
                        const Color(0xFFFF4A4A).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.picture_as_pdf_rounded,
                              color: Color(0xFFFF4A4A), size: 16),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              msg.fileName ?? 'PDF',
                              style: const TextStyle(
                                  color: Color(0xFFFF4A4A),
                                  fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (msg.text.isNotEmpty) const SizedBox(height: 8),
                  ],
                  if (msg.text.isNotEmpty)
                    isUser
                        ? Text(msg.text,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 15))
                        : MarkdownBody(
                      data: msg.text,
                      styleSheet: MarkdownStyleSheet(
                        p: const TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                            height: 1.5),
                        strong: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                        code: const TextStyle(
                          color: Color(0xFF4A90FF),
                          backgroundColor: Color(0xFF0D0D0D),
                          fontFamily: 'monospace',
                          fontSize: 13,
                        ),
                        codeblockDecoration: BoxDecoration(
                          color: const Color(0xFF0D0D0D),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        h1: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                        h2: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                        h3: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                        listBullet: const TextStyle(
                            color: Colors.white70),
                      ),
                    ),
                  // Timestamp
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(msg.timestamp),
                    style: const TextStyle(
                        color: Colors.white30, fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
          if (isUser)
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFF2A2A3E),
              child: Text(
                widget.userName.isNotEmpty
                    ? widget.userName[0].toUpperCase()
                    : 'U',
                style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 32, height: 32,
            margin: const EdgeInsets.only(right: 8),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                  colors: [Color(0xFF7B2FFF), Color(0xFF4A90FF)]),
            ),
            child: const Icon(Icons.auto_awesome,
                color: Colors.white, size: 16),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E2E),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Row(
              children: [
                _DotAnimation(delay: 0),
                SizedBox(width: 4),
                _DotAnimation(delay: 200),
                SizedBox(width: 4),
                _DotAnimation(delay: 400),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A2E),
        border: Border(
            top: BorderSide(color: Color(0xFF2A2A3E), width: 1)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            GestureDetector(
              onTap: _showAttachmentSheet,
              child: Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A3E),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: const Color(0xFF7B2FFF).withOpacity(0.4)),
                ),
                child: const Icon(Icons.attach_file_rounded,
                    color: Color(0xFF7B2FFF), size: 20),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF0D0D1A),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                      color: const Color(0xFF7B2FFF).withOpacity(0.4)),
                ),
                child: TextField(
                  controller: _controller,
                  minLines: 1,
                  maxLines: 4,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 15),
                  cursorColor: const Color(0xFF7B2FFF),
                  decoration: const InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle: TextStyle(color: Color(0xFF5A5A7A)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: 18, vertical: 12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _sendMessage,
              child: Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                      colors: [Color(0xFF7B2FFF), Color(0xFF4A90FF)]),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7B2FFF).withOpacity(0.5),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: _isLoading
                    ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2),
                )
                    : const Icon(Icons.send_rounded,
                    color: Colors.white, size: 22),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGreetingView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                    colors: [Color(0xFF7B2FFF), Color(0xFF4A90FF)]),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7B2FFF).withOpacity(0.4),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(Icons.auto_awesome,
                  color: Colors.white, size: 48),
            ),
            const SizedBox(height: 24),
            Text(
              _getGreeting(),
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              _getGreetingSubtitle(),
              style: const TextStyle(
                  color: Color(0xFF9E9E9E), fontSize: 15),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            const Text(
              'How can I help you today?',
              style: TextStyle(
                  color: Color(0xFF7B2FFF),
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                _buildSuggestionChip('💡 Give me an idea'),
                _buildSuggestionChip('📝 Write something'),
                _buildSuggestionChip('🔍 Explain a topic'),
                _buildSuggestionChip('💻 Help with code'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionChip(String label) {
    return GestureDetector(
      onTap: () {
        _controller.text = label.substring(3);
        _sendMessage();
      },
      child: Container(
        padding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E2E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: const Color(0xFF7B2FFF).withOpacity(0.5)),
        ),
        child: Text(label,
            style:
            const TextStyle(color: Colors.white70, fontSize: 13)),
      ),
    );
  }
}

class _DotAnimation extends StatefulWidget {
  final int delay;
  const _DotAnimation({required this.delay});

  @override
  State<_DotAnimation> createState() => _DotAnimationState();
}

class _DotAnimationState extends State<_DotAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.repeat(reverse: true);
    });
    _anim = Tween<double>(begin: 0.3, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: 8, height: 8,
        decoration: const BoxDecoration(
            shape: BoxShape.circle, color: Color(0xFF7B2FFF)),
      ),
    );
  }
}
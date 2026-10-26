// lib/screens/chatbot_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

// ─────────────────────────────────────────────────────────────────────────────
// LANGUAGE CONFIG
// ─────────────────────────────────────────────────────────────────────────────

const _kLanguageLabels = {'en': 'EN', 'hi': 'HI', 'gu': 'GU'};

const _kGreeting = {
  'en': '👋 Hi! I\'m your Smart Khata assistant.\nHow can I help you today?',
  'hi': '👋 नमस्ते! मैं आपका Smart Khata सहायक हूँ।\nमैं आपकी कैसे मदद कर सकता हूँ?',
  'gu': '👋 નમસ્તે! હું તમારો Smart Khata સહાયક છું.\nહું તમારી કેવી રીતે મદદ કરી શકું?',
};

const _kQuickReplies = {
  'en': ['📦 Track order', '💰 Check payment', '📊 Stock status', '🧾 View bill'],
  'hi': ['📦 ऑर्डर ट्रैक करें', '💰 भुगतान जांचें', '📊 स्टॉक स्थिति', '🧾 बिल देखें'],
  'gu': ['📦 ઓર્ડર ટ્રૅક કરો', '💰 ચુકવણી તપાસો', '📊 સ્ટોક સ્થિતિ', '🧾 બિલ જુઓ'],
};

const _kLangSwitchNotice = {
  'en': '🌐 Switched to English',
  'hi': '🌐 हिंदी में बदला गया',
  'gu': '🌐 ગુજરાતીમાં બદલ્યું',
};

// ─────────────────────────────────────────────────────────────────────────────
// MESSAGE MODEL
// ─────────────────────────────────────────────────────────────────────────────

enum _Sender { bot, user }

class _ChatMessage {
  final String text;
  final _Sender sender;
  final bool isTyping;

  const _ChatMessage({
    required this.text,
    required this.sender,
    this.isTyping = false,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class ChatbotScreen extends StatefulWidget {
  final String userId;
  final String businessType;

  const ChatbotScreen({
    super.key,
    required this.userId,
    required this.businessType,
  });

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  String _lang = 'en';
  bool _showQuickReplies = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _messages.add(_ChatMessage(
      text: _kGreeting[_lang]!,
      sender: _Sender.bot,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
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

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> _sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _isLoading) return;

    _controller.clear();
    setState(() {
      _showQuickReplies = false;
      _messages.add(_ChatMessage(text: trimmed, sender: _Sender.user));
      _messages.add(_ChatMessage(text: '', sender: _Sender.bot, isTyping: true));
      _isLoading = true;
    });
    _scrollToBottom();

    try {
      final token = await _getToken();
      final res = await http.post(
        Uri.parse(ApiConfig.chatbot()),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'token': token,
        },
        body: jsonEncode({
          'message': trimmed,
          'lang': _lang,
          'businessType': widget.businessType,
        }),
      );

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final reply = data['reply'] as String? ??
          (res.statusCode == 200
              ? 'Something went wrong. Please try again.'
              : data['message'] as String? ?? 'Server error.');

      setState(() {
        _messages.removeLast(); // remove typing indicator
        _messages.add(_ChatMessage(text: reply, sender: _Sender.bot));
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _messages.removeLast();
        _messages.add(_ChatMessage(
          text: '⚠️ Network error. Please check your connection.',
          sender: _Sender.bot,
        ));
        _isLoading = false;
      });
    }
    _scrollToBottom();
  }

  void _switchLang(String lang) {
    if (lang == _lang) return;
    setState(() {
      _lang = lang;
      _messages.add(_ChatMessage(
        text: _kLangSwitchNotice[lang]!,
        sender: _Sender.bot,
      ));
    });
    _scrollToBottom();
  }

  // ── build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8F9FF),
      appBar: AppBar(
        backgroundColor: const Color(0xff1a1a2e),
        foregroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Center(
                  child: Text('🤖', style: TextStyle(fontSize: 17))),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Smart Assistant',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                Text('Always here to help',
                    style: TextStyle(fontSize: 10, color: Colors.white60)),
              ],
            ),
          ],
        ),
        actions: [
          // Language switcher
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: _kLanguageLabels.entries.map((e) {
                final active = _lang == e.key;
                return GestureDetector(
                  onTap: () => _switchLang(e.key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: active
                          ? const Color(0xff6D5DF6)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      e.value,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: active
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── messages ───────────────────────────────────────────────────────
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(14),
              itemCount: _messages.length +
                  (_showQuickReplies && _messages.length == 1 ? 1 : 0),
              itemBuilder: (_, i) {
                // quick replies row after greeting
                if (_showQuickReplies && i == 1) {
                  return _QuickReplies(
                    replies: _kQuickReplies[_lang]!,
                    onTap: _sendMessage,
                  );
                }
                final msg = _messages[_showQuickReplies && i > 1 ? i - 1 : i];
                return _MessageBubble(message: msg);
              },
            ),
          ),

          // ── input ──────────────────────────────────────────────────────────
          Container(
            color: Colors.white,
            padding: EdgeInsets.only(
              left: 12,
              right: 12,
              top: 10,
              bottom: MediaQuery.of(context).viewInsets.bottom + 10,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textInputAction: TextInputAction.send,
                    onSubmitted: _sendMessage,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle:
                          const TextStyle(color: Colors.black38, fontSize: 13),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(22),
                        borderSide:
                            const BorderSide(color: Color(0xffE0E0E0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(22),
                        borderSide:
                            const BorderSide(color: Color(0xffE0E0E0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(22),
                        borderSide: const BorderSide(
                            color: Color(0xff6D5DF6), width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _sendMessage(_controller.text),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: _isLoading
                          ? Colors.grey.shade300
                          : const Color(0xff6D5DF6),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.send_rounded,
                      color: _isLoading ? Colors.grey : Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MESSAGE BUBBLE
// ─────────────────────────────────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  final _ChatMessage message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isBot = message.sender == _Sender.bot;

    return Align(
      alignment: isBot ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.78),
        padding: message.isTyping
            ? const EdgeInsets.symmetric(horizontal: 14, vertical: 12)
            : const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: isBot ? Colors.white : const Color(0xff4f46e5),
          border: isBot
              ? Border.all(color: const Color(0xffE8E8F0))
              : null,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: Radius.circular(isBot ? 4 : 12),
            bottomRight: Radius.circular(isBot ? 12 : 4),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: message.isTyping
            ? const _TypingIndicator()
            : Text(
                message.text,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: isBot ? const Color(0xff1a1a2e) : Colors.white,
                ),
              ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TYPING INDICATOR — 3 bouncing dots
// ─────────────────────────────────────────────────────────────────────────────

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
          3, (i) => _BouncingDot(delay: Duration(milliseconds: i * 150))),
    );
  }
}

class _BouncingDot extends StatefulWidget {
  final Duration delay;

  const _BouncingDot({required this.delay});

  @override
  State<_BouncingDot> createState() => _BouncingDotState();
}

class _BouncingDotState extends State<_BouncingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _anim = Tween<double>(begin: 0, end: -5).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Transform.translate(
          offset: Offset(0, _anim.value),
          child: Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Color(0xffB0B0C0),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// QUICK REPLIES
// ─────────────────────────────────────────────────────────────────────────────

class _QuickReplies extends StatelessWidget {
  final List<String> replies;
  final void Function(String) onTap;

  const _QuickReplies({required this.replies, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: replies
            .map((r) => GestureDetector(
                  onTap: () => onTap(r),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: const Color(0xffD8D8F0)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      r,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xff4f46e5),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }
}
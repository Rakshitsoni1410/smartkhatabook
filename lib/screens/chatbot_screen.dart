import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

// ─────────────────────────────────────────────────────────────────────────
// Language config
// ─────────────────────────────────────────────────────────────────────────
const Map<String, String> kLanguageLabels = {
  'en': 'EN',
  'hi': 'हिं',
  'gu': 'ગુજ',
};

const Map<String, String> kGreeting = {
  'en':
      'Hey! 👋 I\'m the SmartKhataBook assistant. Ask me about Stock, Orders, Employees, Reviews, or your Account.',
  'hi':
      'नमस्ते! 👋 मैं SmartKhataBook सहायक हूं। स्टॉक, ऑर्डर, कर्मचारी, समीक्षा या खाते के बारे में पूछें।',
  'gu':
      'નમસ્તે! 👋 હું SmartKhataBook સહાયક છું. સ્ટોક, ઓર્ડર, કર્મચારી, રિવ્યુ અથવા એકાઉન્ટ વિશે પૂછો.',
};

const Map<String, List<String>> kQuickReplies = {
  'en': [
    'How do I add stock?',
    'How do I pay an employee?',
    'How do I track an order?',
    'How do I reply to a review?',
  ],
  'hi': [
    'स्टॉक कैसे जोड़ें?',
    'कर्मचारी को भुगतान कैसे करें?',
    'ऑर्डर कैसे ट्रैक करें?',
    'समीक्षा का जवाब कैसे दें?',
  ],
  'gu': [
    'સ્ટોક કેવી રીતે ઉમેરવો?',
    'કર્મચારીને ચુકવણી કેવી રીતે કરવી?',
    'ઓર્ડર કેવી રીતે ટ્રેક કરવો?',
    'રિવ્યુનો જવાબ કેવી રીતે આપવો?',
  ],
};

const Map<String, String> kLangSwitchNotice = {
  'en': 'Switched to English ✅',
  'hi': 'हिंदी में बदल दिया गया ✅',
  'gu': 'ગુજરાતીમાં બદલાયું ✅',
};

const Map<String, String> kSystemPrompts = {
  'en':
      'You are a helpful business assistant for SmartKhataBook — a digital ledger app for small businesses in India. Help with Stock, Orders, Employees, Reviews, Ledger, and Account questions. Keep answers short and practical. Only help with SmartKhataBook-related questions.',
  'hi':
      'आप SmartKhataBook के लिए एक सहायक हैं — भारत में छोटे व्यवसायों के लिए एक डिजिटल खाता ऐप। स्टॉक, ऑर्डर, कर्मचारी, समीक्षा, लेजर और खाते के सवालों में मदद करें। जवाब छोटे और व्यावहारिक रखें।',
  'gu':
      'તમે SmartKhataBook માટે સહાયક છો — ભારતમાં નાના વ્યવસાયો માટે ડિજિટલ ખાતા એપ. સ્ટોક, ઓર્ડર, કર્મચારી, રિવ્યુ, લેજર અને એકાઉન્ટ પ્રશ્નોમાં મદદ કરો. જવાબ ટૂંકા અને વ્યવહારુ રાખો.',
};

// ─────────────────────────────────────────────────────────────────────────
// Message model
// ─────────────────────────────────────────────────────────────────────────
class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage({required this.text, required this.isUser});
}

// ─────────────────────────────────────────────────────────────────────────
// Chatbot Screen — full screen on mobile
// ─────────────────────────────────────────────────────────────────────────
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
  String _lang = 'en';
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<ChatMessage> _messages = [];
  bool _isTyping = false;
  bool _quickRepliesShown = true;

  static const Color kPrimary = Color(0xff6D5DF6);
  static const Color kDark = Color(0xff1a1a2e);
  static const Color kBg = Color(0xffF8F9FF);

  @override
  void initState() {
    super.initState();
    _messages = [ChatMessage(text: kGreeting[_lang]!, isUser: false)];
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: trimmed, isUser: true));
      _isTyping = true;
      _quickRepliesShown = false;
    });
    _controller.clear();
    _scrollToBottom();

    try {
      final base = dotenv.env['BASE_URL'] ?? '';
      final uri = Uri.parse('$base/chatbot/chat');

      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'message': trimmed,
              'lang': _lang,
              'businessType': widget.businessType,
            }),
          )
          .timeout(const Duration(seconds: 30));

      final data = jsonDecode(response.body);

      setState(() {
        _isTyping = false;
        _messages.add(
          ChatMessage(
            text: (data['success'] == true)
                ? data['reply']
                : (data['message'] ?? 'Something went wrong. Try again.'),
            isUser: false,
          ),
        );
      });
    } catch (e) {
      setState(() {
        _isTyping = false;
        _messages.add(
          ChatMessage(
            text: 'Connection error. Please try again.',
            isUser: false,
          ),
        );
      });
    }

    _scrollToBottom();
  }

  void _switchLang(String code) {
    if (code == _lang) return;
    setState(() {
      _lang = code;
      _messages.add(ChatMessage(text: kLangSwitchNotice[code]!, isUser: false));
    });
    _scrollToBottom();
  }

  // ── Typing indicator dots ──
  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(14),
            topRight: Radius.circular(14),
            bottomRight: Radius.circular(14),
            bottomLeft: Radius.circular(4),
          ),
          border: Border.all(color: const Color(0xffE8E8F0)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            return _BouncingDot(delay: Duration(milliseconds: i * 150));
          }),
        ),
      ),
    );
  }

  // ── Single message bubble ──
  Widget _buildBubble(ChatMessage msg) {
    final isUser = msg.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
        decoration: BoxDecoration(
          color: isUser ? kPrimary : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(isUser ? 14 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 14),
          ),
          border: isUser ? null : Border.all(color: const Color(0xffE8E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          msg.text,
          style: TextStyle(
            fontSize: 13,
            color: isUser ? Colors.white : const Color(0xff1a1a2e),
            height: 1.5,
          ),
        ),
      ),
    );
  }

  // ── Quick reply chips ──
  Widget _buildQuickReplies() {
    final replies = kQuickReplies[_lang] ?? kQuickReplies['en']!;
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: replies.map((q) {
        return GestureDetector(
          onTap: () => _send(q),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xffD8D8F0)),
            ),
            child: Text(
              q,
              style: const TextStyle(
                fontSize: 11,
                color: kPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Language switcher ──
  Widget _buildLangSwitcher() {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: kLanguageLabels.entries.map((e) {
          final isActive = e.key == _lang;
          return GestureDetector(
            onTap: () => _switchLang(e.key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: isActive ? kPrimary : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                e.value,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isActive
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.65),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,

      // ── Header ──
      appBar: AppBar(
        backgroundColor: kDark,
        foregroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
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
                child: Text('📒', style: TextStyle(fontSize: 17)),
              ),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SmartKhataBook Assistant',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
                Text(
                  'App help only • AI powered',
                  style: TextStyle(fontSize: 10, color: Colors.white60),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _buildLangSwitcher(),
          ),
        ],
      ),

      // ── Messages ──
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(14),
              itemCount:
                  _messages.length +
                  (_isTyping ? 1 : 0) +
                  (_quickRepliesShown && _messages.length == 1 ? 1 : 0),
              itemBuilder: (_, index) {
                // Quick replies after first greeting
                if (_quickRepliesShown && _messages.length == 1 && index == 1) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _buildQuickReplies(),
                  );
                }

                // Typing indicator at end
                if (_isTyping &&
                    index ==
                        _messages.length +
                            (_quickRepliesShown && _messages.length == 1
                                ? 1
                                : 0)) {
                  return _buildTypingIndicator();
                }

                return _buildBubble(_messages[index]);
              },
            ),
          ),

          // ── Input row ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xffF0F0F0))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onSubmitted: _send,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Ask about stock, orders, employees...',
                      hintStyle: const TextStyle(
                        fontSize: 12.5,
                        color: Colors.grey,
                      ),
                      filled: true,
                      fillColor: kBg,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: kPrimary),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _send(_controller.text),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: const BoxDecoration(
                      color: kPrimary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 17,
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

// ─────────────────────────────────────────────────────────────────────────
// Bouncing dot widget for typing indicator
// ─────────────────────────────────────────────────────────────────────────
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
      duration: const Duration(milliseconds: 1100),
    );
    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.repeat(reverse: true);
    });
    _anim = Tween(
      begin: 0.0,
      end: -5.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
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
      builder: (_, __) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        transform: Matrix4.translationValues(0, _anim.value, 0),
        width: 7,
        height: 7,
        decoration: const BoxDecoration(
          color: Color(0xffB0B0C0),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

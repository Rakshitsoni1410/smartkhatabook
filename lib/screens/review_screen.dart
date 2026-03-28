import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/user_role.dart';

class ReviewScreen extends StatefulWidget {
  final UserRole userRole;
  final String shopName;
  final String businessType;
  final String userId;

  const ReviewScreen({
    super.key,
    required this.userRole,
    required this.userId,
    this.shopName = '',
    this.businessType = '',
  });

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  bool _isLoading = true;
  bool _isSubmitting = false;
  List<Map<String, dynamic>> _reviews = [];

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  String get _baseUrl => dotenv.env['BASE_URL'] ?? '';

  String get _displayShopName {
    return widget.shopName.trim().isEmpty
        ? widget.userRole.label
        : widget.shopName.trim();
  }

  String get _displayBusinessType {
    return widget.businessType.trim().isEmpty
        ? 'General'
        : widget.businessType.trim();
  }

  int get _reviewCount => _reviews.length;

  int get _replyCount => _reviews.where(_hasReply).length;

  int get _positiveReviewCount {
    return _reviews.where((review) {
      final rating = (review['rating'] as num?)?.toInt() ?? 0;
      return rating >= 4;
    }).length;
  }

  double get _averageRating {
    if (_reviews.isEmpty) return 0;

    final total = _reviews.fold<double>(
      0,
      (sum, review) => sum + ((review['rating'] as num?)?.toDouble() ?? 0),
    );

    return total / _reviews.length;
  }

  dynamic _decodeResponseBody(String body) {
    final trimmed = body.trim();
    if (trimmed.isEmpty) return const <String, dynamic>{};

    try {
      return jsonDecode(trimmed);
    } catch (_) {
      return {'message': trimmed};
    }
  }

  String _extractMessage(dynamic data, String fallback) {
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    if (data is String && data.trim().isNotEmpty) {
      return data.trim();
    }
    return fallback;
  }

  bool _hasReply(Map<String, dynamic> review) {
    final reply = review['reply'];
    if (reply is! Map) return false;

    final text = reply['text']?.toString().trim() ?? '';
    return text.isNotEmpty;
  }

  String _initialsFor(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  Color _ratingColor(int rating) {
    if (rating >= 4) return const Color(0xFF15803D);
    if (rating >= 3) return const Color(0xFFF59E0B);
    return const Color(0xFFDC2626);
  }

  String _formatDate(String? raw) {
    if (raw == null || raw.trim().isEmpty) return '';

    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return '';

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final local = parsed.toLocal();
    return '${local.day} ${months[local.month - 1]} ${local.year}';
  }

  Future<List<Map<String, dynamic>>> _fetchWholesalers() async {
    final uri = Uri.parse('$_baseUrl/user/wholesalers/${widget.businessType}');

    final res = await http.get(uri);

    if (res.statusCode != 200) {
      throw Exception("Failed to load wholesalers");
    }

    final data = jsonDecode(res.body);
    return List<Map<String, dynamic>>.from(data['users']);
  }

  Future<void> _runSubmission(
    Future<void> Function() action, {
    required String successMessage,
  }) async {
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      await action();

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(successMessage)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _loadReviews() async {
    if (mounted) {
      setState(() => _isLoading = true);
    }

    try {
      if (_baseUrl.isEmpty) {
        throw Exception('BASE_URL is missing in .env');
      }

      final uri = Uri.parse('$_baseUrl/reviews/${widget.userId}');
      final response = await http.get(uri).timeout(const Duration(seconds: 20));
      final data = _decodeResponseBody(response.body);

      if (response.statusCode == 200) {
        List<dynamic> rawList = [];

        if (data is List) {
          rawList = data;
        } else if (data is Map && data['reviews'] is List) {
          rawList = data['reviews'] as List<dynamic>;
        }

        if (!mounted) return;
        setState(() {
          _reviews = rawList.map((e) {
            final map = Map<String, dynamic>.from(e as Map);
            map['reply'] ??= <String, dynamic>{};
            return map;
          }).toList();
        });
      } else {
        throw Exception(_extractMessage(data, 'Failed to load reviews'));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Reviews load failed: $e')));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _submitReview({
    required String reviewer,
    required String comment,
    required double rating,
    required String targetUserId,
  }) async {
    if (_baseUrl.isEmpty) {
      throw Exception('BASE_URL is missing in .env');
    }

    // ✅ ADD THIS BLOCK HERE
    if (widget.userRole != UserRole.retailer) {
      throw Exception("Only Retailer can add review");
    }

    final uri = Uri.parse('$_baseUrl/reviews/add');

    final response = await http
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'targetUserId': targetUserId,
            'author': reviewer,
            'comment': comment,
            'rating': rating.round(),
            'shopName': widget.shopName,
            'businessType': widget.businessType,
            'role': widget.userRole.label,
          }),
        )
        .timeout(const Duration(seconds: 20));

    final data = _decodeResponseBody(response.body);

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception(_extractMessage(data, 'Failed to save review'));
    }
  }

  Future<void> _replyToReview(String reviewId, String text) async {
    if (_baseUrl.isEmpty) {
      throw Exception('BASE_URL is missing in .env');
    }

    final uri = Uri.parse('$_baseUrl/reviews/reply/$reviewId');
    final response = await http
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'text': text,
            'role': widget.userRole.label,
            'businessType': widget.businessType,
          }),
        )
        .timeout(const Duration(seconds: 20));

    final data = _decodeResponseBody(response.body);

    if (response.statusCode != 200) {
      throw Exception(_extractMessage(data, 'Failed to post reply'));
    }
  }

  Future<void> _openAddReviewSheet() async {
    List<Map<String, dynamic>> wholesalers = [];

    try {
      wholesalers = await _fetchWholesalers();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to load wholesalers")));
      return;
    }

    Map<String, dynamic>? selectedWholesaler = wholesalers.isNotEmpty
        ? wholesalers.first
        : null;

    final reviewData = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddReviewSheetWithWholesaler(
        wholesalers: wholesalers,
        selectedWholesaler: selectedWholesaler,
      ),
    );

    if (!mounted || reviewData == null) return;

    final wholesalerId = reviewData['wholesalerId'];

    await _runSubmission(() async {
      await _submitReview(
        reviewer: widget.shopName,
        comment: reviewData['comment'],
        rating: reviewData['rating'],
        targetUserId: wholesalerId, // 🔥 IMPORTANT
      );
      await _loadReviews();
    }, successMessage: 'Review added successfully');
  }

  Future<void> _openReplyDialog(String reviewId) async {
    final controller = TextEditingController();

    try {
      final text = await showDialog<String>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Reply to review'),
            content: TextField(
              controller: controller,
              minLines: 3,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Write your reply...',
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, controller.text.trim()),
                child: const Text('Send'),
              ),
            ],
          );
        },
      );

      if (text == null || text.isEmpty) return;

      await _runSubmission(() async {
        await _replyToReview(reviewId, text);
        await _loadReviews();
      }, successMessage: 'Reply posted successfully');
    } finally {
      controller.dispose();
    }
  }

  Widget _buildStarRow(int rating, {double size = 18}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
        (index) => Padding(
          padding: const EdgeInsets.only(right: 2),
          child: Icon(
            index < rating ? Icons.star_rounded : Icons.star_border_rounded,
            color: Colors.amber,
            size: size,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF0EA5E9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 54,
                width: 54,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.reviews_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _displayShopName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$_displayBusinessType business reviews',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.12)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _averageRating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      _buildStarRow(_averageRating.round().clamp(0, 5).toInt()),
                      const SizedBox(height: 8),
                      Text(
                        _reviewCount == 0
                            ? 'No ratings yet'
                            : 'Based on $_reviewCount review${_reviewCount == 1 ? '' : 's'}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  children: [
                    _HeaderStatTile(
                      icon: Icons.rate_review_outlined,
                      label: 'Reviews',
                      value: '$_reviewCount',
                    ),
                    const SizedBox(height: 12),
                    _HeaderStatTile(
                      icon: Icons.thumb_up_alt_outlined,
                      label: 'Positive',
                      value: '$_positiveReviewCount',
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.mark_chat_read_outlined,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Business replies: $_replyCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 68,
            width: 68,
            decoration: BoxDecoration(
              color: const Color(0xFFDBEAFE),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.reviews_outlined,
              color: Color(0xFF2563EB),
              size: 30,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No reviews yet',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'Start the conversation and collect your first customer impression.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          ElevatedButton.icon(
            onPressed: (widget.userRole == UserRole.retailer && !_isSubmitting)
                ? _openAddReviewSheet
                : null,
            icon: const Icon(Icons.add_comment_outlined),
            label: const Text('Write first review'),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(BuildContext context, Map<String, dynamic> review) {
    final author = (review['author']?.toString().trim().isNotEmpty ?? false)
        ? review['author'].toString().trim()
        : 'Reviewer';
    final title = review['title']?.toString().trim() ?? '';
    final comment = review['comment']?.toString().trim() ?? '';
    final rating = (review['rating'] as num?)?.toInt() ?? 0;
    final reviewId = review['_id']?.toString();
    final hasReply = _hasReply(review);
    final replyText = hasReply ? review['reply']['text'].toString().trim() : '';
    final dateText = _formatDate(review['createdAt']?.toString());
    final accent = _ratingColor(rating);
    final showTitle = title.isNotEmpty && title.toLowerCase() != 'new review';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: accent.withOpacity(0.12),
                child: Text(
                  _initialsFor(author),
                  style: TextStyle(color: accent, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      author,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: accent.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.star_rounded, size: 16, color: accent),
                              const SizedBox(width: 4),
                              Text(
                                '$rating.0',
                                style: TextStyle(
                                  color: accent,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _buildStarRow(rating, size: 16),
                        if (dateText.isNotEmpty)
                          Text(
                            dateText,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.grey.shade500),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (showTitle) ...[
            const SizedBox(height: 14),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
          ],
          if (comment.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              comment,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF334155),
                height: 1.55,
              ),
            ),
          ],
          if (hasReply) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        height: 32,
                        width: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFFDBEAFE),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.reply_rounded,
                          color: Color(0xFF2563EB),
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Reply from business',
                        style: TextStyle(
                          color: Color(0xFF1D4ED8),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    replyText,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF1E3A8A),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ] else if (widget.userRole == UserRole.wholesaler &&
              reviewId != null &&
              reviewId.isNotEmpty) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _isSubmitting
                    ? null
                    : () => _openReplyDialog(reviewId),
                icon: const Icon(Icons.reply_outlined),
                label: const Text('Reply'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text('Reviews'),
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: (widget.userRole == UserRole.retailer && !_isSubmitting)
            ? _openAddReviewSheet
            : null,
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        icon: _isSubmitting
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.rate_review_outlined),
        label: Text(_isSubmitting ? 'Please wait' : 'Add Review'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadReviews,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Recent reviews',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      if (_reviewCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Text(
                            '$_reviewCount total',
                            style: const TextStyle(
                              color: Color(0xFF475569),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_reviews.isEmpty)
                    _buildEmptyState(context)
                  else
                    ..._reviews.map(
                      (review) => _buildReviewCard(context, review),
                    ),
                ],
              ),
            ),
    );
  }
}

class _HeaderStatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _HeaderStatTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Row(
        children: [
          Container(
            height: 36,
            width: 36,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AddReviewSheetWithWholesaler extends StatefulWidget {
  final List<Map<String, dynamic>> wholesalers;
  final Map<String, dynamic>? selectedWholesaler;

  const _AddReviewSheetWithWholesaler({
    required this.wholesalers,
    required this.selectedWholesaler,
  });

  @override
  State<_AddReviewSheetWithWholesaler> createState() =>
      _AddReviewSheetWithWholesalerState();
}

class _AddReviewSheetWithWholesalerState
    extends State<_AddReviewSheetWithWholesaler> {
  final TextEditingController _commentController = TextEditingController();
  double _rating = 4;
  Map<String, dynamic>? selected;

  @override
  void initState() {
    super.initState();
    selected = widget.selectedWholesaler;
  }

  void _submit() {
    final comment = _commentController.text.trim();

    if (comment.isEmpty || selected == null) return;

    Navigator.pop(context, {
      'comment': comment,
      'rating': _rating,
      'wholesalerId': selected!["_id"],
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<Map<String, dynamic>>(
            value: selected,
            items: widget.wholesalers.map((w) {
              return DropdownMenuItem(
                value: w,
                child: Text(w["shopName"] ?? w["name"]),
              );
            }).toList(),
            onChanged: (val) => setState(() => selected = val),
            decoration: const InputDecoration(labelText: "Select Wholesaler"),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _commentController,
            decoration: const InputDecoration(labelText: "Comment"),
          ),
          const SizedBox(height: 10),
          ElevatedButton(onPressed: _submit, child: const Text("Submit")),
        ],
      ),
    );
  }
}

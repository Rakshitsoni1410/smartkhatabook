import 'package:flutter/material.dart';

import '../models/user_role.dart';

class ReviewScreen extends StatefulWidget {
  final UserRole userRole;
  final String shopName;
  final String businessType;

  const ReviewScreen({
    super.key,
    required this.userRole,
    this.shopName = '',
    this.businessType = '',
  });

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  late final List<Map<String, dynamic>> _reviews;

  @override
  void initState() {
    super.initState();
    _reviews = _defaultReviews();
  }

  List<Map<String, dynamic>> _defaultReviews() {
    if (widget.userRole == UserRole.wholesaler) {
      return [
        {
          'author': 'Patel Retail',
          'rating': 5,
          'title': 'Fast stock delivery',
          'comment':
              'Products arrived on time and the stock quality was excellent.',
        },
        {
          'author': 'A-One Mart',
          'rating': 4,
          'title': 'Reliable employee support',
          'comment':
              'Billing and loading support was smooth. Keep the packing speed consistent.',
        },
        {
          'author': 'Shree Grocers',
          'rating': 5,
          'title': 'Good wholesale rates',
          'comment':
              'Very useful pricing for repeat orders in the same business category.',
        },
      ];
    }

    if (widget.userRole == UserRole.customer) {
      return [
        {
          'author': 'Ledger Team',
          'rating': 4,
          'title': 'Transparent account history',
          'comment':
              'Your recent payments and pending balances are easy to understand.',
        },
        {
          'author': 'Store Owner',
          'rating': 5,
          'title': 'Prompt settlement',
          'comment': 'Payments are usually completed on time and records stay clean.',
        },
      ];
    }

    return [
      {
        'author': 'Walk-in Customer',
        'rating': 5,
        'title': 'Helpful service',
        'comment':
            'The retailer suggested the right items and handled the order quickly.',
      },
      {
        'author': 'Supplier Network',
        'rating': 4,
        'title': 'Consistent ordering',
        'comment':
            'Orders match the business type well and status updates are easy to follow.',
      },
      {
        'author': 'Regular Buyer',
        'rating': 4,
        'title': 'Clear ledger follow-up',
        'comment':
            'Billing and pending amount discussion stays simple and transparent.',
      },
    ];
  }

  double get _averageRating {
    if (_reviews.isEmpty) return 0;

    final total = _reviews.fold<double>(
      0,
      (sum, review) => sum + ((review['rating'] as num?)?.toDouble() ?? 0),
    );

    return total / _reviews.length;
  }

  void _openAddReviewSheet() {
    final nameController = TextEditingController();
    final commentController = TextEditingController();
    double rating = 4;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Add Review',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Reviewer name',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: commentController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Review comment',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Rating: ${rating.toStringAsFixed(0)}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Slider(
                      value: rating,
                      min: 1,
                      max: 5,
                      divisions: 4,
                      label: rating.toStringAsFixed(0),
                      onChanged: (value) {
                        setModalState(() => rating = value);
                      },
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          final reviewer = nameController.text.trim();
                          final comment = commentController.text.trim();

                          if (reviewer.isEmpty || comment.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter name and comment'),
                              ),
                            );
                            return;
                          }

                          setState(() {
                            _reviews.insert(0, {
                              'author': reviewer,
                              'rating': rating.round(),
                              'title': 'New review',
                              'comment': comment,
                            });
                          });

                          Navigator.pop(context);
                        },
                        child: const Text('Save Review'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      nameController.dispose();
      commentController.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    final displayShopName = widget.shopName.trim().isEmpty
        ? widget.userRole.label
        : widget.shopName.trim();
    final displayBusinessType = widget.businessType.trim().isEmpty
        ? 'General'
        : widget.businessType.trim();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reviews'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddReviewSheet,
        child: const Icon(Icons.rate_review_outlined),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.star_rounded,
                    color: Colors.amber,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayShopName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$displayBusinessType business reviews',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _averageRating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Average',
                      style: TextStyle(
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          ..._reviews.map((review) {
            final rating = (review['rating'] as num?)?.toInt() ?? 0;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          review['author']?.toString() ?? 'Reviewer',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Row(
                        children: List.generate(
                          5,
                          (index) => Icon(
                            index < rating ? Icons.star_rounded : Icons.star_border_rounded,
                            color: Colors.amber,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    review['title']?.toString() ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    review['comment']?.toString() ?? '',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

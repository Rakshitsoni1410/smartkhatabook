class PaymentTransaction {
  final String transactionId;
  final String paymentType;
  final String paymentMethod;
  final double amount;
  final String status;
  final bool isMockPayment;
  final DateTime? paidAt;

  const PaymentTransaction({
    required this.transactionId,
    required this.paymentType,
    required this.paymentMethod,
    required this.amount,
    required this.status,
    required this.isMockPayment,
    this.paidAt,
  });

  factory PaymentTransaction.fromJson(Map<String, dynamic> json) {
    return PaymentTransaction(
      transactionId: json['transactionId']?.toString() ?? '',
      paymentType: json['paymentType']?.toString() ?? '',
      paymentMethod: json['paymentMethod']?.toString() ?? '',
      amount: _number(json['amount']),
      status: json['status']?.toString() ?? '',
      isMockPayment: json['isMockPayment'] == true,
      paidAt: _date(json['paidAt']),
    );
  }

  Map<String, dynamic> toJson() => {
    'transactionId': transactionId,
    'paymentType': paymentType,
    'paymentMethod': paymentMethod,
    'amount': amount,
    'status': status,
    'isMockPayment': isMockPayment,
    'paidAt': paidAt?.toIso8601String(),
  };

  static double _number(dynamic value) => value is num
      ? value.toDouble()
      : double.tryParse(value?.toString() ?? '') ?? 0;

  static DateTime? _date(dynamic value) =>
      value == null ? null : DateTime.tryParse(value.toString());
}

class Order {
  final String id;
  final dynamic retailerId;
  final dynamic wholesalerId;
  final String? retailerName;
  final String? wholesalerName;
  final dynamic productId;
  final String productName;
  final String category;
  final String businessType;
  final double quantity;
  final String unit;
  final double pricePerUnit;
  final double totalAmount;
  final String? invoiceNumber;
  final bool billSentToRetailer;
  final DateTime? billSentAt;
  final double advancePercentage;
  final double advanceAmount;
  final double remainingAmount;
  final bool advanceRequested;
  final bool advancePaid;
  final bool finalPaymentRequested;
  final bool fullPaymentDone;
  final String orderStatus;
  final String paymentStatus;
  final List<PaymentTransaction> paymentHistory;
  final String? lastPaymentTransactionId;
  final String? lastPaymentMethod;
  final String? lastPaymentType;
  final double? lastPaymentAmount;
  final DateTime? lastPaymentAt;
  final DateTime? deliveryDate;
  final DateTime? deliveredAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Order({
    required this.id,
    this.retailerId,
    this.wholesalerId,
    this.retailerName,
    this.wholesalerName,
    this.productId,
    required this.productName,
    required this.category,
    required this.businessType,
    required this.quantity,
    required this.unit,
    required this.pricePerUnit,
    required this.totalAmount,
    this.invoiceNumber,
    required this.billSentToRetailer,
    this.billSentAt,
    required this.advancePercentage,
    required this.advanceAmount,
    required this.remainingAmount,
    required this.advanceRequested,
    required this.advancePaid,
    required this.finalPaymentRequested,
    required this.fullPaymentDone,
    required this.orderStatus,
    required this.paymentStatus,
    required this.paymentHistory,
    this.lastPaymentTransactionId,
    this.lastPaymentMethod,
    this.lastPaymentType,
    this.lastPaymentAmount,
    this.lastPaymentAt,
    this.deliveryDate,
    this.deliveredAt,
    this.createdAt,
    this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    final history = json['paymentHistory'];
    return Order(
      id: _id(json),
      retailerId: json['retailerId'],
      wholesalerId: json['wholesalerId'],
      retailerName: _string(json['retailerName']),
      wholesalerName: _string(json['wholesalerName']),
      productId: json['productId'],
      productName: json['productName']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      businessType: json['businessType']?.toString() ?? '',
      quantity: _number(json['quantity']),
      unit: json['unit']?.toString() ?? '',
      pricePerUnit: _number(json['pricePerUnit']),
      totalAmount: _number(json['totalAmount']),
      invoiceNumber: _string(json['invoiceNumber']),
      billSentToRetailer: json['billSentToRetailer'] == true,
      billSentAt: _date(json['billSentAt']),
      advancePercentage: _number(json['advancePercentage']),
      advanceAmount: _number(json['advanceAmount']),
      remainingAmount: _number(json['remainingAmount']),
      advanceRequested: json['advanceRequested'] == true,
      advancePaid: json['advancePaid'] == true,
      finalPaymentRequested: json['finalPaymentRequested'] == true,
      fullPaymentDone: json['fullPaymentDone'] == true,
      orderStatus: json['orderStatus']?.toString() ?? 'pending',
      paymentStatus: json['paymentStatus']?.toString() ?? 'unpaid',
      paymentHistory: history is List
          ? history
                .whereType<Map>()
                .map(
                  (item) => PaymentTransaction.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .toList()
          : const [],
      lastPaymentTransactionId: _string(json['lastPaymentTransactionId']),
      lastPaymentMethod: _string(json['lastPaymentMethod']),
      lastPaymentType: _string(json['lastPaymentType']),
      lastPaymentAmount: json['lastPaymentAmount'] == null
          ? null
          : _number(json['lastPaymentAmount']),
      lastPaymentAt: _date(json['lastPaymentAt']),
      deliveryDate: _date(json['deliveryDate']),
      deliveredAt: _date(json['deliveredAt']),
      createdAt: _date(json['createdAt']),
      updatedAt: _date(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'retailerId': retailerId,
    'wholesalerId': wholesalerId,
    'retailerName': retailerName,
    'wholesalerName': wholesalerName,
    'productId': productId,
    'productName': productName,
    'category': category,
    'businessType': businessType,
    'quantity': quantity,
    'unit': unit,
    'pricePerUnit': pricePerUnit,
    'totalAmount': totalAmount,
    'invoiceNumber': invoiceNumber,
    'billSentToRetailer': billSentToRetailer,
    'billSentAt': billSentAt?.toIso8601String(),
    'advancePercentage': advancePercentage,
    'advanceAmount': advanceAmount,
    'remainingAmount': remainingAmount,
    'advanceRequested': advanceRequested,
    'advancePaid': advancePaid,
    'finalPaymentRequested': finalPaymentRequested,
    'fullPaymentDone': fullPaymentDone,
    'orderStatus': orderStatus,
    'paymentStatus': paymentStatus,
    'paymentHistory': paymentHistory.map((item) => item.toJson()).toList(),
    'lastPaymentTransactionId': lastPaymentTransactionId,
    'lastPaymentMethod': lastPaymentMethod,
    'lastPaymentType': lastPaymentType,
    'lastPaymentAmount': lastPaymentAmount,
    'lastPaymentAt': lastPaymentAt?.toIso8601String(),
    'deliveryDate': deliveryDate?.toIso8601String(),
    'deliveredAt': deliveredAt?.toIso8601String(),
    'createdAt': createdAt?.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };

  static String _id(Map<String, dynamic> json) =>
      json['_id']?.toString() ?? json['id']?.toString() ?? '';

  static String? _string(dynamic value) =>
      value == null || value.toString().isEmpty ? null : value.toString();

  static double _number(dynamic value) => value is num
      ? value.toDouble()
      : double.tryParse(value?.toString() ?? '') ?? 0;

  static DateTime? _date(dynamic value) =>
      value == null ? null : DateTime.tryParse(value.toString());
}

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmployeeDetail extends StatefulWidget {
  final Map<String, dynamic> employee;

  const EmployeeDetail({
    super.key,
    required this.employee,
  });

  @override
  State<EmployeeDetail> createState() => _EmployeeDetailState();
}

class _EmployeeDetailState extends State<EmployeeDetail> {
  late List<Map<String, dynamic>> payments;
  late List<Map<String, dynamic>> _attendance;
  bool isDark = false;
  File? selectedImage;

  @override
  void initState() {
    super.initState();

    payments = List<Map<String, dynamic>>.from(
      widget.employee['payments'] ?? [],
    );
    
    _attendance = List<Map<String, dynamic>>.from(
      widget.employee['attendance'] ?? [],
    );
  }

  double get totalPaid {
    return payments.fold<double>(
      0,
      (sum, p) => sum + ((p['amount'] ?? 0) as num).toDouble(),
    );
  }

  double get monthlySalary {
    return ((widget.employee['salary'] ?? 0) as num).toDouble();
  }

  double get pendingSalary {
    final value = monthlySalary - totalPaid;
    return value < 0 ? 0 : value;
  }

  double get progress {
    if (monthlySalary <= 0) return 0;

    final p = totalPaid / monthlySalary;

    if (p > 1) return 1;

    return p;
  }

  List<Map<String, dynamic>> get attendance {
    return List<Map<String, dynamic>>.from(
      widget.employee['attendance'] ?? [],
    );
  }

  String formatCurrency(double value) {
    return '₹${value.toStringAsFixed(0)}';
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'Active':
        return Colors.green;
      case 'On Leave':
        return Colors.orange;
      case 'Inactive':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color getAttendanceColor(String status) {
    switch (status.toLowerCase()) {
      case "present":
        return Colors.green;

      case "absent":
        return Colors.red;

      case "leave":
        return Colors.orange;

      case "half day":
        return Colors.purple;

      default:
        return Colors.blue;
    }
  }

  IconData getAttendanceIcon(String status) {
    switch (status.toLowerCase()) {
      case "present":
        return Icons.check_circle;

      case "absent":
        return Icons.cancel;

      case "leave":
        return Icons.event_busy;

      case "half day":
        return Icons.access_time;

      default:
        return Icons.info;
    }
  }

  Future<void> generateReceipt(
    Map<String, dynamic> payment,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(20),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Salary Receipt',
                  style: pw.TextStyle(
                    fontSize: 28,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 30),
                pw.Text(
                  'Employee: ${widget.employee['name']}',
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Amount: ₹${payment['amount']}',
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Method: ${payment['method']}',
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Date: ${payment['date']}',
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Note: ${payment['note'] ?? 'N/A'}',
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();

    final image = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
      });
    }
  }

  Future<void> saveEmployees() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      'employees',
      jsonEncode(widget.employee),
    );
  }

  Future<void> openPaySheet() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xffF5F7FB),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const _PaySalarySheet(),
    );

    if (result == null) return;

    setState(() {
      payments.add(result);
      widget.employee["payments"] = payments;
      saveEmployees();
    });
  }

  Future<void> callEmployee(String phone) async {
    final Uri uri = Uri.parse('tel:$phone');

    await launchUrl(uri);
  }

  Future<void> whatsappEmployee(String phone) async {
    final Uri uri = Uri.parse('https://wa.me/91$phone');

    await launchUrl(uri);
  }

  Widget attendanceCard({
    required String date,
    required String status,
  }) {
    final color = getAttendanceColor(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              getAttendanceIcon(status),
              color: color,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  "Attendance Marked",
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> markAttendancePopup() async {
    String selectedStatus = "Present";

    await showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xffF7F9FC),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    "Mark Attendance",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 18),

                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      "Present",
                      "Absent",
                      "Leave",
                      "Half Day",
                    ].map((status) {
                      final bool isSelected = selectedStatus == status;

                      return GestureDetector(
                        onTap: () {
                          setModalState(() {
                            selectedStatus = status;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? getAttendanceColor(status)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: getAttendanceColor(status),
                            ),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : getAttendanceColor(status),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff2563EB),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _attendance.insert(0, {
                            "date": DateTime.now()
                                .toString()
                                .split(" ")[0],
                            "status": selectedStatus,
                          });

                          widget.employee["attendance"] = _attendance;
                          
                        });

                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.check_circle_outline,
                      ),
                      label: const Text(
                        "Save Attendance",
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget summaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final emp = widget.employee;

    final String name = emp['name'] ?? '';
    final String phone = emp['phone'] ?? '';
    final String category = emp['category'] ?? 'Other';
    final String status = emp['status'] ?? 'Active';

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : const Color(0xffF5F7FB),

      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: "attendance",
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            onPressed: markAttendancePopup,
            icon: const Icon(Icons.calendar_month),
            label: const Text("Attendance"),
          ),

          const SizedBox(height: 12),

          FloatingActionButton.extended(
            heroTag: "payment",
            backgroundColor: const Color(0xff2E7D32),
            foregroundColor: Colors.white,
            onPressed: openPaySheet,
            icon: const Icon(Icons.payments_outlined),
            label: const Text("Pay Salary"),
          ),
        ],
      ),

      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: const Color(0xff2563EB),
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                onPressed: () {
                  setState(() {
                    isDark = !isDark;
                  });
                },
                icon: Icon(
                  isDark
                      ? Icons.light_mode
                      : Icons.dark_mode,
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xff2563EB),
                      Color(0xff0EA5E9),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: pickImage,
                              child: CircleAvatar(
                                radius: 34,
                                backgroundColor: Colors.white24,
                                backgroundImage:
                                    selectedImage != null
                                        ? FileImage(selectedImage!)
                                        : null,
                                child: selectedImage == null
                                    ? Text(
                                        name.isEmpty ? 'E' : name[0],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 26,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    category,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: getStatusColor(status).withOpacity(0.20),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              color: getStatusColor(status),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: summaryCard(
                          title: 'Salary',
                          value: formatCurrency(monthlySalary),
                          icon: Icons.wallet_outlined,
                          color: const Color(0xff2563EB),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: summaryCard(
                          title: 'Paid',
                          value: formatCurrency(totalPaid),
                          icon: Icons.check_circle_outline,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Salary Progress',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 12,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: const AlwaysStoppedAnimation(
                              Color(0xff2E7D32),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Paid ${formatCurrency(totalPaid)}',
                            ),
                            Text(
                              'Pending ${formatCurrency(pendingSalary)}',
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Quick Actions',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceAround,
                          children: [
                            _actionButton(
                              icon: Icons.call,
                              label: 'Call',
                              color: Colors.green,
                              onTap: () => callEmployee(phone),
                            ),
                            _actionButton(
                              icon: Icons.message,
                              label: 'WhatsApp',
                              color: const Color(0xff00C853),
                              onTap: () => whatsappEmployee(phone),
                            ),
                            _actionButton(
                              icon: Icons.picture_as_pdf_outlined,
                              label: 'Receipt',
                              color: Colors.red,
                              onTap: () {
                                if (payments.isNotEmpty) {
                                  generateReceipt(payments.last);
                                }
                              },
                            ),
                            _actionButton(
                              icon: Icons.edit_outlined,
                              label: 'Edit',
                              color: Colors.orange,
                              onTap: () {},
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Payment History',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 14),

                        if (payments.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(24),
                            child: Center(
                              child: Text('No payment history'),
                            ),
                          ),

                        ...payments.reversed.map((p) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xffF7F9FC),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  height: 50,
                                  width: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(
                                    Icons.payments_outlined,
                                    color: Colors.green,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        formatCurrency(
                                          ((p['amount'] ?? 0) as num)
                                              .toDouble(),
                                        ),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        p['method'] ?? 'Cash',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Text(
                                        p['date']
                                            .toString()
                                            .split(' ')[0],
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      if ((p['note'] ?? '')
                                          .toString()
                                          .isNotEmpty)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 4),
                                          child: Text(
                                            p['note'],
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      payments.remove(p);
                                      saveEmployees();
                                    });
                                  },
                                )
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Attendance History",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  _attendance.isEmpty
                      ? Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Column(
                            children: const [
                              Icon(
                                Icons.calendar_month_outlined,
                                size: 42,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 10),
                              Text(
                                "No attendance marked yet",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Column(
                          children: _attendance.map((a) {
                            return attendanceCard(
                              date: a["date"] ?? "",
                              status: a["status"] ?? "",
                            );
                          }).toList(),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Column(
        children: [
          Container(
            height: 58,
            width: 58,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaySalarySheet extends StatefulWidget {
  const _PaySalarySheet();

  @override
  State<_PaySalarySheet> createState() => _PaySalarySheetState();
}

class _PaySalarySheetState extends State<_PaySalarySheet> {
  final amountCtrl = TextEditingController();
  final noteCtrl = TextEditingController();

  String method = 'Cash';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pay Salary',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: amountCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Amount',
                prefixIcon: const Icon(Icons.currency_rupee),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              value: method,
              items: const [
                DropdownMenuItem(
                  value: 'Cash',
                  child: Text('Cash'),
                ),
                DropdownMenuItem(
                  value: 'UPI',
                  child: Text('UPI'),
                ),
                DropdownMenuItem(
                  value: 'Bank Transfer',
                  child: Text('Bank Transfer'),
                ),
              ],
              onChanged: (v) {
                setState(() {
                  method = v!;
                });
              },
              decoration: InputDecoration(
                labelText: 'Payment Method',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: noteCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Payment Note',
                hintText: 'Advance / Bonus / Half Payment',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff2E7D32),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context, {
                    'amount':
                        double.tryParse(amountCtrl.text.trim()) ?? 0,
                    'method': method,
                    'note': noteCtrl.text.trim(),
                    'date': DateTime.now().toString(),
                    'month': DateTime.now().month,
                    'year': DateTime.now().year,
                  });
                },
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Confirm Payment'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

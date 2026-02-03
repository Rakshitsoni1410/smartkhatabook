class LedgerService {
  static final List<Map<String, dynamic>> ledgerEntries = [];

  static void addEntry({
    required String party,
    required String type,
    required int amount,
    required String source,
  }) {
    ledgerEntries.add({
      "party": party,
      "type": type,
      "amount": amount,
      "source": source,
      "date": DateTime.now().toString().split(" ")[0],
    });
  }
}

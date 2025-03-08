class ScannedResult {
  String id;
  String resultText;

  ScannedResult({required this.id, required this.resultText});

  // Convert ScannedResult to a map (for JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'resultText': resultText,
    };
  }

  // Create ScannedResult from a map (from JSON)
  factory ScannedResult.fromJson(Map<String, dynamic> json) {
    return ScannedResult(
      id: json['id'],
      resultText: json['resultText'],
    );
  }
}

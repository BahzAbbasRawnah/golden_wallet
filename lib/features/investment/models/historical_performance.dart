/// Model representing historical performance data for an investment plan
class HistoricalPerformance {
  final DateTime date;
  final double returnPercentage;
  
  const HistoricalPerformance({
    required this.date,
    required this.returnPercentage,
  });
  
  /// Create historical performance data from a JSON object
  factory HistoricalPerformance.fromJson(Map<String, dynamic> json) {
    return HistoricalPerformance(
      date: DateTime.parse(json['date'] as String),
      returnPercentage: json['return_percentage'] as double,
    );
  }
  
  /// Convert this historical performance data to a JSON object
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'return_percentage': returnPercentage,
    };
  }
}

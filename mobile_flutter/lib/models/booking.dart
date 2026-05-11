class Booking {
  final String id;
  final String customerName;
  final String customerMobile;
  final String serviceName;
  final double servicePrice;
  final DateTime date;
  final String startTime;
  final String status;

  Booking({
    required this.id,
    required this.customerName,
    required this.customerMobile,
    required this.serviceName,
    required this.servicePrice,
    required this.date,
    required this.startTime,
    required this.status,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['_id'],
      customerName: json['customer']['name'] ?? 'Unknown',
      customerMobile: json['customer']['mobile'] ?? '',
      serviceName: json['service']['name'] ?? 'Unknown',
      servicePrice: (json['service']['defaultPrice'] ?? 0).toDouble(),
      date: DateTime.parse(json['date']),
      startTime: json['startTime'],
      status: json['status'],
    );
  }
}

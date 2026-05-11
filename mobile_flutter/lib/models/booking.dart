class Booking {
  final String id;
  final String customerName;
  final String customerMobile;
  final String serviceName;
  final double servicePrice;
  final DateTime date;
  final String startTime;
  final String status;
  final String paymentStatus;

  Booking({
    required this.id,
    required this.customerName,
    required this.customerMobile,
    required this.serviceName,
    required this.servicePrice,
    required this.date,
    required this.startTime,
    required this.status,
    required this.paymentStatus,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['_id'],
      customerName: json['customer'] != null ? json['customer']['name'] ?? 'Unknown' : 'Unknown',
      customerMobile: json['customer'] != null ? json['customer']['mobile'] ?? '' : '',
      serviceName: json['service'] != null ? json['service']['name'] ?? 'Unknown' : 'Unknown',
      servicePrice: json['service'] != null ? (json['service']['defaultPrice'] ?? 0).toDouble() : 0.0,
      date: DateTime.parse(json['date']),
      startTime: json['startTime'],
      status: json['status'],
      paymentStatus: json['paymentStatus'] ?? 'pending',
    );
  }
}

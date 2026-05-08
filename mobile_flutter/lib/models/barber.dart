class Service {
  final String id;
  final String name;
  final double defaultPrice;

  Service({
    required this.id,
    required this.name,
    required this.defaultPrice,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      defaultPrice: (json['defaultPrice'] ?? 0).toDouble(),
    );
  }
}

class Location {
  final String city;
  final String address;

  Location({required this.city, required this.address});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      city: json['city'] ?? '',
      address: json['address'] ?? '',
    );
  }
}

class Barber {
  final String id;
  final String name;
  final String shopName;
  final Location location;
  final String? profilePhoto;
  final List<Service> services;

  Barber({
    required this.id,
    required this.name,
    required this.shopName,
    required this.location,
    this.profilePhoto,
    required this.services,
  });

  factory Barber.fromJson(Map<String, dynamic> json) {
    return Barber(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      shopName: json['shopName'] ?? '',
      location: Location.fromJson(json['location'] ?? {}),
      profilePhoto: json['profilePhoto'],
      services: (json['services'] as List? ?? [])
          .map((s) => Service.fromJson(s))
          .toList(),
    );
  }
}

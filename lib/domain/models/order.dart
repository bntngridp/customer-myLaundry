import 'user.dart';

class OrderModel {
  final int id;
  final String status;
  final String createdAt;
  final String updatedAt;
  final double totalPrice;
  final double weight;
  final int quantity;
  final User? customer;
  final User? courier;
  final User? admin;
  final ServiceModel? service;
  final AddressModel? address;

  OrderModel({
    required this.id,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.totalPrice,
    required this.weight,
    required this.quantity,
    this.customer,
    this.courier,
    this.admin,
    this.service,
    this.address,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? 0,
      status: json['status'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      totalPrice: (json['total_price'] as num?)?.toDouble() ?? 0.0,
      weight: (json['weight'] as num?)?.toDouble() ?? 0.0,
      quantity: json['quantity'] ?? 0,
      customer: json['customer'] != null ? User.fromJson(json['customer']) : null,
      courier: json['courier'] != null ? User.fromJson(json['courier']) : null,
      admin: json['admin'] != null ? User.fromJson(json['admin']) : null,
      service: json['service'] != null ? ServiceModel.fromJson(json['service']) : null,
      address: json['address'] != null ? AddressModel.fromJson(json['address']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'total_price': totalPrice,
      'weight': weight,
      'quantity': quantity,
      'customer': customer?.toJson(),
      'courier': courier?.toJson(),
      'admin': admin?.toJson(),
      'service': service?.toJson(),
      'address': address?.toJson(),
    };
  }
}

class ServiceModel {
  final int id;
  final String title;
  final int price;

  ServiceModel({
    required this.id,
    required this.title,
    required this.price,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      price: json['price'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
    };
  }
}

class AddressModel {
  final int id;
  final int customerId;
  final String receiverName;
  final String phoneNumber;
  final String houseNumber;
  final String residenceName;
  final String addressNotes;
  final String streetName;
  final String district;
  final String subDistrict;
  final String city;
  final String area;

  AddressModel({
    required this.id,
    required this.customerId,
    required this.receiverName,
    required this.phoneNumber,
    required this.houseNumber,
    required this.residenceName,
    required this.addressNotes,
    required this.streetName,
    required this.district,
    required this.subDistrict,
    required this.city,
    required this.area,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] ?? 0,
      customerId: json['customer_id'] ?? 0,
      receiverName: json['receiver_name'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      houseNumber: json['house_number'] ?? '',
      residenceName: json['residence_name'] ?? '',
      addressNotes: json['address_notes'] ?? '',
      streetName: json['street_name'] ?? '',
      district: json['district'] ?? '',
      subDistrict: json['sub_district'] ?? '',
      city: json['city'] ?? '',
      area: json['area'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'receiver_name': receiverName,
      'phone_number': phoneNumber,
      'house_number': houseNumber,
      'residence_name': residenceName,
      'address_notes': addressNotes,
      'street_name': streetName,
      'district': district,
      'sub_district': subDistrict,
      'city': city,
      'area': area,
    };
  }

  String get fullAddress {
    List<String> parts = [];
    if (streetName.isNotEmpty) parts.add(streetName);
    if (houseNumber.isNotEmpty) parts.add('No. $houseNumber');
    if (residenceName.isNotEmpty) parts.add(residenceName);
    if (subDistrict.isNotEmpty) parts.add(subDistrict);
    if (district.isNotEmpty) parts.add(district);
    if (city.isNotEmpty) parts.add(city);
    return parts.join(', ');
  }
}

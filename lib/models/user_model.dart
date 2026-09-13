import 'package:cloud_firestore/cloud_firestore.dart';

class AddressModel {
  final String label;
  final String address;
  final String phone;
  final bool isDefault;

  AddressModel({
    required this.label,
    required this.address,
    required this.phone,
    this.isDefault = false,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      label: json['label'] ?? 'Address',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      isDefault: json['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'address': address,
      'phone': phone,
      'isDefault': isDefault,
    };
  }
}

class UserModel {
  final String uid;
  final String fullName;
  final String email;
  final String phone;
  final String role;
  final DateTime? createdAt;
  final String? address; // Legacy single address
  final List<AddressModel> addresses;
  final String? imageUrl;

  UserModel({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.role,
    this.createdAt,
    this.address,
    this.addresses = const [],
    this.imageUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    var addressesList = json['addresses'] as List?;
    List<AddressModel> parsedAddresses = [];
    if (addressesList != null) {
      parsedAddresses = addressesList.map((e) => AddressModel.fromJson(e)).toList();
    }

    return UserModel(
      uid: json['uid'] ?? '',
      fullName: json['fullName'] ?? json['name'] ?? 'User',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? 'buyer',
      createdAt: json['createdAt'] != null ? (json['createdAt'] as Timestamp).toDate() : null,
      address: json['address'],
      addresses: parsedAddresses,
      imageUrl: json['image'] ?? json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'role': role,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'address': address,
      'addresses': addresses.map((e) => e.toJson()).toList(),
      'image': imageUrl,
    };
  }
}

class UserModel {
  final String id;
  final String name;
  final String email;
  final String password; // For Realtime Database authentication
  final String phone;
  final String role; // admin, farmer, buyer
  final String? address;
  final String? farmLocation;
  final List<String>? cropPreferences;
  final DateTime? createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
    required this.role,
    this.address,
    this.farmLocation,
    this.cropPreferences,
    this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password, // Store password for Realtime Database auth
      'phone': phone,
      'role': role,
      'address': address,
      'farmLocation': farmLocation,
      'cropPreferences': cropPreferences,
      'createdAt':
          createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? '',
      address: json['address'],
      farmLocation: json['farmLocation'],
      cropPreferences: json['cropPreferences'] != null
          ? List<String>.from(json['cropPreferences'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }

  // Create a copy without password for security
  UserModel copyWithoutPassword() {
    return UserModel(
      id: id,
      name: name,
      email: email,
      password: '', // Don't expose password
      phone: phone,
      role: role,
      address: address,
      farmLocation: farmLocation,
      cropPreferences: cropPreferences,
      createdAt: createdAt,
    );
  }
}

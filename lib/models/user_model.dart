import 'package:flutter_app/enums/gender.dart';

class UserModel {
  final String firstName;
  final String lastName;
  final String email;
  final Gender gender;
  final String password;

  UserModel({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.gender,
    required this.password,
  });

  String get fullName => '$firstName $lastName';

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'gender': gender.name,
      'password': password,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      gender: Gender.values.firstWhere(
        (item) => item.name == json['gender'],
        orElse: () => Gender.other,
      ),
      password: json['password'] ?? '',
    );
  }
}
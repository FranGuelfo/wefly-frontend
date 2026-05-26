class AuthResponse {
  final String token;
  final int userId;
  final String name;
  final String email;

  AuthResponse({
    required this.token,
    required this.userId,
    required this.name,
    required this.email,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'],
      userId: json['userId'],
      name: json['name'],
      email: json['email'],
    );
  }
}
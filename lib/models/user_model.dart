class UserProfile {
  final int id;
  final String name;
  final String email;
  final String? bio;
  final String? profilePictureUrl;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.bio,
    this.profilePictureUrl,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      bio: json['bio'],
      profilePictureUrl: json['profilePictureUrl'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'bio': bio,
    'profilePictureUrl': profilePictureUrl,
  };
}
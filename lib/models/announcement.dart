class Announcement {
  final int id;
  final String title;
  final String description;
  final int seatsAvailable;
  final String category;
  final String? type;
  final int authorId;
  final String authorName;
  final String? authorPhoto;
  final String flightNumber;

  Announcement({
    required this.id,
    required this.title,
    required this.description,
    required this.seatsAvailable,
    required this.category,
    this.type,
    required this.authorId,
    required this.authorName,
    required this.authorPhoto,
    required this.flightNumber,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Sin título',
      description: json['description'] ?? '',
      seatsAvailable: json['seatsAvailable'] ?? 0,
      category: json['category'] ?? 'General',
      type: json['type'] ?? 'TRANSPORT',
      authorId: json['authorId'] ?? json['author']?['id'] ?? 0, 
      authorName: json['authorName'] ?? 'Usuario', 
      authorPhoto: json['authorProfilePictureUrl'] ?? json['authorPhoto'] ?? '', 
      flightNumber: json['flightNumber'] ?? '---',
    );
  }
}
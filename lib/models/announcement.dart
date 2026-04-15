class Announcement {
  final int? id;
  final String flightNumber;
  final String title;
  final String description;
  final String category;
  final int seatsAvailable;
  final String authorName;
  final int authorId;

  Announcement({
    this.id,
    required this.flightNumber,
    required this.title,
    required this.description,
    required this.category,
    required this.seatsAvailable,
    required this.authorName,
    required this.authorId,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['id'],
      flightNumber: json['flightNumber'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? 'TO_AIRPORT',
      seatsAvailable: json['seatsAvailable'] ?? 0,
      authorName: json['authorName'] ?? 'Anónimo',
      authorId: json['authorId'] ?? 0,
    );
  }
}
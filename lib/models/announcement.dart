class Announcement {
  final int id;
  final String title;
  final String description;
  final int seatsAvailable;
  final String category;
  final int authorId;
  final String authorName;
  final String flightNumber;
  final String? authorPhone;
  final String origin;
  final String destination;
  final String dateStr;

  Announcement({
    required this.id, required this.title, required this.description,
    required this.seatsAvailable, required this.category, required this.authorId,
    required this.authorName, required this.flightNumber, this.authorPhone,
    required this.origin, required this.destination, required this.dateStr,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Sin título',
      description: json['description'] ?? '',
      seatsAvailable: json['seatsAvailable'] ?? 0,
      category: json['category'] ?? 'General',
      authorId: json['authorId'] ?? 0,
      authorName: json['authorName'] ?? 'Usuario',
      flightNumber: json['flightNumber'] ?? '---',
      authorPhone: json['authorPhone'],
      origin: json['origin'] ?? 'Aeropuerto',
      destination: json['destination'] ?? 'Destino',
      dateStr: json['dateStr'] ?? 'Fecha no disponible',
    );
  }
}
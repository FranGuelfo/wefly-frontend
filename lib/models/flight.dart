class Flight {
  final int id;
  final String flightNumber;
  final String origin;
  final String destination;
  final String? arrivalTime; // Nullable por si viene vacío al crearse dinámicamente

  Flight({
    required this.id,
    required this.flightNumber,
    required this.origin,
    required this.destination,
    this.arrivalTime,
  });

  factory Flight.fromJson(Map<String, dynamic> json) {
    return Flight(
      id: json['id'] ?? 0,
      flightNumber: json['flightNumber'] ?? '',
      origin: json['origin'] ?? 'Por definir',
      destination: json['destination'] ?? 'Por definir',
      arrivalTime: json['arrivalTime'],
    );
  }
}
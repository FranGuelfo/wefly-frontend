class Flight {
  final int id;
  final String flightNumber;
  final String origin;
  final String destination;
  final String? arrivalTime;
  final int plazas;

  Flight({
    required this.id,
    required this.flightNumber,
    required this.origin,
    required this.destination,
    this.arrivalTime,
    this.plazas = 0,
  });

  factory Flight.fromJson(Map<String, dynamic> json) {
    return Flight(
      id: json['id'] ?? 0,
      flightNumber: json['flightNumber'] ?? '',
      origin: json['origin'] ?? 'Por definir',
      destination: json['destination'] ?? 'Por definir',
      arrivalTime: json['arrivalTime'],
      plazas: json['plazas'] ?? 0,
    );
  }
}
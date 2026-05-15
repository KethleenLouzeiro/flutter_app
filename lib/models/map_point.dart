enum MapPointCategory {
  hotel,
  mercado,
  posto,
  oficina,
  restaurante,
  turismo,
  hospital,
  farmacia,
  pets,
}

class MapPoint {
  const MapPoint({
    required this.id,
    required this.name,
    required this.category,
    required this.latitude,
    required this.longitude,
    required this.city,
    this.description,
  });

  final String id;
  final String name;
  final MapPointCategory category;
  final double latitude;
  final double longitude;
  final String city;
  final String? description;
}

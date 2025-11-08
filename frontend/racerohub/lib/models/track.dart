class Track {
  final int id;
  final String location;
  final String distance;
  final String description;
  final String imageUrl;

  const Track({
    required this.id,
    required this.location,
    required this.distance,
    required this.description,
    required this.imageUrl,
  });

  factory Track.fromJson(Map<String, dynamic> json) => Track(
    id: (json['id'] as num).toInt(),
    location: (json['location'] ?? '') as String,
    distance: (json['distance'] ?? '') as String,
    description: (json['description'] ?? '') as String,
    imageUrl: (json['imageUrl'] ?? '') as String,
  );
}

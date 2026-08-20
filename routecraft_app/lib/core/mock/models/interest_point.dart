class InterestPoint {
  final String id;
  final String name;
  final String description;

  const InterestPoint({
    required this.id,
    required this.name,
    required this.description,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'description': description,
      };

  factory InterestPoint.fromJson(Map<String, dynamic> json) {
    return InterestPoint(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
    );
  }
}

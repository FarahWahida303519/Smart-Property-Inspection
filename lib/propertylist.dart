class InspectionData {
  int? id;
  String propertyName;
  String description;
  String rating;
  double latitude;
  double longitude;
  String dateCreated;
  String photos; // comma-separated or JSON string

  InspectionData(
    this.id,
    this.propertyName,
    this.description,
    this.rating,
    this.latitude,
    this.longitude,
    this.dateCreated,
    this.photos,
  );

  // Convert object to Map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'property_name': propertyName,
      'description': description,
      'rating': rating,
      'latitude': latitude,
      'longitude': longitude,
      'date_created': dateCreated,
      'photos': photos,
    };
  }

  // Create object from SQLite Map
  factory InspectionData.fromMap(Map<String, dynamic> map) {
    return InspectionData(
      map['id'] as int?,
      map['property_name'] as String,
      map['description'] as String,
      map['rating'] as String,
      map['latitude'] as double,
      map['longitude'] as double,
      map['date_created'] as String,
      map['photos'] as String,
    );
  }
}

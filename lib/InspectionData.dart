import 'package:intl/intl.dart';

class InspectionData {
  int id;
  String propertyName;
  String address;
  String description;
  String rating;
  double latitude;
  double longitude;
  String dateCreated;
  String photos;

  InspectionData(
    this.id,
    this.propertyName,
    this.address,
    this.description,
    this.rating,
    this.latitude,
    this.longitude,
    this.dateCreated,
    this.photos,
  );

  // convert string into fromat date
  DateTime get createdAt {
    final format = DateFormat("dd MMM yyyy, hh:mm a");
    return format.parse(dateCreated);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'property_name': propertyName,
      'address': address,
      'description': description,
      'rating': rating,
      'latitude': latitude,
      'longitude': longitude,
      'date_created': dateCreated,
      'photos': photos,
    };
  }

  factory InspectionData.fromMap(Map<String, dynamic> map) {
    return InspectionData(
      map['id'],
      map['property_name'],
      map['address'],
      map['description'],
      map['rating'],
      map['latitude'],
      map['longitude'],
      map['date_created'],
      map['photos'],
    );
  }
}

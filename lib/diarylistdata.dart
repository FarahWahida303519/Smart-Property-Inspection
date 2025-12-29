class DiaryListData {
  //Attributes
  int id;
  String title;
  String description;
  String status;
  String date;
  String imagename;

  DiaryListData(
    // Constructor to initialize attributes
    this.id,
    this.title,
    this.description,
    this.status,
    this.date,
    this.imagename,
  );

  // Convert DiaryListData object into Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status,
      'date': date,
      'imagename': imagename,
    };
  }

  //to create DiaryListData obj from map to read data from db
  factory DiaryListData.fromMap(Map<String, dynamic> map) {
    return DiaryListData(
      map['id'] as int,
      map['title'] as String,
      map['description'] as String,
      map['status'] as String,
      map['date'] as String,
      map['imagename'] as String,
    );
  }
}

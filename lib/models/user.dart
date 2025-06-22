
//user table
class User {
  final int? id;
  final String name;
  final String gender;
  final String ageGroup;
  final String createdAt;

  User({
    this.id,
    required this.name,
    required this.gender,
    required this.ageGroup,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'gender': gender,
    'ageGroup': ageGroup,
    'createdAt': createdAt,
  };

  static User fromMap(Map<String, dynamic> map) => User(
    id: map['id'],
    name: map['name'],
    gender: map['gender'],
    ageGroup: map['ageGroup'],
    createdAt: map['createdAt'],
  );
}

//scan table
class Scan {
  final int? id;
  final int userId;
  final String result;
  final String? imagePath;
  final String timestamp;

  Scan({
    this.id,
    required this.userId,
    required this.result,
    this.imagePath,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'userId': userId,
    'result': result,
    'imagePath': imagePath,
    'timestamp': timestamp,
  };

  static Scan fromMap(Map<String, dynamic> map) => Scan(
    id: map['id'],
    userId: map['userId'],
    result: map['result'],
    imagePath: map['imagePath'],
    timestamp: map['timestamp'],
  );
}

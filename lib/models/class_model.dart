class ClassModel {
  String uid;
  String name;
  String school;

  ClassModel({
    required this.uid,
    required this.name,
    required this.school,
  });

  // Convert ClassModel to a Firestore-compatible map
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'school': school,
    };
  }

  // Convert Firestore document snapshot into ClassModel
  factory ClassModel.fromMap(Map<String, dynamic> map) {
    return ClassModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      school: map['school'] ?? '',
    );
  }
}

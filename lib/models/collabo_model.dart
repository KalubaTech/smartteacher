import 'package:equatable/equatable.dart';

class CollaboModel extends Equatable {
  final String uid;
  final String classid;
  final String assessment;
  final List<dynamic> teachers;

  CollaboModel({
    required this.uid,
    required this.classid,
    required this.assessment,
    required this.teachers,
  });

  // Convert JSON to CollaboModel
  factory CollaboModel.fromJson(Map<String, dynamic> json) {
    return CollaboModel(
      uid: json['uid'] as String,
      classid: json['classid'] as String,
      assessment: json['assessment'] as String,
      teachers: List<dynamic>.from(json['teachers'] ?? []),
    );
  }

  // Convert CollaboModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'classid': classid,
      'assessment': assessment,
      'teachers': teachers,
    };
  }

  // Copy with method for immutability
  CollaboModel copyWith({
    String? uid,
    String? classid,
    String? assessment,
    List<dynamic>? teachers,
  }) {
    return CollaboModel(
      uid: uid ?? this.uid,
      classid: classid ?? this.classid,
      assessment: assessment ?? this.assessment,
      teachers: teachers ?? List.from(this.teachers),
    );
  }

  @override
  List<Object?> get props => [uid, classid, assessment, teachers];
}

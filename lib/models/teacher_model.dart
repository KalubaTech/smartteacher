class TeacherModel{
  String uid;
  String firstname;
  String lastname;
  String phone;
  String email;
  String password;
  String? photo;
  String school;
  bool isAdmin;

  TeacherModel({
    required this.uid,
    required this.firstname,
    required this.lastname,
    required this.email,
    required this.phone,
    required this.password,
    this.photo,
    required this.school,
    required this.isAdmin
  });
}
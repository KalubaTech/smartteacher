class NoticeModel {
  final String uid;
  final String subject;
  final String body;
  final String datetime;
  final String school;
  final String teacher;
  final List<String>targets;

  NoticeModel({
    required this.uid,
    required this.subject,
    required this.body,
    required this.teacher,
    required this.school,
    required this.targets,
    required this.datetime
  });
}
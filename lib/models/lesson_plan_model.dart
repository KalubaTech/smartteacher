
class LessonPlan  {
  final String subject;
  final String grade;
  final String topic;
  final String subtopic;
  final String time;
  final String duration;
  final String expBoys;
  final String expGirls;
  final String actBoys;
  final String actGirls;
  final String date;
  final String preRequisiteKnowledge;
  final List<String> objectives;
  final String ratContent;
  final String ratValue;
  final String ratPosition;
  final String ratStrategy;
  final String teachingLearningResources;
  final List<String> references;
  final List<dynamic> lessonDevelopment;
  final String conclusion;
  final String exercise;
  final String evaluation;
  final String teacher;
  final String year;

  const LessonPlan({
    required this.subject,
    required this.grade,
    required this.topic,
    required this.subtopic,
    required this.time,
    required this.duration,
    required this.expBoys,
    required this.expGirls,
    required this.actBoys,
    required this.actGirls,
    required this.date,
    required this.preRequisiteKnowledge,
    required this.objectives,
    required this.ratContent,
    required this.ratValue,
    required this.ratPosition,
    required this.ratStrategy,
    required this.teachingLearningResources,
    required this.references,
    required this.lessonDevelopment,
    required this.conclusion,
    required this.exercise,
    required this.evaluation,
    required this.teacher,
    required this.year
  });

  factory LessonPlan.fromMap(Map<String, dynamic> map) {
    return LessonPlan(
      subject: map['subject'] as String,
      grade: map['grade'] as String,
      topic: map['topic'] as String,
      subtopic: map['subtopic'] as String,
      time: map['time'] as String,
      duration: map['duration'] as String,
      expBoys: map['exp_boys'] as String,
      expGirls: map['exp_girls'] as String,
      actBoys: map['act_boys'] as String,
      actGirls: map['act_girls'] as String,
      date: map['date'] as String,
      preRequisiteKnowledge: map['pre_requisite_knowledge'] as String,
      objectives: List<String>.from(map['objectives'] as List),
      ratContent: map['rat_content'] as String,
      ratValue: map['rat_value'] as String,
      ratPosition: map['rat_position'] as String,
      ratStrategy: map['rat_strategy'] as String,
      teachingLearningResources: map['teaching_and_learning_resources'] as String,
      references: List<String>.from(map['references'] as List),
      lessonDevelopment: List<dynamic>.from(map['lesson_development'] as List),
      conclusion: map['conclusion'] as String,
      exercise: map['exercise'] as String,
      evaluation: map['evaluation'] as String,
      teacher: map['teacher'] as String,
      year: map['year'] as String
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'subject': subject,
      'grade': grade,
      'topic': topic,
      'subtopic': subtopic,
      'time': time,
      'duration': duration,
      'exp_boys': expBoys,
      'exp_girls': expGirls,
      'act_boys': actBoys,
      'act_girls': actGirls,
      'date': date,
      'pre_requisite_knowledge': preRequisiteKnowledge,
      'objectives': objectives,
      'rat_content': ratContent,
      'rat_value': ratValue,
      'rat_position': ratPosition,
      'rat_strategy': ratStrategy,
      'teaching_and_learning_resources': teachingLearningResources,
      'references': references,
      'lesson_development': lessonDevelopment,
      'conclusion': conclusion,
      'exercise': exercise,
      'evaluation': evaluation,
      'teacher': teacher,
      'year': year
    };
  }

  @override
  List<Object?> get props => [
    subject,
    grade,
    topic,
    subtopic,
    time,
    duration,
    expBoys,
    expGirls,
    actBoys,
    actGirls,
    date,
    preRequisiteKnowledge,
    objectives,
    ratContent,
    ratValue,
    ratPosition,
    ratStrategy,
    teachingLearningResources,
    references,
    lessonDevelopment,
    conclusion,
    exercise,
    evaluation,
    teacher,
    year
  ];
}
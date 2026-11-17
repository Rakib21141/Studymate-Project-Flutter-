class StudyPlan {
  final int id;
  final String subject;
  final String topic;
  final String notes;
  final bool isCompleted;

  StudyPlan({
    required this.id,
    required this.subject,
    required this.topic,
    required this.notes,
    required this.isCompleted,
  });

  // Converts one row from Supabase (a Map) into a StudyPlan object
  factory StudyPlan.fromMap(Map<String, dynamic> map) {
    return StudyPlan(
      id: map['id'],
      subject: map['subject'],
      topic: map['topic'],
      notes: map['notes'] ?? '',
      isCompleted: map['is_completed'] ?? false,
    );
  }
}

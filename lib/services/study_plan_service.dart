import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/study_plan_model.dart';

class StudyPlanService {
  final supabase = Supabase.instance.client;

  // READ: get all study plans of the logged-in student (newest first)
  Future<List<StudyPlan>> getStudyPlans() async {
    final studentId = supabase.auth.currentUser!.id;

    final data = await supabase
        .from('study_plans')
        .select()
        .eq('student_id', studentId)
        .order('created_at', ascending: false);

    return data.map<StudyPlan>((row) => StudyPlan.fromMap(row)).toList();
  }

  // CREATE: add a new study plan for the logged-in student
  Future<void> addStudyPlan(String subject, String topic, String notes) async {
    final studentId = supabase.auth.currentUser!.id;

    await supabase.from('study_plans').insert({
      'student_id': studentId,
      'subject': subject,
      'topic': topic,
      'notes': notes,
    });
  }

  // UPDATE: change subject, topic, notes and completed status
  Future<void> updateStudyPlan(
    int id,
    String subject,
    String topic,
    String notes,
    bool isCompleted,
  ) async {
    await supabase
        .from('study_plans')
        .update({
          'subject': subject,
          'topic': topic,
          'notes': notes,
          'is_completed': isCompleted,
        })
        .eq('id', id);
  }

  // DELETE: remove a study plan
  Future<void> deleteStudyPlan(int id) async {
    await supabase.from('study_plans').delete().eq('id', id);
  }
}

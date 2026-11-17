import 'package:flutter/material.dart';
import '../../models/study_plan_model.dart';
import '../../services/study_plan_service.dart';
import '../../widgets/study_plan_card.dart';

class StudyPlansScreen extends StatefulWidget {
  const StudyPlansScreen({super.key});

  @override
  State<StudyPlansScreen> createState() => _StudyPlansScreenState();
}

class _StudyPlansScreenState extends State<StudyPlansScreen> {
  final studyPlanService = StudyPlanService();
  List<StudyPlan> plans = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadPlans();
  }

  void showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  // READ
  Future<void> loadPlans() async {
    try {
      final result = await studyPlanService.getStudyPlans();
      if (!mounted) return;
      setState(() => plans = result);
    } catch (e) {
      if (mounted) showMessage('Could not load study plans: $e');
    }
    if (mounted) setState(() => isLoading = false);
  }

  // CREATE
  Future<void> showAddDialog() async {
    final subjectController = TextEditingController();
    final topicController = TextEditingController();
    final notesController = TextEditingController();

    final save = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Study Plan'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: subjectController,
                decoration: const InputDecoration(labelText: 'Subject'),
              ),
              TextField(
                controller: topicController,
                decoration: const InputDecoration(labelText: 'Topic'),
              ),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(labelText: 'Notes'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (save != true) return;
    if (subjectController.text.trim().isEmpty ||
        topicController.text.trim().isEmpty) {
      showMessage('Subject and topic cannot be empty');
      return;
    }

    setState(() => isLoading = true);
    try {
      await studyPlanService.addStudyPlan(
        subjectController.text.trim(),
        topicController.text.trim(),
        notesController.text.trim(),
      );
      await loadPlans();
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        showMessage('Could not add study plan: $e');
      }
    }
  }

  // UPDATE
  Future<void> showEditDialog(StudyPlan plan) async {
    final subjectController = TextEditingController(text: plan.subject);
    final topicController = TextEditingController(text: plan.topic);
    final notesController = TextEditingController(text: plan.notes);
    bool isCompleted = plan.isCompleted;

    // StatefulBuilder lets the checkbox change inside the dialog
    final save = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Study Plan'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: subjectController,
                  decoration: const InputDecoration(labelText: 'Subject'),
                ),
                TextField(
                  controller: topicController,
                  decoration: const InputDecoration(labelText: 'Topic'),
                ),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(labelText: 'Notes'),
                ),
                CheckboxListTile(
                  title: const Text('Completed'),
                  value: isCompleted,
                  onChanged: (value) {
                    setDialogState(() => isCompleted = value ?? false);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );

    if (save != true) return;
    if (subjectController.text.trim().isEmpty ||
        topicController.text.trim().isEmpty) {
      showMessage('Subject and topic cannot be empty');
      return;
    }

    setState(() => isLoading = true);
    try {
      await studyPlanService.updateStudyPlan(
        plan.id,
        subjectController.text.trim(),
        topicController.text.trim(),
        notesController.text.trim(),
        isCompleted,
      );
      await loadPlans();
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        showMessage('Could not update study plan: $e');
      }
    }
  }

  // DELETE
  Future<void> confirmDelete(StudyPlan plan) async {
    final delete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Study Plan?'),
        content: const Text('Are you sure you want to delete this study plan?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (delete != true) return;

    setState(() => isLoading = true);
    try {
      await studyPlanService.deleteStudyPlan(plan.id);
      await loadPlans();
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        showMessage('Could not delete study plan: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Study Plans')),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddDialog,
        child: const Icon(Icons.add),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : plans.isEmpty
              ? const Center(child: Text('No study plans yet. Tap + to add one.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: plans.length,
                  itemBuilder: (context, index) {
                    final plan = plans[index];
                    return StudyPlanCard(
                      plan: plan,
                      onEdit: () => showEditDialog(plan),
                      onDelete: () => confirmDelete(plan),
                    );
                  },
                ),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/study_plan_model.dart';

class StudyPlanCard extends StatelessWidget {
  final StudyPlan plan;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const StudyPlanCard({
    super.key,
    required this.plan,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        isThreeLine: true,
        title: Text(
          plan.subject,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(plan.topic, style: const TextStyle(fontWeight: FontWeight.w500)),
            if (plan.notes.isNotEmpty) Text(plan.notes),
            const SizedBox(height: 4),
            Text(
              plan.isCompleted ? '✓ Completed' : 'Pending',
              style: TextStyle(
                color: plan.isCompleted ? Colors.green : Colors.orange,
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') onEdit();
            if (value == 'delete') onDelete();
          },
          itemBuilder: (context) => const [
            PopupMenuItem(value: 'edit', child: Text('Edit')),
            PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
      ),
    );
  }
}

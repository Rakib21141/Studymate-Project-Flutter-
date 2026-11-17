import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/study_plan_model.dart';
import '../../services/auth_service.dart';
import '../../services/study_plan_service.dart';
import '../auth/login_screen.dart';
import '../study_plans/study_plans_screen.dart';
import '../profile/profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final studyPlanService = StudyPlanService();
  final authService = AuthService();
  List<StudyPlan> plans = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadPlans();
  }

  Future<void> loadPlans() async {
    try {
      final result = await studyPlanService.getStudyPlans();
      if (!mounted) return;
      setState(() => plans = result);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not load study plans: $e')),
      );
    }
    if (mounted) setState(() => isLoading = false);
  }

  Future<void> logout() async {
    await authService.logout();
    if (!mounted) return;
    // Remove all screens and show Login
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  // Open another screen, then refresh the numbers when we come back
  Future<void> openScreen(Widget screen) async {
    Navigator.pop(context); // close the drawer
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
    loadPlans();
  }

  Widget statCard(String title, int number, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Text(
                '$number',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(title),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final email = Supabase.instance.client.auth.currentUser?.email ?? '';
    final completed = plans.where((p) => p.isCompleted).length;
    final pending = plans.length - completed;
    final recentPlans = plans.take(5).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('StudyMate')),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.teal),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    'StudyMate',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                  const SizedBox(height: 8),
                  Text(email, style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.menu_book),
              title: const Text('Study Plans'),
              onTap: () => openScreen(const StudyPlansScreen()),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () => openScreen(const ProfileScreen()),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: logout,
            ),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Hello, Student',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const Text('Welcome back!'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    statCard('Total Plans', plans.length, Colors.teal),
                    statCard('Completed', completed, Colors.green),
                    statCard('Pending', pending, Colors.orange),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Recent Study Plans',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (recentPlans.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text('No study plans yet. Open Study Plans to add one.'),
                  ),
                for (final plan in recentPlans)
                  Card(
                    child: ListTile(
                      title: Text(plan.subject),
                      subtitle: Text(
                        '${plan.topic}\n${plan.isCompleted ? '✓ Completed' : 'Pending'}',
                      ),
                      isThreeLine: true,
                    ),
                  ),
              ],
            ),
    );
  }
}

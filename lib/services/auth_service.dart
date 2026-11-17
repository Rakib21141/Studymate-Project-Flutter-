import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final supabase = Supabase.instance.client;

  // Create a new account in Supabase Auth
  Future<void> register(String email, String password) async {
    await supabase.auth.signUp(email: email, password: password);
    // Some projects log the user in automatically after sign up.
    // We log out so the student goes to the Login screen.
    await supabase.auth.signOut();
  }

  // Check email + password and start a session
  Future<void> login(String email, String password) async {
    await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Send a password reset email
  Future<void> resetPassword(String email) async {
    await supabase.auth.resetPasswordForEmail(email);
  }

  // End the session
  Future<void> logout() async {
    await supabase.auth.signOut();
  }
}

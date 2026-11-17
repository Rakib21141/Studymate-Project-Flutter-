# StudyMate (Flutter + Supabase)

Simple student study planner: register, login, forgot password, per-student study plans (CRUD), drawer, profile, logout.

## 1. Supabase setup

1. Open your project in the Supabase Dashboard (https://jxptjryhdemekqufavup.supabase.co).
2. **Authentication -> Providers -> Email**: make sure Email is enabled.
   - "Confirm email" ON = student must click the link in the confirmation email before login.
   - "Confirm email" OFF = login works immediately (easier for testing).
3. If you used the same project for TaskMate, that is fine: StudyMate uses its own table (`study_plans`) and the same Auth users.

## 2. Run schema.sql

1. Dashboard -> **SQL Editor** -> **New query**.
2. Paste the whole content of `supabase/schema.sql`.
3. Click **Run**. Check **Table Editor** -> `study_plans` exists with RLS enabled.

(Run it only once. Running again gives "already exists" errors.)

## 3. Configuration

`lib/supabase_config.dart` already holds the URL and publishable key. Never put a service-role/secret key in the app.

## 4. Run the Flutter project

```bash
flutter create studymate
cd studymate
# replace the generated lib/ folder and pubspec.yaml with the ones from this project,
# and copy the supabase/ folder next to lib/
flutter pub get
flutter run
```

Android release builds need `<uses-permission android:name="android.permission.INTERNET"/>` in `android/app/src/main/AndroidManifest.xml` (debug builds already have it).

## 5. Viva explanation

- **Supabase**: a backend service that gives us authentication and a PostgreSQL database.
- **Authentication**: verifies the identity of a user using email and password.
- **CRUD**: C = Create, R = Read, U = Update, D = Delete.
- **RLS**: Row Level Security; it controls which database rows a user can access.
- **auth.uid()**: gives the ID of the currently authenticated user.
- **student_id**: connects a study plan to the student who created it.
- **ListView.builder()**: displays many study plans in a scrollable list.
- **StatefulWidget**: used because the study-plan list and loading state change while the app runs.
- **setState()**: tells Flutter to rebuild the screen after data changes.
- **signUp()**: creates a new user in Supabase Authentication.
- **signInWithPassword()**: checks the email and password and logs the user in.
- **signOut()**: logs the user out.
- **resetPasswordForEmail()**: sends a password-reset email.
- **Regex**: a pattern used to validate input such as an email address or password.

## 6. Common errors and fixes

| Error | Fix |
|---|---|
| `relation "public.study_plans" does not exist` | Run `supabase/schema.sql` in the SQL Editor. |
| `new row violates row-level security policy` | Policies missing, or not logged in. Re-run the policies and login again. |
| Study plan list always empty | Check you are logged in as the same student; each student sees only their own plans. |
| `Email not confirmed` on login | Click the link in the confirmation email, or turn off "Confirm email" in Auth -> Providers -> Email. |
| `Invalid login credentials` | Wrong email/password, or the account was never created. |
| `email rate limit exceeded` | Supabase limits auth emails per hour. Wait, or turn off "Confirm email" while testing. |
| `User already registered` | Use Login, or Forgot Password. |
| Build error about `anonKey` | Your supabase_flutter version uses a newer parameter name; use the one the error message suggests, same key. |
| `Failed host lookup` / network error | Check internet; add INTERNET permission for release builds. |
| `flutter pub get` fails | Check `flutter --version` is 3.19+ (Dart 3.3+) or lower the `sdk:` line in pubspec.yaml. |

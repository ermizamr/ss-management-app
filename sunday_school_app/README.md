# sunday_school_app

Flutter implementation of the Sunday School Management System based on the Figma design and existing React prototype.

## Run the app

From the project root:

```bash
cd sunday_school_app
flutter pub get
flutter run
```

The default start screen is the role selection page with **Student** and **Servant** options.

## Supabase configuration

The app is configured to talk to your Supabase project using:

- `SUPABASE_URL=https://jchmduashaoeueugzuss.supabase.co`
- `SUPABASE_ANON_KEY=...` (defined in `lib/core/config/supabase_config.dart`)

For production, consider moving these values to a more secure configuration mechanism.

## Architecture overview

- `lib/core/`
  - `config/supabase_config.dart` – Supabase URL and anon key.
  - `supabase/supabase_client.dart` – Initializes and exposes the Supabase client.
  - `routing/app_router.dart` – `go_router` configuration mirroring the React routes.
- `lib/features/`
  - `auth/presentation/role_selection_screen.dart`
  - `student/presentation/student_screens.dart`
  - `servant/presentation/servant_screens.dart`

## Testing

Basic widget testing is wired up:

- `test/widget_test.dart` verifies that `SundaySchoolApp` renders the role selection screen with the expected buttons.

Run tests with:

```bash
flutter test
```

import '../models/models.dart';

/// In-memory holder for the currently logged-in user. Set on successful login
/// or signup so screens (dashboards, bottom-nav rebuilt screens) can greet the
/// logged-in user by name. Not persisted across app restarts.
class AppSession {
  AppSession._();

  static AuthUser? currentUser;

  /// Clears the in-memory session. Called on logout so the app returns to an
  /// unauthenticated state before the role switcher is shown.
  static void clear() {
    currentUser = null;
  }
}

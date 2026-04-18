import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/auto_change_service.dart';

/// Auth State Provider
final authProvider = StreamProvider<AppUser?>((ref) {
  return AuthService.userStream;
});

/// Current User Provider
final currentUserProvider = Provider<AppUser?>((ref) {
  final authState = ref.watch(authProvider);
  return authState.value;
});

/// Is Logged In Provider
final isLoggedInProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user != null;
});

/// Auth Controller Provider
final authControllerProvider = StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
  return AuthController();
});

/// Auth Controller
class AuthController extends StateNotifier<AsyncValue<void>> {
  AuthController() : super(const AsyncValue.data(null));

  Future<void> signInWithEmail(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      await AuthService.signInWithEmailAndPassword(email, password);
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> signUpWithEmail(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      await AuthService.createUserWithEmailAndPassword(email, password);
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    try {
      await AuthService.signInWithGoogle();
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> signInWithGitHub() async {
    state = const AsyncValue.loading();
    try {
      await AuthService.signInWithGitHub();
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    try {
      await AuthService.signOut();
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

/// Auto Change Settings Provider
final autoChangeSettingsProvider = StreamProvider<AutoChangeSettings>((ref) {
  return AutoChangeService.settingsStream;
});

/// Auto Change Controller Provider
final autoChangeControllerProvider = StateNotifierProvider<AutoChangeController, AsyncValue<void>>((ref) {
  return AutoChangeController();
});

/// Auto Change Controller
class AutoChangeController extends StateNotifier<AsyncValue<void>> {
  AutoChangeController() : super(const AsyncValue.data(null));

  Future<void> updateSettings(AutoChangeSettings settings) async {
    state = const AsyncValue.loading();
    try {
      await AutoChangeService.updateSettings(settings);
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> toggleEnabled(bool enabled) async {
    final currentSettings = AutoChangeService.settings;
    await updateSettings(currentSettings.copyWith(enabled: enabled));
  }

  Future<void> setInterval(int minutes) async {
    final currentSettings = AutoChangeService.settings;
    await updateSettings(currentSettings.copyWith(intervalMinutes: minutes));
  }
}

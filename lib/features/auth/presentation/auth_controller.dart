import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/network/dio_client.dart';

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? errorMessage;
  final String? technicianName;
  final String? technicianRole;

  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.errorMessage,
    this.technicianName,
    this.technicianRole,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? errorMessage,
    String? technicianName,
    String? technicianRole,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      technicianName: technicianName ?? this.technicianName,
      technicianRole: technicianRole ?? this.technicianRole,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final FlutterSecureStorage _storage;

  AuthNotifier(this._storage)
      : super(const AuthState(
          isAuthenticated: false,
          technicianName: 'Carlos Mendoza',
          technicianRole: 'Técnico Instalador',
        ));

  Future<bool> login(String username, String password, bool rememberMe) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    // Simulated Sanctum authentication delay
    await Future.delayed(const Duration(milliseconds: 600));

    // Save token simulation
    await _storage.write(key: 'sanctum_token', value: 'demo_sanctum_token_12345');
    if (rememberMe) {
      await _storage.write(key: 'saved_username', value: username);
    }

    state = state.copyWith(
      isAuthenticated: true,
      isLoading: false,
      technicianName: 'Carlos Mendoza',
      technicianRole: 'Técnico Instalador',
    );
    return true;
  }

  Future<bool> loginBiometric() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    await Future.delayed(const Duration(milliseconds: 500));
    state = state.copyWith(
      isAuthenticated: true,
      isLoading: false,
      technicianName: 'Carlos Mendoza',
      technicianRole: 'Técnico Instalador',
    );
    return true;
  }

  Future<void> logout() async {
    await _storage.delete(key: 'sanctum_token');
    state = const AuthState(isAuthenticated: false);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return AuthNotifier(storage);
});

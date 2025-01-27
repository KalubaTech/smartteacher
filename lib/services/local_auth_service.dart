import 'package:local_auth/local_auth.dart';

class LocalAuthService {
  final LocalAuthentication _localAuth = LocalAuthentication();

  /// Check if device supports biometric authentication
  Future<bool> isBiometricAvailable() async {
    try {
      return await _localAuth.canCheckBiometrics && await _localAuth.isDeviceSupported();
    } catch (e) {
      print("Error checking biometric availability: $e");
      return false;
    }
  }

  /// Get a list of available biometric types (e.g., fingerprint, face recognition)
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      print("Error fetching available biometrics: $e");
      return [];
    }
  }

  /// Authenticate using biometrics
  Future<bool> authenticateWithBiometrics(String reason) async {
    try {
      final isBiometricAvailable = await _localAuth.isDeviceSupported();
      if (!isBiometricAvailable) {
        print("Biometric authentication not available");
        return false;
      }

      return await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: true, // Only use biometrics
          stickyAuth: true,    // Keeps the authentication session alive
        ),
      );
    } catch (e) {
      print("Error during biometric authentication: $e");
      return false;
    }
  }

  /// Authenticate with device PIN or pattern fallback
  Future<bool> authenticateWithFallback(String reason) async {
    try {
      return await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: false, // Allows fallback to PIN/pattern
          stickyAuth: true,     // Keeps the authentication session alive
        ),
      );
    } catch (e) {
      print("Error during fallback authentication: $e");
      return false;
    }
  }
}

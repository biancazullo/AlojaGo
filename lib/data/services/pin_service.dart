// lib/data/services/pin_service.dart
// Maneja los PINs de operador y administrador en Firestore
// Solo el admin puede modificarlos.
// Colección: system_config/pins -> { operatorPin, adminPin }

import 'package:cloud_firestore/cloud_firestore.dart';

class PinService {
  PinService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> get _pinsDoc =>
      _firestore.collection('system_config').doc('pins');

  /// Obtiene el PIN actual para un rol. Si no existe, retorna el default.
  Future<String> getPin({required bool isAdmin}) async {
    try {
      final snap = await _pinsDoc.get();
      if (!snap.exists) {
        // Primera vez: crear con defaults
        await _pinsDoc.set({
          'operatorPin': '1234',
          'adminPin': '9876',
          'updatedAt': FieldValue.serverTimestamp(),
        });
        return isAdmin ? '9876' : '1234';
      }
      final data = snap.data()!;
      return isAdmin
          ? (data['adminPin'] ?? '9876').toString()
          : (data['operatorPin'] ?? '1234').toString();
    } catch (_) {
      return isAdmin ? '9876' : '1234';
    }
  }

  /// Verifica si el PIN ingresado es correcto.
  Future<bool> verifyPin({
    required String inputPin,
    required bool isAdmin,
  }) async {
    final correctPin = await getPin(isAdmin: isAdmin);
    return inputPin.trim() == correctPin.trim();
  }

  /// Solo el admin puede actualizar los PINs.
  Future<void> updatePin({
    required String newOperatorPin,
    required String newAdminPin,
  }) async {
    await _pinsDoc.set({
      'operatorPin': newOperatorPin.trim(),
      'adminPin': newAdminPin.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}

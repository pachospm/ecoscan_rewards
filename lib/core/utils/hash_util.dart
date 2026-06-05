
import 'dart:convert';

import 'package:crypto/crypto.dart';

class HashUtil {
  HashUtil._();

  // Convertir una contraseña en texto plano a su hash SHA-256
  static String hashPassword(String password){
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Verificar si una constraseña coincide con el hash guardado
  static bool verifyPassword(String password, String hash){
    return hashPassword(password) == hash;
  }
}
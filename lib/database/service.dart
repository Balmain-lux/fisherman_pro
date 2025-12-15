import 'package:supabase_flutter/supabase_flutter.dart';

class Services {
  final Supabase _supabase = Supabase.instance;

  Future<bool> authDatabase(String email, String password) async {
    try {
      print('=== Попытка входа ===');
      print('Email: $email');

      final result = await _supabase.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      print('✅ Вход успешен!');
      print('Пользователь: ${result.user?.email}');

      return true;
    } catch (e) {
      print('❌ Ошибка входа: $e');
      return false;
    }
  }

  Future<bool> regDatabase(String email, String password) async {
    try {
      print('=== Попытка регистрации ===');
      print('Email: $email');

      final result = await _supabase.client.auth.signUp(
        email: email,
        password: password,
      );

      print('✅ Регистрация успешна!');
      print('Пользователь: ${result.user?.email}');

      return true;
    } catch (e) {
      print('❌ Ошибка регистрации: $e');
      return false;
    }
  }

  Future<void> logOut() async {
    await _supabase.client.auth.signOut();
  }
}

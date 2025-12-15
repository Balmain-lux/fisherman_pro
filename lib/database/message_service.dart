import 'package:supabase_flutter/supabase_flutter.dart';

class MessageService {
  final Supabase _supabase = Supabase.instance;

  Future<void> sendMessage(
    String? text,
    String? imageUrl,
    double? latitude,
    double? longitude,
    String? address,
  ) async {
    try {
      final user = _supabase.client.auth.currentUser;

      if (user == null) {
        throw Exception('Пользователь не авторизован');
      }

      await _supabase.client.from('messages').insert({
        'text': text,
        'image_url': imageUrl,
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
        'user_id': user.id,
        'user_name': user.email?.split('@').first ?? 'Рыбак',
        'created_at': DateTime.now().toIso8601String(),
      });

      print('✅ Сообщение отправлено');
    } catch (e) {
      print('❌ Ошибка отправки: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getMessages() async {
    try {
      final response = await _supabase.client
          .from('messages')
          .select('*')
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Ошибка получения сообщений: $e');
      return [];
    }
  }
}

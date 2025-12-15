import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

class StorageCloud {
  static const String bucketName = 'fishing-photos';

  Future<String?> uploadImage(XFile imageFile) async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) return null;

      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${user.id.substring(0, 8)}.jpg';
      final bytes = await imageFile.readAsBytes();

      await supabase.storage.from(bucketName).uploadBinary(fileName, bytes);

      final publicUrl = supabase.storage
          .from(bucketName)
          .getPublicUrl(fileName);

      print('🔗 Публичный URL: $publicUrl');
      return publicUrl;
    } catch (e) {
      print('❌ Ошибка: $e');
      return null;
    }
  }
}

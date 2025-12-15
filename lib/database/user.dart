import 'package:supabase_flutter/supabase_flutter.dart';

class Users {
  String? id;

  Users.fromSupabase(User user){
    id = user.id;
  }
}
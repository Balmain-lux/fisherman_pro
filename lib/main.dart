import 'package:flutter/material.dart';
import 'package:fisherman_pro/auth.dart';
import 'package:fisherman_pro/reg.dart';
import 'package:fisherman_pro/home.dart';
import 'package:fisherman_pro/chat_page.dart';
import 'package:fisherman_pro/create_message_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Supabase.initialize(
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Iml4a2ZtaHBmdGJqc3plbWVmd2VkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjUwNTE3MjIsImV4cCI6MjA4MDYyNzcyMn0.J3EDDwEQD8VxfV7LdX63CKEQ9w3h24ltlP6K1ha0Cc0',
      url: 'https://ixkfmhpftbjszemefwed.supabase.co',
    );

    print('✅ Supabase подключен!');
  } catch (e) {
    print('❌ Ошибка подключения: $e');
  }

  runApp(const AppTheme());
}

class AppTheme extends StatelessWidget {
  const AppTheme({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Используем конкретные цвета из Material Design
        primarySwatch: Colors.grey,
        primaryColor: Color(0xFF424242), // grey[900]
        scaffoldBackgroundColor: Color(0xFFFAFAFA), // grey[50]
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF424242), // grey[900]
          foregroundColor: Colors.white,
          elevation: 1,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF424242), // grey[900]
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.symmetric(vertical: 16),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFFE0E0E0)), // grey[300]
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFF424242)), // grey[900]
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        // Убрать cardTheme, если вызывает ошибку
      ),
      initialRoute: "/",
      routes: {
        "/": (context) => AuthPage(),
        "/reg": (context) => RegPage(),
        "/home": (context) => HomePage(),
        "/chat": (context) => ChatPage(),
        "/create": (context) => CreateMessagePage(),
      },
    );
  }
}

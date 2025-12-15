import 'package:flutter/material.dart';
import 'package:fisherman_pro/database/service.dart';
import 'package:motion_toast/motion_toast.dart';

class RegPage extends StatefulWidget {
  const RegPage({super.key});

  @override
  State<RegPage> createState() => _RegPageState();
}

class _RegPageState extends State<RegPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();
  TextEditingController repeatController = TextEditingController();
  Services services = Services();

  void showToast(String message, bool isSuccess) {
    if (isSuccess) {
      MotionToast.success(description: Text(message)).show(context);
    } else {
      MotionToast.error(description: Text(message)).show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text('Регистрация', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.grey.shade900,
        iconTheme: IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10), // Уменьшил отступ сверху

              Text(
                "Создайте аккаунт",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade900,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "Зарегистрируйтесь, чтобы присоединиться к сообществу рыбаков",
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),

              SizedBox(height: 30), // Уменьшил отступ
              // Поле email
              Text(
                'Email',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade800,
                ),
              ),
              SizedBox(height: 8),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  hintText: 'Введите ваш email',
                  prefixIcon: Icon(Icons.email, color: Colors.grey.shade700),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade800),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),

              SizedBox(height: 16), // Уменьшил отступ
              // Поле пароля
              Text(
                'Пароль',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade800,
                ),
              ),
              SizedBox(height: 8),
              TextField(
                controller: passController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Введите пароль',
                  prefixIcon: Icon(Icons.lock, color: Colors.grey.shade700),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade800),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),

              SizedBox(height: 16), // Уменьшил отступ
              // Поле повторения пароля
              Text(
                'Повторите пароль',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade800,
                ),
              ),
              SizedBox(height: 8),
              TextField(
                controller: repeatController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Введите пароль еще раз',
                  prefixIcon: Icon(Icons.lock, color: Colors.grey.shade700),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade800),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),

              SizedBox(height: 8), // Уменьшил отступ
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, size: 20, color: Colors.grey.shade700),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Пароль должен содержать минимум 6 символов',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24), // Уменьшил отступ
              // Кнопка регистрации
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    if (emailController.text.isEmpty ||
                        passController.text.isEmpty ||
                        repeatController.text.isEmpty) {
                      showToast('Заполните все поля', false);
                      return;
                    }

                    if (passController.text != repeatController.text) {
                      showToast('Пароли не совпадают', false);
                      return;
                    }

                    if (passController.text.length < 6) {
                      showToast(
                        'Пароль должен содержать минимум 6 символов',
                        false,
                      );
                      return;
                    }

                    final emailRegex = RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    );
                    if (!emailRegex.hasMatch(emailController.text)) {
                      showToast('Введите корректный email', false);
                      return;
                    }

                    print('Нажата кнопка регистрации');
                    final success = await services.regDatabase(
                      emailController.text,
                      passController.text,
                    );

                    if (success) {
                      showToast('Регистрация успешна!', true);
                      await Future.delayed(Duration(seconds: 2));
                      Navigator.pushReplacementNamed(context, '/home');
                    } else {
                      showToast(
                        'Ошибка регистрации. Возможно email уже используется',
                        false,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade900,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Зарегистрироваться',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 16), // Уменьшил отступ
              // Разделитель
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'или',
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                ],
              ),

              SizedBox(height: 16), // Уменьшил отступ
              // Кнопка входа
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.popAndPushNamed(context, '/');
                  },
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: Colors.grey.shade800),
                  ),
                  child: Text(
                    'Уже есть аккаунт? Войти',
                    style: TextStyle(
                      color: Colors.grey.shade800,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

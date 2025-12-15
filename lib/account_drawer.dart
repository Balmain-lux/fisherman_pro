import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AccountDrawer extends StatefulWidget {
  const AccountDrawer({super.key});

  @override
  State<AccountDrawer> createState() => _AccountDrawerState();
}

class _AccountDrawerState extends State<AccountDrawer> {
  final Supabase _supabase = Supabase.instance;
  User? _user;

  @override
  void initState() {
    super.initState();
    _user = _supabase.client.auth.currentUser;
  }

  Future<void> _signOut() async {
    await _supabase.client.auth.signOut();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.grey[50],
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: Colors.grey[900]),
              accountName: Text(
                _user?.email?.split('@').first ?? 'Рыбак',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              accountEmail: Text(
                _user?.email ?? 'Не указано',
                style: TextStyle(color: Colors.grey[300]),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.grey[800],
                child: Icon(Icons.person, color: Colors.white, size: 40),
              ),
            ),
            ListTile(
              leading: Icon(Icons.email, color: Colors.grey[700]),
              title: Text('Почта'),
              subtitle: Text(_user?.email ?? 'Не указано'),
            ),
            Divider(color: Colors.grey[300]),
            ListTile(
              leading: Icon(Icons.account_circle, color: Colors.grey[700]),
              title: Text('ID пользователя'),
              subtitle: Text(
                _user?.id.substring(0, 8) ?? 'Неизвестно',
                style: TextStyle(fontSize: 12),
              ),
            ),
            Divider(color: Colors.grey[300]),
            ListTile(
              leading: Icon(Icons.history, color: Colors.grey[700]),
              title: Text('Зарегистрирован'),
              subtitle: Text(_user != null ? 'Дата скрыта' : 'Неизвестно'),
            ),
            Spacer(),
            Container(
              padding: EdgeInsets.all(16),
              child: ElevatedButton.icon(
                onPressed: _signOut,
                icon: Icon(Icons.logout, color: Colors.white),
                label: Text('Выйти'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[800],
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

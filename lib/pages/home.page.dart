import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  final Key? key;

  HomePage({this.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<Map<String, String?>> _getUserData;

  @override
  void initState() {
    super.initState();
    _getUserData = _getUserDataAsync();
  }

  Future<Map<String, String?>> _getUserDataAsync() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    String? userEmail = prefs.getString('userEmail');
    return {'id': userId, 'email': userEmail};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Página Inicial'),
      ),
      body: FutureBuilder<Map<String, String?>>(
        future: _getUserData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar dados do usuário'));
          } else {
            final userData = snapshot.data!;
            return Center(
              child: Text(
                'Bem-vindo, ${userData['email']}! Seu ID é ${userData['id']}',
                style: TextStyle(fontSize: 24),
              ),
            );
          }
        },
      ),
    );
  }
}
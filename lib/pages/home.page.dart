import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './login.page.dart';


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
    String? userName = prefs.getString('userName');
    String? userProfile = prefs.getString('userProfile');
    return {'id': userId, 'email': userEmail, 'name': userName, 'perfil': userProfile};
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center, // Center the buttons vertically
                children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => HomePage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 51, 255, 0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Adicionar Medicamentos',
                        style: TextStyle(color: Color.fromARGB(255, 238, 238, 238),fontWeight: FontWeight.bold), // Cor do texto do botão
                      ),
                    ),
                    
                    SizedBox(width: 20),

                    ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => HomePage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 255, 0, 0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Remover Medicamentos',
                      style: TextStyle(color: Color.fromARGB(255, 255, 255, 255),fontWeight: FontWeight.bold), // Cor do texto do botão
                    ),
                  ),
                ]
              ) 
            );
          }
        },
      ),
    );
  }
}
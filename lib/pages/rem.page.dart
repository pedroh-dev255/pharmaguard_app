import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home.page.dart';

class RemPage extends StatefulWidget {
  const RemPage({super.key});

  @override
  State<RemPage> createState() => _RemPageState();
}

class _RemPageState extends State<RemPage> {

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_outlined),
          onPressed: (){
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          },
        ),
      ),
    );
  }
}
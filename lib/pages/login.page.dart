import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/gestures.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './home.page.dart';
import 'dart:convert';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);
  @override
  _LoginPageState createState() =>  _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();


  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    String? userEmail = prefs.getString('userEmail');

    // Se os dados do usuário já estiverem armazenados, redireciona para a Home
    if (userId != null && userEmail != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    }
  }


  void _launchURL() async {
    const url = "https://www.phsolucoes.site";
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      print('Não foi possível abrir o link: $url');
    }
  }

  Future<String?> fazerLogin(String email, String senha) async {
    var url = 'http://localhost/teste.php';

     try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': senha,
        }),
      );

      
      if (response.statusCode == 200) {

        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('userId', data['user']['id'].toString());
          await prefs.setString('userEmail', data['user']['email']);
          await prefs.setString('userName', data['user']['name']);
          await prefs.setString('userProfile', data['user']['profile']);

          return 'Login realizado com sucesso!';
        } else {
          print('Erro ao tentar fazer login: ${data['error']}');
          return 'Erro ao fazer login: ${data['error']}';
        }
      } else {
        print('Erro ao tentar fazer login: ${response.body}');
        return 'Erro ao fazer login: ${response.body}';
      }
    } catch (e) {
      print('Erro ao tentar fazer login: $e');
      return 'Erro ao tentar fazer login: $e';
    }
  }

  /*
  void _showAlert(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Atenção'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  */
  @override
  void dispose() {
    
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      backgroundColor: const Color.fromARGB(255, 85, 15, 206),
      body: Padding(
        padding: EdgeInsets.all(10),
        //child: SingleChildScrollView(
          child: Center(
            child: Form(
              key: _formKey,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        //TextStyle(color: Colors.white),
                      ),
                      padding: EdgeInsets.all(12),
                      child: Column(
                        children: [
                          SizedBox(height: 8),
                          const Text(
                            'Login',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          
                          TextFormField(
                            controller: _emailController,
                            autofocus: true,
                            keyboardType: TextInputType.emailAddress,
                            style: TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                              labelText: 'Email',
                              labelStyle: TextStyle(color: Colors.black),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                              ),
                            ),
                            validator: (value) {
                              if (value == null|| value.isEmpty  || !value.contains('@')|| !value.contains('.')) {
                                return 'Insira um email valido!';
                              }
                              return null;
                            },
                          ),

                          SizedBox(height: 20),

                          TextFormField(
                            controller: _senhaController,
                            autofocus: true,
                            keyboardType: TextInputType.visiblePassword,
                            obscureText: true,
                            style: TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                              labelText: 'Senha',
                              labelStyle: TextStyle(color: Colors.black),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Insira sua senha!';
                              }else if(value.length <= 5){
                                return 'Senha muito curta!';
                              }
                              return null;
                            },
                          ),

                          SizedBox(height: 30),

                          ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {

                                String email = _emailController.text;
                                String senha = _senhaController.text;

                                String? result = await fazerLogin(email, senha);

                                if (result != null) {

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(result)),
                                  );

                                  if (result.contains('Login realizado com sucesso')) {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(builder: (context) => HomePage()),
                                    );
                                  }
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(255, 255, 6, 118),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Acessar',
                              style: TextStyle(color: Color.fromARGB(255, 238, 238, 238),fontWeight: FontWeight.bold), // Cor do texto do botão
                            ),
                          ),
                        ],
                      ),
                    ),
                    Center(
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '@2024 ',
                              style: TextStyle(
                                color: const Color.fromARGB(255, 238, 238, 238),
                                fontWeight: FontWeight.bold,
                                height: 8,
                                fontSize: 15,
                              ),
                            ),
                            TextSpan(
                              text: 'PH Soluções',
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                                height: 8,
                                fontSize: 15,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = _launchURL,
                            ),
                          ],
                        ),
                      ),
                  ),
                ],
              ),
            ),
          ),
       // ),
      )
    );
  }
}
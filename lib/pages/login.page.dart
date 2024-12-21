import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);
  @override
  _LoginPageState createState() =>  _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 85, 15, 206),
      body: Padding(padding: EdgeInsets.all(10),
        child: Center(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(15),
                    //TextStyle(color: Colors.white),
                  ),
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      SizedBox(height: 8),
                      Text(
                        'Login',
                        style: TextStyle(
                          color: Colors.white, // Cor do texto
                          fontSize: 24, // Tamanho da fonte
                          fontWeight: FontWeight.bold, // Peso da fonte
                        ),
                      ),

                      TextFormField(
                        autofocus: true,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: TextStyle(color: Colors.white),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                      ),

                      SizedBox(height: 20),

                      TextFormField(
                        autofocus: true,
                        keyboardType: TextInputType.visiblePassword,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Senha',
                          labelStyle: TextStyle(color: Colors.white),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                      ),

                      SizedBox(height: 30),

                      ElevatedButton(
                        onPressed: () {
                          // Ação a ser realizada ao pressionar o botão
                          // Aqui você pode adicionar a lógica de login
                          print("Botão de Submit pressionado");
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 221, 221, 221), // Cor do botão
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10), // Raio das bordas do botão
                          ),
                        ),
                        child: Text(
                          'Submit',
                          style: TextStyle(color: const Color.fromARGB(255, 44, 44, 44)), // Cor do texto do botão
                        ),
                      )
                    ],
                  ),
                )
            ],
          ),
        ),
      )
    );
  }
}
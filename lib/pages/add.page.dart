import 'dart:ffi';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/config_service.dart';

import 'home.page.dart';

class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _principioController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _quantController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  late Future<Map<String, String?>> _getUserData;

  
  List<Map<String, String>> _armazens = [];
  String? _selectedArmazenamento;

  Future<void> _selectDate(BuildContext context) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.black,
              onPrimary: Color.fromARGB(255, 0, 238, 255),
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.black,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null) {
      setState(() {
        _dateController.text =
            "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}";
      });
    }
  }

  Future<Map<String, String?>> _getUserDataAsync() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    String? userEmail = prefs.getString('userEmail');
    String? userName = prefs.getString('userName');
    String? userProfile = prefs.getString('userProfile');
    return {
      'id': userId,
      'email': userEmail,
      'name': userName,
      'perfil': userProfile
    };
  }

  Future<void> _fetchArmazenamentos() async {
    final String? baseUrl = ConfigService.get("api_base_url");
    final String? listArmEndpoint = ConfigService.get("listArmazem_endpoint");
    try {
      final response = await http.get(Uri.parse("$baseUrl$listArmEndpoint"));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _armazens = data
              .map<Map<String, String>>((item) => {
                    "id": item["id"].toString(),
                    "nome": item["nome"].toString(),
                  })
              .toList();
        });
      } else {

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro na API: ${response.statusCode}")),
        );
        print("Erro na API: ${response.statusCode}");
        print("$baseUrl$listArmEndpoint");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao buscar dados: $e")),
      );
      print("Erro ao buscar dados: $e");
      print("$baseUrl$listArmEndpoint");
    }
  }

  Future<String?> adicionarMedic(String nome, String principio, String validade, String quantidade, String? armazem) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    var url = "${ConfigService.get("api_base_url")}${ConfigService.get("adicionar_endpoint")}";

     try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'nome': nome,
          'principio': principio,
          'validade':validade,
          'quantidade': quantidade,
          'armazem': armazem,
          'id_user': userId,
        }),
      );

      
      if (response.statusCode == 200) {

        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          return 'Login realizado com sucesso!';
        } else {
          print('Erro ao adicionar: ${data['error']}');
          return 'Erro ao adicionar: ${data['error']}';
        }
      } else {
        print('Erro ao tentar adicionar: ${response.body}');
        return 'Erro ao adicionar: ${response.body}';
      }
    } catch (e) {
      print('Erro ao tentar adicionar: $e');
      return 'Erro ao tentar adicionar: $e';
    }
  }

  @override
  void initState() {
    super.initState();
    _getUserData = _getUserDataAsync();
    _fetchArmazenamentos(); // Chama a função ao inicializar o widget
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_outlined),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              

              TextFormField(
                controller: _nomeController,
                autofocus: false,
                keyboardType: TextInputType.text,
                style: const TextStyle(color: Colors.black),
                decoration: const InputDecoration(
                  labelText: 'Nome Medicamento',
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
                    return 'Insira um nome válido!';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: _principioController,
                autofocus: false,
                keyboardType: TextInputType.text,
                style: const TextStyle(color: Colors.black),
                decoration: const InputDecoration(
                  labelText: 'Princípio Ativo',
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
                    return 'Insira um princípio válido!';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 30),

              TextFormField(
                controller: _dateController,
                readOnly: true,
                autofocus: false,
                style: const TextStyle(color: Colors.black),
                decoration: const InputDecoration(
                  labelText: 'Data de Validade',
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
                    return 'Insira uma data válida!';
                  }

                  try {
                    final selectedDate = DateTime.parse(value.split('/').reversed.join('-'));
                    if (selectedDate.isBefore(DateTime.now())) {
                      return 'Medicamento está vencido!';
                    }
                  } catch (e) {
                    return 'Formato de data inválido!';
                  }

                  return null;
                },
                onTap: () => _selectDate(context),
              ),

              const SizedBox(height: 30),

              TextFormField(
                controller: _quantController,
                autofocus: false,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.black),
                decoration: const InputDecoration(
                  labelText: 'Quantidade',
                  labelStyle: TextStyle(color: Colors.black),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty || value == 0) {
                    return 'Insira uma quantidade válida!';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 30),

              DropdownButtonFormField<String>(
                autofocus: false,
                decoration: const InputDecoration(
                  labelText: 'Armazenamento',
                  labelStyle: TextStyle(color: Colors.black),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
                items: _armazens
                    .map((armazem) => DropdownMenuItem<String>(
                          value: armazem["id"],
                          child: Text(armazem["nome"]!),
                        ))
                    .toList(),
                value: _selectedArmazenamento,
                onChanged: (value) {
                  setState(() {
                    _selectedArmazenamento = value;
                  });


                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Selecione um armazenamento válido!';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    print(_getUserData);

                    String nome = _nomeController.text;
                    String principio = _principioController.text;
                    String vencimento = _dateController.text;
                    String quantidade = _quantController.text;
                    String? armazenamento = _selectedArmazenamento;

                    String? result = await adicionarMedic(nome, principio, vencimento, quantidade, armazenamento);

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
                  print("Post: $_nomeController \n$_principioController\n$_dateController\n$_quantController\n$_selectedArmazenamento");
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 93, 255, 126),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text("Adicionar"),
              ),
              
            ],
          ),
        ),
      ),
    );
  }
}

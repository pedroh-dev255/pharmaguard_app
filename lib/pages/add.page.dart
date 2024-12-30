import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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

  void _showAlert(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Atenção'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<Map<String, String?>> _getUserDataAsync() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return {
      'id': prefs.getString('userId'),
      'email': prefs.getString('userEmail'),
      'name': prefs.getString('userName'),
      'perfil': prefs.getString('userProfile')
    };
  }

  Future<void> _fetchArmazenamentos() async {
    final String? baseUrl = ConfigService.get("api_base_url");
    final String? listArmEndpoint = ConfigService.get("listArmazem_endpoint");

    try {
      final response = await http.get(Uri.parse("$baseUrl$listArmEndpoint"))
        .timeout(const Duration(seconds: 2));
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
        _handleApiError(response.statusCode, "$baseUrl$listArmEndpoint");
      }
    } catch (e) {
      _handleApiError(null, "$baseUrl$listArmEndpoint", error: e);
    }
  }

  void _handleApiError(int? statusCode, String endpoint, {Object? error}) {
    String message = error != null
        ? "Erro ao buscar dados: $error"
        : "Erro na API: $statusCode";
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
    _showAlert("Banco de dados dos medicamentos não encontrado!!\n\nVerifique sua conexão");
    //print(message);
    //print(endpoint);
  }

  Future<String?> adicionarMedic(
      String nome, String principio, String validade, String quantidade, String? armazem) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    String url = "${ConfigService.get("api_base_url")}${ConfigService.get("adicionar_endpoint")}";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "nome": nome,
          "principio": principio,
          "validade": validade,
          "quantidade": quantidade,
          "armazem": armazem,
          "id_user": userId,
        }),)
        .timeout(const Duration(seconds: 5));

      return _processApiResponse(response);
    } catch (e) {
      //print('Erro ao tentar adicionar: $e');
      return 'Erro ao tentar adicionar o medicamento\n\nVerifique sua conexão.\n\nerror: $e';
    }
  }

  String? _processApiResponse(http.Response response) {
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['success'] == true
          ? 'Medicamento adicionado com sucesso!'
          : 'Erro ao adicionar(API): ${data['error']}';
    } else {
      //print('Erro ao tentar adicionar(API): ${response.body}');
      return 'Erro ao adicionar(API): ${response.body}';
    }
  }

  @override
  void initState() {
    super.initState();
    _getUserData = _getUserDataAsync();
    _fetchArmazenamentos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _buildTextField(
                controller: _nomeController,
                label: 'Nome Medicamento',
                validator: (value) => value == null || value.isEmpty
                    ? 'Insira um nome válido!'
                    : null,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _principioController,
                label: 'Princípio Ativo',
                validator: (value) => value == null || value.isEmpty
                    ? 'Insira um princípio válido!'
                    : null,
              ),
              const SizedBox(height: 30),
              _buildDateField(),
              const SizedBox(height: 30),
              _buildTextField(
                controller: _quantController,
                label: 'Quantidade',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty || int.tryParse(value) == 0) {
                    return 'Insira uma quantidade válida!';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              _buildDropdownField(),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _handleFormSubmit,
                child: const Text('Adicionar Medicamento'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black),
        border: const OutlineInputBorder(),
      ),
      validator: validator,
    );
  }

  Widget _buildDateField() {
    return TextFormField(
      controller: _dateController,
      style: const TextStyle(color: Colors.black),
      decoration: const InputDecoration(
        labelText: 'Data de Validade',
        labelStyle: TextStyle(color: Colors.black),
        border: OutlineInputBorder(),
      ),
      readOnly: true,
      onTap: () => _selectDate(context),
      validator: (value) => value == null || value.isEmpty
          ? 'Insira uma data válida!'
          : null,
    );
  }

  Widget _buildDropdownField() {
    return DropdownButtonFormField<String>(
      value: _selectedArmazenamento,
      items: _armazens
          .map((armazem) => DropdownMenuItem<String>(
                value: armazem['id'],
                child: Text(armazem['nome'] ?? ''),
              ))
          .toList(),
      decoration: const InputDecoration(
        labelText: 'Armazenamento',
        labelStyle: TextStyle(color: Colors.black),
        border: OutlineInputBorder(),
      ),
      onChanged: (value) => setState(() {
        _selectedArmazenamento = value;
      }),
      validator: (value) => value == null || value.isEmpty
          ? 'Selecione um armazenamento!'
          : null,
    );
  }

  void _handleFormSubmit() async {
    if (_formKey.currentState!.validate()) {
      String? response = await adicionarMedic(
        _nomeController.text,
        _principioController.text,
        _dateController.text,
        _quantController.text,
        _selectedArmazenamento,
      );

      if (response != null) {
        if (response.contains('sucesso')) {
          // Limpa o formulário
          _nomeController.clear();
          _principioController.clear();
          _dateController.clear();
          _quantController.clear();
          setState(() {
            _selectedArmazenamento = null;
          });

          // Exibe mensagem de sucesso
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response)),
          );
        } else {
          // Exibe mensagem de erro
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response)),
          );
        }
      }
    }
  }
}

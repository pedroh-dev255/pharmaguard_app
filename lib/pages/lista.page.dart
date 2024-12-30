//depedences
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
//services
import '../services/config_service.dart';
//pages
import 'home.page.dart';

class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage>  {
  bool _isLoading = false;
  List<Map<String, String>> _medicamentos = [];

  late Future<Map<String, String?>> _getUserData;

  @override
  void initState() {
    super.initState();
    _getUserData = _getUserDataAsync();
    _fetchMedicamentos();
  }

  Future<Map<String, String?>> _getUserDataAsync() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    String? userEmail = prefs.getString('userEmail');
    String? userName = prefs.getString('userName');
    String? userProfile = prefs.getString('userProfile');
    return {'id': userId, 'email': userEmail, 'name': userName, 'perfil': userProfile};
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

  Future<void> _fetchMedicamentos() async {
    setState(() {
      _isLoading = true;
    });

    final String? baseUrl = ConfigService.get("api_base_url");
    final String? listarEndpoint = ConfigService.get("listar_endpoint");

    try {
      final response = await http.get(Uri.parse("$baseUrl$listarEndpoint"))
        .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _medicamentos = data
              .map<Map<String, String>>((item) => {
                    "nome": item["Nome"].toString(),
                    "principio": item["Principio_Ativo"].toString(),
                    "quantidade": item["Quantidade"].toString(),
                    "validade": item["Validade"].toString(),
                  })
              .toList();
        });
      } else {
        _handleApiError(response.statusCode, "$baseUrl$listarEndpoint");
      }
    } catch (e) {
      _handleApiError(null, "$baseUrl$listarEndpoint", error: e);
    } finally {
      setState(() {
        _isLoading = false;
      });
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
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: AbsorbPointer(
              absorbing: _isLoading,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(height: 50),
                  const Text("Listagem de Medicamentos",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 40),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: "Buscar medicamento",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      print('Apertado');
                    },
                    child: const Text("Buscar"),
                  ),
                  if (_medicamentos.isNotEmpty) ...[
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: _medicamentos.length,
                      itemBuilder: (context, index) {
                        final medicamento = _medicamentos[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          elevation: 5,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Nome: ${medicamento['nome']}",
                                        style: const TextStyle(
                                            overflow: TextOverflow.ellipsis,
                                        ),
                                        softWrap: true,
                                      ),

                                      Text("Princípio: ${medicamento['principio']}",
                                        style: const TextStyle(
                                            overflow: TextOverflow.ellipsis,
                                        ),
                                        softWrap: true,
                                      ),
                                      Text("Quantidade: ${medicamento['quantidade']}"),
                                      Text("Validade: ${medicamento['validade']}"),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.cancel,
                                    color: Colors.red,
                                    size: 30.0,
                                  ),
                                  onPressed: () {
                                    print("Ícone de retirada pressionado");
                                  },
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                  if (_medicamentos.isEmpty && !_isLoading) ...[
                    const Text("Nenhum medicamento encontrado."),
                  ],
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
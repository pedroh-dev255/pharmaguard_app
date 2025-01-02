//depedences
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
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

  TextEditingController _searchController = TextEditingController();

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

  void _reload() {
    _fetchMedicamentos(); // Refaz o chamado para buscar os medicamentos
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Dados recarregados com sucesso!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  

Future<void> _fetchMedicamentos({String? searchQuery}) async {
  setState(() {
    _isLoading = true;
  });

  final String? baseUrl = ConfigService.get("api_base_url");
  final String? listarEndpoint = ConfigService.get("listar_endpoint");

  try {
    // Se não houver busca, faz a requisição GET
    if (searchQuery == null || searchQuery.isEmpty) {
      final response = await http.get(
        Uri.parse("$baseUrl$listarEndpoint"),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _medicamentos = data
              .map<Map<String, String>>((item) => {
                    'id': item['ID'],
                    "nome": item["Nome"].toString(),
                    "principio": item["Principio_Ativo"].toString(),
                    "armazenado": item["Armazenamento"].toString(),
                    "quantidade": item["Quantidade"].toString(),
                    "validade": item["Validade"].toString(),
                  })
              .toList();
        });
      } else {
        _handleApiError(response.statusCode, "$baseUrl$listarEndpoint");
      }
    } else {
      // Se houver busca, faz a requisição POST com o termo de pesquisa
      final response = await http.post(
        Uri.parse("$baseUrl$listarEndpoint"),
        headers: {
          "Content-Type": "application/json", // Especifica que o conteúdo será JSON
        },
        body: jsonEncode({
          "search": searchQuery ?? "", // Envia o termo de pesquisa
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _medicamentos = data
              .map<Map<String, String>>((item) => {
                    'id': item['ID'],
                    "nome": item["Nome"].toString(),
                    "principio": item["Principio_Ativo"].toString(),
                    "armazenado": item["Armazenamento"].toString(),
                    "quantidade": item["Quantidade"].toString(),
                    "validade": item["Validade"].toString(),
                  })
              .toList();
        });
      } else {
        _handleApiError(response.statusCode, "$baseUrl$listarEndpoint");
      }
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
    print(message);
    print(endpoint);
  }

  void _showRetiradaModal(Map<String, String> medicamento) async {
    // Fetch the list of doctors
    List<Map<String, String>> medicos = [];
    final String? baseUrl = ConfigService.get("api_base_url");
    final String? listMedicosEndpoint = ConfigService.get("list_medicos_endpoint");

    try {
      final response = await http.get(Uri.parse("$baseUrl$listMedicosEndpoint"))
        .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        medicos = data.map<Map<String, String>>((item) {
          return {
            "id": item["id"].toString(),
            "nome": item["nome"].toString(),
          };
        }).toList();
      }
    } catch (e) {
      print("Erro ao buscar lista de médicos: $e");
    }

    String? selectedMedico;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmação de Retirada"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Medicamento: ${medicamento['nome']}"),
              Text("Princípio Ativo: ${medicamento['principio']}"),
              Text("Local: ${medicamento['armazenado']}"),
              Text("Validade: ${medicamento['validade']}"),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: selectedMedico,
                hint: const Text("Selecione o médico"),
                items: medicos.map<DropdownMenuItem<String>>((medico) {
                  return DropdownMenuItem<String>(
                    value: medico['id'],
                    child: Text(medico['nome']!),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedMedico = value;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text("Cancelar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text("Salvar Alteração"),
              onPressed: () async {
                final String? retirarEndpoint = ConfigService.get("retirar_endpoint");
                SharedPreferences prefs = await SharedPreferences.getInstance();
                String? userId = prefs.getString('userId');

                if (selectedMedico == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Selecione um médico.")),
                     
                  );
                  _showAlert("Nenhum medico selecionado");
                  return;
                }

                try {
                  final response = await http.post(
                    Uri.parse("$baseUrl$retirarEndpoint"),
                    headers: {
                      "Content-Type": "application/json", // Especifica que o conteúdo será JSON
                    },
                    body: jsonEncode({
                      "id_usuario": userId,
                      "id_medico": selectedMedico,
                      "id_medicamento": medicamento['id'],
                    }),
                  );

                  if (response.statusCode == 200) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Retirada salva com sucesso.")),
                    );
                    Navigator.of(context).pop();
                    _reload();
                  } else {
                    _showAlert("Erro ao salvar retirada: ${response.body}");
                  }
                } catch (e) {
                  _showAlert("Erro ao enviar dados: $e");
                }
              },
            ),
          ],
        );
      },
    );
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _reload,
          ),
        ],
      ),

      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(18),
            child: AbsorbPointer(
              absorbing: _isLoading,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  
                  const SizedBox(height: 50),

                  const Text("Listagem de Medicamentos",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)  
                  ),
                  
                  const SizedBox(height: 40),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Expanded(
                        child: TextFormField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            labelText: "Buscar medicamento",
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          _fetchMedicamentos(searchQuery: _searchController.text);
                        },
                        child: const Text("Buscar"),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20), 

                  if (_medicamentos.isNotEmpty)
                  Expanded(
                    child: ListView.builder(
                      itemCount: _medicamentos.length,
                      itemBuilder: (context, index) {
                        final medicamento = _medicamentos[index];
                        
                        DateFormat dateFormat = DateFormat("dd/MM/yyyy");
                        DateTime validade = dateFormat.parse(medicamento['validade']!);

                        DateTime hoje = DateTime.now();
                        int diasParaVencimento = validade.difference(hoje).inDays;

                        // Verifica se a validade está vencida ou a 60 dias para vencer
                        Color cardColor;
                        if (diasParaVencimento < 0) {
                          cardColor = const Color.fromARGB(255, 253, 156, 149);  // Vencido
                        } else if (diasParaVencimento <= 60) {
                          cardColor = Colors.yellow;  // A 60 dias para vencer
                        } else {
                          cardColor = Colors.white;  // Normal
                        }

                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          elevation: 5,
                          color: cardColor,  // Aplica a cor ao card
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Coluna para os textos (Nome, Princípio, Quantidade, Validade)
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Nome: ${medicamento['nome']}",
                                        style: const TextStyle(
                                          overflow: TextOverflow.visible,
                                        ),
                                        softWrap: true,
                                      ),
                                      Text(
                                        "Princípio: ${medicamento['principio']}",
                                        style: const TextStyle(
                                          overflow: TextOverflow.visible,
                                        ),
                                        softWrap: true,
                                      ),
                                      Text("Local: ${medicamento['armazenado']}"),
                                      Text("Quantidade: ${medicamento['quantidade']}"),
                                      Text("Validade: ${DateFormat('dd/MM/yyyy').format(validade)}"),
                                    ],
                                  ),
                                ),
                                // Botão de retirada
                                IconButton(
                                  icon: const Icon(
                                    Icons.cancel,
                                    color: Colors.red,
                                    size: 30.0,
                                  ),
                                  onPressed: () {
                                    _showRetiradaModal(medicamento);
                                    print("id: ${medicamento['id']} - Ícone de retirada pressionado");
                                  },
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
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
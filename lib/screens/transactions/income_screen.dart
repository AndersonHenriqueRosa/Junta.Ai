import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:juntaai/receita.dart';
import 'package:juntaai/screens/home/home_screen.dart';
import 'package:juntaai/service/user_income_service.dart';
import 'package:juntaai/service/user_transactions_service.dart';

class IncomeScreen extends StatefulWidget {
  const IncomeScreen({super.key});

  @override
  State<IncomeScreen> createState() => _IncomeScreenState();
}

class _IncomeScreenState extends State<IncomeScreen> {
  final UserTransactionsService _userTransactionService =
      UserTransactionsService();

  final UserIncomeService _userIncomeService = UserIncomeService();

  final _formSignInKey = GlobalKey<FormState>();
  DateTime? _selectedDate;
  String? _selectedCategoryId;
  Map<String, String> _categories = {};

  final TextEditingController _valueController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final List<Receita> _receitas = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    Map<String, String> categories =
        await _userTransactionService.fetchCategories();
    setState(() {
      _categories = categories;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _addCategory() async {
    final TextEditingController _categoryController = TextEditingController();
    await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Adicionar Categoria'),
          content: TextField(
            controller: _categoryController,
            decoration:
                const InputDecoration(hintText: 'Nome da nova categoria'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                final newCategory = _categoryController.text.trim();
                if (newCategory.isNotEmpty) {
                  setState(() {
                    _categories['new_category_id'] = newCategory;
                    _selectedCategoryId = 'new_category_id';
                  });
                }
                Navigator.of(context).pop();
              },
              child: const Text('Adicionar'),
            ),
          ],
        );
      },
    );
  }

  void _saveData() async {
    if (_formSignInKey.currentState?.validate() ?? false) {
      // Obtém o nome da categoria usando o ID selecionado
      String categoryName =
          _categories[_selectedCategoryId!] ?? 'Categoria Desconhecida';

      final receita = Receita(
        data: _selectedDate,
        categoria: _selectedCategoryId,
        valor: double.tryParse(_valueController.text
            .replaceAll('R\$', '')
            .replaceAll('.', '')
            .replaceAll(',', '.')),
        descricao: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text, // Permite que a descrição seja nula
      );

      // Tenta adicionar a transação e captura o resultado
      bool success = await _userIncomeService.addTransactionIncome(
        _selectedCategoryId!, // Passa o ID da categoria
        categoryName, // Passa o nome da categoria
        receita.valor ?? 0.0, // Se valor for null, usa 0
        receita.descricao, // Pode ser nulo
        receita.data!,
      );

      // Exibe um modal com o resultado
      if (success) {
        // Se a transação foi bem-sucedida, mostre um diálogo de sucesso
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Sucesso'),
              content: const Text('Receita adicionada!'),
              actions: <Widget>[
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomeScreen(),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        );
      } else {
        // Se houve um erro, mostre um diálogo de erro
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Erro'),
              content: const Text(
                  'Ocorreu um erro ao salvar a transação. Tente novamente.'),
              actions: <Widget>[
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop(); // Fecha o diálogo
                  },
                ),
              ],
            );
          },
        );
      }

      setState(() {
        _receitas.add(receita);
      });

      // Limpar o formulário
      _formSignInKey.currentState?.reset();
      _valueController.clear();
      _descriptionController.clear();
      _selectedDate = null;
      _selectedCategoryId = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: (){
          Navigator.pop(context);
        }, icon: Icon(Icons.arrow_back
        )),
        title: const Text(
          "Receita",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.green,
        elevation: 0,
      ),
      body: Container(
        color: Colors.green, // Cor de fundo da tela
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white, // Cor de fundo do conteúdo
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40.0),
                    topRight: Radius.circular(40.0),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(25.0, 50.0, 25.0, 20.0),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formSignInKey,
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start, // Alinhamento à esquerda
                      children: [
                        const SizedBox(height: 20.0),
                        Text(
                          'Data',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        GestureDetector(
                          onTap: () => _selectDate(context),
                          child: AbsorbPointer(
                            child: TextFormField(
                              controller: TextEditingController(
                                text: _selectedDate != null
                                    ? "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}"
                                    : '',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Selecione uma data';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                labelText: 'Selecione a Data',
                                hintText: 'DD/MM/AAAA',
                                hintStyle: const TextStyle(
                                  color: Colors.black26,
                                ),
                                border: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Colors.black12,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Colors.black12,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        Text(
                          'Categoria',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _selectedCategoryId,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedCategoryId = newValue;
                                  });
                                },
                                items: _categories.entries.map((entry) {
                                  return DropdownMenuItem<String>(
                                    value: entry.key,
                                    child: Text(entry.value),
                                  );
                                }).toList(),
                                decoration: InputDecoration(
                                  labelText: 'Selecione uma Categoria',
                                  border: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Colors.black12,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Colors.black12,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Selecione uma categoria';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add, color: Colors.green),
                              onPressed: _addCategory,
                              tooltip: 'Adicionar Categoria',
                            ),
                          ],
                        ),
                        const SizedBox(height: 20.0),
                        Text(
                          'Valor',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        TextFormField(
                          controller: _valueController,
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            CurrencyTextInputFormatter(),
                          ],
                          decoration: InputDecoration(
                            hintText: 'Valor R\$',
                            border: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.black12,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.black12,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                value == 'R\$ 0.00') {
                              return 'Entre com o valor';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20.0),
                        Text(
                          'Descrição',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        TextFormField(
                          controller: _descriptionController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: 'Descrição',
                            border: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.black12,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.black12,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        const SizedBox(height: 40.0),
                        ElevatedButton(
                          onPressed: _saveData,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            minimumSize: const Size.fromHeight(50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                              style: TextStyle(color: Colors.white), 'Salvar'),
                        ),
                      ],
                    ),
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

class CurrencyTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: 'R\$ 0.00');
    }

    final number =
        double.tryParse(newValue.text.replaceAll(RegExp('[^\d]'), ''));

    if (number == null) {
      return newValue;
    }

    final formattedValue =
        'R\$ ${number.toStringAsFixed(2).replaceAll('.', ',')}';
    return newValue.copyWith(text: formattedValue);
  }
}

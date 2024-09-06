import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:juntaai/receita.dart';

class IncomeScreen extends StatefulWidget {
  const IncomeScreen({super.key});

  @override
  State<IncomeScreen> createState() => _IncomeScreenState();
}

class _IncomeScreenState extends State<IncomeScreen> {
  final _formSignInKey = GlobalKey<FormState>();
  DateTime? _selectedDate;
  String? _selectedCategory;
  String? _selectedStatus = 'Realizado'; // Inicializa como 'Realizado'
  final List<String> _categories = [
    'Alimentação',
    'Transporte',
    'Educação',
    'Saúde',
    'Lazer',
    'Outros',
  ];

  final List<String> _statusOptions = ['Realizado', 'previsto']; // Lista de status

  final TextEditingController _valueController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // Lista para armazenar as receitas
  final List<Receita> _receitas = [];

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
            decoration: const InputDecoration(hintText: 'Nome da nova categoria'),
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
                    _categories.add(newCategory);
                    _selectedCategory = newCategory;
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

  void _saveData() {
    if (_formSignInKey.currentState?.validate() ?? false) {
      final receita = Receita(
        data: _selectedDate,
        categoria: _selectedCategory,
        valor: double.tryParse(_valueController.text.replaceAll('R\$', '').replaceAll('.', '').replaceAll(',', '.')),
        status: _selectedStatus,
        descricao: _descriptionController.text,
      );

      setState(() {
        _receitas.add(receita);
      });

      // Limpar o formulário
      _formSignInKey.currentState?.reset();
      _valueController.clear();
      _descriptionController.clear();
      _selectedDate = null;
      _selectedCategory = null;
      _selectedStatus = 'Realizado';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
                      crossAxisAlignment: CrossAxisAlignment.start, // Alinhamento à esquerda
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
                                value: _selectedCategory,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedCategory = newValue;
                                  });
                                },
                                items: _categories.map((String category) {
                                  return DropdownMenuItem<String>(
                                    value: category,
                                    child: Text(category),
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
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
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
                            if (value == null || value.isEmpty || value == 'R\$ 0.00') {
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
                        Text(
                          'Status',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        DropdownButtonFormField<String>(
                          value: _selectedStatus,
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedStatus = newValue;
                            });
                          },
                          items: _statusOptions.map((String status) {
                            return DropdownMenuItem<String>(
                              value: status,
                              child: Text(status),
                            );
                          }).toList(),
                          decoration: InputDecoration(
                            labelText: 'Selecione o Status',
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
                        const SizedBox(height: 30.0),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _saveData,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(20.0),
                              child: Text(
                                'Salvar',
                                style: TextStyle(fontSize: 16.0),
                              ),
                            ),
                          ),
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

    final number = double.tryParse(newValue.text.replaceAll(RegExp('[^\d]'), ''));

    if (number == null) {
      return newValue;
    }

    final formattedValue = 'R\$ ${number.toStringAsFixed(2).replaceAll('.', ',')}';
    return newValue.copyWith(text: formattedValue);
  }
}

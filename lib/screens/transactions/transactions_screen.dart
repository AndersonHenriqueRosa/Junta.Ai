import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:juntaai/service/user_transactions_service.dart';
import 'package:juntaai/widgets/income_expense_card.dart';
import 'package:juntaai/widgets/transactions_list.dart'; 

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final UserTransactionsService _userTransactionsService = UserTransactionsService();
  DateTime selectedMonth = DateTime.now(); 
  bool showOnlyIncome = false; 
  bool showOnlyExpense = false; 
  bool isLoading = true; 
  List<TransactionsData> transactions = [];

  double totalIncome = 0.0;
  double totalExpense = 0.0;

String getFormattedMonth(DateTime date) {
  String formattedDate = DateFormat.yMMMM('pt_BR').format(date);
  return formattedDate[0].toUpperCase() + formattedDate.substring(1);
}


  Future<void> _selectMonth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedMonth,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.orange, 
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedMonth) {
      setState(() {
        selectedMonth = picked;
        _fetchTransactions(); 
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchTransactions(); 
  }

Future<void> _fetchTransactions() async {
  setState(() {
    isLoading = true; 
  });

  try {
    final transactionsData = await _userTransactionsService.fetchTransactionsByMonth(
      selectedMonth: selectedMonth,
      showOnlyIncome: showOnlyIncome, 
      showOnlyExpense: showOnlyExpense, 
    );

    double totalIncomeTemp = 0.0;
    double totalExpenseTemp = 0.0;

    List<TransactionsData> mappedTransactions = transactionsData.map((transaction) {
      double amount = transaction['amount']?.toDouble() ?? 0.0;
      
      if (transaction['type'] == 'income') {
        totalIncomeTemp += amount; 
      } else if (transaction['type'] == 'expense') {
        totalExpenseTemp += amount; 
      }

      return TransactionsData(
        categoryName: transaction['categoryName'] ?? 'Sem descrição',
        amount: amount,
        date: transaction['date']?.toDate().toString() ?? 'Data desconhecida',
        type: transaction['type'] ?? 'other',
      );
    }).toList();

    setState(() {
      transactions = mappedTransactions;
      totalIncome = totalIncomeTemp; 
      totalExpense = totalExpenseTemp; 
      isLoading = false; 
    });
  } catch (e) {
    setState(() {
      isLoading = false; 
    });
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
          "Transações",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.orange,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: Colors.orange,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8.0),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () => _selectMonth(context),
                      icon: const Icon(Icons.arrow_drop_down),
                      label: Text(getFormattedMonth(selectedMonth)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              showOnlyIncome = !showOnlyIncome;
                              showOnlyExpense = false;
                              _fetchTransactions();
                            });
                          },
                          child: IncomeExpenseCard(
                            expenseData: ExpenseData(
                              Icons.arrow_upward_rounded,
                              "Receita",
                              totalIncome,
                            ),
                            active: !showOnlyExpense || showOnlyIncome,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              showOnlyExpense = !showOnlyExpense;
                              showOnlyIncome = false;
                              _fetchTransactions();
                            });
                          },
                          child: IncomeExpenseCard(
                            expenseData: ExpenseData(
                              Icons.arrow_downward_rounded,
                              "Despesa",
                              totalExpense,                            
                              ),
                            active: !showOnlyIncome || showOnlyExpense,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.fromLTRB(25.0, 20.0, 25.0, 20.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
              ),
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : TransactionsList(transactions: transactions), 
            ),
          ),
        ],
      ),
    );
  }
}

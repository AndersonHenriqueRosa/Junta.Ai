enum TransactionType {
  outFlow,
  inFlow,
}

enum ItemCategoryType {
  alimento,
  transporte,
  conta,
}

class UserInfo {
  final String name;
  final String totalBalance;
  final String inFlow;
  final String outFlow;
  final List<Transaction> transaction;

  const UserInfo({
    required this.name,
    required this.totalBalance,
    required this.inFlow,
    required this.outFlow,
    required this.transaction,
  });
}

class Transaction {
  final ItemCategoryType categoryType;
  final TransactionType transactionType;
  final String itemCategoryName; // Renomeado para camelCase
  final String itemName; // Renomeado para camelCase
  final String amount;
  final String date;

  const Transaction(
    this.categoryType,
    this.transactionType,
    this.itemCategoryName, // Atualizado
    this.itemName, // Atualizado
    this.amount,
    this.date,
  );
}

const List<Transaction> transaction = [
  Transaction(
    ItemCategoryType.conta,
    TransactionType.inFlow,
    "Trabalho",
    "Venda de bebida",
    "R\$ 780.00",
    "02, Set",
  ),
  Transaction(
    ItemCategoryType.conta,
    TransactionType.outFlow,
    "Casa",
    "Aluguel",
    "R\$ 780.00",
    "02, Set",
  ),
];

const userdata = UserInfo(
  name: "Anderson",
  totalBalance: "R\$ 4,500.00",
  inFlow: "R\$ 6,000.00",
  outFlow: "R\$ 1,500.00",
  transaction: transaction,
);

import 'dart:math';
import 'package:expense_2/components/chart.dart';
import 'package:expense_2/components/transacrion_list.dart';
import 'package:expense_2/components/transaction_form.dart';
import 'package:expense_2/models/transaction.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';

main() => runApp(ExpenseApp());

class ExpenseApp extends StatelessWidget {
  final ThemeData tema = ThemeData();

  ExpenseApp({super.key});

  @override
  Widget build(Object context) {
    return MaterialApp(
      home: const MyHomePage(),
      theme: tema.copyWith(
        colorScheme: tema.colorScheme.copyWith(
          primary: const Color.fromARGB(255, 185, 57, 207),
          secondary: const Color.fromARGB(255, 235, 206, 216),
        ),
        textTheme: tema.textTheme.copyWith(
          titleLarge: const TextStyle(
            fontFamily: 'OpenSans',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          labelLarge: const TextStyle(
            color: Color.fromARGB(255, 214, 151, 172),
            fontWeight: FontWeight.bold,
          ),
        ),
        appBarTheme: const AppBarTheme(
          titleTextStyle: TextStyle(
            fontFamily: 'OpenSans',
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<StatefulWidget> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Transaction> _transactions = [];
  bool _showChart = false;

  List<Transaction> get _recentTransactions {
    return _transactions.where((tr) {
      return tr.date.isAfter(DateTime.now().subtract(
        const Duration(days: 7),
      ));
    }).toList();
  }

  _addTransaction(String title, double value, DateTime date) {
    final newTransaction = Transaction(
      id: Random().nextDouble().toString(),
      title: title,
      value: value,
      date: date,
    );

    setState(() {
      _transactions.add(newTransaction);
    });
    Navigator.of(context).pop();
  }

  _removeTransaction(String id) {
    setState(() {
      _transactions.removeWhere((tr) => tr.id == id);
    });
  }

  _openTransactionFormModal(BuildContext context) {
    showModalBottomSheet(
      //isScrollControlled: true,
      context: context,
      builder: (_) {
        return TransactionForm((_addTransaction));
      },
    );
  }

  Widget _getIconButton(IconData icon, Function() fn) {
    return Platform.isIOS
        ? GestureDetector(
            onTap: fn,
            child: Icon(icon),
          )
        : IconButton(
            icon: Icon(icon),
            onPressed: fn,
          );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    bool isLandScape = mediaQuery.orientation == Orientation.landscape;

    final iconList = Platform.isIOS ? CupertinoIcons.refresh : Icons.list;
    final chartList = Platform.isIOS ? CupertinoIcons.refresh : Icons.show_chart;

    final actions = [
      _getIconButton(
        Platform.isIOS ? CupertinoIcons.add : Icons.add,
        () => _openTransactionFormModal(context),
      ),
      if (isLandScape)
        _getIconButton(
          _showChart ? iconList : chartList,
          () {
            setState(() {
              _showChart = !_showChart;
            });
          },
        ),
    ];

    final appBar = AppBar(
      title: const Text(
        'Personal Expenses',
        /*style: TextStyle(
          fontSize: mediaQuery.textScaler.scale(20),
        ),*/
      ),
      centerTitle: true,
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Theme.of(context).colorScheme.secondary,
      actions: actions,
    );
    final availbleHeight = mediaQuery.size.height - appBar.preferredSize.height - mediaQuery.padding.top;
    final bodyHomePage = SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (isLandScape)
              /*Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Exibir Grafo'),
                  Switch.adaptive(
                      value: _showChart,
                      activeColor: Theme.of(context).colorScheme.primary,
                      onChanged: (value) {
                        setState(() {
                          _showChart = value;
                        });
                      }),
                ],
              ),*/
              if (_showChart || !isLandScape)
                SizedBox(
                  height: availbleHeight * (isLandScape ? 0.8 : 0.3),
                  child: Chart(_recentTransactions),
                ),
            if (!_showChart || !isLandScape)
              SizedBox(
                height: availbleHeight * (isLandScape ? 1 : 0.7),
                child: TransactionList(_transactions, _removeTransaction),
              ),
            /* _showChart
                ?
                 Container(
                    height: availbleHeight * 0.3,
                    child: Chart(_recentTransactions),
                  )
                : Container(
                    height: availbleHeight * 0.7,
                    child: TransactionList(_transactions, _removeTransaction),
                  ),
          ,*/
          ],
        ),
      ),
    );

    return Platform.isIOS
        ? CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
              middle: const Text('Despesas Pessoais'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: actions,
              ),
            ),
            child: bodyHomePage,
          )
        : Scaffold(
            appBar: appBar,
            body: bodyHomePage,
            floatingActionButton: Platform.isIOS
                ? Container()
                : FloatingActionButton(
                    onPressed: () => _openTransactionFormModal(context),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.secondary,
                    child: const Icon(Icons.add),
                  ),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          );
  }
}

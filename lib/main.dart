import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import './components/new_transaction.dart';
import './components/transaction_list.dart';
import './components/chart.dart';
import './model/transaction.dart';

void main() {
  runApp(
    MyApp(),
  );
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomeApp(),
      title: 'My Expenses.',
      theme: ThemeData(
        primaryColor: Colors.black,
        accentColor: Colors.deepOrangeAccent,
        errorColor: Colors.red,
        fontFamily: 'Quicksand',
        textTheme: ThemeData.light().textTheme.copyWith(
              headline6: TextStyle(
                  //color: Colors.white,
                  fontFamily: 'OpenSans',
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold),
              button: TextStyle(color: Colors.white),
            ),
        appBarTheme: AppBarTheme(
          textTheme: ThemeData.light().textTheme.copyWith(
                headline6: TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: 25.0,
                    fontWeight: FontWeight.bold),
              ),
        ),
      ),
    );
  }
}

class MyHomeApp extends StatefulWidget {
  // This widget is the root of your application.

  @override
  _MyHomeAppState createState() => _MyHomeAppState();
}

class _MyHomeAppState extends State<MyHomeApp> {
  final List<Transaction> _userTransactions = [
    Transaction(
      id: 't1',
      title: 'Shoes',
      amount: 66.65,
      date: DateTime.now(),
    ),
    Transaction(
      id: 't2',
      title: 'Foods',
      amount: 40.35,
      date: DateTime(2020, 10, 6),
    ),
    Transaction(
      id: 't3',
      title: 'Coffee',
      amount: 45.05,
      date: DateTime.now(),
    ),
    Transaction(
      id: 't5',
      title: 'Phone',
      amount: 46.95,
      date: DateTime.now(),
    )
  ];

  List<Transaction> get _recentTransactions {
    return _userTransactions.where((transaction) {
      return transaction.date.isAfter(
        DateTime.now().subtract(
          Duration(days: 7),
        ),
      );
    }).toList();
  }

  void _addNewTransaction(String title, double amount, DateTime selectedDate) {
    final newTransaction = Transaction(
      id: DateTime.now().toString(),
      title: title,
      amount: amount,
      date: selectedDate,
    );
    setState(() {
      _userTransactions.add(newTransaction);
    });
  }

  void _showAddNewTransaction(BuildContext cxt) {
    showModalBottomSheet(
      context: cxt,
      builder: (_) {
        return GestureDetector(
          child: NewTransaction(_addNewTransaction),
          onTap: () {},
          behavior: HitTestBehavior.opaque,
        );
      },
    );
  }

  void _deleteTransaction(String id) {
    setState(() {
      _userTransactions.removeWhere((transaction) => transaction.id == id);
    });
  }

  bool _showSwitchedCard = false;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    //check if landscape is chosen.
    final isLandScape = mediaQuery.orientation == Orientation.landscape;

    final PreferredSizeWidget appBar = Platform.isIOS
        ? CupertinoNavigationBar(
            middle: Text('My Expenses'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () => _showAddNewTransaction(context),
                  child: Icon(CupertinoIcons.add),
                )
              ],
            ),
          )
        : AppBar(
            title: Text('My Expenses'),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () => _showAddNewTransaction(context),
              )
            ],
          );

    final transactionList = Container(
      height: (mediaQuery.size.height -
              mediaQuery.padding.top -
              appBar.preferredSize.height) *
          0.70,
      child: TransactionList(_userTransactions, _deleteTransaction),
    );

    final pageBody = SafeArea(
      child: SingleChildScrollView(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (isLandScape)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Show Card',
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    Switch.adaptive(
                        activeColor: Theme.of(context).accentColor,
                        value: _showSwitchedCard,
                        onChanged: (val) {
                          setState(() {
                            _showSwitchedCard = val;
                          });
                        })
                  ],
                ),
              if (isLandScape)
                _showSwitchedCard
                    ? Container(
                        height: (mediaQuery.size.height -
                                mediaQuery.padding.top -
                                appBar.preferredSize.height) *
                            0.7,
                        child: Chart(_recentTransactions),
                      )
                    : transactionList,
              if (!isLandScape)
                Container(
                  height: (mediaQuery.size.height -
                          mediaQuery.padding.top -
                          appBar.preferredSize.height) *
                      0.25,
                  child: Chart(_recentTransactions),
                ),
              if (!isLandScape) transactionList
            ]),
      ),
    );

    return Platform.isIOS
        ? CupertinoPageScaffold(
            navigationBar: appBar,
            child: pageBody,
          )
        : Scaffold(
            backgroundColor: Colors.black54,
            appBar: appBar,
            body: pageBody,
            floatingActionButton: Platform.isIOS
                ? Container()
                : FloatingActionButton(
                    child: Icon(Icons.add),
                    onPressed: () => _showAddNewTransaction(context),
                  ),
          );
  }
}

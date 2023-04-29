
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moor_flutter/moor_flutter.dart' hide Column;
import 'package:percent_indicator/percent_indicator.dart';
import 'package:thrifty/account.dart';
import 'package:thrifty/database.dart';
import 'package:thrifty/login.dart';
import 'package:intl/intl.dart';



class ExpensesPage extends StatefulWidget {
  get expenses => null;
  @override
  _ExpensesPageState createState() => _ExpensesPageState();


}

class _ExpensesPageState extends State<ExpensesPage> {
  @override
  bool _isLoading = true;
  final GlobalKey<FormState> _keyDialogForm = new GlobalKey<FormState>();

  void initState() {
   _loadData();
  }

  List<Map<String, dynamic>> all_expenses = [];


  Widget build(BuildContext context) {

    if (_isLoading) {
      return Scaffold(

        backgroundColor: Colors.white,
        body: Center(
          child: Container(
            child: CircularProgressIndicator( valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),),
          ),
        ),
      );
    }

    else {
    return Scaffold(
      drawer: MyDrawer(),
      body: Builder(
        builder: (context) => Stack(
            children: [
        Container(
        decoration: BoxDecoration(
        image: DecorationImage(
            image: AssetImage("assets/images/background.png"),
        fit: BoxFit.cover,
           ),
         ),),

              Column(
              children: [
                Padding(padding: EdgeInsets.only(top:20)),
                Text('All Expenses', style: TextStyle(fontSize: 25, color: Colors.redAccent, fontWeight: FontWeight.bold),),

              Expanded(

               child: ListView(
              children: [
                Container(
                child: SingleChildScrollView(
                child: Column(
                    children: [

                      all_expenses.isEmpty
                          ? Center(child: Text('No Data', style: const TextStyle(fontSize: 20),))
                          : SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: DataTable(
                                      showCheckboxColumn: false,
                                      horizontalMargin: 10,
                                      columnSpacing:10,
                                      columns: const [
                                        DataColumn(
                                            label: Text('',
                                                style: TextStyle(
                                                    color: Colors.transparent
                                                ),
                                            ),

                                        ),
                                        DataColumn(label: Text('Category')),
                                        DataColumn(label: Text('Amount')),
                                        DataColumn(label: Text('Date')),
                                        DataColumn(label: Text('Edit')),
                                      ],
                                      rows: all_expenses
                                          .map((expense) => DataRow(
                                                cells: [
                                                  DataCell(
                                                      Text(
                                                          expense['']
                                                              .toString(),
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .transparent)),
                                                      showEditIcon: false),
                                                  DataCell(Text(
                                                      expense['category'],
                                                      style: TextStyle(
                                                          color: getCategoryColor(
                                                              expense[
                                                                  'category'])))),
                                                  DataCell(Text(formatCurrency(
                                                      expense['amount']))),
                                                  DataCell(Text(expense['date']
                                                      .toString())),
                                                  DataCell(
                                                    IconButton(
                                                      icon: Icon(Icons.edit),
                                                      onPressed: () {
                                                        // Handle edit button press here
                                                        showEditExpenseDialog(
                                                            expense['id'],
                                                            expense['amount'],
                                                            expense['category'],
                                                            expense['note'],
                                                            DateTime.parse(
                                                                expense[
                                                                    'date']));
                                                        // You can use the expense variable to access the row data
                                                        print(
                                                            'Edit pressed for ${expense['category']}');
                                                      },
                                                    ),
                                                  ),
                                                ],
                                                onSelectChanged: (value) {
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) =>
                                                        AlertDialog(
                                                      title: Text(
                                                        expense['category'],
                                                        style: TextStyle(
                                                            color: getCategoryColor(
                                                                expense[
                                                                    'category'])),
                                                      ),
                                                      content: Text(
                                                          'Amount: \₱${expense['amount']} \nDate: ${expense['date']}\nNote: ${expense['note']}'),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                  context),
                                                          child: Text('Close'),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              ))
                                          .toList(),
                                    ),
                                  ),
                                ),
                        ]),),),
              ]),
              ),]),
              IconButton(
                icon: Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
                padding: EdgeInsets.all(16.0),
              ),
            ],
          ),
      ),
    );}
  }

  Color getCategoryColor(String category) {
    switch (category) {
      case 'Food':
        return Colors.lightBlueAccent;
      case 'Transportation':
        return Colors.blue;
      case 'Utilities':
        return Colors.orangeAccent;
      case 'Entertainment':
        return Colors.deepOrange;
      default:
        return Colors.grey;

    }
  }
  String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(locale: 'fil_PH', symbol: '₱', decimalDigits: 2);
    return formatter.format(amount);
  }

  getAllExpenses() async {
    all_expenses.clear();
    final query = db.select(db.expenses)
      ..where((expense) => expense.userid.equals(id_session))
      ..orderBy([(expense) => OrderingTerm(expression: expense.date, mode: OrderingMode.desc)]);
    final result = await query.get();

    print("Result: $result");
    for (var row in result) {
      final formatDate = DateFormat('yyyy-MM-dd').format(row.date!);
      Map<String, dynamic> item = {
        'id' : row.id,
        'category': row.category,
        'amount': row.amount,
        'note': row.note,
        'date': formatDate,
      };
      all_expenses.add(item);
    }

  }
  Future<void> _loadDatabase() async {
    // Replace with your Moor database initialization code
    getAllExpenses();


    // Delay for 1 second to simulate database loading
    await Future.delayed(Duration(seconds: 1));

  }

  Future<void> _loadData() async {
    await _loadDatabase();

    setState(() {
      _isLoading = false;
    });
  }

  expenseEdit(int id, double newAmount, String newCategory, String newNote, DateTime date) async {

    final query = db.update(db.expenses)
      ..where((expenses) => expenses.id.equals(id))
      ..write(ExpensesCompanion(amount: Value(newAmount), category: Value(newCategory), note: Value(newNote), date: Value(date as DateTime?)));

    await query;
  }

  Future showEditExpenseDialog(int id, double oldAmount, String oldCategory, String oldNote, DateTime oldDate) {
    TextEditingController dateInputController = TextEditingController(text: DateFormat('yyyy-MM-dd').format((oldDate)));


    String _selectedCategory = oldCategory;
    double _amount = oldAmount;
    String _note = oldNote;
    DateTime _date = oldDate;
    DateTime? _Tempdate;
    DateTime pickedDate = oldDate;
    String formattedDate='';


    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Record new expense'),
            content: SingleChildScrollView(
              child: Form(
                key: _keyDialogForm,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[

                    TextFormField(
                      decoration: InputDecoration(labelText: 'Date'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter date';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        if (_Tempdate==null) {
                          _date = oldDate;
                        }
                        else
                        {_date = _Tempdate!;}
                        print(_date);
                      },

                      controller: dateInputController,
                      readOnly: true,
                      onTap: () async {
                        pickedDate = (await showDatePicker(
                            context: context,
                            initialDate: oldDate,
                            firstDate: DateTime(1950),
                            lastDate: DateTime.now()))!;

                        print(pickedDate);  //pickedDate output format => 2021-03-10 00:00:00.000
                        formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
                        print(formattedDate); //formatted date output using intl package =>  2021-03-16
                        dateInputController.text = formattedDate;
                        _Tempdate=pickedDate;
                        print(_Tempdate);

                      },


                    ),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(labelText: 'Category'),
                      value: oldCategory,
                      onChanged: (newValue) {
                        setState(() {
                          _selectedCategory = newValue!;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a category';
                        }
                        return null;
                      },
                      items: <String>['Food', 'Transportation', 'Utilities', 'Entertainment', 'Others']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),

                    TextFormField(
                      initialValue: oldAmount.toString().replaceAll(RegExp(r'\.0$'), ''),
                      maxLength: 7,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: 'Amount',counterText: "",),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter amount';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _amount = double.parse(value!);
                      },
                    ),

                    TextFormField(
                      initialValue: oldNote,
                      maxLength: 50,
                      decoration: InputDecoration(labelText: 'Note',counterText: "",),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your note';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _note = value!;
                      },
                    ),

                  ],
                ),
              ),),


            actions: <Widget>[
              ElevatedButton(
                onPressed: () {
                  if (_keyDialogForm.currentState!.validate()) {
                    _keyDialogForm.currentState?.save();

                    expenseEdit(id, _amount!, _selectedCategory!, _note!, _date!);
                    _loadData();

                    Navigator.pop(context);
                  }
                },
                child: Text('Save'),

              ),
              ElevatedButton(
                  onPressed: () {

                    Navigator.pop(context);
                  },
                  child: Text('Cancel')),
            ],
          );
        });
  }

}
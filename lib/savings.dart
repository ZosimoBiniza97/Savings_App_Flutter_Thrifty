
import 'package:flutter/material.dart';
import 'package:moor_flutter/moor_flutter.dart' hide Column;
import 'package:thrifty/account.dart';
import 'package:thrifty/database.dart';
import 'package:intl/intl.dart';



class SavingsPage extends StatefulWidget {
  get expenses => null;
  @override
  _SavingsPageState createState() => _SavingsPageState();


}

class _SavingsPageState extends State<SavingsPage> {
  bool _isLoading = true;
  final GlobalKey<FormState> _keyDialogForm = new GlobalKey<FormState>();

  void initState() {
    super.initState();
    _loadData();
  }

  List<Map<String, dynamic>> all_savings = [];
  final GlobalKey<FormState> _keyDialogForm_newSavings = new GlobalKey<FormState>();
  TextEditingController dateInputController = TextEditingController(text: DateFormat('yyyy-MM-dd').format(DateTime.now()));
  DateTime? _date;
  DateTime? _Tempdate;
  DateTime pickedDate = DateTime.now();
  String formattedDate='';
  String formattedCurrentGoal='';
  DateTime? _dateSavings;
  double? _newSavingsAmount;


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
      return new WillPopScope(
          onWillPop: () async => false,
    child: Scaffold(
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
                    Padding(padding: EdgeInsets.only(top:40)),
                    Text('All Savings', style: TextStyle(fontSize: 25, color: Colors.green, fontWeight: FontWeight.bold),),

                    Expanded(

                      child: ListView(
                          children: [
                            Container(
                              child: SingleChildScrollView(
                                child: Column(
                                    children: [

                                      all_savings.isEmpty
                                          ? Center(child: Text('No Data', style: const TextStyle(fontSize: 20),))
                                          : SingleChildScrollView(
                                        scrollDirection: Axis.vertical,
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: DataTable(
                                            showCheckboxColumn: false,
                                            horizontalMargin: 10,
                                            columnSpacing: 10,
                                            columns: const [

                                              DataColumn(label: Text('Amount')),
                                              DataColumn(label: Text('Date')),
                                              DataColumn(label: Text('Edit')),
                                              DataColumn(label: Text('Delete')),

                                            ],
                                            rows: all_savings
                                                .map((savings) => DataRow(cells: [

                                              DataCell(Text(formatCurrency(savings['amount']))),
                                              DataCell(Text(savings['date'].toString())),
                                              DataCell(
                                                IconButton(
                                                  icon: Icon(Icons.edit),
                                                  onPressed: () {

                                                    showEditSavingsDialog(
                                                        savings['id'],
                                                        savings['amount'],
                                                        DateTime.parse(
                                                            savings[
                                                            'date']));
                                                  },
                                                ),
                                              ),
                                              DataCell(
                                                IconButton(
                                                  icon: Icon(Icons.remove),
                                                  onPressed: () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (BuildContext context) {
                                                        return AlertDialog(
                                                          title: Text('Confirm Delete'),
                                                          content: Text('Are you sure you want to delete this savings record?'),
                                                          actions: <Widget>[
                                                            TextButton(
                                                              child: Text('Cancel'),
                                                              onPressed: () {
                                                                Navigator.of(context).pop();
                                                              },
                                                            ),
                                                            TextButton(
                                                              child: Text('Delete'),
                                                              onPressed: () {
                                                                savingsDelete(savings['id']);
                                                                _loadData();
                                                                Navigator.of(context).pop();
                                                              },
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  },
                                                ),
                                              ),
                                            ],
                                              onSelectChanged: (value) {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) => AlertDialog(
                                                    title: Text('Savings Entry',
                                                      style: TextStyle(color: Colors.green),),
                                                    content: Text('Amount: \₱${savings['amount']} \nDate: ${savings['date']}'),
                                                    actions: [

                                                      TextButton(
                                                        onPressed: () => Navigator.pop(context),
                                                        child: Text('Close'),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            )
                                            )
                                                .toList(),
                                          )
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
              Positioned(
                bottom: 16.0,
                right: 16.0,
                child: FloatingActionButton(
                  onPressed: () {
                    showAddSavingsDialog();
                  },
                  child: Icon(Icons.add),
                ),
              ),
            ],
          ),
        ),
      ));}
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

  getAllSavings() async {
    all_savings.clear();
    final query = db.select(db.savings)
      ..where((savings) => savings.userid.equals(id_session))
      ..orderBy([(savings) => OrderingTerm(expression: savings.date, mode: OrderingMode.desc)]);
    final result = await query.get();

    print("Result: $result");
    for (var row in result) {
      final formatDate = DateFormat('yyyy-MM-dd').format(row.date!);
      Map<String, dynamic> item = {
        'id': row.id,
        'amount': row.amount,
        'date': formatDate,
      };
      all_savings.add(item);
    }

  }
  Future<void> _loadDatabase() async {
    // Replace with your Moor database initialization code
      await getAllSavings();

  }

  Future<void> _loadData() async {
    await _loadDatabase();

    setState(() {
      _isLoading = false;
    });
  }


  Future showEditSavingsDialog(int id, double oldAmount, DateTime oldDate) {
    TextEditingController dateInputController = TextEditingController(text: DateFormat('yyyy-MM-dd').format((oldDate)));



    double _amount = oldAmount;
    DateTime _date = oldDate;
    DateTime? _Tempdate;
    DateTime pickedDate = oldDate;
    String formattedDate='';


    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Edit savings record'),
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

                  ],
                ),
              ),),


            actions: <Widget>[
              ElevatedButton(
                onPressed: () {
                  if (_keyDialogForm.currentState!.validate()) {
                    _keyDialogForm.currentState?.save();

                    savingsEdit(id, _amount, _date);
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

  savingsEdit(int id, double newAmount, DateTime date) async {

    final query = db.update(db.savings)
      ..where((savings) => savings.id.equals(id))
      ..write(SavingsCompanion(amount: Value(newAmount), date: Value(date)));

    await query;
  }

  savingsDelete(int id) async
  {
    final query = db.delete(db.savings)
      ..where((savings) => savings.id.equals(id))
      ..go();
    await query;
  }
  Future showAddSavingsDialog() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Record new savings'),
            content: Form(
              key: _keyDialogForm_newSavings,
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
                        _dateSavings = DateTime.now();
                      }
                      else
                      {_dateSavings = _Tempdate;}
                      print(_date);
                    },

                    controller: dateInputController,
                    readOnly: true,
                    onTap: () async {
                      pickedDate = (await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
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

                  TextFormField(
                    maxLength: 7,

                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Amount', counterText: "",),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter amount';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _newSavingsAmount = double.parse(value!);
                    },
                  ),

                ],
              ),
            ),


            actions: <Widget>[
              ElevatedButton(
                onPressed: () {
                  if (_keyDialogForm_newSavings.currentState!.validate()) {
                    _keyDialogForm_newSavings.currentState?.save();
                    insertSavings();
                    _loadData();
                    pickedDate=DateTime.now();
                    formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
                    dateInputController.text = formattedDate;
                    Navigator.pop(context);
                  }
                },
                child: Text('Save'),

              ),
              ElevatedButton(
                  onPressed: () {
                    pickedDate=DateTime.now();
                    formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
                    dateInputController.text = formattedDate;
                    Navigator.pop(context);
                  },
                  child: Text('Cancel')),
            ],
          );
        });
  }

  Future<void> insertSavings() async {

      await db.batch((batch) {
        batch.insertAll(
          db.savings,
          [
            SavingsCompanion(
              userid: Value(id_session!),
              amount: Value(_newSavingsAmount!),
              date: Value(_dateSavings),
              active: Value(1),
            ),
          ],
        );
      });

  }
}
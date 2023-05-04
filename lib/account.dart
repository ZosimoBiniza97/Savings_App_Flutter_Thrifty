
import 'dart:async';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moor_flutter/moor_flutter.dart' hide Column;
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:thrifty/database.dart';
import 'package:intl/intl.dart';
import 'package:thrifty/login.dart';
import 'package:thrifty/expenses.dart';
import 'package:thrifty/profile.dart';
import 'package:thrifty/savings.dart';

String currentPage = 'Home';
int? id_session;
int foodExpenseTotal=0;
int transportationExpenseTotal=0;
int utilitiesExpenseTotal=0;
int entertainmentExpenseTotal=0;
int othersExpenseTotal=0;
double savingsTotal=0;
String formattedSavingsTotal = '';
String firstname = '';
String lastname = '';
String username = '';
String email = '';
String password = '';

class GlobalContextService {
  static GlobalKey<NavigatorState> navigatorKey =
  GlobalKey<NavigatorState>();
}

class ViewAccount extends StatefulWidget {
  get expenses => null;

  @override
  _ViewAccountState createState() => _ViewAccountState();
}

class _ViewAccountState extends State<ViewAccount> {
  final ScrollController _scrollController = ScrollController();




  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {

    if (_scrollController.offset <= _scrollController.position.minScrollExtent) {
      // The scroll is overscrolled to the top
      setState(() {
        _isPressed = false;
        topcontainerheight = 160;
        _isColumnVisible = true;
        _isSecondColumnVisible = false;
      });
    }

    else
    {
      setState(() {
        _isPressed = true;
        topcontainerheight = 50;
        _isColumnVisible = false;
        _isSecondColumnVisible = true;
      });
    }
  }


  bool _isLoading = true;
  final GlobalKey<FormState> _keyDialogForm = new GlobalKey<FormState>();
  final GlobalKey<FormState> _keyDialogForm_newGoal = new GlobalKey<FormState>();
  final GlobalKey<FormState> _keyDialogForm_newSavings = new GlobalKey<FormState>();
  TextEditingController dateInputController = TextEditingController(text: DateFormat('yyyy-MM-dd').format(DateTime.now()));
  String? _selectedCategory;
  double? _amount;
  String? _note;
  DateTime? _date;
  DateTime? _Tempdate;
  DateTime pickedDate = DateTime.now();
  String formattedDate='';
  String _newGoal = "";
  double? _newGoalAmount;
  String _newGoalDescription = "";
  String? _currentGoal = "";
  String formattedCurrentGoal='';
  double _currentGoalAmount=0;
  String? _currentGoalDescription;
  double? _newSavingsAmount;
  DateTime? _dateSavings;
  double percentage =0;
  late ConfettiController _controller;



  List<Map<String, dynamic>> recent_expenses = [];
  List<Map<String, dynamic>> recent_savings = [];
  // These strings are for getting the value of the section of doughnut graph the user tapped.
  // This value is for the money.
  String tappedValue = '';

  // This value is for the category e.g., Utilities, transportation, food, etc
  String tappedValueCat = '';

  // This is for the chart data
  late List<FinancialData> _chartData;

  // Adds tooltip when a section of the graph is tapped
  late TooltipBehavior _tooltipBehavior;

  // Temporary value of 100. This is for determining which section of the graph is clicked.
  int selectedIndex = 100;

  // This is the height of the top container. This value will be changed to 50 when the container is tapped or if the scrollable containers are scrolled.
  double topcontainerheight = 160;

  // This boolean determines if the top container is pressed or not
  bool _isPressed = false;

  // This boolean determines if the section of the doughnut graph is exploded or clicked.
  bool explode = true;

  // These booleans determines which kind text to display.
  // If top container is expanded, it will display the fully detailed current goal information
  bool _isColumnVisible = true;

  // If top container is is minimized, it will display only the current goal text
  bool _isSecondColumnVisible = false;




  @override
  void initState() {
    _scrollController.addListener(_onScroll);
    _tooltipBehavior = TooltipBehavior(enable: true, duration: 5000);
    super.initState();
    _loadData();
    _controller = ConfettiController(duration: const Duration(seconds: 1));
  }

  @override
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

    else{

      _chartData = getChartData();
      // Detects the width of the screen of the device to ensure gui compatibility and dynamic sizes
      final screenWidth = MediaQuery
          .of(context)
          .size
          .width;

    // Hides status bar on the top for a full screen view
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [
      SystemUiOverlay.bottom
    ]);
      return new WillPopScope(
          onWillPop: () async => false,
    child: Scaffold(

      drawer: MyDrawer(),
      body: Builder(
        builder: (BuildContext context) {
          return Stack(

            children: [

              // Detects if the scrollable containers are being scrolled
              // If it is scrolled, the top container will minimize
              NotificationListener<ScrollNotification>(


                // Set up the background of the account page
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/background.png"),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: Column(

                        children: [
                          Container(
                            height: 50,
                            width: 380,
                          ),

                          // This is the dynamic top container that can expand and minimize
                          InkWell(
                              child: Container(
                                width: screenWidth * 0.9,
                                height: topcontainerheight,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(25),
                                    color: Color.fromRGBO(81, 212, 189, 1.0),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        spreadRadius: 5,
                                        blurRadius: 7,
                                        offset: Offset(0, 3),
                                      ),
                                    ]
                                ),

                                child: Column(
                                  children: [
                                    Visibility(
                                        visible: _isColumnVisible,
                                        child: Column(
                                            children: [
                                              Row(
                                                  mainAxisAlignment: MainAxisAlignment
                                                      .spaceBetween,
                                                  children: [

                                                    // Current goal text on the top left
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 30),
                                                      child: Container(
                                                        child: Text(
                                                          'Current goal',
                                                          style: TextStyle(
                                                              fontSize: 15,
                                                              color: Colors
                                                                  .white),),
                                                      ),),


                                                    // New goal button
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          top: 3, right: 20),
                                                      child: Container(
                                                          child: ElevatedButton(
                                                            onPressed: () {
                                                              // add your function here
                                                              showAddGoalDialog();
                                                              // Top be updated once database is complete
                                                            },
                                                            child: Text(
                                                                'New Goal'),
                                                            style: ElevatedButton
                                                                .styleFrom(
                                                                shape: RoundedRectangleBorder(
                                                                  borderRadius: BorderRadius
                                                                      .circular(
                                                                      20), // set the radius value you want
                                                                ),
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                  horizontal: 10,
                                                                  vertical: 10,)
                                                            ),
                                                          )
                                                      ),
                                                    ),
                                                  ]
                                              ),


                                              // This displays the current savings goal
                                              Padding(padding: EdgeInsets.only(
                                                  top: 5, ),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment
                                                      .center,
                                                  children: [

                                                    _currentGoalAmount==0
                                                        ? Center(child: Text('No savings goal', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color: Colors.white),))
                                                    : Text(
                                                      formattedSavingsTotal,
                                                      style: TextStyle(
                                                        fontWeight: FontWeight
                                                            .bold,
                                                        fontSize: 40,
                                                        color: Colors.white,
                                                      ),
                                                    ),

                                                  ],
                                                ),),
                                              Text(
                                                formattedCurrentGoal,
                                                style: TextStyle(
                                                  fontWeight: FontWeight
                                                      .bold,
                                                  fontSize: 15,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              // This is the percent indicator at the bottom of the current goal
                                              // To be updated. This should be dynamic
                                              Row(
                                                  mainAxisAlignment: MainAxisAlignment
                                                      .center,
                                                  children: [
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          top: 10),
                                                      child: Center(
                                                        child: new LinearPercentIndicator(

                                                          width: 250,
                                                          lineHeight: 14.0,
                                                          percent: percentage,

                                                          backgroundColor: Colors
                                                              .grey,
                                                          progressColor: Colors
                                                              .blue,
                                                        ),
                                                      ),),
                                                  ])

                                            ])),


                                    // This displays the alternative texts that will only appear of the top container is minimized
                                    Visibility(
                                      visible: _isSecondColumnVisible,
                                      child:
                                      Padding(padding: EdgeInsets.only(top: 8),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment
                                              .center,
                                          children: [
                                            _currentGoalAmount==0
                                                ? Center(child: Text('No savings goal', style: const TextStyle(fontSize: 20, color: Colors.white),))
                                                : Text(
                                               formattedSavingsTotal+'/',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 30,
                                                color: Colors.white,
                                              ),
                                            ),
                                            Text(
                                              formattedCurrentGoal, style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),),
                                    ),

                                  ],
                                ),
                              ),

                              // This determines if the top container is minimized or expanded
                              // If pressed, the container will minimize. If pressed again, it will expand
                              onTap: () {
                                setState(() {
                                  _isPressed = !_isPressed;

                                  if (_isPressed) {
                                    topcontainerheight = 50;
                                    _isColumnVisible = false;
                                    _isSecondColumnVisible = true;
                                  } else {
                                    topcontainerheight = 160;
                                    _isColumnVisible = true;
                                    _isSecondColumnVisible = false;
                                  }
                                });
                              }


                          ),

                          // These are the scrollable containers
                          // To be updated
                          Expanded(
                            child: ListView(
                              controller: _scrollController,
                              children: [
                                Padding(padding: EdgeInsets.only(
                                    left: screenWidth * 0.07,
                                    right: screenWidth * 0.07,
                                    top: 20),
                                  child: Container(

                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(25),
                                        color: Colors.white,

                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.5),
                                            spreadRadius: 5,
                                            blurRadius: 7,
                                            offset: Offset(0, 3),
                                          ),
                                        ]

                                    ),


                                    child: Column(

                                      children: [
                                    // This snippet displays the chart
                                        Container( height: 400,

                                        child: _chartData.isEmpty
                                        ? Center(child: Text('No Expenses', style: const TextStyle(fontSize: 20),))

                                        : SfCircularChart(
                                          centerY: '100',

                                      annotations: [
                                        CircularChartAnnotation(
                                            widget: Text(
                                              tappedValue,
                                              style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold),
                                            )),
                                        CircularChartAnnotation(
                                            widget: Text(
                                              tappedValueCat,
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold),
                                            ))

                                      ],

                                      title: ChartTitle(text: 'Expenses\n',
                                          textStyle: TextStyle(
                                              color: Colors.red,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold)),

                                      legend: Legend(isVisible: true,
                                          overflowMode: LegendItemOverflowMode.wrap,
                                          position: LegendPosition.bottom),

                                      tooltipBehavior: _tooltipBehavior,

                                      series: <CircularSeries>[
                                        DoughnutSeries<FinancialData, String>(
                                          dataSource: _chartData,
                                          xValueMapper: (FinancialData data,
                                              _) => data.expense,
                                          yValueMapper: (FinancialData data,
                                              _) => data.amount,
                                          pointColorMapper: (FinancialData data, _) => data.color,
                                          dataLabelMapper: (FinancialData data,_) => chartPercentageCalculator(data.amount),
                                          dataLabelSettings: DataLabelSettings(
                                            isVisible: true,),
                                          enableTooltip: false,
                                          explode: true,
                                          explodeGesture: ActivationMode
                                              .singleTap,
                                          explodeIndex: selectedIndex,
                                          radius: '120',


                                          onPointTap: (
                                              pointInteractionDetails) {
                                            tappedValue = formatCurrencyInt(pointInteractionDetails
                                                .dataPoints![pointInteractionDetails
                                                .pointIndex!].y) + "\n\n";
                                            tappedValueCat =
                                                pointInteractionDetails
                                                    .dataPoints![pointInteractionDetails
                                                    .pointIndex!].x
                                                    .toString();
                                            setState(() {
                                              if (selectedIndex ==
                                                  pointInteractionDetails
                                                      .pointIndex) {
                                                selectedIndex = 100;
                                                tappedValue = "";
                                                tappedValueCat = "";
                                              }
                                              else {
                                                selectedIndex =
                                                pointInteractionDetails
                                                    .pointIndex!;
                                              }
                                            }
                                            );
                                          },

                                        ),
                                      ],


                                    ),
                                        ),
                                        Padding(padding: EdgeInsets.only(bottom: 20),

                                       child: ElevatedButton(
                                          onPressed: () {
                                            // add your function here
                                            showAddExpenseDialog();
                                            // Top be updated once database is complete
                                          },
                                          child: Text(
                                              'Add Expense'),
                                          style: ElevatedButton
                                              .styleFrom(
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius
                                                    .circular(
                                                    20), // set the radius value you want
                                              ),
                                              padding: EdgeInsets
                                                  .symmetric(
                                                horizontal: 30,
                                                vertical: 10,)
                                          ),
                                        )
                                        )
                           ] ),
                                  ),
                                ),


                                Padding(padding: EdgeInsets.only(
                                    left: screenWidth * 0.07,
                                    right: screenWidth * 0.07,
                                    top: 20),
                                  child: Container(

                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(25),
                                        color: Colors.white,

                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.5),
                                            spreadRadius: 5,
                                            blurRadius: 7,
                                            offset: Offset(0, 3),
                                          ),
                                        ]

                                    ),
                                    child: Padding(padding: EdgeInsets.all(15),
                                      child: Column(
                                        children: [

                                          Text('Recent Expenses', style: TextStyle(fontSize: 20, color: Colors.deepOrangeAccent, fontWeight: FontWeight.bold),),

                                          recent_expenses.isEmpty
                                           ? Padding(
                                              padding: EdgeInsets.only(top: 20, bottom: 20),
                                              child: Center(child: Text('No Expenses', style: const TextStyle(fontSize: 20),))
                                          )
                                          : SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: DataTable(
                                              showCheckboxColumn: false,
                                              horizontalMargin: 10,
                                              columnSpacing: 30,
                                              columns: const [
                                                DataColumn(label: Text('Category')),
                                                DataColumn(label: Text('Amount')),
                                                DataColumn(label: Text('Date')),
                                              ],
                                              rows: recent_expenses
                                                  .map((expense) => DataRow(
                                                cells: [
                                                  DataCell(Text(expense['category'], style: TextStyle(color: getCategoryColor(expense['category'])))),
                                                  DataCell(Text(formatCurrency(expense['amount']))),
                                                  DataCell(Text(expense['date'].toString())),
                                                ],
                                                onSelectChanged: (value) {
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) => AlertDialog(
                                                      title: Text(
                                                        expense['category'],
                                                        style: TextStyle(color: getCategoryColor(expense['category'])),
                                                      ),
                                                      content: Text('Amount: \₱${expense['amount']} \nDate: ${expense['date']}\nNote: ${expense['note']}'),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () => Navigator.pop(context),
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
                                        ]),



                                    ),
                                  ),
                                ),


                                Padding(padding: EdgeInsets.only(
                                    left: screenWidth * 0.07,
                                    right: screenWidth * 0.07,
                                    top: 20,
                                    bottom: 15),
                                  child: Container(


                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(25),
                                        color: Colors.white,

                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.5),
                                            spreadRadius: 5,
                                            blurRadius: 7,
                                            offset: Offset(0, 3),
                                          ),
                                        ]

                                    ),

                                    child: Padding(padding: EdgeInsets.all(15),

                                      child: Column(
                                        children: [
                                          Text('Savings', style: TextStyle(fontSize: 20, color: Colors.green, fontWeight: FontWeight.bold),),

                                          recent_savings.isEmpty
                                              ? Padding(
                                            padding: EdgeInsets.only(top: 20, bottom: 20),
                                              child: Center(child: Text('No Savings', style: const TextStyle(fontSize: 20),))
                                          )


                                              : SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                          child: DataTable(
                                            showCheckboxColumn: false,
                                            horizontalMargin: 10,
                                            columnSpacing: 30,
                                            columns: const [
                                              DataColumn(label: Text('Amount')),
                                              DataColumn(label: Text('Date')),
                                            ],
                                            rows: recent_savings
                                                .map((savings) => DataRow(cells: [
                                              DataCell(Text(formatCurrency(savings['amount']))),
                                              DataCell(Text(savings['date'].toString())),
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
                                          )),



                                          ElevatedButton(
                                            onPressed: () {
                                              // add your function here
                                              showAddSavingsDialog();
                                              // Top be updated once database is complete
                                            },
                                            child: Text(
                                                'Add Savings'),
                                            style: ElevatedButton
                                                .styleFrom(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius
                                                      .circular(
                                                      20), // set the radius value you want
                                                ),
                                                padding: EdgeInsets
                                                    .symmetric(
                                                  horizontal: 30,
                                                  vertical: 10,)
                                            ),
                                          )


                                        ],
                                      )

                                    ),
                                  ),
                                ),

                              ],
                            ),
                          )
                        ]
                    ),
                  ),
                ),
              ),

              // This is the hamburger icon on the top left. This opens the navigation drawer
              IconButton(
                icon: Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
                padding: EdgeInsets.all(16.0),
              ),
            ],
          );
        },
      ),

    ));
  }
}


  List<Color> categoryColors = [
    Colors.lightBlueAccent, // Food
    Colors.blue, // Transportation
    Colors.orangeAccent, // Utilities
    Colors.grey, // Others
    Colors.deepOrange, // Entertainment
  ];
// This inserts the chart data to be displayed on the container
  List<FinancialData> getChartData() {

    final List<FinancialData> chartData = [

      if (foodExpenseTotal>0)
        FinancialData('Food', foodExpenseTotal,categoryColors[0]),
      if (transportationExpenseTotal>0)
        FinancialData('Transportation', transportationExpenseTotal, categoryColors[1]),
      if (utilitiesExpenseTotal>0)
        FinancialData('Utilities', utilitiesExpenseTotal, categoryColors[2]),
      if (entertainmentExpenseTotal>0)
        FinancialData('Entertainment', entertainmentExpenseTotal, categoryColors[4]),
      if (othersExpenseTotal>0)
        FinancialData('Others', othersExpenseTotal, categoryColors[3]),
    ];
    return chartData;
  }

  getTotalFoodExpenses() async {

      final query = db.select(db.expenses)
        ..where((t) => t.userid.equals(id_session) & t.category.equals('Food'));
      final results = await query.get();
      final amounts = results.map((expense) => expense.amount).toList();

      final int totalAmount = amounts.fold(
          0, (previousValue, currentValue) => previousValue.toInt() +
          currentValue.toInt());

      foodExpenseTotal = totalAmount;

  }

  getTotalTransportationExpenses() async {
    final query = db.select(db.expenses)..where((t) => t.userid.equals(id_session) & t.category.equals('Transportation'));
    final results = await query.get();
    final amounts = results.map((expense) => expense.amount).toList();

    final int totalAmount = amounts.fold(0, (previousValue, currentValue) => previousValue.toInt() + currentValue.toInt());

    transportationExpenseTotal=totalAmount;
  }

  getTotalUtilitiesExpenses() async {
    final query = db.select(db.expenses)..where((t) => t.userid.equals(id_session) & t.category.equals('Utilities'));
    final results = await query.get();
    final amounts = results.map((expense) => expense.amount).toList();

    final int totalAmount = amounts.fold(0, (previousValue, currentValue) => previousValue.toInt() + currentValue.toInt());

    utilitiesExpenseTotal=totalAmount;
  }

  getTotalEntertainmentExpenses() async {
    final query = db.select(db.expenses)..where((t) => t.userid.equals(id_session) & t.category.equals('Entertainment'));
    final results = await query.get();
    final amounts = results.map((expense) => expense.amount).toList();

    final int totalAmount = amounts.fold(0, (previousValue, currentValue) => previousValue.toInt() + currentValue.toInt());

    entertainmentExpenseTotal=totalAmount;
  }
  getTotalOthersExpenses() async {
    final query = db.select(db.expenses)..where((t) => t.userid.equals(id_session) & t.category.equals('Others'));
    final results = await query.get();
    final amounts = results.map((expense) => expense.amount).toList();

    final int totalAmount = amounts.fold(0, (previousValue, currentValue) => previousValue.toInt() + currentValue.toInt());

    othersExpenseTotal=totalAmount;
  }
  getRecentExpenses() async {
    recent_expenses.clear();
    final query = db.select(db.expenses)
      ..where((expense) => expense.userid.equals(id_session))
      ..orderBy([(expense) => OrderingTerm(expression: expense.date, mode: OrderingMode.desc)])
      ..limit(10);
    final result = await query.get();

    print("Result: $result");
    for (var row in result) {
      final formatDate = DateFormat('yyyy-MM-dd').format(row.date!);
      Map<String, dynamic> item = {
        'category': row.category,
        'amount': row.amount,
        'note': row.note,
        'date': formatDate,
      };
      recent_expenses.add(item);
    }

  }

  getRecentSavings() async {
    recent_savings.clear();
    final query = db.select(db.savings)
      ..where((savings) => savings.userid.equals(id_session))
      ..orderBy([(savings) => OrderingTerm(expression: savings.date, mode: OrderingMode.desc)])
      ..limit(10);
    final result = await query.get();

    print("Result: $result");
    for (var row in result) {
      final formatDate = DateFormat('yyyy-MM-dd').format(row.date!);
      Map<String, dynamic> item = {
        'amount': row.amount,
        'date': formatDate,
      };
      recent_savings.add(item);
    }

  }


  getCurrentGoal() async {
    final query = db.select(db.goals)
      ..where((goals) => goals.userid.equals(id_session));

    final result = await query.get();
    _currentGoal = result.first.title;
    _currentGoalAmount = result.first.amount;
    _currentGoalDescription = result.first.description;

    formattedCurrentGoal = NumberFormat.currency(locale: 'fil_PH', symbol: '₱').format(_currentGoalAmount);


  }

  getTotalSavings() async {
    final query = db.select(db.savings)..where((t) => t.userid.equals(id_session) & t.active.equals(1));
    final results = await query.get();
    final amounts = results.map((savings) => savings.amount).toList();

    final double totalAmount = amounts.fold(0, (previousValue, currentValue) => previousValue + currentValue);

    savingsTotal=totalAmount;
    formattedSavingsTotal = NumberFormat.currency(locale: 'fil_PH', symbol: '₱').format(savingsTotal);
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

  setSavingsInactive() async {

    final query = db.update(db.savings)
      ..where((savings) => savings.active.equals(1))
      ..write(SavingsCompanion(active: Value(0)));

    await query;
  }

  Future<void> _loadDatabase() async {

    final functions = [
      getTotalFoodExpenses,
      getTotalEntertainmentExpenses,
      getTotalOthersExpenses,
      getTotalUtilitiesExpenses,
      getTotalTransportationExpenses,
      getRecentExpenses,
      getCurrentGoal,
      getRecentSavings,
      getTotalSavings,
      getUserValues,
    ];

    for (final function in functions) {
      try {
        await function();
      } catch (e) {}
    }


  }

  Future<void> _loadData() async {
    await _loadDatabase();
    if(savingsTotal!=0 && _currentGoalAmount!=0)
    {
      if (savingsTotal<=_currentGoalAmount) {
        percentage = (savingsTotal / _currentGoalAmount);
      }
      else
        {
          percentage = 1;
        }
    }

    else{
      percentage=0;
    }

    if ((savingsTotal >= _currentGoalAmount.toInt()) && (savingsTotal !=0))
    {
    showCongratsDialog(context);

    }

    if(_currentGoalAmount == 0)
    {
      showAddGoalDialogModal();
    }



    setState(() {
      _isLoading = false;
    });
  }

  Future showAddExpenseDialog() {
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
                        _date = DateTime.now();
                      }
                      else
                        {_date = _Tempdate;}
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
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(labelText: 'Category'),
                    value: _selectedCategory,
                    onChanged: (newValue) {
                      setState(() {
                        _selectedCategory = newValue;
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
                    maxLength: 50,
                    decoration: InputDecoration(labelText: 'Note',counterText: "",),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your note';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _note = value;
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
                    insertExpense();
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


  Future showAddGoalDialog() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Create new goal'),
            content: Form(
              key: _keyDialogForm_newGoal,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[

                  TextFormField(
                    maxLength: 20,
                    decoration: InputDecoration(labelText: 'Name', counterText: "",),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter goal name';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _currentGoal = value;
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
                      _newGoalAmount = double.parse(value!);
                    },
                  ),

                  TextFormField(
                    maxLength: 50,
                    decoration: InputDecoration(labelText: 'Description', counterText: "",),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your note';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _newGoalDescription = value!;
                    },
                  ),

                ],
              ),
            ),


            actions: <Widget>[
              ElevatedButton(
                onPressed: () {
                  if (_keyDialogForm_newGoal.currentState!.validate()) {
                    _keyDialogForm_newGoal.currentState?.save();
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Confirmation'),
                          content: Text('Are you sure you want to save this goal and replace current goal?'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                insertGoal();
                                _loadData();
                                Navigator.pop(context);
                                Navigator.pop(context);
                              },
                              child: Text('Yes'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text('No'),
                            ),
                          ],
                        );
                      },
                    );
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

  Future showAddGoalDialogModal() {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return WillPopScope(
              onWillPop: () async => false,
           child: AlertDialog(
            title: Text('Create new goal'),
            content: Form(
              key: _keyDialogForm_newGoal,
              child: Column(
                mainAxisSize: MainAxisSize.min, // Set to min to make the dialog box smaller

                children: <Widget>[

                  TextFormField(
                    maxLength: 20,
                    decoration: InputDecoration(labelText: 'Name', counterText: ""),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter goal name';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _currentGoal = value;
                    },
                  ),

                  TextFormField(
                    maxLength: 7,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Amount', counterText: ""),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter amount';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _newGoalAmount = double.parse(value!);
                    },
                  ),

                  TextFormField(
                    maxLength: 50,
                    decoration: InputDecoration(labelText: 'Description',counterText: ""),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your note';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _newGoalDescription = value!;
                    },
                  ),

                ],
              ),
            ),


            actions: <Widget>[
              ElevatedButton(
                onPressed: () {
                  if (_keyDialogForm_newGoal.currentState!.validate()) {
                    _keyDialogForm_newGoal.currentState?.save();
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Confirmation'),
                          content: Text('Create new goal?'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                setSavingsInactive();
                                insertGoal();
                                _loadData();
                                Navigator.pop(context);
                                Navigator.pop(context);
                              },
                              child: Text('Yes'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text('No'),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
                child: Text('Save'),
              ),

            ],
          ));
        });
  }

  // Create a function to show the alert dialog
  void showCongratsDialog(BuildContext context) {
    // Initialize the confetti widget
    final confetti = ConfettiWidget(
      confettiController: _controller,
      blastDirectionality: BlastDirectionality.explosive,
      shouldLoop: false,
      particleDrag: 0.05,
      emissionFrequency: 0.05,
      numberOfParticles: 100,
      gravity: 0.1,
      maxBlastForce: 100,
      minBlastForce: 80,
      minimumSize: const Size(10, 10), // set a minimum size for particles
      maximumSize: const Size(50, 50), // set a maximum size for particles
      // set the bounds for the confetti to cover the entire screen
    );

    confetti.confettiController.play();
    // Show the alert dialog
    showDialog(

      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Congratulations!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Add the confetti widget to the dialog content
              confetti,
              Text('You have reached your savings goal.'),
            ],
          ),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                showAddGoalDialogModal();
              },
            ),
          ],
        );
      },
    );
  }


  String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(locale: 'fil_PH', symbol: '₱', decimalDigits: 2);
    return formatter.format(amount);
  }

  String chartPercentageCalculator(int amount) {
    final totalexpenses = entertainmentExpenseTotal+foodExpenseTotal+utilitiesExpenseTotal+transportationExpenseTotal+othersExpenseTotal;
    final percentage = amount/totalexpenses;
    final percentageFormatter = NumberFormat.percentPattern('en_US');
    return percentageFormatter.format(percentage);
  }

  String formatCurrencyInt(int amount) {
    final formatter = NumberFormat.currency(locale: 'fil_PH', symbol: '₱', decimalDigits: 2);
    return formatter.format(amount);
  }

  Future<void> insertExpense() async {
    try {
      await db.batch((batch) {
        batch.insertAll(
          db.expenses,
          [
            ExpensesCompanion(
              userid: Value(id_session!),
              category: Value(_selectedCategory!),
              amount: Value(_amount!),
              note: Value(_note!),
              date: Value(_date),
            ),
          ],
        );
      });
    } on MoorWrappedException catch (e) {
      if (e.cause.toString().contains('UNIQUE')) {
        // handle the unique constraint violation error here
        print('already exists');
      } else {
        rethrow;
      }
    }
  }

  Future<void> insertGoal() async {
    try {

      await db.batch((batch) {
        batch.deleteWhere(db.goals, (tbl) => tbl.userid.equals(id_session));

        batch.insertAll(
          db.goals,
          [
            GoalsCompanion(
              userid: Value(id_session!),
              amount: Value(_newGoalAmount!),
              description: Value(_newGoalDescription),
              title: Value(_newGoal),
            ),
          ],
        );


      });
    } on MoorWrappedException catch (e) {
      if (e.cause.toString().contains('UNIQUE')) {
        // handle the unique constraint violation error here
        print('already exists');
      } else {
        rethrow;
      }
    }
  }

  Future<void> insertSavings() async {
    try {
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
    } on MoorWrappedException catch (e) {
      if (e.cause.toString().contains('UNIQUE')) {
        // handle the unique constraint violation error here
        print('already exists');
      } else {
        rethrow;
      }
    }
  }

}

getUserValues() async {

  final query = db.select(db.users)
    ..where((users) => users.id.equals(id_session));
  final result = await query.get();


    firstname = result.first.firstname;
    lastname = result.first.lastname;
    username = result.first.username;
    email = result.first.email;
    password = result.first.password;

}


class FinancialData{
  FinancialData(this.expense, this.amount, this.color);
  final String expense;
  final int amount;
  final Color color;

}


class MyDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;

    // TODO: implement build
    return Drawer(
      width: screenWidth / 1.6,
      child: Container(
        color: Color.fromRGBO(104, 157, 180, 1.0),
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(firstname + ' ' + lastname),
              accountEmail: Text(email),
              currentAccountPicture: CircleAvatar(
                backgroundImage: AssetImage('assets/images/profilepic.png'),
              ),
              decoration: BoxDecoration(
                color: Color.fromRGBO(81, 212, 189, 1.0),
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.home,
                size: 40.0,
                color: Colors.white,
              ),
              title: Text(
                'Home',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
              onTap: () {

                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ViewAccount()),
                    );


              },
            ),
            ListTile(
              leading: Icon(
                Icons.manage_accounts,
                size: 40.0,
                color: Colors.white,
              ),
              title: Text(
                'Profile',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),

                );

              },
            ),
            // ListTile(
            //   leading: Icon(
            //     Icons.settings,
            //     size: 40.0,
            //     color: Colors.white,
            //   ),
            //   title: Text(
            //     'Settings',
            //     style: TextStyle(
            //       color: Colors.white,
            //       fontSize: 20,
            //     ),
            //   ),
            //   onTap: () {
            //     Navigator.pop(context);
            //   },
            // ),
            // ListTile(
            //   leading: Icon(
            //     Icons.account_balance_wallet,
            //     size: 40.0,
            //     color: Colors.white,
            //   ),
            //   title: Text(
            //     'Accounts',
            //     style: TextStyle(
            //       color: Colors.white,
            //       fontSize: 20,
            //     ),
            //   ),
            //   onTap: () {
            //     Navigator.pop(context);
            //   },
            // ),
            ListTile(
              leading: Icon(
                Icons.currency_bitcoin,
                size: 40.0,
                color: Colors.white,
              ),
              title: Text(
                'Savings',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
              onTap: () {

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SavingsPage()),
                );

              },
            ),
            ListTile(
              leading: Icon(
                Icons.food_bank_sharp,
                size: 40.0,
                color: Colors.white,
              ),
              title: Text(
                'Expenses',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
              onTap: () {

                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ExpensesPage()),
                  );

              },
            ),
            ListTile(
              leading: Icon(
                Icons.help_outline_sharp,
                size: 40.0,
                color: Colors.white,
              ),
              title: Text(
                'Help & Support',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.logout_sharp,
                size: 40.0,
                color: Colors.white,
              ),
              title: Text(
                'Logout',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
              onTap: () {
                id_session = null;
                Navigator.of(context).pushAndRemoveUntil(
                    new MaterialPageRoute(
                        builder: (context) =>
                        new Login()),
                        (route) => false);
              },
            ),
          ],
        ),
      ),
    );
  }
}

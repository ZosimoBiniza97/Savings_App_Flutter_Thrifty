import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:percent_indicator/percent_indicator.dart';

class ViewAccount extends StatefulWidget {
  @override
  _ViewAccountState createState() => _ViewAccountState();
}

class _ViewAccountState extends State<ViewAccount> {
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
  double topcontainerheight = 150;

  // This boolean determines if the top container is pressed or not
  bool _isPressed = false;

  // This boolean determines if the section of the doughnut graph is exploded or clicked.
  bool explode = true;

  // Displays the current savings goal
  // To be updated. This should be dynamic once database is completely implemented
  String currentGoal = '\$3,563.00';

  // These booleans determines which kind text to display.
  // If top container is expanded, it will display the fully detailed current goal information
  bool _isColumnVisible = true;
  // If top container is is minimized, it will display only the current goal text
  bool _isSecondColumnVisible = false;


  @override

  void initState()
  {
    _chartData = getChartData();
    _tooltipBehavior = TooltipBehavior(enable: true, duration: 5000);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    // Detects the width of the screen of the device to ensure gui compatibility and dynamic sizes
    final screenWidth = MediaQuery.of(context).size.width;

    // Hides status bar on the top for a full screen view
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [
      SystemUiOverlay.bottom
    ]);

    return Scaffold(
      body: Builder(
        builder: (BuildContext context) {

          return Stack(
            children: [

              // Detects if the scrollable containers are being scrolled
              // If it is scrolled, the top container will minimize
          NotificationListener<ScrollNotification>(
          onNotification: (scrollNotification) {
            if (scrollNotification is ScrollUpdateNotification) {
              // Run your method here when the widget is being scrolled
              setState(() {
                _isPressed = true;
                  topcontainerheight=50;
                  _isColumnVisible = false;
                  _isSecondColumnVisible = true;
              });
            }
            // If user scrolled to the very top, the top container will re expand
            else if (scrollNotification is OverscrollNotification) {
              if (scrollNotification.overscroll < 0) {
                setState(() {
                  _isPressed = false;
                  topcontainerheight = 150;
                  _isColumnVisible = true;
                  _isSecondColumnVisible = false;
                });
              }
            }
            return false;
          },
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
                     decoration: BoxDecoration(borderRadius: BorderRadius.circular(25),color: Color.fromRGBO(81, 212, 189, 1.0),
                         boxShadow: [
                           BoxShadow (color: Colors.grey.withOpacity(0.5),
                             spreadRadius: 5,
                             blurRadius: 7,
                             offset: Offset(0,3),
                           ),]
                     ),

                    child: Column(
                      children: [
                        Visibility(
                          visible: _isColumnVisible,
                        child: Column(
                            children: [
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [

                                    // Current goal text on the top left
                              Padding(padding: EdgeInsets.only(left: 30),
                        child: Container(
                          child: Text('Current goal',style: TextStyle(fontSize: 15, color: Colors.white),),
                        ),),

                                // New goal button
                                Padding(padding: EdgeInsets.only(top:3, right: 20),
                                  child: Container(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          // add your function here
                                          // Top be updated once database is complete
                                        },
                                        child: Text('New Goal'),
                                        style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(20), // set the radius value you want
                                            ),
                                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10,)
                                        ),
                                      )
                                  ),
                                ),
                                  ]
                              ),


                              // This displays the current savings goal
                              Padding(padding: EdgeInsets.only(top: 5, left: 30),
                                child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              currentGoal+'/',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 40,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              '\$ 5,000.00',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),),

                              // This is the percent indicator at the bottom of the current goal
                              // To be updated. This should be dynamic
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                               Padding(
                                padding: EdgeInsets.only(top: 10),
                                child: Center(
                                child: new LinearPercentIndicator(

                                  width: 250,
                                  lineHeight: 14.0,
                                  percent: 0.5,

                                  backgroundColor: Colors.grey,
                                  progressColor: Colors.blue,
                                ),
                              ),),])

                   ])),


                      // This displays the alternative texts that will only appear of the top container is minimized
                      Visibility(
                        visible: _isSecondColumnVisible,
                        child:
                        Padding(padding: EdgeInsets.only(top: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              currentGoal+'/',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 30,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              '\$ 5,000.00',
                              style: TextStyle(
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
                       onTap:()
                       {
                           setState(() {
                             _isPressed = !_isPressed;

                             if (_isPressed) {
                               topcontainerheight=50;
                               _isColumnVisible = false;
                               _isSecondColumnVisible = true;
                             } else {
                               topcontainerheight=150;
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
                       children: [
                         Padding(padding: EdgeInsets.only(left: screenWidth * 0.07,right: screenWidth * 0.07,top: 20),
                         child: Container( height: 400,

                           decoration: BoxDecoration(borderRadius: BorderRadius.circular(25), color: Colors.white,

                           boxShadow: [
                           BoxShadow (color: Colors.grey.withOpacity(0.5),
                           spreadRadius: 5,
                             blurRadius: 7,
                             offset: Offset(0,3),
                           ),]

                           ),


                           // This snippet displays the chart
                           child: SfCircularChart(

                             annotations: [
                               CircularChartAnnotation(
                                   widget: Text(
                                     tappedValue,
                                     style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                   )),
                               CircularChartAnnotation(
                                   widget: Text(
                                     tappedValueCat,
                                     style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                   ))

                             ],

                             title: ChartTitle(text: 'Expenses\n', textStyle: TextStyle(color: Colors.red, fontSize: 20, fontWeight: FontWeight.bold)),

                             legend: Legend(isVisible: true, overflowMode: LegendItemOverflowMode.wrap, position: LegendPosition.bottom),

                             tooltipBehavior: _tooltipBehavior,

                             series: <CircularSeries>[
                             DoughnutSeries<FinancialData, String>(
                               dataSource: _chartData,
                               xValueMapper: (FinancialData data,_) => data.expense,
                               yValueMapper: (FinancialData data,_) => data.amount,
                               dataLabelSettings: DataLabelSettings(isVisible: true,),
                               enableTooltip: true,
                               explode: true,
                               explodeGesture: ActivationMode.singleTap,
                               explodeIndex: selectedIndex,
                               radius: '120',


                               onPointTap: (pointInteractionDetails) {
                                 tappedValue = pointInteractionDetails
                                     .dataPoints![pointInteractionDetails.pointIndex!].y
                                     .toString()+"\n\n";
                                 tappedValueCat = pointInteractionDetails
                                     .dataPoints![pointInteractionDetails.pointIndex!].x
                                     .toString();
                                 setState(() {
                                   if (selectedIndex==pointInteractionDetails.pointIndex)
                                   {selectedIndex=100;
                                   tappedValue="";
                                   tappedValueCat="";}
                                   else{
                                   selectedIndex=pointInteractionDetails.pointIndex!;}

                                 }
                                 );
                               },

                             ),
                           ],
                           ),
                         ),
                         ),


                         Padding(padding: EdgeInsets.only(left: screenWidth * 0.07,right: screenWidth * 0.07,top: 20),
                           child: Container(

                             decoration: BoxDecoration(borderRadius: BorderRadius.circular(25), color: Colors.white,

                                 boxShadow: [
                                   BoxShadow (color: Colors.grey.withOpacity(0.5),
                                     spreadRadius: 5,
                                     blurRadius: 7,
                                     offset: Offset(0,3),
                                   ),]

                             ),
                             child: Padding(padding: EdgeInsets.all(15),
                             child: Text('Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
                             style: TextStyle(fontSize: 20,)),
                           ),
                           ),
                         ),


                         Padding(padding: EdgeInsets.only(left: screenWidth * 0.07,right: screenWidth * 0.07,top: 20, bottom: 15),
                           child: Container(


                             decoration: BoxDecoration(borderRadius: BorderRadius.circular(25), color: Colors.white,

                                 boxShadow: [
                                   BoxShadow (color: Colors.grey.withOpacity(0.5),
                                     spreadRadius: 5,
                                     blurRadius: 7,
                                     offset: Offset(0,3),
                                   ),]

                             ),

                             child: Padding(padding: EdgeInsets.all(15),

                             child: Text('Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
                                 style: TextStyle(fontSize: 20,)),
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


      // This is the navigation drawer. To be updated. No function yet
      drawer: Drawer(
        width: screenWidth/1.6,

        child: Container (
          color: Color.fromRGBO(104, 157, 180, 1.0),

        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[


            UserAccountsDrawerHeader(accountName: Text('John Smith'),
            accountEmail: Text('johnsmith@email.com'),
            currentAccountPicture: CircleAvatar(
              backgroundImage: AssetImage('assets/images/profilepic.png'),),

              decoration: BoxDecoration(
                color: Color.fromRGBO(81, 212, 189, 1.0),
              ),
            ),


            ListTile(

              leading: Icon(Icons.home, size:40.0, color: Colors.white,),
              title: Text('Home',style: TextStyle(

                color: Colors.white,
                fontSize: 20,
              ),),

              onTap: () {
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: Icon(Icons.manage_accounts, size:40.0, color: Colors.white,),
              title: Text('Profile',style: TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),),
              onTap: () {
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: Icon(Icons.settings, size:40.0, color: Colors.white,),
              title: Text('Settings',style: TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),),
              onTap: () {
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: Icon(Icons.account_balance_wallet, size:40.0, color: Colors.white,),
              title: Text('Accounts',style: TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),),
              onTap: () {
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: Icon(Icons.currency_bitcoin, size:40.0, color: Colors.white,),
              title: Text('Savings',style: TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),),
              onTap: () {
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: Icon(Icons.food_bank_sharp, size:40.0, color: Colors.white,),
              title: Text('Expenses',style: TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),),
              onTap: () {
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: Icon(Icons.help_outline_sharp, size:40.0, color: Colors.white,),
              title: Text('Help & Support',style: TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),),
              onTap: () {
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: Icon(Icons.logout_sharp, size:40.0, color: Colors.white,),
              title: Text('Logout',style: TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),),
              onTap: () {
                Navigator.pop(context);
              },
            ),

          ],
        ),
        ),

    ),
    );
  }

// This inserts the chart data to be displayed on the container
  List<FinancialData> getChartData()
  {
    final List<FinancialData> chartData = [
          FinancialData('Food', 24000),
          FinancialData('Transportation', 30000),
          FinancialData('Utilities', 95000),
          FinancialData('Entertainment', 95000),
          FinancialData('Others', 95000),
    ];
    return chartData;
  }

}
class FinancialData{
  FinancialData(this.expense, this.amount);
  final String expense;
  final int amount;

}


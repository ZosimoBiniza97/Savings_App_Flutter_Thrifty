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
  String tappedValue = '';
  String tappedValueCat = '';
  late List<FinancialData> _chartData;
  late TooltipBehavior _tooltipBehavior;
  int selectedIndex = 100;
  double topcontainerheight = 150;
  bool _isPressed = false;
  bool explode = true;
  String currentGoal = '\$3,563.00';
  bool _isColumnVisible = true;
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
    final screenWidth = MediaQuery.of(context).size.width;
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [
      SystemUiOverlay.bottom
    ]);


    return Scaffold(
      body: Builder(
        builder: (BuildContext context) {


          return Stack(
            children: [
              Container(
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

                              Padding(padding: EdgeInsets.only(left: 30),
                        child: Container(

                          child: Text('Current goal',style: TextStyle(fontSize: 15, color: Colors.white),),
                        ),),

                                Padding(padding: EdgeInsets.only(top:3, right: 10),
                                  child: Container(
                                      child: ElevatedButton(

                                        onPressed: () {
                                          // add your function here
                                        },
                                        child: Text('New Goal'),
                                        style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(20), // set the radius value you want
                                            ),
                                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10,)
                                        ),
                                      )

                                  ),),


                              ]),

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
                       ],
                     ),
                   )

                  ]
                  ),



                ),




              ),
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


      drawer: Drawer(
        width: screenWidth/2,

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


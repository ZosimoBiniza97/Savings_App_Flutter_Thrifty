import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moor_flutter/moor_flutter.dart';
import 'package:thrifty/database.dart';
import 'package:thrifty/main.dart';
import 'package:thrifty/signup.dart';

import 'account.dart';

class Login extends StatefulWidget {
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
// Initializing login data types: Username and Password (textfields) for local database query
  final usernameController = TextEditingController();

  final passwordController = TextEditingController();

  String Username = '';

  String Password = '';

  bool isLoggedIn = false;

  int? id_session_login;

  @override
  Widget build(BuildContext context) {
    // insertSampleUser();
    // insertSampleExpenses();

    // Calling auths method to see if authentication is successful
    auths(context);

    // This snippet hides the status bar of the android OS e.g., battery status, notification bar, etc
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom]);

    return new WillPopScope(
        onWillPop: () async => false,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Login',
          home: Scaffold(
            resizeToAvoidBottomInset: false,
            body: Container(

                // Adding the background for the login page
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/background.png"),
                    fit: BoxFit.cover,
                  ),
                ),

                // This listview includes the banner image, Sign In text, the text fields, and the buttons
                child: ListView(
                  children: <Widget>[
                    // Banner image
                    Container(
                      child: Image.asset(
                        'assets/images/login.png',
                        fit: BoxFit.cover,
                      ),
                    ),

                    // Sign in text
                    Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(10),
                        child: const Text(
                          'Sign in',
                          style: TextStyle(
                              fontSize: 30, fontWeight: FontWeight.bold),
                        )),

                    // Username text field
                    Container(
                      padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
                      child: TextField(
                        controller: usernameController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'User Name',
                          labelStyle: TextStyle(fontSize: 20),
                        ),
                      ),
                    ),

                    // Password text field
                    Container(
                      padding: const EdgeInsets.fromLTRB(30, 10, 30, 20),
                      child: TextField(
                        obscureText: true,
                        controller: passwordController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Password',
                          labelStyle: TextStyle(fontSize: 20),
                        ),
                      ),
                    ),

                    // Login button
                    Container(
                        height: 50,
                        padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                        child: ElevatedButton(
                          child: const Text('Login'),
                          onPressed: () async {
                            Username = usernameController.text;
                            Password = passwordController.text;
                            id_session_login =
                                await checkLogin(Username, Password);
                            if (id_session_login != null) {
                              id_session = id_session_login;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ViewAccount()),
                              );
                            } else if (Username.isEmpty || Password.isEmpty) {
                              showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Invalid Login'),
                                    content: Text(
                                        'Please enter Username and Password'),
                                    actions: <Widget>[
                                      TextButton(
                                        child: Text('OK'),
                                        onPressed: () {
                                          Navigator.pop(context);
                                          // Do something when OK button is pressed
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            } else if (!isLoggedIn) {
                              showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Invalid Login'),
                                    content: Text(
                                        'The Username or Password is incorrect. Please try again. '),
                                    actions: <Widget>[
                                      TextButton(
                                        child: Text('OK'),
                                        onPressed: () {
                                          usernameController.clear();
                                          passwordController.clear();
                                          Navigator.pop(context);
                                          // Do something when OK button is pressed
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          },

                          // Design of the login button
                          style: ButtonStyle(backgroundColor:
                              MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) {
                              if (states.contains(MaterialState.disabled)) {
                                return Colors.grey;
                              }
                              return Colors
                                  .grey.shade700; // Change default color here
                            },
                          ), overlayColor:
                              MaterialStateProperty.resolveWith<Color?>(
                                  (Set<MaterialState> states) {
                            if (states.contains(MaterialState.pressed)) {
                              return Colors.black; //<-- SEE HERE
                            }
                            return null; // Defer to the widget's default.
                          })),
                        )),

                    // Text button for forgot password
                    TextButton(
                      onPressed: () {
                        //forgot password screen
                      },
                      child: const Text(
                        'Forgot Password',
                      ),
                    ),

                    // This row is entirely for the line separator under Forgot Password
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 40),
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 2),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.black,
                                    width: 1.0,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                      mainAxisAlignment: MainAxisAlignment.center,
                    ),

                    // Does not have an account text item
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const <Widget>[
                          Text('Do not have an account?'),
                        ],
                      ),
                    ),

                    // This row includes the Sign Up button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        ElevatedButton(
                            child: const Text('Sign up'),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SignUpPage()),
                              );
                              // Do something when Sign Up is pressed
                              // To be updated
                            },
                            style: ButtonStyle(
                                minimumSize: MaterialStateProperty.all<Size>(
                                  Size(100, 40),
                                ),
                                shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18.0),
                                )),
                                overlayColor:
                                    MaterialStateProperty.resolveWith<Color?>(
                                        (Set<MaterialState> states) {
                                  if (states.contains(MaterialState.pressed)) {
                                    return Colors.blue.shade900; //<-- SEE HERE
                                  }
                                  return null; // Defer to the widget's default.
                                })))
                      ],
                    ),
                  ],
                )),
          ),
        ));
  }
}

// This is a database method. This method will check if the Username and Password submitted by the user exists in the database
Future<int?> checkLogin(String username, String password) async {
  // Use the select statement to retrieve the row from the users table with the matching username and password
  final query = db.select(db.users)
    ..where((u) => u.username.equals(username) & u.password.equals(password));
  final result = await query.get();

  // Return true if the result is not empty, indicating a matching user was found

  return result.isNotEmpty ? result.first.id : null;
}

// This is a test method that inserts a sample user data to the user table in the schema
// Future<void> insertSampleUser() async {
//   try {
//     await db.into(db.users).insert(
//       UsersCompanion(
//         firstname: Value('Zeus'),
//         lastname: Value('Biniza'),
//         username: Value('admin'),
//         email: Value('johndoe@example.com'),
//         password: Value('admin'),
//       ),
//     );
//   }
//   on DatabaseException catch (e) {
//     if (e.toString().contains('UNIQUE')) {
//       // handle the unique constraint violation error here
//       print('already exists');
//     } else {
//       rethrow;
//     }
//   }
// }

// Future<void> insertSampleExpenses() async {
//   try {
//     await db.batch((batch) {
//       batch.insertAll(
//         db.expenses,
//         [
//           ExpensesCompanion(
//             username: Value('admin'),
//             category: Value('Transportation'),
//             amount: Value(50000),
//             note: Value('Gas Money'),
//           ),
//           ExpensesCompanion(
//             username: Value('admin'),
//             category: Value('Food'),
//             amount: Value(25000),
//             note: Value('Dinner with friends'),
//           ),
//           ExpensesCompanion(
//             username: Value('admin'),
//             category: Value('Entertainment'),
//             amount: Value(15000),
//             note: Value('Movie tickets'),
//           ),
//           ExpensesCompanion(
//             username: Value('admin'),
//             category: Value('Utilities'),
//             amount: Value(15000),
//             note: Value('Meralco'),
//           ),
//           ExpensesCompanion(
//             username: Value('admin'),
//             category: Value('Others'),
//             amount: Value(15000),
//             note: Value('Tuition'),
//           ),
//         ],
//       );
//     });
//   } on MoorWrappedException catch (e) {
//     if (e.cause.toString().contains('UNIQUE')) {
//       // handle the unique constraint violation error here
//       print('already exists');
//     } else {
//       rethrow;
//     }
//   }
// }

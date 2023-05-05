import 'package:flutter/material.dart';
import 'package:moor_flutter/moor_flutter.dart' hide Column;
import 'package:thrifty/database.dart';
import 'package:thrifty/login.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();

  String _firstName = '';
  String _lastName = '';
  String _username = '';
  String _email = '';
  String _password = '';
  String _confirmPassword = '';

  void _submitForm() {
    _formKey.currentState?.save();
    if (_formKey.currentState!.validate()) {
      insertSampleUser();
      print('password: $_password');
      print('username: $_username');
      print('_confirmPassword: $_confirmPassword');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
        backgroundColor: Colors.teal,
        elevation: 0.0,
      ),
      resizeToAvoidBottomInset: false,
      body: Stack(children: [
        // Adding the background for the signup page
        Image.asset(
          "assets/images/background.png",
          fit: BoxFit.cover,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
        ),

        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 70),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(40)),
            ),
            child: Padding(
              padding: EdgeInsets.only(left: 20, right: 20, top: 20),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      TextFormField(
                        initialValue: 'John',
                        decoration: InputDecoration(labelText: 'First Name'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your first name';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _firstName = value!;
                        },
                      ),
                      TextFormField(
                        initialValue: 'Smith',
                        decoration: InputDecoration(labelText: 'Last Name'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your last name';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _lastName = value!;
                        },
                      ),
                      TextFormField(
                        initialValue: 'admin1',
                        decoration: InputDecoration(labelText: 'Username'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a username';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _username = value!;
                        },
                      ),
                      TextFormField(
                        initialValue: 'Johnsmith@gmail.com',
                        decoration: InputDecoration(labelText: 'Email'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email address';
                          }
                          // TODO: Add email validation logic here
                          return null;
                        },
                        onSaved: (value) {
                          _email = value!;
                        },
                      ),
                      TextFormField(
                        initialValue: 'admin',
                        decoration: InputDecoration(labelText: 'Password'),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a password';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _password = value!;
                        },
                      ),
                      TextFormField(
                        initialValue: 'admin',
                        decoration:
                            InputDecoration(labelText: 'Confirm Password'),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != _password) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _confirmPassword = value!;
                        },
                      ),
                      Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: ElevatedButton(
                          onPressed: _submitForm,
                          child: Text('Register'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  Future<void> insertSampleUser() async {
    if (await checkUsername(_username)) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Username already exists'),
            content: Text('Please use a different username.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Ok'),
              ),
            ],
          );
        },
      );
    } else if (await checkEmail(_email)) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Email already exists'),
            content: Text('Please use a different email.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Ok'),
              ),
            ],
          );
        },
      );
    } else {
      try {
        await db.into(db.users).insert(
              UsersCompanion(
                id: Value(await getUsersCount()),
                firstname: Value(_firstName),
                lastname: Value(_lastName),
                username: Value(_username),
                email: Value(_email),
                password: Value(_password),
              ),
            );
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Success'),
            content: Text('Account created successfully'),
            actions: [
              TextButton(
                onPressed: () => Navigator.push(
                    context, MaterialPageRoute(builder: (context) => Login())),
                child: Text('Ok'),
              ),
            ],
          ),
        );
      } on MoorWrappedException catch (e) {
        if (e.cause.toString().contains('UNIQUE')) {
          // handle the unique constraint violation error here
        } else {
          rethrow;
        }
      }
    }
  }

  Future<bool> checkUsername(String username) async {
    // Use the select statement to retrieve the row from the users table with the matching username and password
    final query = db.select(db.users)
      ..where((u) => u.username.equals(username));
    final result = await query.get();

    // Return true if the result is not empty, indicating a matching user was found
    return result.isNotEmpty;
  }

  Future<bool> checkEmail(String email) async {
    // Use the select statement to retrieve the row from the users table with the matching username and password
    final query = db.select(db.users)..where((u) => u.email.equals(email));
    final result = await query.get();

    // Return true if the result is not empty, indicating a matching user was found
    return result.isNotEmpty;
  }

  Future<int> getUsersCount() async {
    final countResult =
        await db.customSelect('SELECT COUNT(*) FROM users').getSingle();
    return (countResult.data.values.first + 1) as int;
  }
}

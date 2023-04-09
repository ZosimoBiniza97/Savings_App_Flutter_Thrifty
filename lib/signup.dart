import 'package:flutter/material.dart';
import 'package:moor_flutter/moor_flutter.dart' hide Column;
import 'package:thrifty/database.dart';
import 'package:thrifty/login.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  static const primaryColor = Color(0xFF151026);
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
      // TODO: Add registration logic here
      insertSampleUser();
      print('password: $_password');
      print('username: $_username');
      print('_confirmPassword: $_confirmPassword');
      Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Login())
      );
    }
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
        brightness: Brightness.light,
        backgroundColor: Colors.teal,
        elevation: 0.0,
      ),
      resizeToAvoidBottomInset: false,
      body: Stack(
    children: [
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
              padding: EdgeInsets.only(left: 20, right: 20,top: 20),

              child: SingleChildScrollView(

              child: Form(
                key: _formKey,

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    TextFormField(
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
                      decoration: InputDecoration(labelText: 'Confirm Password'),
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
                        onPressed:
                        _submitForm,
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
    try {
      await db.into(db.users).insert(
        UsersCompanion(
          firstname: Value(_firstName),
          lastname: Value(_lastName),
          username: Value(_username),
          email: Value(_email),
          password: Value(_password),
        ),
      );
    }
    on MoorWrappedException catch (e) {
      if (e.cause.toString().contains('UNIQUE')) {
        // handle the unique constraint violation error here
        print('already exists');
      } else {
        rethrow;
      }
    }
  }


}



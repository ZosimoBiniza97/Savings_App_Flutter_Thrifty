import 'package:flutter/material.dart';
import 'package:moor_flutter/moor_flutter.dart' hide Column;
import 'package:thrifty/account.dart';
import 'package:thrifty/database.dart';

String NewFirstname = '';
String NewLastname = '';
String NewUsername = '';
String NewEmail = '';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKeyEdit = GlobalKey<FormState>();
  final _keyDialogForm_changePass = GlobalKey<FormState>();
  bool _isEditMode = false;
  String oldPassword = '';
  String newPassword = '';
  String confirmPassword = '';

  void _submitForm() {
    _formKeyEdit.currentState?.save();
    if (_formKeyEdit.currentState!.validate()) {
      ProfileEdit(id_session!, NewFirstname, NewLastname, NewUsername, NewEmail,
          password);
    }
  }

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        drawer: MyDrawer(),
        body: Builder(
          builder: (BuildContext context) {
            return Stack(
              children: [
                // Detects if the scrollable containers are being scrolled

                Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/profilebg.png"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                ListView(children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 40, bottom: 5),
                    child: Image.asset('assets/images/profilepicture.png',
                        width: 150,
                        height:
                            150), // replace with your image file path and dimensions
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: 20,
                      right: 20,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(40)),
                      ),
                      child: Column(children: [
                        Padding(
                          padding: EdgeInsets.only(top: 20),
                          child: Center(
                            child: Text(
                              'Profile',
                              style: TextStyle(
                                fontSize: 30,
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding:
                              EdgeInsets.only(left: 20, right: 20, top: 10),
                          child: Form(
                            key: _formKeyEdit,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                TextFormField(
                                  decoration:
                                      InputDecoration(labelText: 'First Name'),
                                  initialValue: firstname,
                                  enabled: _isEditMode,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your first name';
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    NewFirstname = value!;
                                  },
                                ),
                                SizedBox(height: 7),
                                TextFormField(
                                  decoration:
                                      InputDecoration(labelText: 'Last Name'),
                                  initialValue: lastname,
                                  enabled: _isEditMode,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your last name';
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    NewLastname = value!;
                                  },
                                ),
                                SizedBox(height: 7),
                                TextFormField(
                                  decoration:
                                      InputDecoration(labelText: 'Username'),
                                  initialValue: username,
                                  enabled: _isEditMode,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter a username';
                                    }

                                    return null;
                                  },
                                  onSaved: (value) {
                                    NewUsername = value!;
                                  },
                                ),
                                SizedBox(height: 7),
                                TextFormField(
                                  decoration:
                                      InputDecoration(labelText: 'Email'),
                                  initialValue: email,
                                  enabled: _isEditMode,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your email address';
                                    }
                                    checkEmail(value);

                                    return null;
                                  },
                                  onSaved: (value) {
                                    NewEmail = value!;
                                  },
                                ),
                                SizedBox(height: 7),
                                Container(
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.only(top: 16.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        _isEditMode
                                            ? Text('')
                                            : ElevatedButton(
                                                onPressed: () {
                                                  setState(() {
                                                    _isEditMode = true;
                                                  });
                                                },
                                                child: Text('Edit Profile'),
                                                style: ElevatedButton.styleFrom(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20.0),
                                                  ),
                                                ),
                                              ),
                                        !_isEditMode
                                            ? Text('')
                                            : ElevatedButton(
                                                onPressed: () {
                                                  _submitForm();
                                                },
                                                child: Text('Save'),
                                                style: ElevatedButton.styleFrom(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20.0),
                                                  ),
                                                ),
                                              ),
                                        !_isEditMode
                                            ? SizedBox(width: 0)
                                            : SizedBox(width: 16),
                                        !_isEditMode
                                            ? Text('')
                                            : ElevatedButton(
                                                onPressed: () {
                                                  setState(() {
                                                    _isEditMode = false;
                                                  });
                                                  _formKeyEdit.currentState
                                                      ?.reset();
                                                },
                                                child: Text('Cancel'),
                                                style: ElevatedButton.styleFrom(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20.0),
                                                  ),
                                                ),
                                              ),
                                      ],
                                    )),
                              ],
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            showChangePassDialog(id_session!);
                          },
                          child: Text('Change Password'),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                      ]),
                    ),
                  ),
                ]),
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
      ),
    );
  }

  ProfileEdit(int id, String FName, String LName, String UName, String Email,
      String Password) async {
    if (await checkUsername(UName) && (UName != username)) {
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
    } else if (await checkEmail(Email) && (Email != email)) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Email already in use'),
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
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Confirmation'),
            content: Text('Are you sure you want to save the changes?'),
            actions: <Widget>[
              TextButton(
                child: Text('No'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text('Yes'),
                onPressed: () async {
                  // Save the changes
                  ProfileDelete(id_session!);
                  await db.into(db.users).insert(
                        UsersCompanion(
                          id: Value(id),
                          firstname: Value(FName),
                          lastname: Value(LName),
                          username: Value(UName),
                          email: Value(Email),
                          password: Value(Password),
                        ),
                      );
                  setState(() {
                    getUserValues();
                    _isEditMode = false;
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  checkUsername(String username) async {
    // Use the select statement to retrieve the row from the users table with the matching username and password
    final query = db.select(db.users)
      ..where((u) => u.username.equals(username));
    final result = await query.get();

    // Return true if the result is not empty, indicating a matching user was found
    return result.isNotEmpty;
  }

  ProfileDelete(int id) async {
    final query = db.delete(db.users)
      ..where((users) => users.id.equals(id))
      ..go();
    await query;
  }

  checkEmail(String email) async {
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

  passwordChange(int id, String oldPassword, String newPass) async {
    if (await checkLogin(id, oldPassword)) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Confirmation'),
            content: Text('Are you sure you want to change password?'),
            actions: [
              TextButton(
                onPressed: () async {
                  final query = db.update(db.users)
                    ..where((users) => users.id.equals(id))
                    ..write(UsersCompanion(password: Value(newPassword)));

                  await query;

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
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Incorrect password'),
            content: Text(
                'Password is incorrect. Please type in your correct password.'),
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
    }
  }

  Future<bool> checkLogin(int ID, String password) async {
    // Use the select statement to retrieve the row from the users table with the matching username and password
    final query = db.select(db.users)
      ..where((u) => u.id.equals(ID) & u.password.equals(password));
    final result = await query.get();

    // Return true if the result is not empty, indicating a matching user was found

    return result.isNotEmpty;
  }

  Future showChangePassDialog(int id) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Change password'),
            content: SingleChildScrollView(
              child: Form(
                key: _keyDialogForm_changePass,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextFormField(
                      obscureText: true,
                      maxLength: 50,
                      decoration: InputDecoration(
                        labelText: 'Current password',
                        counterText: "",
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your current password';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        oldPassword = value!;
                      },
                    ),
                    TextFormField(
                      obscureText: true,
                      maxLength: 50,
                      decoration: InputDecoration(
                        labelText: 'New password',
                        counterText: "",
                      ),
                      validator: (value) {
                        print('new password ' + value!);
                        if (value == null || value.isEmpty) {
                          return 'Please enter your new password';
                        }
                        newPassword = value!;
                        return null;
                      },
                      onSaved: (value) {},
                    ),
                    TextFormField(
                      obscureText: true,
                      maxLength: 50,
                      decoration: InputDecoration(
                        labelText: 'Confirm password',
                        counterText: "",
                      ),
                      validator: (value) {
                        print(
                            'confirm password validator: $value, newPassword: $newPassword');
                        if (value == null || value.isEmpty) {
                          return 'Please enter your new password';
                        }
                        if (value != newPassword) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        confirmPassword = value!;
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              ElevatedButton(
                onPressed: () {
                  if (_keyDialogForm_changePass.currentState!.validate()) {
                    _keyDialogForm_changePass.currentState?.save();
                    passwordChange(id, oldPassword, newPassword);
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

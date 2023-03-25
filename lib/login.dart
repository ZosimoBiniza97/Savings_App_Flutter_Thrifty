import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moor_flutter/moor_flutter.dart';
import 'package:moor_flutter/moor_flutter.dart';
import 'package:thrifty/main.dart';
import 'account.dart';
import 'package:moor_flutter/moor_flutter.dart';


class Login extends StatelessWidget {

  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();


    @override
    Widget build(BuildContext context) {

      auths(context);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [
        SystemUiOverlay.bottom
      ]);

      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Login',
        home: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/background.png"),
                  fit: BoxFit.cover,
                ),
              ),
              child: ListView(

                children: <Widget>[
                  Container(
                    child: Image.asset(
                      'assets/images/login.png',
                      fit: BoxFit.cover,
                    ),

                  ),

                  Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(10),
                      child: const Text(
                        'Sign in',
                        style: TextStyle(fontSize: 30,
                          fontWeight: FontWeight.bold
                        ),
                      )),


                  Container(
                    padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
                    child: TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'User Name',
                        labelStyle: TextStyle(
                          fontSize:20

                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(30, 10, 30, 20),
                    child: TextField(
                      obscureText: true,
                      controller: passwordController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Password',
                        labelStyle: TextStyle(
                            fontSize:20

                        ),
                      ),
                    ),
                  ),
                  Container(
                      height: 50,
                      padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                      child: ElevatedButton(

                        child: const Text('Login'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ViewAccount()),
                          );
                          print(nameController.text);
                          print(passwordController.text);
                        },
                        style: ButtonStyle(

                            backgroundColor: MaterialStateProperty.resolveWith<
                                Color>(
                                  (Set<MaterialState> states) {
                                if (states.contains(MaterialState.disabled)) {
                                  return Colors.grey;
                                }
                                return Colors.grey
                                    .shade700; // Change default color here
                              },
                            ),

                            overlayColor: MaterialStateProperty.resolveWith<
                                Color?>(
                                    (Set<MaterialState> states) {
                                  if (states.contains(MaterialState.pressed)) {
                                    return Colors.black; //<-- SEE HERE
                                  }
                                  return null; // Defer to the widget's default.
                                })),

                      )
                  ),
                  TextButton(
                    onPressed: () {
                      //forgot password screen
                    },
                    child: const Text('Forgot Password',),
                  ),

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
                 Padding(padding: EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const <Widget>[
                      Text('Does not have account?'),

                    ],
                  ),),



                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[

                        ElevatedButton(
                            child: const Text('Sign up'),
                            onPressed: () {
                              print(nameController.text);
                              print(passwordController.text);
                            },

                            style: ButtonStyle(
                                minimumSize: MaterialStateProperty.all<Size>(
                                  Size(100, 40),),

                                shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18.0),

                                    )),

                                overlayColor: MaterialStateProperty.resolveWith<
                                    Color?>(
                                        (Set<MaterialState> states) {
                                      if (states.contains(
                                          MaterialState.pressed)) {
                                        return Colors.blue
                                            .shade900; //<-- SEE HERE
                                      }
                                      return null; // Defer to the widget's default.
                                    })

                            )

                        )
                      ],
                    ),



                ],
              )

          ),


        ),
      );
    }
  }


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/services.dart';
import 'package:thrifty/account.dart';
import 'login.dart'; // import the file containing the Login widget
import 'package:local_auth/local_auth.dart';


LocalAuthentication auth = LocalAuthentication();



void main(){

  runApp(MyApp());


}

Future<void> auths(BuildContext context)
async {
  bool isAuthenticated = await authenticate();
  if (isAuthenticated) {

    showDialog(
      context: context,
      builder: (BuildContext context) {



        return AlertDialog(
          title: Text('Authentication Successful'),
          content: Text('Authentication Successful'),
          actions: <Widget>[

            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ViewAccount()),
                );

               // Do something when OK button is pressed
              },
            ),
          ],
        );
      },
    );


  }

  else {



  }

}


Future authenticate() async {
  final bool isBiometricsAvailable = await auth.isDeviceSupported();
  if (!isBiometricsAvailable) return false;
  try {
    return await auth.authenticate(
      localizedReason: 'Scan Fingerprint To Login',
      options: const AuthenticationOptions(
        useErrorDialogs: true,
        stickyAuth: true,
      ),
    );
  } on PlatformException {
    return;
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      home: Scaffold(
        body:
        Login(), // add the Login widget here
      ),
    );
  }
}


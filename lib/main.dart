import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttery_geeky_math/menu.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
FirebaseUser user;
Future<void> signOut() async{
  return _auth.signOut();
}

final double betweenMargins = 8;

// Color Palette: https://colorhunt.co/palette/138016
// Colors.grey.shade200
// Colors.tealAccent.shade400
// Colors.lightBlue.shade600
// Colors.grey.shade800

void main() => runApp(MaterialApp(title: 'Geeky Math',
  theme: ThemeData(
    fontFamily: 'Raleway',
    accentColor: Colors.grey.shade200,
    accentColorBrightness: Brightness.light,
    backgroundColor: Colors.grey.shade800,
    bottomAppBarColor: Colors.tealAccent.shade400,
    brightness: Brightness.dark,
    buttonColor: Colors.tealAccent.shade700,
    canvasColor: Colors.grey.shade800,
    cardColor: Colors.teal.shade900,
    cursorColor: Colors.lightBlue.shade600,
    dialogBackgroundColor: Colors.tealAccent.shade400,
    dividerColor: Colors.grey.shade200,
    disabledColor: Colors.grey.shade200,
    errorColor: Colors.grey.shade200,
    hintColor: Colors.grey.shade300,
    indicatorColor: Colors.tealAccent.shade700,
    primaryColor: Colors.grey.shade800,
    primaryColorBrightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.grey.shade800,
    splashColor: Colors.tealAccent.shade400,
  ),
  home: LoginScreen(),
));

class LoginScreen extends StatelessWidget {
  TextEditingController _uname = TextEditingController();
  TextEditingController _pword = TextEditingController();
  TextEditingController _unameSignUp = TextEditingController();
  TextEditingController _pwordSignUp = TextEditingController();
  TextEditingController _fname = TextEditingController();
  TextEditingController _lname = TextEditingController();
  TextEditingController _pword2 = TextEditingController();

  Future<void> _handleSignIn(var context, String email, String password) async{
    AlertDialog dialog = new AlertDialog(
        content: new Text("Loading...")
    );
    showDialog(context: context, builder: (BuildContext context) => dialog);
    _auth.signInWithEmailAndPassword(email: email, password: password)
        .then((FirebaseUser user) {
    }).catchError((e) {
      Navigator.pop(context);
      showDialog(context: context,
          builder: (BuildContext context) =>
              AlertDialog(content: Text("Incorrect Password")));
      return;
    }
    );
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(
      builder: (context) => MainMenu(_auth)),
    );
  }

  Future<String> _createUser(String email, String password) async{
    FirebaseUser user = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    await user.sendEmailVerification();
    return user.uid;
  }

  Future<void> _createUserDocument(String uid, String fname, String lname) async{
    DocumentReference postRef = Firestore.instance.collection('users').document(uid);
    Firestore.instance.runTransaction((Transaction tx) async {
      DocumentSnapshot postSnapshot = await tx.get(postRef);
      if (postSnapshot.exists) {
        return;
      }
    });
    Firestore.instance.collection('users').document(uid)
        .setData({ 'class_id': "", 'first_name': fname, 'last_name': lname, 'teacher': false, 'teacher_id': "", 'user_id': '$uid' });
  }

  Future<bool> _newUser(var context, String email, String password, String password2, String first_name, String last_name) async{
    AlertDialog dialog = new AlertDialog(
        content: new Text("Loading")
    );
    showDialog(context: context, builder: (BuildContext context) => dialog);
    if (password.compareTo(password2) != 0){
      Navigator.pop(context);
      AlertDialog dialog = new AlertDialog(
          content: new Text("Passwords do not match.")
      );
      showDialog(context: context, builder: (BuildContext context) => dialog);
      return false; // If our strings aren't the same, don't allow them to continue, return a message that passwords don't match.
    }
    else{
      String id = await _createUser(email, password);
      _createUserDocument(id, first_name, last_name);
      Navigator.pop(context);
      _handleSignIn(context, email, password);
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    Container loginScreen;
    Container signUpScreen;

    Container title = Container(child: Text("Geeky Math", style: TextStyle(fontFamily: 'Ubuntu', fontSize: 36)), padding: EdgeInsets.all(betweenMargins));

    TextField username = TextField(controller: _uname, decoration: InputDecoration(labelText: "Email", border: OutlineInputBorder()), keyboardType: TextInputType.emailAddress, );
    TextField password = TextField(controller: _pword, decoration: InputDecoration(labelText: "Password", border: OutlineInputBorder()), keyboardType: TextInputType.text, obscureText: true,);
    TextField usernameSignUp = TextField(controller: _unameSignUp, decoration: InputDecoration(labelText: "Email", border: OutlineInputBorder()), keyboardType: TextInputType.emailAddress,);
    TextField passwordSignUp = TextField(controller: _pwordSignUp, decoration: InputDecoration(labelText: "Password", border: OutlineInputBorder()), keyboardType: TextInputType.text, obscureText: true,);
    TextField firstname = TextField(controller: _fname, decoration: InputDecoration(labelText: "First Name", border: OutlineInputBorder()), keyboardType: TextInputType.text,);
    TextField lastname = TextField(controller: _lname, decoration: InputDecoration(labelText: "Last Name", border: OutlineInputBorder()), keyboardType: TextInputType.text,);
    TextField password2 = TextField(controller: _pword2, decoration: InputDecoration(labelText: "Re-Enter Password", border: OutlineInputBorder()), keyboardType: TextInputType.text, obscureText: true,);

    RaisedButton login = RaisedButton(child: Text("Login"), onPressed: (){ _handleSignIn(context, _uname.text.toString(), _pword.text.toString()); });
    RaisedButton signUp = RaisedButton(child: Text("Sign Up"), onPressed: (){ _newUser(context, _unameSignUp.text.toString(), _pwordSignUp.text.toString(), _pword2.text.toString(), _fname.text.toString(), _lname.text.toString()); });

    loginScreen = Container(child: Column(children: [title, Container(child: username, padding: EdgeInsets.all(betweenMargins),), Container(child: password, padding: EdgeInsets.all(betweenMargins)), Container(child: login, padding: EdgeInsets.all(betweenMargins))], crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.center,), padding: EdgeInsets.all(16));
    signUpScreen = Container(child: Column(children: [title, Container(child: usernameSignUp, padding: EdgeInsets.all(betweenMargins)), Container(child: passwordSignUp, padding: EdgeInsets.all(betweenMargins)), Container(child: password2, padding: EdgeInsets.all(betweenMargins)), Container(child: firstname, padding: EdgeInsets.all(betweenMargins)), Container(child: lastname, padding: EdgeInsets.all(betweenMargins)), Container(child: signUp, padding: EdgeInsets.all(betweenMargins))], crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.center,), padding: EdgeInsets.all(16));

    return DefaultTabController(length: 2, child:
    Scaffold(appBar:
    AppBar(title: Text('Geeky Math'), bottom: TabBar(
        tabs: [
          Tab(text: "Login"),
          Tab(text: "Sign Up")
        ]
    )),
        body: TabBarView(
          children: [loginScreen, signUpScreen],
        )
    )
    );
  }
}

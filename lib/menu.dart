import 'package:flutter/material.dart';
import 'package:fluttery_geeky_math/testing.dart';
import 'package:fluttery_geeky_math/classes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final int test_options = 3;
final List<String> test_types = ["Decimal to Binary", "Binary to Decimal", "Mixed Binary/Decimal"];

class MainMenu extends StatelessWidget {
  var _auth;

  MainMenu(this._auth);

  void goToClass(var context){
    _auth.currentUser().then( (u) {
      Firestore.instance.collection('users').document('${u.uid}').get().then((DocumentSnapshot ds) {
        if(ds.data["class_id"] != "") {
          Navigator.push(context, MaterialPageRoute(builder: (context) => Classes(_auth, ds.data["class_id"], ds.data["teacher"])));
        }
        else {
          AlertDialog dialog = new AlertDialog(
              content: new Text("You don't have a class! Join one through your profile or become a teacher!")
          );
          showDialog(context: context, builder: (BuildContext context) => dialog);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Container menu;

    RaisedButton classManage = RaisedButton(child: Text("Your class"), onPressed: (){ goToClass(context); } );
    RaisedButton randomTest = RaisedButton(child: Text("Start a Random Test"), onPressed: (){ Navigator.push(context, MaterialPageRoute(builder: (context) => RandomTestSelection(_auth))); } );

    menu = Container(child: Center(child: Column(children: <Widget>[classManage, randomTest],)));

    return Scaffold(appBar: AppBar(title: Text("Geeky Math - Menu")), body: menu);
  }
}

class RandomTestSelection extends StatelessWidget {
  var _auth;

  RandomTestSelection(this._auth);

  void startTest(var context, var testType){
    Navigator.push(context, MaterialPageRoute(
        builder: (context) => TestDisplay(RandomTest(testType + 1, _auth.currentUser().toString()))),);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> selections = List<Widget>.generate(3, (int index) {
      return ListTile(title: Text("${test_types[index]}"), onTap: (){ startTest(context, index); });
    });

    return Scaffold(appBar: AppBar(title: Text("Geeky Math - Select Test")), body: Container(child: Column(children: selections)));
  }
}

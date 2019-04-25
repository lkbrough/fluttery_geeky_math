import 'package:flutter/material.dart';
import 'package:fluttery_geeky_math/testing.dart';
import 'package:fluttery_geeky_math/classes.dart';

final int test_options = 3;
final List<String> test_types = ["Decimal to Binary", "Binary to Decimal", "Mixed Binary/Decimal"];

class MainMenu extends StatelessWidget {
  var _auth;

  MainMenu(this._auth);

  @override
  Widget build(BuildContext context) {
    Container menu;

    RaisedButton classManage = RaisedButton(child: Text("Your class"), onPressed: (){} );
    RaisedButton randomTest = RaisedButton(child: Text("Start a Random Test"), onPressed: (){ Navigator.push(context, MaterialPageRoute(builder: (context) => RandomTestSelection(_auth))); } );

    menu = Container(child: Column(children: <Widget>[classManage, randomTest],));

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

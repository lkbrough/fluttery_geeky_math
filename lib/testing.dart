import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'dart:math';

class Question {
  int type;
  String question, answer;
  String hint;

  Question(this.type, this.question){
    if (type == 1) {
      answer = int.parse(question).toRadixString(2);
      hint = "Convert number to binary";
    }
    else if (type == 2) {
      answer = question;
      question = int.parse(answer).toRadixString(2);
      hint = "Convert number to Decimal";
    }
    else if (type == 3) {
      var random = new Random();
      if(random.nextInt(1) == 1){
        answer = question;
        question = int.parse(answer).toRadixString(2);
        hint = "Convert number to Decimal";
      }
      else {
        answer = int.parse(question).toRadixString(2);
        hint = "Convert number to binary";
      }
    }
  }

  bool check(var response){
    return response.equals(answer);
  }

}

class ClassroomTest extends StatefulWidget {
  var uid, cid, tid; // current user id, classroom id, test id

  ClassroomTest(this.uid, this.cid, this.tid);

  @override
  _ClassroomTestState createState() => _ClassroomTestState(uid, cid, tid);
}

class _ClassroomTestState extends State<ClassroomTest> {
  var uid, cid, tid; // user id, classroom id, test id
  var questionsDisplay;
  var textEditingControllers;
  var questions;

  _ClassroomTestState(this.uid, this.cid, this.tid);

  Future<void> getQuestions() async{
    questionsDisplay = <Widget>[];
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('classes').document("$cid").collection("tests").document("$tid").collection("questions").snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
        if (snapshot.hasError) {
          questionsDisplay.append(Card(child: Text("Error, please try again later")));
          return;
        }
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            questionsDisplay.append(Card(child: Text("Loading...")));
            return;
          default:
            textEditingControllers = List<TextEditingController>.generate(snapshot.data.documents.length, (int index) {
              return TextEditingController();
            });
            questions = List<Question>.generate(snapshot.data.documents.length, (int index){
              return Question(snapshot.data.documents[index].data["type"], snapshot.data.documents[index].data["decimal"]);
            });
            questionsDisplay = List<Widget>.generate(snapshot.data.documents.length, (int index) {
              return Card(child: Column(children: <Widget>[
                Text("${questions[index].question}"),
                TextField(controller: textEditingControllers[index], decoration: InputDecoration(labelText: "${questions[index].hint}",), keyboardType: TextInputType.numberWithOptions(signed: false, decimal: false),),
              ]));
            });
        }
      }
    );
  }

  Future<void> grade() async{
    double grade;
    int num_questions = questions.length;
    int correct = 0;
    for (var i = 0; i < num_questions; i++){
      if(questions[i].check(textEditingControllers[i].text.toString())){
        correct += 1;
      }
    }
    grade = correct / grade;

    var snap = Firestore.instance.collection("classes").document("$cid").collection("tests").document("$tid").snapshots().toList();
    print(snap);

    Firestore.instance.collection("classes").document("$cid").collection("tests").document("$tid").updateData({ });
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

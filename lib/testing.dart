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
      if(random.nextInt(1) == 2){
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
    return response == answer;
  }

}

class ClassroomTest{
  var uid, cid, tid; // user id, classroom id, test id
  var questionsDisplay;
  var textEditingControllers;
  var questions;

  ClassroomTest(this.uid, this.cid, this.tid);

  Future<void> getQuestions() async{
    questionsDisplay = <Widget>[];
    StreamBuilder<QuerySnapshot>(
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
                TextField(controller: textEditingControllers[index], decoration: InputDecoration(labelText: "${questions[index].hint}",), keyboardType: TextInputType.number,),
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

    var taken_list;
    Firestore.instance.collection("classes").document("$cid").collection("tests").document("$tid").get().then((DocumentSnapshot ds) {
      taken_list = ds["taken_by"];
    });
    taken_list.append("$uid");
    Firestore.instance.collection("classes").document("$cid").collection("tests").document("$tid").updateData({"taken_by": taken_list});

    var grades;
    Firestore.instance.collection("classes").document("$cid").collection("students").document("$uid").get().then((DocumentSnapshot ds) {
      grades = ds["test scores"];
    });
    grades.append(grade);
    Firestore.instance.collection("classes").document("$cid").collection("students").document("$uid").updateData({"test scores": grades});
  }
}

class RandomTest {
  var type, uid;
  int streak = 0;
  var currentQuestion;
  var display;
  var previousResponse;
  TextEditingController response = TextEditingController();
  bool submitted = false;

  RandomTest(this.type, this.uid);

  Widget generateQuestion(){
    submitted = false;
    Widget questionCard;

    Random rand = new Random();
    if (streak < 15) {
      currentQuestion = Question(type, rand.nextInt(15).toString());
    }
    else if (streak < 30) {
      currentQuestion = Question(type, rand.nextInt(63).toString());
    }
    else {
      currentQuestion = Question(type, rand.nextInt(255).toString());
    }

    questionCard = Card(child: Container(child: Column(children: <Widget>[Text("${currentQuestion.question}"),
      Divider(),
      TextField(controller: response, decoration: InputDecoration(labelText: "${currentQuestion.hint}"), keyboardType: TextInputType.number),
      Divider(),
      previousResponse == null?Text(""):Text("${previousResponse[0]}"),
      (previousResponse != null && previousResponse[0] == "Incorrect")?Text("Correct Answer: ${previousResponse[1]}"):Text(""),
      Text("Streak: $streak")
      ]),
      padding: EdgeInsets.all(16),
    ));

    display = questionCard;
  }

  void check(){
    if (currentQuestion.check(response.text.toString())) {
      previousResponse = <String>["Correct", "${currentQuestion.answer}"];
      streak += 1;
    }
    else {
      previousResponse = <String>["Incorrect", "${currentQuestion.answer}"];
    }

    response.clear();
  }
}

class TestDisplay extends StatefulWidget {
  var test;

  TestDisplay(this.test);

  @override
  _TestDisplayState createState() => _TestDisplayState(test);
}

class _TestDisplayState extends State<TestDisplay> {
  var test;

  _TestDisplayState(this.test){
    test.generateQuestion();
  }

  void check() {
    test.check();
    super.setState((){ test.generateQuestion(); });
  }

  @override
  Widget build(BuildContext context) {
    RaisedButton submit = RaisedButton(child: Text("Submit"), onPressed: check);
    return Scaffold(appBar: AppBar(title: Text("Geeky Math - Test")), body: Container(child: Column(children: <Widget>[test.display, submit])));
  }
}
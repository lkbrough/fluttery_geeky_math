import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'dart:math';
import 'package:fluttery_geeky_math/solver.dart';

class Question {
  int type;
  String question, answer;
  String hint;

  Question(this.type, this.question){
    if (type == 1) {
      answer = int.parse(question).toRadixString(2);
      hint = "Convert number above to Binary";
    }
    else if (type == 2) {
      answer = question;
      question = int.parse(question).toRadixString(2);
      hint = "Convert number above to Decimal";
    }
    else if (type == 3) {
      var random = new Random();
      if(random.nextBool()){
        answer = question;
        question = int.parse(question).toRadixString(2);
        hint = "Convert number above to Decimal";
      }
      else {
        answer = int.parse(question).toRadixString(2);
        hint = "Convert number above to Binary";
      }
    }
    print("Question: $question\tAnswer: $answer");
  }

  bool check(var response){
    print("Answer: $answer\tRepsonse: $response");
    return int.parse(response) == int.parse(answer);
  }

  Widget generateSolver(){
    var solver = Solver(int.parse(this.question));
    var widget;
    var num;
    if(hint == "Convert number above to Binary"){
      num = int.parse(this.question);
      widget = solver.solveBinary(num);
    }
    else if(hint == "Convert number above to Decimal"){
      num = int.parse(this.question);
      widget = solver.solveDecimal(num);
    }

    return widget;
  }

}

class ClassroomTest{
  var uid, cid, tid; // user id, classroom id, test id
  List<TextEditingController> textEditingControllers;
  List<int> randomQuestionTypes;

  ClassroomTest(this.uid, this.cid, this.tid);

  Widget getQuestions(){
    textEditingControllers = List(10);
    randomQuestionTypes = List(10);

    for(int i = 0; i < 10; i++) {
      textEditingControllers[i] = new TextEditingController();
      randomQuestionTypes[i] = Random().nextInt(2) + 1;
    }
    int index = -1;
    Question q;
    int type;

    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('classes').document('$cid').collection('tests').document('$tid').collection('questions').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError)
          return Text("Error: ${snapshot.error}");
        switch (snapshot.connectionState) {
          case ConnectionState.waiting: return Text("Loading...");
          default:
            return Flexible(fit: FlexFit.loose, child: ListView(
              shrinkWrap: true,
              children: snapshot.data.documents.map((DocumentSnapshot document) {
                index++;
                if(document.data['type'] == 3) {
                  type = randomQuestionTypes[index];
                }
                else {
                  type = document.data['type'];
                }
                q = Question(type, document.data['decimal'].toString());
                return Card(child: Container(padding: EdgeInsets.all(16), child: Column(children: <Widget>[
                  Text("${q.question}", style: TextStyle(fontSize: 24)),
                  Divider(),
                  TextField(controller: textEditingControllers[index], decoration: InputDecoration(labelText: "${q.hint}",), keyboardType: TextInputType.number,)
                ])));
              }).toList(),
            ));
        }
      }
    );
  }

  Future<void> grade() async{
    double grade = 100;
    var taken_list;
    var grades;
    var avg;
    Question q;
    int correct = 0;
    int count = 0;
    int type;

    Firestore.instance.collection("classes").document("$cid").collection("tests").document("$tid").collection("questions").snapshots().listen( (data) {
      data.documents.forEach( (d) {
        if(d.data['type'] == 3) {
          type = randomQuestionTypes[count];
        }
        else {
          type = d.data['type'];
        }
        q = Question(type, d.data['decimal'].toString());
        if(q.check(textEditingControllers[count].text)){
          correct++;
        }
        count++;
      });
      grade = (correct/count)*100;

      Firestore.instance.collection("classes").document("$cid").collection("tests").document("$tid").get().then((DocumentSnapshot ds) {
        taken_list = List.from(ds["taken_by"], growable: true);
        taken_list.add("$uid");
        Firestore.instance.collection("classes").document("$cid").collection("tests").document("$tid").updateData({"taken_by": taken_list});
        Firestore.instance.collection("classes").document("$cid").collection("students").document("$uid").get().then((DocumentSnapshot dsub) {
          grades = dsub["test_scores"];
          grades.addEntries([MapEntry<String, double>("${ds["name"]}", grade)]);
          avg = dsub["score_avg"];
          avg += grade;
          avg /= 2;
          Firestore.instance.collection("classes").document("$cid").collection("students").document("$uid").updateData({"test_scores": grades, "score_avg": avg});
        });
      });
    });
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
      currentQuestion = Question(type, rand.nextInt(16).toString());
    }
    else if (streak < 30) {
      currentQuestion = Question(type, rand.nextInt(64).toString());
    }
    else {
      currentQuestion = Question(type, rand.nextInt(256).toString());
    }

    questionCard = Card(child: Container(child: Column(children: <Widget>[Text("${currentQuestion.question}", style: TextStyle(fontSize: 24)),
      Divider(),
      TextField(controller: response, decoration: InputDecoration(labelText: "${currentQuestion.hint}"), keyboardType: TextInputType.number),
      Text(""),
      previousResponse == null?Text(""):Text("${previousResponse[0]}"),
      (previousResponse != null && previousResponse[0] == "Incorrect")?Text("Correct Answer: ${previousResponse[1]}"):Text(""),
      Text("Streak: $streak")
      ]),
      padding: EdgeInsets.all(16),
    ));

    display = questionCard;
  }

  Widget check(){
    Widget solver = Text("");
    if (currentQuestion.check(response.text.toString())) {
      previousResponse = <String>["Correct", "${currentQuestion.answer}"];
      streak += 1;
    }
    else {
      previousResponse = <String>["Incorrect", "${currentQuestion.answer}"];
      streak = 0;
      solver = currentQuestion.generateSolver();
    }

    response.clear();
    return solver;
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
  Widget display;
  Widget solverDialog;
  Widget solverDisplay = Text("");
  bool questionsDelivered = false;

  _TestDisplayState(this.test){
    if(test is RandomTest) {
      test.generateQuestion();
    }
    else if(test is ClassroomTest) {
      test.getQuestions();
    }
  }

  void check(var context) {
    super.setState((){
      solverDisplay = Text("");
      if(test is RandomTest) {
        solverDialog = test.check();
        test.generateQuestion();
        if(test.previousResponse[0] == "Incorrect"){
          solverDisplay = RaisedButton(child: Text("Display Previous Solution"),
              onPressed: () {
                showDialog(context: context, builder: (BuildContext context) => solverDialog);
              }
          );
        }
      }
      else if(test is ClassroomTest) {
        test.grade();
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    RaisedButton submit = RaisedButton(child: Text("Submit"), onPressed: () { check(context); } );
    if(test is RandomTest) {
      display = test.display;
    }
    else if(test is ClassroomTest && !questionsDelivered) {
      display = test.getQuestions();
      questionsDelivered = true;
    }

    return Scaffold(appBar: AppBar(title: Text("Geeky Math - Test")), body: Container(child: Column(children: <Widget>[display, submit, solverDisplay], crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.center,)));
  }
}
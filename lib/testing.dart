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
      hint = "Convert number above to binary";
    }
    else if (type == 2) {
      answer = question;
      question = int.parse(answer).toRadixString(2);
      hint = "Convert number above to Decimal";
    }
    else if (type == 3) {
      var random = new Random();
      if(random.nextInt(1) == 2){
        answer = question;
        question = int.parse(answer).toRadixString(2);
        hint = "Convert number above to Decimal";
      }
      else {
        answer = int.parse(question).toRadixString(2);
        hint = "Convert number above to binary";
      }
    }
  }

  bool check(var response){
    return response == answer;
  }

}

class ClassroomTest{
  var uid, cid, tid; // user id, classroom id, test id
  List<TextEditingController> textEditingControllers;

  ClassroomTest(this.uid, this.cid, this.tid);

  Widget getQuestions(){
    textEditingControllers = List(10);
    for(int i = 0; i < 10; i++) {
      textEditingControllers[i] = new TextEditingController();
    }
    int index = -1;
    Question q;

    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('classes').document('$cid').collection('tests').document('$tid').collection('questions').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError)
          return Text("Error: ${snapshot.error}");
        switch (snapshot.connectionState) {
          case ConnectionState.waiting: return Text("Loading...");
          default:
            return Expanded(child: ListView(
              children: snapshot.data.documents.map((DocumentSnapshot document) {
                index++;
                q = Question(document.data['type'], document.data['decimal'].toString());
                return Card(child: Container(padding: EdgeInsets.all(16), child: Column(children: <Widget>[
                  Text("${q.question}"),
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

    Firestore.instance.collection("classes").document("$cid").collection("tests").document("$tid").collection("questions").snapshots().listen( (data) {
      data.documents.forEach( (d) {
        q = Question(d.data['type'], d.data['decimal'].toString());
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
  Widget display;
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
      if(test is RandomTest) {
        test.check();
        test.generateQuestion();
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

    return Scaffold(appBar: AppBar(title: Text("Geeky Math - Test")), body: Container(child: Column(children: <Widget>[display, submit])));
  }
}
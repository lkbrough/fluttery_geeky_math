import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Classes extends StatefulWidget {
  var _auth, cid, isTeacher;
  Classes(this._auth, this.cid, this.isTeacher);

  @override
  _ClassesState createState() => _ClassesState(_auth, cid, isTeacher);
}

class _ClassesState extends State<Classes> {
  var _auth, cid, isTeacher;
  var students;
  var tests;
  var studentsDisplay;
  var testsDisplay;

  _ClassesState(this._auth, this.cid, this.isTeacher);

  void teacherCheck(var context, var document) {
    if(isTeacher) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => StudentInfo(cid, document)));
    }
      return;
  }
  
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(length: 2, child:
    Scaffold(appBar:
    AppBar(title: Text('Classroom'), bottom: TabBar(
        tabs: [
          Tab(text: "Students"),
          Tab(text: "Tests")
        ]
    )),
        body: TabBarView(
          children: [Container(child: Column(children: <Widget>[StreamBuilder<QuerySnapshot>(
            stream: Firestore.instance.collection('classes').document('$cid').collection('students').snapshots(),
            builder: (BuildContext subContext, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError)
                return Text('Error: ${snapshot.error}');
              switch (snapshot.connectionState) {
                case ConnectionState.waiting: return Text('Loading...');
                default:
                  return Expanded(child: ListView(
                    children: snapshot.data.documents.map((DocumentSnapshot document) {
                      return new ListTile(
                        title: Text(document['name']),
                        onTap: (){teacherCheck(context, document); },
                      );
                    }).toList(),
                  ));
              }
            },
          )])),
    Container(child: Column(children: <Widget>[StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('classes').document("$cid").collection('tests').snapshots(),
      builder: (BuildContext subContext, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError)
          return Text('Error: ${snapshot.error}');
        switch (snapshot.connectionState) {
          case ConnectionState.waiting: return Text('Loading...');
          default:
            return Expanded(child: ListView(
              children: snapshot.data.documents.map((DocumentSnapshot document) {
                return new ListTile(
                  title: new Text(document['name']),
                );
            }).toList(),
            ));
        }
      },
    )]))],
        )
    )
    );
  }
}


class StudentInfo extends StatelessWidget {
  var info;
  var cid;

  StudentInfo(this.cid, this.info);

  @override
  Widget build(BuildContext context){
    Text avg = Text("Test Average: ${info["score_avg"]}");

    var test_names = info["test_scores"].keys.toList();
    var test_scores = info["test_scores"].values.toList();

    ListView scores = ListView.builder(
        itemCount: info["test_scores"].entries.length,
        itemBuilder: (BuildContext ctxt, int index) {
          return ListTile(title: Text("${test_names[index]}"), subtitle: Text("${test_scores[index]}"));
        });


    return Scaffold(appBar: AppBar(title: Text("Student: ${info["name"]}")), body: Container(child: Column(children: <Widget>[avg, Divider(), Expanded(child: scores)]), padding: EdgeInsets.all(20)));
  }
}

class TestInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}

class TestCreation extends StatefulWidget {
  @override
  _TestCreationState createState() => _TestCreationState();
}

class _TestCreationState extends State<TestCreation> {
  TextEditingController _testName = TextEditingController();
  List<QuestionCreation> questions = <QuestionCreation>[QuestionCreation()];
  int numQuestions = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text("New Test")),
      body: Container(),
    );
  }
}

class QuestionCreation extends StatefulWidget {
  @override
  _QuestionCreationState createState() => _QuestionCreationState();
}

class _QuestionCreationState extends State<QuestionCreation> {
  int _type;
  int _question;

  TextEditingController _questionInput;

  void _handleRadioValueChange(int value) {
    setState( () {
      _type = value;

      _question = int.parse(_questionInput.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    Radio decimalToBinary = Radio(value: 1, groupValue: _type, onChanged: _handleRadioValueChange);
    Radio binaryToDecimal = Radio(value: 2, groupValue: _type, onChanged: _handleRadioValueChange);
    Radio random = Radio(value: 3, groupValue: _type, onChanged: _handleRadioValueChange);

    TextField question = TextField(controller: _questionInput, decoration: InputDecoration(labelText: "Question (In Decimal)"), keyboardType: TextInputType.numberWithOptions(signed: false, decimal: false),);

    return Card(child:
      Container(padding: EdgeInsets.all(15), child:
        Column(children: <Widget>[
          question,
          Row(children: <Widget>[decimalToBinary, Text("Decimal to Binary"), binaryToDecimal, Text("Binary to Decimal"), random, Text("Either (Let the test Pick)")])
        ])
      )
    );
  }
}



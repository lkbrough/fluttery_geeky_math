import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttery_geeky_math/testing.dart';

class Classes extends StatefulWidget {
  var _auth, cid, uid, isTeacher;
  Classes(this._auth, this.cid, this.uid, this.isTeacher);

  @override
  _ClassesState createState() => _ClassesState(_auth, cid, uid, isTeacher);
}

class _ClassesState extends State<Classes> {
  var _auth, cid, uid, isTeacher;
  var students;
  var tests;
  var studentsDisplay;
  var testsDisplay;

  _ClassesState(this._auth, this.cid, this.uid, this.isTeacher);

  void studentInfoTeacherCheck(var context, DocumentSnapshot document) {
    if(isTeacher) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => StudentInfo(cid, document)));
    }
  }

  void testTeacherCheck(var context, var document, var tid) {
    if(isTeacher) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => TestInfo(cid, tid, document)));
    }
    else {
      Navigator.push(context, MaterialPageRoute(builder: (context) => TestDisplay(ClassroomTest(uid, cid, tid))));
    }
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
                        onTap: (){studentInfoTeacherCheck(context, document); },
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
                  onTap: (){testTeacherCheck(context, document, document.documentID); },
                );
            }).toList(),
            ));
        }
      },
    ), Container(child: Align(alignment: Alignment.bottomRight, child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: <Widget>[FloatingActionButton(child: Icon(Icons.add), onPressed: (() {Navigator.push(context, MaterialPageRoute(builder: (context) => TestCreation(cid)));}))])), padding: EdgeInsets.all(17)),
    ]))],
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
  DocumentSnapshot testInfo;
  var cid;
  var tid;

  TestInfo(this.cid, this.tid, this.testInfo);

  @override
  Widget build(BuildContext context) {

    return Scaffold(appBar: AppBar(title: Text("Test ${testInfo["name"]}")), body: Container(child: Column(children: <Widget>[StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('classes').document('$cid').collection('tests').document('$tid').collection('questions').snapshots(),
      builder: (BuildContext subContext, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError)
          return Text('Error: ${snapshot.error}');
        switch (snapshot.connectionState) {
          case ConnectionState.waiting: return Text('Loading...');
          default:
            return Expanded(child: ListView(padding: EdgeInsets.all(20),
              children: snapshot.data.documents.map((DocumentSnapshot document) {
                return Card(child: Container(padding: EdgeInsets.all(20), child: Column(children: <Widget>[Text("Decimal Number: ${document["decimal"]}"), Text("Binary Number: ${document["binary"]}"), Text("Type: ${document["type"] == 1?"Decimal to Binary":document["type"] == 2?"Binary to Decimal":"Random"}")],))
                );}).toList(),
            ));
        }
      })]
    )));
  }
}

class TestCreation extends StatefulWidget {
  var cid;

  TestCreation(this.cid);

  @override
  _TestCreationState createState() => _TestCreationState(cid);
}

class _TestCreationState extends State<TestCreation> {
  var cid;
  TextEditingController _testName = TextEditingController();
  List<QuestionCreation> questions = <QuestionCreation>[QuestionCreation()];

  _TestCreationState(this.cid);
  
  void newQuestion() {
    super.setState((){
      questions.add(QuestionCreation());
    });

  }

  void submit(var context) {
    DocumentReference newDocument = Firestore.instance.collection('classes').document('$cid').collection('tests').document();

    int decimalNumber;
    int binaryNumber;
    for(QuestionCreation i in questions) {
      decimalNumber = int.parse("${i._questionInput.text}");
      binaryNumber = int.parse(decimalNumber.toRadixString(2));
      newDocument.collection('questions').document().setData({"type": i._type, "decimal": decimalNumber, "binary": binaryNumber});
    }

    newDocument.setData({"avaliable" : true, "name" : _testName.text, "reveal_all" : true, "taken_by": [] });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text("New Test")),
      body: Container(child: Column(children: <Widget>[Container(child: TextField(controller: _testName, decoration: InputDecoration(labelText: "Test Name"),), padding: EdgeInsets.all(20)),
        Expanded(child: ListView.builder(itemCount: questions.length, itemBuilder: (BuildContext buildContext, int index) {
          return questions[index];
        },)),
        RaisedButton(onPressed: (){ submit(context); }, child: Text("Submit")),
      ])),
      floatingActionButton: FloatingActionButton(onPressed: newQuestion, child: Icon(Icons.add)),
    );
  }
}

class QuestionCreation extends StatefulWidget {
  var _type;
  TextEditingController _questionInput = TextEditingController();

  @override
  _QuestionCreationState createState() => _QuestionCreationState();
}

class _QuestionCreationState extends State<QuestionCreation> {
  void _handleRadioValueChange(var value) {
    setState( () {
      widget._type = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    Radio decimalToBinary = Radio(value: 1, groupValue: widget._type, onChanged: _handleRadioValueChange);
    Radio binaryToDecimal = Radio(value: 2, groupValue: widget._type, onChanged: _handleRadioValueChange);
    Radio random = Radio(value: 3, groupValue: widget._type, onChanged: _handleRadioValueChange);

    TextField question = TextField(controller: widget._questionInput, decoration: InputDecoration(labelText: "Question (In Decimal)"), keyboardType: TextInputType.numberWithOptions(signed: false, decimal: false),);

    return Card(child:
      Container(padding: EdgeInsets.all(15), child:
        Column(children: <Widget>[
          question,
          Row(children: <Widget>[decimalToBinary, Text("Decimal to Binary"), binaryToDecimal, Text("Binary to Decimal"), random, Text("Either")])
        ])
      )
    );
  }
}



import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Classes extends StatefulWidget {
  var _auth, cid, user;
  Classes(this._auth, this.cid, this.user);

  @override
  _ClassesState createState() => _ClassesState(_auth, cid, user);
}

class _ClassesState extends State<Classes> {
  var _auth, cid, user;
  var students;
  var tests;
  var studentsDisplay;
  var testsDisplay;

  _ClassesState(this._auth, this.cid, this.user);

  Future<void> getStudents(var masterContext) async{
    studentsDisplay = <Widget>[];
    print("here");

    StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collection('classes').document("$cid").collection("students").snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
          if (snapshot.hasError) {
            studentsDisplay.append(Card(child: Text("Error, please try again later")));
            print("error");
            return;
          }
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              studentsDisplay.append(Card(child: Text("Loading...")));
              print("loading");
              return;
            default:
              students = snapshot.data.documents;
              print("generating");
              studentsDisplay = List<Widget>.generate(snapshot.data.documents.length, (int index) {
                return ListTile(
                  title: Text("${students[index]["name"]}"),
                  onTap: user["teacher"]?Navigator.push(masterContext, MaterialPageRoute(builder: (masterContext) => StudentInfo(cid, students[index]))):(){},
                );
              });
          }
        }
    );
    print("finished");
  }

  Future<void> getTests(var masterContext) async{
    testsDisplay = <Widget>[];

    StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collection('classes').document("$cid").collection("tests").snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
          if (snapshot.hasError) {
            testsDisplay.append(Card(child: Text("Error, please try again later")));
            return;
          }
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              testsDisplay.append(Card(child: Text("Loading...")));
              return;
            default:
              tests = snapshot.data.documents;
              testsDisplay = List<Widget>.generate(snapshot.data.documents.length, (int index) {
                return ListTile(
                  title: Text("${tests[index]["name"]}"),
                  // onTap: user["teacher"]?Navigator.push(masterContext, MaterialPageRoute(builder: (masterContext) => TestInfo(cid, tests[index]))):(){},
                );
              });
          }
        }
    );
  }
  
  @override
  Widget build(BuildContext context) {
    getStudents(context);
    getTests(context);
    return DefaultTabController(length: 2, child:
    Scaffold(appBar:
    AppBar(title: Text('Classroom'), bottom: TabBar(
        tabs: [
          Tab(text: "Students"),
          Tab(text: "Tests")
        ]
    )),
        body: TabBarView(
          children: [Container(child: Column(children: studentsDisplay)), Container(child: Column(children: testsDisplay))],
        )
    )
    );
  }
}


class StudentInfo extends StatelessWidget {
  var info;
  var cid;

  StudentInfo(this.cid, this.info);

  Stream<QuerySnapshot> getTestsTakenByStudent() {
    return Firestore.instance.collection("classes").document("$cid").collection("tests").where("taken_by", arrayContains: "${info["id"]}").snapshots();
  }

  @override
  Widget build(BuildContext context){
    Text avg = Text("Test Average: ${info["score_avg"]}");

    var testNames;
    testNames = <Widget>[];

    StreamBuilder<QuerySnapshot>(
        stream: getTestsTakenByStudent(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData)
            return Text("");
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              testNames.append(Card(child: Text("Loading...")));
              return null;
            default:
              testNames = List<Widget>.generate(snapshot.data.documents.length, (int index) {
                return Text("${testNames[index]["name"]}");
              });
          }
        }
    );

    ListView scores = ListView.builder(
        itemCount: info["test scores"].length,
        itemBuilder: (BuildContext ctxt, int index) {

          return ListTile(title: Text("${testNames[index]}"), subtitle: Text("${info["test scores"][index]}"));
        });


    return Scaffold(appBar: AppBar(title: Text("Student: ${info["name"]}")), body: Container(child: Column(children: <Widget>[avg, Divider(), scores])));
  }
}

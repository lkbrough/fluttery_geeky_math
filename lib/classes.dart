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
                        // onTap: isTeacher?Navigator.push(context, MaterialPageRoute(builder: (context) => StudentInfo(cid, document))):(){},
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

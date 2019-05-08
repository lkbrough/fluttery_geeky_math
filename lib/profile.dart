import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile extends StatelessWidget {
  var _auth;
  var uid;

  UserProfile(this._auth, this.uid);

  void addSelfToClass(String cid, var context) {
    Firestore.instance.collection('users').document('$uid').get().then((document) {
      Firestore.instance.collection('classes').document('$cid').snapshots().listen((classDocument) {
        if(classDocument.data != null) {
          Firestore.instance.collection('users').document("$uid").updateData({"teacher_id": classDocument["teacher_id"], "class_id": classDocument["id"]});
          Firestore.instance.collection('classes').document('$cid').collection('students').document(document.data["user_id"]).setData({
            "id": document.data["user_id"],
            "name": document.data["first_name"] + " " + document.data["last_name"],
            "test_scores": {},
            "score_avg": 0.0
          });
          Navigator.pop(context);
        }
        else {
          showDialog(context: context, builder: (BuildContext c) => AlertDialog(title: Text("Class not found")));
        }
      });
    });

  }

  void addClass(var context) {
    TextEditingController _classID = TextEditingController();
    SimpleDialog classDialog = SimpleDialog(title: Text("Join Class"), titlePadding: EdgeInsets.all(16), children: <Widget>[TextField(controller: _classID, decoration: InputDecoration(labelText: "Class Code", border: OutlineInputBorder()),), SimpleDialogOption(child: Text("Join Class"), onPressed: () { addSelfToClass(_classID.text, context); Navigator.pop(context); },)], contentPadding: EdgeInsets.all(15), );
    showDialog(context: context, builder: (BuildContext c) => classDialog);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text("Profile")), body: Container(child: Column(children: <Widget>[StreamBuilder<DocumentSnapshot>(
      stream: Firestore.instance.collection('users').document('$uid').snapshots(),
      builder: (BuildContext subContext, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError)
          return Text('Error: ${snapshot.error}');
        switch (snapshot.connectionState) {
          case ConnectionState.waiting: return Text('Loading...');
          default:
            return Expanded(child: ListView(children: <Widget>[
              ListTile(title: Text("${snapshot.data['first_name']} ${snapshot.data['last_name']}")),
              Divider(),
              ListTile(title: Text("${snapshot.data['class_id']}"), onTap: () { if(!snapshot.data['teacher']) { addClass(context); } } ,),
              Divider(),
            ],));
        }
      },
    )],)));
  }
}


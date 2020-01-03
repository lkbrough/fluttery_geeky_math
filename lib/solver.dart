import 'package:flutter/material.dart';
import 'dart:math';

class Solver {
  int question;
  var answer;

  Solver(this.question) {
    answer = 0;
  }

  SimpleDialog solveBinary(int question) {
    this.question = question;
    this.answer = question.toRadixString(2);
    SimpleDialog simpleDialog;
    ExpansionPanelList list = ExpansionPanelList.radio(
        children: [
          ExpansionPanelRadio(
              value: "Remainder",
              headerBuilder: (BuildContext context, bool isExpanded) {
                return ListTile(title: Text("Remainder Method"));
              },
            body: Container(child: ListView(children: solveBinaryReminder()), height: 500.0, width: 500.0),
          ),
          ExpansionPanelRadio(
              value: "Subtration",
              headerBuilder: (BuildContext context, bool isExpanded) {
                return ListTile(title: Text("Subtraction Method"));
              },
              body: Container(child: ListView(children: solveBinarySubtraction()), height: 500.0, width: 500.0),
          ),
        ]
    );
    ListView listView = ListView(children: <Widget>[list],);
    simpleDialog = SimpleDialog(children: <Widget>[Container(child: listView, height: 750.0, width: 500.0,)],);
    return simpleDialog;
  }

  SimpleDialog solveDecimal(int question) {
    this.question = question;
    this.answer = int.parse(question.toString(), radix: 2);
    SimpleDialog simpleDialog;
    ExpansionPanelList list = ExpansionPanelList.radio(
        children: [
          ExpansionPanelRadio(
              value: "Multiplcation",
              headerBuilder: (BuildContext context, bool isExpanded) {
                return ListTile(title: Text("Multiplication Method"));
              },
            body: Container(child: ListView(children: solveDecimalMultiplication()), height: 400.0, width: 500.0),
          ),
          ExpansionPanelRadio(
              value: "Number Line",
              headerBuilder: (BuildContext context, bool isExpanded) {
                return ListTile(title: Text("Number Line Method"));
              },
            body: Container(child: ListView(children: solveDecimalNumberLine()), height: 400.0, width: 500.0),
          ),
        ]
    );
    ListView listView = ListView(children: <Widget>[list],);
    simpleDialog = SimpleDialog(children: <Widget>[Container(child: listView, height: 750.0, width: 500.0,)],);
    return simpleDialog;
  }

  List<Widget> solveBinaryReminder() {
    var current = question;
    List<Widget> lists = [ListTile(title: Text("Question"), subtitle: Text("$question"))];

    while(current > 0) {
       lists.add(ListTile(
        title: Text("Division and Remainder"),
        subtitle: Text("$current / 2 = ${(current/2).floor()} R: ${current%2}"),
      ));
      current = (current / 2).floor();
    }

    lists.add(ListTile(title: Text("Answer"), subtitle: Text(answer.toString())));
    return lists;
  }

  List<Widget> solveBinarySubtraction() {
    List<Widget> lists = [ListTile(title: Text("Question"), subtitle: Text("$question"))];
    int current = question;
    int currentPower = answer.toString().length - 1;

    lists.add(ListTile(
      title: Text("Highest Power"),
      subtitle: Text("The highest power of two less than the question is ${pow(2, answer.toString().length - 1)}")
    ));

    while(current > 0) {
      if (current >= pow(2, currentPower)) {
        lists.add(ListTile(
          title: Text("Subtraction - 1"),
          subtitle: Text("$current - ${pow(2, currentPower)} = ${current - pow(2, currentPower)}"),
        ));
        current = current - pow(2, currentPower);
      }
      else {
        lists.add(ListTile(
          title: Text("Subtraction not necessary - 0"),
          subtitle: Text("Place value is bigger. Enter a 0."),)
        );
      }
      currentPower--;
    }

    lists.add(ListTile(
        title: Text("Fill in Remaining"),
        subtitle: Text("Fill in remaining powers until power of zero.")
    ));

    lists.add(ListTile(title: Text("Answer"), subtitle: Text(answer.toString())));
    return lists;
  }

  List<Widget> solveDecimalMultiplication() {
    List<Widget> lists = [ListTile(title: Text("Question"), subtitle: Text(question.toString()))];
    int current = 0;
    var questionString = question.toString();

    for(int i = 0; i < questionString.length; i++) {
      lists.add(ListTile(
        title: Text("Multiply by 2 and add current position."),
        subtitle: Text("$current * 2 + ${questionString[i]} = ${(current * 2) + int.parse(questionString[i])}"),
      ));
      current = (current * 2) + int.parse(questionString[i]);
    }

    lists.add(ListTile(title: Text("Answer"), subtitle: Text(answer.toString())));
    return lists;
  }

  List<Widget> solveDecimalNumberLine() {
    List<Widget> lists = [ListTile(title: Text("Question"), subtitle: Text(question.toString()))];
    int current = 0;
    var questionString = question.toString();
    int currentPower = questionString.length - 1;

    for(int i = 0; i < questionString.length; i++) {
      lists.add(ListTile(
        title: Text("Multiply by place value"),
        subtitle: Text("$current + (${questionString[i]} * ${pow(2, currentPower)}) = ${int.parse(questionString[i]) * pow(2, currentPower)}")
      ));
      current += int.parse(questionString[i]) * pow(2, currentPower);
      currentPower--;
    }

    lists.add(ListTile(title: Text("Answer"), subtitle: Text(answer.toString())));
    return lists;
  }
}
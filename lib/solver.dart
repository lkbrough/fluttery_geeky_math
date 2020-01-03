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
              body: Stepper(steps: solveBinaryReminder())
          ),
          ExpansionPanelRadio(
              value: "Subtration",
              headerBuilder: (BuildContext context, bool isExpanded) {
                return ListTile(title: Text("Subtraction Method"));
              },
              body: Stepper(steps: solveBinarySubtraction())
          ),
        ]
    );
    ListView listView = ListView(children: <Widget>[list],);
    simpleDialog = SimpleDialog(children: <Widget>[Container(child: listView, height: 500.0, width: 500.0,)],);
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
              body: Stepper(steps: solveDecimalMultiplication())
          ),
          ExpansionPanelRadio(
              value: "Number Line",
              headerBuilder: (BuildContext context, bool isExpanded) {
                return ListTile(title: Text("Number Line Method"));
              },
              body: Stepper(steps: solveDecimalNumberLine())
          ),
        ]
    );
    ListView listView = ListView(children: <Widget>[list],);
    simpleDialog = SimpleDialog(children: <Widget>[Container(child: listView, height: 750.0, width: 500.0,)],);
    return simpleDialog;
  }

  List<Step> solveBinaryReminder() {
    var current = question;
    List<Step> lists = [Step(title: Text("Question"), content: Text("$question"))];

    while(current > 0) {
       lists.add(Step(
        title: Text("Division and Remainder"),
        content: Text("$current / 2 = ${(current/2).floor()} R: ${current%2}"),
      ));
      current = (current / 2).floor();
    }

    lists.add(Step(title: Text("Answer"), content: Text(answer.toString())));
    return lists;
  }

  List<Step> solveBinarySubtraction() {
    List<Step> lists = [Step(title: Text("Question"), content: Text("$question"))];
    int current = question;
    int currentPower = answer.toString().length - 1;

    lists.add(Step(
      title: Text("Highest Power"),
      content: Text("The highest power of two less than the question is ${pow(2, answer.toString().length - 1)}")
    ));

    while(current > 0) {
      if (current > pow(2, currentPower)) {
        lists.add(Step(
          title: Text("Subtraction - 1"),
          content: Text("$current - ${pow(2, currentPower)} = ${current - pow(2, currentPower)}"),
        ));
        current = current - pow(2, currentPower);
      }
      else {
        lists.add(Step(
          title: Text("Subtraction not necessary - 0"),
          content: Text("Place value is bigger. Enter a 0."),)
        );
      }
      currentPower++;
    }

    lists.add(Step(title: Text("Answer"), content: Text(answer.toString())));
    return lists;
  }

  List<Step> solveDecimalMultiplication() {
    List<Step> lists = [Step(title: Text("Question"), content: Text(question.toString()))];
    int current = 0;
    var questionString = question.toString();

    for(int i = 0; i < questionString.length; i++) {
      lists.add(Step(
        title: Text("Multiply by 2 and add current position."),
        content: Text("$current * 2 + ${questionString[i]} = ${(current * 2) + int.parse(questionString[i])}"),
      ));
      current = (current * 2) + int.parse(questionString[i]);
    }

    lists.add(Step(title: Text("Answer"), content: Text(answer.toString())));
    return lists;
  }

  List<Step> solveDecimalNumberLine() {
    List<Step> lists = [Step(title: Text("Question"), content: Text(question.toString()))];
    int current = 0;
    var questionString = question.toString();
    int currentPower = questionString.length - 1;

    for(int i = 0; i < questionString.length; i++) {
      lists.add(Step(
        title: Text("Multiply by place value"),
        content: Text("$current + (${questionString[i]} * ${pow(2, currentPower)}) = ${int.parse(questionString[i]) * pow(2, currentPower)}")
      ));
      current += int.parse(questionString[i]) * pow(2, currentPower);
      currentPower--;
    }

    lists.add(Step(title: Text("Answer"), content: Text(answer.toString())));
    return lists;
  }
}
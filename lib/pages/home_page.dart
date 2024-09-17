import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../components/dialog_box.dart';
import '../components/todo_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  final _controller = TextEditingController();
  late SharedPreferences prefs;

  List toDoList = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async{
    prefs = await SharedPreferences.getInstance();
    final jsonData = prefs.getString("tasks");

    if(jsonData == null){
      setDefaultData();
      return;
    }

    try {
      List list = jsonDecode(jsonData);
      setState(() {
        toDoList = list;
      });
    } on Exception catch (e) {
      print(e);
      setDefaultData();
    }
  }

  void setDefaultData() {
    setState(() {
      toDoList = [
        ["Michał Makarczuk", false],
        ["ZPSB", false]
      ];
    });
    saveData();
  }

  void saveData() async{
    await prefs.setString('tasks', jsonEncode(toDoList));
  }

  void checkBoxChanged(bool? value, int index) {
    setState(() {
      toDoList[index][1] = !toDoList[index][1];
    });
    saveData();
  }

  void saveNewTask(){
    if(_controller.text.isEmpty){
      return;
    }

    setState(() {
      toDoList.add([
        _controller.text,
        false
      ]);
    });
    Navigator.of(context).pop();
    saveData();
  }

  void createNewTask() {
    _controller.clear();
    showDialog(
        context: context,
        builder: (context) {
          return DialogBox(
              controller: _controller,
            onSave: saveNewTask,
            onCancel: () => Navigator.of(context).pop(),
          );
        }
    );
  }

  void deleteTask(int index){
    setState(() {
      toDoList.removeAt(index);
    });
    saveData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          title: const Text("To Do"),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: createNewTask,
          child: const Icon(Icons.add),
        ),
        body: ListView.builder(
          itemCount: toDoList.length,
          itemBuilder: (context, index) {
            return ToDoTile(
              taskName: toDoList[index][0],
              taskCompleted: toDoList[index][1],
              onChanged: (value) => checkBoxChanged(value, index),
              deleteFunction: (context) => deleteTask(index),
            );
          },
        )
    );
  }
}

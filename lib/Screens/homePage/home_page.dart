import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:todo_app/data/database.dart';
import 'package:todo_app/utils/dialog_box.dart';
import 'package:todo_app/utils/todo_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _myBox = Hive.box('mybox');
  ToDoDataBase db = ToDoDataBase();

  @override
  void initState() {
    if (_myBox.get("TODOLIST") == null) {
      db.createInitialData();
    } else {
      db.loadData();
    }
    _sortToDoList();
    super.initState();
  }

  final _controller = TextEditingController();

  void _sortToDoList() {
    db.toDoList.sort((a, b) {
      if (a[1] == b[1]) {
        return a[0].toLowerCase().compareTo(b[0].toLowerCase());
      } else {
        return a[1] ? 1 : -1;
      }
    });
  }

  void checkBoxChanged(bool? value, int index) {
    setState(() {
      db.toDoList[index][1] = !db.toDoList[index][1];
      _sortToDoList();
    });
    db.updateDataBase();
  }

  void saveNewTask() {
    setState(() {
      db.toDoList.add([_controller.text, false]);
      _controller.clear();
      _sortToDoList();
    });
    Navigator.of(context).pop();
    db.updateDataBase();
  }

  void createNewTask() {
    showDialog(
      context: context,
      builder: (context) {
        return DialogBox(
          controller: _controller,
          onSave: saveNewTask,
          onCancel: () => Navigator.of(context).pop(),
        );
      },
    );
  }

  void deleteTask(int index) {
    setState(() {
      db.toDoList.removeAt(index);
      _sortToDoList(); // Sort the list after deleting a task
    });
    db.updateDataBase();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFE8F4FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A90E2),
        title: const Text(
          'To Do APP',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        elevation: 0,
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: createNewTask,
        backgroundColor: const Color(0xFF56CCF2),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
        child: ListView.builder(
          itemCount: db.toDoList.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.05,
              ),
              child: Card(
                margin: EdgeInsets.symmetric(
                    vertical: screenWidth * 0.03), // Adjusted vertical margin
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(screenWidth * 0.05), // Adjusted border radius
                ),
                elevation: 8, // Increased elevation
                shadowColor: Colors.black
                    .withOpacity(0.2), // Slightly increased shadow opacity
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(screenWidth * 0.05), // Adjusted border radius
                    gradient: const LinearGradient(
                      colors: [Color(0xFF56CCF2), Color(0xFF4A90E2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  padding: EdgeInsets.symmetric(
                      vertical: screenWidth * 0.04, horizontal: screenWidth * 0.05), // Adjusted padding
                  child: Row(
                    children: [
                      // Checkbox for task completion
                      Checkbox(
                        value: db.toDoList[index][1],
                        onChanged: (value) => checkBoxChanged(value, index),
                        activeColor: Colors.white,
                        checkColor: Colors.blue[700],
                      ),
                      SizedBox(width: screenWidth * 0.02),

                      // Task details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              db.toDoList[index][0],
                              style: TextStyle(
                                fontSize: screenWidth * 0.045,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            SizedBox(height: screenWidth * 0.01),
                            Text(
                              db.toDoList[index][1] ? "Completed" : "Pending",
                              style: TextStyle(
                                fontSize: screenWidth * 0.035,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Delete button with icon
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.white, size: screenWidth * 0.06),
                        onPressed: () => deleteTask(index),
                        tooltip: 'Delete task',
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
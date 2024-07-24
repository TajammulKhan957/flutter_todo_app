import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/splash.dart';
import 'database_helper.dart';
import 'add_task_screen.dart';

void main() {
  runApp(TodoApp());
}

class TodoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'To-Do Application',
      theme: ThemeData(
        // primarySwatch: Colors.orange,
        appBarTheme: const AppBarTheme(
          color: Colors.blue,
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: Splash(),
    );
  }
}

class TodoListScreen extends StatefulWidget {
  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  List<Map<String, dynamic>> _tasks = [];

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  void _fetchTasks() async {
    final tasks = await DatabaseHelper().getTasks();
    setState(() {
      _tasks = tasks;
    });
  }

  void _addTask(String title, String description, String date, String time) async {
    await DatabaseHelper().insertTask(title, description, date, time);
    _fetchTasks();
  }

  void _updateTask(int id, String title, String description, String date, String time) async {
    await DatabaseHelper().updateTask(id, title, description, date, time);
    _fetchTasks();
  }

  void _deleteTask(int id) async {
    await DatabaseHelper().deleteTask(id);
    _fetchTasks();
  }

  TimeOfDay _parseTime(String time) {
    final format = DateFormat.jm(); //"6:00 AM"
    final DateTime timeDate = format.parse(time);
    return TimeOfDay(hour: timeDate.hour, minute: timeDate.minute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('To-Do Application'),
      ),
      body: _tasks.isEmpty
          ? Center(child: Text('No tasks yet!'))
          : ListView.builder(
        itemCount: _tasks.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: ListTile(
                title: Text(_tasks[index]['title']),
                subtitle: Text("Description: ${_tasks[index]['description']}\nDate: ${_tasks[index]['date']}, Time: ${_tasks[index]['time']}"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddTaskScreen(
                              task: _tasks[index],
                            ),
                          ),
                        );
                        if (result != null) {
                          _updateTask(_tasks[index]['id'], result['title'], result['description'], result['date'], result['time']);
                        }
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        _deleteTask(_tasks[index]['id']);
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddTaskScreen()),
          );
          if (result != null) {
            _addTask(result['title'], result['description'], result['date'], result['time']);
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

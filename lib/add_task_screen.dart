import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddTaskScreen extends StatefulWidget {
  final Map<String, dynamic>? task;

  AddTaskScreen({this.task});

  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _taskTitle;
  late String _description;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _taskTitle = widget.task!['title'];
      _description = widget.task!['description'];
      _selectedDate = DateFormat.yMd().parse(widget.task!['date']);
      _selectedTime = _parseTime(widget.task!['time']);
    } else {
      _taskTitle = '';
      _description = '';
      _selectedDate = DateTime.now();
      _selectedTime = TimeOfDay.now();
    }
  }

  TimeOfDay _parseTime(String time) {
    final format = DateFormat.jm(); //"6:00 AM"
    final DateTime timeDate = format.parse(time);
    return TimeOfDay(hour: timeDate.hour, minute: timeDate.minute);
  }

  _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  _pickTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (pickedTime != null && pickedTime != _selectedTime) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task != null ? 'Edit Task' : 'Add Task'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                initialValue: _taskTitle,
                decoration: InputDecoration(labelText: 'Task Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a task title';
                  }
                  return null;
                },
                onSaved: (value) {
                  _taskTitle = value!;
                },
              ),
              TextFormField(
                initialValue: _description,
                decoration: InputDecoration(labelText: 'Task Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a task description';
                  }
                  return null;
                },
                onSaved: (value) {
                  _description = value!;
                },
              ),
              SizedBox(height: 16.0),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      "Date: ${DateFormat.yMd().format(_selectedDate)}",
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _pickDate,
                    child: Text('Pick Date'),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      "Time: ${_selectedTime.format(context)}",
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _pickTime,
                    child: Text('Pick Time'),
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    String formattedDate = DateFormat.yMd().format(_selectedDate);
                    String formattedTime = _selectedTime.format(context);
                    Navigator.pop(context, {
                      'title': _taskTitle,
                      'description': _description,
                      'date': formattedDate,
                      'time': formattedTime,
                    });
                  }
                },
                child: Text(widget.task != null ? 'Update Task' : 'Save Task'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

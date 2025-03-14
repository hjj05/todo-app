import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'To-Do App',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: const GetStartedScreen(),
    );
  }
}

class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("lib/assets/background.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Plan.\nOrganize.\nAchieve",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TodoScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32), // Increases button size
                  textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold), // Increases text size
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Optional: Rounds button corners
                  ),
                ),
                child: const Text("Get Started"),
              ),

              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TaskCard extends StatelessWidget {
  final String time;
  final String title;
  final String desc;
  final bool isDone;
  final ValueChanged<bool?> onChanged;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TaskCard({
    super.key,
    required this.time,
    required this.title,
    required this.desc,
    required this.isDone,
    required this.onChanged,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Checkbox(
          value: isDone,
          onChanged: onChanged,
        ),
        title: Text(
          title,
          style: TextStyle(
            decoration: isDone ? TextDecoration.lineThrough : TextDecoration.none,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(desc),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.edit), onPressed: onEdit),
            IconButton(icon: const Icon(Icons.delete),color:Colors.red, onPressed: onDelete),
          ],
        ),
      ),
    );
  }
}

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  _TodoScreenState createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  DateTime selectedDate = DateTime.now();
  final Map<DateTime, List<Map<String, dynamic>>> taskData = {};
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final String userName = "Hiral";

  List<Map<String, dynamic>> get tasks => taskData[selectedDate] ?? [];

  void _addTask() {
    if (_taskController.text.isNotEmpty) {
      setState(() {
        taskData[selectedDate] = [
          ...tasks,
          {'time': 'Time', 'title': _taskController.text, 'desc': _descController.text, 'done': false}
        ];
        _taskController.clear();
        _descController.clear();
      });
    }
    Navigator.pop(context);
  }

  void _editTask(int index) {
    _taskController.text = tasks[index]['title'];
    _descController.text = tasks[index]['desc'];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _buildTaskForm(() {
        setState(() {
          taskData[selectedDate]?[index]['title'] = _taskController.text;
          taskData[selectedDate]?[index]['desc'] = _descController.text;
        });
        Navigator.pop(context);
      }),
    );
  }

  void _deleteTask(int index) {
    setState(() {
      taskData[selectedDate]?.removeAt(index);
    });
  }

  void _resetTasks() {
    setState(() {
      taskData[selectedDate] = [];
    });
  }

  Widget _buildTaskForm(VoidCallback onSave) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: _taskController, decoration: const InputDecoration(labelText: 'Task Title')),
          TextField(controller: _descController, decoration: const InputDecoration(labelText: 'Description')),
          ElevatedButton(onPressed: onSave, child: const Text('Save Task'))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("lib/assets/background.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: Text("Hello, $userName"),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2022),
                        lastDate: DateTime(2030),
                      );
                      if (pickedDate != null && pickedDate != selectedDate) {
                        setState(() {
                          selectedDate = pickedDate;
                        });
                      }
                    },
                  ),
                  IconButton(icon: const Icon(Icons.refresh), onPressed: _resetTasks),
                ],
              ),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text("My Tasks", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    return TaskCard(
                      time: tasks[index]['time'],
                      title: tasks[index]['title'],
                      desc: tasks[index]['desc'],
                      isDone: tasks[index]['done'],
                      onChanged: (value) {
                        setState(() {
                          taskData[selectedDate]?[index]['done'] = value;
                        });
                      },
                      onEdit: () => _editTask(index),
                      onDelete: () => _deleteTask(index),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (_) => _buildTaskForm(_addTask),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}

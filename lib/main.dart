import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  await Hive.initFlutter();
  await Hive.openBox('tasks');
  runApp(const NotesApp());
}

class NotesApp extends StatelessWidget {
  const NotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      title: 'Заметки',
      theme: CupertinoThemeData(
        brightness: Brightness.light,
        primaryColor: CupertinoColors.activeOrange,
      ),
      home: NotesHomePage(),
    );
  }
}

class NotesHomePage extends StatefulWidget {
  const NotesHomePage({super.key});

  @override
  _NotesHomePageState createState() => _NotesHomePageState();
}

class _NotesHomePageState extends State<NotesHomePage> {
  final List<Widget> _tabs = [
    const TodayTasksTab(),
    const AllTasksTab(),
    const ArchiveTasksTab(),
  ];
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.calendar_today),
            label: 'Ближайшие',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.list_bullet),
            label: 'Все задачи',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.archivebox),
            label: 'Архив',
          ),
        ],
      ),
      tabBuilder: (context, index) {
        return CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            middle: Text([
              _tabs[index] is TodayTasksTab
                  ? _getCurrentDayLabel()
                  : ['Ближайшие', 'Все задачи', 'Архив'][index]
            ][0]),
          ),
          child: Stack(
            children: [
              _tabs[index],
              if (index == 0)
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: CupertinoButton(
                    child: const Icon(CupertinoIcons.add, size: 32),
                    color: CupertinoColors.activeOrange,
                    onPressed: () => _showAddTaskDialog(context),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  String _getCurrentDayLabel() {
    final today = DateTime.now();
    final currentTab = (_tabs[_currentIndex] as TodayTasksTab)._currentDate;

    if (currentTab.year == today.year &&
        currentTab.month == today.month &&
        currentTab.day == today.day) {
      return 'Сегодня';
    } else if (currentTab.isBefore(today)) {
      return 'Вчера';
    } else {
      return 'Завтра';
    }
  }

  void _showAddTaskDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) {
        TextEditingController controller = TextEditingController();
        return CupertinoAlertDialog(
          title: const Text('Новая задача'),
          content: CupertinoTextField(
            controller: controller,
            placeholder: 'Введите текст задачи',
          ),
          actions: [
            CupertinoDialogAction(
              child: const Text('Отмена'),
              onPressed: () => Navigator.pop(context),
            ),
            CupertinoDialogAction(
              child: const Text('Добавить'),
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  Hive.box('tasks').add({
                    'title': controller.text,
                    'date': DateTime.now().toIso8601String(),
                    'completed': false,
                    'archived': false,
                  });
                  Navigator.pop(context);
                  setState(() {});
                }
              },
            ),
          ],
        );
      },
    );
  }
}

class TodayTasksTab extends StatefulWidget {
  const TodayTasksTab({super.key});

  DateTime get _currentDate => DateTime.now();

  @override
  _TodayTasksTabState createState() => _TodayTasksTabState();
}

class _TodayTasksTabState extends State<TodayTasksTab> {
  DateTime _currentDate = DateTime.now();

  void _swipeLeft() {
    setState(() {
      _currentDate = _currentDate.add(const Duration(days: 1));
    });
  }

  void _swipeRight() {
    setState(() {
      _currentDate = _currentDate.subtract(const Duration(days: 1));
    });
  }

  @override
  Widget build(BuildContext context) {
    final tasksBox = Hive.box('tasks');
    final tasks = tasksBox.values.where((task) {
      final taskDate = DateTime.parse(task['date']);
      return taskDate.year == _currentDate.year &&
          taskDate.month == _currentDate.month &&
          taskDate.day == _currentDate.day;
    }).toList();

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! < 0) {
          _swipeLeft();
        } else if (details.primaryVelocity! > 0) {
          _swipeRight();
        }
      },
      child: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return TaskItem(
            title: task['title'],
            completed: task['completed'],
            onChanged: (value) {
              tasksBox.putAt(index, {
                'title': task['title'],
                'date': task['date'],
                'completed': value,
              });
              setState(() {});
            },
          );
        },
      ),
    );
  }
}

class AllTasksTab extends StatelessWidget {
  const AllTasksTab({super.key});

  @override
  Widget build(BuildContext context) {
    final tasksBox = Hive.box('tasks');
    final tasks = tasksBox.values.toList();

    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return TaskItem(
          title: task['title'],
          completed: task['completed'],
          onChanged: (value) {
            tasksBox.putAt(index, {
              'title': task['title'],
              'date': task['date'],
              'completed': value,
            });
          },
        );
      },
    );
  }
}

class ArchiveTasksTab extends StatelessWidget {
  const ArchiveTasksTab({super.key});

  @override
  Widget build(BuildContext context) {
    final tasksBox = Hive.box('tasks');
    final archivedTasks =
        tasksBox.values.where((task) => task['archived']).toList();

    return ListView.builder(
      itemCount: archivedTasks.length,
      itemBuilder: (context, index) {
        final task = archivedTasks[index];
        return TaskItem(
          title: task['title'],
          completed: true,
          onChanged: null,
        );
      },
    );
  }
}

class TaskItem extends StatelessWidget {
  final String title;
  final bool completed;
  final ValueChanged<bool>? onChanged;

  const TaskItem({
    super.key,
    required this.title,
    required this.completed,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: CupertinoColors.separator, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          CupertinoSwitch(
            value: completed,
            onChanged: onChanged,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                decoration: completed ? TextDecoration.lineThrough : null,
                color: completed
                    ? CupertinoColors.inactiveGray
                    : CupertinoColors.label,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(TaskAdapter());
  await Hive.openBox<Task>('tasks');

  runApp(NoteApp());
}

class Task extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  DateTime createdAt;

  @HiveField(2)
  DateTime? deadline;

  @HiveField(3)
  bool isCompleted;

  Task({
    required this.title,
    required this.createdAt,
    this.deadline,
    this.isCompleted = false,
  });
}

class TaskAdapter extends TypeAdapter<Task> {
  @override
  final int typeId = 0;

  @override
  Task read(BinaryReader reader) {
    return Task(
      title: reader.readString(),
      createdAt: DateTime.parse(reader.readString()),
      deadline: reader.readBool() ? DateTime.parse(reader.readString()) : null,
      isCompleted: reader.readBool(),
    );
  }

  @override
  void write(BinaryWriter writer, Task obj) {
    writer.writeString(obj.title);
    writer.writeString(obj.createdAt.toIso8601String());
    writer.writeBool(obj.deadline != null);
    if (obj.deadline != null) {
      writer.writeString(obj.deadline!.toIso8601String());
    }
    writer.writeBool(obj.isCompleted);
  }
}

class NoteApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      theme: CupertinoThemeData(
        brightness: Brightness.dark,
        primaryColor: CupertinoColors.activeOrange,
      ),
      home: NoteTabs(),
    );
  }
}

class NoteTabs extends StatefulWidget {
  @override
  _NoteTabsState createState() => _NoteTabsState();
}

class _NoteTabsState extends State<NoteTabs> {
  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: [
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.calendar_today), label: 'Сегодня'),
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.list_bullet), label: 'Все задачи'),
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.archivebox), label: 'Архив'),
        ],
      ),
      tabBuilder: (context, index) {
        switch (index) {
          case 0:
            return TaskPage(
              title: 'Сегодня',
              filter: (task) =>
                  task.createdAt.day == DateTime.now().day && !task.isCompleted,
              emptyMessage: 'Нет задач на сегодня.',
            );
          case 1:
            return TaskPage(
              title: 'Все задачи',
              filter: (task) => !task.isCompleted,
              emptyMessage: 'Список задач пуст.',
            );
          case 2:
            return TaskPage(
              title: 'Архив',
              filter: (task) => task.isCompleted,
              emptyMessage: 'Архив пуст.',
            );
          default:
            return Container();
        }
      },
    );
  }
}

class TaskPage extends StatelessWidget {
  final String title;
  final bool Function(Task) filter;
  final String emptyMessage;

  TaskPage({
    required this.title,
    required this.filter,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    final Box<Task> taskBox = Hive.box<Task>('tasks');

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(title),
      ),
      child: SafeArea(
        child: ValueListenableBuilder(
          valueListenable: taskBox.listenable(),
          builder: (context, Box<Task> box, _) {
            final tasks = box.values.where(filter).toList();

            if (tasks.isEmpty) {
              return Center(
                child: Text(
                  emptyMessage,
                  style: TextStyle(
                      color: CupertinoColors.systemGrey, fontSize: 18),
                ),
              );
            }

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  task.title,
                                  style: TextStyle(
                                    fontSize: 18,
                                    decoration: task.isCompleted
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                    color: task.isCompleted
                                        ? CupertinoColors.systemGrey
                                        : CupertinoColors.white,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Дата создания: ${task.createdAt}',
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: CupertinoColors.systemGrey),
                                ),
                                if (task.deadline != null)
                                  Text(
                                    'Дедлайн: ${task.deadline}',
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: CupertinoColors.systemGrey),
                                  ),
                              ],
                            ),
                            CupertinoButton(
                              padding: EdgeInsets.zero,
                              child: Icon(
                                task.isCompleted
                                    ? CupertinoIcons.check_mark_circled_solid
                                    : CupertinoIcons.check_mark_circled,
                                color: task.isCompleted
                                    ? CupertinoColors.activeGreen
                                    : CupertinoColors.inactiveGray,
                              ),
                              onPressed: () {
                                task.isCompleted = !task.isCompleted;
                                task.save();
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    showCupertinoDialog(
                      context: context,
                      builder: (context) {
                        String newTaskTitle = '';
                        DateTime? deadline;

                        return CupertinoAlertDialog(
                          title: Text('Добавить задачу'),
                          content: Column(
                            children: [
                              CupertinoTextField(
                                placeholder: 'Введите текст задачи',
                                onChanged: (value) {
                                  newTaskTitle = value;
                                },
                              ),
                              CupertinoButton(
                                child: Text('Указать дедлайн'),
                                onPressed: () async {
                                  deadline =
                                      await showCupertinoModalPopup<DateTime>(
                                    context: context,
                                    builder: (context) {
                                      return Container(); // Реализация выбора даты
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                          actions: [
                            CupertinoDialogAction(
                              child: Text('Отмена'),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                            CupertinoDialogAction(
                              child: Text('Добавить'),
                              onPressed: () {
                                if (newTaskTitle.isNotEmpty) {
                                  taskBox.add(Task(
                                    title: newTaskTitle,
                                    createdAt: DateTime.now(),
                                    deadline: deadline,
                                  ));
                                }
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(CupertinoIcons.add,
                          color: CupertinoColors.activeOrange),
                      SizedBox(width: 8),
                      Text(
                        'Добавить',
                        style: TextStyle(
                          fontSize: 18,
                          color: CupertinoColors.activeOrange,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

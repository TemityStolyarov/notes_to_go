import 'package:flutter/cupertino.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:notes_to_go/data/task_adapter.dart';

class TaskPage extends StatelessWidget {
  final String title;
  final bool Function(Task) filter;
  final String emptyMessage;

  const TaskPage({
    super.key,
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
              return Column(
                children: [
                  Expanded(
                    child: Center(
                      child: Text(
                        emptyMessage,
                        style: const TextStyle(
                            color: CupertinoColors.systemGrey, fontSize: 18),
                      ),
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
                            title: const Text('Добавить задачу'),
                            content: Column(
                              children: [
                                CupertinoTextField(
                                  placeholder: 'Введите текст задачи',
                                  onChanged: (value) {
                                    newTaskTitle = value;
                                  },
                                ),
                                CupertinoButton(
                                  child: const Text('Указать дедлайн'),
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
                                child: const Text('Отмена'),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                              CupertinoDialogAction(
                                child: const Text('Добавить'),
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
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          CupertinoIcons.add,
                          color: CupertinoColors.activeOrange,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Добавить',
                          style: TextStyle(
                            fontSize: 16,
                            color: CupertinoColors.activeOrange,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return Dismissible(
                        key: Key(task.key.toString()),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) {
                          task.delete();
                        },
                        background: Container(
                          color: CupertinoColors.systemRed,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 16.0),
                          child: const Icon(
                            CupertinoIcons.delete,
                            color: CupertinoColors.white,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8.0,
                            horizontal: 16.0,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
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
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
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
                                    const SizedBox(height: 4),
                                    Text(
                                      'Дата создания: ${task.createdAt}',
                                      style: const TextStyle(
                                          fontSize: 14,
                                          color: CupertinoColors.systemGrey),
                                    ),
                                    if (task.deadline != null)
                                      Text(
                                        'Дедлайн: ${task.deadline}',
                                        style: const TextStyle(
                                            fontSize: 14,
                                            color: CupertinoColors.systemGrey),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        showCupertinoDialog(
                          context: context,
                          builder: (context) {
                            String newTaskTitle = '';
                            DateTime? deadline;

                            return CupertinoAlertDialog(
                              title: const Text('Добавить задачу'),
                              content: Column(
                                children: [
                                  CupertinoTextField(
                                    placeholder: 'Введите текст задачи',
                                    onChanged: (value) {
                                      newTaskTitle = value;
                                    },
                                  ),
                                  CupertinoButton(
                                    child: const Text('Указать дедлайн'),
                                    onPressed: () async {
                                      deadline = await showCupertinoModalPopup<
                                          DateTime>(
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
                                  child: const Text('Отмена'),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                                CupertinoDialogAction(
                                  child: const Text('Добавить'),
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
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            CupertinoIcons.add,
                            color: CupertinoColors.activeOrange,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Добавить',
                            style: TextStyle(
                              fontSize: 16,
                              color: CupertinoColors.activeOrange,
                            ),
                          ),
                        ],
                      ),
                    ),
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

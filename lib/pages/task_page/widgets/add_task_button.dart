import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:notes_to_go/data/task_adapter.dart';

class AddTaskButton extends StatelessWidget {
  const AddTaskButton({super.key});

  @override
  Widget build(BuildContext context) {
    final Box<Task> taskBox = Hive.box<Task>('tasks');

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
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
                          deadline = await showCupertinoModalPopup<DateTime>(
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
                          taskBox.add(
                            Task(
                              title: newTaskTitle,
                              createdAt: DateTime.now(),
                              deadline: deadline,
                            ),
                          );
                        }
                        Navigator.pop(context);
                      },
                    ),
                  ],
                );
              },
            );
          },
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.65),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 12,
              ),
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
      ),
    );
  }
}

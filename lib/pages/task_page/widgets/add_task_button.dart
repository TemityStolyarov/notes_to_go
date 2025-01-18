import 'package:cupertino_calendar_picker/cupertino_calendar_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:notes_to_go/data/task_adapter.dart';

class AddTaskButton extends StatefulWidget {
  const AddTaskButton({super.key});

  @override
  State<AddTaskButton> createState() => _AddTaskButtonState();
}

class _AddTaskButtonState extends State<AddTaskButton> {
  DateTime? deadline;

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
            showAddTaskDialog(context, taskBox);
          },
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.65),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 12,
              ),
              child: Row(
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

  Future<dynamic> showAddTaskDialog(BuildContext context, Box<Task> taskBox) {
    return showCupertinoModalPopup(
      context: context,
      builder: (context) {
        String newTaskTitle = '';

        return DecoratedBox(
          decoration: BoxDecoration(
            color: CupertinoColors.darkBackgroundGray,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),

          // title: const Text('Добавить задачу'),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Добавить задачу',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 16),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: CupertinoColors.secondarySystemBackground
                        .resolveFrom(context),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      CupertinoTextField(
                        placeholder: 'Название задачи',
                        onChanged: (value) {
                          newTaskTitle = value;
                        },
                        clearButtonMode: OverlayVisibilityMode.editing,
                        keyboardAppearance: Brightness.dark,
                        padding: const EdgeInsets.all(12.0),
                        cursorColor: CupertinoColors.systemRed,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                        decoration: BoxDecoration(
                          color: CupertinoColors.secondarySystemBackground
                              .resolveFrom(context),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Divider(
                          color: CupertinoColors.systemGrey.withOpacity(0.5),
                          height: 1,
                        ),
                      ),
                      CupertinoTextField(
                        placeholder: 'Заметки',
                        onChanged: (value) {
                          newTaskTitle = value;
                        },
                        clearButtonMode: OverlayVisibilityMode.editing,
                        keyboardAppearance: Brightness.dark,
                        padding: const EdgeInsets.all(12.0),
                        cursorColor: CupertinoColors.systemRed,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                        decoration: BoxDecoration(
                          color: CupertinoColors.secondarySystemBackground
                              .resolveFrom(context),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(16),
                            bottomRight: Radius.circular(16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: CupertinoColors.secondarySystemBackground
                        .resolveFrom(context),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text('$deadline'),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Divider(
                          color: CupertinoColors.systemGrey.withOpacity(0.5),
                          height: 1,
                        ),
                      ),
                      CupertinoCalendar(
                        minimumDateTime: DateTime(2001, 01, 01),
                        maximumDateTime: DateTime(2050, 12, 31),
                        initialDateTime: DateTime.now(),
                        currentDateTime: DateTime.now(),
                        timeLabel: 'Deadline',
                        mode: CupertinoCalendarMode.dateTime,
                        mainColor: CupertinoColors.systemRed,
                        onDateSelected: (value) {
                          setState(() {
                            deadline = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CupertinoButton(
                      child: const Text(
                        'Отмена',
                        style: TextStyle(
                          color: CupertinoColors.systemRed,
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    CupertinoButton(
                      child: const Text('Добавить',
                          style: TextStyle(
                            color: CupertinoColors.systemRed,
                          )),
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
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

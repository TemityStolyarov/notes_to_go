import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:notes_to_go/data/task_adapter.dart';
import 'package:notes_to_go/pages/task_page/widgets/add_task_button.dart';

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
      resizeToAvoidBottomInset: true,
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          title,
          style: const TextStyle(
            color: CupertinoColors.white,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      child: SafeArea(
        child: ValueListenableBuilder(
          valueListenable: taskBox.listenable(),
          builder: (context, Box<Task> box, _) {
            final tasks = box.values.where(filter).toList();

            if (tasks.isEmpty) {
              return Stack(
                children: [
                  Center(
                    child: Text(
                      emptyMessage,
                      style: const TextStyle(
                        color: CupertinoColors.systemGrey,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.only(
                        bottom: 12,
                      ),
                      child: AddTaskButton(),
                    ),
                  ),
                ],
              );
            }

            return Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListView.builder(
                    itemCount: tasks.length + 1,
                    itemBuilder: (context, index) {
                      if (index == tasks.length) {
                        return const SizedBox(height: 100);
                      }

                      final task = tasks[index];

                      return Column(
                        children: [
                          Dismissible(
                            key: Key(task.key.toString()),
                            direction: DismissDirection.horizontal,
                            onDismissed: (direction) {
                              if (direction == DismissDirection.startToEnd) {
                                task.isCompleted = !task.isCompleted;
                                task.save();
                              } else if (direction ==
                                  DismissDirection.endToStart) {
                                task.delete();
                              }
                            },
                            background: Container(
                              decoration: const BoxDecoration(
                                color: CupertinoColors.systemGreen,
                              ),
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.only(left: 16.0),
                              child: const Icon(
                                CupertinoIcons.check_mark_circled,
                                size: 24,
                                color: CupertinoColors.white,
                              ),
                            ),
                            secondaryBackground: Container(
                              decoration: const BoxDecoration(
                                color: CupertinoColors.systemRed,
                              ),
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 16.0),
                              child: const Icon(
                                CupertinoIcons.delete,
                                size: 24,
                                color: CupertinoColors.white,
                              ),
                            ),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4.0,
                                  horizontal: 6.0,
                                ),
                                child: Row(
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        CupertinoButton(
                                          padding: EdgeInsets.zero,
                                          child: Icon(
                                            task.isCompleted
                                                ? CupertinoIcons
                                                    .check_mark_circled_solid
                                                : CupertinoIcons
                                                    .check_mark_circled,
                                            color: task.isCompleted
                                                ? CupertinoColors.activeGreen
                                                : CupertinoColors.inactiveGray,
                                          ),
                                          onPressed: () {
                                            task.isCompleted =
                                                !task.isCompleted;
                                            task.save();
                                          },
                                        ),
                                        // TODO deadline indicator
                                      ],
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12.0,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              task.title,
                                              overflow: TextOverflow.ellipsis,
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
                                            Row(
                                              children: [
                                                Text(
                                                  '${_formatDateTime(task.createdAt)}',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: CupertinoColors
                                                        .systemGrey,
                                                  ),
                                                ),
                                                if (task.deadline != null) ...[
                                                  Text(
                                                    ' • ',
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color: CupertinoColors
                                                          .systemGrey,
                                                    ),
                                                  ),
                                                  Text(
                                                    'До ${_formatDateTime(task.deadline!)}',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: DateTime.now()
                                                              .isAfter(task
                                                                  .deadline!)
                                                          ? CupertinoColors
                                                              .destructiveRed
                                                          : CupertinoColors
                                                              .systemGrey,
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                top: 8,
                                              ),
                                              child: Divider(
                                                color: CupertinoColors
                                                    .systemGrey
                                                    .withOpacity(0.5),
                                                height: 1,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // if (index != tasks.length - 1)
                          ///
                        ],
                      );
                    },
                  ),
                ),
                const Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: 12,
                    ),
                    child: AddTaskButton(),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  _formatDateTime(DateTime createdAt) {
    return createdAt.year == DateTime.now().year
        ? DateFormat('DD MMMM в HH:mm', 'ru').format(createdAt)
        : DateFormat('DD MMMM yyyy в HH:mm', 'ru').format(createdAt);
  }
}

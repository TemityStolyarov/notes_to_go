import 'package:flutter/cupertino.dart';
import 'package:hive_flutter/hive_flutter.dart';
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

    return
        // CupertinoPageScaffold(
        //   navigationBar: CupertinoNavigationBar(
        //     middle: Text(title),
        //   ),
        //   child:
        SafeArea(
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
              ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return Dismissible(
                    key: Key(task.key.toString()),
                    direction: DismissDirection.horizontal,
                    onDismissed: (direction) {
                      if (direction == DismissDirection.startToEnd) {
                        task.isCompleted = !task.isCompleted;
                        task.save();
                      } else if (direction == DismissDirection.endToStart) {
                        task.delete();
                      }
                    },
                    background: Container(
                      color: CupertinoColors.systemGreen,
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(left: 16.0),
                      child: const Icon(
                        CupertinoIcons.check_mark_circled,
                        size: 24,
                        color: CupertinoColors.white,
                      ),
                    ),
                    secondaryBackground: Container(
                      color: CupertinoColors.systemRed,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 16.0),
                      child: const Icon(
                        CupertinoIcons.delete,
                        size: 24,
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
                          Column(
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
                              // TODO deadline indicator
                            ],
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
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
      // ),
    );
  }
}

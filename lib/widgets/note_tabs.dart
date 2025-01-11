import 'package:flutter/cupertino.dart';
import 'package:notes_to_go/widgets/task_page.dart';

class NoteTabs extends StatefulWidget {
  const NoteTabs({super.key});

  @override
  _NoteTabsState createState() => _NoteTabsState();
}

class _NoteTabsState extends State<NoteTabs> {
  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              CupertinoIcons.calendar_today,
              size: 24,
            ),
            label: 'Ближайшие',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              CupertinoIcons.list_bullet,
              size: 24,
            ),
            label: 'Все задачи',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              CupertinoIcons.archivebox,
              size: 24,
            ),
            label: 'Архив',
          ),
        ],
      ),
      tabBuilder: (context, index) {
        switch (index) {
          case 0:
            return TaskPage(
              title: 'Ближайшие',
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

import 'package:f_stop_timer/pages/print_page.dart';
import 'package:flutter/cupertino.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {

  @override
  Widget build(BuildContext context) {
    final pages = [
      const PrintPage()
      // const TimerConfigPage(),
      // const TestStripPage(),
      //   const BlePage(),
    ];
    final labels = ["Timer", "Test Strip", "BLE"];
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: List.generate(labels.length, (index) {
          return BottomNavigationBarItem(
            icon: Icon(
              switch (index) {
                0 => CupertinoIcons.timer,
                1 => CupertinoIcons.square_lefthalf_fill,
                2 => CupertinoIcons.bluetooth,
                _ => CupertinoIcons.circle,
              },
            ),
            label: labels[index],
          );
        }),
      ),
      tabBuilder: (context, index) {
        return CupertinoTabView(
          builder: (context) {
            return pages[index];
          },
        );
      },
    );
  }
}

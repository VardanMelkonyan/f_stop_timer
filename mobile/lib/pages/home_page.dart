import 'package:f_stop_timer/pages/print_page.dart';
import 'package:f_stop_timer/pages/test_strip_page.dart';
import 'package:flutter/cupertino.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  Widget build(BuildContext context) {
    final pages = [
      const PrintPage(),
      const TestStripPage(),
    ];
    final labels = ["Print", "Test Strip"];

    // If there's only one tab, use a simple page scaffold to avoid CupertinoTabBar assertion.
    if (labels.length < 2) {
      return CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(
          middle: Text('Print'),
        ),
        child: const PrintPage(),
      );
    }

    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: List.generate(labels.length, (index) {
          return BottomNavigationBarItem(
            icon: Icon(
              switch (index) {
                0 => CupertinoIcons.printer,
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

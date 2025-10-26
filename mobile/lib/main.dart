import 'package:flutter/cupertino.dart';
import './pages/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp( const FStopApp()
    // MultiProvider(
    //   providers: [
    //     // ChangeNotifierProvider(create: (_) => BleController()),
    //     // ChangeNotifierProvider(create: (_) => TimerModel()),
    //   ],
    //   child: const FStopApp(),
    // ),
  );
}

class FStopApp extends StatelessWidget {
  const FStopApp({super.key});
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'F-stop Timer',
	  debugShowCheckedModeBanner: false,
      theme: const CupertinoThemeData(
        brightness: Brightness.dark,
        primaryColor: Color(0xFFFF0000), // bright red
        scaffoldBackgroundColor: Color(0xFF000000), // black background
        barBackgroundColor: Color(0xFF000000), // slightly lighter surface
        textTheme: CupertinoTextThemeData(
          textStyle: TextStyle(color: Color(0xFFCC0000)), // main red text
          primaryColor: Color(0xFFFF0000),
          actionTextStyle: TextStyle(color: Color(0xFF990000)), // muted red
          tabLabelTextStyle: TextStyle(color: Color(0xFF990000)),
        ),
      ),
      home: const HomePage(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:roulette_game/reset_widget.dart';
import 'package:roulette_game/title_screen.dart';

import 'main_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 가로모드
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    return MaterialApp(
        debugShowCheckedModeBanner: false, // 디버그 레이블 비활성화
        title: '공 피하기',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const Scaffold(
            body: Stack(
          children: [
            TitleScreen(),
            // MainGame(),
          ],
        )));
  }
}

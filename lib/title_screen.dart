import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:roulette_game/util/bgm_manager.dart';

import 'main_screen.dart';

class TitleScreen extends StatelessWidget {
  const TitleScreen({super.key});


  void playBackgroundMusic() {
    SoundPlayer soundPlayer = SoundPlayer();
    soundPlayer.playBackgroundSound();
  }

  @override
  Widget build(BuildContext context) {
    playBackgroundMusic(); // 백그라운드 음악 재생

    return menuView(context);
  }
}

Widget menuView(BuildContext context) {

  // SoundPlayer 인스턴스 생성
  SoundPlayer $SoundPlayer = SoundPlayer();

  return Stack(
    children: [
      Image.asset(
        'assets/images/title_image.png',
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      ),
      Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '피하기 게임',
              style: TextStyle(
                fontSize: 40.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(

              onPressed:  () async {

                (() async {
                 await $SoundPlayer.clickedSound();
                })();

                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MainGame()),
                );

              },
              child: const Text(
                '시작하기',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 30.0),
            ElevatedButton(
              onPressed: () {
                // 게임 종료 로직 추가
                SystemNavigator.pop(); // 앱 종료

              },
              child: const Text(
                '종료하기',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}



import 'package:flutter/material.dart';
import 'package:roulette_game/util/bgm_manager.dart';

import 'dart:async';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:math';
import 'timer_widget.dart';

class MainGame extends StatefulWidget {
  const MainGame({Key? key}) : super(key: key);

  @override
  _MainGameState createState() => _MainGameState();
}

class _MainGameState extends State<MainGame>  with SingleTickerProviderStateMixin {

  /// TODO: 변수 정리 필요 enum 및 상수화

  late AnimationController _controller;
  late Animation<double> _animation;

  double centerX = 0.0;
  double centerY = 0.0;
  double offsetX = 0.0;
  double offsetY = 0.0;
  List<Offset> blueCirclePositions = [];
  List<Offset> blueCircleVelocities = [];

  Offset collisionPosition = Offset.zero;
  int elapsedTime = 0;
  double blueCircleSpeedIncrease = 0.1; // 10%
  double maxBlueCircleSpeedIncrease = 3.0; // 최대 3배 증가
  bool isPlay = false; // 추가된 전역 변수
  bool isColliding = false; // 충돌 여부
  bool inColliding = false; // 충돌 딜레이

  SoundPlayer $SoundPlayer = SoundPlayer(); // SoundPlayer 인스턴스 생성

  //ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ

  @override
  void initState() {
    super.initState();

    // AnimationController 초기화
    _controller = AnimationController(
      duration: const Duration(minutes: 1),  // 애니메이션 지속 시간 설정 (1분)
      vsync: this,
    );

    // 애니메이션을 위한 CurvedAnimation 초기화
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    // 가속도계 이벤트 리스너 등록
    accelerometerEvents.listen((AccelerometerEvent event) {
      if (isPlay) { // isPlay 변수 확인
        setState(() {
          // X, Y 좌표의 오프셋 값 계산
          offsetX = event.y * 20;
          offsetY = event.x * 20;

          // 파란색 원들의 이동 처리
          moveBlueCircles();
        });
      }
    });


    // 파란색 원들의 초기 위치 랜덤하게 설정
    Random random = Random();
    for (int i = 0; i < 10; i++) {
      // 최소 10개의 파란색 원
      double x = random.nextDouble() * 300 + 50;
      double y = random.nextDouble() * 300 + 50;
      blueCirclePositions.add(Offset(x, y));

      blueCircleVelocities.add(Offset(random.nextDouble() * 5 + 2, random.nextDouble() * 5 + 2));  // 각각 파란색 원의 X축 속도와 Y축 속도

    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  //ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
  /// 로직 최적화 및 리팩토링 필요

  void accelerateBlueCircleSpeed() {
    const duration = Duration(seconds: 10);
    double maxVelocity = 0.0; // 최대 속도 제한 값

    if (blueCircleVelocities.isNotEmpty) {
      maxVelocity = blueCircleVelocities[0].dx * 3; // 첫 번째 파란색 원의 X축 초기 속도를 기준으로 최대 속도 설정
    }

    Timer.periodic(duration, (timer) {
      if (isPlay) {
        setState(() {
          elapsedTime++;
          // 10초마다 파란색 원들의 속도를 1%씩 증가
          if (elapsedTime % 10 == 0 && blueCircleSpeedIncrease < maxBlueCircleSpeedIncrease) {
            for (int i = 0; i < blueCircleVelocities.length; i++) {
              double currentVelocityX = blueCircleVelocities[i].dx;
              double currentVelocityY = blueCircleVelocities[i].dy;
              double increasedVelocityX = currentVelocityX * 5; // X축 속도 1% 증가
              double increasedVelocityY = currentVelocityY * 5; // Y축 속도 1% 증가

              // 최대 속도 제한
              double newVelocityX = increasedVelocityX > maxVelocity ? maxVelocity : increasedVelocityX;
              double newVelocityY = increasedVelocityY > maxVelocity ? maxVelocity : increasedVelocityY;

              blueCircleVelocities[i] = Offset(newVelocityX, newVelocityY);
            }
            blueCircleSpeedIncrease *= 3.0; // 최대 속도 3배 증가
          }
        });
      }
    });
  }


  void moveBlueCircles() {
    if (!isPlay) {
      return; // isPlay가 false일 경우 움직임을 멈춥니다.
    }

    // 초록색 원과 파란색 원들의 중심 사이의 거리 계산
    double greenCircleCenterX = centerX + offsetX;
    double greenCircleCenterY = centerY + offsetY;

    for (int i = 0; i < blueCirclePositions.length; i++) {
      double blueCircleCenterX = blueCirclePositions[i].dx;
      double blueCircleCenterY = blueCirclePositions[i].dy;

      double distance = sqrt(pow(greenCircleCenterX - blueCircleCenterX, 2) +
          pow(greenCircleCenterY - blueCircleCenterY, 2));

      // 초록색 원과 파란색 원이 완전히 겹칠 경우
      if (distance < 25) {

        $SoundPlayer.effectSound();

        // 초록색 원 반지름 25, 파란색 원 반지름 10
        // 파란색 원의 위치를 재조정
        double angle = atan2(greenCircleCenterY - blueCircleCenterY,
            greenCircleCenterX - blueCircleCenterX);
        double newX = greenCircleCenterX + (25 + distance) * cos(angle);
        double newY = greenCircleCenterY + (25 + distance) * sin(angle);
        blueCirclePositions[i] = Offset(newX, newY);

        // 충돌 이펙트 표시
        isColliding = true;
        inColliding = true;

        // 1분(60초) 후에 inColliding을 false로 설정
        Timer(const Duration(milliseconds: 1000), () {
          inColliding = false;
        });

      } else {

        if(!inColliding) isColliding = false;

        // 파란색 원이 초록색 원과 겹치지 않을 경우
        // 직선으로 이동하며 벽에 부딪히면 방향을 바꿈
        double dx = blueCircleVelocities[i].dx;
        double dy = blueCircleVelocities[i].dy;
        double newX = blueCircleCenterX + dx;
        double newY = blueCircleCenterY + dy;

        // 화면 범위를 벗어나면 방향을 바꿈
        if (newX < 20 || newX > MediaQuery
            .of(context)
            .size
            .width - 20) {
          dx = -dx;
        }
        if (newY < 20 || newY > MediaQuery
            .of(context)
            .size
            .height - 20) {
          dy = -dy;
        }

        newX = max(20, min(newX, MediaQuery
            .of(context)
            .size
            .width - 20));
        newY = max(20, min(newY, MediaQuery
            .of(context)
            .size
            .height - 20));

        blueCirclePositions[i] = Offset(newX, newY);
        blueCircleVelocities[i] = Offset(dx, dy);
      }
    }

    // 초록색 원을 움직이는 로직 추가
    if (isPlay) {
      centerX += offsetX;
      centerY += offsetY;
    }
  }


  //ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ

  @override
  Widget build(BuildContext context) {
    centerX = MediaQuery
        .of(context)
        .size
        .width / 2 - 50;
    centerY = MediaQuery
        .of(context)
        .size
        .height / 2 - 50;

    return Scaffold(
      // backgroundColor: const Color.fromRGBO(181, 214, 146, 1), // 전체 배경색 지정
      body: Stack(
        children: [
             Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/background.jpg'),
                    fit: BoxFit.cover,
                  )
               ),
          ),
          // const ResetButton(), // 리셋 버튼 추가
          TimerWidget(onPlayPauseToggle: isPlay,),
          AnimatedBuilder(
            animation: _controller,
            builder: (BuildContext context, Widget? child) {
              if (isColliding || _controller.status == AnimationStatus.completed) {
                // 충돌 상태일 때는 'assets/images/die.png' 이미지를 사용
                return Positioned(
                  left: centerX + offsetX,
                  top: centerY + offsetY,
                  child: SizedBox(
                    width: 50,
                    height: 50,
                    child: Image.asset('assets/images/die.png'),
                  ),
                );

              } else {

                // 충돌 상태가 아닐 때는 'assets/images/life.png' 이미지를 사용
                return Positioned(
                  left: centerX + offsetX,
                  top: centerY + offsetY,
                  child: SizedBox(
                    width: 50,
                    height: 50,
                    child: Image.asset('assets/images/life.png'),
                  ),
                );
              }
            },
          ),


          Stack(
            children: blueCirclePositions.map((position) {
              return Positioned(
                left: position.dx,
                top: position.dy,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: AssetImage('assets/images/bird.png'), // 이미지 파일 경로를 적절히 수정해주세요.
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),


          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0,top: 20), // 원하는 패딩 값을 설정하세요
                child: IconButton(
                  iconSize: 50,
                  icon: Icon(
                    isPlay ? Icons.pause : Icons.play_arrow,
                    color: Colors.red,
                  ),
                  onPressed: () {
                    setState(() {
                      isPlay = !isPlay;
                    });
                  },
                ),
              ),
              const SizedBox(
                width: 40,
                height: 40,
              ),
            ],
          ),

        ],
      ),
    );
  }
}
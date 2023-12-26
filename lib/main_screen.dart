import 'package:flutter/material.dart';

import 'dart:async';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:math';
import 'my_timer_widget.dart';

class MainGame extends StatefulWidget {
  const MainGame({Key? key}) : super(key: key);

  @override
  _MainGameState createState() => _MainGameState();
}

class _MainGameState extends State<MainGame>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double centerX = 0.0;
  double centerY = 0.0;
  double offsetX = 0.0;
  double offsetY = 0.0;
  List<Offset> blueCirclePositions = [];
  List<Offset> blueCircleVelocities = [];
  bool isColliding = false;
  Offset collisionPosition = Offset.zero;
  int elapsedTime = 0;
  double blueCircleSpeedIncrease = 0.1; // 10%
  double maxBlueCircleSpeedIncrease = 3.0; // 최대 5배 증가

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        offsetX = event.y * 20;
        offsetY = event.x * 20;
        moveBlueCircles();
      });
    });
    // 파란색 원들의 초기 위치 랜덤하게 설정
    Random random = Random();
    for (int i = 0; i < 10; i++) {
      // 최소 10개의 파란색 원
      double x = random.nextDouble() * 300 + 50;
      double y = random.nextDouble() * 300 + 50;
      blueCirclePositions.add(Offset(x, y));
      blueCircleVelocities
          .add(Offset(random.nextDouble() * 10, random.nextDouble() * 10));
    }
    // 타이머 시작
    startTimer();
  }

  void startTimer() {
    const duration = Duration(seconds: 10);
    Timer.periodic(duration, (timer) {
      setState(() {
        elapsedTime++;
        // 10초마다 파란색 원들의 속도를 1%씩 증가
        if (elapsedTime % 10 == 0 &&
            blueCircleSpeedIncrease < maxBlueCircleSpeedIncrease) {
          for (int i = 0; i < blueCircleVelocities.length; i++) {
            blueCircleVelocities[i] *= (1.1); // 1% 증가
          }
          blueCircleSpeedIncrease *= 2.0; // 최대속도
        }
      });
    });
  }

  void moveBlueCircles() {
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
        // 초록색 원 반지름 25, 파란색 원 반지름 10
        // 파란색 원의 위치를 재조정
        double angle = atan2(greenCircleCenterY - blueCircleCenterY,
            greenCircleCenterX - blueCircleCenterX);
        double newX = greenCircleCenterX + (25 + distance) * cos(angle);
        double newY = greenCircleCenterY + (25 + distance) * sin(angle);
        blueCirclePositions[i] = Offset(newX, newY);

        // 충돌 이펙트 표시
        isColliding = true;
        collisionPosition = Offset(blueCircleCenterX, blueCircleCenterY);
        _controller.reset();
        _controller.forward();
      } else {
        // 파란색 원이 초록색 원과 겹치지 않을 경우
        // 직선으로 이동하며 벽에 부딪히면 방향을 바꿈
        double dx = blueCircleVelocities[i].dx;
        double dy = blueCircleVelocities[i].dy;
        double newX = blueCircleCenterX + dx;
        double newY = blueCircleCenterY + dy;

        // 화면 범위를 벗어나면 방향을 바꿈
        if (newX < 20 || newX > MediaQuery.of(context).size.width - 20) {
          dx = -dx;
        }
        if (newY < 20 || newY > MediaQuery.of(context).size.height - 20) {
          dy = -dy;
        }

        newX = max(20, min(newX, MediaQuery.of(context).size.width - 20));
        newY = max(20, min(newY, MediaQuery.of(context).size.height - 20));

        blueCirclePositions[i] = Offset(newX, newY);
        blueCircleVelocities[i] = Offset(dx, dy);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    centerX = MediaQuery.of(context).size.width / 2 - 50;
    centerY = MediaQuery.of(context).size.height / 2 - 50;

    return Scaffold(
      body: Stack(
        children: [
          // MainPopup(), // MainPopup 위젯으로 대체
          const MyTimerWidget(),
          AnimatedBuilder(
            animation: _animation,
            builder: (BuildContext context, Widget? child) {
              return Positioned(
                left: centerX + offsetX,
                top: centerY + offsetY,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    gradient: isColliding && _animation.value != 0.0
                        ? RadialGradient(
                            colors: const [
                              Colors.green,
                              Colors.transparent,
                            ],
                            stops: const [0.0, 1.0],
                            center: const Alignment(0.5, 0.5),
                            radius: _animation.value * 1.5,
                          )
                        : null,
                  ),
                  width: 50,
                  height: 50,
                ),
              );
            },
          ),
          Stack(
            children: blueCirclePositions
                .map((position) => Positioned(
                      left: position.dx,
                      top: position.dy,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                          gradient: isColliding && position == collisionPosition
                              ? RadialGradient(
                                  colors: const [
                                    Colors.blue,
                                    Colors.transparent,
                                  ],
                                  stops: const [0.0, 1.0],
                                  center: const Alignment(0.5, 0.5),
                                  radius: _animation.value * 1.5,
                                )
                              : null,
                        ),
                        width: 20,
                        height: 20,
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

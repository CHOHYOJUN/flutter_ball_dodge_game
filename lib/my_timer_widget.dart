import 'package:flutter/material.dart';
import 'dart:async';

class MyTimerWidget extends StatefulWidget {
  final bool onPlayPauseToggle;

  const MyTimerWidget({
    Key? key,
    required this.onPlayPauseToggle,
  }) : super(key: key);

  @override
  _MyTimerWidgetState createState() => _MyTimerWidgetState();
}

class _MyTimerWidgetState extends State<MyTimerWidget> {
  bool isPlaying = false;
  int secondsElapsed = 0;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      if (widget.onPlayPauseToggle) {
        setState(() {
          isPlaying = !isPlaying;
          if (isPlaying) {
            secondsElapsed++;
          }
        });
      }
    });
  }

  void resetTimer() {
    setState(() {
      secondsElapsed = 0;
    });
  }

  String formatTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds ~/ 60) % 60;
    int remainingSeconds = seconds % 60;

    String hoursStr = hours.toString().padLeft(2, '0');
    String minutesStr = minutes.toString().padLeft(2, '0');
    String secondsStr = remainingSeconds.toString().padLeft(2, '0');

    return '$hoursStr:$minutesStr:$secondsStr';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          alignment: Alignment.topCenter,
          padding: const EdgeInsets.only(top: 16.0),
          child: Text(
            formatTime(secondsElapsed),
            style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

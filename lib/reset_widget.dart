import 'package:flutter/material.dart';

import 'main_screen.dart';

class ResetButton extends StatelessWidget {
  const ResetButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 16.0,
      left: 16.0,
      child: ElevatedButton(
        child: const Text(
          'New',
          style: TextStyle(
              fontSize: 24.0, fontWeight: FontWeight.bold, color: Colors.red),
        ),
        onPressed: () {
          // TimerWidget.reset();
          // MainGame.reset();
        },
      ),
    );
  }
}

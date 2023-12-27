import 'package:flutter/material.dart';

class ResetButton extends StatelessWidget {
  const ResetButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

  /// 미구현 추후 고려
    return Positioned(
      top: 16.0,
      left: 16.0,
      child: ElevatedButton(
        child: const Text(
          '새로시작',
          style: TextStyle(
              fontSize: 24.0, fontWeight: FontWeight.bold, color: Colors.red),
        ),
        onPressed: () async{
          //
        },
      ),
    );
  }
}

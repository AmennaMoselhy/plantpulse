import 'package:flutter/material.dart';

class UpGreenPlantPulse extends StatelessWidget {
  const UpGreenPlantPulse({super.key});

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final size = mq.size;
    final topPadding = mq.padding.top;

    return Container(
      width: double.infinity,
      height: size.height * 0.191 + topPadding,
      padding: EdgeInsets.only(top: topPadding),
      decoration: const BoxDecoration(
        color: Color(0x47A4D19B),
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(256),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: size.width *0.6,
            left: size.width *0.23,
            top: size.height *0.05,
            child: Image.asset(
              'assets/leaf.png',
              height: 58,
              width: 58,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
          Positioned(
            top: size.height *0.085,
            left: size.width *0.37,
            child: Image.asset(
              'assets/plantpulse.png',
              height: size.height * 0.02,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:mcapp/home.dart';



class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

PageRoute buildPageRoute(Widget destination) {
  return PageRouteBuilder(
    transitionDuration: const Duration(milliseconds: 500), // Czas trwania animacji
    pageBuilder: (context, animation, secondaryAnimation) => destination,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // Dostosuj efekt przejścia tutaj
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
  );
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Timer(
      const Duration(seconds: 6),
          () => Navigator.of(context).pushReplacement(
        buildPageRoute(const Home()),

      ),
    );
  }
  
 @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        child: Center(
          child: Lottie.asset('assets/animations/thewire2.json'),
        ),
      ),
    );
  }
}
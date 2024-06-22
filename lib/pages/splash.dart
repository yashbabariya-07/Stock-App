import 'package:flutter/material.dart';
import 'package:share_app/pages/earning.dart';
import 'package:share_app/pages/onboarding.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _imageAnimation;
  late AnimationController _animationController1;
  late Animation<Offset> _imageAnimation1;
  bool _showScrollIndicator = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );
    _imageAnimation = Tween<Offset>(
      begin: Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();

    _animationController1 = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );
    _imageAnimation1 = Tween<Offset>(
      begin: Offset(-1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController1,
      curve: Curves.easeInOut,
    ));

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController1.forward();
      }
    });

    _animationController1.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _showScrollIndicator = true;
        });
        Future.delayed(Duration(milliseconds: 1500), () {
          backscreen();
        });
      }
    });
  }

  Future<void> backscreen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? Token = prefs.getString('token');

    print('tokenn: $Token');

    if (Token != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Earning(),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Onboarding(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          if (!_showScrollIndicator) ...[
            Positioned(
              top: -30,
              left: -60,
              child: AnimatedBuilder(
                animation: _animationController1,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _animationController1.value,
                    child: CircleAvatar(
                      radius: 100,
                      backgroundColor: Colors.yellow,
                    ),
                  );
                },
              ),
            ),
            Positioned(
              top: 460,
              right: -160,
              child: AnimatedBuilder(
                animation: _animationController1,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _animationController1.value,
                    child: CircleAvatar(
                      radius: 100,
                      backgroundColor: Colors.red,
                    ),
                  );
                },
              ),
            ),
            Positioned(
              top: 320,
              left: -170,
              child: AnimatedBuilder(
                animation: _animationController1,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _animationController1.value,
                    child: CircleAvatar(
                      radius: 100,
                      backgroundColor: Colors.orange,
                    ),
                  );
                },
              ),
            ),
            Positioned(
              top: 80,
              right: -140,
              child: AnimatedBuilder(
                animation: _animationController1,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _animationController1.value,
                    child: CircleAvatar(
                      radius: 100,
                      backgroundColor: Colors.blue,
                    ),
                  );
                },
              ),
            ),
            Positioned(
              bottom: -80,
              left: -20,
              child: AnimatedBuilder(
                animation: _animationController1,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _animationController1.value,
                    child: CircleAvatar(
                      radius: 100,
                      backgroundColor: Colors.green,
                    ),
                  );
                },
              ),
            ),
            AnimatedBuilder(
              animation: _animationController1,
              builder: (context, child) {
                return SlideTransition(
                  position: _imageAnimation,
                  child: child,
                );
              },
              child: Center(
                  child: Image.asset(
                "assets/sml.png",
                height: 180,
              )),
            ),
          ],
          if (_showScrollIndicator)
            Center(
              child: LoadingAnimationWidget.threeRotatingDots(
                color: Colors.blue,
                size: 80,
              ),
            ),
        ],
      ),
    );
  }
}

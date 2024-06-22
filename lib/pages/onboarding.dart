import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:share_app/pages/loginpage.dart';
import 'package:share_app/routes/route.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({Key? key}) : super(key: key);

  @override
  _OnboardingState createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  final List<OnboardingPageModel> pages = [
    OnboardingPageModel(
      image: 'assets/os1.png',
      title: 'Invest for your future!',
      description:
          'Explore the world of investing and trading with our user-friendly app. Keep track of your investments and analyze market trends',
    ),
    OnboardingPageModel(
      image: 'assets/os3.png',
      title: 'Discover Opportunities',
      description:
          ' Learn about various investment options, from stocks and mutual funds to cryptocurrencies and commodities.',
    ),
    OnboardingPageModel(
      image: 'assets/os2.png',
      title: 'Keep your investment safe.',
      description:
          ' Stay updated with real-time market news, expert analysis, and personalized insights tailored to your investment goals.',
    ),
  ];

  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _showGetStartedButton = false;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(_handlePageChange);
  }

  @override
  void dispose() {
    _pageController.removeListener(_handlePageChange);
    _pageController.dispose();
    super.dispose();
  }

  void _handlePageChange() {
    setState(() {
      _currentPage = _pageController.page!.round();
      if (_currentPage == pages.length - 1 &&
          _pageController.page!.round() == pages.length - 1) {
        Future.delayed(Duration(milliseconds: 1000), () {
          setState(() {
            _showGetStartedButton = true;
          });
        });
      } else {
        _showGetStartedButton = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        itemCount: pages.length,
        itemBuilder: (context, index) {
          return OnboardingPage(
            pageModel: pages[index],
            currentPage: _currentPage,
            pageIndex: index,
            totalPages: pages.length,
            pageController: _pageController,
            showGetStartedButton: _showGetStartedButton,
          );
        },
      ),
    );
  }
}

class OnboardingPageModel {
  final String image;
  final String title;
  final String description;

  OnboardingPageModel({
    required this.image,
    required this.title,
    required this.description,
  });
}

class OnboardingPage extends StatelessWidget {
  final OnboardingPageModel pageModel;
  final int currentPage;
  final int pageIndex;
  final int totalPages;
  final PageController pageController;
  final bool showGetStartedButton;

  const OnboardingPage({
    Key? key,
    required this.pageModel,
    required this.currentPage,
    required this.pageIndex,
    required this.totalPages,
    required this.pageController,
    required this.showGetStartedButton,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Color> indicatorColors = [
      Colors.red,
      Colors.green,
      Colors.orange,
    ];

    double progress = (currentPage + 1) / totalPages;

    return Padding(
      padding: const EdgeInsets.only(top: 30, right: 20, left: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, Routes.loginRoute);
                },
                child: Text(
                  "Skip",
                  style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF171717)),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Container(
            height: 300,
            width: double.infinity,
            child: Image.asset(
              pageModel.image,
              width: double.infinity,
            ),
          ),
          SizedBox(height: 30),
          Text(
            pageModel.title,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 20,
                fontFamily: 'Inter',
                fontWeight: FontWeight.bold,
                color: Color(0xFF171717)),
          ),
          SizedBox(height: 10),
          Text(
            pageModel.description,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 12, fontFamily: 'Inter', color: Color(0xFF171717)),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              totalPages,
              (index) => AnimatedContainer(
                duration: Duration(milliseconds: 300),
                width: 8,
                height: 8,
                margin: EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: currentPage == index
                      ? Color(0xFFC7FF24)
                      : Color(0xFF171717),
                ),
              ),
            ),
          ),
          SizedBox(height: 80),
          if (!showGetStartedButton)
            GestureDetector(
              onTap: () {
                if (currentPage < totalPages - 1) {
                  pageController.animateToPage(
                    currentPage + 1,
                    duration: Duration(milliseconds: 500),
                    curve: Curves.ease,
                  );
                }
              },
              child: CircularPercentIndicator(
                animation: true,
                animationDuration: 1000,
                radius: 30,
                lineWidth: 1,
                percent: progress,
                progressColor: indicatorColors[pageIndex],
                center: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: indicatorColors[pageIndex],
                  ),
                  child: Icon(Icons.forward),
                ),
              ),
            ),
          if (showGetStartedButton)
            GestureDetector(
              onTap: () {
                // Navigator.pushNamed(context, Routes.loginRoute);
                Navigator.popUntil(context, ModalRoute.withName('/login'));
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginPage(),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Color(0xFF1B1B1B),
                ),
                child: Center(
                  child: Text(
                    "Get Started",
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFFFFFFFF),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:share_app/pages/buy.dart';
import 'package:share_app/pages/earning.dart';
import 'package:share_app/pages/forgotpswd.dart';
import 'package:share_app/pages/loginpage.dart';
import 'package:share_app/pages/myshare.dart';
import 'package:share_app/pages/onboarding.dart';
import 'package:share_app/pages/searchShare.dart';
import 'package:share_app/pages/sell.dart';
import 'package:share_app/pages/setting.dart';
import 'package:share_app/pages/shreinfo.dart';
import 'package:share_app/pages/signuppage.dart';
import 'package:share_app/pages/splash.dart';
import 'package:share_app/pages/userProfile.dart';
import 'package:share_app/routes/route.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: Routes.splashRoute,
      theme: ThemeData(
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      routes: {
        Routes.splashRoute: (context) => SplashPage(),
        Routes.loginRoute: (context) => LoginPage(),
        Routes.signRoute: (context) => SignupPage(),
        Routes.onBoardRoute: (context) => Onboarding(),
        Routes.userRoute: (context) => UserProfile(),
        Routes.earnRoute: (context) => Earning(),
        Routes.shareRoute: (context) => MyShare(),
        Routes.shareInfoRoute: (context) => ShareInfo(),
        Routes.sellRoute: (context) => SellPage(),
        Routes.buyRoute: (context) => BuyPage(),
        Routes.searchShareRoute: (context) => SearchShare(),
        Routes.forgotPswdRoute: (context) => ForgotPswd(),
        Routes.settingRoute: (context) => ChangePswd(),
      },
    );
  }
}

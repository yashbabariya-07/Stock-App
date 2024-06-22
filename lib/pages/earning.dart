import 'dart:math';
import 'package:flutter/material.dart';
import 'package:share_app/pages/bottomtab.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_app/routes/route.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:rxdart/rxdart.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class Earning extends StatefulWidget {
  const Earning({super.key});

  @override
  State<Earning> createState() => _EarningState();
}

class _EarningState extends State<Earning> {
  String? utoken;
  IO.Socket? socket;
  int? levels;
  int? nextLevels;
  double? balance;
  double? amount;
  double? levelAmount;
  String? uid;
  String? fname;
  String? image;
  double valueOfStock = 0.0;
  double changes = 0.0;
  int? rewardAmount;
  int tapCount = 0;

  List shareData = [];

  final selected = BehaviorSubject<int>();
  int rewards = 0;

  List<int> items = [];

  @override
  void initState() {
    super.initState();
    connectAndListen();
    getData();
    random();
    initInterstitialAd();
    initRewardInterstitialAd();
  }

  late InterstitialAd interstitialAd;
  bool displayAd = false;

  late RewardedInterstitialAd rewardedInterstitialAd;
  bool rewardAd = false;

  void connectAndListen() {
    socket = IO.io('http://192.168.43.243:8000/', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket!.connect();

    socket!.onConnect((_) {});

    socket!.onDisconnect((_) {});
  }

  void getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');
    utoken = token;

    SharedPreferences prefss = await SharedPreferences.getInstance();
    String? uInfoString = prefss.getString('Uinfo');
    Map<String, dynamic> userInfo = jsonDecode(uInfoString!);
    String? userId = userInfo['id'].toString();
    print('User ID: $userId');
    uid = userId;
    print('uid $uid');
    setState(() {
      userdata(uid);
      increaseEarnings(0, 0);
      spinner(0, rewards);
      if (Global.shareData == null) {
        symbolList(utoken);
      }
    });
  }

  void random() {
    Random random = Random();
    items = List.generate(6, (index) => random.nextInt(100));
  }

  void userdata(uid) async {
    var url = "http://192.168.43.243:8000/api/user?id=" + uid!;

    var urlParse = Uri.parse(url);
    http.Response response = await http.get(
      urlParse,
      headers: <String, String>{
        'x-auth-token': utoken!,
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    var dataUser = jsonDecode(response.body);
    print("User Data == $dataUser");

    var firstname = dataUser['payload']['userInfo'][0]['firstName'];
    print('Fname!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!: $firstname');
    fname = firstname;

    var images = dataUser['payload']['userInfo'][0]['userProfile'];
    print('Images^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^: $images');
    image = images;

    setState(() {
      fname;
      image;
    });
  }

  //type is use for if user tap the earn money then and then increase balance otherwise not.
  void increaseEarnings(int type, int boostAmount) {
    socket?.emit('ADD_AMOUNT_IN_WALLET', {
      "token": utoken,
      "status": type,
      "boostAmount": boostAmount != 0 ? boostAmount : amount,
    });

    socket!.on('FETCH_WALLET_DATA', (data) {
      print('Earn Data 123-------------------------------------: $data');

      setState(() {
        if (data['wallet'] != null && data['wallet']['current_level'] != null) {
          levels = data['wallet']['current_level'];
          nextLevels = levels! + 1;
        }

        if (data['wallet'] != null &&
            data['wallet']['current_balance'] != null &&
            data['wallet']['current_balance'] != "") {
          balance = double.tryParse(data['wallet']['current_balance']);
        }

        if (data['wallet'] != null &&
            data['wallet']['increment_amount'] != null &&
            data['wallet']['increment_amount'] != "") {
          amount = double.tryParse(data['wallet']['increment_amount']);
        }

        if (data['wallet'] != null &&
            data['wallet']['next_level_amount'] != null &&
            data['wallet']['next_level_amount'] != "") {
          levelAmount = double.tryParse(data['wallet']['next_level_amount']);
        }
      });
    });
  }

  void spinner(int type, int rewardsInt) {
    socket?.emit('ADD_AMOUNT_IN_WALLET',
        {"token": utoken, "status": type, "boostAmount": rewardsInt});
    socket!.on('FETCH_WALLET_DATA', (data) {
      print('Spin Data \\\\\\\\\--///////////: $data');
    });
  }

  void symbolList(utoken) {
    socket?.emit('SYMBOL_LIST', {"token": utoken});
    socket!.on('FETCH_SYMBOL_LIST', (data) {
      print('Symbol List *****************: $data');
      setState(() {
        Global.shareData = data;
      });
    });
    socket!.onDisconnect((_) {});
  }

  initInterstitialAd() {
    InterstitialAd.load(
        adUnitId: "ca-app-pub-3940256099942544/1033173712",
        request: AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(onAdLoaded: (ad) {
          interstitialAd = ad;
          interstitialAd.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {},
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
            },
            onAdDismissedFullScreenContent: (ad) {
              initInterstitialAd();
              ad.dispose();
            },
          );

          setState(() {
            displayAd = true;
          });
        }, onAdFailedToLoad: ((error) {
          interstitialAd.dispose();
        })));
  }

  initRewardInterstitialAd() {
    RewardedInterstitialAd.load(
        adUnitId: "ca-app-pub-3940256099942544/5354046379",
        request: AdRequest(),
        rewardedInterstitialAdLoadCallback:
            RewardedInterstitialAdLoadCallback(onAdLoaded: (ad) {
          rewardedInterstitialAd = ad;
          rewardedInterstitialAd.fullScreenContentCallback =
              FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {},
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
            },
            onAdDismissedFullScreenContent: (ad) {
              initRewardInterstitialAd();

              ad.dispose();
            },
          );
          setState(() {
            rewardAd = true;
          });
        }, onAdFailedToLoad: ((error) {
          print("~~~~ $error");
        })));
  }

  int _selectedIndex = 1;
  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = 1;
    });
    switch (index) {
      case 1:
        Navigator.pushNamed(context, Routes.earnRoute);
        break;
      case 2:
        Navigator.pushNamed(context, Routes.searchShareRoute);
        break;
      case 3:
        Navigator.pushNamed(context, Routes.shareRoute);
        break;
      case 4:
        Navigator.pushNamed(context, Routes.userRoute);
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 1;

    final double safeLevelAmount = levelAmount ?? 1;
    double progress = (balance ?? 0) / safeLevelAmount;
    progress = min(progress, 1.0);

    DateTime currentDate = DateTime.now();
    String formattedDate = DateFormat('MMMM d, yyyy').format(currentDate);

    return Scaffold(
      backgroundColor: Color(0xFFF5F7F9),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 15,
            right: 15,
            top: 35,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    text: TextSpan(
                      style: TextStyle(color: Colors.black, fontSize: 18.0),
                      children: <TextSpan>[
                        TextSpan(
                          text: 'Hello, ',
                          style: TextStyle(fontFamily: 'Inter', fontSize: 20),
                        ),
                        TextSpan(
                            text: fname != null ? fname.toString() : "User",
                            style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  CircleAvatar(
                    backgroundImage: image != null
                        ? NetworkImage(
                            'http://192.168.43.243:8000/api$image',
                          ) as ImageProvider<Object>
                        : const AssetImage('assets/uu.png')
                            as ImageProvider<Object>,
                    radius: 18,
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                  height: height * .25,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Color(0xFF1B1B1B),
                  ),
                  child: Stack(
                    children: [
                      Container(
                        height: height * .09,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Color(0xFFC7FF24),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Your Wallet",
                                  style: TextStyle(
                                      fontFamily: 'Inter',
                                      color: Color(0xFF171717),
                                      fontWeight: FontWeight.w900,
                                      fontSize: 16)),
                              Text("$formattedDate",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF171717),
                                      fontFamily: 'Inter',
                                      fontSize: 16))
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 15,
                        top: 115,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Total Balance",
                                style: TextStyle(
                                    fontFamily: 'Inter',
                                    color: Color(0xFFFFFFFF),
                                    fontSize: 20.0)),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                                '\$${balance != null ? balance.toString() : "0.00"}',
                                style: TextStyle(
                                    fontSize: 25,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      Positioned(
                          right: 5,
                          top: //130,
                              height * .16,
                          child: Image.asset("assets/by.png"))
                    ],
                  )),
              SizedBox(
                height: 20,
              ),
              Container(
                height: height * .155,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: <TextSpan>[
                            TextSpan(
                                text: (levels != null && levels! % 2 != 0)
                                    ? '\$${amount.toString()}'
                                    : '\$${rewards.toString()}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Inter',
                                  fontSize: 18,
                                  color: Color(0xFF171717),
                                )),
                            TextSpan(
                                text: '  per click',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  color: Color(0xFF171717),
                                  fontSize: 14,
                                )),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: <TextSpan>[
                                TextSpan(
                                    text: levels != null
                                        ? levels.toString()
                                        : '0',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF171717),
                                      fontFamily: 'Inter',
                                    )),
                                TextSpan(
                                    text: ' level',
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF171717),
                                        fontFamily: 'Inter')),
                              ],
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                              children: <TextSpan>[
                                TextSpan(
                                    text: nextLevels != null
                                        ? nextLevels.toString()
                                        : '0',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF171717),
                                      fontFamily: 'Inter',
                                    )),
                                TextSpan(
                                    text: ' level',
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF171717),
                                        fontFamily: 'Inter')),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          SizedBox(
                            height: 10,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: LinearProgressIndicator(
                                value: progress,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFFC7FF24)),
                                backgroundColor: Colors.black,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            '\$${balance?.toStringAsFixed(2) ?? '0.00'} / \$${levelAmount?.toStringAsFixed(2) ?? '0.00'}',
                            style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF171717),
                                fontFamily: 'Inter'),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              if (levels != null && levels! % 2 != 0)
                InkWell(
                  onTap: () {
                    setState(() {
                      increaseEarnings(1, 0);
                      if (balance! >= levelAmount!) {
                        if (displayAd) {
                          interstitialAd.show();
                        }
                      }
                      tapCount++;
                      if (tapCount == 10 && rewardAd) {
                        rewardedInterstitialAd.show(
                          onUserEarnedReward: (ad, reward) {
                            print(
                                "You Just Won ~~~~~~~~~~~~~~~~~ ${reward.amount}");
                            increaseEarnings(1, 10);
                          },
                        );

                        tapCount = 0;
                      }
                    });
                  },
                  borderRadius: BorderRadius.circular(15),
                  child: Ink(
                    height: height * .359,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/hdn.png",
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Text(
                          "Click in this area to Earn Money",
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF171717),
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (levels != null && levels! % 2 == 0)
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: height * .33,
                      child: FortuneWheel(
                        selected: selected.stream,
                        animateFirst: false,
                        items: [
                          for (int i = 0; i < items.length; i++)
                            FortuneItem(
                              child: Text(
                                items[i].toString(),
                                style: TextStyle(
                                    fontFamily: "Inter",
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                        ],
                        onAnimationEnd: () {
                          setState(() {
                            rewards = items[selected.value];
                            spinner(1, rewards);
                          });
                          print("????????????????????? $rewards");
                        },
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          selected.add(Fortune.randomInt(0, items.length));
                          if (balance! >= levelAmount!) {
                            if (displayAd) {
                              interstitialAd.show();
                            }
                          }
                        });
                      },
                      child: Container(
                        height: 50,
                        width: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: Center(
                          child: Image.asset("assets/si.png"),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onTabTapped: _onTabTapped,
      ),
    );
  }
}

class Global {
  static int myNumber = 0;
  static var shareData;
  static String flag = "false";
}

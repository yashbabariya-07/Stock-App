import 'package:flutter/material.dart';
import 'package:share_app/pages/bottomtab.dart';
import 'package:share_app/pages/earning.dart';
import 'package:share_app/routes/route.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class MyShare extends StatefulWidget {
  const MyShare({Key? key});

  @override
  State<MyShare> createState() => _MyShareState();
}

class _MyShareState extends State<MyShare> {
  IO.Socket? socket;
  String? utoken;
  double valueOfStock = 0.0;
  double changes = 0.0;
  double? balance;

  List myshares = [];

  @override
  void initState() {
    super.initState();
    connectAndListen();
    getData();
  }

  void getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');

    utoken = token;
    myShares();
    portfolio();
    print('usertoken~~~~~~~~~~~~!!!!!!!!!!!!~~~~~~~~~~~~~~~~~ $utoken');
  }

  void connectAndListen() {
    socket = IO.io('http://192.168.43.243:8000/', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket!.connect();

    socket!.onConnect((_) {
      print('Connected to Socket.IO server');
    });
  }

  void myShares() {
    socket?.emit('MY_STOCK_INFO', {"token": utoken});
    socket!.on('FETCH_MY_STOCK_INFO', (data) {
      setState(() {
        myshares = data;

        print(
            'My Share Orignal My Share -------------------------------------: $data');
      });
    });
    socket!.onDisconnect(
        (_) => print('Disconnected from Socket.IO server My Share'));
  }

  void portfolio() {
    socket?.emit('MY_STOCK_PORTFOLIO', {"token": utoken});
    print("~~~ utoken ~~~ $utoken");
    socket!.on('FETCH_MY_STOCK_PORTFOLIO', (data) {
      setState(() {
        valueOfStock = double.parse(data['valueOfStock'].toString());
        changes = double.parse(data['changes'].toString());

        print('Portfolio -------------------------------------: $data');
      });
    });
  }

  int _selectedIndex = 3;
  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = 3;
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
    return Scaffold(
      backgroundColor: Color(0xFFF5F7F9),
      appBar: AppBar(
        title: Text(
          "My Share List",
          style: TextStyle(
              color: Color(0xFF171717), fontSize: 18, fontFamily: 'inter'),
        ),
        leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Image.asset("assets/barrow.png")),
        centerTitle: true,
        backgroundColor: Color(0xFFF5F7F9),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 15, right: 15, top: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  height: 95,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Color(0xFF1B1B1B),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Your Portfolio",
                              style: TextStyle(
                                fontSize: 15,
                                fontFamily: 'Inter',
                                color: Color(0xFFFFFFFF),
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Row(
                              children: [
                                Text("\$${valueOfStock.toStringAsFixed(3)}",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontFamily: 'Inter',
                                        color: Color(0xFFFFFFFF),
                                        fontWeight: FontWeight.bold)),
                                SizedBox(
                                  width: 10,
                                ),
                                Row(
                                  children: [
                                    if (changes < 0)
                                      Image.asset("assets/downn.png"),
                                    if (changes >= 0)
                                      Image.asset("assets/upp.png"),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      changes >= 0
                                          ? "${changes.toStringAsFixed(2)}%"
                                          : "${(-changes).toStringAsFixed(2)}%",
                                      style: TextStyle(
                                          fontSize: 15,
                                          color: changes >= 0
                                              ? Color(0xFFC7FF24)
                                              : Color(0xFFFF5858),
                                          fontFamily: "Inter"),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                      Positioned(
                          right: 5,
                          top: 27,
                          child: Image.asset("assets/by.png"))
                    ],
                  )),
              SizedBox(
                height: 10,
              ),
              Text(
                "My Stocks",
                style: TextStyle(fontSize: 18, color: Color(0xFF171717)),
              ),
              SizedBox(
                height: 10,
              ),
              myshares.isNotEmpty
                  ? ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: myshares.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            Global.flag = "";
                            Global.flag = myshares[index]?['symbol'];
                            Navigator.pushNamed(
                              context,
                              Routes.shareInfoRoute,
                              arguments: {
                                'data1': myshares[index],
                                'source': 'myShare',
                              },
                            );
                          },
                          child: Container(
                            margin: EdgeInsets.only(bottom: 15),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white,
                            ),
                            child: ListTile(
                              title: Text(
                                myshares[index]['symbol'],
                                style: TextStyle(
                                  color: Color(0xFF171717),
                                  fontSize: 15,
                                  fontFamily: 'Inter',
                                ),
                              ),
                              subtitle: Text(
                                myshares[index]['name'],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Color(0xFF696969),
                                  fontSize: 13,
                                  fontFamily: 'Inter',
                                ),
                              ),
                              trailing: Container(
                                width: 140,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Image.asset(
                                          "assets/qt.png",
                                          height: 8.89,
                                          width: 8,
                                        ),
                                        Text(
                                          " ${myshares[index]['quantity'].toString()} Qty",
                                          style: TextStyle(
                                            color: Color(0xFF171717),
                                            fontSize: 10,
                                            fontFamily: 'Inter',
                                          ),
                                        )
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        myshares[index]['changesPercentage'] < 0
                                            ? Image.asset("assets/downn.png")
                                            : Image.asset("assets/upp.png"),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          '${myshares[index]['changesPercentage'].toStringAsFixed(2)}%',
                                          style: TextStyle(
                                              color: myshares[index][
                                                          'changesPercentage'] >=
                                                      0
                                                  ? Colors.green
                                                  : Color(0xFFFF5858),
                                              fontSize: 12,
                                              fontFamily: 'Inter'),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          '\$${myshares[index]['totalPrice'].toStringAsFixed(2)}',
                                          style: TextStyle(
                                            color: Color(0xFF1B1B1B),
                                            fontSize: 12,
                                            fontFamily: 'Inter',
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              leading: CircleAvatar(
                                backgroundColor: Colors.white,
                                child: Image.network(
                                  myshares[index]['logo'],
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset('assets/sm.png',
                                        fit: BoxFit.cover);
                                  },
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Container(
                        height: MediaQuery.of(context).size.height - 400,
                        child: Center(
                          child: SpinKitFadingCircle(
                            color: Colors.grey,
                          ),
                        ),
                      ),
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

  @override
  void dispose() {
    socket?.dispose();
    super.dispose();
  }
}

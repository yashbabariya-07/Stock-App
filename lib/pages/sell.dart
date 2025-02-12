import 'dart:async';
import 'dart:convert';
import 'package:share_app/pages/earning.dart';
import 'package:share_app/routes/route.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class SellPage extends StatefulWidget {
  const SellPage({super.key});

  @override
  State<SellPage> createState() => _SellPageState();
}

class _SellPageState extends State<SellPage> {
  String? uid;
  double? balance;
  String? utoken;
  IO.Socket? socket;
  String? sname;
  String? enteredValue;
  String? ShareName;
  double? summary = 0;
  Timer? _timer;
  List myshares = [];

  List<dynamic> stockInfo = [];

  @override
  void initState() {
    super.initState();
    getData();
    connectAndListen();
  }

  void getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');

    utoken = token;
    SharedPreferences prefss = await SharedPreferences.getInstance();
    String? uInfoString = prefss.getString('Uinfo');
    Map<String, dynamic> userInfo = jsonDecode(uInfoString!);
    String? userId = userInfo['id'].toString();

    uid = userId;
    connectAndListen();
    print('uid~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ $uid');
  }

  void connectAndListen() {
    socket = IO.io('http://192.168.43.243:8000/', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket!.connect();

    socket!.onConnect((_) {
      balanceData(0);
      print('Connected to Socket.IO server');
    });

    socket!.onDisconnect((_) => print('Disconnected from Socket.IO server'));
  }

  void balanceData(int type) {
    socket?.emit('ADD_AMOUNT_IN_WALLET',
        {"token": utoken, "boostStatus": 0, "status": type});
    socket!.on('FETCH_WALLET_DATA', (data) {
      print('Wallet data received: $data');

      setState(() {
        if (data['wallet'] != null &&
            data['wallet']['current_balance'] != null &&
            data['wallet']['current_balance'] != "") {
          balance = double.tryParse(data['wallet']['current_balance']);
          print("*********** $balance");
        }
      });
    });
  }

  void shareinfo() {
    _timer = Timer.periodic(Duration(minutes: 1), (Timer timer) {
      if (Global.flag == sname) {
        socket?.emit('SELL_STOCK_INFO', {"symbol": sname, "token": utoken});
      }
    });
    print("~~~ Symbol Name ~~~ $sname");
    socket!.on('FETCH_SELL_STOCK_INFO', (data) {
      setState(() {
        stockInfo = data;
      });
      print("############################ $data");
    });

    Future.delayed(Duration(milliseconds: 200), () {
      if (Global.flag == sname) {
        socket?.emit('SELL_STOCK_INFO', {"symbol": sname, "token": utoken});
        print("~~~ instance call sell stock socket ~~~");
      }
    });
  }

  void myShares() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('myShares');

    socket?.emit('MY_STOCK_INFO', {"token": utoken});
    socket!.on('FETCH_MY_STOCK_INFO', (data) {
      setState(() {
        myshares = data;

        SharedPreferences.getInstance().then((prefs) {
          var encodedList =
              myshares.map((e) => jsonEncode(e)).toList().cast<String>();
          prefs.setStringList('myShares', encodedList);
        });
      });
    });
    socket!.onDisconnect(
        (_) => print('Disconnected from Socket.IO server My Share'));
  }

  void sellShare() async {
    if (enteredValue != null && stockInfo.isNotEmpty) {
      double enteredQuantity = double.parse(enteredValue!);
      double totalQuantity = double.parse(stockInfo[0]['quantity'].toString());

      if (enteredQuantity <= totalQuantity) {
        var url = "http://192.168.43.243:8000/api/stock/sell";
        var data = {
          "user_id": uid,
          "symbol_name": sname,
          "share_full_name": ShareName,
          "share_quantity": enteredValue,
          "share_price": stockInfo[0]['price'].toString(),
        };

        var urlParse = Uri.parse(url);
        http.Response response = await http.post(
          body: data,
          urlParse,
        );

        var responseData = jsonDecode(response.body);
        print("Data: $responseData");

        Navigator.pushNamed(context, Routes.shareRoute);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            // behavior: SnackBarBehavior.floating,
            content: Text('Please check your available quantity.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
      myShares();
    }
  }

  String calculateSummary() {
    try {
      double quantity = double.parse(enteredValue ?? '0');
      double summary = (stockInfo.isNotEmpty &&
              stockInfo[0]['totalPrice'] != null &&
              stockInfo[0]['quantity'] != null)
          ? (double.parse(stockInfo[0]['totalPrice'].toString()) /
                  double.parse(stockInfo[0]['quantity'].toString())) *
              quantity
          : 0.0;
      return '\$${summary.toStringAsFixed(2)}';
    } catch (e) {
      print('Error calculating summary: $e');
      return '0.0';
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isKeyboardOpen = true;
    MediaQueryData mediaQuery = MediaQuery.of(context);
    isKeyboardOpen = mediaQuery.viewInsets.bottom > 0;

    final height = MediaQuery.of(context).size.height * 1;
    var routeArguments2 =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    var img = (routeArguments2)?['logo'];
    var name = (routeArguments2 as Map<String, dynamic>)['name'];
    ShareName = name;

    if (routeArguments2 != null && sname == null) {
      sname = routeArguments2['symbol'];

      shareinfo();
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Color(0xFFF5F7F9),
      body: Padding(
        padding:
            const EdgeInsets.only(left: 15, right: 15, top: 40, bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: isKeyboardOpen == true ? 7 : 11,
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Image.asset("assets/barrow.png"),
                      ),
                      Flexible(
                        flex: 1,
                        fit: FlexFit.tight,
                        child: SizedBox(),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.55,
                        child: Row(
                          children: [
                            Image.network(
                              img,
                              height: 20,
                              width: 20,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset('assets/sm.png',
                                    height: 20, width: 20, fit: BoxFit.cover);
                              },
                              fit: BoxFit.cover,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              sname.toString(),
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    height: height * .125,
                    //height: 95,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Color(0xFF1B1B1B),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name.toString(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15,
                              fontFamily: 'Inter',
                              color: Color(0xFFFFFFFF),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              stockInfo.isNotEmpty && stockInfo[0]['change'] < 0
                                  ? Image.asset("assets/downn.png")
                                  : Image.asset("assets/upp.png"),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                stockInfo.isNotEmpty
                                    ? stockInfo[0]['change'].toString()
                                    : '0.00',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontFamily: 'Inter',
                                  color: stockInfo.isNotEmpty &&
                                          stockInfo[0]['change'] >= 0
                                      ? Color(0xFFC7FF24)
                                      : Color(0xFFFF5858),
                                ),
                              )
                            ],
                          ),
                          Text(
                            stockInfo.isNotEmpty
                                ? '\$${stockInfo[0]['price'].toString()}'
                                : '0.00',
                            style: TextStyle(
                              fontSize: 15,
                              fontFamily: 'Inter',
                              color: Color(0xFFFFFFFF),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Center(
                    child: Text(
                      stockInfo.isNotEmpty
                          ? 'Available Qty ${stockInfo[0]['quantity']}'
                          : 'Available Qty 0.00',
                      style: TextStyle(
                        fontSize: 15,
                        fontFamily: 'Inter',
                        color: Color(0xFF1B1B1B),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Quantity",
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'Inter',
                          color: Color(0xFF1B1B1B),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 100),
                        child: TextFormField(
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          style: TextStyle(
                            fontSize: 30,
                            fontFamily: 'Inter',
                            color: Color(0xFF1B1B1B),
                          ),
                          onChanged: (value) {
                            setState(() {
                              enteredValue = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 80,
            ),
            Expanded(
              flex: isKeyboardOpen == true ? 2 : 2,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Wallet : \$${balance.toString()}",
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Inter',
                          color: Color(0xFF1B1B1B),
                        ),
                      ),
                      Text(
                        "Order Value : ${calculateSummary()}",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Inter',
                          color: Color(0xFF1B1B1B),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 27,
                  ),
                  GestureDetector(
                    onTap: () {
                      sellShare();
                    },
                    child: Container(
                      width: double.infinity,
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Color(0xFF1B1B1B),
                      ),
                      child: Center(
                        child: Text(
                          "Place Sell Order",
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
            ),
          ],
        ),
      ),
    );
  }
}

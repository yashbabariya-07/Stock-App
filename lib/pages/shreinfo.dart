import 'dart:async';
import 'package:flutter/material.dart';
import 'package:share_app/pages/earning.dart';
import 'package:share_app/routes/route.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:intl/intl.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ShareInfo extends StatefulWidget {
  const ShareInfo({super.key});

  @override
  State<ShareInfo> createState() => _ShareInfoState();
}

class _ShareInfoState extends State<ShareInfo> {
  IO.Socket? socket;
  String? sname;
  Timer? _timer;
  bool isCandleChart = false;

  List<dynamic> stockInfo = [];
  List<StockData> chart = [];
  List<CandleData> candle = [];
  double adjustedMin = 0;
  double adjustedMax = 0;
  late ZoomPanBehavior _zoomPanBehavior;

  @override
  void initState() {
    super.initState();
    connectAndListen();
    _zoomPanBehavior = ZoomPanBehavior(
        enablePinching: true,
        enableDoubleTapZooming: true,
        enablePanning: true,
        zoomMode: ZoomMode.x);
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

    socket!.onDisconnect((_) => print('Disconnected from Socket.IO server'));
  }

  void shareinfo() {
    _timer = Timer.periodic(Duration(minutes: 1), (Timer timer) {
      if (Global.flag == sname) {
        socket?.emit('STOCK_INFO', {"symbol": sname});
      }
    });
    print("~~~ Symbol Name ~~~ $sname");
    socket!.on('FETCH_STOCK_INFO', (data) {
      setState(() {
        stockInfo = data;
      });
      print("~~~ DATA  ~~~~~~~~~~~~~ $stockInfo");
    });

    _timer = Timer.periodic(Duration(minutes: 1), (Timer timer) {
      if (Global.flag == sname) {
        intra();
        print("~~~ ==== ~~~");
      }
    });

    //instance call intra socket
    Future.delayed(Duration(milliseconds: 200), () {
      if (Global.flag == sname) {
        intra();
        print("~~~ instance call intra socket ~~~");
      }
      print('Interval cleared');
    });

    Future.delayed(Duration(milliseconds: 200), () {
      if (Global.flag == sname) {
        socket?.emit('STOCK_INFO', {"symbol": sname});
        print("~~~ instance call Stock info socket ~~~");
      }
    });
  }

  void intra() {
    socket?.emit('INTRADAY_CHART_DATA', {"symbol": sname});

    socket!.on('FETCH_INTRADAY_CHART_DATA', (data) {
      List<StockData> parsedData = [];
      List<CandleData> candleData = [];
      for (var item in data) {
        DateTime date = DateTime.parse(item['date']);
        double open = double.parse(item['open'].toString());
        double low = double.parse(item['low'].toString());
        double high = double.parse(item['high'].toString());
        double close = double.parse(item['close'].toString());

        parsedData.add(StockData(date, open));
        candleData.add(CandleData(date, open, low, high, close));
      }
      setState(() {
        chart = parsedData;
        candle = candleData;
      });
    });
  }

  Widget buildDivider() {
    return Column(
      children: [
        SizedBox(
          height: 3,
        ),
        Container(
          width: double.infinity,
          height: 1,
          color: Color(0xFFDEDEDE),
        ),
        SizedBox(
          height: 3,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 1;

    var routeArguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    var datas = routeArguments?['data1'];
    var source = routeArguments?['source']?.toString();
    var img = datas?['logo'];

    print("&^&^^^^^^^^^^^&&&&&&&&&&&&&&&&^^^^^^^^^^^^^^& $img");
    var name = datas?['name'];
    var ssname = datas?['symbol'];

    bool isSearchShare = source == 'searchShare';
    bool isMyShare = source == 'myShare';

    print("```````````````````` $routeArguments");

    if (datas != null && sname == null) {
      sname = datas['symbol'];
      shareinfo();
    }

    return Scaffold(
      backgroundColor: Color(0xFFF5F7F9),
      body: SingleChildScrollView(
        child: Padding(
          padding:
              const EdgeInsets.only(left: 15, right: 15, top: 40, bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      // if (isSearchShare) {
                      //   Navigator.pushNamed(context, Routes.searchShareRoute);
                      // } else if (isMyShare) {
                      //   Navigator.pushNamed(context, Routes.shareRoute);
                      // }
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
                          height: 25,
                          width: 25,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset('assets/sm.png',
                                height: 25, width: 25, fit: BoxFit.cover);
                          },
                          fit: BoxFit.cover,
                        ),
                        SizedBox(width: 5),
                        Text(
                          ssname.toString(),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Inter',
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                height: height * .13,
                //height: 95,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Color(0xFF1B1B1B),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
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
                          stockInfo.isNotEmpty && stockInfo[0]['change'] <= 0
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
                height: 20,
              ),
              Container(
                  height: height * .35,
                  //height: 280,
                  width: double.infinity,
                  child: Stack(
                    children: [
                      if (!isCandleChart && chart.isNotEmpty)
                        SfCartesianChart(
                          primaryXAxis: DateTimeAxis(
                            dateFormat: DateFormat('HH:mm'),
                            edgeLabelPlacement: EdgeLabelPlacement.shift,
                            intervalType: DateTimeIntervalType.auto,
                          ),
                          primaryYAxis: NumericAxis(
                            interval: 2,
                            opposedPosition: true,
                          ),
                          series: <CartesianSeries<StockData, DateTime>>[
                            LineSeries<StockData, DateTime>(
                              dataSource: chart,
                              xValueMapper: (StockData sales, _) => sales.date,
                              yValueMapper: (StockData sales, _) => sales.open,
                            )
                          ],
                          tooltipBehavior: TooltipBehavior(
                            enable: true,
                            format: 'point.y : point.x',
                          ),
                          zoomPanBehavior: _zoomPanBehavior,
                        )
                      else if (isCandleChart && candle.isNotEmpty)
                        SfCartesianChart(
                          primaryXAxis: DateTimeAxis(
                            dateFormat: DateFormat('HH:mm'),
                            edgeLabelPlacement: EdgeLabelPlacement.shift,
                            intervalType: DateTimeIntervalType.auto,
                          ),
                          primaryYAxis: NumericAxis(
                            interval: 2,
                            opposedPosition: true,
                          ),
                          series: <CandleSeries<CandleData, DateTime>>[
                            CandleSeries<CandleData, DateTime>(
                              dataSource: candle,
                              xValueMapper: (CandleData sales, _) => sales.date,
                              lowValueMapper: (CandleData sales, _) =>
                                  sales.low,
                              highValueMapper: (CandleData sales, _) =>
                                  sales.high,
                              openValueMapper: (CandleData sales, _) =>
                                  sales.open,
                              closeValueMapper: (CandleData sales, _) =>
                                  sales.close,
                            )
                          ],
                          tooltipBehavior: TooltipBehavior(
                            enable: true,
                            format: 'point.open : point.x',
                          ),
                          zoomPanBehavior: _zoomPanBehavior,
                        )
                      else
                        Center(
                          child: SpinKitFadingCircle(
                            color: Colors.grey,
                          ),
                        ),
                      if (chart.isNotEmpty || candle.isNotEmpty)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 5,
                            ),
                            if (!isCandleChart)
                              IconButton(
                                  onPressed: () {
                                    setState(() {
                                      isCandleChart = true;
                                    });
                                  },
                                  icon: Image.asset(
                                    "assets/candle.png",
                                    height: 25,
                                    width: 25,
                                  )),
                            if (isCandleChart)
                              IconButton(
                                  onPressed: () {
                                    setState(() {
                                      isCandleChart = false;
                                    });
                                  },
                                  icon: Image.asset(
                                    "assets/lineG.png",
                                    height: 25,
                                    width: 25,
                                  )),
                          ],
                        ),
                    ],
                  )),
              SizedBox(
                height: 20,
              ),
              Container(
                height: height * .281,
                //height: 220,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Details",
                        style: TextStyle(
                            fontSize: 15,
                            fontFamily: 'Inter',
                            color: Color(0xFF020202),
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Open",
                            style: TextStyle(
                              fontSize: 15,
                              fontFamily: 'Inter',
                              color: Color(0xFF171717),
                            ),
                          ),
                          Text(
                            stockInfo.isNotEmpty
                                ? stockInfo[0]['open'].toString()
                                : '0.00',
                            style: TextStyle(
                              fontSize: 15,
                              fontFamily: 'Inter',
                              color: Color(0xFF171717),
                            ),
                          ),
                        ],
                      ),
                      buildDivider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "High",
                            style: TextStyle(
                              fontSize: 15,
                              fontFamily: 'Inter',
                              color: Color(0xFF171717),
                            ),
                          ),
                          Text(
                            stockInfo.isNotEmpty
                                ? stockInfo[0]['dayHigh'].toString()
                                : '0.00',
                            style: TextStyle(
                              fontSize: 15,
                              fontFamily: 'Inter',
                              color: Color(0xFF171717),
                            ),
                          ),
                        ],
                      ),
                      buildDivider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Low",
                            style: TextStyle(
                              fontSize: 15,
                              fontFamily: 'Inter',
                              color: Color(0xFF171717),
                            ),
                          ),
                          Text(
                            stockInfo.isNotEmpty
                                ? stockInfo[0]['dayLow'].toString()
                                : '0.00',
                            style: TextStyle(
                              fontSize: 15,
                              fontFamily: 'Inter',
                              color: Color(0xFF171717),
                            ),
                          ),
                        ],
                      ),
                      buildDivider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Year High",
                            style: TextStyle(
                              fontSize: 15,
                              fontFamily: 'Inter',
                              color: Color(0xFF171717),
                            ),
                          ),
                          Text(
                            stockInfo.isNotEmpty
                                ? stockInfo[0]['yearHigh'].toString()
                                : '0.00',
                            style: TextStyle(
                              fontSize: 15,
                              fontFamily: 'Inter',
                              color: Color(0xFF171717),
                            ),
                          ),
                        ],
                      ),
                      buildDivider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Year Low",
                            style: TextStyle(
                              fontSize: 15,
                              fontFamily: 'Inter',
                              color: Color(0xFF171717),
                            ),
                          ),
                          Text(
                            stockInfo.isNotEmpty
                                ? stockInfo[0]['yearLow'].toString()
                                : '0.00',
                            style: TextStyle(
                              fontSize: 15,
                              fontFamily: 'Inter',
                              color: Color(0xFF171717),
                            ),
                          ),
                        ],
                      ),
                      buildDivider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Company Capitalization",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15,
                              fontFamily: 'Inter',
                              color: Color(0xFF171717),
                            ),
                          ),
                          Text(
                            stockInfo.isNotEmpty
                                ? '\$${stockInfo[0]['marketCap'].toString()}'
                                : '0.00',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15,
                              fontFamily: 'Inter',
                              color: Color(0xFF171717),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              if (isSearchShare) ...[
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      Routes.buyRoute,
                      arguments: datas,
                    );
                  },
                  child: Container(
                    // height: height * .062,
                    height: 50,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Color(0xFFC7FF24)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Buy Share",
                          style: TextStyle(
                              color: Color(0xFF1B1B1B),
                              fontSize: 18,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          width: 3,
                        ),
                        Image.asset(
                          "assets/darrow.png",
                          height: 11.67,
                          width: 12.7,
                        )
                      ],
                    ),
                  ),
                ),
              ] else if (isMyShare) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          Routes.sellRoute,
                          arguments: datas,
                        );
                      },
                      child: Container(
                        height: height * .062,
                        // height: 50,
                        width: 155,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Color(0xFF1B1B1B)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Sell",
                              style: TextStyle(
                                  color: Color(0xFFFFFFFF),
                                  fontSize: 18,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              width: 3,
                            ),
                            Image.asset(
                              "assets/uarrow.png",
                              height: 11.67,
                              width: 12.7,
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          Routes.buyRoute,
                          arguments: datas,
                        );
                      },
                      child: Container(
                        height: height * .062,
                        //height: 50,
                        width: 155,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Color(0xFFC7FF24)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Buy More",
                              style: TextStyle(
                                  color: Color(0xFF1B1B1B),
                                  fontSize: 18,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              width: 3,
                            ),
                            Image.asset(
                              "assets/darrow.png",
                              height: 11.67,
                              width: 12.7,
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class StockData {
  final DateTime date;
  final double open;

  StockData(
    this.date,
    this.open,
  );
}

class CandleData {
  final DateTime date;
  final double open;
  final double low;
  final double high;
  final double close;

  CandleData(this.date, this.open, this.low, this.high, this.close);
}

import 'package:flutter/material.dart';
import 'package:share_app/pages/bottomtab.dart';
import 'package:share_app/pages/earning.dart';
import 'package:share_app/routes/route.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class SearchShare extends StatefulWidget {
  const SearchShare({super.key});

  @override
  State<SearchShare> createState() => _SearchShareState();
}

class _SearchShareState extends State<SearchShare> {
  String? utoken;
  IO.Socket? socket;
  String? shareName;
  double? price;
  String searchText = '';
  int? newValue;

  List shareData = [];

  @override
  void initState() {
    super.initState();

    getData();
  }

  void getData() async {
    var newdata = Global.shareData;
    if (newdata == null) {
      newValue = 0;
    } else {
      newValue = 1;
      shareData = Global.shareData
          .where((share) => share['exchange'] == 'New York Stock Exchange')
          .toList();
    }
  }

  int _selectedIndex = 2;
  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = 2;
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
    List filteredShares = [];
    if (searchText.isNotEmpty) {
      filteredShares = shareData
          .where((share) =>
              share['name'] != null &&
              share['name'].toLowerCase().contains(searchText.toLowerCase()))
          .toList();
    } else {
      filteredShares = List.from(shareData);
    }

    return Scaffold(
      backgroundColor: Color(0xFFF5F7F9),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xFFC7FF24),
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: Color(0xFFFFFFFF),
          ),
          child: TextFormField(
            decoration: InputDecoration(
              border: InputBorder.none,
              prefixIcon: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, Routes.earnRoute);
                },
                child: Image.asset(
                  "assets/barrow.png",
                ),
              ),
              hintText: "Search Stocks",
              hintStyle: TextStyle(
                fontSize: 15,
                color: Color(0xFFA7A7A7),
              ),
              contentPadding: EdgeInsets.all(11.5),
            ),
            onChanged: (value) {
              setState(() {
                searchText = value;
              });
            },
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.only(
          left: 18,
          right: 18,
          top: 15,
        ),
        child: newValue == 1
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "My Stocks",
                    style: TextStyle(fontSize: 18, color: Color(0xFF171717)),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Color(0xFFFFFFFF),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListView.builder(
                        itemCount: filteredShares.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              Global.flag = "";
                              Global.flag = filteredShares[index]?['symbol'];
                              Navigator.pushNamed(
                                context,
                                Routes.shareInfoRoute,
                                arguments: {
                                  'data1': filteredShares[index],
                                  'source': 'searchShare',
                                },
                              );
                            },
                            child: Container(
                              margin: EdgeInsets.only(bottom: 15),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.white,
                              ),
                              child: ListTile(
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      filteredShares[index]['name'],
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Color(0xFF171717),
                                      ),
                                    ),
                                    Text(
                                      filteredShares[index]['exchange'],
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF696969),
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '\$${filteredShares[index]['price'].toString()}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF1B1B1B),
                                      ),
                                    ),
                                    // Text(
                                    //   shareData[index].totalPercent,
                                    //   style: TextStyle(color: Colors.green),
                                    // ),
                                  ],
                                ),
                                leading: CircleAvatar(
                                  backgroundColor: Colors.white,
                                  child: Image.network(
                                    filteredShares[index]['logo'],
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
                      ),
                    ),
                  ),
                ],
              )
            : Center(
                child: SpinKitFadingCircle(
                color: Colors.grey,
              )),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onTabTapped: _onTabTapped,
      ),
    );
  }
}

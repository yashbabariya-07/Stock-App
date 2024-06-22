import 'dart:io';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:share_app/pages/bottomtab.dart';
import 'package:share_app/pages/loginpage.dart';
import 'package:share_app/routes/route.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  String? uid;
  String? utoken;
  String? fname;
  String? lastname;
  String? emailId;
  String? contact;
  String? dialCode;
  String? _selectedImagePath;
  String? image;
  String? updateImage;
  late BannerAd bannerAd;
  bool displayAd = false;

  var adUnitId = "ca-app-pub-3940256099942544/9214589741";

  @override
  void initState() {
    super.initState();
    localData();
    getData();
    initBannerAd();
  }

  void localData() async {
    SharedPreferences prefss = await SharedPreferences.getInstance();
    String? uInfoString = prefss.getString('userData');
    Map<String, dynamic> dataUser = jsonDecode(uInfoString!);

    print("%%%%%%%%%%%%%%% $dataUser");

    if (dataUser != null) {
      var images = dataUser['payload']['userInfo'][0]['userProfile'];
      print('Images: $images');
      image = images;

      var firstname = dataUser['payload']['userInfo'][0]['firstName'];
      print('Fname: $firstname');

      var lname = dataUser['payload']['userInfo'][0]['lastName'];
      print('Lname: $lname');
      lastname = lname;
      fname = firstname + ' ' + lname;

      var email = dataUser['payload']['userInfo'][0]['userEmail'];
      print('Email: $email');
      emailId = email;

      var code = dataUser['payload']['userInfo'][0]['dial_code'];
      print('Code: $code');

      var phone = dataUser['payload']['userInfo'][0]['userPhone'];
      print('Phone: $phone');
      contact = phone;
      dialCode = code + ' ' + phone;

      setState(() {
        firstnameController.text = fname ?? '';
        lastnameController.text = lastname ?? '';
        emailController.text = emailId ?? '';
        phoneController.text = contact ?? '';
        codeController.text = dialCode ?? '';
        image;
      });
    } else {
      userdata(uid);
    }
  }

  initBannerAd() {
    bannerAd = BannerAd(
        size: AdSize.banner,
        adUnitId: adUnitId,
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            setState(() {
              displayAd = true;
            });
          },
          onAdFailedToLoad: (ad, error) {
            ad.dispose();
            print("Faillllllllllllllld $error");
          },
        ),
        request: AdRequest());
    bannerAd.load();
  }

  void getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');
    print(token);
    utoken = token;
    print('usertoken $utoken');

    SharedPreferences Uinfo = await SharedPreferences.getInstance();
    String? uInfo = Uinfo.getString('Uinfo');
    print('userInformation=>> $uInfo');

    SharedPreferences prefss = await SharedPreferences.getInstance();
    String? uInfoString = prefss.getString('Uinfo');
    Map<String, dynamic> userInfo = jsonDecode(uInfoString!);
    String? userId = userInfo['id'].toString();
    print('User ID: $userId');
    uid = userId;
    print('uid $uid');
    userdata(uid);
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
    print('Fname: $firstname');

    var lname = dataUser['payload']['userInfo'][0]['lastName'];
    print('Lname: $lname');
    lastname = lname;
    fname = firstname + ' ' + lname;

    var email = dataUser['payload']['userInfo'][0]['userEmail'];
    print('Email: $email');
    emailId = email;

    var code = dataUser['payload']['userInfo'][0]['dial_code'];
    print('Code: $code');

    var phone = dataUser['payload']['userInfo'][0]['userPhone'];
    print('Phone: $phone');
    contact = phone;
    dialCode = code + ' ' + phone;

    var images = dataUser['payload']['userInfo'][0]['userProfile'];
    print('Images: $images');
    image = images;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('userData', jsonEncode(dataUser));

    setState(() {
      firstnameController.text = fname ?? '';
      lastnameController.text = lastname ?? '';
      emailController.text = emailId ?? '';
      phoneController.text = contact ?? '';
      codeController.text = dialCode ?? '';
      image;
    });
  }

  Future<void> _pickImageFromGallery() async {
    Navigator.pop(context, 'Cancel');
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _selectedImagePath = pickedImage.path;
        updateImage = _selectedImagePath;
        image = null;
        print(
            "Gallery --------------------------------------------------------- $_selectedImagePath");
      });
    }
  }

  Future<void> _captureImage() async {
    Navigator.pop(context, 'Cancel');
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.camera);
    if (pickedImage != null) {
      setState(() {
        _selectedImagePath = pickedImage.path;
        updateImage = _selectedImagePath;
        image = null;
        print("Camera $_selectedImagePath");
      });
    }
  }

  final _formKey = GlobalKey<FormState>();
  TextEditingController firstnameController = TextEditingController();
  TextEditingController lastnameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  TextEditingController codeController = TextEditingController();

  int _selectedIndex = 4;
  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = 4;
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

  void update() async {
    String fn = firstnameController.text;
    List<String> parts = fn.split(' ');
    String firstName = parts[0];
    String lastName = parts[1];

    String Mobile = codeController.text;

    List<String> part = Mobile.split(' ');
    String code = part[0];
    String phone = part[1];

    if (_formKey.currentState!.validate()) {
      var url = "http://192.168.43.243:8000/api/user/update?user_id=" + uid!;

      var request = http.MultipartRequest('PUT', Uri.parse(url));
      request.headers['x-auth-token'] = utoken!;
      request.fields['firstName'] = firstName;
      request.fields['lastName'] = lastName;
      request.fields['userEmail'] = emailController.text;
      request.fields['userPhone'] = phone;
      request.fields['dial_code'] = code;

      if (_selectedImagePath != null) {
        File imageFile = File(_selectedImagePath!);
        request.files.add(
          http.MultipartFile(
            'userProfile',
            imageFile.readAsBytes().asStream(),
            imageFile.lengthSync(),
            filename: 'profile.jpg',
          ),
        );
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        // Update local data with the new values
        SharedPreferences prefs = await SharedPreferences.getInstance();
        Map<String, dynamic> userData =
            jsonDecode(prefs.getString('userData') ?? '{}');

        userData['payload']['userInfo'][0]['firstName'] = firstName;
        userData['payload']['userInfo'][0]['lastName'] = lastName;
        userData['payload']['userInfo'][0]['userEmail'] = emailController.text;
        userData['payload']['userInfo'][0]['dial_code'] = code;
        userData['payload']['userInfo'][0]['userPhone'] = phone;

        prefs.setString('userData', jsonEncode(userData));

        showErrorSnackbar(context, "Update Info Successfully.");
      }
    }
  }

  void showErrorSnackbar(BuildContext context, String errorMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(errorMessage),
        duration: Duration(seconds: 4),
      ),
    );
  }

  void LogOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('token');

    SharedPreferences Uinfo = await SharedPreferences.getInstance();

    Uinfo.remove('Uinfo');

    // Navigator.pushNamed(context, Routes.loginRoute);

    Navigator.popUntil(context, ModalRoute.withName('/login'));
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 1;
    return Scaffold(
      backgroundColor: Color(0xFFf5f7f9),
      appBar: AppBar(
        backgroundColor: Color(0xFFf5f7f9),
        leading: GestureDetector(
            onTap: () {
              //Navigator.pushNamed(context, Routes.earnRoute);
              Navigator.pop(context);
            },
            child: Image.asset("assets/barrow.png")),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: GestureDetector(
              onTap: () {
                showMenu(
                  color: Color(0xFFFFFFFF),
                  context: context,
                  position: RelativeRect.fromLTRB(
                      MediaQuery.of(context).size.width - 20, 45, 17, 0),
                  items: [
                    PopupMenuItem(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, Routes.settingRoute);
                        },
                        child: Text(
                          'Change Password',
                          style: TextStyle(
                              fontSize: 15,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF171717)),
                        ),
                      ),
                      value: 'changePassword',
                    ),
                    PopupMenuItem(
                      child: GestureDetector(
                          onTap: () {
                            LogOut();
                          },
                          child: Text(
                            'Log Out',
                            style: TextStyle(
                                fontSize: 15,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF171717)),
                          )),
                      value: 'logOut',
                    ),
                  ],
                );
              },
              child: Icon(Icons.settings),
            ),
          )
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 0, left: 20, right: 20),
              child: Column(
                children: [
                  displayAd
                      ? SizedBox(
                          height: bannerAd.size.height.toDouble(),
                          width: bannerAd.size.width.toDouble(),
                          child: AdWidget(ad: bannerAd),
                        )
                      : SizedBox(),
                  SizedBox(
                    height: 40,
                  ),
                  Stack(
                    children: [
                      GestureDetector(
                        onTap: () {},
                        child: CircleAvatar(
                          radius: 65,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                              radius: 60,
                              backgroundImage: image != null
                                  ? NetworkImage(
                                      'http://192.168.43.243:8000/api$image',
                                    ) as ImageProvider<Object>
                                  : updateImage != null
                                      ? FileImage(File(updateImage!))
                                          as ImageProvider<Object>
                                      : const AssetImage('assets/uu.png')
                                          as ImageProvider<Object>),
                        ),
                      ),
                      Positioned(
                          right: 0,
                          bottom: 0,
                          child: GestureDetector(
                            onTap: () {
                              showDialog<String>(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                                  title: const Text('Select Image Options.'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () => _captureImage(),
                                      child: const Text('Camera'),
                                    ),
                                    TextButton(
                                      onPressed: () => _pickImageFromGallery(),
                                      child: const Text('Gallery'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFFf5f7f9),
                              ),
                              child: Icon(Icons.camera_enhance_outlined),
                            ),
                          ))
                    ],
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  Container(
                    height: height * .225,
                    //height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Color(0xFFFFFFFF),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 15),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            TextFormField(
                              controller: firstnameController,
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                  fontFamily: 'Inter',
                                  color: Color(0xFF171717)),
                              decoration: InputDecoration(
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.only(top: 13.0),
                                  child: Text(
                                    "Name",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontFamily: 'Inter',
                                        color: Color(0xFF171717)),
                                  ),
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.transparent),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your  name';
                                }
                                return null;
                              },
                            ),
                            TextFormField(
                              controller: emailController,
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                  fontFamily: 'Inter',
                                  color: Color(0xFF171717)),
                              decoration: InputDecoration(
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.only(top: 13.0),
                                  child: Text(
                                    "Email",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontFamily: 'Inter',
                                        color: Color(0xFF171717)),
                                  ),
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.transparent),
                                ),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                    .hasMatch(value)) {
                                  return 'Please enter a valid email format';
                                }
                                return null;
                              },
                            ),
                            TextFormField(
                              controller: codeController,
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                  fontFamily: 'Inter',
                                  color: Color(0xFF171717)),
                              decoration: InputDecoration(
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.only(top: 13.0),
                                  child: Text(
                                    "Phone ",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontFamily: 'Inter',
                                        color: Color(0xFF171717)),
                                  ),
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.transparent),
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your phone number';
                                }
                                if (value.length < 10) {
                                  return 'Enter valid phone number';
                                }

                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  GestureDetector(
                    onTap: () {
                      update();
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
                          "Update Changes",
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

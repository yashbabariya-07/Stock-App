import 'dart:convert';
import 'package:share_app/routes/route.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';

class ForgotPswd extends StatefulWidget {
  const ForgotPswd({super.key});

  @override
  State<ForgotPswd> createState() => _ForgotPswdState();
}

class _ForgotPswdState extends State<ForgotPswd> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _otpController = TextEditingController();
  TextEditingController newPswdController = TextEditingController();
  TextEditingController confirmPswdController = TextEditingController();
  String? uid;
  String? utoken;

  bool isVisible = false;
  bool isVisible2 = false;
  bool isVisible3 = false;
  bool isOtpVerified = false;

  void getData() async {
    SharedPreferences prefss = await SharedPreferences.getInstance();
    String? uInfoString = prefss.getString('Uinfo');
    Map<String, dynamic> userInfo = jsonDecode(uInfoString!);
    String? userId = userInfo['id'].toString();
    print('User ID~~~~~~~~~~~~~~~~~~~~~~~~~~: $userId');
    uid = userId;
    print('uid~~~~~~~~~~~~~~~~~~~~~~~~~ $uid');
  }

  void fPswd() async {
    var url = "http://192.168.43.243:8000/api/user/forgotPassword";
    var data = {
      "userEmail": _emailController.text,
    };

    print(data);

    var urlParse = Uri.parse(url);
    http.Response response = await http.post(
      body: data,
      urlParse,
    );

    var dataUser = jsonDecode(response.body);
    print(dataUser);
    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);

      if (responseData['success'] == true) {
        showErrorToast(context, "OTP Sent Successfully.");
      }
    }
  }

  void verifyOtp() async {
    var url = "http://192.168.43.243:8000/api/user/verifyOtp";
    var data = {
      "userEmail": _emailController.text,
      "otp": _otpController.text,
    };

    if (_emailController.text.isEmpty) {
      showErrorSnackbar(context, "Please enter your email");
      return;
    }

    print(data);

    var urlParse = Uri.parse(url);
    http.Response response = await http.post(
      body: data,
      urlParse,
    );

    var dataUser = jsonDecode(response.body);
    print(dataUser);

    if (dataUser['success'] == true) {
      setState(() {
        isOtpVerified = true;
      });
    } else {
      showErrorSnackbar(context, "Failed to verify otp.");
    }
  }

  void newPswd() async {
    var url = "http://192.168.43.243:8000/api/user/changePassword";
    var data = {
      "user_id": uid,
      "new_password": newPswdController.text,
      "confirm_password": confirmPswdController.text,
    };

    print(data);

    var urlParse = Uri.parse(url);
    http.Response response = await http.post(
      body: data,
      urlParse,
    );

    var dataUser = jsonDecode(response.body);
  }

  void showErrorSnackbar(BuildContext context, String errorMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(errorMessage),
        duration: Duration(seconds: 4),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  void showErrorToast(BuildContext context, String errorMessage) {
    Fluttertoast.showToast(
      msg: errorMessage,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.TOP,
      backgroundColor: Colors.black,
      textColor: Colors.white,
    );
  }

  late AnimationController _controllerCenter;
  late Animation<Offset> _animationCenter;
  late AnimationController _controllerContainer;
  late Animation<double> _animationContainer;

  @override
  void initState() {
    super.initState();
    getData();
    _controllerCenter = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _animationCenter = Tween<Offset>(
      begin: Offset(-1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controllerCenter,
      curve: Curves.easeInOut,
    ));

    _controllerContainer = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _animationContainer = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _controllerContainer,
      curve: Curves.easeInOut,
    ));

    _controllerCenter.forward().then((_) {
      _controllerContainer.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFf5f7f9),
      resizeToAvoidBottomInset: false,
      body: Form(
        key: _formKey,
        child: Stack(
          children: [
            Positioned(
              top: -40,
              left: -80,
              child: AnimatedBuilder(
                animation: _controllerContainer,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _animationContainer.value,
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
              right: -180,
              child: AnimatedBuilder(
                animation: _controllerContainer,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _animationContainer.value,
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
                animation: _controllerContainer,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _animationContainer.value,
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
                animation: _controllerContainer,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _animationContainer.value,
                    child: CircleAvatar(
                      radius: 100,
                      backgroundColor: Colors.blue,
                    ),
                  );
                },
              ),
            ),
            Positioned(
              bottom: -100,
              left: -40,
              child: AnimatedBuilder(
                animation: _controllerContainer,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _animationContainer.value,
                    child: CircleAvatar(
                      radius: 100,
                      backgroundColor: Colors.green,
                    ),
                  );
                },
              ),
            ),
            Positioned(
              left: 15,
              top: 50,
              child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, Routes.loginRoute);
                  },
                  child: Image.asset("assets/barrow.png")),
            ),
            SlideTransition(
              position: _animationCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Forgot Your Password??",
                        style: TextStyle(
                            fontSize: 20,
                            fontFamily: 'Inter',
                            color: Color(0xFF171717),
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        width: 350,
                        child: Text(
                          "Enter your email and we will send you a OTP to reset your password.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            fontFamily: 'Inter',
                            color: Color(0xFF171717),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      if (!isOtpVerified)
                        Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                  color: Color(0xFFf5f7f9),
                                  borderRadius: BorderRadius.circular(5)),
                              child: TextFormField(
                                controller: _emailController,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 3, horizontal: 15),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Color(0xFF171717), width: 1)),
                                  prefixIcon: Icon(
                                    Icons.email,
                                  ),
                                  hintText: "Email",
                                  hintStyle: TextStyle(
                                    fontSize: 15,
                                    fontFamily: 'Inter',
                                  ),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5)),
                                ),
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your email';
                                  }
                                  if (!RegExp(
                                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                      .hasMatch(value)) {
                                    return 'Please enter a valid email format';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            GestureDetector(
                              onTap: () {
                                fPswd();
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
                                    "Send OTP",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Color(0xFFFFFFFF),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 80,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  color: Color(0xFFf5f7f9),
                                  borderRadius: BorderRadius.circular(5)),
                              child: TextFormField(
                                controller: _otpController,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 3, horizontal: 15),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Color(0xFF171717), width: 1)),
                                  prefixIcon: Icon(
                                    Icons.phone,
                                  ),
                                  hintText: "Enter otp ",
                                  hintStyle: TextStyle(
                                    fontSize: 15,
                                    fontFamily: 'Inter',
                                  ),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5)),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your otp';
                                  }

                                  return null;
                                },
                              ),
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            GestureDetector(
                              onTap: () {
                                verifyOtp();
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
                                    "Verify OTP",
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
                      if (isOtpVerified)
                        Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                  color: Color(0xFFf5f7f9),
                                  borderRadius: BorderRadius.circular(5)),
                              child: TextFormField(
                                controller: newPswdController,
                                obscureText: !isVisible,
                                obscuringCharacter: '*',
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 3, horizontal: 15),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Color(0xFF171717), width: 1)),
                                  prefixIcon: Icon(
                                    Icons.lock,
                                  ),
                                  hintText: "New Password",
                                  hintStyle: TextStyle(
                                    fontSize: 15,
                                    fontFamily: 'Inter',
                                  ),
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        isVisible = !isVisible;
                                      });
                                    },
                                    icon: Icon(isVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your password';
                                  }
                                  if (value.length < 6) {
                                    return 'Password must be at least 6 characters';
                                  }
                                  if (!RegExp(
                                          r'^(?=.*?[a-zA-Z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{6,}$')
                                      .hasMatch(value)) {
                                    return 'Use mix symbol,letter and digits ';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  color: Color(0xFFf5f7f9),
                                  borderRadius: BorderRadius.circular(5)),
                              child: TextFormField(
                                controller: confirmPswdController,
                                obscureText: !isVisible2,
                                obscuringCharacter: '*',
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 3, horizontal: 15),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Color(0xFF171717), width: 1)),
                                  prefixIcon: Icon(
                                    Icons.lock,
                                  ),
                                  hintText: "Confirm Your Password",
                                  hintStyle: TextStyle(
                                    fontSize: 15,
                                    fontFamily: 'Inter',
                                  ),
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        isVisible2 = !isVisible2;
                                      });
                                    },
                                    icon: Icon(isVisible2
                                        ? Icons.visibility
                                        : Icons.visibility_off),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your password';
                                  }
                                  if (value.length < 6) {
                                    return 'Password must be at least 6 characters';
                                  }
                                  if (!RegExp(
                                          r'^(?=.*?[a-zA-Z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{6,}$')
                                      .hasMatch(value)) {
                                    return 'Use mix symbol,letter and digits ';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            GestureDetector(
                              onTap: () {
                                if (newPswdController.text ==
                                    confirmPswdController.text) {
                                  newPswd();
                                } else {
                                  showErrorSnackbar(context,
                                      "Passwords do not match. Please try again.");
                                }
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
                                    "Change Password",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Color(0xFFFFFFFF),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                    ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

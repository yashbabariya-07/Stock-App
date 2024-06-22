import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:share_app/routes/route.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void loginUser() async {
    if (_formKey.currentState!.validate()) {
      var url = "http://192.168.43.243:8000/api/user/login";
      var data = {
        "userEmail": _emailController.text,
        "password": _passwordController.text,
      };

      var urlParse = Uri.parse(url);
      http.Response response = await http.post(
        body: data,
        urlParse,
      );

      var responseData = jsonDecode(response.body);
      print("datauser $responseData");

      if (responseData['success'] == true) {
        final String token = responseData['payload']['Token'];

        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('token', token);

        final Map<String, dynamic> userInfo =
            responseData['payload']['userInfo'];

        SharedPreferences Uinfo = await SharedPreferences.getInstance();
        String jsonString = jsonEncode(userInfo);
        Uinfo.setString('Uinfo', jsonString);

        Navigator.pushNamed(context, Routes.earnRoute);
      } else {
        showErrorSnackbar(
            context, "Invalid credentials. Please check your data");
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

  bool isVisible = false;

  late AnimationController _controllerSto;
  late Animation<Offset> _animationSto;

  late AnimationController _controllerCenter;
  late Animation<Offset> _animationCenter;

  late AnimationController _controllerG;
  late Animation<Offset> _animationG;

  late AnimationController _controllerContainer;
  late Animation<double> _animationContainer;

  @override
  void initState() {
    super.initState();

    _controllerSto = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );
    _animationSto = Tween<Offset>(
      begin: Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controllerSto,
      curve: Curves.easeInOut,
    ));
    _controllerSto.forward();

    _controllerCenter = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _animationCenter = Tween<Offset>(
      begin: Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controllerCenter,
      curve: Curves.easeInOut,
    ));

    _controllerG = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );

    _animationG = Tween<Offset>(
      begin: Offset(0, 6),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controllerG,
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

    _controllerSto.forward().then((_) {
      _controllerCenter.forward().then((_) {
        _controllerG.forward().then((_) {
          _controllerContainer.forward();
        });
      });
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
              top: 80,
              left: 80,
              child: SlideTransition(
                position: _animationSto,
                child: Image.asset(
                  "assets/sml.png",
                  height: 200,
                ),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                child: SlideTransition(
                  position: _animationCenter,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 150,
                        ),
                        Text(
                          "LogIn",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontSize: 30,
                              fontFamily: 'Inter',
                              color: Color(0xFF171717),
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "Enter your credentials to login",
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontSize: 15,
                            fontFamily: 'Inter',
                            color: Color(0xFF171717),
                          ),
                        ),
                        SizedBox(height: 50),
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
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                  .hasMatch(value)) {
                                return 'Please enter a valid email format';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(height: 15),
                        Container(
                          decoration: BoxDecoration(
                              color: Color(0xFFf5f7f9),
                              borderRadius: BorderRadius.circular(5)),
                          child: TextFormField(
                            controller: _passwordController,
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
                              hintText: "Password",
                              hintStyle: TextStyle(
                                fontSize: 15,
                                fontFamily: 'Inter',
                              ),
                              suffixIcon: IconButton(
                                color: Colors.black,
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
                                  borderRadius: BorderRadius.circular(5)),
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
                                return 'Use mix symbol, letter, and digits';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(
                          height: 2,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(
                                    context, Routes.forgotPswdRoute);
                              },
                              child: Text(
                                "Forgot Password?",
                                style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF171717)),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 40),
                        GestureDetector(
                          onTap: () {
                            loginUser();
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
                                "LOG IN",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Color(0xFFFFFFFF),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        SlideTransition(
                          position: _animationG,
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Don't have an account?",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontFamily: 'Inter',
                                      color: Color(0xFF171717),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pushNamed(
                                          context, Routes.signRoute);
                                    },
                                    child: Text(
                                      "Sign Up",
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontFamily: 'Inter',
                                          color: Color(0xFF171717),
                                          fontWeight: FontWeight.bold),
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

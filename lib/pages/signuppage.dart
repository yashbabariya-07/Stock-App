import 'dart:convert';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:share_app/routes/route.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  String? _selectedImagePath;

  TextEditingController firstnameController = TextEditingController();
  TextEditingController lastnameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController codeController = TextEditingController();

  void signUser() async {
    if (_formKey.currentState!.validate()) {
      var url = "http://192.168.43.243:8000/api/user/signup";
      var request = http.MultipartRequest('POST', Uri.parse(url));

      request.fields['firstName'] = firstnameController.text;
      request.fields['lastName'] = lastnameController.text;
      request.fields['userEmail'] = emailController.text;
      request.fields['userPhone'] = phoneController.text;
      request.fields['dial_code'] = codeController.text;
      request.fields['password'] = passwordController.text;

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

      var response = await request.send();

      var responseString = await response.stream.bytesToString();
      var dataUser = jsonDecode(responseString);
      print('dataUser =>> $dataUser');

      Navigator.pushNamed(context, Routes.loginRoute);
    }
  }

  Future<void> _pickImageFromGallery() async {
    Navigator.pop(context, 'Cancel');
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _selectedImagePath = pickedImage.path;
        print("Image ---- $_selectedImagePath");

        final String fileName = pickedImage.path.split('/').last;
        print(
            'Original File Name:================================== $fileName');
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
      });
    }
  }

  bool isVisible = false;

  late AnimationController _controller;
  late Animation<Offset> _animation;

  late AnimationController _controllerC;
  late Animation<Offset> _animationC;

  late AnimationController _controllerT;
  late Animation<Offset> _animationT;

  late AnimationController _controllerG;
  late Animation<Offset> _animationG;

  late AnimationController _controllerContainer;
  late Animation<double> _animationContainer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );

    _animation = Tween<Offset>(
      begin: Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controllerC = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );

    _animationC = Tween<Offset>(
      begin: Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controllerC,
      curve: Curves.easeInOut,
    ));

    _controllerT = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );

    _animationT = Tween<Offset>(
      begin: Offset(-2, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controllerT,
      curve: Curves.easeInOut,
    ));

    _controllerG = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );

    _animationG = Tween<Offset>(
      begin: Offset(0, 1),
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

    _controller.forward().then((_) {
      _controllerC.forward().then((_) {
        _controllerT.forward().then((_) {
          _controllerG.forward().then((_) {
            _controllerContainer.forward();
          });
        });
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _controllerC.dispose();
    _controllerT.dispose();
    _controllerG.dispose();
    _controllerContainer.dispose();
    super.dispose();
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
            Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: 60, left: 20, right: 20, bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SlideTransition(
                        position: _animation,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "SignUP",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  fontSize: 35,
                                  fontFamily: 'Inter',
                                  color: Color(0xFF171717),
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "create your account",
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontSize: 20,
                                fontFamily: 'Inter',
                                color: Color(0xFF171717),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      SlideTransition(
                        position: _animationC,
                        child: Center(
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
                            child: CircleAvatar(
                              radius: 63,
                              backgroundColor: Colors.white,
                              child: CircleAvatar(
                                radius: 60,
                                backgroundImage: _selectedImagePath != null
                                    ? FileImage(File(_selectedImagePath!))
                                        as ImageProvider<Object>
                                    : const AssetImage('assets/ccp.png')
                                        as ImageProvider<Object>,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      SlideTransition(
                        position: _animationT,
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                  color: Color(0xFFf5f7f9),
                                  borderRadius: BorderRadius.circular(5)),
                              child: TextFormField(
                                controller: firstnameController,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 3, horizontal: 15),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Color(0xFF171717), width: 1)),
                                  prefixIcon: Icon(
                                    Icons.person,
                                  ),
                                  hintText: "First Name",
                                  hintStyle: TextStyle(
                                    fontSize: 15,
                                    fontFamily: 'Inter',
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your first name';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  color: Color(0xFFf5f7f9),
                                  borderRadius: BorderRadius.circular(5)),
                              child: TextFormField(
                                controller: lastnameController,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 3, horizontal: 15),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Color(0xFF171717), width: 1)),
                                  prefixIcon: Icon(
                                    Icons.person,
                                  ),
                                  hintText: "Last Name",
                                  hintStyle: TextStyle(
                                    fontSize: 15,
                                    fontFamily: 'Inter',
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your last name';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  color: Color(0xFFf5f7f9),
                                  borderRadius: BorderRadius.circular(5)),
                              child: TextFormField(
                                controller: emailController,
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
                                    borderRadius: BorderRadius.circular(5),
                                  ),
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
                              height: 15,
                            ),
                            Row(
                              children: [
                                Flexible(
                                  flex: 3,
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Color(0xFFf5f7f9),
                                        borderRadius: BorderRadius.circular(5)),
                                    child: TextFormField(
                                      controller: codeController,
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 3, horizontal: 15),
                                        focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Color(0xFF171717),
                                                width: 1)),
                                        prefixIcon: Icon(
                                          Icons.call,
                                        ),
                                        hintText: "Dial Code",
                                        hintStyle: TextStyle(
                                          fontSize: 15,
                                          fontFamily: 'Inter',
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                      ),
                                      keyboardType: TextInputType.number,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter your country code';
                                        }
                                        if (!RegExp(r'^[0-9+]+$')
                                            .hasMatch(value)) {
                                          return 'Invalid country code';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Flexible(
                                  flex: 4,
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Color(0xFFf5f7f9),
                                        borderRadius: BorderRadius.circular(5)),
                                    child: TextFormField(
                                      controller: phoneController,
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 3, horizontal: 15),
                                        focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Color(0xFF171717),
                                                width: 1)),
                                        hintText: "Phone No.",
                                        hintStyle: TextStyle(
                                          fontSize: 15,
                                          fontFamily: 'Inter',
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                      ),
                                      keyboardType: TextInputType.number,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter your phone number';
                                        }
                                        if (value.length < 10 ||
                                            value.length > 10) {
                                          return 'Enter valid phone number';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  color: Color(0xFFf5f7f9),
                                  borderRadius: BorderRadius.circular(5)),
                              child: TextFormField(
                                controller: passwordController,
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
                              height: 50,
                            ),
                            GestureDetector(
                              onTap: () {
                                signUser();
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
                                    "SIGN UP",
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Color(0xFFFFFFFF),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      SlideTransition(
                        position: _animationG,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Already have an account?",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontFamily: 'Inter',
                                    color: Color(0xFF171717),
                                  ),
                                ),
                                TextButton(
                                    onPressed: () {
                                      Navigator.pushNamed(
                                          context, Routes.loginRoute);
                                    },
                                    child: Text(
                                      "LogIn",
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontFamily: 'Inter',
                                          color: Color(0xFF171717),
                                          fontWeight: FontWeight.bold),
                                    ))
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
          ],
        ),
      ),
    );
  }
}

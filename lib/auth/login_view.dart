import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ode2code/auth/register_view.dart';
import 'package:ode2code/auth/state.dart';
import 'package:ode2code/dashboard/view.dart';
import 'package:ode2code/utils.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({Key? key}) : super(key: key);

  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final _key = GlobalKey<FormState>();
  final LoginButton _obj = Get.put(LoginButton());

  void login() {
    if (_obj.loading.value) return;
    _obj.loading.value = true;

    FirebaseAuth.instance
        .signInWithEmailAndPassword(
            email: _email.text, password: _password.text)
        .then((value) {
      _obj.loading.value = false;
      Get.offAll(() =>const Dashboard());
    }).catchError((e) {
      Get.snackbar("Error", e.message,
          //  "Unable to login, Please try again later..",
          icon: const Icon(Icons.error));
      _obj.loading.value = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      bottomSheet: Container(
        color: Colors.transparent,
        height: size.height * 0.1,
        width: double.maxFinite,
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                  color: Colors.black,
                  boxShadow: const [
                    BoxShadow(color: Colors.grey, blurRadius: 10),
                  ],
                  borderRadius: BorderRadius.circular(20)),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
                child: Obx(
                  () => MaterialButton(
                    color: Colors.orange[800],
                    padding: const EdgeInsets.all(10),
                    height: size.height*0.07,
                    onPressed: () async {
                      (_key.currentState!.validate())
                          ? login()
                          : Timer(const Duration(seconds: 2), () {
                              _key.currentState!.reset();
                            });
                    },
                    child: (_obj.loading.value)
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : Text("Login",
                            style: boldtextsyle(
                                size: size.height * 0.021,
                                shadow: true,
                                color: Colors.white)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      // backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
              child: Text("Lets Sign you in.",
                  // textAlign: TextAlign.center,
                  style: boldtextsyle(
                      size: size.height * 0.044,
                      color: Colors.black,
                      shadow: true)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
              child: Text("Welcome Back.\nYou've been missed!",
                  // textAlign: TextAlign.center,
                  style: mediumtextsyle(
                      size: size.height * 0.032, color: Colors.black)),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _key,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 10),
                    TextFormField(
                      validator: (text) {
                        if (text == null || text.isEmpty || !text.isEmail) {
                          return 'Enter Valid Email!';
                        }
                        return null;
                      },
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                          // label: Text("Email"),
                          prefixIcon: Icon(
                            Icons.email,
                            color: Colors.grey[700],
                          ),
                          hintText: "abcd@gmail.com",
                          border: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey,
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                          hintStyle: normaltextsyle(
                            size: 16,
                            color: Colors.grey[700],
                          )
                          // prefixIcon: Icon(Icons.email)
                          ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      validator: (text) {
                        if (text == null || text.isEmpty) {
                          return 'Enter Password';
                        }
                        return null;
                      },
                      controller: _password,
                      keyboardType: TextInputType.text,
                      obscureText: true,
                      obscuringCharacter: '*',
                      decoration: InputDecoration(
                          // label: Text("Email"),
                          prefixIcon: Icon(
                            Icons.vpn_key,
                            color: Colors.grey[700],
                          ),
                          hintText: "**********",
                          border: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey,
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                          hintStyle: normaltextsyle(
                            size: 16,
                            color: Colors.grey[700],
                          )
                          // prefixIcon: Icon(Icons.email)
                          ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an Account?",
                    style: boldtextsyle(size: 15),
                  ),
                  const SizedBox(
                    width: 7,
                  ),
                  MaterialButton(
                    color: Colors.black,
                    padding: const EdgeInsets.all(10),
                    shape: const StadiumBorder(),
                    onPressed: () async {
                      Get.to(() => RegisterScreen());
                    },
                    child: Text("SignUp!",
                        style: boldtextsyle(
                            size: 12, shadow: true, color: Colors.white)),
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

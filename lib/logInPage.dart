
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify.dart';
import 'package:amplify_analytics_pinpoint/amplify_analytics_pinpoint.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:testapp/amplifyconfiguration.dart';
import 'package:testapp/languages.dart';
import 'package:testapp/webView.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:image_picker/image_picker.dart';



class LogInPage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ThisLogInPage();
  }

}

class ThisLogInPage extends State<LogInPage> {

  /// Vars *******************************

  String appName = "TestApp";
  bool loading =true;
  bool signInLoading =false;
  double _phoneHeight;
  double _phoneWidth;
  Color backgroundColor= Colors.white;
  Color appBarBackColor = Colors.indigo.withOpacity(0.2);
  Color appBarTxtColor = Colors.white;
  String widgetSwitcher ="SignIn";
  bool showPassword= false;
  bool showConfigCodeWidget= false;
  bool showResetPWCodeWidget= false;

  bool loginState= false;
  String signInError="";
  String signUpError="";
  String resetWMsg="";
  String url ='https://images.pexels.com/photos/462118/pexels-photo-462118.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500';

  String myEmail="";
  TextEditingController nameTextController = TextEditingController();
  TextEditingController emailTextController = TextEditingController();
  TextEditingController passwordTextController = TextEditingController();
  TextEditingController confirmPWTextController = TextEditingController();
  TextEditingController configCodeTextController = TextEditingController();

  bool amplifyConfigured =false;

  //File image;
  final picker = ImagePicker();

  String lng = "En";
  bool showLanguageWidget=true;

  /// Functions *******************************

  Future<bool> readFromLocal()async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    /// if first time connection u see language widget else u ll not see it
    showLanguageWidget = !prefs.containsKey("language");
    lng = prefs.getString("language") ?? "En";
    url = prefs.getString("profilePicture") ?? "https://images.pexels.com/photos/462118/pexels-photo-462118.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500";

    setState(() {});
    return true;
  }

  saveToLocal()async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("language", lng);
    prefs.setString("profilePicture", url);
    readFromLocal();

  }

  void configureAmplify() async {
    if (!mounted) return;

    if(!amplifyConfigured){
      // Add Pinpoint and Cognito Plugins
      Amplify.addPlugin(AmplifyAnalyticsPinpoint());
      Amplify.addPlugin(AmplifyAuthCognito());

      try {
        await Amplify.configure(amplifyconfig);
      } on AmplifyAlreadyConfiguredException {
        print("Amplify was already configured. Was the app restarted?");
      }catch(ee){
        print("Amplify was already configured. Was the app restarted? 2");
      }

      try {
        setState(() {
          amplifyConfigured = true;
        });
      } catch (e) {
        print(e);
      }
    }

    try {
      final user = await Amplify.Auth.getCurrentUser();
      print("user id is  :: ${user.userId}");
      setState(() {
        myEmail= user.username;
        loginState=true;
        loading=false;
      });
    }catch(err){
      print("configureAmplify Error :: $err");
      setState(() {
        loginState=false;
        loading=false;
      });
    }

  }




  signInFunction()async{
    FocusScope.of(context).unfocus();
    setState(() {
      signInError="";
      signInLoading=true;
    });

    if (emailTextController.text.length>5 && !emailTextController.text.contains(" ") && emailTextController.text.contains("@") && passwordTextController.text.length>6) {
      try {
        await Amplify.Auth.signIn(username: emailTextController.text, password: passwordTextController.text).then((value) async{

          try {
            final user = await Amplify.Auth.getCurrentUser();

            setState(() {
              emailTextController.text="";
              passwordTextController.text="";
              loginState=true;
            });
          }catch(err){
            print("signInFunction Error  :: $err");
          }

        }).then((value) {
          setState(() {
            signInLoading=false;
          });
        });
      }catch(er){

        setState(() {
          signInError=LanguagesPages().getWord("Incorrect Email or Password", lng);
          loginState=false;
          signInLoading=false;
        });
      }
    }else{
      setState(() {
        signInError=LanguagesPages().getWord("Incorrect Email or Password", lng);
        loginState=false;
        signInLoading=false;
      });
    }
    
  }

  signUpFunction() async{

    FocusScope.of(context).unfocus();
    if (emailTextController.text.length>5 && !emailTextController.text.contains(" ") && emailTextController.text.contains("@") && passwordTextController.text.length>6 && confirmPWTextController.text==passwordTextController.text) {
      setState(() {
        signUpError="";
        signInLoading=true;
      });

      try {
        final CognitoSignUpOptions options = CognitoSignUpOptions(userAttributes: {LanguagesPages().getWord('email', lng): emailTextController.text});
        await Amplify.Auth.signUp(username: emailTextController.text, password: passwordTextController.text, options: options).then((value) {

          setState(() {
            showConfigCodeWidget=true;
            signUpError="";
            signInLoading=false;
          });
        });
      }catch(err){
        setState(() {
          signUpError=LanguagesPages().getWord("Incorrect Email or Password", lng);
          showConfigCodeWidget=false;
          signInLoading=false;
        });
      }
    }else{

      if(emailTextController.text.length<5 || emailTextController.text.contains(" ") || !emailTextController.text.contains("@")){
        setState(() {
          signUpError=LanguagesPages().getWord("Incorrect Email address", lng);
        });
      }else if (confirmPWTextController.text!=passwordTextController.text) {
        setState(() {
          signUpError=LanguagesPages().getWord("Password do not match", lng);
        });
      }else if(passwordTextController.text.length<=6){
        setState(() {
          signUpError=LanguagesPages().getWord("Password length min 7 character", lng);
        });
      }else {
        setState(() {
          signUpError=LanguagesPages().getWord("Unknown Error", lng);
        });
      }
    }
  }

  forgotPWFunction() async{
    FocusScope.of(context).unfocus();
    try {
      ResetPasswordResult res = await Amplify.Auth.resetPassword(username: emailTextController.text);

      setState(() {
        var isPasswordReset = res.isPasswordReset;
        showResetPWCodeWidget=true;
      });

    }catch(er){
      print("Error 214 :: $er");
    }
    setState(() {
      resetWMsg =LanguagesPages().getWord("Check your email address, and follow the link to reset your password", lng);
    });
  }

  resetPasswordFunction()async {
    try {
      await Amplify.Auth.confirmPassword(username: emailTextController.text, newPassword: passwordTextController.text, confirmationCode: configCodeTextController.text).then((value) {
        setState(() {
          resetVariables();
          widgetSwitcher=LanguagesPages().getWord('SignIn', lng);
          //showResetPWCodeWidget=false;
        });
      });
    }catch(er){
      print("Error 231 : $er");
    }
  }


  confirmCodeFunction()async{
    try {
      await Amplify.Auth.confirmSignUp(username: emailTextController.text, confirmationCode: configCodeTextController.text).then((value) {
        setState(() {
          showConfigCodeWidget=false;
        });
      });
    }catch(er){
      print("Error 244 : $er");
    }
  }


  signOut()async{
    await Amplify.Auth.signOut().then((value) {
      setState(() {
        loginState=false;
      });
    });
  }


  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        //image = File(pickedFile.path);
        url=pickedFile.path;
        saveToLocal();
        print('path of image selected. is : ${pickedFile.path}');
      } else {
        print('No image selected.');
      }
    });
  }

  resetVariables(){
    setState(() {
      emailTextController.clear();
      passwordTextController.clear();
      confirmPWTextController.clear();
      configCodeTextController.clear();
      signUpError="";
      signInError="";
      showPassword=false;
      showConfigCodeWidget=false;
      signInLoading=false;
      showResetPWCodeWidget=false;
    });
  }

  /// Widgets *******************************

  Widget emailWidget(){
    return Container(
      padding: EdgeInsets.only(left: 15, right: 15, bottom: 2),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(15)),
          color: Colors.grey.withOpacity(0.1),
          border: Border.all(
            width: 1,
            color: Colors.orangeAccent,
          )
      ),

      child: TextFormField(
        decoration: InputDecoration(
          icon: Icon(Icons.email),
          hintText: LanguagesPages().getWord('Email Address', lng),
        ),
        controller: emailTextController,

      ),
    );
  }

  Widget passwordWidget(){
    return Container(
      child: Stack(
        children: [
          Container(
            padding: EdgeInsets.only(left: 15, right: 35, bottom: 2),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(15)),
                color: Colors.grey.withOpacity(0.1),
                border: Border.all(
                  width: 1,
                  color: Colors.orangeAccent,
                )
            ),

            child: TextFormField(
              obscureText: !showPassword,
              obscuringCharacter: "*",
              decoration: InputDecoration(
                icon: Icon(Icons.vpn_key),
                hintText: LanguagesPages().getWord('Password', lng),
              ),
              controller: passwordTextController,

            ),
      ),

          Positioned(
            top: 0, right: 10, bottom: 0,
            child: InkWell(
              onTap: (){
                setState(() {
                  showPassword=!showPassword;
                });
              },
              child: Icon(showPassword ? Icons.remove_red_eye : Icons.remove_red_eye_outlined),
            ),
          ),
        ],
      ),
    );
  }

  Widget confirmPWWidget(){
    return Container(
      child: Stack(
        children: [
          Container(
            padding: EdgeInsets.only(left: 15, right: 35, bottom: 2),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(15)),
                color: Colors.grey.withOpacity(0.1),
                border: Border.all(
                  width: 1,
                  color: Colors.orangeAccent,
                )
            ),

            child: TextFormField(
              obscureText: !showPassword,
              obscuringCharacter: "*",
              decoration: InputDecoration(
                icon: Icon(Icons.vpn_key),
                hintText: LanguagesPages().getWord('Confirm Password', lng),
              ),
              controller: confirmPWTextController,

            ),
          ),

          Positioned(
            top: 0, right: 10, bottom: 0,
            child: InkWell(
              onTap: (){
                setState(() {
                  showPassword=!showPassword;
                });
              },
              child: Icon(showPassword ? Icons.remove_red_eye : Icons.remove_red_eye_outlined),
            ),
          ),
        ],
      ),
    );
  }


  Widget signInWidget() {
    return Container(
      height: 400, width: 300,
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(20)),
        border: Border.all(
          width: 1,
          color: Colors.orangeAccent,
        )

      ),
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [

              emailWidget(),

              passwordWidget(),

              Container(
                height: 150,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [

                    Text(signInError, style: TextStyle(color: Colors.red),),
                    /// login button
                    InkWell(
                      onTap: (){
                        signInFunction();
                      },

                      child: Container(
                        height: 40, width: 90,
                        padding: EdgeInsets.only(left: 15, right: 15, bottom: 2),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            color: Colors.blue.withOpacity(0.4),
                            border: Border.all(
                              width: 2,
                              color: Colors.orangeAccent,
                            )
                        ),

                        child: Center(child: Text(LanguagesPages().getWord("Sing In", lng)),),
                      ),
                    ),

                    /// SignUp button
                    InkWell(
                      onTap: (){
                        resetVariables();
                        setState(() {
                          widgetSwitcher ="SignUp";
                        });
                      },

                      child: Container(
                        height: 30, width: 90,


                        child: Center(child: Text(LanguagesPages().getWord("Sign Up", lng)),),
                      ),
                    ),

                    /// Forgot PW Button
                    InkWell(
                      onTap: (){
                        resetVariables();
                        setState(() {
                          widgetSwitcher ="ForgotPW";
                        });
                      },

                      child: Container(
                        height: 30, width: 140,
                        child: Center(child: Text(LanguagesPages().getWord("Forgot Password", lng)),),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          signInLoading
              ?
          Positioned(
            top: 0, bottom: 0, right: 0, left: 0,
            child: Container(
              color:  Colors.grey.withOpacity(0.5),
              child: Center(child: CircularProgressIndicator(),),
            ),
          ) : Container(),
        ],
      ),
    );
  }


  Widget signUpWidget() {
    return Container(
      height: 460, width: 300,
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(20)),
          border: Border.all(
            width: 1,
            color: Colors.orangeAccent,
          )

      ),
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [


              emailWidget(),

              passwordWidget(),


              Container(
                child: Stack(
                  children: [
                    Container(
                      padding: EdgeInsets.only(left: 15, right: 35, bottom: 2),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          color: Colors.grey.withOpacity(0.1),
                          border: Border.all(
                            width: 1,
                            color: Colors.orangeAccent,
                          )
                      ),

                      child: TextFormField(
                        obscureText: !showPassword,
                        obscuringCharacter: "*",
                        decoration: InputDecoration(
                          icon: Icon(Icons.vpn_key),
                          hintText: LanguagesPages().getWord('Password', lng),
                        ),
                        controller: confirmPWTextController,

                      ),
                    ),

                    Positioned(
                      top: 0, right: 10, bottom: 0,
                      child: InkWell(
                        onTap: (){
                          setState(() {
                            showPassword=!showPassword;
                          });
                          },
                        child: Icon(showPassword ? Icons.remove_red_eye : Icons.remove_red_eye_outlined),
                      ),
                    ),
                  ],
                ),
              ),


              Text(signUpError, style: TextStyle(color: Colors.red),),

              Container(
                height: 150,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    /// Sign Up button
                    InkWell(
                      onTap: (){

                        setState(() {
                          signUpError="";
                        });
                        signUpFunction();
                      },

                      child: Container(
                        height: 40, width: 90,
                        padding: EdgeInsets.only(left: 15, right: 15, bottom: 2),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            color: Colors.blue.withOpacity(0.4),
                            border: Border.all(
                              width: 2,
                              color: Colors.orangeAccent,
                            )
                        ),

                        child: Center(child: Text(LanguagesPages().getWord("Sign Up", lng)),),
                      ),
                    ),

                    /// SignIn button
                    InkWell(
                      onTap: (){
                        resetVariables();
                        setState(() {
                          widgetSwitcher ="SignIn";
                        });
                      },

                      child: Container(
                        height: 30, width: 90,


                        child: Center(child: Text(LanguagesPages().getWord("Sign In", lng)),),
                      ),
                    ),

                    /// Forgot PW Button
                    InkWell(
                      onTap: (){
                        resetVariables();
                        setState(() {
                          widgetSwitcher ="ForgotPW";
                        });
                      },

                      child: Container(
                        height: 30, width: 140,
                        child: Center(child: Text(LanguagesPages().getWord("Forgot Password", lng)),),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),


          signInLoading
              ?
          Positioned(
            top: 0, bottom: 0, right: 0, left: 0,
            child: Container(
              color:  Colors.grey.withOpacity(0.5),
              child: Center(child: CircularProgressIndicator(),),
            ),
          ) : Container(),

          showConfigCodeWidget ?
          Positioned(
            top: 0, bottom: 0, left: 0, right: 0,
              child: confirmCodeWidget(),
          ): Container(),
        ],
      ),
    );
  }


  Widget forgotPWWidget() {
    return Container(
      height: 400, width: 300,
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(20)),
          border: Border.all(
            width: 1,
            color: Colors.orangeAccent,
          )

      ),
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [

              emailWidget(),

              resetWMsg!=""
                  ?
              Text(resetWMsg, textAlign: TextAlign.center,)
                  :
              Container(),

              Container(
                height: 150,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    /// Reset PassWord button
                    InkWell(
                      onTap: (){
                        forgotPWFunction();

                      },

                      child: Container(
                        height: 40, width: 140,
                        padding: EdgeInsets.only(left: 15, right: 15, bottom: 2),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            color: Colors.blue.withOpacity(0.4),
                            border: Border.all(
                              width: 2,
                              color: Colors.orangeAccent,
                            )
                        ),

                        child: Center(child: Text(LanguagesPages().getWord("Reset PassWord", lng)),),
                      ),
                    ),

                    /// SignIn button
                    InkWell(
                      onTap: (){
                        resetVariables();
                        setState(() {
                          widgetSwitcher ="SignIn";
                        });
                      },

                      child: Container(
                        height: 30, width: 90,


                        child: Center(child: Text(LanguagesPages().getWord("Sign In", lng)),),
                      ),
                    ),

                    /// SignUp Button
                    InkWell(
                      onTap: (){
                        resetVariables();
                        setState(() {
                          widgetSwitcher ="SignUp";
                        });
                      },

                      child: Container(
                        height: 30, width: 140,
                        child: Center(child: Text(LanguagesPages().getWord("Sign Up", lng)),),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          showResetPWCodeWidget
              ?
          Positioned(
            top: 0, bottom: 0, right: 0, left: 0,
              child: Container(
                color: Colors.grey.withOpacity(0.4),
                child: Container(
                  margin: EdgeInsets.all(30),
                  padding: EdgeInsets.only(left: 10, right: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                  ),
                  child: Stack(
                    children: [
                      Column(
                        children: [

                          Container(
                            height: 45,
                            margin: EdgeInsets.only(top: 40),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.3),
                              borderRadius: BorderRadius.all(Radius.circular(15)),
                            ),
                            child: passwordWidget(),
                          ),

                          Container(
                            height: 45,
                            margin: EdgeInsets.only(top: 30),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.3),
                              borderRadius: BorderRadius.all(Radius.circular(15)),
                            ),
                            child: confirmPWWidget(),
                          ),

                          Container(
                            margin: EdgeInsets.only(top: 30),
                            height: 40, width: 100,
                            color: Colors.white,
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: LanguagesPages().getWord('Code', lng),
                              ),
                              controller: configCodeTextController,
                            ),
                          ),


                          InkWell(
                            onTap: (){
                              resetPasswordFunction();
                            },

                            child: Container(
                              margin: EdgeInsets.only(top: 30),
                              height: 40, width: 100,
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.all(Radius.circular(10)),
                              ),
                              child: Center(child: Text(LanguagesPages().getWord("Validate", lng)),),
                            ),
                          ),
                        ],
                      ),

                      Positioned(
                        top: 0, right: 0,
                          child: InkWell(
                            onTap: (){
                              resetVariables();
                            },

                            child: Icon(Icons.cancel),
                          ),
                      ),
                    ],
                  ),
                )
              ),
          ) :Container(),
        ],
      ),
    );
  }

  Widget confirmCodeWidget(){
    return Container(
      height: 100, width: 100, color: Colors.grey.withOpacity(0.6),
      child: Center(
        child: Container(
          height: 150, width: 200,color: Colors.cyanAccent,
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      height: 40, width: 100,
                      color: Colors.white,
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: LanguagesPages().getWord('Code', lng),
                        ),
                        controller: configCodeTextController,
                      ),
                    ),
                    InkWell(
                      onTap: (){
                        if (configCodeTextController.text.length>3) {
                          confirmCodeFunction();
                        }

                      },

                      child: Container(
                        height: 40, width: 80,
                        color: Colors.blue,
                        child: Center(child: Text(LanguagesPages().getWord("Validate", lng)),),
                      ),
                    ),
                  ],
                ),
              ),
              
              Positioned(
                top: 0, right: 0,
                  child: InkWell(
                    onTap: (){
                      setState(() {
                        showConfigCodeWidget=false;
                      });
                    },
                    child: Icon(Icons.cancel),
                  ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget profile(){
    return Container(
      margin: EdgeInsets.only(left: 10, right: 10, top: 10),
      child: Center(
          child: ListView(
            children: [
              Container(
                  height: 40,
                  color: Colors.blue,
                  margin: EdgeInsets.only(bottom: 10),
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: Row(
                    mainAxisAlignment: lng=="Ar" ? MainAxisAlignment.end : MainAxisAlignment.start,
                    children: [
                      Text(LanguagesPages().getWord("Profile Picture", lng), style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),),
                    ],
                  )
              ),
              Container(
                  height: 160, width: _phoneWidth,
                  color: Colors.blue,
                child: Stack(
                  children: [
                    Container(
                      height: 160, width: _phoneWidth,
                      child: Image(
                        image: url.contains("https://") || url.contains("http://") ? NetworkImage(url,) : FileImage(File(url)), fit: BoxFit.fill,
                      ),
                    ),

                    Positioned(
                      bottom: 10, right: 10,
                        child: InkWell(
                          onTap: (){
                            getImage();
                          },
                          child: Container(
                            height: 30, width: 30,
                            decoration: BoxDecoration(
                              color: Colors.cyanAccent,
                              borderRadius: BorderRadius.all(Radius.circular(40)),
                            ),
                            child: Center(child: Icon(Icons.edit, color: Colors.grey,),),
                          )
                        )
                    ),


                  ],
                ),
              ),

              Container(
                  height: 40,
                  color: Colors.blue,
                  margin: EdgeInsets.only(top: 10),
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: Row(
                    textDirection: lng=="Ar" ? TextDirection.rtl :TextDirection.ltr,
                    children: [
                      Text("${LanguagesPages().getWord("Email", lng)}", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),),
                      Text(" : ", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),),
                      Text(" $myEmail", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),),
                    ],
                  )
              ),

              InkWell(
                onTap: (){
                  /*setState(() {
                    showWebView=true;
                  });*/
                  Navigator.push(context, MaterialPageRoute(
                    builder: (BuildContext context) => WebViewPage(logInState: loginState,),
                  ));
                },

                child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.7),
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    margin: EdgeInsets.only(bottom: 10, top: 60,left: 20, right: 20),
                    child: Center(child: Text(LanguagesPages().getWord("Visit the Website", lng), style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),),),
                ),
              ),


            ],
          )
      ),
    );
  }

  Widget languageWidget(){
    return Container(
      //height: 100, //width: 100,
      color: Colors.cyanAccent.withOpacity(0.5),
      child: Center(
        child: Container(
          height: 280, width: _phoneWidth-40,
          //color: Colors.cyan,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [

              Container(
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: lng=="Ar" ? Colors.blue[100] : Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(10)),

                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Radio(value: "Ar", groupValue: lng, onChanged: (_){setState(() {lng="Ar";});}),
                    Text(' العربية ',style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20,),),
                    Container(
                      height: 40, width: 60,
                      decoration: BoxDecoration(
                          image: DecorationImage(image: AssetImage("lib/images/arabic.png"), fit: BoxFit.fill)
                      ),
                    )
                  ],
                ),
              ),

              Container(
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: lng=="En" ? Colors.blue[100] : Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(10)),

                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Radio(value: "En", groupValue: lng, onChanged: (_){setState(() {lng="En";});}),
                    Text('English',style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20,),),
                    Container(
                      height: 40, width: 60,
                      decoration: BoxDecoration(
                          image: DecorationImage(image: AssetImage("lib/images/england.png"), fit: BoxFit.fill)
                      ),
                    )
                  ],
                ),
              ),

              Container(
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: lng=="Fr" ? Colors.blue[100] : Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(10)),

                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Radio(value: "Fr", groupValue: lng, onChanged: (_){setState(() {lng="Fr";});}),
                    Text('Français',style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20,),),
                    Container(
                      height: 40, width: 60,
                      decoration: BoxDecoration(
                          image: DecorationImage(image: AssetImage("lib/images/french.png"), fit: BoxFit.fill)
                      ),
                    )
                  ],
                ),
              ),

              InkWell(
                onTap: (){
                  saveToLocal();
                },

                child: Container(
                  margin: EdgeInsets.only(top: 30),
                  height: 40, width: 80,
                  color: Colors.blue,
                  child: Center(child: Text(LanguagesPages().getWord("Validate", lng), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),),

                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

  Widget switcher(){
    switch(widgetSwitcher){
      case "SignIn":
        return signInWidget();
        break;
      case "SignUp":
        return signUpWidget();
        break;
      case "ForgotPW":
        return forgotPWWidget();
        break;

      default:
        return signInWidget();
    }
    return Container();
  }


  @override
  void initState() {

    super.initState();
    // TODO: implement initState
    readFromLocal().then((value) {
      configureAmplify();
    });


  }

  @override
  Widget build(BuildContext context) {

    _phoneHeight = MediaQuery.of(context).size.height;
    _phoneWidth = MediaQuery.of(context).size.width;
    
    // TODO: implement build
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: appBarBackColor,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(appName,style: TextStyle(color: appBarTxtColor),),

           Row(
             children: [

               Container(
                 margin: EdgeInsets.only(right: 20),
                 child: InkWell(
                   onTap: (){
                     setState(() {
                       showLanguageWidget=true;
                     });
                   },
                   child: Text(lng),
                 ),
               ),

               loginState ?
               InkWell(
                 onTap: (){
                   signOut();
                 },

                 child: Icon(Icons.logout),
               ) : Container(),
             ],
           ),
          ],
        ),
      ),

      body:
      loading ? Center(child: CircularProgressIndicator(),) :
          showLanguageWidget ? languageWidget() :
          loginState
              ?
          profile()
              :
          Container(
        margin: EdgeInsets.only(left: 10, right: 10),
        child: Center(
          child: ListView(
            children: [
              Container(
                height: (_phoneHeight -460)> 0 ? (_phoneHeight -460)/3 : 10,
              ),
              switcher(),
            ],
          )
        ),
      ),
    );
  }


}
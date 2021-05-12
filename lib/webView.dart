import 'package:flutter/material.dart';
import 'package:testapp/logInPage.dart';
import 'package:webview_flutter/webview_flutter.dart';


class WebViewPage extends StatelessWidget{

  final bool logInState;

  const WebViewPage({Key key, this.logInState}) : super(key: key);

  final String url = "https://saloneverywhere.com/sample-profiles";

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
      backgroundColor: ThisLogInPage().appBarBackColor,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(ThisLogInPage().appName,style: TextStyle(color: ThisLogInPage().appBarTxtColor),),

          logInState ?
          InkWell(
            onTap: (){
              ThisLogInPage().signOut();
              Navigator.pushReplacement(context, MaterialPageRoute(
                builder: (BuildContext context) => LogInPage(),
              ));
            },

            child: Icon(Icons.logout,),
          ) : Container(),
        ],
      ),
    ),

      body: WebView(initialUrl: url,javascriptMode: JavascriptMode.unrestricted,),
    );
  }

}
import 'package:flutter/material.dart';
import 'package:ritlibrary/login.dart';

class About extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
      return MaterialApp(
         theme: ThemeData(primaryColor: Colors.orange[400],),
        title: 'About Us',
        home: AboutBody(),
      );
  }
}
class AboutBody extends StatefulWidget{
  @override
  State createState() {
    return AboutBodyState();
  }
}
class AboutBodyState extends State<AboutBody>{
  static var value;

  @override
  Widget build(BuildContext context) {
   return Scaffold(
     drawer: DrawerWidget(context),
    appBar: AppBar(actions: [],title:Text("About us"),),
    body:Container(
      width: double.infinity,
      padding: EdgeInsets.all(2),
      margin: EdgeInsets.all(2),
      child: Text("$value"),),
   );
  }
}
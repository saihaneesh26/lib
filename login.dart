// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:firebase_database/ui/firebase_animated_list.dart';
// import 'package:firebase_storage/firebase_storage.dart';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'main.dart';
import 'upload.dart';
import 'request.dart';
// ignore: non_constant_identifier_names
Widget DrawerWidget(BuildContext context)
{
  Map returnArea = {'QP':MyApp('QP'),'books':MyApp('books'),'Upload':Upload(),'Request':Request()};
  var list = ['QP','books','Request','Upload'];
  var icon = [Icons.question_answer,Icons.book,Icons.request_page_rounded,Icons.upload];
  return Container(
        child:Drawer(
          child: Container(
            child:Column(children: [
              
             Container(
                padding: EdgeInsets.symmetric(vertical:20).add(EdgeInsets.fromLTRB(15, 18, 2, 1)),
                child: Column(children: [
                  Row(children: [
                     Container(
                      padding: EdgeInsets.all(1),
                      margin: EdgeInsets.all(1),
                      width: 50,
                      height: 50,
                      child: Image.asset('assets/icon.png'),
                      ),SizedBox(width: 5,),
                    Text("ISE LIBRARY",overflow: TextOverflow.clip,maxLines: 1,style: TextStyle(fontSize: 35),),
                    
                  ]),
                 Text('welcome '+HomeState.USN.toString()+' '+HomeState.Name,overflow: TextOverflow.clip,maxLines: 2,style: TextStyle(fontSize: 15),),
                ],),
                width: double.infinity,
              //  height: 10,
                color: Colors.orange[400],
              ),
              Expanded(child: ListView.builder(
                itemCount: list.length,
                itemBuilder: (context,index){
                  return GestureDetector(
                    child: Container(child:Row(children: [
                      Icon(icon[index],color: Colors.orange[400],),
                      SizedBox(width: 5,),
                      Text(list[index],style: TextStyle(fontSize: 24),),

                    ],),padding: EdgeInsets.all(7),
                    margin: EdgeInsets.all(2),
                    decoration: BoxDecoration(border: Border.all(width: 1)),
                    ),
                    onTap: ()async{
                    //  print("pressed ${list[index]}");

                      if(list[index]=='Upload')
                      {
                            Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
                            var i =await _prefs;
                            var islogin = i.getBool('login');
                            islogin==true?Navigator.push(context, MaterialPageRoute(builder: (context)=>Upload())):Navigator.push(context, MaterialPageRoute(builder: (context)=>Login()));
                      }
                      // sideval=list[index];
                      // sideval=='new_files'||sideval=='books'?
                     Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>returnArea[list[index].toString()]));
                      // Navigator.push(context, MaterialPageRoute(builder: (context)=>Login()));
                    },
                  );
                },
              ),
              ),
              HomeState.main_update?TextButton(onPressed: ()async{
                print(HomeState.url.toString());
                await canLaunch(HomeState.url)?launch(HomeState.url):throw 'error something is wrong';
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('something is wrong')));
              }, child: Row(children: [
                Icon(Icons.update),
                Text("Update Available ${HomeState.updateval}")]
                )
                ):Text(""),
            ],),
          ),
        ),
      );
}


class Login extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
  appBar: AppBar(actions: [] ,title: Text('Login'),),
drawer: DrawerWidget(context),
body: LoginBody(),
    );
  }
}

class LoginBody extends StatefulWidget{
  LoginBodyState createState()=> LoginBodyState();
}

class LoginBodyState extends State<LoginBody>{

  bool Isloading = false;
  TextEditingController c1 = new TextEditingController();
  TextEditingController c2 = new TextEditingController();
  bool pass_visible=false;

  Widget build(context)
  {
    return Isloading?Center(child: CircularProgressIndicator(),):Container(
      child: Column(children: [
        Container(
          child: TextField(
            decoration: InputDecoration(labelText: 'USN',hintText: '1MS.......'),
            autofocus: true,
            style: TextStyle(fontSize: 20),
            controller: c1,
            maxLength: 10,
            ),
          padding: EdgeInsets.all(5),
          margin: EdgeInsets.all(2),
        //   decoration: BoxDecoration(border: Border.all(width: 2,color: Colors.blue)),
        ),
        SizedBox(height: 10,),
        Container(
          child: TextField(
            obscureText: !pass_visible,
            decoration: InputDecoration(labelText: 'Password',suffixIcon: IconButton(icon: pass_visible?Icon(Icons.visibility_off):Icon(Icons.visibility),onPressed: (){
            setState(() {
                pass_visible = !pass_visible;
            });
            },)
            ),
            style: TextStyle(fontSize: 20),
            controller: c2,
            ),
          padding: EdgeInsets.all(5),
          margin: EdgeInsets.all(2),
   // decoration: BoxDecoration(border: Border.all(width:2,color: Colors.blue)),
        ),
        SizedBox(height: 20,),
        Container(child:Center(child: 
        ElevatedButton(child: Text('Login'),onPressed: ()async{
            setState(() {
              Isloading=true;
            });
            await FirebaseDatabase.instance.reference().child('Users').once().then((snapshot)async {
            var i = snapshot.value;
            var j = snapshot.value.keys;
            for (var item in j) {
              Map profile = i[item];
              
              if(c1.text.toUpperCase().toString() == profile['Usn'].toString() && c2.text ==  profile['password'].toString())
              {
                var s=await FirebaseAuth.instance.signInAnonymously();
               // print("done");
               setState(() {
                 HomeState.Islogin=true;
                 HomeState.USN = profile['Usn'];
                 HomeState.Name = profile['name'];
               }); 
                Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
                            var i =await _prefs;
                            var islogin = i.setBool('login',true);
                            var USN = i.setString('USN', profile['Usn'].toString());
                            i.setString('Name', profile['name']);
                       
               setState(() {
                 Isloading= false;
               });
               
                HomeState.Islogin==true?Navigator.push(context, MaterialPageRoute(builder: (context)=>Upload())):Navigator.push(context, MaterialPageRoute(builder: (context)=>Login()));
                break;
              }
            }
            setState(() {
              Isloading=false;
            });
            HomeState.Islogin?Text(""):ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("wrong credentials")));
          });
        },)
        ,)),
      ],),
    );
  }
}
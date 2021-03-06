// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:firebase_database/ui/firebase_animated_list.dart';
// import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'main.dart';
import 'upload.dart';
import 'request.dart';
import 'About.dart';
// ignore: non_constant_identifier_names
Widget DrawerWidget(BuildContext context)
{
  if(HomeState.mm!='off')
  {
    return Container();
  }
  
  Map returnArea = {'QP':MyApp('QP'),'Lab':MyApp('Lab'),'Upload':Upload(),'Request':Request(),'About us':About()};
  var list = ['QP','Lab','Request','Upload','About us'];
  var icon = [Icons.question_answer,Icons.book,Icons.request_page_rounded,Icons.upload,Icons.person];
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
                 Text(HomeState.USN.toString()!=''&&HomeState.Name.toString()!=''?'welcome '+HomeState.USN.toString()+' '+HomeState.Name:'',overflow: TextOverflow.clip,maxLines: 2,style: TextStyle(fontSize: 15),),
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
              Container(
                padding: EdgeInsets.all(3),
                margin: EdgeInsets.all(2),
                width:double.infinity,
                height:20,
                child:(Row(children: [
                Icon(Icons.build_circle_sharp),
                 SizedBox(width: 5,),
                Text("Version: "+HomeState.version.toString()),
              ],
              )
              ),
              ),
              HomeState.main_update?TextButton(onPressed: ()async{
                print(HomeState.url.toString());
                await canLaunch(HomeState.url)?launch(HomeState.url):throw 'error something is wrong';
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('something is wrong')));
              }, child: Row(children: [
                Icon(Icons.update_outlined),
                SizedBox(width: 5,),
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
                try{
                var s=await FirebaseAuth.instance.signInWithEmailAndPassword(email: profile['Usn'].toString().toLowerCase()+"@gmail.com", password: profile['password'].toString());
               }catch(e){
                 UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                        email: profile['Usn'].toString().toLowerCase()+"@gmail.com",
                        password:c2.text
                    );
                var s=await FirebaseAuth.instance.signInWithEmailAndPassword(email: profile['Usn'].toString().toLowerCase()+"@gmail.com", password: profile['password'].toString());  
                 print('new user created');
               }// print("done");
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
               
                HomeState.Islogin==true?Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Upload())):Navigator.push(context, MaterialPageRoute(builder: (context)=>Login()));
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
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:firebase_database/ui/firebase_animated_list.dart';
// import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'main.dart';
import 'upload.dart';

// ignore: non_constant_identifier_names
Widget DrawerWidget(BuildContext context)
{
  Map returnArea = {'QP':MyApp('QP'),'books':MyApp('books'),'Upload':Upload(),'rate_us':MyApp('QP')};
  var list = ['QP','books','rate us','Upload'];
  var icon = [Icons.question_answer,Icons.book,Icons.rate_review,Icons.upload];
  return Container(
        child:Drawer(
          child: Container(
            child: Column(children: [
              Container(
                padding: EdgeInsets.symmetric(vertical:20).add(EdgeInsets.fromLTRB(15, 18, 2, 1)),
                child:Text("RIT-LIBRARY",style: TextStyle(fontSize: 50),),
                width: double.infinity,
                height: 140,
                color: Colors.blue[400],
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
                    onTap: (){
                      print("pressed ${list[index]}");
                      // sideval=list[index];
                      // sideval=='new_files'||sideval=='books'?
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>returnArea[list[index].toString()]));
                      // Navigator.push(context, MaterialPageRoute(builder: (context)=>Login()));
                    },
                  );
                },
              ),)
            ],),
          ),
        ),
        );
}


class Login extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
appBar: AppBar(actions: [],title: Text('Login'),),
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
            decoration: InputDecoration(labelText: 'USN'),
            autofocus: true,
            style: TextStyle(fontSize: 20),
            controller: c1,
            maxLength: 100,
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
              
              if(c1.text == profile['Usn'].toString() && c2.text ==  profile['password'].toString())
              {
                var s=await FirebaseAuth.instance.signInAnonymously();
                print("done");
               setState(() {
                 HomeState.Islogin=true;
               }); 
               setState(() {
                 Isloading= false;
               });
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Upload()));
                break;
              }
            }
            setState(() {
              Isloading=false;
            });
            HomeState.Islogin?Text(""):ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("wrong credentials")));
          });
          var username = c1.text;
          var pass = c2.text;

         
        },)
        ,)),
      ],),
    );
  }
}
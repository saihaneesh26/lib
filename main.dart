import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'pdfview.dart';
Future <void> main() async{ 
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp('Qp'));
}

class MyApp extends StatelessWidget{
var sideval;
MyApp(val){
this.sideval=val;
}
Widget DrawerWidget(BuildContext context)
{
  var list = ['new_files','books','rate us','login'];
  var icon = [Icons.question_answer,Icons.book,Icons.rate_review,Icons.login];
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
                      sideval=list[index];
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>MyApp(list[index])));
                    },
                  );
                },
              ),)
            ],),
          ),
          
        ),
    
        );
}

  Widget build(context){
    return MaterialApp(
      title: "Rit Library",
      home: Scaffold(
        drawer:DrawerWidget(context),
        appBar: AppBar(
        actions: [],
        title: Text('Welcome'),
        ),
        body: Home(sideval),
        ),
    );
  }
}

class Home extends StatefulWidget{
  var sidebar;
  Home(sideval){
    this.sidebar=FirebaseDatabase.instance.reference().child(sideval);
  }
  HomeState createState() {
    return HomeState(sidebar);
    }
}


class HomeState extends State<Home>{
var _dbref;
HomeState(val){
  _dbref = val;
  print('96$val');
  }
  void initstate()
  {
    super.initState();
  }

  //global

  Map layer_values = {1:"sem",2:"subject",3:"file_name"};

  var layer = 1; //l1=>new_files
  var val="null";
 Future <void> data(String param)async{
  //var info = NetworkInfo().getWifiBSSID().then((val){print(val);});
          try{
                var file = FirebaseStorage.instance.ref().child('$param');
                
                await file.getDownloadURL().then((value){
                  setState(() {
                    val = value;
                  });

                });
              }catch(e)
              {
                print("error manual $e");
              }
                Navigator.push(context, MaterialPageRoute(builder: (context)=>PDFPAGE(val,param)));

 // print(info.toString());
  }

Widget build(context){
  return Column(children: [
      layer!=1?Container(
        child: Row(children: [
          IconButton(onPressed: (){
            setState(() {
              print(layer);
              layer-=1;
             //  data();
            });
          }, icon: Icon(Icons.arrow_back)),
         
         Center(child:Text(layer_values[layer].toString(),style: TextStyle(fontSize: 30),),),
        ],),height: 50,width: double.infinity,decoration: BoxDecoration(border: Border.all(color:Colors.black))
      , margin: EdgeInsets.all(0),
      )
        
      :Container(
        child: Row(children: [
          Center(child:
          Text(layer_values[layer].toString(),style: TextStyle(fontSize: 30),),),
        ],),height: 50,width: double.infinity,decoration: BoxDecoration(border: Border.all(color:Colors.black))
      , margin: EdgeInsets.all(0),
      ),
     
      Expanded(child: 
        Container(child: 
        FirebaseAnimatedList(scrollDirection: Axis.vertical,query: _dbref,itemBuilder: (BuildContext context,DataSnapshot snapshot,Animation<double>animation,int index){
          var keys = snapshot.value.keys;
          var values = snapshot.value;
          return GestureDetector(child: Container(
           width:double.infinity,
           height: 200,
           child: Center(child: Text('${values[layer_values[layer]].toString()}',overflow:TextOverflow.clip)),
           decoration: BoxDecoration(border: Border.all()),
          ),onDoubleTap: () async{
              if(layer==layer_values.length)
              {
                print(values['file_name'].toString());
                await data(values['file_name'].toString());
              }
              setState(() {
              print(layer);
              layer!=layer_values.length?layer+=1:layer=layer_values.length;
            });
          },
          );
        }),
      ),
      ),
    ],
  );
}

}
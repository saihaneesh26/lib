import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//import 'package:network_info_plus/network_info_plus.dart';
import 'pdfview.dart';
import 'login.dart';
Future <void> main() async{ 
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // SharedPreferences.setMockInitialValues({});
  runApp(MyApp('QP'));
}

// ignore: must_be_immutable
class MyApp extends StatelessWidget{
var sideval;
MyApp(val){
this.sideval=val;
}

  Widget build(context){
    return MaterialApp(
      title: "Rit Library",
      home: Scaffold(
        drawer:DrawerWidget(context),
        appBar: AppBar(
        actions: [],
        title: Text('e-LIBRARY'),
        ),
        body: Home(sideval),
        ),
    );
  }
}

// ignore: must_be_immutable
class Home extends StatefulWidget{
  var sidebar;

  Home(sideval){
    this.sidebar=sideval;
  }
  HomeState createState() {
    return HomeState(sidebar);
    }
}


class HomeState extends State<Home>{
var _dbref;
var heading =[];
HomeState(val){
  _dbref = FirebaseDatabase.instance.reference().child(val.toString());
  print("added");
  heading.add(val.toString());
  }
  void initstate()
  {
    super.initState();
  }

  //global
  static var Islogin = false;
  var sem='null',subject='null';
  Map layer_values = {1:"sem",2:"subject",3:"file_name"};
  var layer = 1; //l1=>new_files
  var val="null";
  // Future<SharedPreferences> login = SharedPreferences.getInstance();
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
  }

String funct()
{
  var temp='';
  heading.forEach((element) {
    temp+=element.toString()+'/';
  });
print(temp);
  return temp;
}

Widget build(context){
  Set a = {};
  return Column(children: [
      layer!=1?Container(
        child: Row(children: [
          IconButton(onPressed: (){
            setState(() {
              layer-=1;
              heading.removeLast();
              print(layer);
              if(layer==1)
              {
                subject='null';
                sem='null';
              }
              else if(layer==2)
              {
                subject='null';
              }
            });
          }, icon: Icon(Icons.arrow_back)),
        Center(child:Text(funct(),style: TextStyle(fontSize: 24),)),
        Text(layer_values[layer].toString(),style: TextStyle(fontSize: 24),),
        ],),height: 50,width: double.infinity,decoration: BoxDecoration(border: Border.all(color:Colors.black))
      , margin: EdgeInsets.all(0),
      )
        
      :Container(
        child: Row(children: [
        Center(child:Text(funct(),style: TextStyle(fontSize: 24),)),
          Text(layer_values[layer].toString(),style: TextStyle(fontSize: 24),),
        ],),height: 50,width: double.infinity,decoration: BoxDecoration(border: Border.all(color:Colors.black))
      , margin: EdgeInsets.all(0),
      ),
     
      Expanded(child: 
        Container(child: 
        FirebaseAnimatedList(scrollDirection: Axis.vertical,query: _dbref,itemBuilder: (BuildContext context,DataSnapshot snapshot,Animation<double>animation,int index){
        var values = snapshot.value;
       var t = a.add(values[layer_values[layer].toString()].toString());
        var returnVal;
          if(sem=='null'&&subject=='null')
          {
             returnVal = values[layer_values[layer]].toString();
          }
          else if(sem.toString()==values['sem'].toString()&&layer==2)
          {
            returnVal = values[layer_values[layer]].toString();
          }
          else if(sem.toString()==values['sem'].toString()&&subject.toString()==values['subject'].toString()&&layer==3)
          {
               returnVal = values[layer_values[layer]].toString();
          }
          return returnVal!=null&&t?GestureDetector(child: Container(
           width:double.infinity,
           height: 200,
           child: Center(child: Text( values[layer_values[layer]].toString(),overflow:TextOverflow.clip)),
           decoration: BoxDecoration(border: Border.all()),
          ),onDoubleTap: () async{
            heading.add(values[layer_values[layer]].toString());
              if(layer==layer_values.length)
              {
                await data(values['file_name'].toString());
              }
              setState(() {              
              if(layer==1)//sem selected
              {
                sem = values[layer_values[layer]].toString();
              }
              else if(layer==2){//subject
                 subject = values[layer_values[layer]].toString();
              }

              layer!=layer_values.length?layer+=1:layer=layer_values.length;
            
            });
         }
         ):SizedBox(height: 0,);
        }),
      ),
      ),
    ],
  );
}

}
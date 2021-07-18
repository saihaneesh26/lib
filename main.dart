import 'package:package_info/package_info.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:network_info_plus/network_info_plus.dart';
import 'pdfview.dart';
import 'login.dart';
Future <void> main() async{ 
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  PackageInfo packageInfo = await PackageInfo.fromPlatform(); 
  var present_val = packageInfo.toString();
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
                            var i =await _prefs;
                            var islogin = i.getBool('login');
                            var name = i.getString('USN');
                        
                            HomeState.USN = name!=''?name.toString():'';
                           // print('main'+name.toString());
                            HomeState.Islogin = islogin==true?true:false;
                      //      print("main = "+HomeState.Islogin.toString());
                         //   islogin==true?Navigator.push(context, MaterialPageRoute(builder: (context)=>Upload())):Navigator.push(context, MaterialPageRoute(builder: (context)=>Login()));
       var up;var url;              
  await FirebaseDatabase.instance.reference().child('Update').once().then((value) {
   print(present_val==value.value.toString());
    if(present_val==value.value.toString()) //up to date
    {
      up = i.setString('update', 'DONT' );
      i.setString('update_value', value.value.toString());
       HomeState.update = false;
    }
    else{ // do update
      up = i.setString('update', 'DO');
      HomeState.update = true;
      HomeState.updateval = value.value.toString();
      print("update");
    }    
  });
     await FirebaseDatabase.instance.reference().child('Url').once().then((value) {
        HomeState.url = value.value.toString();
     });
  // SharedPreferences.setMockInitialValues({
  //   'login':false,
  // });
 
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
      title: "ISE Library",
      home: Scaffold(
        drawer:DrawerWidget(context),
        appBar: AppBar(
        actions: [],
        title: Text('e-LIBRARY ISE'),
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
static bool update=false;
var heading =[];
static var url;
HomeState(val){
  _dbref = FirebaseDatabase.instance.reference().child(val.toString());

  heading.add(val.toString());
  }
  void initstate()
  {
    super.initState();
  }

  //global
  static var Islogin = false;
  static var USN = '';
  var sem='null',subject='null';
  Map layer_values = {1:"sem",2:"subject",3:"file_name"};
  var layer = 1; //l1=>new_files
  var val="null";
  static var updateval = '';
  Future<SharedPreferences> login = SharedPreferences.getInstance();
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
  return temp+layer_values[layer];
}

Widget build(context){
  Set a = {};
  return update==true?AlertDialog(
    title: Text("Update available"),
    actions: [
      TextButton(onPressed: (){
        setState(() {
          update=false;
        });
      }, child: Text('close')),
      TextButton(onPressed: ()async{
      await canLaunch(url)?await launch(url) : throw 'Could not launch ';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('something is wrong')));
        setState(() {
          update=false;
        });
      }, child: Text('Install')),
    ],
    content: SingleChildScrollView(child: ListBody(children: [
      Text('A latest version ${updateval} is available'),
      Text('Install it')
    ],
    ),
    ),
  ):Column(children: [
      layer!=1?Container(
        child: Row(children: [
          IconButton(onPressed: (){
            setState(() {
              layer-=1;
              heading.removeLast();
              if(layer==1)
              {
                subject='null';
                sem='null';
              }
              else if(layer==2)
              {
                subject='null';
                heading.removeLast();
              }
            });
          }, icon: Icon(Icons.arrow_back)),
        Expanded(child:Text(funct(),style: TextStyle(fontSize: 20),overflow:TextOverflow.clip,)),
        ],),height: 50,width: double.infinity,decoration: BoxDecoration(border: Border.all(color:Colors.black))
      , margin: EdgeInsets.all(0),
      )
        
      :Container(
        child: Row(children: [
    Expanded(child:Text(funct(),style: TextStyle(fontSize: 20),overflow: TextOverflow.clip,)),
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
           child: Center(child: Text( values[layer_values[layer]].toString(),overflow:TextOverflow.clip,style: TextStyle(fontSize: 20),)),
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
              else if(layer==3)
              {

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
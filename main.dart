import 'package:package_info/package_info.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:ritlibrary/request.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'pdfview.dart';
import 'login.dart';
import 'notification.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message)async{
  await Firebase.initializeApp();
  print("a msg show up ${message.notification!.body}");
}

Future <void> main() async{ 
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  try{
  var b =await NetworkInfo().getWifiIP();
  var c = await NetworkInfo().getWifiName();
  c= c==null?'':"name: "+c.toString();
var ij ="IP: ${b.toString()} ${c.toString()}";
HomeState.i = ij;
}catch(e)
{
  print(e.toString());
}

  await FirebaseMessaging.instance.subscribeToTopic('notifications');

  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  var present_val = packageInfo.version.toString();
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
                            var i =await _prefs;
                            var islogin = i.getBool('login');
                            var usn = i.getString('USN');
                            var name = i.getString('Name');
                            var qps = i.getInt('QPS');
                            var tbs = i.getInt('TBS');
                            var re = i.getInt('req');
                            HomeState.req = re!=null?re:0;
                            HomeState.qps = qps!=null?qps:0;
                            HomeState.tbs = tbs!=null?tbs:0;
                            HomeState.Name = name!=null?name:'user';
                            HomeState.USN = usn!=''?usn.toString():'';
                            HomeState.Islogin = islogin==true?true:false;
                        var up;var url;       
                  int dbqps=0,dbtbs=0;
                    await FirebaseDatabase.instance.reference().child('QP').onChildAdded.listen((event) { 
                      var values = event.snapshot.value;
                      dbqps+=1;
                      var s= i.setInt('QPS', dbqps);
                      RemoteMessage n = new RemoteMessage(messageId: '1',data: {'route':'QP'},
                        notification: RemoteNotification(
                          body:'Tap to see',
                          title: dbqps-HomeState.qps==1?'${dbqps-HomeState.qps} New Question Paper is available Now':'${dbqps-HomeState.qps} New Question Papers are available Now', 
                        ),
                      );
                  if(dbqps-HomeState.qps>0){LocalNotificationsService.display(n);}
                    });  
  
  await FirebaseDatabase.instance.reference().child('books').onChildAdded.listen((event) { 
    var values = event.snapshot.value;
    dbtbs+=1;
     var ss =  i.setInt('TBS', dbtbs);
    RemoteMessage n = new RemoteMessage(messageId: '1',data: {'route':'TB'},
      notification: RemoteNotification(
        body:'Tap to see',
        title: dbtbs-HomeState.tbs==1?'${dbtbs-HomeState.tbs} New Textbook is available Now':'${dbtbs-HomeState.tbs} New Textbooks are available Now', 
      ),
    );
    print("dbtbs"+dbtbs.toString());
   if(dbtbs-HomeState.tbs>0){ LocalNotificationsService.display(n);}
  }); 
var req=0;
   await FirebaseDatabase.instance.reference().child('requests').onChildAdded.listen((event) { 
    var values = event.snapshot.value;
    req+=1;
     var s= i.setInt('req', req);
    RemoteMessage n = new RemoteMessage(messageId: '1',data: {'route':'QP'},
      notification: RemoteNotification(
        body:'Tap to see',
        title: req-HomeState.req==1?'${req-HomeState.req} New Requests':'${req-HomeState.req} New Requests', 
      ),
    );
 if(dbqps-HomeState.qps>0&&HomeState.Name!='user'){LocalNotificationsService.display(n);}
  });  

  await FirebaseDatabase.instance.reference().child('Update').once().then((value) {
  // print(present_val==value.value.toString());
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
      HomeState.main_update = true;
    }    
  });
     await FirebaseDatabase.instance.reference().child('url').once().then((value) {
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
      theme: ThemeData(primaryColor: Colors.orange[400],),
      routes: {
        'QP':(_)=>MyApp('QP'),
        'TB':(_)=>MyApp('TB'),
        'RQ':(_)=>Request(),
      },
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
static var url,i;
static var qps,tbs ,req;
static bool main_update=false;
    HomeState(val){
      _dbref = FirebaseDatabase.instance.reference().child(val.toString());

      heading.add(val.toString());
      }
  void initState()
  {
    super.initState();
      LocalNotificationsService.init(context);
    //init msg - gives msg and open app from termination
    FirebaseMessaging.instance.getInitialMessage().then((value) {
      if(value != null)
      {
        final route = value.data['route'];
        Navigator.of(context).pushNamed(route);
      }
    });

    //foreground
    FirebaseMessaging.onMessage.listen((event) { 
      try{
      if(event.notification!=null)
      {
        print(event.notification!.title);
        print(event.notification!.body);
        LocalNotificationsService.display(event);
      }else{
        print('null');
      }
      }catch(e)
      {
        print(e.toString());
      }
    });
    //clickaction-background running
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      if(message.notification!=null)
      {
        final routeFromMessage = message.data['route'];
        print(routeFromMessage);
        Navigator.of(context).pushNamed(routeFromMessage);
      }else{
        print("null2");
      }
    });




  }//init state

  //global
  static var Islogin = false;
  static var USN = '';
  static var Name='';
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
          HomeState.update=false;
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
    HomeState.i==null?SizedBox():Text('info: ${HomeState.i}'),
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
       var t = a.add((values[(layer_values[layer]).toString()]).toString());
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
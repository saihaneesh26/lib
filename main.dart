import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:package_info/package_info.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:ritlibrary/request.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pdfview.dart';
import 'login.dart';
import 'notification.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message)async{
  await Firebase.initializeApp();
  print("a msg show up ${message.notification!.body}");
}

Future <void> main() async{ 
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await FirebaseMessaging.instance.subscribeToTopic('notifications');

  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  var present_val = packageInfo.version.toString();
  await FirebaseDatabase.instance.reference().child('MM').once().then((snapshot) {
    print(snapshot.value);
    HomeState.mm = snapshot.value.toString();
  });

  await FirebaseDatabase.instance.reference().child('particular').once().then((value){
    HomeState.particular = value.value.toString()=='false'?false:true;
  });
  await FirebaseDatabase.instance.reference().child('bssid').once().then((value) {
    HomeState.bssid = value.value.toString();
  });

try{
  HomeState.location = false;
 var a = await Permission.locationWhenInUse.status;
if(a==PermissionStatus.granted){ 
  print("granted");
   HomeState.location = true;
      await NetworkInfo().getWifiName().then((value){
        print(value.toString());
        if(value.toString()!='null')
        HomeState.info+="network: "+value.toString();
      });
      await NetworkInfo().getWifiBSSID().then((value){
        print(value.toString());
        if(value.toString()!='02:00:00:00:00:00')
        HomeState.info+=" bssid:"+value.toString();
        HomeState.mybssid = value.toString();
      });
      await NetworkInfo().getWifiIP().then((value){
        print(value.toString());
        HomeState.info+=" ip:"+value.toString();
      });
}
else{
  openAppSettings();
}
    
  
}catch(e){
  print(e);
}
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
                            var i =await _prefs;
                            var islogin = i.getBool('login');
                            var usn = i.getString('USN');
                            var name = i.getString('Name');
                            var qps = i.getInt('QPS');
                            var lp = i.getInt('lp');
                            var agreement = i.getBool('agreement');
                            var re = i.getInt('req');
                            HomeState.req = re!=null?re:0;
                            HomeState.ag = agreement!=null?agreement:false;
                            HomeState.qps = qps!=null?qps:0;
                            HomeState.Name = name!=null?name:'user';
                            HomeState.USN = usn!=''?usn.toString():'';
                            HomeState.lp = lp!=null?lp:0;
                            HomeState.Islogin = islogin==true?true:false;
                        var up;var url;       
                  int dbqps=0,dblp=0;
                    await FirebaseDatabase.instance.reference().child('QP').onChildAdded.listen((event) { 
                      var values = event.snapshot.value;
                      dbqps+=1;
                      var s= i.setInt('QPS', dbqps);
                      RemoteMessage n = new RemoteMessage(messageId: '1',data: {'route':'QP'},
                        notification: RemoteNotification(
                          body:'Tap to Check',
                          title: dbqps-HomeState.qps==1?'${dbqps-HomeState.qps} New Question Paper is available Now':'${dbqps-HomeState.qps} New Question Papers are available Now', 
                        ),
                      );
                  if(dbqps-HomeState.qps>0){LocalNotificationsService.display(n);}
                    });  

                     await FirebaseDatabase.instance.reference().child('Lab').onChildAdded.listen((event) { 
                      var values = event.snapshot.value;
                      dblp+=1;
                      var s= i.setInt('lp', dblp);
                      RemoteMessage n = new RemoteMessage(messageId: '1',data: {'route':'Lab'},
                        notification: RemoteNotification(
                          body:'Tap to Check',
                          title: dblp-HomeState.lp==1?'${dblp-HomeState.lp} New Lab Program is available Now':'${dblp-HomeState.lp} New Lab Programs are available Now', 
                        ),
                      );
                  if(dblp-HomeState.lp>0){LocalNotificationsService.display(n);}
                    });  
  
var req=0;
   await FirebaseDatabase.instance.reference().child('requests').onChildAdded.listen((event) { 
    var values = event.snapshot.value;
    req+=1;
     var s= i.setInt('req', req);
    RemoteMessage n = new RemoteMessage(messageId: '1',data: {'route':'RQ'},
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
      i.setBool('agreement',false);
      HomeState.ag = false;
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
        'Lab':(_)=>MyApp('Lab'),
        'RQ':(_)=>Request(),
      },
      home: Scaffold(
        
       drawer: DrawerWidget(context),
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

   Future<void> secureScreen() async {
    await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE); 
 }

var _dbref;
static var mm = 'off';
static bool update=false;
var heading =[];
static var url,info='';
static var location = false;
static var mybssid = '';
static var bssid='',particular = false;
static var qps,lp ,req;
static bool ag = false;
static bool main_update=false;
    HomeState(val){
      _dbref = FirebaseDatabase.instance.reference().child(val.toString());

      heading.add(val.toString());
      }
  void initState()
  {
    secureScreen();
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
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>PDFPAGE(val,param)));
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
  bool v=false;var type;

  var error =''; var enter = false;
  if(HomeState.particular==true && HomeState.location == false)
  {
    setState(() {
      enter=false;
      error='location access is denied';
    });
  }
  else if((HomeState.particular==true && HomeState.bssid == HomeState.mybssid) || (HomeState.particular == false))
  { 
    setState(() {
      enter = true;
    });
  }
 else if(HomeState.mybssid != HomeState.bssid)
 {
   setState(() {
     enter = false;
     error ='connect to Proper netwrok here';
   });
 }

  return 
  enter==true?
  HomeState.mm=='off'?HomeState.ag==false?AlertDialog(
    title: Text('Agreement & Privacy Policy'),
    content: Container(
      height: 300,
      child:SingleChildScrollView(child: Text('Disclaimer:\nThe Content inside is only Education purpose only.\n The shared content is available in Public and RIT Library.\nThe information Provided inside may not be reliable and may be inaccurate.\nThe information is taken from respective writers and they are notified that this information is made public.\nThe information inside can be shared with others without any information to respective authors or Owners. So Use if wisely☺\n')),
      ),
    actions: [
      TextButton(onPressed: (){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("You cannot Continue to use this App unless you Accept")));
      }, child: Text("Reject")),
    TextButton(onPressed: ()async{
        Future<SharedPreferences> _p = SharedPreferences.getInstance();
         var i =await _p;
        var islogin = i.setBool('agreement',true);
         setState(() {  
         HomeState.ag=true;
         });
      }, child: Text("Accept All and Continue"))
     ],
  ):update==true?AlertDialog(
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
    Container(
      child: Text(HomeState.info.toString()),
    ),
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
              }
              
            });
          }, icon: Icon(Icons.arrow_back)),
        Expanded(child:Text(funct(),style: TextStyle(fontSize: 20),overflow:TextOverflow.clip,)),
        ],),height: 50,width: double.infinity,decoration: BoxDecoration(border: Border.all(color:Colors.black))
      , margin: EdgeInsets.all(0),
      )
        
      :Container(
        child: Row(children: [
    Expanded(child:Text("  "+funct(),style: TextStyle(fontSize: 20),overflow: TextOverflow.clip,)),
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
          ),onTap: () async{
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
  ):Center(child: Text("Maintainence mode is on. Please Come back later"),):
  Center(child:TextButton(child: error=='location access is denied'?Text('$error\nGive permission here'):Text('$error'),onPressed: ()async{
    openAppSettings();
  }, ),);
}

}
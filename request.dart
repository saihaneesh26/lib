import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:ritlibrary/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';
import 'upload.dart';
import 'package:clipboard/clipboard.dart';

class Request extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      drawer: DrawerWidget(context),
      appBar: AppBar(actions: [],title: Text('Request'),),
      body: RequestBody()
    );
  }
}
class RequestBody extends StatefulWidget{
  RequestBodyState createState()=>RequestBodyState();
}

class RequestBodyState extends State<RequestBody>{
  var _dbref = FirebaseDatabase().reference().child('requests');
  TextEditingController c1 = new TextEditingController();
  TextEditingController c2 = new TextEditingController();
  TextEditingController c3 = new TextEditingController();
  TextEditingController c4 = new TextEditingController();
  bool isloading=false;
  var type=null;
  Widget build(context)
  {
    return isloading?Center(child: CircularProgressIndicator(),):Column(children: [
     SingleChildScrollView(child: Container(
      padding: EdgeInsets.all(2),
      margin: EdgeInsets.all(2),
      decoration: BoxDecoration(border: Border.all(color: Colors.black)),
      child: Column(children: [
   
        TextField(//sem
          controller: c1,
          maxLength: 1,
          decoration: InputDecoration(labelText: 'semester',hintText:'1'),
        ),
        TextField(//subject
          controller: c2,
           decoration: InputDecoration(labelText: 'Subject',hintText: ' IS**/ISL**'),
        ),
        Row(children: [
            Text('Type: ',style: TextStyle(fontSize: 20),),
          Radio(value: 'QP', groupValue: type, onChanged: (val){
          setState(() {
            type = val;
          });
        }),Text("QP"),SizedBox(width: 20,),
        Radio(value: 'Lab', groupValue: type, onChanged: (val){
          setState(() {
            type = val;
          });
        }),Text('Lab'),
        ],),
        type=='QP'?TextField(//year
          controller: c3,
           decoration: InputDecoration(labelText: 'Year',hintText: 'YYYY'),
        ):SizedBox(height: 0,),
        type=='QP'?TextField(//year
          controller: c4,
           decoration: InputDecoration(labelText: 'Type',hintText: 'SEE/SUP/CIE1/CIE2'),
        ):SizedBox(),
        type=='Lab'?TextField(//year
          controller: c4,
           decoration: InputDecoration(labelText: 'Qno',hintText: 'all/*'),
        ):SizedBox(height: 0,),
        ElevatedButton(onPressed: ()async{
          if(c2.text!=null&&c2.text!=''&&c1.text!=null&&c1.text!=''&&c1.text!=null&&c1.text!=''&&type!=''&&type!=null&&c4.text!=null)
          {
            setState(() {
              isloading=true;
            });
            await FirebaseDatabase.instance.reference().child('requests').push().set({
            'id':c2.text.toString().toLowerCase()+'-'+c4.text.toString().toLowerCase()+'-'+c3.text.toString(),
            'subject':c2.text.toString().toUpperCase(),
            'type':type.toString()+' '+c4.text,
            'year':c3.text.toString(),
            'status':'NO'
            });
            setState(() {
              c1.clear();
              c2.clear();
              c3.clear();
              c4.clear();
              type=null;
              isloading=false;
              print("done");
            });
             ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Requested')));
          }
          else{
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Give crct details')));
          }
        }, child: Text('Request')),
      
      ],),
     )
    ),
  Container(
        child: Text('Requested',style: TextStyle(fontSize: 40),),
      ),Expanded(child:Container(
        width: double.infinity,
        child:FirebaseAnimatedList(query: _dbref,itemBuilder: (BuildContext context,DataSnapshot snapshot,Animation animation,int index){
          var values = snapshot.value;
          var keys = snapshot.value.keys;
          var p = (index+1).toString()+"."+values['type']+" "+values['subject'];
          if(values['year']!=null)
          {
            p+='-'+values['year'];
          }
          return SingleChildScrollView(child:Container(
            width: double.infinity,
            decoration: BoxDecoration(border: Border.all(color: Colors.black)),
            child:(
              Row(children:[
              values['status']=='NO'?Icon(Icons.pending,color:Colors.red,size: 25,):Icon(Icons.verified,color:Colors.green,size: 25,),  
              Expanded(
              child: Container(
              padding: EdgeInsets.all(1),
              margin: EdgeInsets.all(3),
               decoration: BoxDecoration(border: Border.all(color: Colors.black)),
                child:Text(p,style: TextStyle(fontSize: 20),overflow: TextOverflow.clip,)),
             ),
             IconButton(onPressed: ()async{
               FlutterClipboard.copy(values['id']);
               ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Id copied to clipboard")));
             }, icon: Icon(Icons.copy))
            ]
            )
            ),
          ));
        },) 
        ,) //listview
        ,)
    ],    
    );
  }
}
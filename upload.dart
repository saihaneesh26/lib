import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
// import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'main.dart';
// import 'package:path/path.dart';
import 'login.dart';
import 'package:file_picker/file_picker.dart';

class Upload extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return HomeState.Islogin==false?Login():Scaffold(
appBar: AppBar(actions: [IconButton(icon:Icon(Icons.logout),onPressed: ()async{
  HomeState.Islogin=false;
  await FirebaseAuth.instance.signOut();
  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>MyApp('new_files')));
},)],title: Text('Upload'),),
drawer: DrawerWidget(context),
body: UploadBody(),
    );
  }
}

class UploadBody extends StatefulWidget{
  UploadBodyState createState()=> UploadBodyState();
}

class UploadBodyState extends State<UploadBody>{

    TextEditingController c1 = new TextEditingController();
  TextEditingController c2 = new TextEditingController();
    TextEditingController c3 = new TextEditingController();
  TextEditingController c4 = new TextEditingController();
    TextEditingController c5 = new TextEditingController();
  bool pass_visible=false;
  bool Isloading = false;
  var result;
  var type='';
  @override
  Widget build(BuildContext context) {
  return Isloading?Center(child: CircularProgressIndicator(),):SingleChildScrollView(
      child: Column(children: [
        Container(
          child: TextField(
            decoration: InputDecoration(labelText: 'Sem'),
            autofocus: true,
            style: TextStyle(fontSize: 20),
            controller: c1,
            maxLength: 1,
            ),
          padding: EdgeInsets.all(5),
          margin: EdgeInsets.all(2),
        //   decoration: BoxDecoration(border: Border.all(width: 2,color: Colors.blue)),
        ),
        SizedBox(height: 10,),
        Container(
          child: TextField(
             decoration: InputDecoration(labelText: 'Subject',hintText: 'IS**'),
            style: TextStyle(fontSize: 20),
            maxLength: 4,
            controller: c2,
            ),
          padding: EdgeInsets.all(5),
          margin: EdgeInsets.all(2),
   // decoration: BoxDecoration(border: Border.all(width:2,color: Colors.blue)),
        ),
        SizedBox(height: 10,),
        Container(
          child: TextField(
             decoration: InputDecoration(labelText: 'year'),
            style: TextStyle(fontSize: 20),
            controller: c3,
            maxLength: 4,
            ),
          padding: EdgeInsets.all(5),
          margin: EdgeInsets.all(2),
   // decoration: BoxDecoration(border: Border.all(width:2,color: Colors.blue)),
        ),
        SizedBox(height: 10,),
        Container(
          child: TextField(
             decoration: InputDecoration(labelText: 'Type',hintText: 'QP / TB'),
            style: TextStyle(fontSize: 20),
            controller: c5,
            maxLength: 2,onChanged: (val)
            {
              setState(() {
                type=c5.text;
              });
            },
            ),
          padding: EdgeInsets.all(5),
          margin: EdgeInsets.all(2),
   // decoration: BoxDecoration(border: Border.all(width:2,color: Colors.blue)),
        ),
        SizedBox(height: 10,),
        type.toString()=='QP'?Container(
          child: TextField(
             decoration: InputDecoration(labelText: 'QP Type',hintText: 'SEE/CIE'),
            style: TextStyle(fontSize: 20),
            controller: c4,
            maxLength: 3,
            ),
          padding: EdgeInsets.all(5),
          margin: EdgeInsets.all(2),
   // decoration: BoxDecoration(border: Border.all(width:2,color: Colors.blue)),
        ):type.toString()=='TB'?Container(
          child: TextField(
             decoration: InputDecoration(labelText: 'TB Number',hintText: '1/2'),
            style: TextStyle(fontSize: 20),
            controller: c4,
            maxLength: 3,
            ),
          padding: EdgeInsets.all(5),
          margin: EdgeInsets.all(2),
   // decoration: BoxDecoration(border: Border.all(width:2,color: Colors.blue)),
        ):
        SizedBox(height: 20,),
        ElevatedButton(onPressed: ()async{
          setState(() {
            Isloading=true;
          });
          try{
            result = await FilePicker.platform.pickFiles(allowMultiple: false);}catch(e){
            print(e);
          }
          if(result==null)
          {
            setState(() {
              Isloading=false;
            });
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to select file")));
          }
          else{
            setState(() {
              Isloading=false;
            });
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("selected file ${result.names.first}")));
          }
        }, child: Text("Upload file")),

        Container(child:Center(child: 
        ElevatedButton(child: Text('Submit'),onPressed: ()async{
          setState(() {
            Isloading=true;
          });
          var p='',temp_name='';
        if(c5.text.toString()=='QP')
            {
              List<PlatformFile> files = result.files;
              files.forEach((element) async
              {
                if(c1.text!=null&&c2.text!=null&&c3.text!=null&&c5.text!=null&&c4.text!=null)
               { 
                 temp_name+=(c5.text+'${c4.text}'+'-'+c2.text+'-'+c1.text+'-'+c3.text).toString();
                 temp_name+='.'+element.extension.toString();
                  var uploadTask = FirebaseStorage.instance.ref().child(temp_name).putFile(File(element.path.toString()));
                  await uploadTask.whenComplete((){
                  print("uploaded");
                  });
                  await FirebaseDatabase.instance.reference().child("QP").push().set({
                  'sem':'sem-'+c1.text,
                  'subject':c2.text.toString(),
                  'year':c3.text.toString(),
                  'feature':c4.text.toString(),
                  'file_name':temp_name.toString()
                  });
                  setState(() {
                    Isloading=false;
                  });
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Uploaded")));
                }

                setState(() {
                    Isloading=false;
                  });
               });
               ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("enter crct details")));
            }
            else if(c5.text.toString()=='TB'){
              List<PlatformFile> files = result.files;
              files.forEach((element) async
              {
                 if(c1.text!=null&&c2.text!=null&&c3.text!=null&&c5.text!=null)
               { 
                 temp_name+=(c5.text+'-'+c2.text+'-'+c1.text+'-'+c3.text).toString();
                temp_name+='.'+element.extension.toString();
                var uploadTask = FirebaseStorage.instance.ref().child(temp_name).putFile(File(element.path.toString()));
                await uploadTask.whenComplete((){
                print("uploaded");
                });
                await FirebaseDatabase.instance.reference().child("books").push().set({
                'sem':c1.text,
                'subject':c2.text.toString(),
                'file_name':temp_name.toString()
                });
                setState(() {
                    Isloading=false;
                  });
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Uploaded")));
               }
               else{
                 setState(() {
                    Isloading=false;
                  });
                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("enter crct details")));
               }
               
               });
               
              
              
            }
            else{
              setState(() {
                Isloading=false;
              });
               ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to select crct type")));
            }
         
        },)
        ,)),
      ],),
    );
  }
  
}
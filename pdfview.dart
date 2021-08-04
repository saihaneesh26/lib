import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';



// ignore: must_be_immutable
class PDFPAGE extends StatefulWidget{
  var link,name;
  PDFPAGE(link,param){
    this.name=param;
    this.link=link;
  }
  PDFVIEWBODYState createState(){
    return PDFVIEWBODYState(link,name);
  }
}



class PDFVIEWBODYState extends State<PDFPAGE>{
  
 Future<void> secureScreen() async {
   print("Secure");
   try{
 await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
   }catch(e)
   {
     print(e);
   }
   
 }
   PDFVIEWBODYState(link,param){
    this.name=param;
    this.link=link;
  } 
  
  void initState(){
    super.initState();
    print("initState");
    secureScreen();
    
  }

var link,name;

  var _pdfViewerController;

  var notification=null;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Row(children: [
         IconButton(onPressed: ()async{
          Navigator.popAndPushNamed(context, 'QP');
        }, icon: Icon(Icons.arrow_back))
        ,Text(name.toString())]),actions: [
       
      ],),
      body:Container(
        child: Column(children: [
          notification!=null?Text('$notification'):SizedBox(height: 0,),
          Expanded(
            child: SfPdfViewer.network(
            link,
            onDocumentLoadFailed: (e)=>{
              setState((){
                notification = "Error: "+e.toString();
              })
            },
            enableDoubleTapZooming: true,
            enableTextSelection: false,
            ),
        ),
        ]
      )
      )
    );
  }
}
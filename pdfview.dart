import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';


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
  var link,name;
  PDFVIEWBODYState(link,param){
    this.name=param;
    this.link=link;
  }
  var _pdfViewerController;
  void initState() 
  {
    super.initState();
  }
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
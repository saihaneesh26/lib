// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:firebase_database/ui/firebase_animated_list.dart';
// import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
// import 'package:network_info_plus/network_info_plus.dart';
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

  void initState() 
  {
    super.initState();
  }
 // final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(actions: [],title: Text("$name"),),body:Container(child:link!="null"?SfPdfViewer.network(link):Text("no file") ,));
  }

}

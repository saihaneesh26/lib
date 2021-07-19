import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'main.dart';
import 'upload.dart';
import 'request.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationsService{
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin= FlutterLocalNotificationsPlugin();
 
  static void init(context)
  {
    final InitializationSettings initializationSettings = InitializationSettings(android: AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    ));
    _flutterLocalNotificationsPlugin.initialize(initializationSettings,onSelectNotification: (String? route)async{
        // final route = value.data['route'];
        if(route!=null)
        Navigator.of(context).pushNamed(route);
    });
  } 
  static void display(RemoteMessage message)async
  {
  try{
    final id = DateTime.now().millisecondsSinceEpoch~/1000;//unique id
    await _flutterLocalNotificationsPlugin.show(
      id, message.notification!.title, message.notification!.body, 
      NotificationDetails(
      android: AndroidNotificationDetails(
          'easyapproach',    //channel id
        'easyapproach_channel',//channel name
        'this is chanel',//description
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
      ),
    ),
    payload:message.data['route'],
    );
    print("done");
  }catch(e)
  {
    print(e);
  }
  }
}

// ignore_for_file: prefer_const_constructors

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatsphere/model/message.dart';
import 'package:chatsphere/notification_body.dart';
import 'package:flutter/material.dart';
import 'package:in_app_notification/in_app_notification.dart';
import 'package:photo_view/photo_view.dart';

class MessageBox extends StatefulWidget {
  const MessageBox({super.key, required this.child, required this.timestamp, required this.aligment, this.replyTo, this.messageType});
  final Widget child;
  final String timestamp;
  final Alignment aligment;
  final String? replyTo;
  final MessageType? messageType;
  @override
  State<MessageBox> createState() => _MessageBoxState();
}
String _truncateText(String text, int maxLength) {
    return text.length > maxLength ? '${text.substring(0, maxLength)}...' : text;
  }
void viewImage(BuildContext context, String url) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => SafeArea(
        child: Scaffold(
          body: Stack(
            children: [
              Center(
                child: PhotoView(
                  imageProvider: CachedNetworkImageProvider(url),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(onPressed: (){Navigator.pop(context);}, icon: Icon(Icons.cancel, color: Theme.of(context).colorScheme.onBackground,)
                ))
            ],
          ),
        ),
      ),
    ),
  );
}
class _MessageBoxState extends State<MessageBox> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color:widget.aligment==Alignment.centerRight? Theme.of(context).primaryColor.withOpacity(0.65):Theme.of(context).colorScheme.onSecondary,
            borderRadius:widget.aligment==Alignment.centerRight? BorderRadius.only(bottomLeft: Radius.circular(10), topLeft: Radius.circular(10), bottomRight: Radius.circular(13)):BorderRadius.only( topRight: Radius.circular(10), bottomLeft: Radius.circular(13), bottomRight: Radius.circular(10),),

          ),
          
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:widget.aligment==Alignment.centerRight? CrossAxisAlignment.end:CrossAxisAlignment.start,
              children: [
               if(widget.replyTo!=null) 
              widget.replyTo!.contains("%!image!_")||widget.replyTo!.contains("https://firebasestorage.googleapis.com/v0/b/chatsphere-bbc53.appspot.com/o/images")?
              GestureDetector(
                onDoubleTap: (){
                  viewImage(context,widget.replyTo!.contains("%!image!_")?widget.replyTo!.substring(9):widget.replyTo!);
                },
                onTap: (){
                  viewImage(context,widget.replyTo!.contains("%!image!_")?widget.replyTo!.substring(9):widget.replyTo!);
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("replyed:", style: TextStyle(fontSize: 10, color: Colors.white)),
                     Icon(Icons.image, size: IconTheme.of(context).size!*0.7,),
                  ],
                ),
              ) 
              :
              widget.replyTo!.contains("https://firebasestorage.googleapis.com/v0/b/chatsphere-bbc53.appspot.com/o/audio")?
              Text("replyed: audio")
              :
              widget.messageType==MessageType.video?
              Container()
              :
              widget.messageType==MessageType.audio?
              Container()
              :
              GestureDetector(
               onDoubleTap: () {
                 InAppNotification.show(
                child: NotificationBody(child: Text("reply to: ${widget.replyTo!}", maxLines: 5,),),
              context: context,
              onTap: () => (){},
                );
               },
               onTap:(){
                 InAppNotification.show(
                 child: NotificationBody(child: Text("reply to: ${widget.replyTo!}",maxLines: 5,)),
                 context: context,
                onTap: () => (){},
                 );
               } ,
                child: RichText(text: TextSpan(
                  children: [
                   TextSpan(text: "replyed:", style: TextStyle(fontSize: 12, color: Colors.white)),
                   TextSpan(text: _truncateText(widget.replyTo!, 8), style: TextStyle(fontSize: 15, color: Colors.white))
                  ]
                )),
              ),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: widget.child,
                ),
                Text(" ${widget.timestamp}", style: TextStyle(color:Theme.of(context).primaryColor,fontSize: 12),)
              ],
            ),
          ),
        ),
      ],
    );
  }
}

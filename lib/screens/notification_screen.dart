import 'package:flutter/material.dart';
import 'package:twitter_flutter_app/constants/constants.dart';
import 'package:twitter_flutter_app/models/activity.dart';
import 'package:twitter_flutter_app/models/user_model.dart';
import 'package:twitter_flutter_app/services/database_services.dart';
class NotificationScreen extends StatefulWidget {
  final String currentUserId;
  NotificationScreen(this.currentUserId);
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<Activity> _activities = [];

  setupActivities() async{
    List<Activity> activities = await DatabaseServices.getActivities(widget.currentUserId);
    setState(() {
          _activities = activities;
        });
  }

    Widget buildActivity(Activity activity) {

      return FutureBuilder(
        future: usersRef.doc(activity.fromUserId).get(),
        builder: (context, snapshot){
          if(!snapshot.hasData){
            return SizedBox.shrink();
          }else{
            UserModel user = UserModel.fromDoc(snapshot.data);
            return Column(
              children: [
                ListTile(
                  leading: CircleAvatar(
                    radius: 20,
                    backgroundImage: user.profilePicture.isEmpty
                       ?AssetImage('assets/placeholder.png')
                       :NetworkImage(user.profilePicture),
                  ),
                  title:activity.follow
                     ?Text('${user.name} follow you')
                     :Text('${user.name} like you tweet'), 
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Divider(color: kTweeterColor,thickness: 2,),
                )
              ],
            );
          }
        },
      );

    }

  @override
    void initState() {
      setupActivities();
      super.initState();
    }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: .5,
        title: Text('Notifications', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
      ),
      body:RefreshIndicator(
        onRefresh: ()=>setupActivities(),
        child: ListView.builder(
          itemCount: _activities.length,
          itemBuilder: (ctx, i){
            Activity activity = _activities[i];
            return buildActivity(activity);
          },
        ),
      ),
    );
  }

}
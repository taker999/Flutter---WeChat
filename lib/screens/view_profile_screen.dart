import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_we_chat/helper/my_date_util.dart';
import 'package:flutter_we_chat/main.dart';
import 'package:flutter_we_chat/models/chat_user.dart';
import 'package:insta_image_viewer/insta_image_viewer.dart';

// view profile screen -- to view profile of user
class ViewProfileScreen extends StatefulWidget {
  const ViewProfileScreen({super.key, required this.user});

  final ChatUser user;

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        // app bar
        appBar: AppBar(
          title: Text(widget.user.name),
        ),

        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Joined On: ',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
            ),
            Text(
              MyDateUtil.getLastMessageTime(context: context, time: widget.user.createdAt, showYear: true),
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 15,
              ),
            ),
          ],
        ),

        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // for adding some space
                SizedBox(width: mq.width, height: mq.height * .03),

                // user profile pic
                InstaImageViewer(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(mq.height * .1),
                    child: CachedNetworkImage(
                      width: mq.height * .2,
                      height: mq.height * .2,
                      fit: BoxFit.cover,
                      imageUrl: widget.user.image,
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(),
                      errorWidget: (context, url, error) =>
                          const CircleAvatar(child: Icon(CupertinoIcons.person)),
                    ),
                  ),
                ),

                // for adding some space
                SizedBox(height: mq.height * .03),

                // user email label
                Text(
                  widget.user.email,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                  ),
                ),

                // for adding some space
                SizedBox(height: mq.height * .02),

                // user about
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'About: ',
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      widget.user.about,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

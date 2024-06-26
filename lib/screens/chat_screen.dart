import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_we_chat/api/apis.dart';
import 'package:flutter_we_chat/helper/my_date_util.dart';
import 'package:flutter_we_chat/main.dart';
import 'package:flutter_we_chat/models/chat_user.dart';
import 'package:flutter_we_chat/models/message.dart';
import 'package:flutter_we_chat/screens/view_profile_screen.dart';
import 'package:flutter_we_chat/widgets/message_card.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.user});

  final ChatUser user;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // for storing all messages
  List<Message> _list = [];

  // for handling message text changes
  final _textController = TextEditingController();

  // showEmoji -- for storing value of showing or hiding emoji
  // isUploading -- for checking if image is uploading or not
  bool _showEmoji = false, _isUploading = false, _isImagine = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: PopScope(
        // if emojis are shown & back button is pressed then hide emojis
        // or else simply close current screen on back button click
        canPop: !_showEmoji,
        onPopInvoked: (didPop) {
          if (_showEmoji) {
            setState(() {
              _showEmoji = !_showEmoji;
            });
          } else {}
        },
        child: Scaffold(
          // app bar
          appBar: AppBar(
            automaticallyImplyLeading: false,
            flexibleSpace: _appBar(),
          ),

          backgroundColor: const Color.fromARGB(255, 234, 248, 255),

          // body
          body: Column(
            children: [
              Expanded(
                child: StreamBuilder(
                  stream: APIs.getAllMessages(widget.user),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      // if data is loading
                      case ConnectionState.waiting:
                      case ConnectionState.none:
                        return const SizedBox();

                      // if some or all data is loaded then show it
                      case ConnectionState.active:
                      case ConnectionState.done:
                        final data = snapshot.data?.docs;
                        // log('Data: ${jsonEncode(data![0].data())}');
                        _list = data
                                ?.map((e) => Message.fromJson(e.data()))
                                .toList() ??
                            [];

                        if (_list.isNotEmpty) {
                          return ListView.builder(
                            reverse: true,
                            padding: EdgeInsets.only(top: mq.height * .01),
                            physics: const BouncingScrollPhysics(),
                            itemCount: _list.length,
                            itemBuilder: (context, index) {
                              return MessageCard(message: _list[index]);
                            },
                          );
                        } else {
                          return const Center(
                            child: Text(
                              'Say Hi! 👋',
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                          );
                        }
                    }
                  },
                ),
              ),

              if (_isUploading)
                const Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
                ),

              // chat input field
              _chatInput(),

              // show emojis on keyboard emoji button click & vice versa
              if (_showEmoji)
                EmojiPicker(
                  textEditingController: _textController,
                  config: Config(
                    height: mq.height * .35,
                    // bgColor: const Color.fromARGB(255, 234, 248, 255),
                    emojiViewConfig: EmojiViewConfig(
                      emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // app bar widget
  Widget _appBar() {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => ViewProfileScreen(user: widget.user)));
      },
      child: StreamBuilder(
        stream: APIs.getUserInfo(widget.user),
        builder: (context, snapshot) {
          final data = snapshot.data?.docs;
          final list =
              data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];

          return Row(
            children: [
              // back button
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.black54,
                ),
              ),

              // user profile picture
              ClipRRect(
                borderRadius: BorderRadius.circular(mq.height * .3),
                child: CachedNetworkImage(
                  width: mq.height * .05,
                  height: mq.height * .05,
                  imageUrl: list.isNotEmpty ? list[0].image : widget.user.image,
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                  errorWidget: (context, url, error) =>
                      const CircleAvatar(child: Icon(CupertinoIcons.person)),
                ),
              ),

              // for adding some space
              const SizedBox(width: 10),

              // user name & last seen time
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // user name
                  Text(
                    list.isNotEmpty ? list[0].name : widget.user.name,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  // for adding some space
                  const SizedBox(height: 2),

                  // last seen time of user
                  Text(
                    list.isNotEmpty
                        ? list[0].isOnline
                            ? 'Online'
                            : MyDateUtil.getLastActiveTime(
                                context: context,
                                lastActive: list[0].lastActive)
                        : MyDateUtil.getLastActiveTime(
                            context: context,
                            lastActive: widget.user.lastActive),
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  )
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  // bottom chat input field
  Widget _chatInput() {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: mq.height * .01, horizontal: mq.width * .025),
      child: Row(
        children: [
          // input field & buttons
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Row(
                children: [
                  // emoji button
                  IconButton(
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      setState(() => _showEmoji = !_showEmoji);
                    },
                    icon: const Icon(
                      Icons.emoji_emotions,
                      color: Colors.blueAccent,
                      size: 25,
                    ),
                  ),

                  Expanded(
                    child: TextField(
                      onTap: () {
                        if (_showEmoji) setState(() => _showEmoji = false);
                      },
                      onChanged: (val) {
                        if (val.contains('/imagine', 0)) {
                          if (!_isImagine) {
                            setState(() {
                              _isImagine = true;
                            });
                          }
                        } else {
                          if (_isImagine) {
                            setState(() {
                              _isImagine = false;
                            });
                          }
                        }
                      },
                      controller: _textController,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      style: _isImagine
                          ? const TextStyle(color: Colors.blue)
                          : null,
                      decoration: const InputDecoration(
                        hintText: 'Type Something...',
                        hintStyle: TextStyle(color: Colors.blueAccent),
                        border: InputBorder.none,
                      ),
                    ),
                  ),

                  // pick image from gallery button
                  IconButton(
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();

                      // picking multiple images
                      final List<XFile> images =
                          await picker.pickMultiImage(imageQuality: 80);

                      // uploading & sending image one by one
                      for (var i in images) {
                        setState(() => _isUploading = true);
                        await APIs.sendChatImage(widget.user, File(i.path));
                        setState(() => _isUploading = false);
                      }
                    },
                    icon: const Icon(
                      Icons.image,
                      color: Colors.blueAccent,
                      size: 26,
                    ),
                  ),

                  // take image from camera button
                  IconButton(
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      // Capture a photo.
                      final XFile? image = await picker.pickImage(
                          source: ImageSource.camera, imageQuality: 80);
                      if (image != null) {
                        setState(() => _isUploading = true);
                        await APIs.sendChatImage(widget.user, File(image.path));
                        setState(() => _isUploading = false);
                      }
                    },
                    icon: const Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.blueAccent,
                      size: 26,
                    ),
                  ),

                  // add some space
                  SizedBox(width: mq.width * .02),
                ],
              ),
            ),
          ),

          // send message button
          MaterialButton(
            onPressed: () async {
              if (_list.isEmpty) {
                // on first message (add user to my_user collection of chat user)
                APIs.sendFirstMessage(
                    widget.user, _textController.text, Type.text);
              } else {
                // simply send message
                APIs.sendMessage(
                    widget.user, _textController.text, Type.text);
              }
              if (_textController.text.trim().isNotEmpty) {
                if (_textController.text.contains('/imagine', 0)) {
                  String imageQuery =
                      _textController.text.replaceRange(0, 8, '').trim();
                  _textController.clear();
                  setState(() => _isUploading = true);
                  var response = await APIs.imageQuery({"inputs": imageQuery})
                      .catchError((error) {
                    log('Error: $error');
                    if (_list.isEmpty) {
                      // on first message (add user to my_user collection of chat user)
                      APIs.sendFirstMessage(
                          widget.user, "Sorry, can't generate image", Type.text);
                    } else {
                      // simply send message
                      APIs.sendMessage(
                          widget.user, "Sorry, can't generate image", Type.text);
                    }
                    setState(() => _isUploading = false);
                  });
                  // log(File.fromRawPath(response).toString());
                  Uint8List imageInUnit8List =
                      response; // store unit8List image here ;
                  final tempDir = await getTemporaryDirectory();
                  File file = await File('${tempDir.path}/image.jpg').create();
                  file.writeAsBytesSync(imageInUnit8List);
                  // log(file.toString());
                  await APIs.sendChatImage(widget.user, file);
                  setState(() => _isUploading = false);
                }
                _textController.clear();
              }
            },
            minWidth: 0,
            padding:
                const EdgeInsets.only(top: 10, bottom: 10, right: 5, left: 10),
            shape: const CircleBorder(),
            color: Colors.green,
            child: const Icon(
              Icons.send,
              color: Colors.white,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}

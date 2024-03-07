import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_we_chat/api/apis.dart';
import 'package:flutter_we_chat/main.dart';
import 'package:flutter_we_chat/models/chat_user.dart';
import 'package:flutter_we_chat/screens/all_user_screen..dart';
import 'package:flutter_we_chat/screens/profile_screen.dart';
import 'package:flutter_we_chat/widgets/chat_user_card.dart';

// home screen -- where all available contacts are shown
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // for storing all users
  List<ChatUser> _list = [];

  //for storing searched users
  final List<ChatUser> _searchList = [];
  // for storing search status
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    APIs.getSelfInfo();

    // for updating user active status according to lifecycle events
    // resume -- active or online
    // pause -- inactive or offline
    SystemChannels.lifecycle.setMessageHandler((message) {
      if (APIs.auth.currentUser != null) {
        if (message.toString().contains('resume')) {
          APIs.updateActiveStatus(true);
        } else if (message.toString().contains('inactive')) {
          APIs.updateActiveStatus(false);
        } else if (message.toString().contains('pause')) {
          APIs.updateActiveStatus(false);
        } else if (message.toString().contains('detached')) {
          APIs.updateActiveStatus(false);
        }
      }

      return Future.value(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // for hiding keyboard when a tap is detected on screen
      onTap: () => Focus.of(context).unfocus(),
      child: PopScope(
        // if search is on & back button is pressed then close search
        // or else simply close current screen on back button click
        canPop: !_isSearching,
        onPopInvoked: (didPop) {
          if (_isSearching) {
            setState(() {
              _isSearching = !_isSearching;
            });
          } else {}
        },
        child: Scaffold(
          //app bar
          appBar: AppBar(
            leading: InkWell(
                onTap: () {
                  if (_isSearching) {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (_) => const HomeScreen()));
                  }
                },
                child: const Icon(CupertinoIcons.home)),
            title: _isSearching
                ? TextField(
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Name, Email, ...',
                    ),
                    autofocus: true,
                    style: const TextStyle(fontSize: 17, letterSpacing: 0.5),
                    // when search text changes then update search list
                    onChanged: (val) {
                      // search logic
                      _searchList.clear();
                      for (var i in _list) {
                        if (i.name.toLowerCase().contains(val.toLowerCase()) ||
                            i.email.toLowerCase().contains(val.toLowerCase())) {
                          _searchList.add(i);
                        }
                        setState(() {
                          _searchList;
                        });
                      }
                    },
                  )
                : const Text('WeChat',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 23)),
            actions: [
              //search user button
              IconButton(
                onPressed: () {
                  _searchList.clear();
                  setState(() {
                    _isSearching = !_isSearching;
                  });
                },
                icon: Icon(_isSearching
                    ? CupertinoIcons.clear_circled_solid
                    : Icons.search),
              ),

              //more features button
              IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProfileScreen(
                          user: APIs.me,
                        ),
                      ));
                },
                icon: const Icon(Icons.person),
              ),
            ],
          ),

          //floating button to add new user
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AllUserScreen(),
                    ));
                // _addChatUserDialog();
              },
              child: const Icon(Icons.add_comment_rounded),
            ),
          ),

          body: StreamBuilder(
            stream: APIs.getMyUsersId(),

            // get id of only known users
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                // if data is loading
                case ConnectionState.waiting:
                case ConnectionState.none:
                  return const Center(
                    child: CircularProgressIndicator(),
                  );

                // if some or all data is loaded then show it
                case ConnectionState.active:
                case ConnectionState.done:
                  return StreamBuilder(
                    stream: APIs.getAllUsers(
                        snapshot.data?.docs.map((e) => e.id).toList() ?? []),

                    // get only those users, who's ids are provided
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        // if data is loading
                        case ConnectionState.waiting:
                        case ConnectionState.none:
                        // return const Center(
                        //   child: CircularProgressIndicator(),
                        // );

                        // if some or all data is loaded then show it
                        case ConnectionState.active:
                        case ConnectionState.done:
                          final data = snapshot.data?.docs;
                          _list = data
                                  ?.map((e) => ChatUser.fromJson(e.data()))
                                  .toList() ??
                              [];

                          if (_list.isNotEmpty) {
                            return ListView.builder(
                              padding: EdgeInsets.only(top: mq.height * .01),
                              physics: const BouncingScrollPhysics(),
                              itemCount: _isSearching
                                  ? _searchList.length
                                  : _list.length,
                              itemBuilder: (context, index) {
                                return ChatUserCard(
                                  user: _isSearching
                                      ? _searchList[index]
                                      : _list[index],
                                );
                              },
                            );
                          } else {
                            return const Center(
                              child: Text(
                                'No Connection Found!',
                                style: TextStyle(
                                  fontSize: 20,
                                ),
                              ),
                            );
                          }
                      }
                    },
                  );
              }
            },
          ),
        ),
      ),
    );
  }

  // dialog for adding new chat user
  // void _addChatUserDialog() {
  //   String email = '';
  //
  //   showDialog(
  //       context: context,
  //       builder: (_) => AlertDialog(
  //             contentPadding: const EdgeInsets.only(
  //                 left: 24, right: 24, top: 20, bottom: 10),
  //             shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(20),
  //             ),
  //
  //             // title
  //             title: const Row(
  //               children: [
  //                 Icon(
  //                   Icons.person_add,
  //                   color: Colors.blue,
  //                   size: 28,
  //                 ),
  //                 Text('  Add User'),
  //               ],
  //             ),
  //
  //             // content
  //             content: TextFormField(
  //               maxLines: null,
  //               onChanged: (value) => email = value,
  //               decoration: InputDecoration(
  //                 hintText: 'Email Id',
  //                 prefixIcon: const Icon(
  //                   Icons.email,
  //                   color: Colors.blue,
  //                 ),
  //                 border: OutlineInputBorder(
  //                   borderRadius: BorderRadius.circular(15),
  //                 ),
  //               ),
  //             ),
  //
  //             // actions
  //             actions: [
  //               // cancel button
  //               MaterialButton(
  //                 onPressed: () {
  //                   // hide alert dialog
  //                   Navigator.pop(context);
  //                 },
  //                 child: const Text(
  //                   'Cancel',
  //                   style: TextStyle(
  //                     color: Colors.blue,
  //                     fontSize: 16,
  //                   ),
  //                 ),
  //               ),
  //
  //               // update button
  //               MaterialButton(
  //                 onPressed: () async {
  //                   // hide alert dialog
  //                   Navigator.pop(context);
  //
  //                   if (email.trim().isNotEmpty) {
  //                     await APIs.addChatUser(email).then((value) {
  //                       if (!value) {
  //                         Dialogs.showSnackBar(context, 'User does not Exists');
  //                       }
  //                     });
  //                   }
  //                 },
  //                 child: const Text(
  //                   'Add',
  //                   style: TextStyle(
  //                     color: Colors.blue,
  //                     fontSize: 16,
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ));
  // }
}

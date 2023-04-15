import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:now_ui_flutter/models/dart_models.dart';
import 'package:now_ui_flutter/globals.dart' as globals;
import 'package:now_ui_flutter/providers/services.dart';
import 'package:provider/provider.dart';

class ChatDetail extends StatefulWidget {
  final String documentId;
  final String cabang;
  final int param;
  final String fcmToken;
  final int uidParam;

  const ChatDetail({
    Key key,
    this.documentId,
    this.cabang,
    this.param,
    this.fcmToken,
    this.uidParam,
  }) : super(key: key);
  @override
  _ChatDetailState createState() => _ChatDetailState();
}

class _ChatDetailState extends State<ChatDetail> {
  String messageText;

  TextEditingController chatMsgTextController = new TextEditingController();

  final _firestore = FirebaseFirestore.instance;

  String username;

  String email;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        flexibleSpace: SafeArea(
          child: Container(
            padding: EdgeInsets.only(right: 16),
            child: Row(
              children: <Widget>[
                IconButton(
                  onPressed: () {
                    // if (globals.loggedIn == false) {
                    //   showDialog<String>(
                    //       context: context,
                    //       builder: (context) {
                    //         return AlertDialog(
                    //           title: Text(
                    //             "Apakah anda yakin?",
                    //             style: TextStyle(fontWeight: FontWeight.bold),
                    //           ),
                    //           content: const Text(
                    //               'Apakah anda yakin? chat akan otomatis terhapus dan tidak akan menyimpan histori anda.'),
                    //           actions: <Widget>[
                    //             TextButton(
                    //               onPressed: () =>
                    //                   Navigator.pop(context, 'Cancel'),
                    //               child: const Text('Cancel'),
                    //             ),
                    //             TextButton(
                    //               onPressed: () async {
                    //                 await Navigator.pop(context, 'Ok');
                    //                 Navigator.of(context).pop();
                    //               },
                    //               child: const Text('OK'),
                    //             ),
                    //           ],
                    //         );
                    //       });
                    // } else {
                    Navigator.pop(context);
                    // }
                  },
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                  ),
                ),
                SizedBox(
                  width: 2,
                ),
                CircleAvatar(
                  backgroundImage: AssetImage("assets/imgs/user.png"),
                  maxRadius: 20,
                ),
                SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        widget.cabang,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(
                        height: 6,
                      ),
                      Text(
                        "Online",
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: Color.fromARGB(255, 212, 212, 212),
      body: new Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          new Expanded(
            child: new Material(
              color: Color.fromARGB(255, 212, 212, 212),
              child: StreamBuilder(
                stream: _firestore
                    .collection('conversations')
                    .doc(widget.documentId)
                    .collection('messages')
                    .orderBy('timestamp', descending: false)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasData) {
                    final messages = snapshot.data.docs;
                    List<ChatMessage> messageWidgets = [];
                    for (var message in messages) {
                      final msgText = message['message'];
                      final msgSender = message['sender'];
                      final currentUser = globals.loggedIn == true
                          ? globals.loggedinEmail
                          : widget.param.toString();
                      final dataTimestamp = message['timestamp'];

                      // print('MSG'+msgSender + '  CURR'+currentUser);
                      final msgBubble = ChatMessage(
                        msgText: msgText,
                        msgSender: msgSender,
                        user: currentUser == msgSender,
                        timestamp: dataTimestamp,
                      );
                      messageWidgets.add(msgBubble);
                    }
                    return ListView.builder(
                      itemCount: messageWidgets.length + 1,
                      controller: _scrollController,
                      shrinkWrap: true,
                      padding: EdgeInsets.only(top: 10, bottom: 10),
                      // physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        if (index == messageWidgets.length) {
                          return Container(
                            height: 70,
                          );
                        }
                        var dt = DateTime.fromMillisecondsSinceEpoch(
                            messageWidgets[index].timestamp);
                        var dateformat = DateFormat('dd MMM yyyy').format(dt);

                        bool visible = false;
                        if (index == 0) {
                          visible = true;
                        } else {
                          var timeStampitemBefore =
                              messageWidgets[index - 1].timestamp;
                          var dtTimestamp = DateTime.fromMicrosecondsSinceEpoch(
                              timeStampitemBefore * 1000);
                          var dtResultFormat =
                              DateFormat('dd MMM yyyy').format(dtTimestamp);
                          if (dateformat != dtResultFormat) {
                            visible = true;
                          }
                        }

                        return SingleChildScrollView(
                          child: Column(
                            children: [
                              if (visible)
                                Text(
                                  DateFormat('dd MMM yyyy').format(dt),
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontFamily: 'Poppins',
                                      color: Colors.black87),
                                  textAlign: TextAlign.right,
                                ),
                              Container(
                                padding: EdgeInsets.only(
                                    left: 14, right: 14, top: 10, bottom: 10),
                                child: Align(
                                  alignment: (messageWidgets[index].user
                                      ? Alignment.topRight
                                      : Alignment.topLeft),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: (messageWidgets[index].user
                                          ? Colors.blue[200]
                                          : Colors.grey.shade200),
                                    ),
                                    padding: EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          messageWidgets[index].msgText,
                                          style: TextStyle(fontSize: 15),
                                        ),
                                        Text(
                                          DateFormat('HH:mm').format(dt),
                                          textAlign: TextAlign.right,
                                          style: TextStyle(fontSize: 11),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  } else {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Material(
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.white,
                    child: Padding(
                      padding:
                          const EdgeInsets.only(left: 8.0, top: 2, bottom: 2),
                      child: TextField(
                        onChanged: (value) {
                          messageText = value;
                        },
                        controller: chatMsgTextController,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 10.0,
                            horizontal: 20.0,
                          ),
                          hintText: 'Ketik Pesan',
                          hintStyle: TextStyle(
                            fontFamily: 'Nunito-Medium',
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                ),
                MaterialButton(
                  shape: CircleBorder(),
                  color: Colors.blue,
                  onPressed: () async {
                    Map<String, Object> dataChat = {
                      'message': messageText,
                      'senderName': globals.loggedIn == true
                          ? globals.loggedinName
                          : "Guest",
                      'sender': globals.loggedIn == true
                          ? globals.loggedinEmail
                          : widget.param.toString(),
                      'timestamp': DateTime.now().millisecondsSinceEpoch,
                    };
                    _scrollController.animateTo(
                        _scrollController.position.maxScrollExtent,
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeOut);
                    _firestore
                        .collection('conversations')
                        .doc(widget.documentId)
                        .collection('messages')
                        .doc()
                        .set(dataChat);
                    await Provider.of<MasterProvider>(context, listen: false)
                        .sendPushMessage(
                      widget.fcmToken,
                      '${widget.cabang} : $messageText',
                      'TAS Orderan Admin',
                    );
                    chatMsgTextController.clear();
                    Provider.of<MasterProvider>(context, listen: false)
                        .storeChat(dataChat, widget.uidParam);
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Icon(
                      Icons.send,
                      color: Colors.white,
                    ),
                  ),
                  // Text(
                  //   'Send',
                  //   style: kSendButtonTextStyle,
                  // ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

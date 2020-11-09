import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatView extends StatefulWidget {
  @override
  _ChatViewState createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final messageController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("NearBy")),
      ),
          body: SafeArea(
                      child: Container(
        child: Column(
            children: <Widget>[
              Center(
                child: Container(
                  padding: EdgeInsets.only(top: 15, bottom: 10),
                  child: Text(
                    "Today, ${DateFormat("Hm").format(DateTime.now())}",
                    style: TextStyle(fontSize: 20, color: Colors.blue),
                  ),
                ),
              ),
              Flexible(
                child: ListView.builder(
                  reverse: true,
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return Card(child:Text("Hello World"));
                  },
                ),
              ),
              Divider(
                height: 5,
                color: Colors.greenAccent,
              ),
              Container(
                child: ListTile(
                  // leading: IconButton(icon: null, color: Colors.greenAccent,iconSize: 35, ),
                  title: Container(
                    height: 35,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                        color: Color.fromRGBO(220, 220, 220, 1)),
                    padding: EdgeInsets.only(left: 15),
                    child: TextFormField(
                      controller: messageController,
                      decoration: InputDecoration(
                        hintText: "Enter a message",
                        hintStyle: TextStyle(color: Colors.black26),
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                      ),
                      style: TextStyle(fontSize: 16, color: Colors.blue),
                    ),
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      Icons.send,
                      size: 30,
                      color: Colors.greenAccent,
                    ),
                    onPressed: () {
                      if (messageController.text.isEmpty) {
                        print("Empty Message");
                      } else {
                        setState(() {});
                      }
                    },
                  ),
                ),
              ),
            ],
        ),
      ),
          ),
    );
  }
}

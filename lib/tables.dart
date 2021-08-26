import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:http/http.dart' as http;
import 'package:timeago/timeago.dart' as timeago;

import 'inpformatter.dart';

class JustHomePage extends StatefulWidget {
  @override
  State createState() => _JustHomePageState();
}

class _JustHomePageState extends State<JustHomePage>
    with SingleTickerProviderStateMixin {
  final Firestore firestore = Firestore.instance;

  var minController = new TextEditingController();

  var maxController = new TextEditingController();

  final _amountValidator = RegExInputFormatter.withRegex(
      '^\$|^(0|([1-9][0-9]{0,}))(\\[0-9]{0,})?\$');

  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = new TabController(length: 2, vsync: this);

    fetchminandmaxvalues();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext bcontext) {
                      return Container(
                        height: MediaQuery.of(context).size.height / 2,
                        width: MediaQuery.of(context).size.width,
                        child: SingleChildScrollView(
                          child: Container(
                            height: MediaQuery.of(context).size.height / 2,
                            width: MediaQuery.of(context).size.width,
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(2, 8, 8, 8),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Spacer(),
                                        Center(
                                          child: FittedBox(
                                              child: Text(
                                            "Set min and max values",
                                            style: TextStyle(fontSize: 22),
                                          )),
                                        ),
                                        Spacer(),
                                        GestureDetector(
                                            onTap: () {
                                              Navigator.of(bcontext).pop();
                                            },
                                            child: Icon(Icons.close))
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Center(child: Text("Min : ")),
                                        Expanded(
                                          child: new TextField(
                                            autofocus: false,
                                            inputFormatters: [
                                              _amountValidator,
                                              LengthLimitingTextInputFormatter(
                                                  3),
                                            ],
                                            keyboardType:
                                                TextInputType.numberWithOptions(
                                              decimal: true,
                                              signed: false,
                                            ),
                                            controller: minController,
                                            maxLines: null,
                                            decoration: new InputDecoration(
                                              hintText: "Enter Min Value",
                                              labelText: 'Enter Min Value',
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Text("Max : "),
                                        Expanded(
                                          child: new TextField(
                                            autofocus: false,
                                            inputFormatters: [
                                              _amountValidator,
                                              LengthLimitingTextInputFormatter(
                                                  3),
                                            ],
                                            keyboardType:
                                                TextInputType.numberWithOptions(
                                              decimal: true,
                                              signed: false,
                                            ),
                                            controller: maxController,
                                            maxLines: null,
                                            decoration: new InputDecoration(
                                              hintText: "Enter Max Value",
                                              labelText: 'Enter Max Value',
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  RaisedButton(
                                    onPressed: () {
                                      if (minController.text.isNotEmpty &&
                                          maxController.text.isNotEmpty) {
                                        updateminandaxvalues();
                                      }
                                    },
                                    child: Text("Submit"),
                                  )
                                ]),
                          ),
                        ),
                      );
                    },
                  );
                },
                child: Icon(
                  Icons.settings,
                  color: Colors.grey[300],
                )),
          ),
        ],
        backgroundColor: Colors.black,
        title: new Text("Tables Check"),
        bottom: TabBar(
          unselectedLabelColor: Colors.white,
          labelColor: Colors.yellow,
          tabs: [
            new Tab(
              child: Text(
                "Wrong",
                textAlign: TextAlign.center,
              ),
            ),
            new Tab(
              child: Text("Right", textAlign: TextAlign.center),
            ),
          ],
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorSize: TabBarIndicatorSize.tab,
        ),
        bottomOpacity: 1,
      ),
      body: TabBarView(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: firestore
                .collection("wrong")
                .orderBy("time", descending: true)
                .where("time",
                    isGreaterThan: Timestamp.fromDate(
                        DateTime.now().subtract(Duration(days: 10))))
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              print("Someting");
              print(snapshot.hasData);
              print(snapshot.data.documents.length);

              if (snapshot.data == null || snapshot.data.documents.length < 1)
                return Center(
                    child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "nothing found",
                        textAlign: TextAlign.center,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ));
              final int messageCount = snapshot.data.documents.length;
              return Container(
                width: MediaQuery.of(context).size.width,
                child: ListView.separated(
                  itemCount: messageCount,
                  itemBuilder: (_, int index) {
                    final DocumentSnapshot document =
                        snapshot.data.documents[index];
                    final dynamic message = document['name'];
                    return SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Container(
                        color: Colors.grey[100],
                        child: Column(
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Text(
                                  "  Wrong",
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.w900),
                                ),
                                Spacer(),
                                Text("${document['ans']}"),
                                Spacer(),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                      "${timeago.format(document["time"].toDate())}"),
                                )
                              ],
                            ),
                            Divider(),
                          ],
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return Container(
                      height: 10,
                    );
                  },
                ),
              );
            },
          ),
          StreamBuilder<QuerySnapshot>(
            stream: firestore
                .collection("right")
                .orderBy("time", descending: true)
                .where("time",
                    isGreaterThan: Timestamp.fromDate(
                        DateTime.now().subtract(Duration(days: 10))))
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              print("Someting");
              print(snapshot.hasData);
              print(snapshot.data.documents.length);

              if (snapshot.data == null || snapshot.data.documents.length < 1)
                return Center(
                    child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "nothing found",
                        textAlign: TextAlign.center,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ));
              final int messageCount = snapshot.data.documents.length;
              return ListView.separated(
                itemCount: messageCount,
                itemBuilder: (_, int index) {
                  final DocumentSnapshot document =
                      snapshot.data.documents[index];
                  final dynamic message = document['name'];
                  return Container(
                    color: Colors.grey[100],
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Text(
                              "  Wrong",
                              style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w900),
                            ),
                            Spacer(),
                            Text("${document['ans']}"),
                            Spacer(),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                  "${timeago.format(document["time"].toDate())}"),
                            )
                          ],
                        ),
                        Divider(),
                      ],
                    ),
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return Container(
                    height: 10,
                  );
                },
              );
            },
          ),
        ],
        controller: _tabController,
      ),
    );
  }

  void updateToken() {
    FirebaseMessaging().subscribeToTopic("admin");
  }

  void fetchminandmaxvalues() {
    Firestore.instance
        .collection("admin")
        .document("settings")
        .get()
        .then((value) {
      print("values are ${value["min"]}");
      minController.text = "${value["min"]}";
      maxController.text = "${value["max"]}";
    });
  }

  void updateminandaxvalues() {
    Firestore.instance.collection("admin").document("settings").updateData({
      "min": int.parse(minController.text),
      "max": int.parse(maxController.text),
    }).then((value) {
      showToast("Done", Colors.green);
    });
  }

  void showToast(message, Color color) {
    print(message);
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 2,
        backgroundColor: color,
        textColor: Colors.white,
        fontSize: 16.0);
  }
}

// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//     FlutterLocalNotificationsPlugin();
//

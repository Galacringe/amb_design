import 'package:emergenshare_amb/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:restart_app/restart_app.dart';

class Hospital_Infomation extends StatefulWidget {
  const Hospital_Infomation({super.key});

  @override
  State<Hospital_Infomation> createState() => _Hospital_InfomationState();
}

Future<dynamic> _showDELETEDB(BuildContext context, String text, var doc) {
  return showDialog(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: Text('정보'),
      content: Text(
        text,
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
      ),
      actions: [
        ElevatedButton(onPressed: () {}, child: Text('확인')),
      ],
    ),
  );
}

void displayToast(String message, bool isBad) {
  if (isBad) {
    Fluttertoast.showToast(
        msg: message,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.redAccent,
        fontSize: 20,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_LONG);
  } else {
    Fluttertoast.showToast(
        msg: message,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.greenAccent,
        fontSize: 20,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_LONG);
  }
}

class _Hospital_InfomationState extends State<Hospital_Infomation>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      //do remove data
      firestore.collection("AMB").doc(doctem).delete().then((doc) {
        print("Deleted");
      }, onError: (e) => displayToast("Error: " + e, true));
    }
  }

  // 위 세 함수는 중간에 끌 시(절대로 백그라운드가 아님, 그것마저도 꺼질때) DB 지워주는거임

  var doctem;

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> _args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    var code = _args["code"];
    doctem = _args['doc'];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Row(
          children: [
            Text("병원 확인하기"),
            StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection("AMB")
                    .doc(doctem)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
                        snapshot) {
                  print(snapshot.connectionState);
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container();
                  }

                  try {
                    final docs = snapshot.data?["RESERVED"];
                    print(docs);
                    if (docs == true) {
                      // 탭바꾸기
                      print("tye");

                      WidgetsBinding.instance!.addPostFrameCallback((_) {
                        Navigator.of(context).pushNamed("/HR", arguments: {
                          'code': snapshot.data?['RESERVED_HOSPITAL_CODE'],
                          'doc': doctem,
                        });
                      });

                      return SizedBox();
                    }
                  } on StateError catch (e) {}

                  return SizedBox();

//Whatever extra code you put here friend, enter that here!
                })
          ],
        ),
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection("HOSPITAL")
              .doc(code.toString())
              .snapshots(),
          builder: (BuildContext context,
              AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
            print(snapshot.connectionState);
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Column(
                  children: [
                    Text("데이터를 수신하고 있습니다..."),
                    CircularProgressIndicator(),
                  ],
                ),
              );
            }
            try {
              return Container(
                child: Column(
                  children: [
                    Text(
                      snapshot.data?["NAME"],
                      style: TextStyle(
                        fontSize: 45,
                      ),
                    ),
                    Container(
                      height: 230,
                      width: 300,
                      child: Image.network(snapshot.data?["IMAGE"]),
                    ),
                    Text(snapshot.data?["INFO"]),
                    Text(
                      "현재 탐지된 인원 수 : " + snapshot.data?["PEOPLE_RES"],
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      "병상 수 " +
                          snapshot.data?["BED_RES"] +
                          "개 중 " +
                          snapshot.data?["USEABLE_BED_RES"] +
                          "개 가량 남은 것으로 추정됨",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      "혼잡도 현재 안내 : " + snapshot.data?["CROWD_VALUE"],
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                    ),
                    ListTile(
                        leading: Icon(Icons.apartment_rounded,
                            size: 70, color: Colors.black),
                        title: Row(
                          children: [
                            Text(snapshot.data?["ADDRESS"]),
                            IconButton(
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(
                                      text: snapshot.data?["ADDRESS"]));
                                  displayToast("복사되었습니다!", false);
                                },
                                tooltip: "복사하기",
                                icon: Icon(Icons.copy)),
                          ],
                        ),
                        subtitle: Row(
                          children: [
                            Text(snapshot.data?["CALL"]),
                            IconButton(
                                padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                constraints: BoxConstraints(),
                                onPressed: () {
                                  launchUrl(Uri.parse(
                                      "tel:" + snapshot.data?["CALL"]));
                                },
                                tooltip: "전화하기",
                                icon: Icon(Icons.call)),
                          ],
                        )),
                    SizedBox(
                      height: 50,
                    ),
                    Text("공지",
                        style: TextStyle(
                            fontSize: 30, fontWeight: FontWeight.w600)),
                    Container(
                      padding: EdgeInsets.all(13),
                      margin: EdgeInsets.all(10),
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: Color.fromARGB(235, 235, 235, 235),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(snapshot.data?["BROADCAST"],
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
              ); // 여기에 표시할거 쭉 짜면 됨
            } on StateError catch (e) {
              return Text("$e.toString()");
            }

            return SizedBox();
          }),
      bottomNavigationBar: BottomAppBar(),
    );
    ;
  }
}

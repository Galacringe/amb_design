import 'package:emergenshare_amb/main.dart';
import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Hospital_List extends StatefulWidget {
  const Hospital_List({super.key});

  @override
  State<Hospital_List> createState() => _Hospital_ListState();
}

class _Hospital_ListState extends State<Hospital_List>
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

  void displayToast(String message, bool isBad) {
    //토스트 메시지 표시
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

  Future<String> _checkDB(car) async {
    var res = await firestore
        .collection('AMB')
        .where("CAR", isEqualTo: int.parse(car))
        .get();

    return res.docs[0].id;
  }

  var doctem;

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> _args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    print(_args['car']);
    print(_args['name']);
    doctem = _args['car'] + _args['name'];
    print(doctem);
    final ambRef = firestore.collection("AMB");
    final myDB = ambRef
        .where("CAR", isEqualTo: _args["car"])
        .where("NAME", isEqualTo: _args["name"])
        .get();

    //AppBar에서 변동사항 확인 StreamBuilder
    //body에서 병원 실시간 표시 StreamBuilder
    return Scaffold(
      appBar: AppBar(
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
      body: Container(
        child: StreamBuilder(
          // * collection path : Collection / ID / Collection
          // * snapshots() : 데이터가 바뀔 때마다 받아옴
          stream:
              FirebaseFirestore.instance.collection('HOSPITAL/').snapshots(),
          // * AsyncSnapshot : Stream에서 가장 최신의 snapShot을 가져오기 위한 클래스
          builder: (BuildContext context,
              AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
            // * 데이터를 받아오기 전 대기 상태일 때 화면 처리
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final docs = snapshot.data!.docs;
            return ListView.builder(
              itemCount: docs.length, // * 데이터 갯수
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    isThreeLine: true,
                    title: Text(docs[index]['NAME']),
                    subtitle: Text(docs[index]['ADDRESS'] +
                        "\n" +
                        docs[index]["BROADCAST"]),
                    trailing: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: Colors.grey),
                      child: IconButton(
                        splashRadius: 28,
                        onPressed: () {
                          displayToast(docs[index]['NAME'], false);
                          WidgetsBinding.instance!.addPostFrameCallback((_) {
                            Navigator.of(context).pushNamed("/HI", arguments: {
                              'code': docs[index]['CODE'],
                              'doc': doctem,
                            });
                          });
                        },
                        tooltip: "병원 확인하기",
                        icon: Icon(
                          Icons.info,
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      bottomNavigationBar: BottomAppBar(),
    );
  }
}

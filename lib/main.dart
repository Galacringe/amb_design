import 'package:emergenshare_amb/widgets/tabs/hospital_info.dart';
import 'package:emergenshare_amb/widgets/tabs/hospital_reservation.dart';
import 'package:emergenshare_amb/widgets/tabs/hospital_list.dart';
import 'package:emergenshare_amb/widgets/tabs/patient_info.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

import 'package:fluttertoast/fluttertoast.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MaterialApp(
      title: "ESamb",
      home: MyApp(),
      theme: ThemeData(fontFamily: 'NotoSerifKR'),

      // 앱 이동 루트,  여기 없으면 새 .dart파일로 창 만들어도 이동 못함
      routes: {
        "/PI": (context) => const Patient_Info(),
        "/PH": (context) => const MyApp(),
        "/HL": (context) => const Hospital_List(),
        "/HI": (context) => const Hospital_Infomation(),
        "/HR": (context) => const Hospital_Reservation(),
      },
    ),
  );
}

final firestore = FirebaseFirestore.instance;

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _AppState();
}

class _AppState extends State<MyApp> {
  void displayToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.redAccent,
        fontSize: 20,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_LONG);
  }

  final _location = [
    '강남',
    '강동',
    '강서',
    '강북',
    '관악',
    '광진',
    '구로',
    '금천',
    '노원',
    '동대문',
    '도봉',
    '동작',
    '마포',
    '서대문',
    '성동',
    '성북',
    '서초',
    '송파',
    '영등포',
    '용산',
    '양천',
    '은평',
    '종로',
    '중',
    '중랑'
  ];

  var locationSelected = "강동";
  TextEditingController sender = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        toolbarHeight: 150,
        centerTitle: true,
        title: Column(
          children: [
            Text(
              "Welcome to EmergenShare!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 25),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              "시작하기 전, 정보를 알려주세요.",
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              "ES_amb_testBuild",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 8,
              ),
            ),
          ],
        ),
      ),
      body: Container(
        color: Colors.white,
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 40,
              ),
              Text(
                "현재 위치는 어디인가요?",
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("서울시  "),
                    DropdownButton(
                      value: locationSelected,
                      items: _location
                          .map((location) => DropdownMenuItem(
                              value: location, child: Text(location)))
                          .toList(),
                      onChanged: (location) {
                        setState(() {
                          locationSelected = location!;
                        });
                      },
                    ),
                    SizedBox(
                      width: 7,
                    ),
                    Text("구")
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                "구급차량 번호판 4자리를 적어주세요.",
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              SizedBox(
                width: 100,
                child: TextField(
                  controller: sender,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4)
                  ],
                  textAlign: TextAlign.center,
                ),
              )
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          height: 70,
          child: Column(
            children: [
              Container(
                height: 70,
                width: MediaQuery.of(context).size.width,
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(3)),
                child: TextButton(
                  child: Text(
                    "완료",
                    style: TextStyle(
                        fontWeight: FontWeight.w700, color: Colors.black),
                  ),
                  onPressed: () {
                    if (sender.text.length != 4) {
                      displayToast("올바르지 못한 양식입니다.");
                    } else {
                      // _sendDB(sender.text,
                      //     locationSelected); 실제로는 여기서 안보냄. 다음 페이지에서 보낼거임.
                      Navigator.of(context).pushNamed("/PI", arguments: {
                        "car": sender.text,
                        "location": locationSelected
                      });
                    }
                    print(locationSelected);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

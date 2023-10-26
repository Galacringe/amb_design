// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, curly_braces_in_flow_control_structures

import 'dart:convert';

import 'package:emergenshare_amb/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:fluttertoast/fluttertoast.dart';

class Patient_Info extends StatefulWidget {
  const Patient_Info({super.key});

  @override
  State<Patient_Info> createState() => _Patient_InfoState();
}

class _Patient_InfoState extends State<Patient_Info>
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
      firestore.collection("AMB").doc(carCode + patientName).delete().then(
          (doc) {
        print("Deleted");
      }, onError: (e) => displayToast("Error: " + e, true));
    }
  }

  // 위 세 함수는 중간에 끌 시(절대로 백그라운드가 아님, 그것마저도 꺼질때) DB 지워주는거임

  // 이름 나이
  TextEditingController patientName = TextEditingController();
  TextEditingController patientAge = TextEditingController();

  //KTAS 토글버튼
  var sliderValue = 1.0;
  List<bool> KTAS = [true, false, false, false, false];
  List<String> colors = [
    'Colors.blue',
    'Colors.red',
    'Colors.yellow',
    'Colors.green',
    'Colors.black'
  ];

  Color kc(double num) {
    switch (num) {
      case 1:
        return Colors.blue;
      case 2:
        return Colors.red;
      case 3:
        return Color.fromARGB(181, 255, 226, 59);
      case 4:
        return Colors.green;
      default:
        return Colors.black;
    }
  }

  //환자 정보 글
  TextEditingController patientInfo = TextEditingController();

  //혈액형
  final _bloodType = [
    "Rh+A",
    "Rh-A",
    "Rh+B",
    "Rh-B",
    "Rh+AB",
    "Rh-AB",
    "Rh+O",
    "Rh-O",
    "Rare",
    "???"
  ];
  var bloodTypeSelected = "???";

  // 태그 모음
  final _tags = [
    "화상",
    "동상",
    "외상",
    "수술 필요",
    "신경 마비",
    "파상풍 우려",
    "심장",
    "뇌손상",
    "절단",
    "관통",
    "무의식",
    "빈혈",
    "쇼크",
    "두통",
    "오한",
    "맹장염",
    "골절",
    "심한 출혈",
    "교통사고",
    "저체온증",
    "저혈압",
  ];
  String tags1 = "???";
  String tags2 = "???";
  String tags3 = "???";

  String? DBCAR;

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

  //KTAS 팝업
  Future<dynamic> _showKTAS(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('KTAS란?'),
        content: Text(
          "증상 중심 환자 분류 도구를 의미합니다.\n\n" +
              "1단계: 심정지 등 생명 위험 \n" +
              "2단계: 뇌출혈 등 생명 위협 가능성 \n" +
              "3단계: 호흡곤란 등 심각한 위협 가능성 \n" +
              "4단계: 착란 등 환자에 따라 2시간 내 치료 \n" +
              "5단계: 상처 소독 등 긴급하지 않은 상황 \n\n",
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        actions: [
          ElevatedButton(
              onPressed: () => Navigator.of(context).pop(), child: Text('확인')),
        ],
      ),
    );
  }

  Future<dynamic> _showTextPop(BuildContext context, String text) {
    return showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('정보'),
        content: Text(
          text,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        actions: [
          ElevatedButton(
              onPressed: () => Navigator.of(context).pop(), child: Text('확인')),
        ],
      ),
    );
  }

  Future<dynamic> _showPopDB(BuildContext context, String text, car, location) {
    return showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('정보'),
        content: Text(
          text,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        actions: [
          ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed("/HL", arguments: {
                  "name": patientName.text,
                  "car": car,
                });
              },
              child: Text('확인')),
        ],
      ),
    );
  }

  // DB 전송
  void _sendDB(
      car, location, name, ktas, info, blood, tag1, tag2, tag3, age) async {
    firestore.collection('AMB').doc('$car' + '$name').set({
      'CAR': car,
      'LOCATION': location,
      'NAME': name,
      "AGE": age,
      'KTAS': ktas,
      'INFO': info,
      'BLOOD': blood,
      'TAG1': tag1,
      'TAG2': tag2,
      'TAG3': tag3,
      'RESERVED': false,
      'RESERVED_HOSPITAL_CODE': 0
    });
  }

  void _checkDB(car, location) async {
    var res = await firestore
        .collection('AMB')
        .where("CAR", isEqualTo: int.parse(car))
        .where("NAME", isEqualTo: patientName.text)
        .get();

    try {
      print(res.docs[0].data()["INFO"]);
      firestore.collection("AMB").doc(res.docs[0].id).delete().then(
            (doc) => print("Document deleted"),
            onError: (e) => print("Error updating document $e"),
          );

      displayToast("초기화를 완료했습니다. 이제 등록해주세요", true);
      return;
    } on RangeError catch (e) {
      print(e);
      displayToast("저장되었습니다.", false);
      return;
    }
  }

  var carCode;

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> _args = ModalRoute.of(context)?.settings.arguments
        as Map<String, dynamic>; //매개변수 = 즉 번호랑 위치 받아온거
    //print(_args);
    carCode = _args["car"];
    var location = _args["location"];

    // 시작 시 기본으로 db 조회하고 존재 시 삭제
    //_checkDB(carCode, location);

    //displayToast(res, true);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("환자 정보"),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "환자 정보를 입력해주세요!",
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
              ),
              SizedBox(
                height: 8,
              ),
              Row(
                children: [
                  SizedBox(
                    width: 80,
                    height: 40,
                    child: TextField(
                      controller: patientName,
                      textAlignVertical: TextAlignVertical.bottom,
                      style:
                          TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
                      decoration: InputDecoration(
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          label: Text("이름"),
                          hintText: '이름'),
                      inputFormatters: [LengthLimitingTextInputFormatter(4)],
                    ),
                  ),
                  SizedBox(
                    width: 34,
                  ),
                  SizedBox(
                    width: 50,
                    height: 40,
                    child: TextField(
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(3)
                      ],
                      controller: patientAge,
                      textAlignVertical: TextAlignVertical.bottom,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                      ),
                      decoration: InputDecoration(
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          label: Text(
                            "나이",
                            style: TextStyle(
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          alignLabelWithHint: true),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Column(
                children: [
                  Row(
                    children: [
                      Text(
                        "환자 예상 KTAS 단계",
                        style: TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 16),
                      ),
                      SizedBox(
                        width: 7,
                      ),
                      Container(
                        height: 20,
                        width: 20,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.grey),
                        child: FloatingActionButton(
                          child: Icon(
                            Icons.question_mark_rounded,
                            size: 15,
                          ),
                          onPressed: () {
                            _showKTAS(context);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                  width: 335,
                  height: 40,
                  decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: Offset(0, 1),
                        )
                      ],
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(40)),
                  child: ToggleButtons(
                    renderBorder: false,
                    splashColor: Colors.transparent,
                    textStyle:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                    borderRadius: BorderRadius.circular(40),
                    fillColor: kc(sliderValue),
                    selectedColor: Colors.white,
                    isSelected: KTAS,
                    onPressed: (int index) {
                      setState(() {
                        for (int bi = 0; bi < KTAS.length; bi++) {
                          KTAS[bi] = bi == index;
                        }
                      });
                      sliderValue = double.parse((index + 1).toString());
                    },
                    children: [
                      Container(
                          width: 67,
                          alignment: Alignment.center,
                          child: Text('1')),
                      Container(
                        height: 30,
                        width: 67,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            border: Border(
                                left: BorderSide(color: Colors.black, width: 2),
                                right:
                                    BorderSide(color: Colors.black, width: 2))),
                        child: Text('2'),
                      ),
                      Container(
                          width: 67,
                          alignment: Alignment.center,
                          child: Text('3')),
                      Container(
                        height: 30,
                        width: 67,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            border: Border(
                                left:
                                    BorderSide(color: Colors.black, width: 2.3),
                                right:
                                    BorderSide(color: Colors.black, width: 2))),
                        child: Text('4'),
                      ),
                      Container(
                          width: 67,
                          alignment: Alignment.center,
                          child: Text('5'))
                    ],
                  )),
              SizedBox(
                height: 5,
              ),
              Text(
                "환자 상태정보",
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
              SizedBox(
                height: 5,
              ),
              Container(
                width: 350,
                height: 90,
                child: Container(
                  height: 70,
                  child: TextField(
                    maxLength: 150,
                    controller: patientInfo,
                    keyboardType: TextInputType.multiline,
                    maxLines: 3,
                    textAlign: TextAlign.start,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(150),
                    ],
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 8,
              ),
              Text(
                "혈액형",
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
              Row(
                children: [
                  DropdownButton(
                    value: bloodTypeSelected,
                    items: _bloodType
                        .map((location) => DropdownMenuItem(
                            value: location, child: Text(location)))
                        .toList(),
                    onChanged: (blood) {
                      setState(() {
                        bloodTypeSelected = blood!;
                      });
                    },
                  ),
                  Expanded(
                      flex: 1,
                      child: Container(
                          decoration: BoxDecoration(
                              border:
                                  Border.all(color: Colors.black, width: 3)),
                          height: 50,
                          child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _tags.length,
                              itemBuilder: (c, i) {
                                return TextButton(
                                    child: Text(_tags[i],
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 15)),
                                    onPressed: () {});
                              })))
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: ButtonBar(
          children: [
            ElevatedButton(
              onPressed: () {
                _checkDB(carCode, location);
              },
              child: Text("등록 전 저장하기"),
            ),
            ElevatedButton(
              child: Text("등록하기"),
              onPressed: () {
                try {
                  var id = _sendDB(
                      carCode,
                      location,
                      patientName.text,
                      sliderValue,
                      patientInfo.text,
                      bloodTypeSelected,
                      tags1,
                      tags2,
                      tags3,
                      patientAge.text);

                  _showPopDB(context, "등록이 완료되었습니다.", carCode, location);
                } catch (e) {
                  _showTextPop(context, "문제가 발생했습니다. \n" + e.toString());
                }
              },
            )
          ],
        ),
      ),
    );
  }
}

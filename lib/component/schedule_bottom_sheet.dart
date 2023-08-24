import 'package:flutter/material.dart';
import 'package:flutter_calendar_scheduler/const/colors.dart';
import 'package:flutter_calendar_scheduler/component/custom_text_field.dart';
// material.dart 패키지의 Column 클래스와 중복되니 드리프트에서는 숨기기
import 'package:drift/drift.dart' hide Column;
import 'package:get_it/get_it.dart';
import 'package:flutter_calendar_scheduler/database/drift_database.dart';


class ScheduleBottomSheet extends StatefulWidget {
  final DateTime selectedDate;
  final Schedule? schedule;

  const ScheduleBottomSheet({
    required this.selectedDate,
    this.schedule,
    Key? key
  }) : super(key: key);

  @override
  State<ScheduleBottomSheet> createState() => _ScheduleBottomSheetState();

}

class _ScheduleBottomSheetState extends State<ScheduleBottomSheet> {
  final GlobalKey<FormState> formKey = GlobalKey(); // 폼 key 생성


  int? startTime; // 시작 시간 저장 변수
  int? endTime;   // 종료 시간 저장 변수
  String? content;

  @override
  void initState() {
    super.initState();
    if(widget.schedule != null) {
      startTime = widget.schedule!.startTime;
      endTime   = widget.schedule!.endTime;
      content   = widget.schedule!.content;
    }

  } // 일정 내용 저장 변수



  @override
  Widget build(BuildContext context) {
    // 키보드 놓이 가져오기
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Form( // form tag로 싸기
      key:  formKey, //Form을 조작할 키값
      child: SafeArea(
          child: Container(
              height: MediaQuery.of(context).size.height / 2 + bottomInset,
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.only(left: 8, right: 8, top: 8, bottom:
                bottomInset),
                // 패딩에 키보드 높이 추가해서 위젯 전반적으로 위로 올려주기
                child: Column(
                  // 시간 관련 텍스트 필드와 내용 관련 텍스트 필드 세로로 배치
                  children: [
                    Row(
                      // 시작 시간 종료 시간 가로로 배치
                      children: [
                        Expanded(
                          child: CustomTextField( //시작 시간 입력 필드
                            timecontent: startTime.toString(),
                            schedule: widget.schedule,
                            label: '시작 시간',
                            isTime: true,
                            onSaved: (String? val) {
                              // 저장이 실행되면 startTime 변수에 텍스트 필드값 저장
                                startTime = int.parse(val!);
                            },
                            validator: timeValidator,
                          ),
                        ),
                        Expanded(
                            child: CustomTextField(// 종료 시간 입력 필드
                              timecontent: endTime.toString(),
                              schedule: widget.schedule,
                              label: '종료 시간',
                              isTime: true,
                              onSaved: (String? val) {
                                // 저장이 실행되면 endTime 변수에 텍스트 필드값 저장
                                endTime = int.parse(val!);
                              },
                              validator: timeValidator,
                            )
                        )
                      ],
                    ),
                    SizedBox(height: 8.0),
                    Expanded(
                      child: CustomTextField(
                        timecontent: content,
                        schedule: widget.schedule,
                        label: '내용',
                        isTime: false,
                        onSaved: (String? val){
                          content = val;
                        },
                        validator: contentValidator,
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: onSavePressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: PRIMARY_COLOR,
                        ),
                        child: Text('저장'),
                      ),
                    )
                  ],
                ),
              )
          )
      ),

    );
  }

  // _ScheduleBottomSheetState의 onSavePressed() 함수
  void onSavePressed() async {
    if(formKey.currentState!.validate()){ // 폼 검증하기
      formKey.currentState!.save();       // 폼 저장하기

      final localDb = GetIt.I<LocalDatabase>();
      if (widget.schedule != null) {
        await localDb.updateSchedule(SchedulesCompanion(
          id: Value(widget.schedule!.id),
          startTime: Value(startTime!),
          endTime: Value(endTime!),
          content: Value(content!),
          date: Value(widget.selectedDate),
        ));
      } else {
        await localDb.createSchedule(
          SchedulesCompanion(
            startTime: Value(startTime!),
            endTime: Value(endTime!),
            content: Value(content!),
            date: Value(widget.selectedDate),
          ),
        );
      }



      Navigator.of(context).pop(); // 일정 생성 후 화면 뒤로 가기


      //print(startTime);   // 시작 시간 출력
      //print(endTime);     // 종료 시간 출력
      //print(content);     // 내용 출력

    }

  }

  String? timeValidator(String? val) { // 시간 검증 함수
    if (val == null) {
      return '값을 입력해주세요';
    }
    int? number;

    try {
      number = int.parse(val);
    } catch(e) {
      return '숫자를 입력해주세요';
    }

    if (number < 0 || number > 24) {
      return '0시부터 24시 사이를 입력해주세요';
    }

    return null;
  }

  //미리 정의해둔 함수
  String? contentValidator(String? val) { // 내용 검증 함수
    if(val == null || val.length == 0) {
      return '값을 입력해주세요';
    }
    return null;
  }

}




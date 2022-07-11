import 'package:calender_scheduler_app/const/const.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final bool isTime;
  // true - 시간 , flase = 내용
  final String initialValue;

  final FormFieldSetter<String> onSaved;

  const CustomTextField({
    required this.label,
    required this.isTime,
    required this.onSaved,
    required this.initialValue,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: PRIMARY_COLOR,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (isTime) renderTextField(),
        if (!isTime) Expanded(child: renderTextField()),
      ],
    );
  }

  Widget renderTextField() {
    return TextFormField(
      onSaved: onSaved,// 상위 Form 위젯에서 Save 함수를 실행하면 불린다.

      validator: (String? val) {
        // null이 리턴되면 에러가 없다, 에러가 있으면 에러를 String값으로 리턴해준다.
        if (val == null || val.isEmpty) {
          return '값을 입력해주세요';
        }

        if (isTime) {
          int time = int.parse(val); // string -> int

          if (time < 0) {
            return '0 이상의 숫자를 입력해주세요';
          }

          if (time > 24) {
            return '24 이하의 숫자를 입력해주세요';
          }
        }
        return null;
      },
      maxLines: isTime ? 1 : null,
      maxLength: 500,
      // 500자 제한두기
      // 가능한 줄의 갯수 (줄바꿈)
      expands: !isTime,
      // 내용이면 TextField를 세로로 최대한 (부모의 높이만큼) 늘려준다
      cursorColor: Colors.grey,
      // 깜빡이는 커서 색깔
      keyboardType: isTime ? TextInputType.number : TextInputType.multiline,
      initialValue: initialValue,
      // 시간관련타입이면 숫자 키보드, 아니면 글자 키보드
      inputFormatters: isTime
          ? [
              FilteringTextInputFormatter.digitsOnly,
            ]
          : [],
      // TextInputType을 숫자로 했더라도 블루투스 키보드등을 써서 글자를 입력할수도 있으므로 시간이면 숫자만 입력가능하도록 제한을 둔다.
      decoration: InputDecoration(
        suffixText: isTime ? '시' : null,
        border: InputBorder.none, // border 없애기
        filled: true, // 색깔을 넣으려면 true로 세팅을 해줘야함
        fillColor: Colors.grey[300],
      ),
    );
  }
}

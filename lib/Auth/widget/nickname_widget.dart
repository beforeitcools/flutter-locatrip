import 'package:flutter/material.dart';
import 'package:flutter_locatrip/Auth/model/auth_model.dart';
import 'package:flutter_locatrip/Auth/widget/error_text_widget.dart';
import 'package:flutter_locatrip/common/widget/color.dart';

class NicknameWidget extends StatefulWidget {
  late Function nicknameValidCheckSetState;
  late Function nicknameAlreadyExistsCheckSetState;
  String? nicknameError;
  bool nicknameCheck;
  TextEditingController nicknameController;

  NicknameWidget({
    super.key,
    required this.nicknameValidCheckSetState,
    required this.nicknameAlreadyExistsCheckSetState,
    required this.nicknameError,
    required this.nicknameCheck,
    required this.nicknameController,
  });

  @override
  State<NicknameWidget> createState() => _NicknameWidgetState();
}

class _NicknameWidgetState extends State<NicknameWidget> {
  void _nicknameValidCheck(String nicknameInput) {
    widget.nicknameValidCheckSetState(nicknameInput);
  }

  void _nicknameAlreadyExistsCheck() {
    widget.nicknameAlreadyExistsCheckSetState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Row(
            children: [
              Text(
                "닉네임",
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: blackColor),
              ),
            ],
          ),
          SizedBox(
            height: 7,
          ),
          Container(
            height: 45,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: _nicknameValidCheck,
                    controller: widget.nicknameController,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(color: pointBlueColor)),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: lightGrayColor,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: pointBlueColor,
                          ),
                        ),
                        hintText: "닉네임 입력",
                        hintStyle:
                            Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: grayColor,
                                ),
                        contentPadding: EdgeInsets.fromLTRB(8, 0, 8, 0)),
                  ),
                ),
                SizedBox(
                  width: 16,
                ),
                TextButton(
                  onPressed: _nicknameAlreadyExistsCheck,
                  child: Text(
                    "중복확인",
                    style: Theme.of(context)
                        .textTheme
                        .labelMedium
                        ?.copyWith(color: blackColor),
                  ),
                  style: TextButton.styleFrom(
                    minimumSize: Size(88, 45),
                    backgroundColor: subPointColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 7,
          ),
          widget.nicknameError == null
              ? SizedBox()
              : Row(
                  children: [
                    ErrorTextWidget(
                      errorMessage: widget.nicknameError,
                    ),
                  ],
                )
        ],
      ),
    );
  }
}

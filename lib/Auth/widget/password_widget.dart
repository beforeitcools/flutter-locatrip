import 'package:flutter/material.dart';
import 'package:flutter_locatrip/common/widget/color.dart';

class PasswordWidget extends StatefulWidget {
  late Function passwordValidCheckSetState;
  late Function passwordCompareCheckSetState;
  TextEditingController pwController;
  TextEditingController pwCheckController;
  String? passwordError;
  String? passwordCheckError;

  PasswordWidget({
    super.key,
    required this.passwordValidCheckSetState,
    required this.passwordCompareCheckSetState,
    required this.pwController,
    required this.pwCheckController,
    required this.passwordError,
    required this.passwordCheckError,
  });

  @override
  State<PasswordWidget> createState() => _PasswordWidgetState();
}

class _PasswordWidgetState extends State<PasswordWidget> {
  void _passwordValidCheck(String passwordInput) {
    widget.passwordValidCheckSetState(passwordInput);
  }

  void _passwordCompareCheck(String passwordCheckInput) {
    widget.passwordCompareCheckSetState(passwordCheckInput);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Container(
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      "비밀번호",
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
                          onChanged: _passwordValidCheck,
                          controller: widget.pwController,
                          obscureText: true,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide:
                                      BorderSide(color: pointBlueColor)),
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
                              hintText: "비밀번호 입력",
                              hintStyle: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: grayColor,
                                  ),
                              contentPadding: EdgeInsets.fromLTRB(8, 0, 8, 0)),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 7,
                ),
                widget.passwordError == null
                    ? SizedBox()
                    : Row(
                        children: [
                          Flexible(
                              child: Wrap(
                            children: [
                              Text(widget.passwordError!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(color: Colors.red)),
                            ],
                          ))
                        ],
                      )
              ],
            ),
          ),
          SizedBox(
            height: 16,
          ),
          Container(
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      "비밀번호 확인",
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
                          onChanged: _passwordCompareCheck,
                          controller: widget.pwCheckController,
                          obscureText: true,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide:
                                      BorderSide(color: pointBlueColor)),
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
                              hintText: "비밀번호 재입력",
                              hintStyle: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: grayColor,
                                  ),
                              contentPadding: EdgeInsets.fromLTRB(8, 0, 8, 0)),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 7,
                ),
                widget.passwordCheckError == null
                    ? SizedBox()
                    : Row(
                        children: [
                          Text(widget.passwordCheckError!,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: Colors.red)),
                        ],
                      )
              ],
            ),
          )
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_locatrip/common/widget/color.dart';

class CustomDialog {
  static void show(BuildContext context, String contentMessage,
      String buttonText, VoidCallback onConfirm) {
    showDialog(
      context: context,
      barrierDismissible: false, // dialog 밖에 눌렀을때 닫힘 방지
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          contentPadding: EdgeInsets.zero,
          content: Container(
            width: MediaQuery.of(context).size.width - 50,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: pointBlueColor,
                        size: 50,
                      ),
                      SizedBox(height: 16),
                      Text(
                        contentMessage,
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: blackColor),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Material(
                        color: grayColor,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(10),
                        ),
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          splashColor: Color.fromARGB(50, 43, 192, 228),
                          highlightColor: Color.fromARGB(30, 43, 192, 228),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(10),
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            width: (MediaQuery.of(context).size.width - 50) / 2,
                            height: 48,
                            child: Text(
                              "취소",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Material(
                        color: pointBlueColor,
                        borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(10),
                        ),
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                            onConfirm();
                          },
                          splashColor: Color.fromARGB(90, 43, 192, 228),
                          highlightColor: Color.fromARGB(90, 43, 192, 228),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(10),
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            width: (MediaQuery.of(context).size.width - 50) / 2,
                            height: 48,
                            child: Text(
                              buttonText,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

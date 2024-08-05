import 'package:flutter/material.dart';

class CommonMethods {
  Widget header(int headerFlexValue, String headerTitle) {
    return Expanded(
      flex: headerFlexValue,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          color: Colors.blue.shade800,
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(
            headerTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget data(int dataFlexValue, Widget widget) {
    return Expanded(
      flex: dataFlexValue,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: widget,
        ),
      ),
    );
  }

  Widget tooltipData(int dataFlexValue, String text, String tooltipMessage) {
    return Expanded(
      flex: dataFlexValue,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Tooltip(
            message: tooltipMessage,
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}

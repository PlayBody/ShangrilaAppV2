// Copyright 2020, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
import 'package:flutter/material.dart';
import 'package:shangrila/src/common/const.dart';
import 'package:shangrila/src/common/functions/datetimes.dart';

import '../../../common/globals.dart' as global;

class MyConnetStampBar extends StatelessWidget implements PreferredSizeWidget {
  const MyConnetStampBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      toolbarHeight: 70,
      backgroundColor: Colors.white,
      elevation: 4,
      titleSpacing: 0,
      title: Container(
        padding: EdgeInsets.only(left: 24),
        alignment: Alignment.centerLeft,
        height: 70,
        child: Text(
          global.userName,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 49, 49, 49),
          ),
        ),
      ),
      actions: [
        Container(
          alignment: Alignment.center,
          child: Text(
            DateTimes().dateFormatMonthAndDay(global.userBirthday),
            style: TextStyle(
              color: Color.fromARGB(255, 49, 49, 49),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(width: 12),
        Container(
          margin: EdgeInsets.symmetric(vertical: 16),
          alignment: Alignment.center,
          width: 38,
          height: 28,
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 33, 97, 172),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            global.dayStampCnt.toString(),
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
        SizedBox(width: 8),

        ElevatedButton(
          onPressed: () => Scaffold.of(context).openDrawer(),
          style: ElevatedButton.styleFrom(
            visualDensity: VisualDensity(horizontal: -2),
            padding: EdgeInsets.all(0),
            elevation: 0,
          ),
          child: Container(
            width: 70,
            height: 70,
            color: primaryColor,
            child: Icon(Icons.menu, color: Colors.white, size: 28),
          ),
        ),
      ],
    );
  }
}

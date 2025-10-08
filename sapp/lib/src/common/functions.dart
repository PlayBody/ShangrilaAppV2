import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common/globals.dart' as globals;

class Funcs {
  Future<void> logout(BuildContext context) async {
    globals.userId = '';
    globals.userName = '';

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('is_shangrila_login_id', '');

    // ignore: use_build_context_synchronously
    Navigator.pushNamed(context, '/Home');
  }

  // bool orderInputListAdd(BuildContext context, MenuReserveModel item) {
  //   if (globals.orderReserveMenus.length >= 10) {
  //     Dialogs().infoDialog(context, warningOrderReserveMenuMax);
  //     return false;
  //   }
  //   if (item.menuId == null) {
  //     globals.orderReserveMenus.add(item);
  //   } else {
  //     List<MenuReserveModel> reserveList = [];
  //     bool isExist = false;
  //     globals.orderReserveMenus.forEach((element) {
  //       if (element.menuId == item.menuId &&
  //           element.variationId == item.variationId) {
  //         reserveList.add(MenuReserveModel(
  //             menuTitle: item.menuTitle,
  //             quantity: (int.parse(element.quantity) + int.parse(item.quantity))
  //                 .toString(),
  //             menuPrice: item.menuPrice,
  //             menuId: item.menuId,
  //             variationId: item.variationId));
  //         isExist = true;
  //       } else {
  //         reserveList.add(element);
  //       }
  //     });
  //     if (!isExist) {
  //       reserveList.add(item);
  //     }
  //     globals.orderReserveMenus = reserveList;
  //   }
  //   return true;
  // }

  String getTimeFormatHHMM(DateTime? time) {
    if (time == null) return '設定なし';

    String hour =
        time.hour < 10 ? '0${time.hour}' : time.hour.toString();
    String min = time.minute < 10
        ? '0${time.minute}'
        : time.minute.toString();

    return '$hour:$min';
  }

  String getTimeFormatHMM00(DateTime? time) {
    if (time == null) return '設定なし';

    String hour = time.hour.toString();
    String min = time.minute < 10
        ? '0${time.minute}'
        : time.minute.toString();

    return '$hour:$min:00';
  }

  bool isNumeric(String string) {
    final numericRegex = RegExp(r'^-?(([0-9]*)|(([0-9]*)\.([0-9]*)))$');

    return numericRegex.hasMatch(string);
  }

  String dateFormatJP1(String? dateString) {
    if (dateString == null) return '';
    DateTime date = DateTime.parse(dateString);
    return '${date.year}年${date.month}月${date.day}日';
  }

  String dateFormatHHMMJP(String? dateString) {
    if (dateString == null) return '';
    DateTime date = DateTime.parse(dateString);
    return '${date.hour}時${date.minute}分';
  }

  String dateTimeFormatJP1(String? dateString) {
    if (dateString == null) return '';
    DateTime date = DateTime.parse(dateString);
    return '${date.month}月${date.day}日${date.hour}時${date.minute}分';
  }

  String dateTimeFormatJP2(String? dateString) {
    if (dateString == null) return '';
    return '${int.parse(dateString.split(":")[0])}時間${int.parse(dateString.split(":")[1])}分';
  }

  List<String> getYearSelectList(String min, String max) {
    List<String> results = [];

    for (int i = int.parse(min); i <= int.parse(max); i++) {
      results.add(i.toString());
    }
    return results;
  }

  List<String> getMonthSelectList() {
    List<String> results = [];

    for (int i = 1; i <= 12; i++) {
      results.add(i.toString());
    }
    return results;
  }

  List<String> getDaySelectList(String? year, String? month) {
    List<String> results = [];
    int maxDay = 31;

    if (year != null && month != null) {
      if (month == '12') {
        year = (int.parse(year) + 1).toString();
        month = '01';
      } else {
        month = (int.parse(month) + 1).toString();
        if (int.parse(month) < 10) month = '0$month';
      }
      DateTime nextMonthFirstDate = DateTime.parse('$year-$month-01');
      DateTime monthLastDate = nextMonthFirstDate.subtract(Duration(days: 1));
      maxDay = monthLastDate.day;
    }
    for (int i = 1; i <= maxDay; i++) {
      results.add(i.toString());
    }
    return results;
  }

  int getMaxDays(String? year, String? month) {
    int maxDay = 31;

    if (year != null && month != null) {
      if (month == '12') {
        year = (int.parse(year) + 1).toString();
        month = '01';
      } else {
        month = (int.parse(month) + 1).toString();
        if (int.parse(month) < 10) month = '0$month';
      }
      DateTime nextMonthFirstDate = DateTime.parse('$year-$month-01');
      DateTime monthLastDate = nextMonthFirstDate.subtract(Duration(days: 1));
      maxDay = monthLastDate.day;
    }
    return maxDay;
  }

  List<String> getMiniuteSelectList(
      String? min, String? max, String? dur, bool isEmpty) {
    List<String> results = [];
    if (isEmpty) results.add('');
    int fromT = min == null ? 0 : int.parse(min);
    int toT = max == null ? 90 : int.parse(max);
    int stepT = dur == null ? 5 : int.parse(dur);

    for (int i = fromT; i <= toT; i = i + stepT) {
      results.add(i.toString());
    }
    return results;
  }

  String currencyFormat(String value) {
    bool isMinus = false;
    //print(int.parse(value));
    if (int.parse(value) < 0) isMinus = true;
    String param = value.replaceAll('-', '');

    String result = '';

    int length = param.length;
    if (length < 4) return isMinus ? ('-$param') : param;

    int commaCount = length ~/ 3;
    int mod = length % 3;

    if (mod == 0) {
      commaCount--;
      mod = 3;
    }
    for (var i = 0; i <= commaCount; i++) {
      if (i == 0) {
        result = param.substring(0, mod);
      } else {
        result = '$result,${param.substring((i - 1) * 3 + mod, i * 3 + mod)}';
      }
    }

    //print(isMinus);
    return isMinus ? ('-$result') : result;
  }
}

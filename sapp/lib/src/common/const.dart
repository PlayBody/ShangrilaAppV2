import 'package:flutter/material.dart';

// ---------------- Store URL -----------------------
const String consAndroidStore =
    'https://play.google.com/store/apps/details?id=cloud.connect.shangrila';
const String consIOSStore = 'https://apps.apple.com/jp/app/%E3%82%B7%E3%83%A3%E3%83%B3%E3%82%B0%E3%83%AA%E3%83%A9/id1601232466?l=en-US';
const String consPrivacyPolicy = 'https://devotion-co.jp/privacy/';

const int constIsTestApi = 0;

const String APPCOMANYID = '1';
const String APPDOMAIN = 'conceptbar.info';
const String APPCOMPANYTITLE = 'シャングリラグループ';

// const String RESERVE_REQUEST = '1';
// const String RESERVE_APPLY = '2';
// const String RESERVE_REJECT = '3';
// const String RESERVE_CANCEL = '4';
// const String RESERVE_ENTERING = '5';
// const String RESERVE_COMPLETE = '6';

List<String> weekAry = ['月', '火', '水', '木', '金', '土', '日'];

List<dynamic> constSex = [
  {'value': '1', 'label': '男'},
  {'value': '2', 'label': '女'},
];

var primaryColor = Color(0xff0b75b3);
String errServerString = "システムエラーが発生しました。";
String errNetworkString =
    "通信ができませんでした。\nご使用端末の通信環境をご確認ください。\n通信環境を改善しても本メッセージが表示される場合はサポートへご連絡をお願いします";

const String ORDER_STATUS_NONE = '0';
const String ORDER_STATUS_RESERVE_REQUEST = '1';
const String ORDER_STATUS_RESERVE_REJECT = '2';
const String ORDER_STATUS_RESERVE_CANCEL = '3';
const String ORDER_STATUS_RESERVE_APPLY = '4';
const String ORDER_STATUS_TABLE_REJECT = '5';
const String ORDER_STATUS_TABLE_START = '6';
const String ORDER_STATUS_TABLE_END = '7';
const String ORDER_STATUS_TABLE_COMPLETE = '8';

String constCheckinTypeNone = '0';
String constCheckinTypeBoth = '1';
String constCheckinTypeOnlyReserve = '2';

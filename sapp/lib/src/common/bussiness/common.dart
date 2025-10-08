import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shangrila/src/http/webservice.dart';
import 'package:shangrila/src/model/home_menu_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../apiendpoint.dart';
import '../const.dart';

class ClCommon {

  Future<bool> loadAppVersion(context) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    Map<dynamic, dynamic> results = {};

    String apiUrl = '$apiBase/api/loadAppVersion';
    await Webservice().loadHttp(context, apiUrl, {
      'app_id': packageInfo.packageName,
      'os_type': Platform.operatingSystem
    }).then((v) => {results = v});

    // if (constIsTestApi == 1) {
    //   return true;
    // }

    String testFlag = results['test_flag'] ?? '0';
    if (testFlag == '1' ||
        (packageInfo.version == results['version'] &&
            packageInfo.buildNumber == results['build'])) {
      return true;
    } else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool('is_old_run', false);
      return false;
    }
  }

  Future<bool> isNetworkFile(context, String path, String? fileUrl) async {
    if (fileUrl == null) return false;
    String apiUrl = '$apiBase/api/isFileCheck';

    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(
        context, apiUrl, {'path': path + fileUrl}).then((v) => {results = v});

    if (results['isFile'] == null) {
      return false;
    }
    return results['isFile'];
  }

  Future<List<HomeMenuModel>> loadConnectHomeMenu(context) async {
    Map<dynamic, dynamic> results = {};
    String apiUrl = '$apiBase/api/loadConnectHomeMenuSetting';
    await Webservice().loadHttp(context, apiUrl,
        {'company_id': APPCOMANYID}).then((value) => results = value);

    List<HomeMenuModel> homeMenus = [];
    if (results['isLoad']) {
      for (var item in results['menus']) {
        homeMenus.add(HomeMenuModel.fromJson(item));
      }
    }
    return homeMenus;
  }

  Future<int> loadBadgeCount(context, dynamic param) async {
    Map<dynamic, dynamic> results = {};
    String apiUrl = '$apiBase/api/loadBadgeCount';
    await Webservice().loadHttp(context, apiUrl,
        {'condition': jsonEncode(param)}).then((value) => results = value);

    return int.parse(results['badge_count'].toString());
  }

  Future<bool> clearBadge(context, dynamic param) async {
    String apiUrl = '$apiBase/api/clearBadgeCount';
    await Webservice()
        .loadHttp(context, apiUrl, {'condition': jsonEncode(param)});

    return true;
  }

  Future<bool> isNewSale(context, String userId) async {
    Map<dynamic, dynamic> results = {};
    if (kDebugMode) {
      print(apiNewSaleUrl);
      print(userId);
    }
    await Webservice()
        .loadHttp(context, apiNewSaleUrl, {'user_id': userId}).then((value) => results = value);

    return results['is_new'] ?? false;
  }
}

import 'dart:async';
import 'dart:io';
import 'package:shangrila/src/common/bussiness/common.dart';
import 'package:shangrila/src/common/bussiness/company.dart';
import 'package:shangrila/src/common/bussiness/user.dart';
import 'package:shangrila/src/common/const.dart';
import 'package:shangrila/src/common/dialogs.dart';
import 'package:shangrila/src/common/messages.dart';
import 'package:shangrila/src/interface/connect/connect_login.dart';
import 'package:shangrila/src/interface/connect/password_reset.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shangrila/src/interface/connect/connect_register.dart';
import 'package:shangrila/src/model/companymodel.dart';
import 'package:shangrila/src/model/usermodel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:square_in_app_payments/in_app_payments.dart';
import 'package:url_launcher/url_launcher.dart';

import 'src/interface/connect/connect_home.dart';
import 'src/interface/connect/license.dart';
import 'src/common/globals.dart' as globals;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FlutterDownloader.initialize();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky)
      .then((_) => runApp(MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
        child: MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('ja'),
        const Locale('en'),
      ],
      locale: const Locale('ja'),
      debugShowCheckedModeBanner: false,
      title: 'Shangri-la',
      theme: ThemeData(primarySwatch: Colors.blueGrey),
      home: AppInit(), //ConnectRegister(), //AdminHome(), //AppInit(),
      routes: <String, WidgetBuilder>{
        '/Home': (BuildContext context) => ConnectHome(),
        '/Login': (BuildContext context) => ConnectLogin(),
        '/License': (BuildContext context) => LicenseView(),
        '/Register': (BuildContext context) => ConnectRegister(),
        '/Reset': (BuildContext context) => PasswordReset(),
      },
    ));
  }
}

class AppInit extends StatefulWidget {
  const AppInit({super.key});

  @override
  _AppInit createState() => _AppInit();
}

class _AppInit extends State<AppInit> {
  late Future<List> loadData;

  Future<void>? launched;
  @override
  void initState() {
    super.initState();
    _initSquarePayment();
    loadData = loadAppData();
  }

  Future<void> _initSquarePayment() async {
    CompanyModel company =
        await ClCompany().loadCompanyInfo(context, APPCOMANYID);
    globals.squareToken = company.squareToken;
    await InAppPayments.setSquareApplicationId(company.squareApplicationId);
  }

  Future<List> loadAppData() async {
    
    bool isVersionOK = await ClCommon().loadAppVersion(context);

    if (isVersionOK) {
      /*if (await isFirstTime()) {
        // ignore: use_build_context_synchronously
        Navigator.pushNamed(context, '/License');
      } else {
        // ignore: use_build_context_synchronously
        Navigator.pushNamed(context, '/Login');
      }*/
    } else {
      bool conf =
          // ignore: use_build_context_synchronously
          await Dialogs().oldVersionDialog(context, warningVersionUpdate);
      if (conf) {
        launched = _launchInBrowser();
        return [];
      }
    }

    String? deviceToken;
    
    // Request notification permissions (required for iOS)
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    
    if (Platform.isIOS) {
      // Wait for APNS token to be available
      int retries = 0;
      while (retries < 10) {
        String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
        if (apnsToken != null) {
          break;
        }
        await Future.delayed(Duration(milliseconds: 500));
        retries++;
      }
    }
    
    deviceToken = await FirebaseMessaging.instance
        .getToken()
        .then((token) => deviceToken = token);
    deviceToken ??= 'LocalDevice';
    globals.connectDeviceToken = deviceToken!; // == null ? '' : deviceToken!;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String saveUserId = prefs.getString('is_shangrila_login_id') ?? '';

    if (saveUserId != '') {
      UserModel user = await ClUser().getUserFromId(context, saveUserId);
      if (user.userId != '') {
        globals.userId = user.userId.toString();
        globals.userName = user.userNick;
        globals.userBirthday = user.userBirth;
      }
    }

    bool? isAgreeLicense = prefs.getBool('is_shangrila_agree_license') ?? false;
    if (isAgreeLicense) {
      Navigator.pushNamed(context, '/Home');
    } else {
      Navigator.pushNamed(context, '/License');
    }
    return [];
  }

  Future<void> _launchInBrowser() async {
    String url = Platform.isAndroid ? consAndroidStore : consIOSStore;
    launchUrl(Uri.parse(url));
  }
  
  Future<bool> isFirstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('is_old_run') == null ||
        prefs.getBool('is_old_run') == false) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: FutureBuilder<List>(
          future: loadData,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Container();
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            // By default, show a loading spinner.
            return Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}

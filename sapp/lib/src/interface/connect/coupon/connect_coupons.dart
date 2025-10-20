import 'package:shangrila/src/common/apiendpoint.dart';
import 'package:shangrila/src/common/bussiness/company.dart';
import 'package:shangrila/src/common/bussiness/stamps.dart';
import 'package:shangrila/src/common/bussiness/user.dart';
import 'package:shangrila/src/common/dialogs.dart';
import 'package:shangrila/src/common/functions.dart';
import 'package:shangrila/src/http/webservice.dart';
import 'package:shangrila/src/interface/component/form/main_form.dart';
import 'package:shangrila/src/interface/component/text/header_text.dart';
import 'package:shangrila/src/interface/connect/layout/header_stamp.dart';
import 'package:shangrila/src/model/couponmodel.dart';
import 'package:shangrila/src/model/rankmodel.dart';
import 'package:shangrila/src/model/stampmodel.dart';
import 'package:flutter/material.dart';
import 'package:shangrila/src/model/usermodel.dart';
import '../../../common/const.dart';
import '../../../common/globals.dart' as globals;
import 'package:carousel_slider/carousel_slider.dart';

class ConnectCoupons extends StatefulWidget {
  const ConnectCoupons({Key? key}) : super(key: key);

  @override
  _ConnectCoupons createState() => _ConnectCoupons();
}

class _ConnectCoupons extends State<ConnectCoupons> {
  late Future<List> loadData;

  List<CouponModel> coupons = [];
  List<StampModel> stamps = [];
  String openCouponId = '';
  int stampCount = 10;
  int _current = 0;
  List<RankModel> ranks = [];
  int prevCnt = 0;
  int goldLevel = 0;

  @override
  void initState() {
    super.initState();
    loadData = loadCouponData();
  }

  Future<void> updateCouponUseFlag(String userCouponId) async {
    bool conf = await Dialogs().confirmDialog(context, '使用しますか？');
    if (!conf) {
      return;
    }
    Map<dynamic, dynamic> results = {};
    await Webservice()
        .loadHttp(context, apiUpdateUserCouponUseFlagUrl, {
          'user_coupon_id': userCouponId,
        })
        .then((value) => results = value);
    if (results['isLoad']) {
      final updateResult = results['updateResult'];
      if (updateResult) {
        await loadCouponData();
        setState(() {});
      }
      print(updateResult);
    }
  }

  Future<void> deleteUserCoupon(String userCouponId) async {
    bool conf = await Dialogs().confirmDialog(context, 'このクーポンを削除しますか？');
    if (!conf) {
      return;
    }
    Map<dynamic, dynamic> results = {};
    await Webservice()
        .loadHttp(context, apiDeleteUserCouponUrl, {
          'user_coupon_id': userCouponId,
        })
        .then((value) => results = value);
    if (results['isDelete']) {
      await loadCouponData();
      setState(() {});
      // Show success message
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('クーポンを削除しました')));
    } else {
      // Show error message
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('クーポンの削除に失敗しました')));
    }
  }

  Future<List> loadCouponData() async {
    globals.dayStampCnt = await ClCoupon().loadDayStampCount(
      context,
      globals.userId,
    );

    // ranks = await ClCoupon().loadRanks(context, '5');
    prevCnt = await ClCompany().loadPrevStampCount(
      context,
      APPCOMANYID,
      globals.userRank!.level,
    );

    stampCount = globals.userRank == null
        ? 5
        : int.parse(globals.userRank!.maxStamp);

    stamps = await ClCoupon().loadUserStamps(context, globals.userId);

    Map<dynamic, dynamic> results = {};
    await Webservice()
        .loadHttp(context, apiLoadUserCouponsUrl, {'user_id': globals.userId})
        .then((value) => results = value);

    print(apiLoadUserCouponsUrl);
    print(globals.userId);

    coupons = [];
    if (results['isLoad']) {
      for (var item in results['coupons']) {
        coupons.add(CouponModel.fromJson(item));
      }
    }

    UserModel user = await ClUser().getUserFromId(context, globals.userId);
    goldLevel = user.goldLevel;

    setState(() {});
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return MainForm(
      title: 'スタンプ・クーポン',
      header: MyConnetStampBar(),
      render: FutureBuilder<List>(
        future: loadData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Center(
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Container(
                    //   child: DropDownModelSelect(items: [
                    //     ...ranks.map((e) => DropdownMenuItem(
                    //           child: Text(e.rankName),
                    //           value: e.rankId,
                    //         ))
                    //   ], tapFunc: (v) {}),
                    // ),
                    _getCoupons(),
                    SizedBox(height: 8),
                    // _getCardUserButton(),
                    // SizedBox(height: 25),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Header3Text(label: '使用可能なクーポン一覧'),
                            _getCouponContent(),
                            SizedBox(height: 40),
                            Header3Text(label: 'スタンプ特典'),
                            _getBenefitContent(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }
          // By default, show a loading spinner.
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  var txtTitleStyle = TextStyle(fontSize: 22, fontWeight: FontWeight.bold);
  var txtContentStyle = TextStyle(fontSize: 16);

  Widget _getCoupons() {
    int slideCnt = (stampCount <= 10) ? 1 : (stampCount - 1) ~/ 10 + 1;
    List<int> slideItems = [];
    for (int i = 1; i <= slideCnt; i++) slideItems.add(i);
    return Container(
      color: Color(0Xff749b88),
      child: Column(
        children: [
          CarouselSlider(
            options: CarouselOptions(
              viewportFraction: 1,
              height: 220,
              onPageChanged: (index, reason) {
                setState(() {
                  _current = index;
                });
              },
            ),
            items: slideItems.map((ii) {
              return Builder(
                builder: (BuildContext context) {
                  return Container(
                    padding: EdgeInsets.only(top: 8),
                    child: GridView.count(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      padding: EdgeInsets.all(30),
                      crossAxisCount: 5,
                      crossAxisSpacing: 18,
                      mainAxisSpacing: 18,
                      childAspectRatio: 0.7,
                      children: [
                        for (int i = 10 * (ii - 1) + 1; i <= 10 * ii; i++)
                          if (i <= stampCount)
                            Column(
                              children: [
                                Container(
                                  child: Text(
                                    i <= stamps.length
                                        ? stamps[i - 1].createDate
                                        : '',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                Container(
                                  height: 50,
                                  alignment: Alignment.center,
                                  child: i <= stamps.length
                                      ? null
                                      // Icon(Icons.card_giftcard_outlined,
                                      //     color: Colors.white, size: 32)
                                      : Text(
                                          (i + prevCnt).toString(),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 24,
                                          ),
                                        ),
                                  decoration: BoxDecoration(
                                    image: (i <= stamps.length)
                                        ? DecorationImage(
                                            image: NetworkImage(
                                              apiRenderPrintLogo +
                                                  stamps[i - 1].organId,
                                            ),
                                            fit: BoxFit.fill,
                                          )
                                        : null,
                                    color:
                                        ((i <= stamps.length &&
                                                stamps[i - 1].useflag
                                                        .toString() ==
                                                    '1') ||
                                            i > stamps.length)
                                        ? Colors.transparent
                                        : Color.fromARGB(255, 255, 255, 255),
                                    border: Border.all(
                                      color: Color(0xFFf3f3f3),
                                    ),
                                    borderRadius: BorderRadius.circular(60),
                                  ),
                                ),
                              ],
                            ),
                      ],
                    ),
                  );
                },
              );
            }).toList(),
          ),
          if (goldLevel > 0)
            Container(
              padding: EdgeInsets.only(right: 32),
              alignment: Alignment.centerRight,
              child: Text(
                '${globals.userRank!.rankName} ${goldLevel}',
                style: TextStyle(color: Colors.white),
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...slideItems.map(
                (e) => Container(
                  width: 12.0,
                  height: 12.0,
                  margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 4.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (_current + 1) == e
                        ? Color.fromRGBO(0, 0, 0, 0.6)
                        : Color.fromRGBO(0, 0, 0, 0.2),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget _getCardUserButton() {
  //   return Container(
  //     padding: EdgeInsets.only(left: 30, right: 30),
  //     child: ElevatedButton(
  //       child: Text('スタンプを使う'),
  //       onPressed: () {
  //         Navigator.push(context, MaterialPageRoute(builder: (_) {
  //           return ConnectCouponConfirm();
  //         }));
  //       },
  //     ),
  //   );
  // }

  Widget _getCouponContent() {
    return Container(
      padding: EdgeInsets.only(left: 30, right: 30),
      child: SingleChildScrollView(
        child: Column(children: [...coupons.map((e) => _getCouponItem(e))]),
      ),
    );
  }

  Widget _getBenefitContent() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 24),
      padding: EdgeInsets.only(left: 30, right: 30),
      child: Text('', style: txtContentStyle),
    );
  }

  Widget _getCouponItem(coupon) {
    return Container(
      margin: new EdgeInsets.symmetric(vertical: 12.0),
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: coupon.isUserUseFlag ? Colors.grey : Colors.blueGrey,
        ),
      ),
      child: Column(
        children: [
          Container(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            padding: const EdgeInsets.only(right: 8),
                            child: null,
                            decoration: BoxDecoration(
                              color: const Color(0xffcecece),
                              image: DecorationImage(
                                image: coupon.iconUrl == null
                                    ? NetworkImage(
                                        "$apiBase/assets/images/coupons/no_images.jpg",
                                      )
                                    : NetworkImage(
                                        "$apiBase/assets/images/coupons/" +
                                            coupon.iconUrl!,
                                      ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(width: 4),
                          Container(
                            padding: EdgeInsets.only(bottom: 5),
                            child: Text(
                              coupon.couponName.length > 15
                                  ? coupon.couponName.substring(0, 15) + '...'
                                  : coupon.couponName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              softWrap: true,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        child: Text(
                          '有効期限: ' + coupon.useDate.replaceAll('-', '/'),
                        ),
                      ),
                      Container(
                        child: Text(
                          coupon.condition == '1' ? '他クーポン併用不可' : '他クーポンと併用化',
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 130,
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      if (coupon.discountAmount != null)
                        Text(
                          Funcs().currencyFormat(coupon.discountAmount!) +
                              '円 OFF',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      if (coupon.discountRate != null)
                        Text(
                          coupon.discountRate! + '％OFF',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      if (coupon.discountRate != null &&
                          coupon.upperAmount != null)
                        Text(
                          '上限${Funcs().currencyFormat(coupon.upperAmount!)}円',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (openCouponId == coupon.couponId)
            Container(
              margin: EdgeInsets.symmetric(vertical: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(child: Text(coupon.comment)),
                  Expanded(child: Container()),
                  // Container(
                  //   child: ElevatedButton(
                  //     child: Text('クーポンを使う'),
                  //     onPressed: () {
                  //       Navigator.push(context,
                  //           MaterialPageRoute(builder: (_) {
                  //         return ConnectCouponUseConfirm(
                  //             couponId: coupon.couponId);
                  //       }));
                  //     },
                  //   ),
                  // )
                ],
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                child: TextButton(
                  child: Row(
                    children: [
                      Text('詳細を見る'),
                      Icon(
                        openCouponId == coupon.couponId
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                      ),
                    ],
                  ),
                  onPressed: () {
                    setState(() {
                      if (openCouponId == coupon.couponId) {
                        openCouponId = '';
                      } else {
                        openCouponId = coupon.couponId;
                      }
                    });
                  },
                ),
              ),
              coupon.isUserUseFlag
                  ? Row(
                      children: [
                        Text('使用済み'),
                        SizedBox(width: 8),
                        Container(
                          child: TextButton(
                            child: Text(
                              '削除する',
                              style: TextStyle(color: Colors.red),
                            ),
                            onPressed: () {
                              deleteUserCoupon(coupon.userCouponId);
                            },
                          ),
                        ),
                      ],
                    )
                  : Container(
                      child: TextButton(
                        child: Text(
                          '使用する',
                          style: TextStyle(color: Colors.blue),
                        ),
                        onPressed: () {
                          updateCouponUseFlag(coupon.userCouponId);
                        },
                      ),
                    ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/foundation.dart';
import 'package:shangrila/src/http/webservice.dart';
import 'package:shangrila/src/model/company_site_model.dart';
import 'package:shangrila/src/model/companymodel.dart';

import '../apiendpoint.dart';

class ClCompany {
  Future<CompanyModel> loadCompanyInfo(context, String companyId) async {
    Map<dynamic, dynamic> results = {};
    String apiUrl = '$apiBase/apicompanies/loadCompanyInfo';
    await Webservice().loadHttp(
        context, apiUrl, {'company_id': companyId}).then((v) => {results = v});

    return CompanyModel.fromJson(results['company']);
  }

  Future<List<CompanySiteModel>> loadCompanySites(
      context, String companyId) async {
    List<CompanySiteModel> sites = [];

    String apiUrl = '$apiBase/apicompanies/getCompanySites';
    await Webservice()
        .loadHttp(context, apiUrl, {'company_id': companyId}).then(
            (results) => {
                  for (var item in results['sites'])
                    {sites.add(CompanySiteModel.fromJson(item))}
                });

    return sites;
  }

  Future<int> loadPrevStampCount(context, String companyId, String rank) async {
    String apiUrl = '$apiBase/apicompanies/loadStampCountPrevRank';
    if (kDebugMode) {
      print({'company_id': companyId, 'rank': rank.toString()});
    }
    int stampCnt = 0;
    if (int.parse(rank) > 1) {
      await Webservice().loadHttp(context, apiUrl, {
        'company_id': companyId,
        'rank': rank.toString()
      }).then((results) => {stampCnt = results['stamp_count']});
    }

    return stampCnt;
  }
}

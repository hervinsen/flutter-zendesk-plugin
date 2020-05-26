import 'package:zendeskchat/model/base.dart';

class ZendeskConstant {
  static const String accountKey = 'C1CTbSEeLEsbB4XXek9yyjEgCuEOgz4v';
  static const String url = 'https://amaanhelp.zendesk.com';
  static const String appId =
      'bf715b4c0c3cfd735f086a41d66f8bee18820b84432288d3';
  static const String clientId = 'mobile_sdk_client_0066cd535527780fde07';

  static final _liveChat = BaseModel(
      code: 'LIVECHAT-INT-PREF',
      name: 'Live Chat Integration Prefix',
      value: 'Support');

  static final _konsultasiKesehatan = BaseModel(
      code: 'MEDCON-INT-PREF',
      name: 'Medical Consultation Integration Prefix',
      value: 'Konsultasi Kesehatan');

  static final _whistleBlower = BaseModel(
      code: 'WHISBLOW-INT-PREF',
      name: 'Whistleblower Integration Prefix',
      value: 'Pengaduan');

  static final List<BaseModel> departmentDropDown = <BaseModel>[
    _liveChat,
    _konsultasiKesehatan,
    _whistleBlower
  ];
}

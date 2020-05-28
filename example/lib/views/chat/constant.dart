import 'package:zendesk_flutter_plugin_example/model/base.dart';

class CommonConstant {
  static const String name = 'nama';
  static const String email = 'email';
  static const String phoneNumber = 'nomor telepon';
  static const String department = 'department';
  static const String submit = 'Masuk';
  static const String isTyping = 'isTyping';
  static const String visitor = 'visitor';
}


class ViewConstant {
  static const String chatHintText = 'Ketik pesan disini...';
  static const String pleaseWait = 'Mohon Tunggu...';
  static const String goodService = 'Good Service';
  static const String badService = 'Bad Service';

  static const String hasJoin = 'Telah Bergabung';
  static const String hasLeft = 'Telah Meninggalkan Percakapan';
  static const String welcome = 'Selamat datang';
  static const String greeting ='Adakah yang bisa kami bantu ?';

  static const String alertCloseHour = 'Mohon maaf, Sesi Pembicaraan Telah berakhir Mohon coba kembali.';
}


class ZendeskConstant {
  static const String accountKey = 'C1CTbSEeLEsbB4XXek9yyjEgCuEOgz4v';
  static const String url = 'https://amaanhelp.zendesk.com';
  static const String appId =
      'bf715b4c0c3cfd735f086a41d66f8bee18820b84432288d3';
  static const String clientId = 'mobile_sdk_client_0066cd535527780fde07';

  static const String noDepartment = 'No Department';

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

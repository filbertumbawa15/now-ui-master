part of 'services.dart';

class MasterProvider extends ChangeNotifier {
  //ListPesanan
  List<ListPesanan> _data = [];
  List<ListPesanan> get dataPesanan => _data;
  //Status Barang
  List<StatusBarang> _data_status = [];
  List<StatusBarang> get dataStatus => _data_status;
  //Status Barang
  List<DataQty> _data_qty = [];
  List<DataQty> get dataqty => _data_qty;
  //Invoice Tambahan
  List<DataInvoiceTambahan> _data_invoice = [];
  List<DataInvoiceTambahan> get datainvoice => _data_invoice;
  //List Data Favorit
  List<Favorites> _data_favorit = [];
  List<Favorites> get datafavorit => _data_favorit;
  //List Data Notifikasi
  List<NotificationsData> _data_notif = [];
  List<NotificationsData> get datanotif => _data_notif;
  //Lainnya
  List<ListPesanan> _data_kondisi = [];

  bool _onSearch = false;
  bool get onSearch => _onSearch;

  static MasterProvider instance(BuildContext context) =>
      Provider.of(context, listen: false);

  Future<Totalbayar> addPembayaran(var data_pembayaran, List<dynamic> sk,
      String lokmuat, String lokbongkar, String harga) async {
    try {
      final url =
          '${globals.url}/api-orderemkl/public/api/faspay/insertorderfaspay';
      // '${globals.url}/faspay/index.php';
      final response = await http.post(
        Uri.parse(url),
        body: {'data_pembayaran': jsonEncode(data_pembayaran)},
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer ${globals.accessToken}',
        },
      );
      print(response.body);
      var trxid = jsonDecode(response.body)['trxid'];
      var nobukti = jsonDecode(response.body)['nobukti'];
      if (response.statusCode == 200) {
        print("masuk 200");
        await generatePdfFile(nobukti, sk, lokmuat, lokbongkar, harga);
        return showTanggalBayar(nobukti);
        // return jsonDecode(response.body);
        // final result = response.body;
        // debugPrint(response.body);
        // return Totalbayar.fromJson(jsonDecode(response.body));
      } else {
        print("error 500");
        throw Exception();
      }
    } catch (e) {
      print("error catch");
      print(e);
    }
  }

  void generatePdfFile(String nobukti, List<dynamic> sk, String lokmuat,
      String lokbongkar, String harga) async {
    final syaratketentuan = sk.asMap().entries.map((val) {
      int idx = val.key;
      return sk[idx]['syaratketentuan'];
    }).toList();
    final syarat = SyaratKetentuan(
      nama: globals.loggedinName,
      nobukti: nobukti,
      notelp: globals.loggedinTelp,
      tanggal: DateFormat('dd MMMM yyyy').format(DateTime.now()),
      lokmuat: lokmuat,
      lokbongkar: lokbongkar,
      harga: harga,
      syaratketentuan: syaratketentuan,
    );
    final pdfFile = await PdfSKApi.generate(syarat);
    String buktiPdf = pdfFile.path.split('/').last;
    var data = FormData.fromMap({
      "bukti_pdf": await MultipartFile.fromFile(
        pdfFile.path,
        filename: buktiPdf,
      ),
      'nobukti': nobukti,
    });
    Dio dio = new Dio();

    try {
      var response = await dio.post(
        'https://web.transporindo.com/api-orderemkl/public/api/syaratdanketentuan/uploadBukti',
        data: data,
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Content-type': 'application/json',
            'Authorization': 'Bearer ${globals.accessToken}',
          },
        ),
      );
    } on DioError catch (e) {
      if (e.response.statusCode == 500) {
        print(e.response.data);
        print(e.response.headers);
        print(e.response.requestOptions);
      }
    } on SocketException catch (_) {
      print('not connected');
    }
  }

  Future<Totalbayar> showTanggalBayar(var nobukti) async {
    var data = {
      "nobukti": nobukti,
    };
    final response = await http.get(
        Uri.parse(
            '${globals.url}/api-orderemkl/public/api/pesanan/listpesananwhereUtc?data=${jsonEncode(data)}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${globals.accessToken}',
        });
    final result = jsonDecode(response.body);
    print(result);
    if (response.statusCode == 200) {
      // print(Totalbayar.fromJson(result));
      return Totalbayar.fromJson(result['data']);
    } else {
      throw Exception();
    }
  }

  Future<ListPesanan> listPesananRow(var nobukti) async {
    var data = {
      "nobukti": nobukti,
      "utctime": globals.dateAus.timeZoneOffset.inHours,
    };
    print(globals.dateAus.timeZoneOffset.inHours);
    final response = await http.get(
        Uri.parse(
            '${globals.url}/api-orderemkl/public/api/pesanan/listpesananrow?data=${jsonEncode(data)}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${globals.accessToken}',
        });
    final result = jsonDecode(response.body);
    if (response.statusCode == 200) {
      // print(Totalbayar.fromJson(result));
      return ListPesanan.fromJson(result['data']);
    } else {
      throw Exception();
    }
  }

  void callSkeletonListPesanan(BuildContext context, var userid) async {
    setOnSearchListPesanan(true);
    await getListPesanan(context, userid);
    setOnSearchListPesanan(false);
  }

  void setOnSearchListPesanan(bool value) {
    _onSearch = value;
    notifyListeners();
  }

  Future<List<ListPesanan>> getListPesanan(
      BuildContext context, var user_id) async {
    setOnSearchListPesanan(true);
    // try {
    final status = {
      "id": user_id,
      "kondisi": 0,
      "utctime": globals.dateAus.timeZoneOffset.inHours,
    };
    // final status2 = {"id": user_id, "kondisi": 1};
    final response = await http.get(
        Uri.parse(
            '${globals.url}/api-orderemkl/public/api/pesanan/listpesanan?data=${jsonEncode(status)}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${globals.accessToken}',
        });
    print(response.body);
    if (response.statusCode == 500) {
      // return <String>['error' => "1"];
      // _data = ([
      //   {'error': '1'}
      // ] as List)
      //     .map((data) => new ListPesanan.fromJson(data))
      //     .toList();
    } else if (response.statusCode == 200) {
      // final result2 = jsonDecode(response2.body);
      // _data_kondisi = (result2['data'] as List)
      //     .map((data) => new ListPesanan.fromJson(data))
      //     .toList();
      // for (var i = 0; i < _data_kondisi.length; i++) {
      //   print("test");
      //   // checkStatusPayment(
      //   //   context,
      //   //   _data_kondisi[i].trx_id,
      //   //   _data_kondisi[i].bill_no,
      //   //   user_id,
      //   //   _data_kondisi[i].merchant_id,
      //   //   _data_kondisi[i].merchant_password,
      //   // );
      // }
      print("masuk");
      final result = jsonDecode(response.body);
      _data = (result['data'] as List)
          .map((data) => new ListPesanan.fromJson(data))
          .toList();
      return _data;
    }
    print("Baca end");
    setOnSearchListPesanan(false);
    // } on SocketException catch (_) {
    //   globals.checkConnection(
    //     context,
    //     "Mohon cek kembali koneksi internet WiFi/Data anda",
    //     'Tidak ada koneksi',
    //     'assets/imgs/no-internet.json',
    //     getListPesanan(context, user_id),
    //   );
    // }
  }

  checkStatusPayment(BuildContext context, var trx_id, var bill_no, var user_id,
      String merchant_id, String merchant_password) async {
    // progressDialog.show();
    globals.merchantid = merchant_id;
    globals.merchantpassword = merchant_password;
    try {
      var data_pembayaran = {
        'noVA': trx_id,
        'bill_no': bill_no,
        "merchantid": globals.merchantid,
        "merchantpassword": globals.merchantpassword,
      };
      final response = await http.post(
          Uri.parse(
            '${globals.url}/api-orderemkl/public/api/faspay/statuspayment',
            // /api-orderemkl/public/api/faspay/listofpayment,
          ),
          body: {'data_pembayaran': jsonEncode(data_pembayaran)});
      var hasil = json.decode(response.body);
      print(hasil);
      if (hasil['payment_status_code'] == '2') {
        updateStatusPembayaran(trx_id, 2); //sudah terbayar
        getListPesanan(context, user_id);
        globals.condition = "true";
        // await globals.notificationService.showNotifications(
        //   "Pesanan sudah dibayar",
        //   "Pesanan anda telah terbayar, silahkan cek status orderan anda",
        // );
      } else if (hasil['payment_status_code'] == '7') {
        updateStatusPembayaran(trx_id, 7); //habis waktu
      } else if (hasil['payment_status_code'] == '8') {
        updateStatusPembayaran(trx_id, 8); //habis waktu
      }
      //else {
      //   checkStatusPayment(
      //       context, trx_id, bill_no, user_id, merchant_id, merchant_password);
      // }
    } catch (e) {
      print(e);
    }
  }

  void updateStatusPembayaran(var trx_id, var payment_status) async {
    var data = {
      "trx_id": trx_id,
      "payment_status": payment_status,
      "payment_date": DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
    };
    print(jsonEncode(data));
    final url = '${globals.url}/api-orderemkl/public/api/pesanan/update';
    final response = await http.post(Uri.parse(url), headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer ${globals.accessToken}',
    }, body: {
      'data': jsonEncode(data)
    });
    final result = jsonDecode(response.body);
  }

  Future<List<StatusBarang>> getStatusBarang(
      var nobukti, var qty, var jobemkl) async {
    final data_status = {"nobukti": nobukti, "qty": qty, "jobemkl": jobemkl};
    final response = await http.get(
        Uri.parse(
            '${globals.url}/api-orderemkl/public/api/pesanan/getstatusorderan?data=${jsonEncode(data_status)}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${globals.accessToken}',
        });
    if (response.statusCode == 500) {
      // return <String>['error' => "1"];
      // _data = ([
      //   {'error': '1'}
      // ] as List)
      //     .map((data) => new ListPesanan.fromJson(data))
      //     .toList();
    } else if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      _data_status = (result['data'][0]['pesananstatus'] as List)
          .map((data) => new StatusBarang.fromJson(data))
          .toList();
      // print(_data_status[0].kode_status);
      return _data_status;
    }
  }

  Future<List<DataQty>> getListQty(var nobukti) async {
    final data_qty = {"nobukti": nobukti};
    final response = await http.get(Uri.parse(
            // '${globals.url}/api-orderemkl/public/api/pesanan/getstatusorderan?data=${jsonEncode(data_status)}'));
            '${globals.url}/api-orderemkl/public/api/pesanan/getListjob?data=${jsonEncode(data_qty)}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${globals.accessToken}',
        });
    if (response.statusCode == 500) {
      // return <String>['error' => "1"];
      // _data = ([
      //   {'error': '1'}
      // ] as List)
      //     .map((data) => new ListPesanan.fromJson(data))
      //     .toList();
    } else if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      _data_qty = (result['data'] as List)
          .map((data) => new DataQty.fromJson(data))
          .toList();
      // print(_data_status[0].kode_status);
      return _data_qty;
    }
  }

  void callSkeleton(var nobukti) async {
    setOnSearch(true);
    await getDataInvoiceTambahan(nobukti);
    setOnSearch(false);
  }

  Future<List<DataInvoiceTambahan>> getDataInvoiceTambahan(var nobukti) async {
    setOnSearch(true);
    final data_invoice = {"nobukti": nobukti};
    final response = await http.get(Uri.parse(
            // '${globals.url}/api-orderemkl/public/api/pesanan/getstatusorderan?data=${jsonEncode(data_status)}'));
            '${globals.url}/api-orderemkl/public/api/pesanan/getListInvoiceTambahan?data=${jsonEncode(data_invoice)}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${globals.accessToken}',
        });
    if (response.statusCode == 500) {
      // return <String>['error' => "1"];
      // _data = ([
      //   {'error': '1'}
      // ] as List)
      //     .map((data) => new ListPesanan.fromJson(data))
      //     .toList();
    } else if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      print(result);
      _data_invoice = (result['data'] as List)
          .map((data) => new DataInvoiceTambahan.fromJson(data))
          .toList();
      return _data_invoice;
    }
    print("berhasil");
    setOnSearch(false);
  }

  void setOnSearch(bool value) {
    _onSearch = value;
    notifyListeners();
  }

  Future<void> updateStatusInvoiceTambahan(
      var trx_id, var paymentStatus) async {
    var data = {
      "trx_id": trx_id,
      "payment_status": paymentStatus,
      "payment_date": DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
    };
    print(jsonEncode(data));
    final url =
        '${globals.url}/api-orderemkl/public/api/pesanan/updateInvoiceTambahan';
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer ${globals.accessToken}',
      },
      body: {'data': jsonEncode(data)},
    );
    final result = jsonDecode(response.body);
  }

  Future<void> addToFavorites(var data) async {
    final url = '${globals.url}/api-orderemkl/public/api/favorites';
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer ${globals.accessToken}',
      },
      body: {'data': jsonEncode(data)},
    );
    final result = jsonDecode(response.body);
  }

  void callFavorites() async {
    setOnSearch(true);
    await getFavorites();
    setOnSearch(false);
  }

  void setOnSearchFavorites(bool value) {
    _onSearch = value;
    notifyListeners();
  }

  Future<List<Favorites>> getFavorites() async {
    setOnSearchFavorites(true);
    final url =
        '${globals.url}/api-orderemkl/public/api/favorites/${globals.loggedinId ?? 0}';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer ${globals.accessToken}',
      },
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      _data_favorit = (result['data'] as List)
          .map((data) => new Favorites.fromJson(data))
          .toList();
      return _data_favorit;
    }
    setOnSearchFavorites(false);
  }

  void deleteFavoritesData(int id) async {
    setOnSearchFavorites(true);
    final url = '${globals.url}/api-orderemkl/public/api/favorites/$id';
    final response = await http.delete(
      Uri.parse(url),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer ${globals.accessToken}',
      },
    );
    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      await getFavorites();
      print(result);
    }
    setOnSearchFavorites(false);
  }

  void callNotifications() async {
    setOnSearch(true);
    await getNotifications();
    setOnSearch(false);
  }

  void setOnSearchNotifications(bool value) {
    _onSearch = value;
    notifyListeners();
  }

  Future<List<NotificationsData>> getNotifications() async {
    setOnSearchNotifications(true);
    final url =
        '${globals.url}/api-orderemkl/public/api/notifications?userid=${globals.loggedinId ?? 0}';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer ${globals.accessToken}',
      },
    );
    print(response.body);
    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      print(globals.loggedinId);
      _data_notif = (result['data'] as List)
          .map((data) => new NotificationsData.fromJson(data))
          .toList();
      return _data_notif;
    }
    setOnSearchNotifications(false);
  }

  Future<void> sendPushMessage(String token, String body, String title) async {
    try {
      final response = await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization':
              'key=AAAAK7MzGj8:APA91bHclxG_eQMdSyZLlGgtbPlGVINJxKfhfZC8ksxyEcYHtO4VP6YaLDoDx4y515bxTqG5_EN0aaUfUK_TVBczLve5SeI3dZX8B4J-ps_82Dxvgi1sd0NtsSmsryMamwfEIw6XxKyM',
        },
        body: jsonEncode(<String, dynamic>{
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'status': 'done',
          },
          'notification': <String, dynamic>{
            'title': title,
            'body': body,
            'sound': 'default',
            'badge': '1',
          },
          'to': token,
        }),
      );
      final result = jsonDecode(response.body);
      if (response.statusCode == 200) {
        print(response);
      } else {
        print(response.body);
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> storeConversation(
      var data, var array, var chatData, int timestamp) async {
    final url =
        '${globals.url}/api-orderemkl/public/api/chatting/storeConversations';
    final response = await http.post(
      Uri.parse(url),
      body: {
        "data": jsonEncode(data),
        "participants": "${jsonEncode(array)}",
        'dataChat': jsonEncode(chatData),
        'idConversation': timestamp.toString(),
      },
      headers: {
        'Accept': 'application/json',
      },
    );
    print(response.body);
    if (response.statusCode == 200) {
      print("Data conversation berhasil ditambahkan");
    } else {
      print(response.body);
    }
  }

  Future<void> storeChat(var dataChat, int timestamp) async {
    final url =
        '${globals.url}/api-orderemkl/pcalcublic/api/chatting/storeChats';
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Accept': 'application/json',
      },
      body: {
        'data': jsonEncode(dataChat),
        'idConversation': timestamp.toString(),
      },
    );
    print(response.body);
    final result = jsonDecode(response.body);
    if (response.statusCode == 200) {
      print("Data chats berhasil ditambahkan");
    } else {
      print(result);
    }
  }
}

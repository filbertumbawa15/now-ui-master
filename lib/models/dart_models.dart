import 'package:flutter/material.dart';

class MasterContainer {
  final int id;
  final String kodecontainer;

  MasterContainer({this.id, this.kodecontainer});

  factory MasterContainer.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return MasterContainer(
      id: json["id"],
      kodecontainer: json["kodecontainer"],
    );
  }

  static List<MasterContainer> fromJsonList(List list) {
    if (list == null) return null;
    return list.map((item) => MasterContainer.fromJson(item)).toList();
  }

  @override
  String toString() => kodecontainer;
}

class MasterPelayaran {
  final int fid;
  final String fnpelayaran;

  MasterPelayaran({this.fid, this.fnpelayaran});

  factory MasterPelayaran.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return MasterPelayaran(
      fid: json["fid"],
      fnpelayaran: json["fnpelayaran"],
    );
  }

  static List<MasterPelayaran> fromJsonList(List list) {
    if (list == null) return null;
    return list.map((item) => MasterPelayaran.fromJson(item)).toList();
  }

  @override
  String toString() => fnpelayaran;
}

class Events {
  final String time;
  final String eventName;
  final String description;

  Events({this.time, this.eventName, this.description});
}

class Constants {
  static const kPurpleColor = Color(0xFFB97DFE);
  static const kRedColor = Color(0xFFFE4067);
  static const kGreenColor = Color(0xFFADE9E3);
}

class Pembayaran {
  final String pg_code;
  final String pg_name;

  Pembayaran({this.pg_code, this.pg_name});

  factory Pembayaran.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return Pembayaran(
      pg_code: json["pg_code"],
      pg_name: json["pg_name"],
    );
  }

  static List<Pembayaran> fromJsonList(List list) {
    if (list == null) return null;
    return list.map((item) => Pembayaran.fromJson(item)).toList();
  }

  @override
  String toString() => pg_name;
}

class ListBank {
  final String kodebank;
  final String namabank;

  ListBank({this.kodebank, this.namabank});

  factory ListBank.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return ListBank(
      kodebank: json["kodebank"],
      namabank: json["namabank"],
    );
  }

  static List<ListBank> fromJsonList(List list) {
    if (list == null) return null;
    return list.map((item) => ListBank.fromJson(item)).toList();
  }

  @override
  String toString() => namabank;
}

class Totalbayar {
  final String lokasiMuat;
  final String lokasiBongkar;
  final String harga;
  final String noVA;
  final String bill_no;
  final String payment_name;
  final String waktu_bayar;
  final String endDate;
  final String nobukti;

  Totalbayar({
    this.lokasiMuat,
    this.lokasiBongkar,
    this.harga,
    this.noVA,
    this.bill_no,
    this.payment_name,
    this.waktu_bayar,
    this.endDate,
    this.nobukti,
  });

  factory Totalbayar.fromJson(Map<String, dynamic> json) {
    return Totalbayar(
      lokasiMuat: json["alamatdetailpengirim"],
      lokasiBongkar: json["alamatdetailpenerima"],
      harga: json["harga"],
      noVA: json["trx_id"],
      bill_no: json["bill_no"],
      payment_name: json["payment_code"],
      waktu_bayar: json["bill_expired"],
      endDate: json["date"],
      nobukti: json["nobukti"],
    );
  }

  // Map<String, dynamic> toJson([String jsonEncode]) => {
  //       "fharga": harga,
  //       "noVA": noVA,
  //       "bill_no": bill_no,
  //       "fpayment_code": payment_name,
  //       "fbill_expired": waktu_bayar,
  //     };

  // @override
  // String toString() => no;
}

class ListPesanan {
  String placeidasal;
  String pelabuhanidasal;
  String trx_id;
  String bill_no;
  String payment_code;
  String prov_asal;
  String prov_tujuan;
  String payment_status;
  String harga;
  String order_date;
  String payment_date;
  String alamat_asal;
  String alamat_tujuan;
  String latitude_pelabuhan_asal;
  String longitude_pelabuhan_asal;
  String latitude_pelabuhan_tujuan;
  String longitude_pelabuhan_tujuan;
  String latitude_muat;
  String longitude_muat;
  String latitude_bongkar;
  String longitude_bongkar;
  String pengirim;
  String penerima;
  String placeidtujuan;
  String pelabuhanidtujuan;
  String jarak_asal;
  String waktu_asal;
  String jarak_tujuan;
  String waktu_tujuan;
  String kodecontainer;
  String qty;
  String notelppengirim;
  String notelppenerima;
  String container_id;
  String nilaibarang;
  String jenisbarang;
  String namabarang;
  String keterangantambahan;
  String nobukti;
  String nominalrefund;
  String notepengirim;
  String notepenerima;
  String namapelabuhanmuat;
  String namapelabuhanbongkar;
  String contactperson;
  String buktipdf;
  String buktipdfrefund;
  String merchant_id;
  String merchant_password;
  String lampiraninvoice;
  List<dynamic> invoiceTambahan;
  int totalNominal;
  String namabankrefund;
  String norekening;
  String namarekening;
  String cabangbankrefund;
  String keteranganrefund;
  String tglrefund;

  ListPesanan({
    this.placeidasal,
    this.pelabuhanidasal,
    this.trx_id,
    this.bill_no,
    this.payment_code,
    this.prov_asal,
    this.prov_tujuan,
    this.payment_status,
    this.harga,
    this.order_date,
    this.payment_date,
    this.alamat_asal,
    this.alamat_tujuan,
    this.latitude_pelabuhan_asal,
    this.longitude_pelabuhan_asal,
    this.latitude_pelabuhan_tujuan,
    this.longitude_pelabuhan_tujuan,
    this.latitude_muat,
    this.longitude_muat,
    this.latitude_bongkar,
    this.longitude_bongkar,
    this.pengirim,
    this.penerima,
    this.placeidtujuan,
    this.pelabuhanidtujuan,
    this.jarak_asal,
    this.waktu_asal,
    this.jarak_tujuan,
    this.waktu_tujuan,
    this.kodecontainer,
    this.qty,
    this.notelppengirim,
    this.notelppenerima,
    this.container_id,
    this.nilaibarang,
    this.jenisbarang,
    this.namabarang,
    this.keterangantambahan,
    this.nobukti,
    this.nominalrefund,
    this.notepengirim,
    this.notepenerima,
    this.namapelabuhanmuat,
    this.namapelabuhanbongkar,
    this.contactperson,
    this.buktipdf,
    this.buktipdfrefund,
    this.merchant_id,
    this.merchant_password,
    this.lampiraninvoice,
    this.invoiceTambahan,
    this.totalNominal,
    this.namabankrefund,
    this.norekening,
    this.namarekening,
    this.cabangbankrefund,
    this.keteranganrefund,
    this.tglrefund,
  });

  // FORMAT TO JSON
  factory ListPesanan.fromJson(Map<String, dynamic> json) => ListPesanan(
        placeidasal: json["placeidasal"],
        pelabuhanidasal: json["pelabuhanidasal"],
        jarak_asal: json["jarak_asal"],
        waktu_asal: json["waktu_asal"],
        placeidtujuan: json["placeidtujuan"],
        pelabuhanidtujuan: json["pelabuhanidtujuan"],
        jarak_tujuan: json["jarak_tujuan"],
        waktu_tujuan: json["waktu_tujuan"],
        trx_id: json["trx_id"],
        bill_no: json["bill_no"],
        payment_code: json["payment_code"],
        prov_asal: json["provinsi_asal"],
        prov_tujuan: json["provinsi_tujuan"],
        payment_status: json["payment_status"],
        harga: json["harga"],
        order_date: json["order_date"],
        payment_date: json["payment_date"],
        alamat_asal: json["alamatdetailpengirim"],
        alamat_tujuan: json["alamatdetailpenerima"],
        latitude_pelabuhan_asal: json["latitude_pelabuhan_asal"],
        longitude_pelabuhan_asal: json["longitude_pelabuhan_asal"],
        latitude_pelabuhan_tujuan: json["latitude_pelabuhan_tujuan"],
        longitude_pelabuhan_tujuan: json["longitude_pelabuhan_tujuan"],
        latitude_muat: json["latitude_muat"],
        longitude_muat: json["longitude_muat"],
        latitude_bongkar: json["latitude_bongkar"],
        longitude_bongkar: json["longitude_bongkar"],
        pengirim: json["namapengirim"],
        penerima: json["namapenerima"],
        kodecontainer: json["kodecontainer"],
        qty: json["qty"],
        notelppengirim: json["notelppengirim"],
        notelppenerima: json["notelppenerima"],
        nilaibarang: json["nilaibarang_asuransi"],
        jenisbarang: json["jenisbarang"],
        namabarang: json["namabarang"],
        keterangantambahan: json["keterangantambahan"],
        container_id: json["container_id"],
        nobukti: json["nobukti"],
        nominalrefund: json["nominalrefund"],
        notepengirim: json["note_pengirim"],
        notepenerima: json["note_penerima"],
        namapelabuhanmuat: json["namapelabuhanmuat"],
        namapelabuhanbongkar: json["namapelabuhanbongkar"],
        contactperson: json["contactperson"],
        buktipdf: json["buktipdf"],
        buktipdfrefund: json["buktipdfrefund"],
        merchant_id: json["merchantid"],
        merchant_password: json["merchantpassword"],
        lampiraninvoice: json["lampiraninvoice"],
        invoiceTambahan: json["invoice_tambahan"],
        totalNominal: json["totalNominal"],
        namabankrefund: json["namabankrefund"],
        norekening: json["norekening"],
        namarekening: json["namarekening"],
        cabangbankrefund: json["cabangrekening"],
        keteranganrefund: json["keteranganrefund"],
        tglrefund: json["tglrefund"],
      );

  static List<ListPesanan> fromJsonList(List list) {
    if (list == null) return null;
    return list.map((item) => ListPesanan.fromJson(item)).toList();
  }

  // @override
  // String toString() => ftrx_id;
}

class ProvinsiAsal {
  final String fkode;
  final String fprovinsi;

  ProvinsiAsal({this.fkode, this.fprovinsi});

  factory ProvinsiAsal.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return ProvinsiAsal(
      fkode: json["fkode"],
      fprovinsi: json["fprovinsi"],
    );
  }

  static List<ProvinsiAsal> fromJsonList(List list) {
    if (list == null) return null;
    return list.map((item) => ProvinsiAsal.fromJson(item)).toList();
  }

  @override
  String toString() => fprovinsi;
}

class KotaAsal {
  final String fkode;
  final String fnamacity_kab;

  KotaAsal({this.fkode, this.fnamacity_kab});

  factory KotaAsal.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return KotaAsal(
      fkode: json["fkode"],
      fnamacity_kab: json["fnamacity_kab"],
    );
  }

  static List<KotaAsal> fromJsonList(List list) {
    print(list);
    if (list == null) return null;
    return list.map((item) => KotaAsal.fromJson(item)).toList();
  }

  @override
  String toString() => fnamacity_kab;
}

class KecamatanAsal {
  final String fkode;
  final String fkec_subdistrict;

  KecamatanAsal({this.fkode, this.fkec_subdistrict});

  factory KecamatanAsal.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return KecamatanAsal(
      fkode: json["fkode"],
      fkec_subdistrict: json["fkec_subdistrict"],
    );
  }

  static List<KecamatanAsal> fromJsonList(List list) {
    if (list == null) return null;
    return list.map((item) => KecamatanAsal.fromJson(item)).toList();
  }

  @override
  String toString() => fkec_subdistrict;
}

class KelurahanAsal {
  final String fkode;
  final String fkelurahan_desa;

  KelurahanAsal({this.fkode, this.fkelurahan_desa});

  factory KelurahanAsal.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return KelurahanAsal(
      fkode: json["fkode"],
      fkelurahan_desa: json["fkelurahan_desa"],
    );
  }

  static List<KelurahanAsal> fromJsonList(List list) {
    if (list == null) return null;
    return list.map((item) => KelurahanAsal.fromJson(item)).toList();
  }

  @override
  String toString() => fkelurahan_desa;
}

class DonePayment {
  String trx_id;
  String nobukti;
  String bill_no;
  String payment_code;
  String prov_asal;
  String prov_tujuan;
  int payment_status;
  String harga;
  String order_date;
  String payment_date;
  String alamat_asal;
  String alamat_tujuan;
  String latitude_pelabuhan_asal;
  String longitude_pelabuhan_asal;
  String latitude_pelabuhan_tujuan;
  String longitude_pelabuhan_tujuan;
  String latitude_muat;
  String longitude_muat;
  String latitude_bongkar;
  String longitude_bongkar;
  String pengirim;
  String penerima;
  String kodecontainer;
  String qty;
  String notelppengirim;
  String notelppenerima;
  String buktipdf;
  String notepengirim;
  String notepenerima;

  DonePayment({
    this.trx_id,
    this.nobukti,
    this.bill_no,
    this.payment_code,
    this.prov_asal,
    this.prov_tujuan,
    this.payment_status,
    this.harga,
    this.order_date,
    this.payment_date,
    this.alamat_asal,
    this.alamat_tujuan,
    this.latitude_pelabuhan_asal,
    this.longitude_pelabuhan_asal,
    this.latitude_pelabuhan_tujuan,
    this.longitude_pelabuhan_tujuan,
    this.latitude_muat,
    this.longitude_muat,
    this.latitude_bongkar,
    this.longitude_bongkar,
    this.pengirim,
    this.penerima,
    this.kodecontainer,
    this.qty,
    this.notelppengirim,
    this.notelppenerima,
    this.buktipdf,
    this.notepengirim,
    this.notepenerima,
  });

  // FORMAT TO JSON
  factory DonePayment.fromJson(Map<String, dynamic> json) => DonePayment(
        trx_id: json["trxid"],
        nobukti: json["nobukti"],
        bill_no: json["billno"],
        payment_code: json["paymentcode"],
        prov_asal: json["provinsilokasimuat"],
        prov_tujuan: json["provinsilokasibongkar"],
        payment_status: json["paymentstatus"],
        harga: json["harga"],
        order_date: json["tgl"],
        payment_date: json["paymentdate"],
        alamat_asal: json["alamatdetailpengirim"],
        alamat_tujuan: json["alamatdetailpenerima"],
        latitude_pelabuhan_asal: json["latitudepelabuhanlokasimuat"],
        longitude_pelabuhan_asal: json["longitudepelabuhanlokasimuat"],
        latitude_pelabuhan_tujuan: json["latitudepelabuhanlokasibongkar"],
        longitude_pelabuhan_tujuan: json["longitudepelabuhanlokasibongkar"],
        latitude_muat: json["latitudelokasimuat"],
        longitude_muat: json["longitudelokasimuat"],
        latitude_bongkar: json["latitudelokasibongkar"],
        longitude_bongkar: json["longitudelokasibongkar"],
        pengirim: json["namapengirim"],
        penerima: json["namapenerima"],
        qty: json["qty"],
        notelppengirim: json["notelppengirim"],
        notelppenerima: json["notelppenerima"],
        buktipdf: json["buktipdf"],
        notepengirim: json["notepengirim"],
        notepenerima: json["notepenerima"],
      );

  static List<DonePayment> fromJsonList(List list) {
    if (list == null) return null;
    return list.map((item) => DonePayment.fromJson(item)).toList();
  }

  // @override
  // String toString() => ftrx_id;

  // Map<String, dynamic> toJson([String jsonEncode]) => {
  //       "fharga": harga,
  //       "noVA": noVA,
  //       "bill_no": bill_no,
  //       "fpayment_code": payment_name,
  //       "fbill_expired": waktu_bayar,
  //     };

  // @override
  // String toString() => no;
}
// Change(bool loggedIn) {
//   if (loggedIn == true) {
//     // print("berhasil login");
//     // return Text("asdf");
//     // return Profiles();
//   } else {
//     // return Text("asdfasdfa");
//     // print("gagal login");
//     // return Profiles();
//   }
// }

class MasterPelabuhan {
  final int id;
  final String namapelabuhan;
  final String latitude;
  final String longitude;
  final String contactperson;

  MasterPelabuhan(
      {this.id,
      this.namapelabuhan,
      this.latitude,
      this.longitude,
      this.contactperson});

  factory MasterPelabuhan.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return MasterPelabuhan(
      id: json["id"],
      namapelabuhan: json["namapelabuhan"],
      latitude: json["latitude"],
      longitude: json["longitude"],
      contactperson: json["contactperson"],
    );
  }

  static List<MasterPelabuhan> fromJsonList(List list) {
    if (list == null) return null;
    return list.map((item) => MasterPelabuhan.fromJson(item)).toList();
  }

  @override
  String toString() => namapelabuhan;
}

class ChatUsers {
  String name;
  String messageText;
  String imageURL;
  String time;
  String email;
  ChatUsers({
    @required this.name,
    @required this.messageText,
    @required this.imageURL,
    @required this.time,
    @required this.email,
  });
}

class ChatMessage {
  String msgText;
  String msgSender;
  bool user;
  dynamic timestamp;
  ChatMessage(
      {@required this.msgText,
      @required this.msgSender,
      @required this.user,
      @required this.timestamp});
}

class StatusBarang {
  String tgl_status;
  int status_id;
  String kode_status;
  String keterangan;
  String gambar;

  StatusBarang({
    this.tgl_status,
    this.status_id,
    this.kode_status,
    this.keterangan,
    this.gambar,
  });

  // FORMAT TO JSON
  factory StatusBarang.fromJson(Map<String, dynamic> json) => StatusBarang(
        tgl_status: json["tglstatus"],
        status_id: json["pelabuhanidasal"],
        kode_status: json["status"]["kodestatus"],
        keterangan: json["status"]["keterangan"],
        gambar: json["status"]["gambar"],
      );

  static List<StatusBarang> fromJsonList(List list) {
    if (list == null) return null;
    return list.map((item) => StatusBarang.fromJson(item)).toList();
  }
}

class DataQty {
  String trx_id;
  String qty;
  String jobemkl;
  String nocont;
  String nobukti;

  DataQty({
    this.trx_id,
    this.qty,
    this.jobemkl,
    this.nocont,
    this.nobukti,
  });

  // FORMAT TO JSON
  factory DataQty.fromJson(Map<String, dynamic> json) => DataQty(
        trx_id: json["trx_id"],
        qty: json["qty"],
        jobemkl: json["jobemkl"],
        nocont: json["nocont"],
        nobukti: json["nobukti"],
      );

  static List<DataQty> fromJsonList(List list) {
    if (list == null) return null;
    return list.map((item) => DataQty.fromJson(item)).toList();
  }

  // @override
  // String toString() => ftrx_id;
}

class Whatsapp {
  String notelp;
  String name;

  Whatsapp({
    this.notelp,
    this.name,
  });
}

class DataInvoiceTambahan {
  String nobukti;
  String job;
  String noinvoice;
  String tglinvoice;
  String tglbayar;
  String tglexpired;
  String nominal;
  String keterangan;
  String lampiran1;
  String lampiran2;
  String trxid;
  String paymentstatus;
  String paymentcode;
  String billno;

  DataInvoiceTambahan({
    this.nobukti,
    this.job,
    this.noinvoice,
    this.tglinvoice,
    this.tglbayar,
    this.tglexpired,
    this.nominal,
    this.keterangan,
    this.lampiran1,
    this.lampiran2,
    this.trxid,
    this.paymentstatus,
    this.paymentcode,
    this.billno,
  });

  // FORMAT TO JSON
  factory DataInvoiceTambahan.fromJson(Map<String, dynamic> json) =>
      DataInvoiceTambahan(
        nobukti: json["nobukti"],
        job: json["job"],
        noinvoice: json["noinvoice"],
        tglinvoice: json["tglinvoice"],
        tglbayar: json["paymentdate"],
        tglexpired: json["billexpired"],
        nominal: json["nominal"],
        keterangan: json["keterangan"],
        lampiran1: json["lampiran1"],
        lampiran2: json["lampiran2"],
        trxid: json["trxid"],
        paymentstatus: json["paymentstatus"],
        paymentcode: json["paymentcode"],
        billno: json["billno"],
      );

  // static List<DataInvoiceTambahan> fromJsonList(List list) {
  //   if (list == null) return null;
  //   return list.map((item) => DataInvoiceTambahan.fromJson(item)).toList();
  // }

  // @override
  // String toString() => ftrx_id;
}

class Penerima {
  final String name;
  final String notelp;
  final String address;

  const Penerima({
    this.name,
    this.notelp,
    this.address,
  });
}

class Pengirim {
  final String name;
  final String address;
  final String notelp;
  final String paymentInfo;

  const Pengirim({
    this.name,
    this.address,
    this.notelp,
    this.paymentInfo,
  });
}

class Invoice {
  final InvoiceInfo info;
  final Pengirim pengirim;
  final Penerima penerima;
  final List<InvoiceItem> items;

  const Invoice({
    this.info,
    this.pengirim,
    this.penerima,
    this.items,
  });
}

class InvoiceInfo {
  final String description;
  final String number;
  final String date;
  final String payDate;
  final String payment;

  const InvoiceInfo({
    this.description,
    this.number,
    this.date,
    this.payDate,
    this.payment,
  });
}

class InvoiceItem {
  final String pengirim;
  final String penerima;
  final int quantity;
  final String uk_container;
  final String total;

  const InvoiceItem({
    this.pengirim,
    this.penerima,
    this.quantity,
    this.uk_container,
    this.total,
  });
}

class SyaratKetentuan {
  final String nama;
  final String nobukti;
  final String notelp;
  final String tanggal;
  final String lokmuat;
  final String lokbongkar;
  final String harga;
  final List<dynamic> syaratketentuan;

  const SyaratKetentuan(
      {this.nama,
      this.nobukti,
      this.notelp,
      this.tanggal,
      this.lokmuat,
      this.lokbongkar,
      this.harga,
      this.syaratketentuan});
}

class SyaratKetentuanRefund {
  final String nama;
  final String nobukti;
  final String notelp;
  final String tanggal;
  final String lokmuat;
  final String lokbongkar;
  final String harga;
  final List<dynamic> syaratketentuan;

  const SyaratKetentuanRefund(
      {this.nama,
      this.nobukti,
      this.notelp,
      this.tanggal,
      this.lokmuat,
      this.lokbongkar,
      this.harga,
      this.syaratketentuan});
}

class Favorites {
  int id;
  String userId;
  String placeid;
  String pelabuhanid;
  String alamat;
  String customer;
  String notelpcustomer;
  String latitudeplace;
  String longitudeplace;
  String namapelabuhan;
  String note;
  String labelName;

  Favorites({
    this.id,
    this.userId,
    this.placeid,
    this.pelabuhanid,
    this.alamat,
    this.customer,
    this.notelpcustomer,
    this.latitudeplace,
    this.longitudeplace,
    this.namapelabuhan,
    this.note,
    this.labelName,
  });

  // FORMAT TO JSON
  factory Favorites.fromJson(Map<String, dynamic> json) => Favorites(
        id: json["id"],
        userId: json["userId"],
        placeid: json["placeid"],
        pelabuhanid: json["pelabuhanid"],
        alamat: json["alamat"],
        customer: json["customer"],
        notelpcustomer: json["notelpcustomer"],
        latitudeplace: json["latitudeplace"],
        longitudeplace: json["longitudeplace"],
        namapelabuhan: json["namapelabuhan"],
        note: json["note"],
        labelName: json["labelName"],
      );

  static List<Favorites> fromJsonList(List list) {
    if (list == null) return null;
    return list.map((item) => Favorites.fromJson(item)).toList();
  }

  // @override
  // String toString() => ftrx_id;
}

class NotificationsData {
  String tgl;
  List<dynamic> dataNotifikasi;

  NotificationsData({this.tgl, this.dataNotifikasi});

  factory NotificationsData.fromJson(Map<String, dynamic> json) =>
      NotificationsData(
        tgl: json["tglbukti"],
        dataNotifikasi: json["list"],
      );

  static List<NotificationsData> fromJsonList(List list) {
    if (list == null) return null;
    return list.map((item) => NotificationsData.fromJson(item)).toList();
  }
}

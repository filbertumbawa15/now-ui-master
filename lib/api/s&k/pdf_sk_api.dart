import 'dart:io';
import 'package:flutter/material.dart' as mm;
import 'package:flutter/services.dart';
import 'package:now_ui_flutter/api/pdf_api.dart';
import 'package:now_ui_flutter/models/dart_models.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/widgets.dart';
import 'package:now_ui_flutter/globals.dart' as globals;

class PdfSKApi {
  static Future<File> generate(SyaratKetentuan syaratKetentuan) async {
    final pdf = Document();
    final imageJpg =
        (await rootBundle.load('assets/imgs/taslogo.png')).buffer.asUint8List();

    pdf.addPage(MultiPage(
      pageFormat: PdfPageFormat.legal,
      build: (context) => [
        buildHeader(imageJpg),
        buildTitle(syaratKetentuan),
        pw.Padding(
          padding: pw.EdgeInsets.only(top: 15.0, bottom: 15.0),
          child: pw.Text(
              "DENGAN HORMAT, \nSYARAT DAN KETENTUAN DALAM PEMESANAN ORDERAN"),
        ),
        buildSupplierAddress(syaratKetentuan),
        SizedBox(height: 1 * PdfPageFormat.mm),
        buildPengirim(syaratKetentuan),
        // buildInvoice(invoice),
        // Divider(),
        // buildTotal(invoice),
      ],
      footer: (context) => buildFooter(),
    ));

    return PdfApi.saveDocument(
        name: 'Bukti-Pengesahan ${syaratKetentuan.nobukti}.pdf', pdf: pdf);
  }

  static Widget buildHeader(var imageJpg) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              pw.Container(
                width: 80,
                child: Image(pw.MemoryImage(imageJpg)),
              ),
              Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  Text(
                    "JASA PENGURUSAN TRANSPORTASI",
                  ),
                  Text('PT. TRANSPORINDO AGUNG SEJAHTERA',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  Text(
                    '- EMKL - Export-Import - Inter Island - Trucking - Warehouse',
                  ),
                ],
              )
              // buildInvoiceInfo(invoice.info),
            ],
          ),
          pw.Divider(
            color: PdfColors.grey,
            indent: 0,
            endIndent: 0,
            height: 10.0,
          ),
        ],
      );

  static Widget buildCustomerAddress(SyaratKetentuan syaratKetentuan) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Kepada: ${syaratKetentuan.nama}',
              style: TextStyle(fontWeight: FontWeight.bold)),
          Text('No Bukti: ${syaratKetentuan.nobukti}',
              style: TextStyle(fontWeight: FontWeight.bold)),
          Text('Telp/Fax: ${syaratKetentuan.notelp}',
              style: TextStyle(fontWeight: FontWeight.bold)),
          Text('Email: test@gmail.com',
              style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      );

  static Widget buildTgl(SyaratKetentuan syaratKetentuan) => Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('Medan, ${syaratKetentuan.tanggal}',
              style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      );

  static Widget buildSupplierAddress(SyaratKetentuan syaratKetentuan) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Lokasi Muat : ${syaratKetentuan.lokmuat}",
              style: TextStyle(fontWeight: FontWeight.bold)),
          Text("Lokasi Bongkar : ${syaratKetentuan.lokbongkar}",
              style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 1 * PdfPageFormat.mm),
          Text("Harga : ${syaratKetentuan.harga}"),
        ],
      );

  static Widget buildTitle(SyaratKetentuan syaratKetentuan) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          pw.Container(
            width: 200,
            child: buildCustomerAddress(syaratKetentuan),
          ),
          pw.Container(
            width: 200,
            child: buildTgl(syaratKetentuan),
          ),
          // SizedBox(height: 0.8 * PdfPageFormat.cm),
        ],
      );

  static Widget buildPengirim(SyaratKetentuan syaratKetentuan) {
    final headers = [
      'ADAPUN HARGA TERSEBUT DIATAS BERLAKU DENGAN KONDISI SEBAGAI BERIKUT: ',
    ];
    final data = syaratKetentuan.syaratketentuan.asMap().entries.map((val) {
      int idx = val.key + 1;
      return [
        '$idx. ${val.value}',
      ];
    }).toList();

    return Table.fromTextArray(
      headers: headers,
      data: data,
      border: null,
      headerStyle: TextStyle(fontWeight: FontWeight.bold),
      headerDecoration: BoxDecoration(color: PdfColors.grey300),
      cellHeight: 15,
      cellAlignments: {
        0: Alignment.centerLeft,
      },
    );
  }

  static Widget buildPenerima(Invoice invoice) {
    final headers = [
      'Penerima',
    ];
    final data = invoice.items.map((item) {
      // final total = item.unitPrice * item.quantity * (1 + item.vat);

      return [
        item.penerima,
      ];
    }).toList();

    return Table.fromTextArray(
      headers: headers,
      data: data,
      border: null,
      headerStyle: TextStyle(fontWeight: FontWeight.bold),
      headerDecoration: BoxDecoration(color: PdfColors.grey300),
      cellHeight: 30,
      cellAlignments: {
        0: Alignment.centerLeft,
      },
    );
  }

  static Widget buildTotal(Invoice invoice) {
    final netTotal = invoice.items
        .map((item) =>
            //  item.quantity)
            int.parse(item.total.substring(4).replaceAll('.', '')))
        .reduce((item1, item2) => item1 + item2);
    // final vatPercent = invoice.items.first.vat;
    // final vat = netTotal * vatPercent;

    return Container(
      alignment: Alignment.centerRight,
      child: Row(
        children: [
          Spacer(flex: 6),
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildText(
                  title: 'Total',
                  value: NumberFormat.currency(
                          locale: 'id', symbol: 'Rp.', decimalDigits: 00)
                      .format(double.tryParse(netTotal.toString())),
                  unite: true,
                ),
                // buildText(
                //   title: 'Vat ${vatPercent * 100} %',
                //   value: Utils.formatPrice(vat),
                //   unite: true,
                // ),
                Divider(),
                buildText(
                  title: 'Total keseluruhan',
                  titleStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  value: NumberFormat.currency(
                          locale: 'id', symbol: 'Rp.', decimalDigits: 00)
                      .format(double.tryParse(netTotal.toString())),
                  unite: true,
                ),
                SizedBox(height: 2 * PdfPageFormat.mm),
                Container(height: 1, color: PdfColors.grey400),
                SizedBox(height: 0.5 * PdfPageFormat.mm),
                Container(height: 1, color: PdfColors.grey400),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildFooter() => Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Divider(),
          pw.RichText(
            text: pw.TextSpan(
              children: <TextSpan>[
                pw.TextSpan(
                  text: "Medan: ",
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.TextSpan(
                  text: "Jl.Pulau Menjangan No.3 KIM II, MEDAN 20242",
                ),
              ],
            ),
          ),
          pw.RichText(
            text: pw.TextSpan(
              children: <TextSpan>[
                pw.TextSpan(
                  text: "Jakarta: ",
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.TextSpan(
                  text:
                      "Jl.Gorontalo III No.10 Tanjung Priok, JAKARTA UTARA 14330",
                ),
              ],
            ),
          ),
          pw.RichText(
            text: pw.TextSpan(
              children: <TextSpan>[
                pw.TextSpan(
                  text: "Surabaya: ",
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.TextSpan(
                  text: "Jl. Margomulyo No 44 Blok DD No 12, SURABAYA ",
                ),
              ],
            ),
          ),
          pw.RichText(
            text: pw.TextSpan(
              children: <TextSpan>[
                pw.TextSpan(
                  text: "Makassar: ",
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.TextSpan(
                  text:
                      "Jl.Cakalang III Blok A No.24 Komplek Mall Cakalang MAKASSAR",
                ),
              ],
            ),
          ),
        ],
      );

  static buildSimpleText({
    String title,
    String value,
  }) {
    final style = TextStyle(fontWeight: FontWeight.bold);

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        Text(title, style: style),
        SizedBox(width: 2 * PdfPageFormat.mm),
        Text(value),
      ],
    );
  }

  static buildText({
    String title,
    String value,
    double width = double.infinity,
    TextStyle titleStyle,
    bool unite = false,
  }) {
    final style = titleStyle ?? TextStyle(fontWeight: FontWeight.bold);

    return Container(
      width: width,
      child: Row(
        children: [
          Expanded(child: Text(title, style: style)),
          Text(value, style: unite ? style : null),
        ],
      ),
    );
  }
}

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:number_display/number_display.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfInvoiceService {
  Future<Uint8List> createHelloWorld() {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(child: pw.Text('Hello World'));
        },
      ),
    );

    return pdf.save();
  }

  Future<void> savePdfFile(String fileName, Uint8List byteList) async {
    final output = await getTemporaryDirectory();
    var filePath = "${output.path}/$fileName.pdf";
    final file = File(filePath);
    await file.writeAsBytes(byteList);
    await OpenFile.open(file.path);

    // await OpenDocument.openDocument(filePath: filePath);
  }

  Future<Uint8List> generateInvoice(List soldProducts, var detailCustomerInfo,
      instantInvoiceDate, totalInvoicedAmt) async {
    final pdf = pw.Document();

    final logo =
        (await rootBundle.load("images/shopper_logo.png")).buffer.asUint8List();
    pdf.addPage(
      pw.MultiPage(
          margin: const pw.EdgeInsets.all(20),
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return <pw.Widget>[
              pw.Column(
                children: [
                  // getOrderNo(detailCustomerInfo),
                  pw.Header(
                    child: getCompanyInfo(logo),
                  ),
                  pw.Header(
                    child: customerInfo(detailCustomerInfo, instantInvoiceDate,
                        totalInvoicedAmt),
                    level: 0,
                  ),
                  getRowHeader(),

                  // ================= ROW DETAILS ===================
                  for (int x = 0; x < soldProducts.length; x++)
                    pw.Table(columnWidths: const {
                      0: pw.FixedColumnWidth(80),
                      1: pw.FixedColumnWidth(20),
                      2: pw.FixedColumnWidth(50),
                      3: pw.FixedColumnWidth(50),
                    }, children: [
                      pw.TableRow(
                          decoration: getDecoration(x % 2 == 0),
                          children: [
                            pw.Container(
                              // color: PdfColors.yellow,
                              alignment: pw.Alignment.centerLeft,
                              height: 30,
                              child: pw.Text(
                                soldProducts[x]['ptdName'].toString(),
                                // style: pw.TextStyle(

                                // ),
                              ),
                              // ),
                            ),
                            pw.Container(
                              // color: PdfColors.red,
                              height: 30,
                              alignment: pw.Alignment.centerRight,
                              child: pw.Text(
                                soldProducts[x]['qty'].toString(),
                                style: const pw.TextStyle(
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            pw.Container(
                              // color: PdfColors.green,
                              alignment: pw.Alignment.centerRight,
                              height: 30,
                              child: pw.Text(
                                formattedNumber(
                                        double.parse(soldProducts[x]['price']))
                                    .toString(),
                                style: const pw.TextStyle(
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            pw.Container(
                              alignment: pw.Alignment.centerRight,
                              height: 30,
                              // color: PdfColors.purple,
                              // child: pw.Center(
                              child: pw.Text(
                                formattedNumber(double.parse(
                                        soldProducts[x]['lineTotal']))
                                    .toString(),
                                style: const pw.TextStyle(
                                  fontSize: 13,
                                ),
                              ),
                              // ),
                            ),
                          ])
                    ]),
                  pw.Divider(thickness: 1),

                  pw.SizedBox(height: 10),
                  getSubTotalUnit(totalInvoicedAmt),
                ],
              ),
            ];
          },
          header: (context) {
            return pw.Container(
              child: pw.Column(children: [
                if (context.pageNumber > 1) getRowHeader(),
              ]),
            );
          },
          footer: (context) {
            final text = 'Page ${context.pageNumber} of ${context.pagesCount}';

            return pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(''),
                  pw.Text(
                    'Powered by Happy Shoppers',
                    style: const pw.TextStyle(
                      color: PdfColors.grey300,
                      fontSize: 9,
                    ),
                  ),
                  pw.Container(
                    alignment: pw.Alignment.centerRight,
                    // margin: const pw.EdgeInsets.only(top: 1 * PdfPageFormat.cm),
                    child: pw.Text(
                      text,
                      style: const pw.TextStyle(
                        color: PdfColors.black,
                      ),
                    ),
                  ),
                ]);
          }),
    );

    return pdf.save();
  }

  getOrderNo(detailCustomerInfo) {
    return pw.Container(
      height: 50,
      width: 600,
      color: PdfColors.grey300,
      child: pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          pw.Text(
            'Packing Slip for Order No: ${detailCustomerInfo['transaction_id']}',
            style: pw.TextStyle(
              fontSize: 18,
              color: PdfColors.grey500,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  getCompanyInfo(companyLogo) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          children: [
            pw.SizedBox(
              width: 200,
              child: pw.Container(
                child: pw.Text(
                  "Bill From: ",
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            pw.SizedBox(height: 15),
            pw.SizedBox(
              width: 200,
              child: pw.Container(
                child: pw.Text(
                  "Happy Shoppers Co. ",
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            pw.SizedBox(
              width: 200,
              child: pw.Container(
                child: pw.Text(
                  "34 Isolo Road",
                  style: const pw.TextStyle(
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            pw.SizedBox(
              width: 200,
              child: pw.Container(
                child: pw.Text(
                  "Off Ajao Estate,",
                  style: const pw.TextStyle(
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            pw.SizedBox(
              width: 200,
              child: pw.Container(
                child: pw.Text(
                  "Isolo Way,",
                  style: const pw.TextStyle(
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            pw.SizedBox(
              width: 200,
              child: pw.Container(
                child: pw.Text(
                  "Lagos.",
                  style: const pw.TextStyle(
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
        pw.Container(
          width: 180,
          // color: PdfColors.amber,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Image(pw.MemoryImage(companyLogo),
                  width: 70, height: 70, fit: pw.BoxFit.cover),
              pw.Text(
                "Happy Shoppers Co.",
                style: pw.TextStyle(
                  color: PdfColors.grey400,
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 8,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  customerInfo(detailCustomerInfo, instantInvoiceDate, totalInvoicedAmt) {
    return pw.Column(children: [
      pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
        pw.Text(
          'Bill To:',
          style: pw.TextStyle(
            fontSize: 15,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.Text(
          'INVOICE',
          style: pw.TextStyle(
            color: PdfColors.cyanAccent700,
            fontSize: 25,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.Text(''),
      ]),
      pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.SizedBox(
              width: 200,
              child: pw.Container(
                child: pw.Text(
                  "${detailCustomerInfo['address']}",
                  style: const pw.TextStyle(
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            pw.SizedBox(
              width: 200,
              child: pw.Container(
                child: pw.Text(
                  "${detailCustomerInfo['city']}",
                  style: const pw.TextStyle(
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            pw.SizedBox(
              width: 200,
              child: pw.Container(
                child: pw.Text(
                  "${detailCustomerInfo['state']}",
                  style: const pw.TextStyle(
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            pw.SizedBox(
              width: 200,
              child: pw.Container(
                child: pw.Row(children: [
                  pw.Text(
                    "Phone: ",
                    style: pw.TextStyle(
                      fontSize: 13,
                      color: PdfColors.blue800,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(
                      width: 180,
                      child: pw.Text(
                        "${detailCustomerInfo['mobile']}",
                        style: const pw.TextStyle(
                          fontSize: 12,
                        ),
                      ))
                ]),
              ),
            ),
            pw.SizedBox(
              width: 200,
              child: pw.Container(
                child: pw.Row(children: [
                  pw.Text(
                    "Alt Phone: ",
                    style: pw.TextStyle(
                      fontSize: 13,
                      color: PdfColors.blue800,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(
                      width: 160,
                      child: pw.Text(
                        "${detailCustomerInfo['altMobile']}",
                        style: const pw.TextStyle(
                          fontSize: 12,
                        ),
                      ))
                ]),
              ),
            ),
            pw.SizedBox(
              width: 200,
              child: pw.Container(
                child: pw.Row(children: [
                  pw.Text(
                    "Email: ",
                    style: pw.TextStyle(
                      fontSize: 13,
                      color: PdfColors.blue800,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(
                      width: 180,
                      child: pw.Text(
                        "${detailCustomerInfo['user_email']}",
                        style: const pw.TextStyle(
                          fontSize: 12,
                        ),
                      ))
                ]),
              ),
            ),
          ],
        ),
        pw.Container(
          width: 215,
          child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.SizedBox(
                  // width: 100,
                  // child: pw.Container(
                  child: pw.Row(children: [
                    pw.Text(
                      "Invoice Date: ",
                      style: pw.TextStyle(
                        fontSize: 13,
                        color: PdfColors.blue800,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(
                        width: 130,
                        child: pw.Text(
                          instantInvoiceDate.toString(),
                          style: const pw.TextStyle(
                            fontSize: 12,
                          ),
                        ))
                  ]),
                  // ),
                ),
                pw.SizedBox(
                  // width: 100,
                  // child: pw.Container(
                  //   width: 190,
                  //   color: PdfColors.green200,
                  child: pw.Row(children: [
                    pw.Text(
                      "Payment Method: ",
                      style: pw.TextStyle(
                        fontSize: 13,
                        color: PdfColors.blue800,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(
                      width: 100,
                      child: pw.Text(
                        "${detailCustomerInfo['payment_option']}",
                        style: const pw.TextStyle(
                          fontSize: 12,
                        ),
                      ),
                    )
                  ]),
                  // ),
                ),
                pw.SizedBox(
                  // width: 100,
                  // child: pw.Container(
                  child: pw.Row(children: [
                    pw.Text(
                      "Invoice Total: ",
                      style: pw.TextStyle(
                        fontSize: 13,
                        color: PdfColors.blue800,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(
                        width: 130,
                        child: pw.Text(
                          'N $totalInvoicedAmt',
                          style: pw.TextStyle(
                            color: PdfColors.cyanAccent700,
                            fontSize: 20,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ))
                  ]),
                  // ),
                ),
              ]),
        ),
      ]),
    ]);
  }

  static pw.Widget getRowHeader() {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Column(children: [
        pw.Table(columnWidths: const {
          0: pw.FixedColumnWidth(80),
          1: pw.FixedColumnWidth(20),
          2: pw.FixedColumnWidth(50),
          3: pw.FixedColumnWidth(50),
        }, children: [
          pw.TableRow(children: [
            pw.Container(
              // color: PdfColors.yellow200,
              alignment: pw.Alignment.centerLeft,
              child: pw.Text(
                'Item',
                style: pw.TextStyle(
                  fontSize: 18,
                  color: PdfColors.cyanAccent700,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.Container(
              // color: PdfColors.red200,
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                'Qty',
                style: pw.TextStyle(
                  fontSize: 18,
                  color: PdfColors.cyanAccent700,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.Container(
              // color: PdfColors.green200,
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                'Unit Price (N)',
                style: pw.TextStyle(
                  fontSize: 18,
                  color: PdfColors.cyanAccent700,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.Container(
              // color: PdfColors.purple200,
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                'Line Total (N)',
                style: pw.TextStyle(
                  fontSize: 18,
                  color: PdfColors.cyanAccent700,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          ])
        ]),
      ]),
    );
  }

  // ============ FIGURE FORMATTER TO TWO DECIMAL PLACES ===========
  final formattedNumber = createDisplay(
    length: 12,
    separator: ',',
    decimal: 2,
    decimalPoint: '.',
  );

  getSubTotalUnit(totalInvoicedAmt) {
    return pw.Container(
      // width: 500,
      child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(''),
            pw.Container(
              // color: PdfColors.amber300,
              child: pw.Table(
                columnWidths: const {
                  0: pw.FixedColumnWidth(100),
                  1: pw.FixedColumnWidth(140),
                },
                children: [
                  pw.TableRow(
                    children: [
                      pw.Container(
                        alignment: pw.Alignment.centerRight,
                        child: pw.Text(
                          'SUBTOTAL',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                      ),
                      pw.Container(
                        alignment: pw.Alignment.centerRight,
                        child: pw.Text(
                          'N $totalInvoicedAmt',
                        ),
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Container(
                        alignment: pw.Alignment.centerRight,
                        child: pw.Text(
                          'TAX',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                      ),
                      pw.Container(
                        alignment: pw.Alignment.centerRight,
                        child: pw.Text('N 0.00'),
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Container(
                        alignment: pw.Alignment.centerRight,
                        child: pw.Text(
                          'TOTAL',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                      ),
                      pw.Container(
                        alignment: pw.Alignment.centerRight,
                        child: pw.Text(
                          'N $totalInvoicedAmt',
                          style: pw.TextStyle(
                            fontSize: 20,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.cyanAccent700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ]),
    );
  }

  getDecoration([bool even = true]) {
    return pw.BoxDecoration(
      color: even ? PdfColors.grey100 : PdfColors.white,
      shape: pw.BoxShape.rectangle,
      // border: const pw.Border(
      //     bottom : pw.BorderSide( color: Colors.black87,
      //         width: 1, style: pw.BorderStyle.solid
      //     )
      // )
    );
  }
}

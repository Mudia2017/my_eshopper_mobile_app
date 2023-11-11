import 'dart:io';
import 'dart:typed_data';

// import 'package:open_document/open_document.dart';
// import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfPackingSlipService {
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

  Future<Uint8List> createPackingSlip(
      List soldProducts, var detailCustomerInfo) async {
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
                  getOrderNo(detailCustomerInfo),
                  pw.Header(
                    child: getCompanyInfo(logo),
                  ),
                  pw.Header(
                    child: customerInfo(detailCustomerInfo),
                  ),
                  getRowHeader(),
                  // pw.SizedBox(height: 250),
                  for (int x = 0; x < soldProducts.length; x++)
                    pw.Table(columnWidths: const {
                      0: pw.FixedColumnWidth(30),
                      1: pw.FixedColumnWidth(80),
                      2: pw.FixedColumnWidth(50),
                      3: pw.FixedColumnWidth(15),
                    }, children: [
                      pw.TableRow(
                          decoration: getDecoration(x % 2 == 0),
                          children: [
                            pw.Container(
                              // color: PdfColors.yellow,
                              // margin: const pw.EdgeInsets.only(left: 25),
                              alignment: pw.Alignment.center,
                              height: 30,
                              // child: pw.Center(
                              child: pw.Text(
                                'Image',
                                // getImageUrl(soldProducts[x]['ptdImage']),
                                // style: pw.TextStyle(

                                // ),
                              ),
                              // ),
                            ),
                            // (soldProducts[x]['ptdImage'].bodyBytes.toList()),
                            // pw.Image(

                            //   // pw.MemoryImage(
                            //   // soldProducts[x]['ptdImage'].buffer.asUint8List() == null
                            //   //     ? image
                            //   //     :
                            // soldProducts[x]['ptdImage'],
                            //   // width: 30,
                            //   // height: 30,
                            //   // fit: pw.BoxFit.cover
                            //   // ),
                            // ),
                            pw.Container(
                              // color: PdfColors.red,
                              alignment: pw.Alignment.centerLeft,
                              height: 30,
                              child: pw.Text(
                                soldProducts[x]['ptdName'].toString(),
                                style: pw.TextStyle(
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            pw.Container(
                              // color: PdfColors.green,
                              alignment: pw.Alignment.centerLeft,
                              height: 30,
                              child: pw.Text(
                                soldProducts[x]['storeLocation'].toString(),
                                style: pw.TextStyle(
                                  fontSize: 13,
                                ),
                              ),
                            ),

                            pw.Container(
                              // width: 50,
                              // margin: const pw.EdgeInsets.only(left: 20),
                              alignment: pw.Alignment.center,
                              height: 30,
                              // color: PdfColors.purple,
                              // child: pw.Center(
                              child: pw.Text(
                                soldProducts[x]['qty'].toString(),
                                // style: pw.TextStyle(
                                //   fontSize: 13,
                                // ),
                              ),
                              // ),
                            ),
                          ])
                    ]),
                  // pw.Footer(
                  //   title: pw.Text(
                  //       "Thanks for your trust, and till the next time."),
                  // ),
                  // pw.SizedBox(height: 25),
                  // pw.Text("Kind regards,"),
                  // pw.SizedBox(height: 25),
                  // pw.Text("Max Weber")
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
    // pdf.addPage(
    //   pw.Page(
    //     pageFormat: PdfPageFormat.a4,
    //     build: (pw.Context context) {
    //       return pw.Column(
    //         children: [
    //           getOrderNo(detailCustomerInfo),
    //           pw.SizedBox(height: 20),
    //           getCompanyInfo(logo),
    //           pw.SizedBox(height: 25),
    //           customerInfo(detailCustomerInfo),
    //           pw.SizedBox(height: 15),
    //           getRowHeader(),
    //           pw.SizedBox(height: 150),
    //           getRowDetails(soldProducts),
    //           pw.SizedBox(height: 15),
    //           pw.Text("Thanks for your trust, and till the next time."),
    //           pw.SizedBox(height: 25),
    //           pw.Text("Kind regards,"),
    //           pw.SizedBox(height: 25),
    //           pw.Text("Max Weber")
    //         ],
    //       );
    //     },
    //   ),
    // );
    return pdf.save();
  }

  // pw.Expanded itemColumn(List<CustomRow> elements) {
  //   return pw.Expanded(
  //     child: pw.Column(
  //       children: [
  //         for (var element in elements)
  //           pw.Row(
  //             children: [
  //               pw.Expanded(
  //                   child: pw.Text(element.ptdImage,
  //                       textAlign: pw.TextAlign.left)),
  //               pw.Expanded(
  //                   child: pw.Text(element.ptdName,
  //                       textAlign: pw.TextAlign.right)),
  //               pw.Expanded(
  //                   child: pw.Text(element.storeLocation,
  //                       textAlign: pw.TextAlign.right)),
  //               pw.Expanded(
  //                   child: pw.Text(element.qty, textAlign: pw.TextAlign.right)),
  //             ],
  //           )
  //       ],
  //     ),
  //   );
  // }

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
      mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
      children: [
        pw.Column(
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
        pw.Column(
          // crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
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
        )
      ],
    );
  }

  customerInfo(detailCustomerInfo) {
    return pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Ship To:',
                style: pw.TextStyle(
                  fontSize: 15,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
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
              pw.SizedBox(
                width: 200,
                child: pw.Container(
                  child: pw.Text(
                    "Customer Note:",
                    style: pw.TextStyle(
                      fontSize: 13,
                      color: PdfColors.blue800,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              ),
              pw.SizedBox(
                width: 200,
                child: pw.Text(
                  "${detailCustomerInfo['optional_note']}",
                  style: const pw.TextStyle(
                    fontSize: 12,
                  ),
                ),
              )
            ],
          ),
          pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.SizedBox(
              width: 270,
              child: pw.Container(
                child: pw.Row(children: [
                  pw.Text(
                    "Order No: ",
                    style: pw.TextStyle(
                      fontSize: 13,
                      color: PdfColors.blue800,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(
                      width: 210,
                      child: pw.Text(
                        "${detailCustomerInfo['transaction_id']}",
                        style: const pw.TextStyle(
                          fontSize: 12,
                        ),
                      ))
                ]),
              ),
            ),
            pw.SizedBox(
              width: 270,
              child: pw.Container(
                child: pw.Row(children: [
                  pw.Text(
                    "Order Date: ",
                    style: pw.TextStyle(
                      fontSize: 13,
                      color: PdfColors.blue800,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(
                    width: 190,
                    child: pw.Text(
                      "${detailCustomerInfo['order_date']}",
                      style: const pw.TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  )
                ]),
              ),
            ),
            pw.SizedBox(
              width: 270,
              child: pw.Container(
                child: pw.Row(children: [
                  pw.Text(
                    "Shipping Method: ",
                    style: pw.TextStyle(
                      fontSize: 13,
                      color: PdfColors.blue800,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(
                      width: 150,
                      child: pw.Text(
                        '',
                        style: const pw.TextStyle(
                          fontSize: 12,
                        ),
                      ))
                ]),
              ),
            ),
            pw.SizedBox(
              width: 270,
              child: pw.Container(
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
                      width: 150,
                      child: pw.Text(
                        "${detailCustomerInfo['payment_option']}",
                        style: const pw.TextStyle(
                          fontSize: 12,
                        ),
                      ))
                ]),
              ),
            ),
          ]),
        ]);
  }

  static pw.Widget getRowHeader() {
    return pw.Header(
      child: pw.Container(
        height: 50,
        color: PdfColors.orange200,
        child: pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              pw.Table(columnWidths: const {
                0: pw.FixedColumnWidth(30),
                1: pw.FixedColumnWidth(80),
                2: pw.FixedColumnWidth(50),
                3: pw.FixedColumnWidth(15),
              }, children: [
                pw.TableRow(children: [
                  pw.Container(
                    // color: PdfColors.yellow200,
                    child: pw.Center(
                      child: pw.Text(
                        'Image',
                        style: pw.TextStyle(
                          fontSize: 18,
                          color: PdfColors.black,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  pw.Container(
                    // color: PdfColors.red200,
                    child: pw.Text(
                      'Item',
                      style: pw.TextStyle(
                        fontSize: 18,
                        color: PdfColors.black,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  pw.Container(
                    // color: PdfColors.green200,
                    child: pw.Text(
                      'Store Location',
                      style: pw.TextStyle(
                        fontSize: 18,
                        color: PdfColors.black,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  pw.Container(
                    // color: PdfColors.purple200,
                    child: pw.Center(
                      child: pw.Text(
                        'Qty',
                        style: pw.TextStyle(
                          fontSize: 18,
                          color: PdfColors.black,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ])
              ]),
            ]),
      ),
    );
  }

  getRowDetails(List soldProducts) {
    return pw.Container(
        child: pw.Column(children: [
      for (int x = 0; x < soldProducts.length; x++)
        pw.Table(columnWidths: const {
          0: pw.FixedColumnWidth(30),
          1: pw.FixedColumnWidth(80),
          2: pw.FixedColumnWidth(50),
          3: pw.FixedColumnWidth(15),
        }, children: [
          pw.TableRow(children: [
            pw.Container(
              // color: PdfColors.yellow,
              margin: const pw.EdgeInsets.only(left: 25),
              height: 30,
              // child: pw.Center(
              child: pw.Text(
                'Image',
                // getImageUrl(soldProducts[x]['ptdImage']),
                // style: pw.TextStyle(

                // ),
              ),
              // ),
            ),
            // (soldProducts[x]['ptdImage'].bodyBytes.toList()),
            // pw.Image(

            //   // pw.MemoryImage(
            //   // soldProducts[x]['ptdImage'].buffer.asUint8List() == null
            //   //     ? image
            //   //     :
            // soldProducts[x]['ptdImage'],
            //   // width: 30,
            //   // height: 30,
            //   // fit: pw.BoxFit.cover
            //   // ),
            // ),
            pw.Container(
              // color: PdfColors.red,
              height: 30,
              child: pw.Text(
                soldProducts[x]['ptdName'].toString(),
                style: pw.TextStyle(
                  fontSize: 13,
                ),
              ),
            ),
            pw.Container(
              // color: PdfColors.green,
              height: 30,
              child: pw.Text(
                soldProducts[x]['storeLocation'].toString(),
                style: pw.TextStyle(
                  fontSize: 13,
                ),
              ),
            ),

            pw.Container(
              // width: 50,
              margin: const pw.EdgeInsets.only(left: 20),
              height: 30,
              // color: PdfColors.purple,
              // child: pw.Center(
              child: pw.Text(
                soldProducts[x]['qty'].toString(),
                // style: pw.TextStyle(
                //   fontSize: 13,
                // ),
              ),
              // ),
            ),
          ])
        ]),
    ]));
  }

  getDecoration([bool even = true]) {
    return const pw.BoxDecoration(
      // color: even ? PdfColors.brown100 : PdfColors.white,
      // shape: pw.BoxShape.rectangle,
      border: pw.Border(
        bottom: pw.BorderSide(
          color: PdfColors.grey300,
          width: 1,
          style: pw.BorderStyle.solid,
        ),
      ),
    );
  }
}

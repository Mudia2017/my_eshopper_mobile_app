import 'package:eshopper_mobile_app/componets/data_computation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class AllProductReviews extends StatefulWidget {
  final List ptdCommentData;
  final String avgRating;
  final String totalReview;
  final String totalOneRate;
  final String totalTwoRate;
  final String totalThreeRate;
  final String totalFourRate;
  final String totalFiveRate;

  AllProductReviews({
    required this.ptdCommentData,
    required this.avgRating,
    required this.totalReview,
    required this.totalOneRate,
    required this.totalTwoRate,
    required this.totalThreeRate,
    required this.totalFourRate,
    required this.totalFiveRate,
  });

  @override
  _AllProductReviewsState createState() => _AllProductReviewsState();
}

class _AllProductReviewsState extends State<AllProductReviews> {
  List filterPtdCommentData = [];
  var filteredCommentData = [];
  int numberFiltered = 0;

  // THIS FUNCTION IS CALLED WHEN EVER A FILTER IS SELECTED
  _runFilter(double radioBtnValue) {
    if (radioBtnValue == 1) {
      // FILTER ALL POSITIVE COMMENT AND DISPLAY RESULT TO USER.
      // ALL POSITIVE COMMENTS ARE FILTERED BASE ON 4 AND 5 STAR RATING
      filteredCommentData = [];
      numberFiltered = 0;
      filterPtdCommentData.where((result) {
        double rate = 0;
        if (result['rate'] > 3.9) {
          rate = result['rate'];
          filteredCommentData.add(result);
          numberFiltered += 1;
        }
        return filteredCommentData.contains(rate);
      }).toList();
      filterPtdCommentData = [];
      filterPtdCommentData = filteredCommentData;
    } else if (radioBtnValue == 2) {
      // FILTER ALL CRITICAL COMMENT AND DISPLAY RESULT TO UER.
      // ALL CRITICAL COMMENTS ARE FILTERED BASE STAR RATING WITH LESS THAN 4
      filteredCommentData = [];
      numberFiltered = 0;
      filterPtdCommentData.where((result) {
        double rate = 0;
        if (result['rate'] < 4) {
          rate = result['rate'];
          filteredCommentData.add(result);
          numberFiltered += 1;
        }
        return filteredCommentData.contains(rate);
      }).toList();
      filterPtdCommentData = [];
      filterPtdCommentData = filteredCommentData;
    }
  }

  var change = ''; // USED FOR COMMENT FILTER. GET THE VALUE OF WHAT USER SELECT

  @override
  Widget build(BuildContext context) {
    // PART OF THE LOGIC USED TO FILTER COMMENTS
    filterPtdCommentData = [];
    filterPtdCommentData = widget.ptdCommentData;
    if (change != '') {
      double val = double.parse(change);
      _runFilter(val);
    } else {
      filterPtdCommentData = [];
      filterPtdCommentData = widget.ptdCommentData;
    }

    var serviceProvider = Provider.of<DataProcessing>(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [
            Color(0xFF40C4FF),
            Color(0xFFA7FFEB),
          ])),
        ),
        title: titleSection(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  serviceProvider
                      .displayHorizontalStar(double.parse(widget.avgRating)),
                  const SizedBox(
                    width: 8,
                  ),
                  Text(
                      serviceProvider.formatNumberToOneDecimalPoint(
                              double.parse(widget.avgRating)) +
                          " out of 5",
                      style: GoogleFonts.sora().copyWith())
                ],
              ),
              if (change == '')
                Text("${widget.totalReview} ratings",
                    style: GoogleFonts.sora().copyWith()),
              if (change != '')
                Text("$numberFiltered ratings",
                    style: GoogleFonts.sora().copyWith()),
              const SizedBox(
                height: 15,
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(0),
                    width: 60,
                    child: Text(
                      "5 star",
                      style: GoogleFonts.sora().copyWith(),
                    ),
                  ),
                  Expanded(
                    flex: 6,
                    child: LinearPercentIndicator(
                      lineHeight: 18.0,
                      percent: double.parse(widget.totalFiveRate) / 100,
                      backgroundColor: Colors.grey,
                      progressColor: Colors.blue,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(0),
                    width: 60,
                    child: Text(
                      serviceProvider.formatNumberToInt(
                              double.parse(widget.totalFiveRate)) +
                          ' %',
                      textAlign: TextAlign.end,
                      style: GoogleFonts.sora().copyWith(),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 12,
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(0),
                    width: 60,
                    child: Text(
                      "4 star",
                      style: GoogleFonts.sora().copyWith(),
                    ),
                  ),
                  Expanded(
                    flex: 6,
                    child: LinearPercentIndicator(
                      lineHeight: 18.0,
                      percent: double.parse(widget.totalFourRate) / 100,
                      backgroundColor: Colors.grey,
                      progressColor: Colors.blue,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(0),
                    width: 60,
                    child: Text(
                      serviceProvider.formatNumberToInt(
                              double.parse(widget.totalFourRate)) +
                          ' %',
                      textAlign: TextAlign.end,
                      style: GoogleFonts.sora().copyWith(),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 12,
              ),
              Row(
                children: [
                  Container(
                      padding: const EdgeInsets.all(0),
                      width: 60,
                      child: Text(
                        "3 star",
                        style: GoogleFonts.sora().copyWith(),
                      )),
                  Expanded(
                    flex: 6,
                    child: LinearPercentIndicator(
                      lineHeight: 18.0,
                      percent: double.parse(widget.totalThreeRate) / 100,
                      backgroundColor: Colors.grey,
                      progressColor: Colors.blue,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(0),
                    width: 60,
                    child: Text(
                      serviceProvider.formatNumberToInt(
                              double.parse(widget.totalThreeRate)) +
                          ' %',
                      textAlign: TextAlign.end,
                      style: GoogleFonts.sora().copyWith(),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 12,
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(0),
                    width: 60,
                    child: Text(
                      "2 star",
                      style: GoogleFonts.sora().copyWith(),
                    ),
                  ),
                  Expanded(
                    flex: 6,
                    child: LinearPercentIndicator(
                      lineHeight: 18.0,
                      percent: double.parse(widget.totalTwoRate) / 100,
                      backgroundColor: Colors.grey,
                      progressColor: Colors.blue,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(0),
                    width: 60,
                    child: Text(
                      serviceProvider.formatNumberToInt(
                              double.parse(widget.totalTwoRate)) +
                          ' %',
                      textAlign: TextAlign.end,
                      style: GoogleFonts.sora().copyWith(),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 12,
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(0),
                    width: 60,
                    child: Text(
                      "1 star",
                      style: GoogleFonts.sora().copyWith(),
                    ),
                  ),
                  Expanded(
                    flex: 6,
                    child: LinearPercentIndicator(
                      lineHeight: 18.0,
                      percent: double.parse(widget.totalOneRate) / 100,
                      backgroundColor: Colors.grey,
                      progressColor: Colors.blue,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(0),
                    width: 60,
                    child: Text(
                      serviceProvider.formatNumberToInt(
                              double.parse(widget.totalOneRate)) +
                          ' %',
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
              Divider(
                height: 20,
                color: Colors.grey[800],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (change != '')
                    TextButton(
                      onPressed: () {
                        setState(() {
                          change = '';
                        });
                      },
                      child: Text(
                        'Clear Filter',
                        style: GoogleFonts.sora()
                            .copyWith(color: Colors.redAccent.shade700),
                      ),
                    ),
                  InkWell(
                    onTap: () {
                      // showDialog<void>(
                      //     context: context, builder: (context) => dialog);
                      _showMaterialDialog();
                    },
                    child: Text(
                      'Filter >>',
                      style: GoogleFonts.sora()
                          .copyWith(color: Colors.blue, fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (change == '1')
                    Text(
                      'All positive reviews',
                      style: GoogleFonts.sora().copyWith(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  if (change == '2')
                    Text(
                      'All critical reviews',
                      style: GoogleFonts.sora().copyWith(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    )
                ],
              ),
              const Divider(
                color: Colors.black45,
              ),
              Container(
                padding: const EdgeInsets.all(0),
                // height: MediaQuery.of(context).size.height *
                //     ((widget.ptdCommentData.length) / 4.5),
                child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filterPtdCommentData.length,
                    itemBuilder: (BuildContext context, int index) {
                      return commentSection(
                        filterPtdCommentData[index]["customer"],
                        filterPtdCommentData[index]["rate"],
                        filterPtdCommentData[index]["subject"],
                        filterPtdCommentData[index]["comment"],
                        filterPtdCommentData[index]["created_at"],
                      );
                    }),
              ),
              if (filterPtdCommentData.isEmpty)
                Container(
                  padding: const EdgeInsets.all(0),
                  height: 250,
                  child: Center(
                    child: Text(
                      'No Record',
                      style: GoogleFonts.sora().copyWith(
                        fontSize: 28,
                        color: Colors.grey.shade400,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }

  Container titleSection() {
    return Container(
      margin: const EdgeInsets.all(0.0),
      child: const Text("All Customer Reviews",
          style: TextStyle(
              color: Colors.black,
              fontSize: 25.0,
              fontWeight: FontWeight.bold)),
    );
  }

  Container commentSection(String cusName, double cusRate, String cusSubject,
      String cusComment, String createdDate) {
    var serviceProvider = Provider.of<DataProcessing>(context);
    return Container(
      padding: const EdgeInsets.all(0),
      child: ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                cusName,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: (GoogleFonts.sora().copyWith(
                    fontWeight: FontWeight.bold, color: Colors.grey[600])),
              ),
            ),
            Icon(
              Icons.how_to_reg,
              color: Colors.green[500],
            ),
            const Text(
              "Verified Purchase",
              style: TextStyle(fontSize: 12, color: Colors.green),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            serviceProvider.displayHorizontalSmallStar(cusRate),
            Text(cusSubject,
                style: GoogleFonts.sora().copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.black)),
            Text(
              createdDate,
              style: GoogleFonts.sora().copyWith(),
            ),
            Text(cusComment,
                style: GoogleFonts.sora().copyWith(color: Colors.black)),
            Divider(
              height: 15,
              color: Colors.grey[800],
            ),
          ],
        ),
      ),
    );
  }

  void _showMaterialDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: const Text('Filter Review '),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile(
                    value: 1,
                    groupValue: 2,
                    onChanged: (value) {
                      setState(() {
                        change = value.toString();
                      });

                      Navigator.of(context).pop();
                    },
                    title: Text('Positive reviews',
                        style: GoogleFonts.sora().copyWith()),
                  ),
                  RadioListTile(
                    value: 2,
                    groupValue: 3,
                    onChanged: (value) {
                      setState(() {
                        change = value.toString();
                      });

                      Navigator.of(context).pop();
                    },
                    title: Text('Critical reviews',
                        style: GoogleFonts.sora().copyWith()),
                  ),
                ],
              )

              // content: Column(
              //   mainAxisSize: MainAxisSize.min,
              //   children: [

              //     // Row(
              //     //   children: [
              //     //     Container(
              //     //       width: 300,
              //     //       child: RadioListTile(
              //     //         value: 1,
              //     //         groupValue: 2,
              //     //         onChanged: (value) {
              //     //           setState(() {
              //     //             change = value.toString();
              //     //           });

              //     //           Navigator.of(context).pop();
              //     //         },
              //     //         title: Text('Positive reviews',
              //     //             style: GoogleFonts.sora().copyWith()),
              //     //       ),
              //     //     ),
              //     //     const SizedBox(
              //     //       width: 10,
              //     //     ),
              //     //   ],
              //     // ),
              //     // Row(
              //     //   children: [
              //     //     Container(
              //     //       width: 300,
              //     //       child: RadioListTile(
              //     //         value: 2,
              //     //         groupValue: 3,
              //     //         onChanged: (value) {
              //     //           setState(() {
              //     //             change = value.toString();
              //     //           });

              //     //           Navigator.of(context).pop();
              //     //         },
              //     //         title: Text('Critical reviews',
              //     //             style: GoogleFonts.sora().copyWith()),
              //     //       ),
              //     //     ),
              //     //     const SizedBox(
              //     //       width: 10,
              //     //     ),
              //     //   ],
              //     // ),
              //   ],
              // ),
              );
        });
  }
}

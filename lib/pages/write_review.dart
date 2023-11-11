import 'package:eshopper_mobile_app/componets/data_computation.dart';
import 'package:eshopper_mobile_app/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class WriteReview extends StatefulWidget {
  final String token, userName, parentPtdReviewId, transId;
  WriteReview(
      {required this.token,
      required this.userName,
      required this.parentPtdReviewId,
      required this.transId});

  @override
  _WriteReviewState createState() => _WriteReviewState();
}

class _WriteReviewState extends State<WriteReview> {
  @override
  void initState() {
    super.initState();

    initializingFunctionCall(
        widget.token, widget.parentPtdReviewId, widget.transId);
  }

  bool isCompleteLoading = false;
  bool isLoadingError = false;
  List _myPendingReviewOrderItems = [];

  void initializingFunctionCall(token, parentPtdReviewId, transId) async {
    var serviceProvider = Provider.of<DataProcessing>(context, listen: false);
    var response = await serviceProvider.writePendingReview(
        token, parentPtdReviewId, transId, '', {}, '', '');

    setState(() {
      isLoadingError = response['isLoadingError'];
      isCompleteLoading = response['isCompleteLoading'];
      _myPendingReviewOrderItems = response['pendingReviewOrderItems'];
    });
  }

  commentRecord(subject, comment, double rating) {
    var commentInfo = {
      'subject': subject,
      'comment': comment,
      'rating': rating,
    };
    return commentInfo;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [
              Color(0xFF40C4FF),
              Color(0xFFA7FFEB),
            ]),
          ),
        ),
        title: appBarTitle(),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF40C4FF),
              Color(0xFFA7FFEB),
            ],
          ),
        ),
        child: isCompleteLoading
            ? Column(
                children: [
                  Text(
                    'Click on an item to write your review!',
                    style: GoogleFonts.philosopher().copyWith(
                      fontWeight: FontWeight.w100,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                  GridView.count(
                    childAspectRatio: 0.65,
                    shrinkWrap: true,
                    crossAxisCount: 3,
                    scrollDirection: Axis.vertical,
                    children: List.generate(
                      _myPendingReviewOrderItems.length,
                      (index) {
                        return ItemReviewGridViewList(
                          widget.token,
                          _myPendingReviewOrderItems.toList()[index]['ptd_id'],
                          _myPendingReviewOrderItems.toList()[index]
                              ['product_name'],
                          _myPendingReviewOrderItems.toList()[index]
                              ['product_image'],
                          _myPendingReviewOrderItems
                              .toList()[index]['id']
                              .toString(),
                          _myPendingReviewOrderItems.toList()[index]
                              ['ptd_review_id'],
                          widget.transId,
                        );
                      },
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isCompleteLoading == false)
                    const CircularProgressIndicator(),
                  if (isLoadingError == true)
                    Text(
                      'Error occured!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.red.shade200,
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  Container appBarTitle() {
    return Container(
      margin: const EdgeInsets.all(0.0),
      child: const Text("Write Product Review",
          style: TextStyle(
              color: Colors.black,
              fontSize: 20.0,
              fontWeight: FontWeight.bold)),
    );
  }

  Container ItemReviewGridViewList(token, ptdId, ptdName, ptdImage, ptdReviewId,
      parentPtdReviewId, transId) {
    return Container(
      child: Card(
        child: InkWell(
          onTap: () async {
            var response = await dialogBoxWritePtdReview(context, ptdName,
                token, parentPtdReviewId, transId, ptdId, ptdReviewId);

            if (response != null && response['isCompleteLoading'] == true) {
              setState(() {
                _myPendingReviewOrderItems =
                    response['pendingReviewOrderItems'];
              });

              if (_myPendingReviewOrderItems.isEmpty) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    RouteManager.myPtdReviewSession,
                    (Route<dynamic> route) => false,
                    arguments: {
                      'token': widget.token,
                      'userName': widget.userName
                    });
              }
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(0),
                child: GridTile(
                  child: Image.network(
                    ptdImage,
                    fit: BoxFit.contain,
                    height: 150,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Text(
                  ptdName,
                  style: GoogleFonts.sora().copyWith(
                      overflow: TextOverflow.ellipsis,
                      fontSize: 13,
                      color: Colors.lightBlueAccent.shade400),
                  maxLines: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ========= USED TO WRITE PRODUCT REVIEW OF ITEM ===========
  Future dialogBoxWritePtdReview(BuildContext context, ptdName, token,
      parentPtdReviewId, transId, ptdId, ptdReviewId) {
    var serviceProvider = Provider.of<DataProcessing>(context, listen: false);
    double rate = 0;
    TextEditingController commentController = TextEditingController();
    TextEditingController subjectController = TextEditingController();
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              scrollable: true,
              elevation: 0,
              title: Center(
                child: Row(
                  children: [
                    Text(
                      "Rate the Product: ",
                      style: GoogleFonts.sora()
                          .copyWith(fontSize: 15, fontWeight: FontWeight.w800),
                    ),
                    Expanded(
                      child: Text(
                        ptdName,
                        style: GoogleFonts.sora().copyWith(
                          color: Colors.blue,
                          fontSize: 15,
                        ),
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                        maxLines: 2,
                      ),
                    )
                  ],
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RatingBar.builder(
                    updateOnDrag: true,
                    initialRating: 0,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemBuilder: (context, _) => const Icon(
                      Icons.star,
                      color: Colors.orange,
                    ),
                    onRatingUpdate: (rating) {
                      setState(() {
                        rate = rating;
                      });
                    },
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    keyboardType: TextInputType.multiline,
                    controller: subjectController,
                    decoration: InputDecoration(
                      labelText: 'Subject',
                      hintStyle: GoogleFonts.sora().copyWith(),
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  TextField(
                    keyboardType: TextInputType.multiline,
                    controller: commentController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: "Kindly comment...",
                      hintStyle: GoogleFonts.sora().copyWith(),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    "Your Rating: " + rate.toString(),
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    MaterialButton(
                        color: Colors.grey.shade600,
                        elevation: 0,
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        }),
                    MaterialButton(
                      color: Colors.blue.shade400,
                      elevation: 0,
                      child: const Text(
                        'Submit',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                      ),
                      onPressed: () async {
                        var response;
                        if (rate == 0) {
                          serviceProvider.warningToastMassage(
                              'Kindly select star rating for this item!');
                        } else {
                          // CALL THE DIALOG TO PREVENT USER FROM THE UI UNTIL DATA IS SAVED TO THE SERVER
                          setState(() {
                            serviceProvider.isLoadDialogBox = true;
                            serviceProvider.buildShowDialog(context);
                          });
                          response = await serviceProvider.writePendingReview(
                            token,
                            parentPtdReviewId,
                            transId,
                            ptdId,
                            commentRecord(subjectController.text,
                                commentController.text, rate),
                            rate,
                            ptdReviewId,
                          );

                          // CALL THE DIALOG TO ALLOW USER PERFORM OPERATION ON THE UI

                          setState(() {
                            serviceProvider.isLoadDialogBox = false;
                            serviceProvider.buildShowDialog(context);
                          });

                          if (response['isCompleteLoading'] == true) {
                            Navigator.pop(context, response);
                            serviceProvider.toastMessage('Submited Successful');
                          } else {
                            serviceProvider
                                .warningToastMassage('Error occured');
                          }
                        }
                      },
                    ),
                  ],
                ),
              ],
            );
          });
        });
  }
}

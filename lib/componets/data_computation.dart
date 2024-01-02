// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:eshopper_mobile_app/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:number_display/number_display.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:flutter_paystack/flutter_paystack.dart';

class CartItem {
  final cartProductID;
  final cartProductName;
  final cartProductPrice;
  int cartProductQuantity;
  final pdtid;
  final cartProductImage;
  final cartPtdDiscount;
  final cartProdOutOfStock;
  final cartActivePtd;
  final cartActiveStore;

  CartItem(
      {this.cartProductID,
      this.cartProductName,
      this.cartProductPrice,
      this.cartProductQuantity = 0,
      this.pdtid,
      this.cartProductImage,
      this.cartPtdDiscount,
      this.cartProdOutOfStock,
      this.cartActivePtd,
      this.cartActiveStore});

  CartItem.fromMap(Map map)
      : pdtid = map['pdtid'],
        cartProductID = map['cartProductID'],
        cartProductName = map['cartProductName'],
        cartProductPrice = map['cartProductPrice'],
        cartProductQuantity = map['cartProductQuantity'],
        cartProductImage = map['cartProductImage'],
        cartPtdDiscount = map['cartProductDiscount'],
        cartProdOutOfStock = map['cartProdOutOfStock'],
        cartActivePtd = map['cartActiveProd'],
        cartActiveStore = map['cartActiveStore'];

  Map toMap() {
    return {
      'pdtid': pdtid,
      'cartProductID': cartProductID,
      'cartProductName': cartProductName,
      'cartProductPrice': cartProductPrice,
      'cartProductQuantity': cartProductQuantity,
      'cartProductImage': cartProductImage,
      'cartPtdDiscount': cartPtdDiscount,
      'cartProdOutOfStock': cartProdOutOfStock,
      'cartActiveProd': cartActivePtd,
      'cartActiveStore': cartActiveStore
    };
  }
}

class DataProcessing extends ChangeNotifier {
  List _item = [];
  Map<String, CartItem> _items = {};

  Map<String, CartItem> get items {
    return {..._items};
  }

  // =========== NUMBER OF ITEM ROW COUNT ============
  int get itemCount {
    return _items.length;
  }

  void addItem(String ptdId, String name, double price, String image,
      String outOfStock, String activePtd, String activeStore) {
    if (_items.containsKey(ptdId)) {
      _item = [];
      _items.update(
          ptdId,
          (existingCartItem) => CartItem(
                pdtid: ptdId,
                cartProductID: DateTime.now().toString(),
                cartProductName: existingCartItem.cartProductName,
                cartProductQuantity: existingCartItem.cartProductQuantity + 1,
                cartProductPrice: existingCartItem.cartProductPrice,
                cartProductImage: existingCartItem.cartProductImage,
                cartProdOutOfStock: existingCartItem.cartProdOutOfStock,
                cartActivePtd: existingCartItem.cartActivePtd,
                cartActiveStore: existingCartItem.cartActiveStore,
              ));
      for (var entry in _items.values) {
        _item.add(entry);
      }
      saveCartData();
      toastMessage('Item added to cart');
    } else {
      _item = [];
      _items.putIfAbsent(
          ptdId,
          () => CartItem(
                pdtid: ptdId,
                cartProductName: name,
                cartProductID: DateTime.now().toString(),
                cartProductQuantity: 1,
                cartProductPrice: price,
                cartProductImage: image,
                cartProdOutOfStock: outOfStock,
                cartActivePtd: activePtd,
                cartActiveStore: activeStore,
              ));
      for (var entry in _items.values) {
        _item.add(entry);
      }
      saveCartData();
      toastMessage('Item added to cart');
    }
    notifyListeners();
  }

  // =============== COMPUTE TOTAL AMOUNT ============
  double get totalAmt {
    double total = 0;
    _items.forEach((key, cartItem) {
      total += cartItem.cartProductPrice * cartItem.cartProductQuantity;
    });
    return total;
  }

  // =============== COMPUTE TOTAL CART ITEM(S) =============
  int get totalCartItm {
    int itemTotal = 0;
    _items.forEach((key, cartItem) {
      itemTotal += (cartItem.cartProductQuantity);
    });
    return itemTotal;
  }

  // ================ GET ROW TOTAL ==================
  double rowTotalAmt(double price, int qty) {
    double rowTotal = 0;
    rowTotal = price * qty;

    return rowTotal;
  }

  // =========== REMOVE SINGLE ITEM FROM ITEM-CART ============
  void removeSingleItem(String ptdId) {
    if (!_items.containsKey(ptdId)) {
      return;
    } else if (_items[ptdId]!.cartProductQuantity > 1) {
      _item = [];
      _items.update(
          ptdId,
          (existingCartItem) => CartItem(
                pdtid: ptdId,
                cartProductID: DateTime.now().toString(),
                cartProductName: existingCartItem.cartProductName,
                cartProductQuantity: existingCartItem.cartProductQuantity - 1,
                cartProductPrice: existingCartItem.cartProductPrice,
                cartProductImage: existingCartItem.cartProductImage,
                cartProdOutOfStock: existingCartItem.cartProdOutOfStock,
                cartActivePtd: existingCartItem.cartActivePtd,
                cartActiveStore: existingCartItem.cartActiveStore,
              ));
      for (var entry in _items.values) {
        _item.add(entry);
      }
      saveCartData();
      toastMessage('Item remove from cart');
    }
    notifyListeners();
  }

  // UPDATE CART DATA AGAINST PRICE CHANGE, OUT-OF-STOCK & PRODUCT STATUS
  void updateGuestCartItem(String ptdId, double ptdPrice, String outOfStock,
      String ptdActive, String ptdActiveStore) {
    if (!_items.containsKey(ptdId)) {
      return;
    } else {
      _item = [];
      _items.update(
          ptdId,
          (existingCartItem) => CartItem(
              pdtid: existingCartItem.pdtid,
              cartProductName: existingCartItem.cartProductName,
              cartProductID: existingCartItem.cartProductID,
              cartProductQuantity: existingCartItem.cartProductQuantity,
              cartProductPrice: ptdPrice,
              cartProductImage: existingCartItem.cartProductImage,
              cartProdOutOfStock: outOfStock,
              cartActivePtd: ptdActive,
              cartActiveStore: ptdActiveStore));
      for (var entry in _items.values) {
        _item.add(entry);
      }
      saveCartData();
    }
  }

  // =============== REMOVE SINGLE ROW ITEM FROM CART ==============
  void removeSingleRowItm(String ptdId) {
    _items.remove(ptdId);
    for (var entry in _items.values) {
      _item.add(entry);
    }
    saveCartData();
    notifyListeners();
  }

  // ================ SAVE CART DATA TO SHARED PREFERENCE ===============
  void saveCartData() async {
    SharedPreferences sharedPreference;
    sharedPreference = await SharedPreferences.getInstance();
    List<String> spList =
        _item.map((item) => json.encode(item.toMap())).toList();
    sharedPreference.setStringList('saveCartItem', spList);
    _item = [];
    // print(spList);
    notifyListeners();
  }

  // =========== USED TO UPLOAD CART DATA ===============
  void loadCartData(
    String pdtid,
    String name,
    double price,
    String image,
    int quantity,
    String outOfStock,
    String activePtd,
    String activeStore,
  ) {
    _items.putIfAbsent(
        pdtid,
        () => CartItem(
              pdtid: pdtid,
              cartProductName: name,
              cartProductID: DateTime.now().toString(),
              cartProductQuantity: quantity,
              cartProductPrice: price,
              cartProductImage: image,
              cartProdOutOfStock: outOfStock,
              cartActivePtd: activePtd,
              cartActiveStore: activeStore,
            ));
    // notifyListeners();
  }

  // ==== USED TO CLEAR ALL CART DATA FOR GUEST USER ======
  void removeAllCartRecord() async {
    SharedPreferences sharedPreferences;

    sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.remove('saveCartItem');
    _item = [];

    notifyListeners();
  }

  void clear() {
    _items = {};
    notifyListeners();
  }

  // =====================================================================
  bool isLoadDialogBox = false;

  buildShowDialog(BuildContext context) {
    isLoadDialogBox
        ? showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return Dialog(
                backgroundColor: Colors.black12,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    SizedBox(
                      height: 20,
                    ),
                    CircularProgressIndicator(
                      strokeWidth: 6.0,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      "Loading...",
                      style: TextStyle(
                          fontSize: 22,
                          fontStyle: FontStyle.italic,
                          color: Colors.white60),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              );
            },
          )
        : Navigator.pop(context);
  }

  // ========== GET USERNAME FROM SHARED PREFERENCE ===========
  static Future getUserNamePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var name = prefs.getString('username');
    if (name == 'Guest' || name == null) {
      name = 'Guest';
    }
    return name;
  }

  // ========= GET EMAIL FROM SHARED PREFERENCE ============
  static Future getUserEmailPreference() async {
    SharedPreferences emailPref = await SharedPreferences.getInstance();

    var email = emailPref.getString('useremail');
    if (email == '' || email == null) {
      email = '';
    }
    return email;
  }

  // ======== GET USER TOKEN FROM SHARED PREFERENCE ==========
  static Future getTokenFrmPreference() async {
    SharedPreferences tokenPref = await SharedPreferences.getInstance();

    var userToken = tokenPref.getString('token');
    if (userToken == '' || userToken == null) {
      userToken = '';
    }
    return userToken;
  }

  // ======== GET CUSTOMER ID FROM SHARED PREFERENCE ==========
  static Future getCusIdPreference() async {
    SharedPreferences customerId = await SharedPreferences.getInstance();

    var custId = customerId.getString('customerId').toString();
    if (custId == '' || custId == 'null') {
      custId = '';
    }
    return custId;
  }

  // ======== GET CUSTOMER NAME FROM SHARED PREFERENCE ==========
  static Future getCusNamePreference() async {
    SharedPreferences customerName = await SharedPreferences.getInstance();

    var custName = customerName.getString('custName').toString();
    if (custName == '' || custName == 'null') {
      custName = '';
    }
    return custName;
  }

  // ======== GET CUSTOMER EMAIL FROM SHARED PREFERENCE ==========
  static Future getCusEmailPreference() async {
    SharedPreferences customerEmail = await SharedPreferences.getInstance();

    var custEmail = customerEmail.getString('custEmail').toString();
    if (custEmail == '' || custEmail == 'null') {
      custEmail = '';
    }
    return custEmail;
  }

  // ======== GET USER ID FROM SHARED PREFERENCE ==========
  static Future getUserIdPreference() async {
    SharedPreferences userId = await SharedPreferences.getInstance();

    var _userId = userId.getString('userId').toString();
    if (_userId == '' || _userId == 'null') {
      _userId = '';
    }
    return _userId;
  }

  // ============ FIGURE FORMATTER TO TWO DECIMAL PLACES ===========
  final formattedNumber = createDisplay(
    length: 12,
    separator: ',',
    decimal: 2,
    decimalPoint: '.',
  );

  // ============ FIGURE FORMATTER TO ONE DECIMAL PLACE ===========
  final formatNumberToOneDecimalPoint = createDisplay(
    length: 12,
    separator: ',',
    decimal: 1,
    decimalPoint: '.',
  );

  // ============ FIGURE FORMATTER TO INT ===========
  final formatNumberToInt = createDisplay(
    length: 12,
    separator: ',',
    decimal: 0,
  );

  // ========= USED TO DISPLAY STAR RATINGS =========
  Container displayHorizontalStar(double value) {
    return Container(
      height: 50,
      child: Row(
        children: [
          RatingBarIndicator(
            rating: value,
            itemBuilder: (context, index) => const Icon(
              Icons.star_rate,
              color: Colors.orange,
            ),
            unratedColor: Colors.grey.shade800,
            itemCount: 5,
            itemSize: 25.0,
            direction: Axis.horizontal,
          ),
        ],
      ),
    );
  }

  // ========= DISPLAY SMALL STAR RATING ==========
  Container displayHorizontalSmallStar(double value) {
    return Container(
      height: 20,
      child: Row(
        children: [
          RatingBarIndicator(
            rating: value,
            itemBuilder: (context, index) => const Icon(
              Icons.star_rate,
              color: Colors.orange,
            ),
            unratedColor: Colors.grey.shade800,
            itemCount: 5,
            itemSize: 20.0,
            direction: Axis.horizontal,
          ),
        ],
      ),
    );
  }

  // =================== FLUTTER TOAST MESSAGE =================
  void toastMessage(toastMsg) {
    Fluttertoast.showToast(
      msg: toastMsg,
      fontSize: 18.0,
      backgroundColor: Colors.black45,
      textColor: Colors.white,
      toastLength: Toast.LENGTH_LONG,
      timeInSecForIosWeb: 8,
    );
  }

  void warningToastMassage(toastMsg) {
    Fluttertoast.showToast(
      msg: toastMsg,
      fontSize: 18.0,
      backgroundColor: Colors.orange.shade900,
      textColor: Colors.white,
      toastLength: Toast.LENGTH_LONG,
    );
  }

  // FOR AUTHENTICATED USER, ON THE ORDER TABLE OF THE DATABASE, WE ARE GOING TO
  // CREATE AN ORDER IF NONE EXIST BEFORE OR GET THE CUSTOMER'S ORDER WHOSE COMPLETE
  // STATUS IS FALSE.
  // ON THE DATABASE, WE WILL SAVE THE ITEM THAT WAS SELECTED BY THE USER IN THE
  // ORDER-ITEM TABLE, FROM THE API RESPONSE, WE WILL GET THE LIST OF ALL
  // ORDER-ITEMS AND TOTAL NUMBER OF ITEM COUNT
  String grandTotal = '0.0';
  bool isApiLoaded = false;
  var counter = 0;
  List updatedCartItems = [];
  List wishListData = [];
  bool isWishListData = false;

  Future apiCartDataUpdate(String name, userToken, ptdId, action) async {
    var updatedCartData = {};
    Map data = ({
      "customer": {"name": name},
      "ptd_id": ptdId,
      "action": action
    });

    var response = await http.post(
      // Uri.parse(
      //     "http://192.168.43.50:8000/apis/v1/homePage/api_updateCartData/"),
      Uri.parse(
          "http://Oneluvtoall.pythonanywhere.com/apis/v1/homePage/api_updateCartData/"),
      body: jsonEncode(data),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Token $userToken"
      },
    );
    if (response.statusCode == 200) {
      updatedCartData = json.decode(response.body);
      grandTotal = (updatedCartData['grand total']).toString();
      isApiLoaded = true;
      counter = updatedCartData['cart total count'];
      updatedCartItems = updatedCartData['cart item'];
      wishListData = updatedCartData['wishListData'];
      isWishListData = true;
      notifyListeners();
    } else {
      print('Error');
    }

    return updatedCartData;
  }

  Future apiCartData(String name, email, userToken) async {
    var cartData;

    Map data = ({
      "customer": {"name": name, "email": email},
    });

    var response = await http.post(
      // Uri.parse("http://192.168.43.50:8000/apis/v1/homePage/api_cartData/"),
      Uri.parse(
          "http://Oneluvtoall.pythonanywhere.com/apis/v1/homePage/api_cartData/"),
      body: jsonEncode(data),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Token $userToken"
      },
    );
    if (response.statusCode == 200) {
      var cartRecord = json.decode(response.body);
      cartData = cartRecord;
    }
    notifyListeners();
    return cartData;
  }

  Future processOrder(
      String userName,
      String userEmail,
      Map<String, dynamic> shippingInfo,
      String paymentMethod,
      String token,
      double amount,
      String payStackReference,
      bool status,
      verifyPtdList) async {
    var serverResponseMsg;
    var data = {
      "userName": userName,
      "shippingInfo": shippingInfo,
      "paymentMethod": paymentMethod,
      "amount": amount,
      "payStackReference": payStackReference,
      "paymentStatus": status,
      "guestCartData": verifyPtdList // ONLY USED FOR GUEST PURCHASE
    };

    if (token.isNotEmpty) {
      var response = await http.post(
        // Uri.parse(
        //     'http://192.168.43.50:8000/apis/v1/homePage/api_processOrder/'),
        Uri.parse(
            'http://Oneluvtoall.pythonanywhere.com/apis/v1/homePage/api_processOrder/'),
        body: jsonEncode(data),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Token $token",
        },
      );

      try {
        if (response.statusCode == 200) {
          var serverResponse = json.decode(response.body);
          serverResponseMsg = serverResponse;
        }
      } catch (error) {
        rethrow;
      }
    } else {
      // ======= ITS A GUEST USER REQUEST ==========
      var response = await http.post(
        // Uri.parse(
        //     'http://192.168.43.50:8000/apis/v1/homePage/api_processOrder/'),
        Uri.parse(
            'http://Oneluvtoall.pythonanywhere.com/apis/v1/homePage/api_processOrder/'),
        body: jsonEncode(data),
        headers: {"Content-Type": "application/json"},
      );

      try {
        if (response.statusCode == 200) {
          var serverResponse = json.decode(response.body);
          serverResponseMsg = serverResponse;
        }
      } catch (error) {
        rethrow;
      }
    }
    notifyListeners();
    return serverResponseMsg;
  }

  // THIS API IS FOR GUEST USERS. IT WILL TAKE THE CART ITEM(S) TO THE
  // SERVER, VERIFY THAT THE ITEM ARE CURRENTLY IN STOCK, THAT THE ITEM
  // PRICE TALLY WITH DB PRICE, THAT THE ITEM AND STORE ITEM ARE VALID.
  Future guestVerifyCartItems(List ptdData) async {
    var serverResponseMsg;
    var response = await http.post(
      // Uri.parse(
      //     'http://192.168.43.50:8000/apis/v1/homePage/api_guestVerifyCartItems/'),
      Uri.parse(
          'http://Oneluvtoall.pythonanywhere.com/apis/v1/homePage/api_guestVerifyCartItems/'),
      body: jsonEncode(ptdData),
      headers: {
        "Content-Type": "application/json",
      },
    );

    try {
      if (response.statusCode == 200) {
        var serverResponse = json.decode(response.body);
        serverResponseMsg = serverResponse['serverResponse'];
      }
    } catch (error) {
      rethrow;
    }

    return serverResponseMsg;
  }

  // API CALL TO SAVE/DELETE WISH LIST PRODUCT TO DATABASE
  Future sendWishListPtdToDB(ptdId, wishListType, token) async {
    var isHeartFill = false;
    var data = {'wishList': wishListType, 'ptdId': ptdId};
    var response = await http.post(
      // Uri.parse(
      //     'http://192.168.43.50:8000/apis/v1/homePage/api_get_PtdDetail_SameCategoryPtd/'),
      Uri.parse(
          'http://Oneluvtoall.pythonanywhere.com/apis/v1/homePage/api_get_PtdDetail_SameCategoryPtd/'),
      body: jsonEncode(data),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Token $token",
      },
    );
    try {
      if (response.statusCode == 200) {
        var serverResponse = json.decode(response.body);
        isHeartFill = serverResponse['isHeartFill'];
      }
    } catch (error) {
      rethrow;
    }
    // notifyListeners();
    return isHeartFill;
  }

  // ============ ADMIN API TO EDIT ORDER CREATED ====================
  bool isAdminUpdatedRecord = false;
  List adminOrderItemData = [];
  double adminUpdateOrderGrandTotal = 0;
  Map adminDetailOrderHeader = {};
  bool isVerifiedPayment = false;
  String transId = '';
  String orderStatus = '';
  Future adminUpdateOrder(
    bool isAdminUpdateOrder,
    orderNo,
    itemRowId,
    action,
    token,
    selectedVal,
    amtPaid,
    paymentMode,
    paymentNote,
    Map<String, dynamic> updateShippingInfo,
    closeOrderNote,
  ) async {
    var data = {
      'isAdminUpdateOrder': isAdminUpdateOrder,
      'order_no': orderNo,
      'itemRowId': itemRowId,
      'action': action,
      'selectedValue': selectedVal,
      'amtPaid': amtPaid,
      'paymentMode': paymentMode,
      'paymentNote': paymentNote,
      'updateShippingInfo': updateShippingInfo,
      'closeOrderNote': closeOrderNote,
    };

    var response = await http.post(
      // Uri.parse(
      //     'http://192.168.43.50:8000/apis/v1/homePage/api_adminEditOrder/'),
      Uri.parse(
          'http://Oneluvtoall.pythonanywhere.com/apis/v1/homePage/api_adminEditOrder/'),
      body: jsonEncode(data),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Token $token",
      },
    );

    try {
      if (response.statusCode == 200) {
        var adminDetailOrder = json.decode(response.body);
        isAdminUpdatedRecord = true;
        adminOrderItemData = adminDetailOrder['orderItemData'];
        adminDetailOrderHeader = adminDetailOrder['order_obj'];
        transId = adminDetailOrder['order_obj']['transaction_id'];
        orderStatus = adminDetailOrder['order_obj']['status'];
        if (adminDetailOrder['grandTotal'] == 0) {
          adminUpdateOrderGrandTotal = 0;
        } else {
          adminUpdateOrderGrandTotal =
              double.parse(adminDetailOrder['grandTotal']);
        }
        isVerifiedPayment = adminDetailOrder['isVerifiedPayment'];
      }
    } catch (error) {
      rethrow;
    }

    notifyListeners();
  }

  // ====== ADMIN API USED TO UPDATE REFUND ORDER ===========
  bool isAdminUpdatedRefundRecord = false;
  List updatedRefundOrderItem = [];
  double updatedTotalRefundAmt = 0;
  String updatedReasonForRefund = '';
  String updatedRefundPrivateNote = '';

  Future adminUpdateRefundOrder(bool isAdminUpdateRefund, token, itemRowId,
      inputAmt, transId, refundNote, reasonForRefund) async {
    var data = {
      'isAdminUpdateRefund': isAdminUpdateRefund,
      'itemRowId': itemRowId,
      'inputAmt': inputAmt,
      'transId': transId,
      'refundNote': refundNote,
      'reasonForRefund': reasonForRefund
    };

    var response = await http.post(
      // Uri.parse(
      //     'http://192.168.43.50:8000/apis/v1/homePage/api_adminProcessRefundOrder/'),
      Uri.parse(
          'http://Oneluvtoall.pythonanywhere.com/apis/v1/homePage/api_adminProcessRefundOrder/'),
      body: jsonEncode(data),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Token $token",
      },
    );

    try {
      if (response.statusCode == 200) {
        var adminRefundOrder = json.decode(response.body);

        updatedRefundOrderItem = adminRefundOrder['refundOrderItem'];
        if (adminRefundOrder['refundInfo']['totalRefundAmt'] == 0) {
          updatedTotalRefundAmt = 0;
        } else {
          updatedTotalRefundAmt =
              double.parse(adminRefundOrder['refundInfo']['totalRefundAmt']);
        }
        if (adminRefundOrder['refundInfo']['reasonForRefund'] == null) {
          updatedReasonForRefund = '';
        } else {
          updatedReasonForRefund =
              adminRefundOrder['refundInfo']['reasonForRefund'];
        }
        if (adminRefundOrder['refundInfo']['refundPrivateNote'] == null) {
          updatedRefundPrivateNote = '';
        } else {
          updatedRefundPrivateNote =
              adminRefundOrder['refundInfo']['refundPrivateNote'];
        }

        isAdminUpdatedRefundRecord =
            adminRefundOrder['refundInfo']['isRefundAmtUpdated'];
      }
    } catch (error) {
      isAdminUpdatedRefundRecord = false;
      // rethrow;
    }

    notifyListeners();
    return isAdminUpdatedRefundRecord;
  }

  // ========= API CALL TO LOAD PENDING REVIEW ITEM COMMENT PAGE PER CUSTOMER =======

  writePendingReview(token, parentPtdReviewId, transId, ptdId,
      Map ptdCommentData, rated, ptdReviewId) async {
    bool isLoadingError = false;
    bool isCompleteLoading = false;
    List peningReviewOrderItems = [];

    var data = {
      'parentPtdReviewId': parentPtdReviewId,
      'transId': transId,
      'ptdId': ptdId,
      'commentData': ptdCommentData,
      'rated': rated,
      'ptdReviewId': ptdReviewId,
    };
    var response = await http.post(
      // Uri.parse(
      //     'http://192.168.43.50:8000/apis/v1/homePage/api_writePtdReview/'),
      Uri.parse(
          'http://Oneluvtoall.pythonanywhere.com/apis/v1/homePage/api_writePtdReview/'),
      body: jsonEncode(data),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Token " + token,
      },
    );

    try {
      if (response.statusCode == 200) {
        var myPeningReviewOrderItems = json.decode(response.body);

        peningReviewOrderItems = myPeningReviewOrderItems;

        isCompleteLoading = true;
        isLoadingError = false;
      }
    } catch (error) {
      isLoadingError = true;
      isCompleteLoading = true;
      // rethrow;
    }
    Map dataRecord = {
      'isLoadingError': isLoadingError,
      'isCompleteLoading': isCompleteLoading,
      'pendingReviewOrderItems': peningReviewOrderItems,
    };
    notifyListeners();
    return dataRecord;
  }

  // ========= API CALL TO LOAD/UPDATE WISH LIST ITEM =======

  // "isSuccess" IS USED ON THE CUST CART PAGE. STATUS IS UPDATE ONCE CONDITION IS MEANT
  bool isSuccess = false;
  Map result = {};
  Future getWishListItem(
      token, customerId, selectedList, action, custName) async {
    var data = {
      'customerId': customerId,
      'selectedList': selectedList,
      'action': action,
      'customer': {'name': custName}
    };

    var response = await http.post(
      // Uri.parse('http://192.168.43.50:8000/apis/v1/homePage/api_wishList/'),
      Uri.parse(
          'http://Oneluvtoall.pythonanywhere.com/apis/v1/homePage/api_wishList/'),
      body: jsonEncode(data),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Token $token",
      },
    );

    try {
      if (response.statusCode == 200) {
        var _myWishListItems = json.decode(response.body);

        result['myWishListItems'] = _myWishListItems['wishListData'];
        result['inactive_outOfStock'] = _myWishListItems['inactive_outOfStock'];
        counter = _myWishListItems['cartCounter'];
        result['isCompleteLoading'] = true;
        result['isLoadingError'] = false;
        isSuccess = true;
        notifyListeners();
      }
    } catch (error) {
      result['isLoadingError'] = true;
      result['isCompleteLoading'] = true;
      // rethrow;
    }
    return result;
  }

  // ========= API CALL TO LOAD/UPDATE TRADER'S STORE =======
  Future traderStore(token, userId, storeRecord, isActive, action) async {
    Map result = {};
    var data = {
      'user_id': userId,
      'storeRecord': storeRecord,
      'isActive': isActive,
      'action': action,
    };
    var response = await http.post(
      // Uri.parse('http://192.168.43.50:8000/apis/v1/homePage/api_traderStore/'),
      Uri.parse(
          'http://Oneluvtoall.pythonanywhere.com/apis/v1/homePage/api_traderStore/'),
      body: jsonEncode(data),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Token $token",
      },
    );

    try {
      if (response.statusCode == 200) {
        var _serverResponse = json.decode(response.body);

        result = _serverResponse;
        // result['inactive_outOfStock'] = _myWishListItems['inactive_outOfStock'];

        result['isCompleteLoading'] = true;
        result['isLoadingError'] = false;
      }
    } catch (error) {
      result['isLoadingError'] = true;
      result['isCompleteLoading'] = true;
      // rethrow;
    }
    return result;
  }

  // === API CALL TO GET A TRADER'S ITEM(S) PRODUCT OVERVIEW PAGE =========
  getTraderItems(token, userId, caller, list, value) async {
    Map serverResp = {};
    List traderItmList = [];
    List filterTraderItmList = [];
    bool isDoneLoading = false;
    bool isErrorLoading = false;
    var data = {
      'userId': userId,
      'caller': caller,
      'list': list,
      'value': value
    };

    var response = await http.post(
      // Uri.parse(
      //     'http://192.168.43.50:8000/apis/v1/homePage/api_productOverView/'),
      Uri.parse(
          'http://Oneluvtoall.pythonanywhere.com/apis/v1/homePage/api_productOverView/'),
      body: jsonEncode(data),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Token " + token,
      },
    );

    try {
      if (response.statusCode == 200) {
        var tStoreData = json.decode(response.body);
        serverResp = tStoreData;

        traderItmList = tStoreData['traderPtdList'];
        filterTraderItmList = traderItmList;
        isDoneLoading = true;
      }
    } catch (error) {
      isErrorLoading = true;
    }
    Map dataRecord = {
      'serverResp': serverResp,
      'isDoneLoading': isDoneLoading,
      'traderItmList': traderItmList,
      'filterTraderItmList': filterTraderItmList,
      'isErrorLoading': isErrorLoading
    };
    return dataRecord;
  }

  // ============= API CALL TO DISPLAY EDITABLE PRODUCT ============
  getEditablePtd(token, ptdId, userId, call, editPtdRcd) async {
    Map myEditableRecord = {};
    bool isDoneLoading = false;
    bool isErrorLoading = false;
    var data = {
      'ptdId': ptdId,
      'userId': userId,
      'call': call,
      'editPrdRcd': editPtdRcd
    };
    var response = await http.post(
      // Uri.parse('http://192.168.43.50:8000/apis/v1/homePage/api_editProduct/'),
      Uri.parse(
          'http://Oneluvtoall.pythonanywhere.com/apis/v1/homePage/api_editProduct/'),
      body: jsonEncode(data),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Token " + token,
      },
    );

    try {
      if (response.statusCode == 200) {
        var myEditablePtdData = json.decode(response.body);
        myEditableRecord = myEditablePtdData;

        isDoneLoading = true;
      }
    } catch (error) {
      isErrorLoading = true;
      // rethrow;
    }
    Map dataRecord = {
      'myEditableRecord': myEditableRecord,
      'isDoneLoading': isDoneLoading,
      'isErrorLoading': isErrorLoading
    };
    return dataRecord;
  }

  // ===== API CALL FUNCTION TO CHANGE IMAGE WITH A NEW IMAGE FILE. ===
  // THIS FUNCTION IS ONLY CALLED WHEN THER IS A CHANGE OF IMAGE OR
  // WHEN UPLOADING A NEW IMAGE TO AN EXISTING PRODUCT FOR THE 1ST TIME
  editPtdImage(
    token,
    ptdId,
    userId,
    call,
    ptdName,
    ptdDescription,
    ptdCategory,
    ptdBrand,
    ptdPrice,
    ptdMfgDate,
    ptdExpDate,
    ptdDiscount,
    ptdOutOfStock,
    ptdStore,
    isActivePtd,
    File imageFile,
  ) async {
    var serverRes = '';
    var request = http.MultipartRequest(
      'POST',
      // Uri.parse("http://192.168.43.50:8000/apis/v1/homePage/api_editProduct/"),
      Uri.parse(
          "http://Oneluvtoall.pythonanywhere.com/apis/v1/homePage/api_editProduct/"),
    );
    Map<String, String> headers = {
      "Authorization": "Token $token",
      "Content-type": "multipart/form-data"
    };
    if (imageFile.path != '') {
      request.files.add(
        http.MultipartFile(
          'image',
          imageFile.readAsBytes().asStream(),
          imageFile.lengthSync(),

          filename: imageFile.path.split('/').last,
          // contentType: MediaType('image','jpeg'),
        ),
      );
    }

    request.headers.addAll(headers);
    request.fields.addAll({
      'ptdId': ptdId,
      'userId': userId,
      'call': call,
      'name': ptdName,
      'description': ptdDescription,
      'categoryId': ptdCategory,
      'brandId': ptdBrand,
      'price': ptdPrice,
      'mfgDate': ptdMfgDate,
      'expDate': ptdExpDate,
      'discount': ptdDiscount,
      'outOfStock': ptdOutOfStock,
      'storeId': ptdStore,
      'isActive': getBoolValue(isActivePtd)
    });
    var response = await request.send();
    if (response.statusCode == 200) {
      serverRes = await response.stream.bytesToString();
    } else {
      serverRes = await response.stream.bytesToString();
      print(serverRes);
    }

    return serverRes;
  }

  getBoolValue(val) {
    if (val == true) {
      return val = 'yes';
    } else {
      return val = 'no';
    }
  }

  // ======== API CALL FOR ADDING NEW PRODUCT =======
  addNewPtd(
    token,
    call,
    ptdName,
    ptdDescription,
    ptdCategoryId,
    ptdBrand,
    ptdPrice,
    ptdMfgDate,
    ptdExpDate,
    ptdDiscount,
    ptdOutOfStock,
    ptdStore,
    isActivePtd,
    File imageFile,
  ) async {
    var serverRes = '';
    bool isDoneLoading = false;
    bool isErrorLoading = false;

    var request = http.MultipartRequest(
      'POST',
      // Uri.parse("http://192.168.43.50:8000/apis/v1/homePage/api_addProduct/"),
      Uri.parse(
          "http://Oneluvtoall.pythonanywhere.com/apis/v1/homePage/api_addProduct/"),
    );
    Map<String, String> headers = {
      "Authorization": "Token $token",
      "Content-type": "multipart/form-data"
    };
    if (imageFile.path != '') {
      request.files.add(
        http.MultipartFile(
          'image',
          imageFile.readAsBytes().asStream(),
          imageFile.lengthSync(),

          filename: imageFile.path.split('/').last,
          // contentType: MediaType('image','jpeg'),
        ),
      );
    }

    // var outOfStock = getOutOfStock(ptdOutOfStock);

    request.headers.addAll(headers);
    request.fields.addAll({
      'call': call,
      'name': ptdName,
      'description': ptdDescription,
      'categoryId': ptdCategoryId,
      'brandId': ptdBrand,
      'price': ptdPrice,
      'mfgDate': ptdMfgDate,
      'expDate': ptdExpDate,
      'discount': ptdDiscount,
      'outOfStock': ptdOutOfStock,
      'storeId': ptdStore,
      'isActive': getBoolValue(isActivePtd)
    });
    var response = await request.send();
    if (response.statusCode == 200) {
      serverRes = await response.stream.bytesToString();

      print(serverRes);
      // var serverResponse = json.decode(response);
      //   serverReply = serverResponse;
    } else {
      serverRes = await response.stream.bytesToString();
      print(serverRes);
    }

    return serverRes;
  }

  // ========= API CALL TO SHIPPING CUSTOMER ADDRESS =======

  Future updateCustomerAddress(
      token, shipAddressId, call, addressRecord) async {
    // List dataList = [];
    Map recordData = {};
    var data = {
      'shipAddressId': shipAddressId,
      'call': call,
      'addressRecord': addressRecord,
    };
    var response = await http.post(
      // Uri.parse(
      //     'http://192.168.43.50:8000/apis/v1/homePage/api_updateCustomerAddress/'),
      Uri.parse(
          'http://Oneluvtoall.pythonanywhere.com/apis/v1/homePage/api_updateCustomerAddress/'),
      body: jsonEncode(data),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Token $token",
      },
    );

    try {
      if (response.statusCode == 200) {
        var _serverResponse = json.decode(response.body);

        recordData['isSuccess'] = _serverResponse['isSuccess'];
        if (recordData['isSuccess'] == false) {
          recordData['errorMsg'] = _serverResponse['error_msg'];
        }
      }
    } catch (error) {
      // result['isLoadingError'] = true;
      // result['isCompleteLoading'] = true;
      // rethrow;
    }

    return recordData;
  }

  // ========= API ADMIN SETTING CALL =======

  Future adminSetting(token, isActiveSwitch, storeId, call, value) async {
    // List dataList = [];
    Map recordData = {};
    var data = {
      'isActiveSwitch': isActiveSwitch,
      'id': storeId,
      'call': call,
      'value': value,
    };
    var response = await http.post(
      // Uri.parse('http://192.168.43.50:8000/apis/v1/homePage/api_adminSetting/'),
      Uri.parse(
          'http://Oneluvtoall.pythonanywhere.com/apis/v1/homePage/api_adminSetting/'),
      body: jsonEncode(data),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Token $token",
      },
    );

    try {
      if (response.statusCode == 200) {
        var _serverResponse = json.decode(response.body);

        recordData = _serverResponse;
        if (recordData['isSuccess'] == false) {
          recordData['errorMsg'] = _serverResponse['error_msg'];
        }
      }
    } catch (error) {
      // result['isLoadingError'] = true;
      // result['isCompleteLoading'] = true;
      // rethrow;
    }

    return recordData;
  }

  // ========= API GET PTD CATEGORY OR PTD BRAND =======

  Future getCategoryBrand(token, call) async {
    // List dataList = [];
    Map recordData = {};
    var data = {
      'call': call,
    };
    var response = await http.post(
      // Uri.parse(
      //     'http://192.168.43.50:8000/apis/v1/homePage/api_ptdCategoryBrand/'),
      Uri.parse(
          'http://Oneluvtoall.pythonanywhere.com/apis/v1/homePage/api_ptdCategoryBrand/'),
      body: jsonEncode(data),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Token $token",
      },
    );

    try {
      if (response.statusCode == 200) {
        var _serverResponse = json.decode(response.body);

        recordData = _serverResponse;
        // if (recordData['isSuccess'] == false) {
        //   recordData['errorMsg'] = _serverResponse['error_msg'];
        // }
      }
    } catch (error) {
      // result['isLoadingError'] = true;
      // result['isCompleteLoading'] = true;
      // rethrow;
    }

    return recordData;
  }

  // API CALL TO GET PRODUCT OF THE SAME CATEGORY
  Future getPtdSameCategory(token, ptdId, category, call) async {
    Map data = {
      'categoryName': category,
      'ptdId': ptdId,
      'call': call,
    };
    var serverResponseMsg;
    var response = await http.post(
      // Uri.parse('http://192.168.43.50:8000/apis/v1/homePage/api_cartData/'),
      Uri.parse(
          'http://Oneluvtoall.pythonanywhere.com/apis/v1/homePage/api_cartData/'),
      body: jsonEncode(data),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Token $token",
      },
    );

    try {
      if (response.statusCode == 200) {
        var serverResponse = json.decode(response.body);
        serverResponseMsg = serverResponse['sameCatPtdList'];
      }
    } catch (error) {
      rethrow;
    }

    return serverResponseMsg;
  }

  // API CALL TO VIEW OR DELETE ALL RECENT VIEWED ITEMS
  bool isRecentlyViewItmDeleted = false;
  allRecentlyViewedItem(call, token) async {
    var _allRecentViewedData;
    List _allRecentViewList = [];

    var response;
    Map data = {'call': call};
    response = await http.post(
      // Uri.parse(
      //     "http://192.168.43.50:8000/apis/v1/homePage/api_allRecentView/"),
      Uri.parse(
          "http://Oneluvtoall.pythonanywhere.com/apis/v1/homePage/api_allRecentView/"),
      body: json.encode(data),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Token $token",
      },
    );
    try {
      if (response.statusCode == 200) {
        var allRecentViewedData = json.decode(response.body);
        _allRecentViewedData = allRecentViewedData;
        _allRecentViewList = _allRecentViewedData['allRecentViewList'];
        if (_allRecentViewList.isEmpty) {
          isRecentlyViewItmDeleted = true;
        }
      }
    } catch (error) {
      rethrow;
    }
    notifyListeners();
    return _allRecentViewedData;
  }

  // API CALL TO GET ALL SELLER ITEMS
  allSellerItems(storeId, token) async {
    var _allSellerRecords;
    List _allRecentViewList = [];

    var response;
    Map data = {'storeId': storeId};
    response = await http.post(
      // Uri.parse(
      //     "http://192.168.43.50:8000/apis/v1/homePage/api_allSellerItems/"),
      Uri.parse(
          "http://Oneluvtoall.pythonanywhere.com/apis/v1/homePage/api_allSellerItems/"),
      body: json.encode(data),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Token $token",
      },
    );
    try {
      if (response.statusCode == 200) {
        var allSellerData = json.decode(response.body);
        _allSellerRecords = allSellerData;
      }
    } catch (error) {
      rethrow;
    }
    notifyListeners();
    return _allSellerRecords;
  }

  // ========= USED TO CONFIRM ANY ACTION ON ADMIN EDIT ORDERED ITEM ===========
  Future confirmationPopDialogMsg(
    BuildContext context,
    String titleMsg,
    contentMsg,
    orderNo,
    itemRowId,
    action,
    token,
    selectedVal,
    amtPaid,
    paymentMode,
    paymentNote,
    closeOrderNote,
    callFrom,
  ) {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.black54,
              scrollable: true,
              elevation: 0,
              title: Center(
                child: Text(
                  titleMsg,
                  style: GoogleFonts.sora().copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.yellow.shade800,
                  ),
                ),
              ),
              content: Text(
                contentMsg,
                style: GoogleFonts.sora()
                    .copyWith(fontSize: 18, color: Colors.white60),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    MaterialButton(
                        color: Colors.grey.shade700,
                        elevation: 0,
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        ),
                        onPressed: () {
                          Navigator.pop(context, 'cancel');
                        }),
                    if (callFrom == 'admin_edit_order' ||
                        callFrom == 'edit_my_order')
                      MaterialButton(
                          color: Colors.blue.shade400,
                          elevation: 0,
                          child: const Text(
                            'Continue',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18),
                          ),
                          onPressed: () async {
                            // CALL THE DIALOG TO PREVENT USER FROM THE UI UNTIL DATA IS SAVED TO THE SERVER
                            setState(() {
                              isLoadDialogBox = true;
                              buildShowDialog(context);
                            });
                            var response = await adminUpdateOrder(
                              true,
                              orderNo,
                              itemRowId,
                              action,
                              token,
                              selectedVal,
                              amtPaid,
                              paymentMode,
                              paymentNote,
                              {},
                              closeOrderNote,
                            );

                            // CALL THE DIALOG TO ALLOW USER PERFORM OPERATION ON THE UI

                            setState(() {
                              isLoadDialogBox = false;
                              buildShowDialog(context);
                            });
                            Navigator.pop(context, response);
                          }),
                    if (callFrom == 'my_wish_list')
                      MaterialButton(
                          color: Colors.blue.shade400,
                          elevation: 0,
                          child: const Text(
                            'Continue',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18),
                          ),
                          onPressed: () async {
                            // CALL THE DIALOG TO PREVENT USER FROM THE UI UNTIL DATA IS SAVED TO THE SERVER
                            setState(() {
                              isLoadDialogBox = true;
                              buildShowDialog(context);
                            });
                            // THIS CALL IS TO DELETE SELECTED WISHLIST ITEMS FROM DB
                            var response = await getWishListItem(
                              token,
                              orderNo,
                              itemRowId,
                              action,
                              '',
                            );

                            // CALL THE DIALOG TO ALLOW USER PERFORM OPERATION ON THE UI

                            setState(() {
                              isLoadDialogBox = false;
                              buildShowDialog(context);
                            });
                            Navigator.pop(context, response);
                          }),
                  ],
                ),
              ],
            );
          });
        });
  }

  // ========== THIS ALERT DIALOG POP UP WHEN ORDER IS CREATED ===========
  Future customAlertDialogMsg(BuildContext context, String titleMsg, contentMsg,
      actionMsg, Map<String, dynamic> userInfo) {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (contex) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              scrollable: true,
              elevation: 15,
              title: Center(
                child: Text(
                  titleMsg,
                  style: GoogleFonts.sora().copyWith(
                      fontSize: 20,
                      color: Colors.cyanAccent.shade700,
                      fontWeight: FontWeight.bold),
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    height: 15,
                  ),
                  if (actionMsg == 'transaction completed')
                    Text(
                      contentMsg,
                      style: GoogleFonts.sora().copyWith(
                          fontSize: 15, color: Colors.greenAccent.shade700),
                    ),
                  if (actionMsg == "item(s) not valid" ||
                      actionMsg == 'invalid guest cart')
                    Text(
                      contentMsg,
                      style: GoogleFonts.sora()
                          .copyWith(fontSize: 15, color: Colors.red.shade800),
                    ),
                  if ((actionMsg != 'invalid guest cart' ||
                          actionMsg != "item(s) not valid") &&
                      actionMsg != 'transaction completed')
                    Text(
                      contentMsg[0],
                      style: GoogleFonts.sora()
                          .copyWith(fontSize: 15, color: Colors.red.shade800),
                    ),
                ],
              ),
              actions: [
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MaterialButton(
                        color: Colors.blueAccent,
                        elevation: 10.0,
                        child: const Text(
                          'Ok',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        ),
                        onPressed: () {
                          if (actionMsg == 'transaction completed') {
                            // REDIRECT CUSTOMER TO HOME PAGE
                            Navigator.of(context).pushNamedAndRemoveUntil(
                                RouteManager.homePage,
                                (Route<dynamic> route) => false);
                          } else if (actionMsg == "item(s) not valid") {
                            // REDIRECT CUSTOMER TO MARKET PLACE
                            Navigator.of(context).pushNamedAndRemoveUntil(
                                RouteManager.marketPlace,
                                (Route<dynamic> route) => false,
                                arguments: {
                                  'username': userInfo['userName'],
                                  'useremail': userInfo['userEmail'],
                                  'usertoken': userInfo['token'],
                                  'custId': userInfo['custId'],
                                });
                          } else if (actionMsg == 'invalid guest cart') {
                            // REDIRECT GUEST TO MARKET PLACE
                            Navigator.of(context).pushNamedAndRemoveUntil(
                                RouteManager.marketPlace,
                                (Route<dynamic> route) => false,
                                arguments: {
                                  'username': 'Guest',
                                  'useremail': '',
                                  'usertoken': ''
                                });
                          } else {
                            // REDIRECT CUSTOMER TO MARKET PLACE
                            Navigator.of(context).pushNamedAndRemoveUntil(
                                RouteManager.marketPlace,
                                (Route<dynamic> route) => false,
                                arguments: {
                                  'username': userInfo['userName'],
                                  'useremail': userInfo['userEmail'],
                                  'usertoken': userInfo['token'],
                                  'custId': userInfo['custId'],
                                });
                          }
                        },
                      ),
                    ],
                  ),
                )
              ],
            );
          });
        });
  }

  // ========= USED TO DISPLAY A POP UP MESSAGE ===========
  Future popDialogMsg(BuildContext context, String titleMsg, contentMsg) {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.blue.shade100,
              scrollable: true,
              elevation: 0,
              title: Center(
                child: Text(
                  titleMsg,
                  style: GoogleFonts.sora()
                      .copyWith(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              content: Text(
                contentMsg,
                style: GoogleFonts.sora()
                    .copyWith(fontSize: 15, color: Colors.black38),
              ),
              actions: [
                Center(
                  child: MaterialButton(
                      color: Colors.blue.shade400,
                      elevation: 0,
                      child: const Text(
                        'Ok',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      }),
                ),
              ],
            );
          });
        });
  }

  // ======== DIALOG POP UP CONTEXT FOR SENDING E-MAIL ===============
  TextEditingController textfieldControllerEmailMsg = TextEditingController();
  Future sendEmailDialogPopUp(BuildContext context, String titleMsg) {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              scrollable: true,
              elevation: 0,
              title: Center(
                child: Text(
                  titleMsg,
                  style: GoogleFonts.sora()
                      .copyWith(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              content: TextFormField(
                maxLines: null,
                controller: textfieldControllerEmailMsg,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  labelText: 'E-Mail Customer',
                  hintText: 'Type the body of email',
                  hintStyle: GoogleFonts.sora().copyWith(),
                ),
                onSaved: (custName) {
                  // custShippingName = custName.toString();
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Kindly compose the body of the e-mail before sending!';
                  }
                  return null;
                },
              ),
              actions: [
                MaterialButton(
                    color: Colors.orangeAccent.shade700,
                    elevation: 10.0,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          'Send Email',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Icon(
                          Icons.send_outlined,
                          color: Colors.white,
                        )
                      ],
                    ),
                    onPressed: () {
                      // I WILL CALL A FUNCTION TO SEND AN EMAIL
                      // IF IT'S SUCCESSFUL, WILL POP ELSE
                      // THE OPTION TO EITHER CANCEL OR RESEND
                      Navigator.of(context).pop();
                    }),
              ],
            );
          });
        });
  }

  // == USED TO DISPLAY A WARNING CONFIRMATION MESSAGE WITH YES OR NO ==
  Future popWarningConfirmActionYesNo(
      BuildContext context, String titleMsg, contentMsg) {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.black54,
              scrollable: true,
              elevation: 0,
              title: Center(
                child: Text(
                  titleMsg,
                  style: GoogleFonts.sora().copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.yellow.shade800),
                ),
              ),
              content: Text(
                contentMsg,
                style: GoogleFonts.sora()
                    .copyWith(fontSize: 15, color: Colors.white60),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    MaterialButton(
                        color: Colors.grey.shade700,
                        child: const Text(
                          'No',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        ),
                        onPressed: () {
                          Navigator.pop(context, false);
                        }),
                    MaterialButton(
                        color: Colors.blue.shade400,
                        child: const Text(
                          'Yes',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        ),
                        onPressed: () {
                          Navigator.pop(context, true);
                        }),
                  ],
                ),
              ],
            );
          });
        });
  }

  // == USED TO DISPLAY A WARNING OR ERROR MESSAGE WITH OK BUTTON ==
  Future popWarningErrorMsg(BuildContext context, String titleMsg, contentMsg) {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.black54,
              scrollable: true,
              elevation: 0,
              title: Center(
                child: Text(
                  titleMsg,
                  style: GoogleFonts.sora().copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.yellow.shade800),
                ),
              ),
              content: Text(
                contentMsg,
                style: GoogleFonts.sora()
                    .copyWith(fontSize: 15, color: Colors.white60),
              ),
              actions: [
                Center(
                  child: MaterialButton(
                      color: Colors.blue.shade400,
                      child: const Text(
                        'Ok',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                      ),
                      onPressed: () {
                        Navigator.pop(context, true);
                      }),
                ),
              ],
            );
          });
        });
  }

  // USED TO DISPLAY NETWORK ERROR (ISSUE)

  Container noServerResponse() {
    return Container(
      child: Column(
        children: [
          const SizedBox(
            height: 50,
          ),
          Image.asset(
            'images/caution sign.png',
            height: 80,
          ),
          const SizedBox(
            height: 10,
          ),
          const Text('No response from server'),
        ],
      ),
    );
  }
}

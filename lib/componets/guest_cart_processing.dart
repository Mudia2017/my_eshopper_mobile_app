// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CartItem {
  final cartProductID;
  final cartProductName;
  final cartProductPrice;
  final cartProductQuantity;
  final pdtid;
  final cartProductImage;

  CartItem({
    this.cartProductID,
    this.cartProductName,
    this.cartProductPrice,
    this.cartProductQuantity,
    this.pdtid,
    this.cartProductImage,
  });

  CartItem.fromMap(Map map)
      : pdtid = map['pdtid'],
        cartProductID = map['cartProductID'],
        cartProductName = map['cartProductName'],
        cartProductPrice = map['cartProductPrice'],
        cartProductQuantity = map['cartProductQuantity'],
        cartProductImage = map['cartProductImage'];

  Map toMap() {
    return {
      'pdtid': pdtid,
      'cartProductID': cartProductID,
      'cartProductName': cartProductName,
      'cartProductPrice': cartProductPrice,
      'cartProductQuantity': cartProductQuantity,
      'cartProductImage': cartProductImage,
    };
  }
}

class Cart with ChangeNotifier {
  List _item = [];
  Map<String, CartItem> _items = {};

  Map<String, CartItem> get items {
    return {..._items};
  }

  int get itemCount {
    return _items.length;
  }

  void addItem(String ptdId, String name, double price, String image) {
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
              ));
      for (var entry in _items.values) {
        _item.add(entry);
      }
      Fluttertoast.showToast(msg: 'Item added to cart');
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
              ));
      for (var entry in _items.values) {
        _item.add(entry);
      }
      Fluttertoast.showToast(msg: 'Item added to cart');
    }
    notifyListeners();
  }
}

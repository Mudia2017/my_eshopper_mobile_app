import 'package:eshopper_mobile_app/componets/cus_s_change_password.dart';
import 'package:eshopper_mobile_app/componets/cus_s_contact_us.dart';
import 'package:eshopper_mobile_app/componets/sub_home_page.dart';
import 'package:eshopper_mobile_app/pages/add_ptd.dart';
import 'package:eshopper_mobile_app/pages/admin/admin_session.dart';
import 'package:eshopper_mobile_app/pages/admin/admin_edit_order.dart';
import 'package:eshopper_mobile_app/pages/admin/refund.dart';
import 'package:eshopper_mobile_app/pages/all_ptd_reviews.dart';
import 'package:eshopper_mobile_app/pages/all_recent_view_item.dart';
import 'package:eshopper_mobile_app/pages/all_seller_items.dart';
import 'package:eshopper_mobile_app/pages/authentic_cust_cart_page.dart';
import 'package:eshopper_mobile_app/pages/check_out.dart';
import 'package:eshopper_mobile_app/pages/customer_service.dart';
import 'package:eshopper_mobile_app/pages/edit_my_order.dart';
import 'package:eshopper_mobile_app/pages/edit_ptd.dart';
import 'package:eshopper_mobile_app/pages/guest_cart.dart';
import 'package:eshopper_mobile_app/pages/guest_check_out.dart';
import 'package:eshopper_mobile_app/pages/guest_order_summary.dart';
import 'package:eshopper_mobile_app/pages/home_page.dart';
import 'package:eshopper_mobile_app/pages/login.dart';
import 'package:eshopper_mobile_app/pages/market_place.dart';
import 'package:eshopper_mobile_app/pages/my_order_session.dart';
import 'package:eshopper_mobile_app/pages/my_pending_review_session.dart';
import 'package:eshopper_mobile_app/pages/my_wish_list.dart';
import 'package:eshopper_mobile_app/pages/order_summary.dart';
import 'package:eshopper_mobile_app/pages/payment.dart';
import 'package:eshopper_mobile_app/pages/product_detail.dart';
import 'package:eshopper_mobile_app/pages/product_overview.dart';
import 'package:eshopper_mobile_app/pages/register.dart';
import 'package:eshopper_mobile_app/pages/search_template.dart';
import 'package:eshopper_mobile_app/pages/settings/admin_setting.dart';
import 'package:eshopper_mobile_app/pages/settings/ptd_brand_setup.dart';
import 'package:eshopper_mobile_app/pages/settings/ptd_category_setup.dart';
import 'package:eshopper_mobile_app/pages/settings/settings.dart';
import 'package:eshopper_mobile_app/pages/settings/ship_address.dart';
import 'package:eshopper_mobile_app/pages/settings/ship_address_overview.dart';
import 'package:eshopper_mobile_app/pages/trader_store.dart';
import 'package:eshopper_mobile_app/pages/write_review.dart';
import 'package:flutter/material.dart';

class RouteManager {
  static const String homePage = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String marketPlace = '/marketPlace';
  static const String customerService = '/customerService';
  static const String changePassword = '/changePassword';
  static const String contactUs = '/contactUs';
  static const String sendEmailToCusService = '/sendEmailToCusService';
  static const String authenticCartPage = '/authenticCartPage';
  static const String productDetail = '/productDetail';
  static const String allPtdReviws = '/allPtdReviws';
  static const String orderSummary = '/orderSummary';
  static const String checkOut = '/checkOut';
  static const String payment = '/payment';
  static const String adminSession = '/adminSession';
  static const String adminUpdateOrder = '/adminUpdateOrder';
  static const String refund = '/refund';
  static const String myOrderSession = '/myOrderSession';
  static const String editMyOrder = '/editMyOrder';
  static const String myPtdReviewSession = '/myPtdReviewSession';
  static const String writeMyPtdReview = '/writeMyPtdReview';
  static const String myWishList = '/myWishList';
  static const String traderStore = '/traderStore';
  static const String productOverview = '/productOverview';
  static const String addProduct = '/addProduct';
  static const String editProduct = '/editProduct';
  static const String appSettings = '/settings';
  static const String allShipAddress = '/allShipAddress';
  static const String updateShipAddress = '/updateShipAddress';
  static const String adminSetting = '/adminSetting';
  static const String categorySetup = '/categorySetup';
  static const String brandSetup = '/brandSetup';
  static const String searchTemplate = '/searchTemplate';
  static const String allRecentVivedItm = '/allRecentVivedItm';
  static const String allSellerItms = '/allSellerItms';

  // FOR GUEST USERS
  static const String guestCart = '/guestCart';
  static const String guestSummary = '/guestSummary';
  static const String checkOutGuest = '/checkOutGuest';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    var valuePassed = {};
    if (settings.arguments != null) {
      valuePassed = settings.arguments as Map<String, dynamic>;
    }
    switch (settings.name) {
      case homePage:
        return MaterialPageRoute(
          builder: (context) => const MyHomePage(title: 'eShopper'),
        );

      case login:
        return MaterialPageRoute(
          builder: (context) => const Login(),
        );

      case register:
        return MaterialPageRoute(
          builder: (context) => const Register(),
        );

      case marketPlace:
        return MaterialPageRoute(
          builder: (context) => MarketPlace(
            username: valuePassed['username'],
            useremail: valuePassed['useremail'],
            token: valuePassed['usertoken'],
            custId: valuePassed['custId'],
            custName: valuePassed['custName'],
            custEmail: valuePassed['custEmail'],
          ),
        );

      case customerService:
        return MaterialPageRoute(
          builder: (context) => CustomerService(
            userName: valuePassed['username'],
            userId: valuePassed['userId'],
            token: valuePassed['token'],
          ),
        );

      case changePassword:
        return MaterialPageRoute(
          builder: (context) => ChangePassword(
            userName: valuePassed['username'],
            userId: valuePassed['userId'],
            token: valuePassed['token'],
          ),
        );

      case contactUs:
        return MaterialPageRoute(
          builder: (context) => const ContactUs(),
        );

      case sendEmailToCusService:
        return MaterialPageRoute(
          builder: (context) => const SendEmailToCusService(),
        );

      case authenticCartPage:
        return MaterialPageRoute(
          builder: (context) => AuthenticCartPage(
            name: valuePassed['name'],
            email: valuePassed['email'],
            userToken: valuePassed['token'],
            custId: valuePassed['custId'],
          ),
        );

      case productDetail:
        return MaterialPageRoute(
          builder: (context) => ProductDetail(
            ptdId: valuePassed['ptdId'],
            category: valuePassed['category'],
          ),
        );

      case allPtdReviws:
        return MaterialPageRoute(
          builder: (context) => AllProductReviews(
            ptdCommentData: valuePassed['ptdCommentData'],
            avgRating: valuePassed['avgRating'],
            totalReview: valuePassed['totalReview'],
            totalOneRate: valuePassed['totalOneRate'],
            totalTwoRate: valuePassed['totalTwoRate'],
            totalThreeRate: valuePassed['totalThreeRate'],
            totalFourRate: valuePassed['totalFourRate'],
            totalFiveRate: valuePassed['totalFiveRate'],
          ),
        );

      case orderSummary:
        return MaterialPageRoute(
          builder: (context) => CustomerOrderSummary(
            userName: valuePassed['userName'],
            userEmail: valuePassed['userEmail'],
            token: valuePassed['token'],
            custId: valuePassed['custId'],
          ),
        );

      case checkOut:
        return MaterialPageRoute(
          builder: (context) => CustomerCheckOut(
            userName: valuePassed['userName'],
            userEmail: valuePassed['userEmail'],
            token: valuePassed['token'],
            custId: valuePassed['custId'],
          ),
        );

      case payment:
        return MaterialPageRoute(
          builder: (context) => Payment(
            userName: valuePassed['userName'],
            token: valuePassed['token'],
          ),
        );

      case guestCart:
        return MaterialPageRoute(
          builder: (context) => const GuestCart(),
        );

      case guestSummary:
        return MaterialPageRoute(
          builder: (context) => GuestOrderSummary(),
        );

      case checkOutGuest:
        return MaterialPageRoute(
          builder: (context) => CheckOutGuest(),
        );

      case adminSession:
        return MaterialPageRoute(
          builder: (context) => AdminSession(token: valuePassed['token']),
        );

      case adminUpdateOrder:
        return MaterialPageRoute(
          builder: (context) => AdminUpdateOrder(
            orderNo: valuePassed['orderNo'],
            token: valuePassed['token'],
          ),
        );

      case refund:
        return MaterialPageRoute(
          builder: (context) => Refund(
            orderNo: valuePassed['orderNo'],
            token: valuePassed['token'],
          ),
        );

      case myOrderSession:
        return MaterialPageRoute(
          builder: (context) => MyOrderSession(token: valuePassed['token']),
        );

      case editMyOrder:
        return MaterialPageRoute(
          builder: (context) => EditMyOrder(
            orderNo: valuePassed['orderNo'],
            token: valuePassed['token'],
          ),
        );

      case myPtdReviewSession:
        return MaterialPageRoute(
          builder: (context) => MyPtdReviewSession(
            token: valuePassed['token'],
            userName: valuePassed['userName'],
          ),
        );

      case writeMyPtdReview:
        return MaterialPageRoute(
          builder: (context) => WriteReview(
            token: valuePassed['token'],
            userName: valuePassed['userName'],
            parentPtdReviewId: valuePassed['parentPtdReviewId'],
            transId: valuePassed['transId'],
          ),
        );

      case myWishList:
        return MaterialPageRoute(
          builder: (context) => MyWishList(
            token: valuePassed['token'],
            customerId: valuePassed['customer_id'],
            custName: valuePassed['customerName'],
            custEmail: valuePassed['custEmail'],
          ),
        );

      case traderStore:
        return MaterialPageRoute(
          builder: (context) => TraderStore(
            token: valuePassed['token'],
            userId: valuePassed['userId'],
          ),
        );

      case productOverview:
        return MaterialPageRoute(
          builder: (context) => ProductOverView(
            token: valuePassed['token'],
            userId: valuePassed['userId'],
          ),
        );

      case addProduct:
        return MaterialPageRoute(
          builder: (context) => AddProduct(
            token: valuePassed['token'],
            userId: valuePassed['userId'],
          ),
        );

      case editProduct:
        return MaterialPageRoute(
          builder: (context) => EditProduct(
            token: valuePassed['token'],
            ptdId: valuePassed['ptdId'],
            userId: valuePassed['userId'],
          ),
        );

      case appSettings:
        return MaterialPageRoute(
          builder: (context) => Settings(
            token: valuePassed['token'],
            userId: valuePassed['userId'],
          ),
        );

      case allShipAddress:
        return MaterialPageRoute(
          builder: (context) => OverViewShipAddresses(
            token: valuePassed['token'],
          ),
        );

      case updateShipAddress:
        return MaterialPageRoute(
          builder: (context) => ShipAddress(
            token: valuePassed['token'],
            calling: valuePassed['calling'],
            shipAddressId: valuePassed['shipAddressId'],
            shipRecord: valuePassed['shipRecord'],
          ),
        );

      case adminSetting:
        return MaterialPageRoute(
          builder: (context) => AdminSetting(
            token: valuePassed['token'],
          ),
        );

      case categorySetup:
        return MaterialPageRoute(
          builder: (context) => CategorySetup(
            token: valuePassed['token'],
            call: valuePassed['call'],
          ),
        );

      case brandSetup:
        return MaterialPageRoute(
          builder: (context) => BrandSetup(
            token: valuePassed['token'],
            call: valuePassed['call'],
          ),
        );

      case searchTemplate:
        return MaterialPageRoute(
          builder: (context) => SearchTemplate(ptdList: valuePassed['ptdList']),
        );

      case allRecentVivedItm:
        return MaterialPageRoute(
          builder: (context) => AllRecentViewItems(
            custId: valuePassed['custId'],
            token: valuePassed['token'],
            userName: valuePassed['userName'],
            userEmail: valuePassed['userEmail'],
            cartCounter: valuePassed['cartCounter'],
          ),
        );

      case allSellerItms:
        return MaterialPageRoute(
          builder: (context) => AllSellerItems(
            custId: valuePassed['custId'],
            token: valuePassed['token'],
            userName: valuePassed['userName'],
            userEmail: valuePassed['userEmail'],
            storeId: valuePassed['storeId'],
          ),
        );

      default:
        throw const FormatException('Route not found! Check routes again.');
    }
  }
}

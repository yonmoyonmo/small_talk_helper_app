import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
//import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_ios/in_app_purchase_ios.dart';
import 'package:in_app_purchase_ios/store_kit_wrappers.dart';
import 'package:small_talk_helper_app/utils/consumable_store.dart';

const bool _kAutoConsume = true;

const String _kConsumableId = 'sth_donate_001';

const List<String> _kProductIds = <String>[_kConsumableId];

class Donate extends StatefulWidget {
  const Donate({Key? key}) : super(key: key);

  @override
  _DonateState createState() => _DonateState();
}

class _DonateState extends State<Donate> {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  List<String> _notFoundIds = [];
  List<ProductDetails> _products = [];
  List<PurchaseDetails> _purchases = [];
  //컨슈머블 형태로 한 푼 쥐어주는 것이므로 딱히 컨슘할 일이 없음
  List<String> _consumables = [];
  bool _isAvailable = false;
  bool _purchasePending = false;
  bool _loading = true;
  String? _queryProductError;

  @override
  void initState() {
    final Stream<List<PurchaseDetails>> purchaseUpdated =
        _inAppPurchase.purchaseStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (error) {
      // handle error here.
    });
    initStoreInfo();
    super.initState();
  }

  Future<void> initStoreInfo() async {
    //store 연결 확인
    final bool isAvailable = await _inAppPurchase.isAvailable();
    if (!isAvailable) {
      setState(() {
        _isAvailable = isAvailable;
        _products = [];
        _purchases = [];
        _notFoundIds = [];
        _consumables = [];
        _purchasePending = false;
        _loading = false;
      });
      return;
    }

    if (Platform.isIOS) {
      var iosPlatformAddition = _inAppPurchase
          .getPlatformAddition<InAppPurchaseIosPlatformAddition>();
      await iosPlatformAddition.setDelegate(ExamplePaymentQueueDelegate());
    }

    ProductDetailsResponse productDetailResponse =
        await _inAppPurchase.queryProductDetails(_kProductIds.toSet());
    if (productDetailResponse.error != null) {
      setState(() {
        _queryProductError = productDetailResponse.error!.message;
        _isAvailable = isAvailable;
        _products = productDetailResponse.productDetails;
        _purchases = [];
        _notFoundIds = productDetailResponse.notFoundIDs;
        _consumables = [];
        _purchasePending = false;
        _loading = false;
      });
      return;
    }

    if (productDetailResponse.productDetails.isEmpty) {
      setState(() {
        _queryProductError = null;
        _isAvailable = isAvailable;
        _products = productDetailResponse.productDetails;
        _purchases = [];
        _notFoundIds = productDetailResponse.notFoundIDs;
        _consumables = [];
        _purchasePending = false;
        _loading = false;
      });
      return;
    }

    List<String> consumables = await ConsumableStore.load();
    setState(() {
      _isAvailable = isAvailable;
      _products = productDetailResponse.productDetails;
      _notFoundIds = productDetailResponse.notFoundIDs;
      _consumables = consumables;
      _purchasePending = false;
      _loading = false;
    });
  }

  @override
  void dispose() {
    if (Platform.isIOS) {
      var iosPlatformAddition = _inAppPurchase
          .getPlatformAddition<InAppPurchaseIosPlatformAddition>();
      iosPlatformAddition.setDelegate(null);
    }
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> stack = [];
    if (_queryProductError == null) {
      stack.add(
        ListView(
          children: [
            _buildConnectionCheckTile(),
            _buildProductList(),
          ],
        ),
      );
    } else {
      stack.add(Center(
        child: Text(_queryProductError!),
      ));
    }
    if (_purchasePending) {
      stack.add(
        Stack(
          children: [
            Opacity(
              opacity: 0.3,
              child: const ModalBarrier(dismissible: false, color: Colors.grey),
            ),
            Center(
              child: CircularProgressIndicator(),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('개발자의 구걸 깡통'),
      ),
      body: Stack(
        children: stack,
      ),
    );
  }

  Card _buildConnectionCheckTile() {
    if (_loading) {
      return Card(child: ListTile(title: const Text('연결 중...')));
    }
    final Widget storeHeader = ListTile(
      leading: Icon(_isAvailable ? Icons.check : Icons.block,
          color: _isAvailable ? Colors.green : ThemeData.light().errorColor),
      title: Text('개발자의 구걸 깡통이 ' +
          (_isAvailable ? '열렸습니다!' : '사라졌습니다... 누가 발로 찼어?') +
          '!'),
    );
    final List<Widget> children = <Widget>[storeHeader];

    if (!_isAvailable) {
      children.addAll([
        Divider(),
        ListTile(
          title: Text('Not connected',
              style: TextStyle(color: ThemeData.light().errorColor)),
          subtitle: const Text('플레이 스토어 연결에 문제가 생겼습니다...'),
        ),
      ]);
    }
    return Card(child: Column(children: children));
  }

  Card _buildProductList() {
    if (_loading) {
      return Card(
          child: (ListTile(
              leading: CircularProgressIndicator(), title: Text('불러오는 중...'))));
    }
    if (!_isAvailable) {
      return Card();
    }

    List<ListTile> productList = <ListTile>[];

    if (_notFoundIds.isNotEmpty) {
      productList.add(ListTile(
          title: Text('[${_notFoundIds.join(", ")}] not found',
              style: TextStyle(color: ThemeData.light().errorColor)),
          subtitle: Text('플레이 스토어 연결에 문제가 생겼습니다...')));
    }

    productList.addAll(_products.map(
      (ProductDetails productDetails) {
        return ListTile(
          title: Text(
            "백수 개발자에게 삼각김밥 하나 사주기",
            style: TextStyle(height: 2),
          ),
          subtitle: Text(
            "배고픈 개발자에게 삼각김밥이라도 하나 사 줍니다.",
            style: TextStyle(height: 2),
          ),
          trailing: TextButton(
            child: Text(productDetails.price),
            style: TextButton.styleFrom(
              backgroundColor: Colors.green[800],
              primary: Colors.white,
            ),
            onPressed: () {
              late PurchaseParam purchaseParam;
              if (Platform.isAndroid) {
                purchaseParam = GooglePlayPurchaseParam(
                  productDetails: productDetails,
                  applicationUserName: null,
                );
              } else {
                purchaseParam = PurchaseParam(
                  productDetails: productDetails,
                  applicationUserName: null,
                );
              }
              if (productDetails.id == _kConsumableId) {
                _inAppPurchase.buyConsumable(
                    purchaseParam: purchaseParam,
                    autoConsume: _kAutoConsume || Platform.isIOS);
              } else {
                _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
              }
            },
          ),
        );
      },
    ));

    return Card(child: Column(children: productList));
  }

  void showAlertDialog(BuildContext context) async {
    String result = await showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('감사합니다 선생님!'),
          content: Text("열심히 살겠습니다!"),
          actions: <Widget>[
            TextButton(
              child: Text('열심히 살거라!'),
              onPressed: () {
                Navigator.pop(context, "OK");
              },
            )
          ],
        );
      },
    );
  }

  void showPendingUI() {
    setState(() {
      _purchasePending = true;
    });
  }

  void deliverProduct(PurchaseDetails purchaseDetails) async {
    // IMPORTANT!! Always verify purchase details before delivering the product.
    if (purchaseDetails.productID == _kConsumableId) {
      await ConsumableStore.save(purchaseDetails.purchaseID!);

      List<String> consumables = await ConsumableStore.load();
      showAlertDialog(context);
      setState(() {
        _purchasePending = false;
        _consumables = consumables;
      });
    } else {
      setState(() {
        _purchases.add(purchaseDetails);
        _purchasePending = false;
      });
    }
  }

  void handleError(IAPError error) {
    setState(() {
      _purchasePending = false;
    });
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) {
    // IMPORTANT!! Always verify a purchase before delivering the product.
    // For the purpose of an example, we directly return true.
    // 그냥 적선하는 것이므로 사기칠 것이 없음 -> 검증 필요 없음
    return Future<bool>.value(true);
  }

  void _handleInvalidPurchase(PurchaseDetails purchaseDetails) {
    // handle invalid purchase here if  _verifyPurchase` failed.
    // 무조건 통과이므로 쓰일 일 없음
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        showPendingUI();
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          handleError(purchaseDetails.error!);
        } else if (purchaseDetails.status == PurchaseStatus.purchased) {
          bool valid = await _verifyPurchase(purchaseDetails);
          if (valid) {
            deliverProduct(purchaseDetails);
          } else {
            _handleInvalidPurchase(purchaseDetails);
            print("s-s-s-s-s-s-s-s-s-s-어째서??-s-s-s-s-s-s-ss--s-s-s-s-ss-");
            return;
          }
        }
        if (Platform.isAndroid) {
          if (!_kAutoConsume && purchaseDetails.productID == _kConsumableId) {
            final InAppPurchaseAndroidPlatformAddition androidAddition =
                _inAppPurchase.getPlatformAddition<
                    InAppPurchaseAndroidPlatformAddition>();
            await androidAddition.consumePurchase(purchaseDetails);
          }
        }
        if (purchaseDetails.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(purchaseDetails);
        }
      }
    });
  }
}

/// Example implementation of the
/// [`SKPaymentQueueDelegate`](https://developer.apple.com/documentation/storekit/skpaymentqueuedelegate?language=objc).
///
/// The payment queue delegate can be implementated to provide information
/// needed to complete transactions.
/// IOS에 필요한 것
class ExamplePaymentQueueDelegate implements SKPaymentQueueDelegateWrapper {
  @override
  bool shouldContinueTransaction(
      SKPaymentTransactionWrapper transaction, SKStorefrontWrapper storefront) {
    return true;
  }

  @override
  bool shouldShowPriceConsent() {
    return false;
  }
}

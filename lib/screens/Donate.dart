import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
//import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_ios/in_app_purchase_ios.dart';
import 'package:in_app_purchase_ios/store_kit_wrappers.dart';
import 'package:small_talk_helper_app/utils/consumable_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;

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
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  //donator restore
  // ignore: non_constant_identifier_names
  String? donator_name;
  String? password;
  bool registered = false;
  String? donatorRegisterMessage;
  String? donatorName;
  String? restoreMessage;

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
    final SharedPreferences prefs = await _prefs;
    if (prefs.getInt("isDonator") != null) {
      setState(() {
        donatorName = prefs.getString("donatorName");
        registered = true;
      });
    }
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
    BoxDecoration boxDeco = BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20)),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          spreadRadius: 10,
          blurRadius: 10,
          offset: Offset(0, 3), // changes position of shadow
        ),
      ],
    );

    List<Widget> stack = [];
    if (_queryProductError == null) {
      stack.add(
        ListView(
          children: [
            Container(
              decoration: boxDeco,
              margin: EdgeInsets.all(10),
              child: Image(
                height: MediaQuery.of(context).size.height / 3,
                image: AssetImage('images/baggerWonmo.png'),
              ),
            ),
            _buildConnectionCheckTile(),
            Container(
                margin: EdgeInsets.all(10),
                child: Text(donatorRegisterMessage ?? ""),
                alignment: Alignment.center),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    margin: EdgeInsets.only(right: 10),
                    child: Text(donatorName ?? ""),
                    alignment: Alignment.center),
                Container(
                    child: Text(donatorName != null ? "님 감사해요!" : ""),
                    alignment: Alignment.center),
              ],
            ),
            _buildProductList(),
            Card(
                margin: EdgeInsets.all(10),
                child: ListTile(
                  title: Text(
                    "광고제거 불러오기",
                    style: TextStyle(height: 2),
                  ),
                  subtitle: Text(
                    "효과 : 다른 기기에서 제거했던 광고제거 효과를 이 기기에도 적용합니다",
                    style: TextStyle(height: 2),
                  ),
                  trailing: TextButton(
                      child: Text("Restore"),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.black,
                        primary: Colors.white,
                      ),
                      onPressed: () {
                        if (registered == false) {
                          showRestoreIAPTextFieldDialog(context);
                        } else {
                          print("이미함");
                          return;
                        }
                      }),
                )),
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
      return Card(
          margin: EdgeInsets.all(10),
          child: ListTile(title: const Text('연결 중...')));
    }
    final Widget storeHeader = ListTile(
      leading: Icon(_isAvailable ? Icons.check : Icons.block,
          color: _isAvailable ? Colors.black : ThemeData.light().errorColor),
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
          subtitle: const Text('스토어 연결에 문제가 생겼습니다...'),
        ),
      ]);
    }
    return Card(margin: EdgeInsets.all(10), child: Column(children: children));
  }

  Card _buildProductList() {
    if (_loading) {
      return Card(
          margin: EdgeInsets.all(10),
          child: (ListTile(
              leading: CircularProgressIndicator(), title: Text('불러오는 중...'))));
    }
    if (!_isAvailable) {
      return Card(
        margin: EdgeInsets.all(10),
      );
    }

    List<ListTile> productList = <ListTile>[];

    if (_notFoundIds.isNotEmpty) {
      productList.add(ListTile(
          title: Text('[${_notFoundIds.join(", ")}] not found',
              style: TextStyle(color: ThemeData.light().errorColor)),
          subtitle: Text('스토어 연결에 문제가 생겼습니다...')));
    }

    productList.addAll(_products.map(
      (ProductDetails productDetails) {
        return ListTile(
          title: Text(
            "한 푼 주기",
            style: TextStyle(height: 2),
          ),
          subtitle: Text(
            "효과 : 자비로운 마음씨로 인해 광고가 제거됩니다.",
            style: TextStyle(height: 2),
          ),
          trailing: TextButton(
            child: Text(productDetails.price),
            style: TextButton.styleFrom(
              backgroundColor: Colors.black,
              primary: Colors.white,
            ),
            onPressed: () {
              if (registered == false) {
                showDonatorRegisterTextFieldDialog(context);
                return;
              } else {
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
                return;
              }
            },
          ),
        );
      },
    ));

    return Card(
      child: Column(children: productList),
      margin: EdgeInsets.all(10),
    );
  }

  //-----------for restoring purchase----------------
  Future<Map<String, dynamic>> registerDonator() async {
    if (donator_name != null && password != null) {
      try {
        final response = await http.post(
          Uri.parse(
              "https://small-talk-helper.wonmonae.com/api/donator/register"),
          body:
              jsonEncode({"donator_name": donator_name, "password": password}),
          headers: {"Content-Type": "application/json"},
        );
        if (response.statusCode == 200) {
          return json.decode(response.body);
        } else {
          print("500?");
          Map<String, dynamic> result = jsonDecode(response.body);
          print(result.toString());
          print(result["message"]);
          return result;
        }
      } catch (e) {
        print(e);
        Map<String, dynamic> result = new Map<String, String>();
        result = {"success": false};
        return result;
      }
    } else {
      Map<String, dynamic> result = new Map<String, String>();
      result = {"success": false, "message": "no name, password"};
      return result;
    }
  }

  Future<Map<String, dynamic>> checkDonator() async {
    if (donator_name != null && password != null) {
      try {
        final response = await http.post(
          Uri.parse("https://small-talk-helper.wonmonae.com/api/donator/check"),
          body:
              jsonEncode({"donator_name": donator_name, "password": password}),
          headers: {"Content-Type": "application/json"},
        );
        if (response.statusCode == 200) {
          return json.decode(response.body);
        } else {
          print("500? in check");
          Map<String, dynamic> result = jsonDecode(response.body);
          print(result.toString());
          print(result["message"]);
          return result;
        }
      } catch (e) {
        print(e);
        Map<String, dynamic> result = new Map<String, String>();
        result = {"success": false};
        return result;
      }
    } else {
      Map<String, dynamic> result = new Map<String, String>();
      result = {"success": false, "message": "no name, password"};
      return result;
    }
  }

  void showDonatorRegisterTextFieldDialog(BuildContext context) async {
    String result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(16.0),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  onChanged: (text) {
                    setState(() {
                      donator_name = text;
                    });
                  },
                  decoration: InputDecoration(
                      labelText: '등록할 닉네임', hintText: '등록할 예명을 입력해 주세요'),
                ),
                TextField(
                  onChanged: (text) {
                    setState(() {
                      password = text;
                    });
                  },
                  obscureText: true,
                  decoration: InputDecoration(labelText: "비밀번호"),
                ),
                TextButton(
                  child: Text('확인'),
                  onPressed: () async {
                    if (donator_name != null && password != null) {
                      var result = await registerDonator();
                      print("button");
                      print(result.toString());
                      if (result["success"]) {
                        setState(() {
                          donatorRegisterMessage = "기부자 등록 성공!";
                          donatorName = donator_name;
                          registered = true;
                        });
                        final SharedPreferences prefs = await _prefs;

                        await prefs.setInt("isRegister", 1);
                        await prefs.setString(
                            "donatorName", donator_name ?? "");

                        Navigator.pop(context, "OK");
                      } else {
                        if (result["dup"] == true) {
                          setState(() {
                            donatorRegisterMessage = "중복된 닉네임입니다!";
                          });
                          Navigator.pop(context, "OK");
                        } else {
                          setState(() {
                            donatorRegisterMessage = "죄송합니다. 등록에 문제가 생겼습니다!";
                          });
                          Navigator.pop(context, "OK");
                        }
                      }
                    } else {
                      Navigator.pop(context, "OK");
                    }
                    return;
                  },
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void showRestoreIAPTextFieldDialog(BuildContext context) async {
    String result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(16.0),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  onChanged: (text) {
                    setState(() {
                      donator_name = text;
                    });
                  },
                  decoration: InputDecoration(
                      labelText: '등록했던 닉네임', hintText: '등록했던 예명을 입력해 주세요'),
                ),
                TextField(
                  onChanged: (text) {
                    setState(() {
                      password = text;
                    });
                  },
                  obscureText: true,
                  decoration: InputDecoration(labelText: "비밀번호"),
                ),
                TextButton(
                  child: Text('확인'),
                  onPressed: () async {
                    if (donator_name != null && password != null) {
                      var result = await checkDonator();
                      print("button 쳌");
                      print(result.toString());
                      if (result["success"]) {
                        setState(() {
                          donatorRegisterMessage = "기부했었던 분이셨군요?";
                          donatorName = donator_name;
                          registered = true;
                        });
                        final SharedPreferences prefs = await _prefs;

                        await prefs.setInt("isRegister", 1);
                        await prefs.setString(
                            "donatorName", donator_name ?? "");
                        await prefs.setInt("isDonator", 1);

                        Navigator.pop(context, "OK");
                      } else {
                        setState(() {
                          donatorRegisterMessage = "입력하신 닉네임으로 등록된 분이 없어요!";
                        });
                        Navigator.pop(context, "OK");
                      }
                    } else {
                      Navigator.pop(context, "OK");
                    }
                    return;
                  },
                )
              ],
            ),
          ),
        );
      },
    );
  }

  //------------------------------------------
  void showAlertDialog(BuildContext context) async {
    String result = await showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('감사합니다!'),
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

      final SharedPreferences prefs = await _prefs;
      //왜인지 리스트를 여러개 쓰니 하나씩 이상해짐
      //불값도 이미 쓰고 있으니 인트로 해본다
      await prefs.setInt("isDonator", 1);

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

import 'dart:developer';

import 'package:js/js_util.dart' as js;
import 'dart:async';
import 'dart:html' as html;
import 'dart:convert';
import 'dart:js';

import 'package:flutter/services.dart';
import 'dart:html' as html;
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:go_sell_sdk_flutter/goselljs.dart';

class GoSellSdkFlutterPlugin {
  static void registerWith(Registrar registrar) {
    final MethodChannel channel = MethodChannel('go_sell_sdk_flutter',
        const StandardMethodCodec(), registrar.messenger);
    final GoSellSdkFlutterPlugin instance = GoSellSdkFlutterPlugin();
    channel.setMethodCallHandler(instance.handleMethodCall);
  }

  Future<dynamic> handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'start_sdk':
        var name = await startSdk(call);
        return name;

      default:
        throw PlatformException(
            code: 'Unimplemented',
            details: "The url_launcher plugin for web doesn't implement "
                "the method '${call.method}'");
    }
  }

  Future<dynamic> startSdk(MethodCall call) async {
    var creds = call.arguments["appCredentials"];
    var params = call.arguments['sessionParameters'];
    var customer = jsonDecode(params['customer']);
    List<dynamic> paymentitems = jsonDecode(params['paymentitems']);
    paymentitems.forEach((element) {
      element['quantity'] = element['quantity']['value'];
      element['taxes'] = null;
    });
    var taxes = jsonDecode(params['taxes']);
    var shipping = jsonDecode(params['shipping']);
    var paymentReference = jsonDecode(params['paymentReference']);
    var receiptSettings = jsonDecode(params['receiptSettings']);
    var authorizeAction = jsonDecode(params['authorizeAction']);
    var completer = new Completer();
    Map map = <dynamic, dynamic>{
      'containerID': creds['containerID'] ?? 'root',
      'gateway': <dynamic, dynamic>{
        'publicKey': creds["publicKey"],
        'merchantId': params["merchantID"],
        'language': creds["language"],
        // 'contactInfo': true,
        // 'supportedCurrencies': "all",
        // 'supportedPaymentMethods': "all",
        'saveCardOption': creds['isUserAllowedToSaveCard'],
        // 'customerCards': true,
        'callback': allowInterop((response) {
          int x = 0;
        }),
        'onClose': allowInterop(() {
          int x = 0;
        }),
        'onLoad': allowInterop(() async {
          await Future.delayed(Duration(seconds: 2), () {
            goSell.openPaymentPage();
          });
        }),
        // 'backgroundImg': {'url': 'imgURL', 'opacity': '0.5'},
        // 'labels': {
        //   'cardNumber': "Card Number",
        //   'expirationDate': "MM/YY",
        //   'cvv': "CVV",
        //   'cardHolder': "Name on Card",
        //   'actionButton': "Pay"
        // },
        // 'style': {
        //   'base': {
        //     'color': '#535353',
        //     'lineHeight': '18px',
        //     'fontFamily': 'sans-serif',
        //     'fontSmoothing': 'antialiased',
        //     'fontSize': '16px',
        //     '::placeholder': {
        //       'color': 'rgba(0, 0, 0, 0.26)',
        //       'fontSize': '15px'
        //     }
        //   },
        //   'invalid': {'color': 'red', 'iconColor': '#fa755a '}
        // }
      },
      'customer': <dynamic, dynamic>{
        'id': customer['customerId'],
        'first_name': customer['first_name'],
        'middle_name': customer['middle_name'],
        'last_name': customer['last_name'],
        'email': customer['email'],
        'phone': <dynamic, dynamic>{
          'country_code': customer['isdNumber'],
          'number': customer['number']
        }
      },
      'order': <dynamic, dynamic>{
        'amount': params['amount'],
        'currency': params['transactionCurrency'],
        'items': paymentitems,
        // 'shipping': shipping,
        // 'taxes': null
      },
      'transaction': <dynamic, dynamic>{
        'mode': 'charge',
        'charge': <dynamic, dynamic>{
          'saveCard': params['isUserAllowedToSaveCard'],
          'threeDSecure': params['isRequires3DSecure'],
          'description': params['paymentDescription'],
          'statement_descriptor': params['paymentStatementDescriptor'],
          'reference': <dynamic, dynamic>{
            'transaction': paymentReference['transaction'],
            'order': paymentReference['order']
          },
          'metadata': jsonDecode(params['paymenMetaData']),
          'receipt': receiptSettings,
          'redirect': params['redirectUrl'],
          'post': params['postURL'],
        }
      }
    };
    goSell.config(mapToLiteralJsObject(map));
    var response = await completer.future;
    return response;
  }

  Object mapToLiteralJsObject(Map<dynamic, dynamic> a) {
    var object = js.newObject();
    a.forEach((k, v) {
      var key = k;
      Object value;
      if (v is Map<dynamic, dynamic>) {
        value = mapToLiteralJsObject(v);
      } else if (v is List<dynamic>) {
        var arr = []; // js.callConstructor("Array",[]);
        v.forEach((element) {
          js.callMethod(arr, 'push',
              [mapToLiteralJsObject(element as Map<dynamic, dynamic>)]);
        });
        value = arr;
      } else {
        value = v;
      }
      js.setProperty(object, key, value);
    });
    return object;
  }
}

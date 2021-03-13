@JS()
library goSell;

import 'dart:js';

import 'package:js/js.dart';

@JS('goSell')
class goSell {
  external static void config(Object object);

  external static openLightBox();
  external static openPaymentPage();
}

//
// @JS()
// @anonymous
// class PaymentOptions {
//   String containerID;
//   GatewayOptions gateway;
//   Customer customer;
//   Order order;
//   Transaction transaction;
// }
//
// @JS()
// @anonymous
// class Customer {
//   String id;
//   String first_name;
//   String middle_name;
//   String last_name;
//   String email;
//   PhoneNumber phone;
// }
// @JS()
// @anonymous
// class PhoneNumber {
// }
//
// @JS()
// @anonymous
// class Transaction {
//   String mode;
//   Charge charge;
// }
// @JS()
// @anonymous
// class Charge {
// }
//
// @JS()
// @anonymous
// class Order {}
//
// @JS()
// @anonymous
// class GatewayOptions {}
@JS()
class JSON {
  @JS()
  external static Object parse(String str);
}
@JS()
external gosellloaded();
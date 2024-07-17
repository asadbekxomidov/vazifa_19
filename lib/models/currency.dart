import 'dart:convert';
import 'package:intl/intl.dart';

class Currency {
  final String? title;
  final String? code;
  final String? cbPrice;
  final String? nbuBuyPrice;
  final String? nbuCellPrice;
  final DateTime? date;

  Currency({
    this.title,
    this.code,
    this.cbPrice,
    this.nbuBuyPrice,
    this.nbuCellPrice,
    this.date,
  });

  factory Currency.fromRawJson(String str) =>
      Currency.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  static final _dateFormat = DateFormat("dd.MM.yyyy HH:mm:ss");

  factory Currency.fromJson(Map<String, dynamic> json) => Currency(
        title: json["title"] as String?,
        code: json["code"] as String?,
        cbPrice: json["cb_price"] as String?,
        nbuBuyPrice: json["nbu_buy_price"] as String?,
        nbuCellPrice: json["nbu_cell_price"] as String?,
        date: json["date"] != null ? _dateFormat.parse(json["date"]) : null,
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "code": code,
        "cb_price": cbPrice,
        "nbu_buy_price": nbuBuyPrice,
        "nbu_cell_price": nbuCellPrice,
        "date": date != null ? _dateFormat.format(date!) : null,
      };
}

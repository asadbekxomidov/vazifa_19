import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:vazifa_19/models/currency.dart';
import 'package:vazifa_19/services/currency_sevices.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Currency State
abstract class CurrencyState extends Equatable {
  const CurrencyState();

  @override
  List<Object?> get props => [];
}

class CurrencyInitial extends CurrencyState {}

class CurrencyLoaded extends CurrencyState {
  final List<Currency> currencies;
  final Currency selectedCurrency;
  final String convertedAmount;

  const CurrencyLoaded(
      {required this.currencies, required this.selectedCurrency, required this.convertedAmount});

  @override
  List<Object?> get props => [currencies, selectedCurrency, convertedAmount];
}

// Currency Cubit
class CurrencyCubit extends Cubit<CurrencyState> {
  final CurrencyServices currencyServices;
  List<Currency> _currencies = [];
  Currency? _selectedCurrency;
  String _convertedAmount = '0.0';

  CurrencyCubit(this.currencyServices) : super(CurrencyInitial());

  Future<void> fetchCurrencies() async {
    _currencies = await currencyServices.getAllCurrencies();
    if (_currencies.isNotEmpty) {
      _selectedCurrency = _currencies.first;
      _saveSelectedCurrency(_selectedCurrency!.code!);
      emit(CurrencyLoaded(
          currencies: _currencies,
          selectedCurrency: _selectedCurrency!,
          convertedAmount: _convertedAmount));
    }
  }

  void convertCurrency(String amount) {
    if (_selectedCurrency != null) {
      final double howMuch = double.tryParse(amount) ?? 0.0;
      final double rate = double.tryParse(_selectedCurrency!.cbPrice!) ?? 0.0;
      _convertedAmount = (rate * howMuch).toStringAsFixed(2);
      emit(CurrencyLoaded(
          currencies: _currencies,
          selectedCurrency: _selectedCurrency!,
          convertedAmount: _convertedAmount));
    }
  }

  void setCurrencyRate(String code) {
    _selectedCurrency = _currencies.firstWhere((currency) => currency.code == code);
    _saveSelectedCurrency(code);
    emit(CurrencyLoaded(
        currencies: _currencies,
        selectedCurrency: _selectedCurrency!,
        convertedAmount: _convertedAmount));
  }

  Future<void> _saveSelectedCurrency(String code) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedCurrency', code);
  }

  Future<void> loadSelectedCurrency() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? code = prefs.getString('selectedCurrency');
    if (code != null) {
      setCurrencyRate(code);
    }
  }
}

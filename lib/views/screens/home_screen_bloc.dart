import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vazifa_19/models/currency.dart';
import 'package:vazifa_19/services/currency_sevices.dart';
import 'package:vazifa_19/cubit/currency_cubit.dart';

class HomeScreenBloc extends StatelessWidget {
  const HomeScreenBloc({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CurrencyCubit(CurrencyServices())
        ..fetchCurrencies()
        ..loadSelectedCurrency(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F5F6),
        body: Center(
          child: BlocBuilder<CurrencyCubit, CurrencyState>(
            builder: (context, state) {
              if (state is CurrencyLoaded) {
                return CurrencyConverter(
                  currencies: state.currencies,
                  selectedCurrency: state.selectedCurrency,
                  convertedAmount: state.convertedAmount,
                );
              }
              return const CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }
}

class CurrencyConverter extends StatefulWidget {
  final List<Currency> currencies;
  final Currency selectedCurrency;
  final String convertedAmount;

  const CurrencyConverter({
    Key? key,
    required this.currencies,
    required this.selectedCurrency,
    required this.convertedAmount,
  }) : super(key: key);

  @override
  _CurrencyConverterState createState() => _CurrencyConverterState();
}

class _CurrencyConverterState extends State<CurrencyConverter> {
  final TextEditingController _fromPriceController = TextEditingController();
  final TextEditingController _toPriceController = TextEditingController();
  GlobalKey<FormState> formKey1 = GlobalKey<FormState>();
  String? dropDownValue1;

  @override
  void initState() {
    super.initState();
    dropDownValue1 = widget.selectedCurrency.code;
    _fromPriceController.addListener(() {
      BlocProvider.of<CurrencyCubit>(context)
          .convertCurrency(_fromPriceController.text);
    });
  }

  @override
  void didUpdateWidget(covariant CurrencyConverter oldWidget) {
    super.didUpdateWidget(oldWidget);
    _toPriceController.text = widget.convertedAmount;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 200),
        const Column(
          children: [
            Text(
              'Currency Converter',
              style: TextStyle(
                  color: Color(0xFF1F2261),
                  fontWeight: FontWeight.w700,
                  fontSize: 22),
            ),
            SizedBox(height: 10),
            Text(
              'Check live rates, set rate alerts, receive notifications and more.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF808080)),
            ),
          ],
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF),
              borderRadius: BorderRadius.circular(20)),
          child: Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Amount',
                    style: TextStyle(
                        color: Color(0xFF989898),
                        fontSize: 15,
                        fontWeight: FontWeight.w400),
                  ),
                  const SizedBox(height: 7),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      DropdownButton<String>(
                        icon: const Icon(Icons.expand_more),
                        value: dropDownValue1,
                        style: const TextStyle(
                            color: Color(0xFF26278D),
                            fontWeight: FontWeight.w600,
                            fontSize: 18),
                        onChanged: (String? value) {
                          setState(() {
                            dropDownValue1 = value;
                            BlocProvider.of<CurrencyCubit>(context)
                                .setCurrencyRate(value!);
                          });
                        },
                        elevation: 16,
                        underline: Container(),
                        items: widget.currencies.map((currency) {
                          return DropdownMenuItem<String>(
                            value: currency.code,
                            child: Row(
                              children: [
                                Container(
                                  clipBehavior: Clip.hardEdge,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Image.asset(
                                    'assets/images/${currency.code}.png',
                                    width: 30,
                                    height: 30,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Text(currency.code!),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                      SizedBox(
                        width: 150.w,
                        height: 50.h,
                        child: Form(
                          key: formKey1,
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            controller: _fromPriceController,
                            decoration: const InputDecoration(
                                hintText: '0.0', border: OutlineInputBorder()),
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Converted Amount',
                    style: TextStyle(
                        color: Color(0xFF989898),
                        fontSize: 15,
                        fontWeight: FontWeight.w400),
                  ),
                  const SizedBox(height: 7),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 360.w,
                        height: 50.h,
                        child: Form(
                          child: TextField(
                            readOnly: true,
                            keyboardType: TextInputType.number,
                            controller: _toPriceController,
                            decoration: const InputDecoration(
                                hintText: '0.0', border: OutlineInputBorder()),
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _fromPriceController.dispose();
    _toPriceController.dispose();
    super.dispose();
  }
}

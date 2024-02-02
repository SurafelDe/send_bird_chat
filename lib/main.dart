import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'main_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ko_KR');
  runApp(MyApp());
}



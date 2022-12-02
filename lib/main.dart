import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'contract_linking.dart';
import 'checkapk_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Inserting Provider as a parent of HelloUI()
    return ChangeNotifierProvider<ContractLinking>(
      create: (_) => ContractLinking(),
      child: MaterialApp(
        title: "Hello World",
        theme: ThemeData(
            brightness: Brightness.light,
            primaryColor: Colors.cyan[400],
            accentColor: Colors.deepOrange[200]),
        home: CheckApkScreen(),
      ),
    );
  }
}

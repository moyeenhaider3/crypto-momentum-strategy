import 'package:crypto/features/momentum_strategy/presentation/pages/top_gainer.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Top Gainers',
      home: TopGainersPage(),
    );
  }
}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../domain/model/coin.dart';

class TopGainersPage extends StatefulWidget {
  @override
  _TopGainersPageState createState() => _TopGainersPageState();
}

class _TopGainersPageState extends State<TopGainersPage> {
  List<Coin> gainers60d = [];
  List<Coin> gainers30d = [];
  List<Coin> gainers7d = [];

  List<Coin> topGainers = [];
  final api_key = "CG-8YiJoWEzDNecZhoStkXdxoCf"; //Use Your Own API Key
  final baseUrl = "https://api.coingecko.com/api/v3/";

  /// Fetches a list of top gaining coins for a specific duration.
  ///
  /// The [duration] parameter specifies the time period for which to fetch
  /// the top gaining coins. Possible values could be '60d', '30d', '7d', etc.
  ///
  /// Returns a [Future] that resolves to a list of [Coin] objects containing
  /// the coin ID, name, and price change percentage.
  ///
  /// Throws an [Exception] if the API request fails.
  Future<List<Coin>> fetchCoinsForDuration(String duration) async {
    // Construct the URL for the API request
    final url =
        '${baseUrl}coins/top_gainers_losers?duration=$duration&x_cg_demo_api_key=$api_key';

    // Print the URL for debugging purposes
    print("url:==>$url");

    // Make the HTTP GET request
    var response = await http.get(Uri.parse(url), headers: {
      'accept': 'application/json',
    });

    // Check if the response is successful
    if (response.statusCode == 200) {
      // Parse the JSON response
      var data = jsonDecode(response.body) as List;

      // Map the data to a list of Coin objects
      return data
          .map((coinData) => Coin(
                coinData['id'],
                coinData['name'],
                coinData['market_data']['price_change_percentage'],
              ))
          .toList();
    } else {
      // Throw an exception if the request failed
      throw Exception('Failed to fetch data for duration: $duration');
    }
  }

  /// Fetches top gaining coins for multiple durations and updates the state.
  ///
  /// This method fetches the top gaining coins for 60 days, 30 days, and 7 days
  /// durations by calling the `fetchCoinsForDuration` method for each respective
  /// duration. After fetching, it updates the state with the common top gainers
  /// across all durations using the `findCommonTopGainers` method.
  ///
  /// If an error occurs during fetching, it prints the error message.

  Future<void> fetchAllDurations() async {
    try {
      gainers60d = await fetchCoinsForDuration('60d');
      gainers30d = await fetchCoinsForDuration('30d');
      gainers7d = await fetchCoinsForDuration('7d');

      setState(() {
        topGainers = findCommonTopGainers(gainers60d, gainers30d, gainers7d);
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  /// Finds the common top gainers among the given lists of coins for 60 day,
  /// 30 day, and 7 day durations.
  ///
  /// This method takes three lists of [Coin] objects, each representing the
  /// top gainers for a specific duration. It first finds the common coin IDs
  /// that are present in all three lists. Then, it filters the original list of
  /// coins for the 60 day duration and takes only those coins that have a common
  /// ID. Finally, it sorts the common coins by their percentage change in
  /// descending order and returns the top 10 coins.
  ///
  List<Coin> findCommonTopGainers(
    List<Coin> gainers60d,
    List<Coin> gainers30d,
    List<Coin> gainers7d,
  ) {
    final ids60d = gainers60d.map((coin) => coin.id).toSet();
    final ids30d = gainers30d.map((coin) => coin.id).toSet();
    final ids7d = gainers7d.map((coin) => coin.id).toSet();

    final commonIds = ids60d.intersection(ids30d).intersection(ids7d);

    final commonCoins =
        gainers60d.where((coin) => commonIds.contains(coin.id)).toList();

    commonCoins
        .sort((a, b) => b.percentageChange.compareTo(a.percentageChange));
    return commonCoins.take(10).toList();
  }

  @override
  void initState() {
    super.initState();
    // testApiKey();
    fetchAllDurations();
  }

  /// Tests the API key by sending a GET request to the `/ping` endpoint
  /// with the API key as a query parameter. If the response is successful,
  /// it prints a success message to the console. Otherwise, it prints an
  /// error message indicating the reason for the failure.
  Future<void> testApiKey() async {
    const url = 'https://api.coingecko.com/api/v3/ping';
    final response = await http.get(
      Uri.parse('$url?x_cg_demo_api_key=$api_key'),
    );

    if (response.statusCode == 200) {
      print('API is working: ${response.body}');
    } else {
      print('API error: ${response.reasonPhrase}');
    }
  }

  /// Builds the widget tree for the top gainers page.
  ///
  /// The widget tree consists of a [Scaffold] with an [AppBar] and a
  /// [SingleChildScrollView] body. The body contains a [Column] widget
  /// with four sections: the top common gainers, the top gainers for 60
  /// days, the top gainers for 30 days, and the top gainers for 7 days.
  /// Each section is separated by a [Padding] widget with a bold header
  /// [Text] widget, and contains a [DataTable] widget with the list of
  /// coins for that section.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Top Gainers')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (topGainers.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Top Common Gainers (60d, 30d, 7d)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              buildDataTable(topGainers),
            ],
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Top Gainers (60 Days)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            buildDataTable(gainers60d),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Top Gainers (30 Days)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            buildDataTable(gainers30d),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Top Gainers (7 Days)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            buildDataTable(gainers7d),
          ],
        ),
      ),
    );
  }
}

/// Builds a DataTable widget from a list of [Coin] objects.
///
/// If the input list is empty, it returns a Center widget with a text
/// indicating that no data is available. Otherwise, it returns a DataTable
/// widget with three columns: 'Coin Name', 'Percentage Change', and 'Coin ID'.
/// The percentage change is formatted as a string with two decimal places.
/// The rows of the table are generated by mapping each coin in the list to a
/// DataRow with the respective cells.
Widget buildDataTable(List<Coin> coins) {
  if (coins.isEmpty) {
    return const Center(
      child: Text('No data available'),
    );
  }
  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: DataTable(
      columns: const [
        DataColumn(label: Text('Coin Name')),
        DataColumn(label: Text('Percentage Change')),
        DataColumn(label: Text('Coin ID')),
      ],
      rows: coins.map((coin) {
        return DataRow(cells: [
          DataCell(Text(coin.name)),
          DataCell(Text('${coin.percentageChange.toStringAsFixed(2)}%')),
          DataCell(Text(coin.id)),
        ]);
      }).toList(),
    ),
  );
}

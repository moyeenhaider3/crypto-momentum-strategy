# Top Crypto Momentum Gainers

## Project Description
This Flutter project identifies the **top-gaining cryptocurrencies** over different time periods (7, 30, and 60 days). By consolidating growth data across multiple durations, it applies science-backed momentum trading principles to highlight consistent top performers.

The strategy takes inspiration from research in momentum trading and asset rebalancing, widely used in traditional financial markets to outperform average market returns.

---

## Key Features
- **Fetch Top Gainers**: Pulls data of the top-performing cryptocurrencies for durations of 7, 30, and 60 days.
- **Find Common Gainers**: Identifies cryptocurrencies appearing as gainers across all three durations.
- **Display Results**: Renders a list of top gainers sorted by their percentage change.
- **Data Visualization**: Presents the results in a clean table format for better interpretation.
- **API Integration**: Fetches real-time data from a crypto market API.

---

## Momentum Trading: Theoretical Background
This application is inspired by momentum trading strategies explored in financial research and leveraged at leading institutions like **Harvard** and **Yale** for traditional asset classes:

1. **The Momentum Effect**: Momentum trading theory suggests that assets with recent strong performance tend to continue performing well over short durations due to factors like investor behavior, market psychology, and volatility.

2. **Shorter Duration Advantage**: Academic studies have shown that while momentum-based strategies work well for traditional assets on a **3-12 month time frame**, in the highly volatile crypto market, the optimal performance comes when shorter durations such as **7-day rebalancing** are used (Source: Economic Letters research).

3. **Cross-Asset Consistency**: By analyzing performance across different periods (7d, 30d, and 60d), we reduce noise and identify consistently strong assets.

For further insights into the concepts, refer to:
- Muscular Portfolio Strategies: [The Papa Bear Strategy](https://muscularportfolios.com/papa-bear/)
- Crypto Momentum Research: [Momentum in Crypto Research](https://www.sciencedirect.com/science/article/abs/pii/S0165176519303647)

---

## Project Structure
```
lib/
├── domain/
│   └── model/
│       └── coin.dart      # Data model for a cryptocurrency
├── pages/
│   └── top_gainers_page.dart   # Main page implementing top gainers logic
├── main.dart               # Entry point of the app
```

---

## Code Walkthrough
### Fetching Top Gainers
```dart
Future<List<Coin>> fetchCoinsForDuration(String duration) async {
  final url = '${baseUrl}coins/top_gainers_losers?duration=$duration&x_cg_demo_api_key=$api_key';
  var response = await http.get(Uri.parse(url), headers: {'accept': 'application/json'});

  if (response.statusCode == 200) {
    var data = jsonDecode(response.body) as List;
    return data.map((coinData) => Coin(
      coinData['id'],
      coinData['name'],
      coinData['market_data']['price_change_percentage'],
    )).toList();
  } else {
    throw Exception('Failed to fetch data');
  }
}
```

### Identifying Common Gainers
```dart
List<Coin> findCommonTopGainers(
    List<Coin> gainers60d,
    List<Coin> gainers30d,
    List<Coin> gainers7d,
) {
  final commonIds = gainers60d.map((c) => c.id)
                              .toSet()
                              .intersection(gainers30d.map((c) => c.id).toSet())
                              .intersection(gainers7d.map((c) => c.id).toSet());

  final commonCoins = gainers60d.where((coin) => commonIds.contains(coin.id)).toList();
  commonCoins.sort((a, b) => b.percentageChange.compareTo(a.percentageChange));
  return commonCoins.take(10).toList();
}
```

### Displaying Results in a Table
```dart
Widget buildDataTable(List<Coin> coins) {
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
```

---

## Installation
1. **Clone the Repository**
   ```bash
   git clone https://github.com/your_username/your_repo.git
   cd your_repo
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the Project**
   ```bash
   flutter run
   ```

---

## Requirements
- Flutter SDK
- Dart
- API Key for accessing crypto market data

---

## Results Demonstration
- Identifies consistent top-performing cryptocurrencies.
- Compares results across 7-day, 30-day, and 60-day intervals.
- Displays clear tables for easy decision-making.

---

## Limitations
- Data accuracy relies on external API providers.
- Real-time market changes may impact results.

---

## Credits
- **Muscular Portfolio** strategies inspired research: [The Papa Bear](https://muscularportfolios.com/papa-bear/)
- Momentum Trading in Cryptos: [Economic Letters Study](https://www.sciencedirect.com/science/article/abs/pii/S0165176519303647)

---

## Disclaimer
This project is for educational purposes and demonstrates concepts around momentum-based asset filtering. The data and analysis should **not** be treated as financial advice. Always conduct independent research before making investment decisions.


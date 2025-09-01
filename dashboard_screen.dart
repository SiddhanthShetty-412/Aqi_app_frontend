import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'historypage.dart'; // ✅ Import added

class DashboardScreen extends StatefulWidget {
  final String username;
  DashboardScreen({required this.username});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TextEditingController _monthController = TextEditingController();
  String aqiData = '';
  String _aqiResult = '';
  String news = '';
  List<Uint8List> _charts = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    fetchNews();
  }

  String getBaseUrl() {
    return String.fromEnvironment('FLUTTER_ENV') == 'emulator'
        ? 'http://10.0.2.2:5000'
        : 'http://10.68.121.252:5000';
  }



  Future<void> fetchNews() async {
    final String apiUrl = '${getBaseUrl()}/delhi-news';
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List articles = data['articles'];
        final String compiledNews = articles
            .map((a) => "- ${a['title']} (${a['source']})")
            .join('\n\n');
        setState(() {
          news = compiledNews.isNotEmpty ? compiledNews : "No news available.";
        });
      } else {
        setState(() {
          news = 'Failed to load news';
        });
      }
    } catch (e) {
      setState(() {
        news = 'Error: $e';
      });
    }
  }

  Future<void> fetchAQIAndCharts() async {
    final int? monthIndex = int.tryParse(_monthController.text);
    if (monthIndex == null || monthIndex < 1 || monthIndex > 12) {
      setState(() {
        _aqiResult = "❌ Invalid month! Please enter a value between 1 and 12.";
        _charts.clear();
      });
      return;
    }

    setState(() {
      isLoading = true;
      _aqiResult = '';
      _charts.clear();
    });

    final String baseUrl = getBaseUrl();

    try {
      final predictionResponse = await http.post(
        Uri.parse('$baseUrl/predict/$monthIndex'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': widget.username}),
      );

      final chartsResponse = await http.post(
        Uri.parse('$baseUrl/run-notebook'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'month': monthIndex}),
      );

      if (predictionResponse.statusCode == 200 && chartsResponse.statusCode == 200) {
        final predictionData = json.decode(predictionResponse.body);
        final chartsData = json.decode(chartsResponse.body);

        setState(() {
          _aqiResult =
          "Predicted AQI: ${predictionData['aqi_value']}\nSolution: ${predictionData['solution']}";
          _charts = (chartsData['visualizations'] as Map<String, dynamic>)
              .values
              .whereType<String>()
              .map(base64.decode)
              .toList();
        });
      } else {
        setState(() {
          _aqiResult = "❌ Failed to load data from server.";
        });
      }
    } catch (e) {
      setState(() {
        _aqiResult = "❌ Exception: $e";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CLOUD AQI - ${widget.username}'),
        backgroundColor: Colors.lightBlue.shade800,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.lightBlue.shade800, Colors.black],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [

              TextField(
                controller: _monthController,
                keyboardType: TextInputType.number,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Enter month (1-12)",
                  filled: true,
                  fillColor: Colors.white10,
                  labelStyle: TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: fetchAQIAndCharts,
                child: Text("Fetch AQI & Charts"),
              ),
              SectionWidget(title: "Month-wise AQI Prediction", content: _aqiResult),

              if (isLoading)
                const CircularProgressIndicator()
              else if (_charts.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Visualizations",
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    ..._charts.map((img) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(img, fit: BoxFit.cover),
                      ),
                    )),
                  ],
                ),

              SectionWidget(title: "Today's News", content: news),

              const SizedBox(height: 20),

              // ✅ "View History" Button
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HistoryPage(
                        loggedInUser: widget.username,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                ),
                child: const Text(
                  'View History',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SectionWidget extends StatelessWidget {
  final String title;
  final String content;

  const SectionWidget({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.symmetric(vertical: 12.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title.isNotEmpty)
              Text(title,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(content, style: TextStyle(color: Colors.white70)),
            ),
          ],
        ),
      ),
    );
  }
}

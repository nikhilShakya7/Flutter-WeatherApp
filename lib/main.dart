import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: WeatherApp());
  }
}

class WeatherApp extends StatefulWidget {
  const WeatherApp({super.key});

  @override
  State<WeatherApp> createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {
  final TextEditingController _controller = TextEditingController();
  String city = '';
  double? temperature;
  String? description;

  Future<void> fetchWeather(String cityName) async {
    const apiKey =
        '16cf71b238debc55a78b25f571f94bd3'; // Replace with your real key
    final url = Uri.parse(
      'https://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=$apiKey&units=metric',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        temperature = data['main']['temp'];
        description = data['weather'][0]['description'];
        city = data['name'];
      });
    } else {
      setState(() {
        temperature = null;
        description = 'City not found';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weather App')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Enter city name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                fetchWeather(_controller.text);
              },
              child: const Text('Get Weather'),
            ),
            const SizedBox(height: 20),
            if (temperature != null)
              Column(
                children: [
                  Text(city, style: const TextStyle(fontSize: 24)),
                  Text(
                    '${temperature!.toStringAsFixed(1)} °C',
                    style: const TextStyle(fontSize: 32),
                  ),
                  Text('$description', style: const TextStyle(fontSize: 18)),
                ],
              )
            else if (description != null)
              Text(
                description!,
                style: const TextStyle(color: Colors.red, fontSize: 18),
              ),
          ],
        ),
      ),
    );
  }
}

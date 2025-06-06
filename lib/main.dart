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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Roboto'),
      home: const WeatherApp(),
    );
  }
}

class WeatherApp extends StatefulWidget {
  const WeatherApp({super.key});

  @override
  State<WeatherApp> createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  String city = '';
  double? temperature;
  String? description;
  String? iconCode;
  bool isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _animationController.dispose();
    _slideController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> fetchWeather(String cityName) async {
    if (cityName.trim().isEmpty) return;

    const apiKey = '16cf71b238debc55a78b25f571f94bd3';
    final url = Uri.parse(
      'https://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=$apiKey&units=metric',
    );

    setState(() {
      isLoading = true;
      temperature = null;
      description = null;
      iconCode = null;
    });

    try {
      final response = await http.get(url);
      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          city = data['name'];
          temperature = data['main']['temp'];
          description = data['weather'][0]['description'];
          iconCode = data['weather'][0]['icon'];
        });
        _animationController.forward();
        _slideController.forward();
      } else {
        setState(() {
          description = data['message'];
        });
      }
    } catch (e) {
      setState(() {
        description = 'Error fetching data. Please check your connection.';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Color _getBackgroundColor() {
    if (temperature == null) return Colors.blue.shade300;
    if (temperature! >= 30) return Colors.orange.shade400;
    if (temperature! >= 20) return Colors.green.shade400;
    if (temperature! >= 10) return Colors.blue.shade400;
    return Colors.indigo.shade500;
  }

  Widget _buildSearchCard() {
    return Card(
      elevation: 8,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              style: const TextStyle(fontSize: 16),
              decoration: InputDecoration(
                labelText: 'Enter city name',
                labelStyle: TextStyle(color: Colors.grey.shade600),
                prefixIcon: Icon(
                  Icons.location_city,
                  color: Colors.blue.shade400,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 20,
                ),
              ),
              onSubmitted: fetchWeather,
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () => fetchWeather(_controller.text),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade500,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text(
                        'Get Weather',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherCard() {
    if (isLoading) {
      return Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [Colors.blue.shade300, Colors.blue.shade500],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 3,
            ),
          ),
        ),
      );
    } else if (temperature != null) {
      return FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Card(
            elevation: 12,
            shadowColor: Colors.black38,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            child: Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                gradient: LinearGradient(
                  colors: [
                    _getBackgroundColor(),
                    _getBackgroundColor().withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  if (iconCode != null)
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Image.network(
                        'https://openweathermap.org/img/wn/$iconCode@4x.png',
                        height: 80,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                              Icons.cloud,
                              size: 80,
                              color: Colors.white,
                            ),
                      ),
                    ),
                  const SizedBox(height: 15),
                  Text(
                    city,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          offset: Offset(0, 2),
                          blurRadius: 4,
                          color: Colors.black26,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        temperature!.toStringAsFixed(0),
                        style: const TextStyle(
                          fontSize: 64,
                          fontWeight: FontWeight.w300,
                          color: Colors.white,
                          height: 1,
                        ),
                      ),
                      const Text(
                        '°C',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w300,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      description?.toUpperCase() ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } else if (description != null) {
      return Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [Colors.red.shade300, Colors.red.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            children: [
              const Icon(Icons.error_outline, size: 50, color: Colors.white),
              const SizedBox(height: 15),
              Text(
                description!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    } else {
      return Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [Colors.grey.shade200, Colors.grey.shade300],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.wb_sunny_outlined,
                size: 60,
                color: Colors.grey.shade600,
              ),
              const SizedBox(height: 15),
              Text(
                'Enter a city name to get weather information',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blue.shade100,
              Colors.blue.shade200,
              Colors.blue.shade300,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Row(
                  children: [
                    Icon(Icons.cloud, size: 32, color: Colors.blue.shade700),
                    const SizedBox(width: 10),
                    Text(
                      'Weather App',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                _buildSearchCard(),
                const SizedBox(height: 30),
                _buildWeatherCard(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

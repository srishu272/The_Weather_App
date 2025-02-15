import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _cityName;
  String? _temperature;
  String? _condition;
  String? _windSpeed;
  bool _isLoading = false;
  String? _error;

  final String? apiKey = dotenv.env['API_KEY'];

  Future<void> fetchWeatherData(String cityName) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    final url = Uri.parse(
        "https://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=$apiKey");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _cityName = data['name'];
          _temperature = data['main']['temp'].toString();
          _condition = data['weather'][0]['description'];
          _windSpeed = data['wind']['speed'].toString();
        });
        print(data);
        print(cityName);
      } else {
        setState(() {
          _error = "City Not found. Please Try Again...";
        });
      }
    } catch (e) {
      setState(() {
        _error = "An error occured";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Weather App",
            style: TextStyle(color: Colors.white70),
          ),
          backgroundColor: Colors.indigo,
        ),
        body: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(
                      "assets/premium_photo-1667143327618-bf16fc8777ba.jpeg"),
                  fit: BoxFit.fill)),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_isLoading) CircularProgressIndicator(),
                if (_error != null)
                  Center(
                      child: Text(
                    _error!,
                    style: TextStyle(fontSize: 20),
                  )),
                if (!_isLoading && _error == null && _cityName != null) ...[
                  Text(
                    '$_cityName',
                    style: TextStyle(fontSize: 25),
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration:BoxDecoration(
                      color: Colors.white70.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(18)
                    ),
                    child: Column(
                      children: [
                        Text(
                          '$_temperature k',
                          style: TextStyle(fontSize: 50),
                        ),
                        Text(
                          '${_condition?.toUpperCase()}',
                          style: TextStyle(fontSize: 18),
                        ),
                        Text(
                          '$_windSpeed m/s',
                          style: TextStyle(fontSize: 18),
                        )
                      ],
                    ),
                  )
                ],
                SizedBox(
                  height: 10,
                ),
                Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        icon: Icon(Icons.search_outlined,color: Colors.black87,),
                        labelText: "Enter the City Name",
                        labelStyle: TextStyle(color: Colors.black),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black,width: 2)),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black)),
                      ),
                      onSubmitted: fetchWeatherData,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

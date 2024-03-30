import 'package:http/http.dart' as http;
import 'dart:convert';

class WeatherService {
  static const String _apiKey =
      "392410f275cb413d8eb83141243003"; // Update with your WeatherAPI key
  static const String _baseUrl = "http://api.weatherapi.com/v1/current.json";

  Future<String> fetchWeatherInfo() async {
    final String universityLocation = "Kamloops"; // City name for WeatherAPI
    final url = '$_baseUrl?key=$_apiKey&q=$universityLocation&aqi=no';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final conditionText = data['current']['condition']['text'];
      final double temp = data['current']['temp_c'];

      return _generateWeatherComment(conditionText, temp);
    } else {
      throw Exception('Failed to load weather data for Kamloops, BC, Canada.');
    }
  }

  String _generateWeatherComment(String conditionText, double temp) {
    // Mapping condition keywords to emojis
    String emoji = '';
    if (conditionText.contains("Rain") || conditionText.contains("Drizzle")) {
      emoji = '☔';
    } else if (conditionText.contains("Snow")) {
      emoji = '❄️';
    } else if (conditionText.contains("Sunny")) {
      emoji = '☀️';
    } else if (temp < 0) {
      emoji = '🧣';
    } else if (temp > 25) {
      emoji = '🥤';
    } else {
      emoji = '🌤'; // Default weather emoji
    }

    String tempMessage =
        "$emoji It's currently ${temp.toStringAsFixed(1)}°C at TRU.";

    // Additional advice based on the condition text or temperature
    String advice = tempMessage;
    if (conditionText.contains("Rain") || conditionText.contains("Drizzle")) {
      advice += "\nIt might rain later, grab an umbrella!";
    } else if (conditionText.contains("Snow")) {
      advice += "\nSnowfall expected, dress warmly!";
    } else if (conditionText.contains("Sunny")) {
      advice += "\nIt's sunny today, don't forget sunscreen!";
    } else if (temp < 0) {
      advice += "\nIt's really cold, ensure you're bundled up!";
    } else if (temp > 25) {
      advice += "\nQuite hot, stay hydrated!";
    }

    return tempMessage;
  }
}

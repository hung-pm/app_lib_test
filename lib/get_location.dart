import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';

class GetLocationWidget extends StatefulWidget {
  const GetLocationWidget({super.key});

  @override
  _GetLocationState createState() => _GetLocationState();
}

class _GetLocationState extends State<GetLocationWidget> {
  final Location location = Location();

  bool _loading = false;

  LocationData? _location;
  String? _city;
  String? _content;
  String? _state;
  String? _error;

  Future<void> _getLocation() async {
    setState(() {
      _error = null;
      _loading = true;
    });

    try {
      final locationResult = await Location().getLocation();
      final lat = locationResult.latitude;
      final lon = locationResult.longitude;

      final url = Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lon&format=json');

      final response = await http.get(url, headers: {
        'User-Agent': 'FlutterApp', // Nominatim yêu cầu có User-Agent
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final address = data['address'];
        final city = address['city'] ??
            address['town'] ??
            address['village'] ??
            address['county'];
        final state = address['state'];

        setState(() {
          _location = locationResult;
          _city = city;
          _state = state;
          _content = data['display_name'];
          _loading = false;
        });
      } else {
        setState(() {
          _error = 'Lỗi khi gọi API: ${response.statusCode}';
          _loading = false;
        });
      }
    } catch (err) {
      setState(() {
        _error = err.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Location: ${_error ?? '${_location ?? "unknown"}'}',
          style: Theme
              .of(context)
              .textTheme
              .bodyLarge,
        ),
        Text("Tỉnh/thành: ${_state ?? 'Không xác định'}"),
        Text("Thành phố/huyện: ${_city ?? 'Không xác định'}"),
        Text("Display Name: ${_content ?? 'Không xác định'}"),
        Row(
          children: <Widget>[
            ElevatedButton(
              onPressed: _getLocation,
              child: _loading
                  ? const CircularProgressIndicator(
                color: Colors.white,
              )
                  : const Text('Get'),
            ),
          ],
        ),
      ],
    );
  }
}
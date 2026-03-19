import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = 'https://www.buskirala.com/wp-admin/admin-ajax.php';
  static const String _secret = 'BuskiralaMobil2026';

  static Future<Map<String, dynamic>> _post(Map<String, String> body) async {
    body['secret'] = _secret;
    final response = await http.post(
      Uri.parse(_baseUrl),
      body: body,
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getConfig() async {
    return await _post({'action': 'bk_mobile_get_config'});
  }

  static Future<Map<String, dynamic>> getVehicles({
    required String pickupId,
    required String dropoffId,
    required String pickupCity,
  }) async {
    return await _post({
      'action': 'bk_mobile_get_vehicles',
      'pickup_id': pickupId,
      'dropoff_id': dropoffId,
      'pickup_city': pickupCity,
    });
  }

  static Future<Map<String, dynamic>> saveTransfer({
    required String firstName,
    required String lastName,
    required String phone,
    required String email,
    required String pickupLocation,
    required String dropoffLocation,
    required String transferDate,
    required String transferTime,
    required String vehicleType,
    required double price,
    String tripType = 'one-way',
    String returnDate = '',
    String returnTime = '',
    String flightCode = '',
    String driverNote = '',
    int extraChild = 0,
    int extraGreet = 0,
    String company = '',
    String taxNo = '',
    String taxOffice = '',
    String paxList = '',
  }) async {
    return await _post({
      'action': 'bk_mobile_save_transfer',
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'email': email,
      'pickup_location': pickupLocation,
      'dropoff_location': dropoffLocation,
      'transfer_date': transferDate,
      'transfer_time': transferTime,
      'vehicle_type': vehicleType,
      'price': price.toString(),
      'trip_type': tripType,
      'return_date': returnDate,
      'return_time': returnTime,
      'flight_code': flightCode,
      'driver_note': driverNote,
      'extra_child': extraChild.toString(),
      'extra_greet': extraGreet.toString(),
      'company': company,
      'tax_no': taxNo,
      'tax_office': taxOffice,
      'pax_list': paxList,
    });
  }

  static Future<Map<String, dynamic>> saveRental({
    required String firstName,
    required String lastName,
    required String phone,
    required String email,
    required String vehicleType,
    required String startDate,
    required String endDate,
    required String pickupCity,
    required int passengerCount,
    String note = '',
  }) async {
    return await _post({
      'action': 'bk_mobile_save_rental',
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'email': email,
      'vehicle_type': vehicleType,
      'start_date': startDate,
      'end_date': endDate,
      'pickup_city': pickupCity,
      'passenger_count': passengerCount.toString(),
      'note': note,
    });
  }

  static Future<Map<String, dynamic>> getOrders({
    String phone = '',
    String email = '',
  }) async {
    return await _post({
      'action': 'bk_mobile_get_orders',
      'phone': phone,
      'email': email,
    });
  }
}
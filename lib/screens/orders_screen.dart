import 'package:flutter/material.dart';
import '../services/api_service.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final _phoneController = TextEditingController();
  List<dynamic> _orders = [];
  bool _loading = false;
  bool _searched = false;

  Future<void> _search() async {
    if (_phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen telefon numaranızı girin.'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() {
      _loading = true;
      _searched = false;
    });

    final res = await ApiService.getOrders(phone: _phoneController.text.trim());

    setState(() {
      _loading = false;
      _searched = true;
      _orders = res['success'] == true ? res['data']['orders'] ?? [] : [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rezervasyonlarım'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        hintText: 'Telefon numaranız...',
                        prefixIcon: const Icon(Icons.phone_outlined, color: Colors.grey),
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                      ),
                      keyboardType: TextInputType.phone,
                      onSubmitted: (_) => _search(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _loading ? null : _search,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    ),
                    child: _loading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Sorgula'),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: !_searched
                  ? _buildEmpty()
                  : _orders.isEmpty
                      ? _buildNotFound()
                      : _buildOrderList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text('Rezervasyonlarınızı görmek için\ntelefonunuzu girin.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildNotFound() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text('Bu telefon numarasına ait rezervasyon bulunamadı.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildOrderList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _orders.length,
      itemBuilder: (context, index) {
        final o = _orders[index];
        final isPaid = o['payment_status'] == 'odendi';
        final statusColor = isPaid ? Colors.green : Colors.orange;
        final statusText = isPaid ? 'Ödendi' : 'Beklemede';

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('#${o['id']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor.withOpacity(0.3)),
                    ),
                    child: Text(statusText, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _orderRow(Icons.person_outline, '${o['first_name']} ${o['last_name']}'),
              const SizedBox(height: 6),
              _orderRow(Icons.location_on_outlined, o['pickup_location'] ?? ''),
              const SizedBox(height: 4),
              _orderRow(Icons.location_off_outlined, o['dropoff_location'] ?? ''),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(child: _orderRow(Icons.calendar_today, _formatDate(o['transfer_date'] ?? ''))),
                  Expanded(child: _orderRow(Icons.access_time, o['transfer_time'] ?? '')),
                ],
              ),
              const SizedBox(height: 6),
              _orderRow(Icons.directions_bus, o['vehicle_name'] ?? o['vehicle_type'] ?? ''),
              const Divider(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Toplam Tutar', style: TextStyle(color: Colors.grey, fontSize: 13)),
                  Text('${o['price']?.toInt()} TL', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFFFF6600))),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _orderRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 6),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis)),
      ],
    );
  }

  String _formatDate(String date) {
    if (date.isEmpty) return '';
    try {
      final parts = date.split('-');
      return '${parts[2]}.${parts[1]}.${parts[0]}';
    } catch (e) {
      return date;
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }
}
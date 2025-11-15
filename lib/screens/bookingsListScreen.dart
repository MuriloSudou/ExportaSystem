
import 'package:exportasystem/controllers/bookingController.dart';

import 'package:exportasystem/models/BookingModel.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; 
import 'package:exportasystem/screens/bookingFormScreen.dart';

class BookingsListScreen extends StatelessWidget {
  BookingsListScreen({super.key});
  final c = Get.put(BookingController());

  @override
  Widget build(BuildContext context) {
    c.load();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => c.load(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Buscar por nº, armador ou navio...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (v) {
                c.query.value = v;
                c.load(v);
              },
            ),
          ),
          Expanded(
            child: Obx(() {
              if (c.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (c.error.value != null) {
                return Center(child: Text(c.error.value!));
              }
              if (c.bookings.isEmpty) {
                return const Center(child: Text('Nenhum booking encontrado.'));
              }
              return ListView.separated(
                itemCount: c.bookings.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final Booking b = c.bookings[i];
                  return ListTile(
                    title: Text(
                        '${b.numeroBooking} (${b.quantidadeContainers} Cntr)'),
                    subtitle: Text(
                        'Armador: ${b.armador} • Navio: ${b.navio ?? '-'}'),
                    
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          tooltip: 'Editar',
                          onPressed: () async {
                            final updated = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BookingFormScreen(booking: b),
                              ),
                            );
                            if (updated == true) c.load();
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          tooltip: 'Excluir',
                          onPressed: () => _confirmDelete(context, c, b),
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final created = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const BookingFormScreen()),
          );
          if (created == true) c.load();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, BookingController c, Booking b) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir Booking'),
        content: Text('Confirmar exclusão do booking "${b.numeroBooking}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Excluir')),
        ],
      ),
    );
    if (ok == true && b.id != null) {
      await c.remove(b.id!);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Booking excluído.')));
    }
  }
}
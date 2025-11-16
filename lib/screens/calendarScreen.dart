import 'package:exportasystem/models/BookingModel.dart';
import 'package:exportasystem/repository/BookingRepository.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  static const corPrincipal = Color(0xFF1E88E5);
  static const background = Color(0xFFF5F7FA);
  static const corTexto = Color(0xFF37474F);

  final BookingRepository _repo = BookingRepository();

  late Map<DateTime, List<dynamic>> _events;
  late List<dynamic> _selectedEvents;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _events = {};
    _selectedEvents = [];
    _loadAllBookings();
  }

  
  Future<void> _loadAllBookings() async {
    setState(() { _isLoading = true; });

    final allBookings = await _repo.getAll();
    final Map<DateTime, List<dynamic>> eventMap = {};

    for (final booking in allBookings) {
      
      
      _addEventToMap(eventMap, booking.previsaoEmbarque, "Saída (ETD): ${booking.numeroBooking}");
      
   
      _addEventToMap(eventMap, booking.previsaoDesembarque, "Chegada (ETA): ${booking.numeroBooking}");

 
      if (booking.deadlineDraft != null) {
        _addEventToMap(eventMap, booking.deadlineDraft!, "Draft: ${booking.numeroBooking}");
      }
      if (booking.deadlineVgm != null) {
        _addEventToMap(eventMap, booking.deadlineVgm!, "VGM: ${booking.numeroBooking}");
      }
      if (booking.deadlineCarga != null) {
        _addEventToMap(eventMap, booking.deadlineCarga!, "Carga: ${booking.numeroBooking}");
      }
    }

    setState(() {
      _events = eventMap;
      _selectedEvents = _getEventsForDay(_selectedDay!);
      _isLoading = false;
    });
  }

  void _addEventToMap(Map<DateTime, List<dynamic>> map, DateTime date, String event) {
    final normalizedDay = DateTime.utc(date.year, date.month, date.day);
    map[normalizedDay] = map[normalizedDay] ?? [];
    map[normalizedDay]!.add(event);
  }

  List<dynamic> _getEventsForDay(DateTime day) {
    final normalizedDay = DateTime.utc(day.year, day.month, day.day);
    return _events[normalizedDay] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _selectedEvents = _getEventsForDay(selectedDay);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1.0,
        centerTitle: false,
        title: Text(
          "Calendário de Eventos", // Título atualizado
          style: TextStyle(color: corTexto, fontWeight: FontWeight.bold),
        ),
        iconTheme: IconThemeData(color: corPrincipal),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(32.0),
                child: Center(child: CircularProgressIndicator()),
              )
            else
              TableCalendar(
                locale: 'pt_BR',
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: _onDaySelected,
                eventLoader: _getEventsForDay,
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(
                    color: corTexto,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  leftChevronIcon: Icon(Icons.chevron_left, color: corPrincipal),
                  rightChevronIcon: Icon(Icons.chevron_right, color: corPrincipal),
                ),
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    shape: BoxShape.circle,
                  ),
                  todayTextStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                  selectedDecoration: BoxDecoration(
                    color: corPrincipal,
                    shape: BoxShape.circle,
                  ),
                  selectedTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  markerDecoration: BoxDecoration(
                    color: Colors.red.shade400,
                    shape: BoxShape.circle,
                  ),
                  markersMaxCount: 4,
                  outsideDaysVisible: false,
                ),
              ),

            const SizedBox(height: 12.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "Eventos do Dia",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: corTexto),
              ),
            ),
            if (_selectedEvents.isEmpty && !_isLoading)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Nenhum evento para este dia.", 
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
            
           
            ListView.builder(
              itemCount: _selectedEvents.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final event = _selectedEvents[index] as String;
                
               
                final parts = event.split(':');
                final eventType = parts[0].trim();
                final bookingNumber = parts.sublist(1).join(':').trim();

                
                IconData iconData;
                Color iconColor;

                if (eventType.startsWith('Saída')) {
                  iconData = Icons.directions_boat_filled_outlined;
                  iconColor = Colors.orange.shade700;
                } else if (eventType.startsWith('Chegada')) {
                  iconData = Icons.anchor;
                  iconColor = Colors.green.shade700; 
                } else {
                  iconData = Icons.event_note;
                  iconColor = corPrincipal; 
                }

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: Icon(
                      iconData,
                      color: iconColor,
                      size: 32,
                    ),
                    title: Text(
                      bookingNumber,
                      style: TextStyle(fontWeight: FontWeight.bold, color: corTexto),
                    ),
                    subtitle: Text(
                      
                      eventType.startsWith('Saída') || eventType.startsWith('Chegada') 
                          ? eventType 
                          : "Deadline: $eventType",
                      style: TextStyle(color: iconColor.withOpacity(0.9)),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20.0), 
          ],
        ),
      ),
    );
  }
}
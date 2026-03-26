import 'package:flutter/material.dart';

class CalendarioView extends StatefulWidget {
  const CalendarioView({super.key});

  @override
  State<CalendarioView> createState() => _CalendarioViewState();
}

class _CalendarioViewState extends State<CalendarioView> {
  DateTime _dataSelecionada = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendário de Viagens'),
        backgroundColor: Colors.redAccent, // Cor para combinar com o ícone da foto
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(16.0),
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: CalendarDatePicker(
              initialDate: _dataSelecionada,
              firstDate: DateTime(2024),
              lastDate: DateTime(2030),
              onDateChanged: (date) {
                setState(() {
                  _dataSelecionada = date;
                });
              },
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ListTile(
              leading: const Icon(Icons.event, color: Colors.red),
              title: const Text("Data Selecionada:"),
              subtitle: Text(
                "${_dataSelecionada.day}/${_dataSelecionada.month}/${_dataSelecionada.year}",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                // Lógica futura para salvar um evento nesta data
              },
              child: const Text("AGENDAR VISITA", style: TextStyle(color: Colors.white)),
            ),
          )
        ],
      ),
    );
  }
}

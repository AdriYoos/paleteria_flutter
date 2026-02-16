import 'dart:io'; // Importa dart:io para usar la clase File
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import './utils/config.dart';

class HistorialInventarioPage extends StatefulWidget {
  @override
  _HistorialInventarioPageState createState() => _HistorialInventarioPageState();
}

class _HistorialInventarioPageState extends State<HistorialInventarioPage> {
  final Dio _dio = Dio();
  List<dynamic> _historial = [];
  bool _isLoading = true;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _fetchHistorial();
  }

  Future<void> _fetchHistorial({DateTime? startDate, DateTime? endDate}) async {
    // Validar que endDate no sea mayor que la fecha actual
    if (endDate != null && endDate.isAfter(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('La fecha final no puede ser mayor que la fecha actual.')),
      );
      return;
    }

    try {
      final response = await _dio.get('${Config.apiBaseUrl}/historial_Inventario', queryParameters: {
        'startDate': startDate != null ? DateFormat('yyyy-MM-dd').format(startDate) : null,
        'endDate': endDate != null ? DateFormat('yyyy-MM-dd').format(endDate) : null,
      });
      setState(() {
        _historial = response.data;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching historial: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // Fecha inicial es la actual
      firstDate: DateTime(2000),   // Fecha mínima permitida
      lastDate: DateTime.now(),    // Fecha máxima permitida es la actual
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
      _fetchHistorial(startDate: _startDate, endDate: _endDate);
    }
  }

  Future<void> _generateExcel() async {
    // Crear un nuevo archivo Excel
    final excel = Excel.createExcel();
    final sheet = excel['Historial'];

    // Agregar encabezados
    sheet.appendRow([
      'ID',
      'Fecha',
      'ID Producto',
      'Descripción',
      'Cantidad',
      'Categoría',
      'Sabor',
    ]);

    // Agregar datos del historial
    for (final item in _historial) {
      sheet.appendRow([
        item['id'],
        formatDate(item['fecha']),
        item['id_producto'],
        item['descripcion'],
        item['cantidad'],
        item['categoria'],
        item['sabor'],
      ]);
    }

    // Guardar el archivo Excel
    final fileBytes = excel.save();
    if (fileBytes != null) {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/historial_inventario.xlsx';
      final file = File(filePath); // Usar la clase File de dart:io
      await file.writeAsBytes(fileBytes);

      // Abrir el archivo después de generarlo
      OpenFile.open(file.path);
    }
  }

  String formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return 'N/A';
    }
    try {
      final dateTime = DateTime.parse(dateString);
      return DateFormat('yyyy-MM-dd').format(dateTime);
    } catch (e) {
      print('Error formateando la fecha: $e');
      return 'N/A';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Historial de Inventario'),
        actions: [
          DropdownButton<String>(
            value: 'Reportes',
            onChanged: (String? newValue) {
              if (newValue == 'Generar Excel') {
                _generateExcel();
              }
            },
            items: [
              DropdownMenuItem(
                value: 'Reportes',
                child: Text('Reportes'),
              ),
              DropdownMenuItem(
                value: 'Generar Excel',
                child: Text('Generar Excel'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton(
                onPressed: () => _selectDate(context, true),
                child: Text(_startDate != null ? DateFormat('yyyy-MM-dd').format(_startDate!) : 'Seleccionar fecha inicial'),
              ),
              TextButton(
                onPressed: () => _selectDate(context, false),
                child: Text(_endDate != null ? DateFormat('yyyy-MM-dd').format(_endDate!) : 'Seleccionar fecha final'),
              ),
            ],
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _historial.length,
                    itemBuilder: (context, index) {
                      final item = _historial[index];
                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: ListTile(
                          title: Text('ID: ${item['id']}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Fecha: ${formatDate(item['fecha'])}'),
                              Text('Descripción: ${item['descripcion']}'),
                              Text('Cantidad: ${item['cantidad']}'),
                              Text('Categoría: ${item['categoria']}'),
                              Text('Sabor: ${item['sabor']}'),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: HistorialInventarioPage(),
  ));
}
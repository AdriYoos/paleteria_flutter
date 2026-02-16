import 'dart:io'; // Importa dart:io para usar la clase File
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import './utils/config.dart';
class ApiService {
  final Dio _dio = Dio();

  Future<Map<String, dynamic>> fetchReporteFinanciero({DateTime? startDate, DateTime? endDate}) async {
    try {
      final response = await _dio.get('${Config.apiBaseUrl}/historialFinanciero', queryParameters: {
        'startDate': startDate != null ? DateFormat('yyyy-MM-dd').format(startDate) : null,
        'endDate': endDate != null ? DateFormat('yyyy-MM-dd').format(endDate) : null,
      });
      return response.data;
    } catch (e) {
      throw Exception('Error fetching reporte financiero: $e');
    }
  }
}

class ExcelService {
  static Future<void> generateExcel(Map<String, dynamic> reporteFinanciero) async {
    final excel = Excel.createExcel();
    final sheet = excel['Reporte Financiero'];

    // Agregar encabezados
    sheet.appendRow([
      'Tipo',
      'ID',
      'Fecha',
      'Total',
      'Descripción',
      'Tipo de Gasto',
    ]);

    // Agregar datos de ventas
    for (final item in reporteFinanciero['detalleVentas']) {
      sheet.appendRow([
        'Venta',
        item['id'],
        formatDate(item['fecha']),
        item['total'],
        'N/A',
        'N/A',
      ]);
    }

    // Agregar datos de gastos
    for (final item in reporteFinanciero['detalleGastos']) {
      sheet.appendRow([
        'Gasto',
        item['id'],
        formatDate(item['fecha']),
        item['total'],
        item['descripcion'],
        item['tipo_gasto'],
      ]);
    }

    // Guardar el archivo Excel
    final fileBytes = excel.save();
    if (fileBytes != null) {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/reporte_financiero.xlsx';
      final file = File(filePath);
      await file.writeAsBytes(fileBytes);

      // Abrir el archivo después de generarlo
      OpenFile.open(file.path);
    }
  }

  static String formatDate(String? dateString) {
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
}

class HistorialFinancieroPage extends StatefulWidget {
  @override
  _HistorialFinancieroPageState createState() => _HistorialFinancieroPageState();
}

class _HistorialFinancieroPageState extends State<HistorialFinancieroPage> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic> _reporteFinanciero = {};
  bool _isLoading = true;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _fetchReporteFinanciero();
  }

  Future<void> _fetchReporteFinanciero({DateTime? startDate, DateTime? endDate}) async {
    if (endDate != null && endDate.isAfter(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('La fecha final no puede ser mayor que la fecha actual.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final data = await _apiService.fetchReporteFinanciero(startDate: startDate, endDate: endDate);
      setState(() {
        _reporteFinanciero = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al obtener el reporte financiero: $e')),
      );
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
      _fetchReporteFinanciero(startDate: _startDate, endDate: _endDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reporte Financiero'),
        actions: [
          IconButton(
            icon: Icon(Icons.file_download),
            onPressed: () => ExcelService.generateExcel(_reporteFinanciero),
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
                : ListView(
                    children: [
                      Card(
                        margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: ListTile(
                          title: Text('Suma de Ventas: \$${_reporteFinanciero['sumaVentas']?.toStringAsFixed(2) ?? '0.00'}'),
                        ),
                      ),
                      Card(
                        margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: ListTile(
                          title: Text('Suma de Gastos: \$${_reporteFinanciero['sumaGastos']?.toStringAsFixed(2) ?? '0.00'}'),
                        ),
                      ),
                      Card(
                        margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: ListTile(
                          title: Text('Ganancias: \$${_reporteFinanciero['ganancias']?.toStringAsFixed(2) ?? '0.00'}'),
                        ),
                      ),
                      if (_reporteFinanciero['detalleVentas'] != null)
                        ..._reporteFinanciero['detalleVentas'].map<Widget>((venta) {
                          return Card(
                            margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            child: ListTile(
                              title: Text('Venta ID: ${venta['id']}'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Fecha: ${ExcelService.formatDate(venta['fecha'])}'),
                                  Text('Total: \$${venta['total']?.toStringAsFixed(2) ?? '0.00'}'),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      if (_reporteFinanciero['detalleGastos'] != null)
                        ..._reporteFinanciero['detalleGastos'].map<Widget>((gasto) {
                          return Card(
                            margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            child: ListTile(
                              title: Text('Gasto ID: ${gasto['id']}'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Fecha: ${ExcelService.formatDate(gasto['fecha'])}'),
                                  Text('Descripción: ${gasto['descripcion']}'),
                                  Text('Total: \$${gasto['total']?.toStringAsFixed(2) ?? '0.00'}'),
                                  Text('Tipo de Gasto: ${gasto['tipo_gasto']}'),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: HistorialFinancieroPage(),
  ));
}
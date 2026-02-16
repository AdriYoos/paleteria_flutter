import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import './utils/config.dart';

void main() {
  runApp(MaterialApp(
    home: RegistrarGastoPage(),
  ));
}

class RegistrarGastoPage extends StatefulWidget {
  @override
  _RegistrarGastoPageState createState() => _RegistrarGastoPageState();
}

class _RegistrarGastoPageState extends State<RegistrarGastoPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController descripcionController = TextEditingController();
  final TextEditingController unidadesController = TextEditingController();
  final TextEditingController precioUnidadController = TextEditingController();
  final TextEditingController fechaController = TextEditingController();
  int? selectedTipoGasto;
  List<Map<String, dynamic>> tiposGasto = [];
  final Dio dio = Dio();
  double total = 0.0;

  @override
  void initState() {
    super.initState();
    _getTiposGasto();
  }

  @override
  void dispose() {
    descripcionController.dispose();
    unidadesController.dispose();
    precioUnidadController.dispose();
    fechaController.dispose();
    super.dispose();
  }

  Future<void> _getTiposGasto() async {
    try {
      final response = await dio.get('${Config.apiBaseUrl}/tipos_gasto');
      setState(() {
        tiposGasto = List<Map<String, dynamic>>.from(response.data);
      });
    } catch (e) {
      print("Error al obtener los tipos de gasto: $e");
    }
  }

  void _calcularTotal() {
    double unidades = double.tryParse(unidadesController.text) ?? 0.0;
    double precioUnidad = double.tryParse(precioUnidadController.text) ?? 0.0;
    setState(() {
      total = unidades * precioUnidad;
    });
  }

  Future<void> _confirmarGasto() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final response = await dio.post('${Config.apiBaseUrl}/gastos', data: {
          'descripcion': descripcionController.text,
          'unidades': unidadesController.text,
          'fecha': fechaController.text,
          'total': total,
          'id_tipo': selectedTipoGasto,
          'precio_unidad': precioUnidadController.text,
        });

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gasto registrado con éxito')),
          );
          Navigator.pop(context); // Regresar a la página anterior
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al registrar el gasto')),
          );
        }
      } catch (e) {
        print("Error al registrar el gasto: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error de conexión')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registrar Gasto'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: descripcionController,
                  decoration: InputDecoration(
                    labelText: 'Descripción',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingrese la descripción';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: unidadesController,
                  decoration: InputDecoration(
                    labelText: 'Unidades',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => _calcularTotal(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingrese las unidades';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Por favor, ingrese un número válido';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: precioUnidadController,
                  decoration: InputDecoration(
                    labelText: 'Precio por Unidad',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => _calcularTotal(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingrese el precio por unidad';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Por favor, ingrese un número válido';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: fechaController,
                  decoration: InputDecoration(
                    labelText: 'Fecha',
                    border: OutlineInputBorder(),
                  ),
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        fechaController.text = "${pickedDate.toLocal()}".split(' ')[0];
                      });
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingrese la fecha';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                DropdownButtonFormField<int>(
                  value: selectedTipoGasto,
                  decoration: InputDecoration(
                    labelText: 'Tipo de Gasto',
                    border: OutlineInputBorder(),
                  ),
                  items: tiposGasto.map((tipo) {
                    return DropdownMenuItem<int>(
                      value: tipo["id"],
                      child: Text(tipo["tipo"]),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedTipoGasto = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Por favor, seleccione un tipo de gasto';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                Text(
                  'Total: \$${total.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 24.0),
                Center(
                  child: ElevatedButton(
                    onPressed: _confirmarGasto,
                    child: Text('Confirmar Gasto'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
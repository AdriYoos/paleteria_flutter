import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import './ventas2.dart';
import 'perfil_vendedor.dart';
import './utils/config.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ventas App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: VentasScreen(),
    );
  }
}

class VentasScreen extends StatefulWidget {
  @override
  _VentasScreenState createState() => _VentasScreenState();
}

class _VentasScreenState extends State<VentasScreen> {
  List<Map<String, dynamic>> ventasPendientes = [];
  final Dio dio = Dio();
  bool isLoading = true; // Indica si se está cargando
  String? errorMessage; // Almacena un mensaje de error si falla la carga

  @override
  void initState() {
    super.initState();
    cargarVentasPendientes();
  }

  Future<void> cargarVentasPendientes() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await dio.get('${Config.apiBaseUrl}/ventas_pendientes');
      if (response.statusCode == 200) {
        setState(() {
          ventasPendientes = List<Map<String, dynamic>>.from(response.data);
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error al cargar ventas: $e';
        isLoading = false;
      });
    }
  }

  void navegarAVentaPendiente(Map<String, dynamic>? venta) async {
    final numVenta = venta != null ? venta['id'] : null;

    final ventaActualizada = await Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => VentaInventarioPage(
          numVenta: numVenta,
          onGuardarPendiente: (venta) {
            cargarVentasPendientes();
          },
        ),
      ),
    );

    if (ventaActualizada != null) {
      cargarVentasPendientes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ventas'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => SellerProfile(),
              ),
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh), // Icono de actualización
            onPressed: cargarVentasPendientes, // Llama la función al presionar
            tooltip: "Actualizar ventas",
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text(errorMessage!, style: TextStyle(color: Colors.red)))
              : ventasPendientes.isEmpty
                  ? Center(child: Text('No hay ventas pendientes'))
                  : RefreshIndicator( // Permite actualizar deslizando hacia abajo
                      onRefresh: cargarVentasPendientes,
                      child: ListView.builder(
                        itemCount: ventasPendientes.length,
                        itemBuilder: (context, index) {
                          var venta = ventasPendientes[index];
                          return ListTile(
                            title: Text(venta['nombre'] ?? 'Venta ${venta['id']}'),
                            subtitle: Text('Total: \$${(venta['total'] is int ? venta['total'] : 0).toStringAsFixed(2)}'),
                            onTap: () => navegarAVentaPendiente(venta),
                          );
                        },
                      ),
                    ),
      floatingActionButton: GestureDetector(
        onLongPress: cargarVentasPendientes, // Mantener presionado para actualizar
        child: FloatingActionButton(
          onPressed: () {
            navegarAVentaPendiente(null);  // Navegar sin pasar una venta pendiente
          },
          child: Icon(Icons.add),
          tooltip: 'Agregar Venta',
        ),
      ),
    );
  }
}
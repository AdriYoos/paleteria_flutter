import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import './ventas.dart';
import './utils/config.dart';

class VentaInventarioPage extends StatefulWidget {
  final int? numVenta;
  final Function(Map<String, dynamic>)? onGuardarPendiente;

  VentaInventarioPage({this.numVenta, this.onGuardarPendiente});

  @override
  _VentaInventarioPageState createState() => _VentaInventarioPageState();
}

class _VentaInventarioPageState extends State<VentaInventarioPage> {
  List<Map<String, dynamic>> productosSeleccionados = [];
  final Dio _dio = Dio();
  int? _numVenta;

  
  @override
  void initState() {
    super.initState();
    if (widget.numVenta != null) {
      _numVenta = widget.numVenta;
      debugPrint("Cargando venta existente: $_numVenta");
      cargarProductosDeVenta(widget.numVenta!);
    } else {
      obtenerProximoNumVenta().then((numVenta) {
        setState(() {
          _numVenta = numVenta;
          productosSeleccionados.clear();
        });
        debugPrint("Nueva venta asignada: $_numVenta");
      });
    }
  }



  Future<int> obtenerProximoNumVenta() async {
    try {
      final response = await Dio().get('${Config.apiBaseUrl}/nextVentaId');
      return (response.data['nextId']);
    } catch (e) {
      debugPrint("Error al obtener próximo número de venta: $e");
      return 1; // En caso de error, devolver un valor por defecto
    }
  }

  void cargarProductosDeVenta(int numVenta) async {
    try {
      final response = await _dio.post('${Config.apiBaseUrl}/productosPorVenta', data: {
        'num_venta': numVenta,
      });

      if (response.data != null && response.data['productos'] != null) {
        setState(() {
          productosSeleccionados = List<Map<String, dynamic>>.from(response.data['productos'].map((producto) => {
            'codigo': producto['codigo'],
            'sabor': producto['sabor'],
            'categoria': producto['categoria'],
            'precio': (producto['precio'] ?? 0).toDouble(),
            'cantidad': (producto['stock_tem'] ?? 0).toInt(),
            'id_sub_venta': producto['id_sub_venta'],
          }));
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al cargar productos de la venta: $e")),
      );
    }
  }

  void agregarProducto(Map<String, dynamic> producto) async {
    try {
      if (_numVenta == null) {
        _numVenta = await obtenerProximoNumVenta();
        setState(() {});  // Asegurar actualización del estado
        debugPrint("Venta creada antes de agregar producto: $_numVenta");
      }

      final response = await _dio.post('${Config.apiBaseUrl}/addToSubVenta', data: {
        'id_producto': producto['codigo'],
        'cantidad': producto['cantidad'],
        'num_venta': _numVenta,
      });

      if (response.data['status'] == 'success') {
        setState(() {
          productosSeleccionados.add({
            ...producto,
            'id_sub_venta': response.data['id_sub_venta'],
          });
        });
        debugPrint("Producto agregado a venta $_numVenta");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al agregar producto: ${response.data['error']}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al agregar producto: $e")),
      );
    }
  }


  void eliminarProducto(int index) async {
    try {
      var producto = productosSeleccionados[index];
      final response = await _dio.post('${Config.apiBaseUrl}/disminuirSubVenta', data: {
        'id_sub_venta': producto['id_sub_venta'],
      });

      if (response.data['status'] == 'success') {
        setState(() {
          if (producto['cantidad'] > 1) {
            producto['cantidad'] -= 1;
          } else {
            productosSeleccionados.removeAt(index);
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.data['message'])),
        );
      } else {
        debugPrint("Error al disminuir producto: ${response.data['error']}");
      }
    } catch (e) {
      debugPrint("Error al disminuir producto: $e");
    }
  }

  void abrirDialogoVenta() async {
    final seleccionados = await showModalBottomSheet<List<Map<String, dynamic>>>(
      context: context,
      isScrollControlled: true,
      builder: (context) => VentaInventarioBottomSheet(),
    );

    if (seleccionados != null && seleccionados.isNotEmpty) {
      for (var producto in seleccionados) {
        agregarProducto(producto);
      }
    }
  }

  double calcularTotal() {
    return productosSeleccionados.fold(0.0, (total, producto) => total + ((producto['precio'] ?? 0.0) * (producto['cantidad'] ?? 0)));
  }

Future<void> dejarVentaPendiente() async {
  try {
    if (_numVenta == null) {
      _numVenta = await obtenerProximoNumVenta();
      setState(() {});
      debugPrint("Venta creada antes de dejar pendiente: $_numVenta");
    }

    final response = await _dio.post('${Config.apiBaseUrl}/saveAsPending', data: {
      'num_venta': _numVenta,
      'total': calcularTotal(),
    });

    if (response.data['status'] == 'success') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Venta guardada como pendiente!')),
      );

      setState(() {
        productosSeleccionados.clear();
        _numVenta = null;
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MyApp(),
        ),
      );
    } else {
      debugPrint("Error al guardar venta pendiente: ${response.data['error']}");
    }
  } catch (e) {
    debugPrint("Error al dejar venta pendiente: $e");
  }
}

Future<void> confirmarVenta() async {
  try {
    if (_numVenta == null) {
      _numVenta = await obtenerProximoNumVenta();
      setState(() {});
      debugPrint("Venta creada antes de confirmar: $_numVenta");
    }

    if (widget.numVenta == null) {
      await _dio.post('${Config.apiBaseUrl}/saveAsPending', data: {
        'num_venta': _numVenta,
        'total': calcularTotal(),
      });
    }

    final response = await _dio.post('${Config.apiBaseUrl}/confirmVenta', data: {
      'id_venta_tem': _numVenta,
    });

    if (response.data['status'] == 'success') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Venta confirmada!')),
      );

      setState(() {
        productosSeleccionados.clear();
        _numVenta = null;
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MyApp(),
        ),
      );
    } else {
      debugPrint("Error al confirmar la venta: ${response.data['error']}");
    }
  } catch (e) {
    debugPrint("Error al confirmar la venta: $e");
  }
}

void canelarVenta(int index) async {
  try {
    var producto = productosSeleccionados[index];
    final response = await _dio.post('${Config.apiBaseUrl}/removeFromSubVenta', data: {
      'id_sub_venta': producto['id_sub_venta'],
    });

    if (response.data['status'] == 'success') {
      setState(() {
        productosSeleccionados.removeAt(index);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Producto eliminado correctamente')),
      );
    } else {
      debugPrint("Error al eliminar producto: ${response.data['error']}");
    }
  } catch (e) {
    debugPrint("Error al eliminar producto: $e");
  }
}

void _mostrarDialogoCancelarVenta() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('¿Estás seguro de cancelar la venta?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Seguir con la venta'),
          ),
          TextButton(
            onPressed: () async {
              List<Map<String, dynamic>> productosAEliminar = List.from(productosSeleccionados);
              
              for (var producto in productosAEliminar) {
                await _dio.post('${Config.apiBaseUrl}/removeFromSubVenta', data: {
                  'id_sub_venta': producto['id_sub_venta'],
                });
              }

              setState(() {
                productosSeleccionados.clear();
              });

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => MyApp(),
                ),
              );
            },
            child: Text('Salir'),
          ),
        ],
      );
    },
  );
}




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Venta de Inventario')),
      body: Column(
        children: [
    Padding(
      padding: EdgeInsets.all(8.0), // Espaciado para que no queden pegados
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Distribuye los botones
        children: [
          ElevatedButton(
            onPressed: _mostrarDialogoCancelarVenta,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red, // Color del botón
            ),
            child: Text('Cancelar Venta', style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            onPressed: abrirDialogoVenta,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue, // Color del botón
            ),
            child: Text('Agregar Producto', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ),
    Expanded(
      child: ListView.builder(
        itemCount: productosSeleccionados.length,
        itemBuilder: (context, index) {
          var producto = productosSeleccionados[index];
          return ListTile(
            title: Text('${producto['sabor']} - ${producto['categoria']}'),
            subtitle: Text('Cantidad: ${producto['cantidad']} | Precio: \$${producto['precio']}'),
            trailing: IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => eliminarProducto(index),
            ),
          );
        },
      ),
    ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Total: \$${calcularTotal().toStringAsFixed(2)}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: dejarVentaPendiente,
                  child: Text('Dejar Pendiente'),
                ),
                ElevatedButton(
                  onPressed: productosSeleccionados.isEmpty ? null : confirmarVenta,
                  child: Text('Confirmar Venta'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class VentaInventarioBottomSheet extends StatefulWidget {
  @override
  _VentaInventarioBottomSheetState createState() => _VentaInventarioBottomSheetState();
}

class _VentaInventarioBottomSheetState extends State<VentaInventarioBottomSheet> {
  List<dynamic> productos = [];
  Map<String, int> cantidades = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    obtenerInventario();
  }

  Future<void> obtenerInventario() async {
    try {
      var response = await Dio().get('${Config.apiBaseUrl}/products3');
      setState(() {
        productos = response.data;
        for (var producto in productos) {
          cantidades[producto['codigo'].toString()] = 0;
        }
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error al obtener inventario: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void actualizarCantidad(String codigo, int cambio, int stock) {
    setState(() {
      int nuevaCantidad = cantidades[codigo]! + cambio;
      if (nuevaCantidad >= 0 && nuevaCantidad <= stock) {
        cantidades[codigo] = nuevaCantidad;
      }
    });
  }

  void agregarProductos() {
    List<Map<String, dynamic>> seleccionados = productos
        .where((producto) => cantidades[producto['codigo'].toString()]! > 0)
        .map((producto) => {
              'codigo': producto['codigo'],
              'sabor': producto['sabor'],
              'categoria': producto['categoria'],
              'precio': producto['precio'],
              'cantidad': cantidades[producto['codigo'].toString()],
            })
        .toList();

    Navigator.pop(context, seleccionados);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      height: MediaQuery.of(context).size.height * 0.8,
      child: Column(
        children: [
          Text(
            'Seleccionar Productos',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: productos.length,
                    itemBuilder: (context, index) {
                      var producto = productos[index];
                      return Card(
                        margin: EdgeInsets.all(8.0),
                        child: ListTile(
                          leading: producto['url_image'] != null
                              ? Image.network(
                                  '${Config.apiBaseUrl}${producto['url_image']}',
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(Icons.image_not_supported, size: 50);
                                  },
                                )
                              : Icon(Icons.image_not_supported, size: 50),
                          title: Text('${producto['sabor']} - ${producto['categoria']}'),
                          subtitle: Text('Precio: \$${producto['precio']} | Stock: ${producto['stock']}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.remove),
                                onPressed: () => actualizarCantidad(producto['codigo'].toString(), -1, producto['stock']),
                              ),
                              Text('${cantidades[producto['codigo'].toString()]}'),
                              IconButton(
                                icon: Icon(Icons.add),
                                onPressed: () => actualizarCantidad(producto['codigo'].toString(), 1, producto['stock']),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cerrar'),
              ),
              ElevatedButton(
                onPressed: agregarProductos,
                child: Text('Agregar'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
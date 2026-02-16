import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import './utils/config.dart';

final Dio dioInstance = Dio();

class InventarioPage extends StatefulWidget {
  @override
  _InventarioPageState createState() => _InventarioPageState();
}

class _InventarioPageState extends State<InventarioPage> {
  List<Map<String, dynamic>> _productos = [];
  String _categoriaSeleccionada = 'Todas';
  bool _modoEliminar = false;

  @override
  void initState() {
    super.initState();
    _cargarProductos();
  }

  Future<void> _cargarProductos() async {
    final url = '${Config.apiBaseUrl}/products3'; // Reemplaza con tu URL
    try {
      final response = await dioInstance.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        setState(() {
          _productos = data.map((producto) {
            return {
              'id': producto['codigo'],
              'nombre': producto['sabor'],
              'categoria': producto['categoria'],
              'precio': producto['precio'],
              'stock': producto['stock'],
              'url_image': producto['url_image'], // Añadir la URL de la imagen
              'seleccionado': false,
            };
          }).toList();
        });
      } else {
        print('Error al obtener los productos: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al realizar la solicitud: $e');
    }
  }

  void _toggleSeleccion(int index) {
    setState(() {
      _productos[index]['seleccionado'] = !_productos[index]['seleccionado'];
    });
  }

  Future<void> _eliminarUnidad(Map<String, dynamic> producto) async {
    if (producto['stock'] > 0) {
      setState(() {
        producto['stock'] -= 1;
      });

      final url = '${Config.apiBaseUrl}/updateStock2';
      try {
        final response = await dioInstance.post(
          url,
          data: {
            'id_product': producto['id'],
            'stock': producto['stock'],
          },
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Unidad eliminada correctamente')),
          );
        } else {
          throw Exception('Error al actualizar stock');
        }
      } catch (e) {
        print('Error al modificar producto: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar stock')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No hay unidades disponibles')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final categorias = ['Todas', ..._productos.map((p) => p['categoria']).toSet()];

    return Scaffold(
      appBar: AppBar(
        title: Text('Inventario'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Regresar a la pantalla anterior
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _cargarProductos,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: _categoriaSeleccionada,
              isExpanded: true,
              onChanged: (value) {
                setState(() {
                  _categoriaSeleccionada = value!;
                });
              },
              items: categorias
                  .map((categoria) => DropdownMenuItem<String>(
                        value: categoria,
                        child: Text(categoria),
                      ))
                  .toList(),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _productos.length,
              itemBuilder: (context, index) {
                final producto = _productos[index];
                if (_categoriaSeleccionada != 'Todas' &&
                    producto['categoria'] != _categoriaSeleccionada) {
                  return SizedBox.shrink();
                }

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
                    title: Text(producto['nombre']),
                    subtitle: Text('Categoría: ${producto['categoria']}\nPrecio: \$${producto['precio']}\nStock: ${producto['stock']} unidades'),
                    trailing: _modoEliminar
                        ? Checkbox(
                            value: producto['seleccionado'],
                            onChanged: (value) {
                              _toggleSeleccion(index);
                            },
                          )
                        : IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              _eliminarUnidad(producto);
                            },
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
    home: InventarioPage(),
  ));
}
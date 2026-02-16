import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'agregar_producto.dart'; // Importamos AltaProductoPage
import 'package:image_picker/image_picker.dart';
import 'dart:io';
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
    final url = '${Config.apiBaseUrl}/products'; // Reemplaza con tu URL
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

  Future<void> _eliminarProductos() async {
    bool confirmar = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirmar Eliminación'),
          content: Text(
              '¿Estás seguro de que quieres eliminar los productos seleccionados? Esta acción no se puede deshacer.'),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _modoEliminar = false; // Sale del modo eliminación
                });
                Navigator.of(context).pop(false); // Usuario cancela
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Usuario confirma
              },
              child: Text('Eliminar', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirmar == true) {
      for (var producto in _productos.where((p) => p['seleccionado'] == true).toList()) {
        final url = '${Config.apiBaseUrl}/deleteProduct';
        try {
          final response = await dioInstance.delete(url, data: {'id': producto['id']});
          if (response.statusCode == 200) {
            setState(() {
              _productos.remove(producto);
            });
          }
        } catch (e) {
          print('Error al eliminar producto: $e');
        }
      }
      setState(() {
        _modoEliminar = false; // Desactiva modo eliminación después de eliminar
      });
    }
  }

  Future<void> _modificarPrecio(Map<String, dynamic> producto) async {
    final TextEditingController precioController = TextEditingController(text: producto['precio'].toString());

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Modificar Precio'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: precioController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Precio'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                final url = '${Config.apiBaseUrl}/updateProduct';
                try {
                  final response = await dioInstance.post(
                    url,
                    data: {
                      'id_product': producto['id'],
                      'precio': double.parse(precioController.text),
                    },
                  );
                  if (response.statusCode == 200) {
                    setState(() {
                      producto['precio'] = double.parse(precioController.text);
                    });
                    Navigator.of(context).pop();
                  }
                } catch (e) {
                  print('Error al modificar producto: $e');
                }
              },
              child: Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _modificarCantidad(Map<String, dynamic> producto) async {
    final TextEditingController stockController = TextEditingController(text: producto['stock'].toString());

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Modificar Cantidad'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: stockController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Cantidad'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                final url = '${Config.apiBaseUrl}/updateStock';
                try {
                  final response = await dioInstance.post(
                    url,
                    data: {
                      'id_product': producto['id'],
                      'stock': int.parse(stockController.text),
                    },
                  );
                  if (response.statusCode == 200) {
                    setState(() {
                      producto['stock'] = int.parse(stockController.text);
                    });
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Stock actualizado correctamente')),
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
              },
              child: Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _modificarImagen(Map<String, dynamic> producto) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return; // Usuario canceló la selección

    File imageFile = File(pickedFile.path);
    
    try {
      String uploadUrl = '${Config.apiBaseUrl}/updateImage';

      FormData formData = FormData.fromMap({
        'id_product': producto['id'],
        'image': await MultipartFile.fromFile(imageFile.path, filename: producto['id'].toString() + '.jpg'),
      });

      final response = await dioInstance.post(uploadUrl, data: formData);

      if (response.statusCode == 200) {
        print('Imagen subida correctamente');
        setState(() {
          producto['imagen'] = response.data['url']; // Asigna la nueva URL de la imagen
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Imagen actualizada con éxito')),
        );
      } else {
        throw Exception('Error al subir la imagen');
      }
    } catch (e) {
      print('Error al modificar imagen: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar la imagen')),
      );
    }
  }

  void _navegarAAgregarProducto(BuildContext context) async {
    final nuevoProducto = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AltaProductoPage(),
      ),
    );

    if (nuevoProducto != null) {
      setState(() {
        _productos.add(nuevoProducto);
      });
    }
  }

  void _toggleModoEliminar() {
    setState(() {
      if (_modoEliminar) {
        // Si ya está en modo eliminación, verifica si hay productos seleccionados
        final hayProductosSeleccionados = _productos.any((producto) => producto['seleccionado'] == true);
        if (!hayProductosSeleccionados) {
          // Si no hay productos seleccionados, desactiva el modo eliminación
          _modoEliminar = false;
        } else {
          // Si hay productos seleccionados, procede con la eliminación
          _eliminarProductos();
        }
      } else {
        // Si no está en modo eliminación, actívalo
        _modoEliminar = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final categorias = ['Todas', ..._productos.map((p) => p['categoria']).toSet()];

    return Scaffold(
      appBar: AppBar(
        title: Text('Inventario'),
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
                    leading: Icon(Icons.shopping_bag, size: 50),
                    title: Text(producto['nombre']),
                    subtitle: Text('Categoría: ${producto['categoria']}\nPrecio: \$${producto['precio']}\nStock: ${producto['stock']} unidades'),
                    trailing: _modoEliminar
                        ? Checkbox(
                            value: producto['seleccionado'],
                            onChanged: (value) {
                              _toggleSeleccion(index);
                            },
                          )
                        : PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'precio') {
                                _modificarPrecio(producto);
                              } else if (value == 'cantidad') {
                                _modificarCantidad(producto);
                              } else if (value == 'imagen') {
                                _modificarImagen(producto);
                              }
                            },
                            itemBuilder: (BuildContext context) {
                              return [
                                PopupMenuItem(
                                  value: 'precio',
                                  child: Text('Modificar Precio'),
                                ),
                                PopupMenuItem(
                                  value: 'cantidad',
                                  child: Text('Modificar Cantidad'),
                                ),
                                PopupMenuItem(
                                  value: 'imagen',
                                  child: Text('Modificar Imagen'),
                                ),
                              ];
                            },
                          ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16),
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton.icon(
              onPressed: _toggleModoEliminar,
              icon: Icon(_modoEliminar ? Icons.delete : Icons.delete_outline),
              label: Text(_modoEliminar ? 'Confirmar Eliminación' : 'Eliminar Producto'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _modoEliminar ? Colors.red : Colors.orange,
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => _navegarAAgregarProducto(context),
              icon: Icon(Icons.add),
              label: Text('Agregar Producto'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: InventarioPage(),
  ));
}
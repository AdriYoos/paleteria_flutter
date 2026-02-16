import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import './utils/config.dart';

void main() {
  runApp(MaterialApp(
    home: AltaProductoPage(),
  ));
}

class AltaProductoPage extends StatefulWidget {
  @override
  _AltaProductoPageState createState() => _AltaProductoPageState();
}

class _AltaProductoPageState extends State<AltaProductoPage> {
  final _formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> categorias = [];
  final Dio dio = Dio();
  final TextEditingController saborController = TextEditingController();
  final TextEditingController precioController = TextEditingController();
  int? selectedCategoria;
  File? _image;

  @override
  void initState() {
    super.initState();
    _getData(); // Obtener las categorías al iniciar
  }

  @override
  void dispose() {
    saborController.dispose();
    precioController.dispose();
    super.dispose();
  }

  // Obtener las categorías desde el servidor
  Future<void> _getData() async {
    try {
      final categoriaResponse = await dio.get('${Config.apiBaseUrl}/categories');
      setState(() {
        categorias = List<Map<String, dynamic>>.from(categoriaResponse.data);
      });
    } catch (e) {
      print("Error al obtener los datos: $e");
    }
  }

  // Seleccionar una imagen desde la galería
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  // Verificar si el producto ya existe
  Future<bool> _verificarProductoExistente(String sabor, int idCategoria) async {
    try {
      final response = await dio.get('${Config.apiBaseUrl}/products2');
      if (response.statusCode == 200) {
        List<dynamic> productos = response.data;
        return productos.any((producto) =>
            producto['sabor'] == sabor && producto['id_categoria'] == idCategoria);
      }
    } catch (e) {
      print("Error al verificar el producto: $e");
    }
    return false;
  }

  // Limpiar los campos del formulario
  void _limpiarCampos() {
    setState(() {
      saborController.clear();
      precioController.clear();
      selectedCategoria = null;
      _image = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Alta de Producto'),
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
                  controller: saborController,
                  decoration: InputDecoration(
                    labelText: 'Sabor',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingrese el sabor';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                DropdownButtonFormField<int>(
                  value: selectedCategoria,
                  decoration: InputDecoration(
                    labelText: 'Categoría',
                    border: OutlineInputBorder(),
                  ),
                  items: categorias.map((categoria) {
                    return DropdownMenuItem<int>(
                      value: categoria["id"],
                      child: Text(categoria["categoria"]),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCategoria = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Por favor, seleccione una categoría';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: precioController,
                  decoration: InputDecoration(
                    labelText: 'Precio',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingrese el precio';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Por favor, ingrese un número válido';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                _image == null
                    ? Text('No image selected.')
                    : Image.file(_image!, height: 150),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _pickImage,
                  child: Text('Seleccionar Imagen'),
                ),
                SizedBox(height: 24.0),
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState?.validate() ?? false) {
                        if (_image == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Por favor, seleccione una imagen')),
                          );
                          return;
                        }

                        FormData formData = FormData.fromMap({
                          'sabor': saborController.text,
                          'id_categoria': selectedCategoria,
                          'precio': precioController.text,
                          'image': await MultipartFile.fromFile(_image!.path, filename: 'product_image.jpg'),
                        });

                        bool productoExistente = await _verificarProductoExistente(
                            saborController.text, selectedCategoria!);

                        if (productoExistente) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Ya existe un producto con la misma categoría y sabor')),
                          );
                        } else {
                          try {
                            final response = await dio.post(
                              '${Config.apiBaseUrl}/addProduct',
                              data: formData,
                            );

                            if (response.statusCode == 200) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Producto registrado con éxito')),
                              );
                              _limpiarCampos();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error al registrar el producto')),
                              );
                            }
                          } catch (e) {
                            print("Error al registrar el producto: $e");
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error de conexión')),
                            );
                          }
                        }
                      }
                    },
                    child: Text('Registrar Producto'),
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
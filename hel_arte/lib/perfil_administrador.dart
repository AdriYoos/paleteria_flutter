import 'package:flutter/material.dart';
import 'inventario_productos.dart';
import 'main.dart';
import 'registrar_gasto.dart'; // Asegúrate de importar la página correspondiente
import 'historial_inventario.dart'; // Importa la nueva página
import 'historial_financiero.dart'; // Importa la página de historial financiero

class AdminProfile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Hel-Arte',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          children: [
            _buildButton(context, Icons.archive_rounded, 'Inventario', 'Toca para registrar nueva venta', onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => InventarioPage()),
              );
            }),
            _buildButton(context, Icons.stacked_line_chart_outlined, 'Historial Financiero', 'Toca para consultar inventario', onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HistorialFinancieroPage()),
              );
            }),
            _buildButton(context, Icons.attach_money_rounded, 'Registrar Gasto', 'Toca para registrar un nuevo gasto', onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RegistrarGastoPage()),
              );
            }),
            _buildButton(context, Icons.inventory_rounded, 'Historial Inventario', 'Toca para ver el historial del inventario', onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HistorialInventarioPage()),
              );
            }),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.yellow[700],
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.exit_to_app), label: 'Salir'),
        ],
        onTap: (index) {
          if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MyLoginApp()),
            );
          }
        },
      ),
    );
  }

  Widget _buildButton(BuildContext context, IconData icon, String title, String subtitle, {VoidCallback? onTap, bool isHighlighted = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isHighlighted ? Colors.yellow[100] : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 5,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: isHighlighted ? Colors.yellow[700] : Colors.black),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
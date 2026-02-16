import 'package:flutter/material.dart';
import 'perfil_administrador.dart'; // Asegúrate de tener este archivo creado
import 'perfil_vendedor.dart'; // Archivo que mencionaste previamente

void main() {
  runApp(MyLoginApp());
}

class MyLoginApp extends StatelessWidget {
  const MyLoginApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatelessWidget {
  final TextEditingController userController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final String adminUser = "admin"; // Usuario administrador
  final String adminPassword = "admin123"; // Contraseña administrador
  final String sellerUser = "vendedor"; // Usuario vendedor
  final String sellerPassword = "vendedor123"; // Contraseña vendedor

  // Preguntas de seguridad y respuestas predefinidas
  late final Map<String, String> securityQuestions;
  late final Map<String, String> securityAnswers;

  LoginPage({super.key}) {
    // Inicializar los Map en el constructor
    securityQuestions = {
      adminUser: "¿Cuál es el nombre de tu primera mascota?",
      sellerUser: "¿Cuál es el nombre de tu ciudad natal?",
    };

    securityAnswers = {
      adminUser: "Max",
      sellerUser: "Madrid",
    };
  }

  void _login(BuildContext context) {
    String username = userController.text.trim();
    String password = passwordController.text.trim();

    if (username == adminUser && password == adminPassword) {
      // Redirige a la pantalla del perfil de administrador
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AdminProfile()),
      );
    } else if (username == sellerUser && password == sellerPassword) {
      // Redirige a la pantalla del perfil de vendedor
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SellerProfile()),
      );
    } else {
      // Muestra un mensaje de error si las credenciales son incorrectas
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Error"),
          content: Text("El perfil no existe. Inténtalo de nuevo."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  void _showPasswordRecoveryDialog(BuildContext context) {
    String username = userController.text.trim();
    TextEditingController answerController = TextEditingController();

    // Verifica si el usuario existe
    if (!securityQuestions.containsKey(username)) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Error"),
          content: Text("El usuario no existe."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("OK"),
            ),
          ],
        ),
      );
      return;
    }

    // Obtiene la pregunta de seguridad correspondiente al usuario
    String question = securityQuestions[username]!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Recuperar Contraseña"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(question),
            SizedBox(height: 10),
            TextField(
              controller: answerController,
              decoration: InputDecoration(
                labelText: 'Respuesta',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              String userAnswer = answerController.text.trim();
              String correctAnswer = securityAnswers[username]!;

              if (userAnswer == correctAnswer) {
                Navigator.pop(context);
                _showPassword(context);
              } else {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text("Error"),
                    content: Text("Respuesta incorrecta. Inténtalo de nuevo."),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text("OK"),
                      ),
                    ],
                  ),
                );
              }
            },
            child: Text("Verificar"),
          ),
        ],
      ),
    );
  }

  void _showPassword(BuildContext context) {
    String username = userController.text.trim();
    String password = "";

    if (username == adminUser) {
      password = adminPassword;
    } else if (username == sellerUser) {
      password = sellerPassword;
    } else {
      password = "Usuario no encontrado";
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Contraseña Recuperada"),
        content: Text("Tu contraseña es: $password"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.blue[100],
                  child: Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.blue[700],
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "Bienvenido al Hel-Arte",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: userController,
                  decoration: InputDecoration(
                    labelText: 'Usuario',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                SizedBox(height: 15),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Checkbox(value: false, onChanged: (value) {}),
                        Text("No soy un robot")
                      ],
                    ),
                    TextButton(
                      onPressed: () => _showPasswordRecoveryDialog(context),
                      child: Text(
                        "Recuperar Contraseña",
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _login(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 100),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    "Iniciar Sesión",
                    style: TextStyle(color: Colors.white, fontSize: 16),
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
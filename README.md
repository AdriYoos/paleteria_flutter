# 🍦 Sistema de Gestión para Paletería - Hel Arte

Sistema completo de gestión empresarial desarrollado para una paletería, que incluye control de inventario, ventas, finanzas y perfiles de usuario diferenciados. Aplicación móvil multiplataforma desarrollada en Flutter con backend en Node.js y MySQL.

## 📋 Tabla de Contenidos

- [Características](#-características)
- [Tecnologías](#-tecnologías)
- [Arquitectura del Sistema](#-arquitectura-del-sistema)
- [Estructura del Proyecto](#-estructura-del-proyecto)
- [Requisitos Previos](#-requisitos-previos)
- [Instalación y Configuración](#-instalación-y-configuración)


## ✨ Características

### 📱 Frontend (Aplicación Móvil Flutter)

#### Módulos Principales
- **Perfil Administrador** (`perfil_administrador.dart`)
  - Vista completa del sistema
  - Acceso a todas las funcionalidades
  - Gestión de inventario y finanzas
  
- **Perfil Vendedor** (`perfil_vendedor.dart`)
  - Interfaz simplificada para ventas
  - Consulta de inventario disponible
  - Registro rápido de transacciones

- **Inventario de Productos** (`inventario_productos.dart`)
  - Lista completa de productos disponibles
  - Consulta de stock en tiempo real
  - Información detallada de cada producto

- **Inventario para Vendedor** (`inventario_vendedor.dart`)
  - Vista optimizada para el proceso de venta
  - Stock actualizado en tiempo real
  - Interfaz amigable

- **Agregar Producto** (`agregar_producto.dart`)
  - Registro de nuevos productos
  - Carga de imágenes del producto
  - Validación de datos

- **Sistema de Ventas** (`ventas.dart`, `ventas2.dart`)
  - Registro de ventas múltiples
  - Cálculo automático de totales
  - Actualización automática de inventario

- **Registro de Gastos** (`registrar_gasto.dart`)
  - Control de gastos operativos
  - Categorización de gastos
  - Registro de montos y descripciones

- **Historiales** 
  - `historial_inventario.dart` - Movimientos de productos
  - `historial_financiero.dart` - Registro de transacciones financieras

### 🔧 Backend (API Node.js + Express)
- 🚀 **API RESTful** con endpoints no organizados
- 🗄️ **MySQL** como base de datos principal
- 📤 **Multer** para carga y gestión de imágenes de productos
- 🔄 **CORS** configurado para comunicación cliente-servidor
- 🐳 **Docker Compose** para orquestación de servicios
- 📁 **Sistema de archivos** para almacenamiento de imágenes (`uploads/`)

## 🛠 Tecnologías

### Frontend
- **Flutter** 3.x - Framework de desarrollo multiplataforma
- **Dart** - Lenguaje de programación
- **image_picker** - Selección de imágenes desde galería/cámara
- **pdf** - Generación de documentos PDF
- **printing** - Impresión de documentos
- **http** - Cliente HTTP para comunicación con API
- **open_file** - Apertura de archivos en el dispositivo
- **path_provider** - Acceso a directorios del sistema

### Backend
- **Node.js** 16+ - Entorno de ejecución JavaScript
- **Express.js** 4.x - Framework web minimalista
- **MySQL2** - Driver de MySQL para Node.js
- **Multer** - Middleware para manejo de archivos multipart/form-data
- **CORS** - Middleware para habilitar CORS
- **Body-parser** - Parseo de cuerpos de peticiones
- **Nodemon** - Herramienta de desarrollo para auto-reinicio

### Infraestructura
- **Docker** - Contenedorización de servicios
- **Docker Compose** - Orquestación de contenedores
- **MySQL** 8.0 - Base de datos relacional


### 🔌 Comunicación Cliente-Servidor

**IMPORTANTE**: La aplicación móvil y el backend deben estar en la **misma red local** para comunicarse.

- **Frontend**: Realiza peticiones HTTP al backend
- **Backend**: Expone API REST en puerto 3000
- **Base de datos**: MySQL expuesto en puerto 3309 (contenedor Docker)

## 📋 Requisitos Previos

### Para desarrollo local (opción 1):
- ✅ **Flutter SDK** (3.0 o superior)
- ✅ **Node.js** (16.x o superior) y npm
- ✅ **MySQL** (8.0 o superior)
- ✅ **Android Studio** (para Android) o **Xcode** (para iOS)
- ✅ **Git**
- ✅ Dispositivo Android/iOS o emulador configurado

### Para deployment con Docker (opción 2 - recomendada):
- ✅ **Docker** (20.10 o superior)
- ✅ **Docker Compose** (2.0 o superior)
- ✅ **Node.js** (16.x o superior) y npm
- ✅ **Flutter SDK** (3.0 o superior)

### Requisitos de red:
- 📡 **Misma red local**: El dispositivo móvil y el servidor backend deben estar en la misma red WiFi
- 🔌 Puerto **3000** disponible para el backend
- 🔌 Puerto **3309** disponible para MySQL (Docker)

## 🚀 Instalación y Configuración

### Paso 1: Clonar el repositorio

```bash
git clone https://github.com/tu-usuario/hel-arte-paleteria.git
cd hel-arte-paleteria
```

### Paso 2: Iniciar servicios con Docker

#### 2.1 Levantar los contenedores Docker

Primero, navega a la carpeta del proyecto ./Paleteria_APp y levanta los servicios (MySQL y otros):

```bash
cd Paleteria_APp
docker-compose up -d
```

Esto iniciará:
- ✅ Contenedor de MySQL en puerto 3309
- ✅ Volúmenes persistentes para la base de datos

Verifica que los contenedores estén corriendo:
```bash
docker ps
```
Tambien se agrega la base de datos, asi que subela a MySQL

#### 2.2 Levantar el servicio de Node.js

Ahora dirígete a la carpeta ./Paleteria_APp/backend y ejecuta:

```bash
npm install  # Instala las dependencias (solo la primera vez)
npm start    # Inicia el servidor
```

El servidor estará corriendo en `http://localhost:3000`


### Paso 3: Configurar la base de datos

Si es la primera vez que ejecutas el proyecto, necesitas importar la base de datos que se encuentra en la carpeta Paleteria_APp

### Paso 4: Configurar la aplicación Flutter

Debes modificar la IP en el archivo de configuración para que apunte a tu servidor backend.

Edita el archivo `/hel_arte/lib/utils/config.dart`:

```dart
// config.dart

class Config {
  static const String apiBaseUrl = 'http://10.16.121.136:3000';
  //                                      ^^^^^^^^^^^^^^^^
  //                               Cambia esto por tu IP local
}
```

#### 4.1 Verificar la conexión de red

**REQUISITO CRÍTICO**: Tu dispositivo móvil (o emulador) y tu computadora deben estar conectados a la **misma red WiFi**.

```
┌─────────────┐           ┌──────────────┐
│  Teléfono   │  WiFi     │  Computadora │
│   Android   │ <──────>  │   (Backend)  │
│             │  Red:     │              │
│ 10.16.121.X │  10.16.   │ 10.16.121.136│
└─────────────┘  121.0/24 └──────────────┘
```

### Paso 5: Ejecutar la aplicación Flutter

#### 5.1 Conectar tu dispositivo o iniciar emulador

**Opción A - Dispositivo físico:**
1. Habilita "Depuración USB" en tu teléfono
2. Conecta el dispositivo por USB
3. Verifica: `flutter devices`

**Opción B - Emulador:**
1. Abre Android Studio
2. Inicia un emulador AVD
3. Verifica: `flutter devices`

#### 5.2 Ejecutar main.dart

Desde la carpeta `hel_arte/`, ejecuta:

```bash
flutter run
```

O si tienes múltiples dispositivos:

```bash
flutter run -d <device_id>
```

La aplicación se compilará e instalará en tu dispositivo.

### Paso 6: Verificar que todo funciona

1. ✅ Abre la aplicación en tu dispositivo
2. ✅ Intenta acceder como administrador o vendedor
3. ✅ Verifica que puedas ver el inventario (esto confirma que la API funciona)
4. ✅ Intenta agregar un producto con imagen

Si hay problemas de conexión:
- Verifica que el backend esté corriendo: `http://TU_IP:3000` desde un navegador
- Revisa los logs del backend: `npm start` debería mostrar las peticiones
- Confirma que ambos dispositivos estén en la misma red
- Desactiva temporalmente el firewall de tu computadora


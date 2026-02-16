-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: mysql:3306
-- Tiempo de generación: 16-02-2026 a las 06:37:55
-- Versión del servidor: 8.0.36
-- Versión de PHP: 8.2.8

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `Paleteria_Base_datos`
--

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `Categoria`
--

CREATE TABLE `Categoria` (
  `id` int NOT NULL,
  `categoria` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `Categoria`
--

INSERT INTO `Categoria` (`id`, `categoria`) VALUES
(1, 'Agua'),
(2, 'Crema');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `Gasto`
--

CREATE TABLE `Gasto` (
  `id` int NOT NULL,
  `descripcion` tinytext,
  `unidades` float DEFAULT NULL,
  `fecha` date DEFAULT NULL,
  `total` float DEFAULT NULL,
  `id_tipo` int DEFAULT NULL,
  `precio_unidad` float NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `Gasto`
--

INSERT INTO `Gasto` (`id`, `descripcion`, `unidades`, `fecha`, `total`, `id_tipo`, `precio_unidad`) VALUES
(1, 'pago empledo ', 1, '2025-02-07', 1500, 1, 1500),
(2, 'compra de crema ', 5, '2025-02-07', 132.5, 2, 26.5),
(3, 'pago a empleado local', 2, '2025-02-07', 2900, 1, 1450),
(4, 'descripcion', 1, '2025-02-07', 1500, 1, 1500),
(5, 'coco', 5, '2025-02-07', 250, 2, 50),
(6, 'leche ', 5, '2025-02-09', 150, 2, 30),
(7, 'compra de producto', 100, '2025-02-11', 10000, 2, 100),
(8, 'compra de materia prima', 15, '2025-02-11', 300, 2, 20),
(9, 'compraa', 10, '2025-02-11', 10, 2, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `Historial_Stock`
--

CREATE TABLE `Historial_Stock` (
  `id` int NOT NULL,
  `fecha` date DEFAULT NULL,
  `id_producto` int DEFAULT NULL,
  `descripcion` varchar(50) NOT NULL,
  `cantidad` int NOT NULL DEFAULT '0',
  `id_categoria` int NOT NULL,
  `sabor` varchar(40) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `Historial_Stock`
--

INSERT INTO `Historial_Stock` (`id`, `fecha`, `id_producto`, `descripcion`, `cantidad`, `id_categoria`, `sabor`) VALUES
(1, '2025-02-07', 67, 'Se agregó producto', 0, 1, 'arrox'),
(2, NULL, 67, 'Se modificó el precio de 15 a 14', 0, 1, 'arrox'),
(3, '2025-02-07', 67, 'Se modificó el precio de 14 a 15', 0, 1, 'arrox'),
(4, '2025-02-07', 67, 'Se modificó la cantidad de 0 a 6', 0, 1, 'arrox'),
(5, '2025-02-07', 67, 'Se modificó la imagen', 6, 1, 'arrox'),
(6, '2025-02-07', 68, 'Se agregó producto', 0, 2, 'chocolate'),
(7, '2025-02-07', 69, 'Se agregó producto', 0, 2, 'leche quemada'),
(8, '2025-02-07', 69, 'Se elimino', 0, 2, 'leche quemada'),
(9, '2025-02-07', 67, 'Se elimino', 6, 1, 'arrox'),
(10, '2025-02-07', 68, 'Se elimino', 0, 2, 'chocolate'),
(11, '2025-02-07', 70, 'Se agregó producto', 0, 2, 'fresas con crema '),
(12, '2025-02-07', 71, 'Se agregó producto', 0, 2, 'vainilla '),
(13, '2025-02-07', 72, 'Se agregó producto', 0, 1, 'limon'),
(19, '2025-02-07', 74, 'Se agregó producto', 0, 1, 'arandano'),
(20, '2025-02-07', 71, 'Se modificó el precio de 12 a 15', 0, 2, 'vainilla '),
(21, '2025-02-07', 71, 'Se modificó la imagen', 0, 2, 'vainilla '),
(22, '2025-02-07', 71, 'Se modificó la cantidad de 0 a 5', 5, 2, 'vainilla '),
(23, '2025-02-07', 75, 'Se agregó producto', 0, 2, 'leche quemada '),
(24, '2025-02-07', 75, 'Se elimino', 0, 2, 'leche quemada '),
(27, '2025-02-10', 70, 'Se modificó la cantidad de 8 a 7', 7, 2, 'fresas con crema '),
(31, '2025-02-11', 74, 'Se modificó la cantidad de 0 a 20', 20, 1, 'arandano'),
(32, '2025-02-11', 72, 'Se modificó la cantidad de 0 a 20', 20, 1, 'limon'),
(33, '2025-02-11', 71, 'Se modificó la cantidad de 1 a 20', 20, 2, 'vainilla '),
(34, '2025-02-11', 70, 'Se modificó la cantidad de 0 a 20', 20, 2, 'fresas con crema '),
(35, '2025-02-11', 70, 'Se modificó la cantidad de 9 a 8 por perdida', 8, 2, 'fresas con crema '),
(37, '2025-02-11', 71, 'Se modificó la cantidad de 12 a 11 por perdida', 11, 2, 'vainilla '),
(38, '2025-02-11', 70, 'Se modificó la cantidad de 8 a 7 por perdida', 7, 2, 'fresas con crema '),
(39, '2025-02-11', 71, 'Se modificó la cantidad de 11 a 10 por perdida', 10, 2, 'vainilla '),
(40, '2025-02-11', 71, 'Se modificó la cantidad', 10, 2, 'vainilla'),
(45, '2025-02-11', 72, 'Se elimino', 6, 1, 'limon'),
(46, '2025-02-11', 74, 'Se elimino', 6, 1, 'arandano'),
(47, '2025-02-11', 70, 'Se elimino', 7, 2, 'fresas con crema '),
(48, '2025-02-11', 71, 'Se elimino', 6, 2, 'vainilla '),
(49, '2025-02-11', 77, 'Se agregó producto', 0, 1, 'Mango'),
(50, '2025-02-11', 78, 'Se agregó producto', 0, 1, 'Guayaba'),
(51, '2025-02-11', 79, 'Se agregó producto', 0, 1, 'Tamarindo'),
(52, '2025-02-11', 80, 'Se agregó producto', 0, 2, 'Chocolate'),
(53, '2025-02-11', 81, 'Se agregó producto', 0, 1, 'Arándano '),
(54, '2025-02-11', 77, 'Se modificó la cantidad de 0 a 30', 30, 1, 'Mango'),
(55, '2025-02-11', 78, 'Se modificó la cantidad de 0 a 30', 30, 1, 'Guayaba'),
(56, '2025-02-11', 79, 'Se modificó la cantidad de 0 a 30', 30, 1, 'Tamarindo'),
(57, '2025-02-11', 81, 'Se modificó la cantidad de 0 a 30', 30, 1, 'Arándano '),
(58, '2025-02-11', 80, 'Se modificó la cantidad de 0 a 30', 30, 2, 'Chocolate'),
(59, '2025-02-11', 78, 'Se modificó la cantidad de 30 a 29 por perdida', 29, 1, 'Guayaba'),
(60, '2025-02-11', 82, 'Se agregó producto', 0, 2, 'Pistache'),
(61, '2025-02-11', 82, 'Se modificó la cantidad de 0 a 14', 14, 2, 'Pistache'),
(62, '2025-02-11', 83, 'Se agregó producto', 0, 1, 'mango'),
(63, '2025-02-11', 81, 'Se elimino', 24, 1, 'Arándano '),
(64, '2025-02-11', 82, 'Se elimino', 11, 2, 'Pistache'),
(65, '2025-02-11', 77, 'Se modificó el precio de 20 a 25', 22, 1, 'Mango'),
(66, '2025-02-11', 77, 'Se modificó la imagen', 22, 1, 'Mango'),
(67, '2025-02-11', 84, 'Se agregó producto', 0, 2, 'pistache '),
(68, '2025-02-11', 84, 'Se modificó la imagen', 0, 2, 'pistache '),
(69, '2025-02-11', 77, 'Se modificó la cantidad de 0 a 20', 20, 1, 'Mango'),
(70, '2025-02-11', 78, 'Se modificó la cantidad de 0 a 30', 30, 1, 'Guayaba'),
(71, '2025-02-11', 79, 'Se modificó la cantidad de 0 a 15', 15, 1, 'Tamarindo'),
(72, '2025-02-11', 80, 'Se modificó la cantidad de 0 a 50', 50, 2, 'Chocolate'),
(73, '2025-02-11', 85, 'Se agregó producto', 0, 2, 'nuez'),
(74, '2025-02-11', 85, 'Se modificó la cantidad de 0 a 25', 25, 2, 'nuez'),
(75, '2025-02-11', 83, 'Se elimino', 0, 1, 'mango'),
(76, '2025-02-11', 84, 'Se elimino', 0, 2, 'pistache ');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `Producto`
--

CREATE TABLE `Producto` (
  `codigo` int NOT NULL,
  `sabor` varchar(40) DEFAULT NULL,
  `id_categoria` int DEFAULT NULL,
  `precio` float DEFAULT NULL,
  `url_image` varchar(40) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `Producto`
--

INSERT INTO `Producto` (`codigo`, `sabor`, `id_categoria`, `precio`, `url_image`) VALUES
(77, 'Mango', 1, 25, '/uploads/1739290254623-540490131.jpg'),
(78, 'Guayaba', 1, 20, '/uploads/1739276474277-207625795.jpg'),
(79, 'Tamarindo', 1, 25, '/uploads/1739276490460-349060431.jpg'),
(80, 'Chocolate', 2, 25, '/uploads/1739276500093-816023438.jpg'),
(85, 'nuez', 2, 25, '/uploads/1739291402116-390492171.jpg');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `Stock`
--

CREATE TABLE `Stock` (
  `id` int NOT NULL,
  `stock` int DEFAULT '0',
  `perdidas` int DEFAULT '0',
  `id_producto` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `Stock`
--

INSERT INTO `Stock` (`id`, `stock`, `perdidas`, `id_producto`) VALUES
(44, 5, 1, 76),
(45, 0, 0, 77),
(46, 0, 1, 78),
(47, 0, 0, 79),
(48, 0, 0, 80),
(53, 0, 0, 85);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `Sub_Venta`
--

CREATE TABLE `Sub_Venta` (
  `id` int NOT NULL,
  `id_producto` int DEFAULT NULL,
  `sub_total` float DEFAULT NULL,
  `num_venta` int NOT NULL DEFAULT '0',
  `id_stock` int NOT NULL,
  `precio_unidad` int NOT NULL,
  `stock_tem` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `Sub_Venta`
--

INSERT INTO `Sub_Venta` (`id`, `id_producto`, `sub_total`, `num_venta`, `id_stock`, `precio_unidad`, `stock_tem`) VALUES
(64, 72, 30, 16, 40, 15, 1),
(72, 76, 3, 16, 44, 1, 3),
(97, 72, 15, 17, 40, 15, 1),
(106, 72, 15, 17, 40, 15, 1),
(107, 74, 14, 17, 42, 14, 1),
(108, 72, 15, 17, 40, 15, 1),
(109, 74, 14, 17, 42, 14, 1),
(110, 72, 15, 17, 40, 15, 1),
(111, 74, 14, 17, 42, 14, 1),
(112, 74, 28, 17, 42, 14, 2),
(113, 72, 15, 17, 40, 15, 1),
(114, 74, 14, 17, 42, 14, 1),
(173, 71, 30, 9, 39, 15, 2),
(174, 71, 30, 10, 39, 15, 2),
(175, 72, 30, 10, 40, 15, 2),
(176, 74, 14, 10, 42, 14, 1),
(177, 74, 14, 17, 42, 14, 1),
(178, 72, 15, 17, 40, 15, 1),
(179, 77, 40, 17, 45, 20, 2),
(180, 79, 25, 17, 47, 25, 1),
(181, 81, 75, 16, 49, 25, 3),
(182, 80, 50, 16, 48, 25, 2),
(183, 79, 25, 16, 47, 25, 1),
(184, 77, 60, 11, 45, 20, 3),
(185, 80, 75, 12, 48, 25, 3),
(186, 81, 25, 12, 49, 25, 1),
(187, 78, 20, 13, 46, 20, 1),
(188, 79, 25, 13, 47, 25, 1),
(189, 81, 25, 13, 49, 25, 1),
(190, 82, 60, 18, 50, 20, 3),
(191, 81, 25, 18, 49, 25, 1),
(192, 77, 60, 14, 45, 20, 3),
(193, 77, 250, 15, 45, 25, 10),
(194, 79, 250, 15, 47, 25, 10),
(195, 78, 200, 15, 46, 20, 10),
(196, 80, 250, 15, 48, 25, 10),
(202, 79, 25, 18, 47, 25, 1),
(203, 78, 20, 18, 46, 20, 1),
(208, 77, 250, 19, 45, 25, 10),
(209, 78, 200, 19, 46, 20, 10),
(210, 79, 400, 20, 47, 25, 16),
(211, 80, 250, 20, 48, 25, 10),
(212, 78, 140, 21, 46, 20, 7),
(213, 80, 125, 21, 48, 25, 5),
(214, 77, 50, 1, 45, 25, 2),
(215, 77, 500, 22, 45, 25, 20),
(216, 78, 600, 22, 46, 20, 30),
(217, 80, 1250, 22, 48, 25, 50),
(218, 85, 625, 22, 53, 25, 25),
(219, 79, 375, 22, 47, 25, 15);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `Tipo_Gasto`
--

CREATE TABLE `Tipo_Gasto` (
  `id` int NOT NULL,
  `tipo` varchar(40) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `Tipo_Gasto`
--

INSERT INTO `Tipo_Gasto` (`id`, `tipo`) VALUES
(1, 'pago empleado'),
(2, 'compra de crema');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `Venta`
--

CREATE TABLE `Venta` (
  `id` int NOT NULL,
  `id_sub_venta` int DEFAULT NULL,
  `total` float DEFAULT NULL,
  `fecha` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `Venta`
--

INSERT INTO `Venta` (`id`, `id_sub_venta`, `total`, `fecha`) VALUES
(9, NULL, 30, '2025-02-11'),
(10, NULL, 74, '2025-02-11'),
(11, NULL, 60, '2025-02-11'),
(12, NULL, 100, '2025-02-11'),
(13, NULL, 70, '2025-02-11'),
(14, NULL, 60, '2025-02-11'),
(15, NULL, 950, '2025-02-11'),
(16, NULL, 150, '2025-02-11'),
(17, NULL, 65, '2025-02-11'),
(18, NULL, 45, '2025-02-11'),
(19, NULL, 450, '2025-02-11'),
(20, NULL, 650, '2025-02-11'),
(21, NULL, 265, '2025-02-11'),
(22, NULL, 3350, '2025-02-11');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `venta_tem`
--

CREATE TABLE `venta_tem` (
  `id` int NOT NULL,
  `id_sub_venta` int DEFAULT NULL,
  `total` float NOT NULL,
  `fecha` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `venta_tem`
--

INSERT INTO `venta_tem` (`id`, `id_sub_venta`, `total`, `fecha`) VALUES
(1, NULL, 50, '2025-02-11');

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `Categoria`
--
ALTER TABLE `Categoria`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `Gasto`
--
ALTER TABLE `Gasto`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_tipo` (`id_tipo`);

--
-- Indices de la tabla `Historial_Stock`
--
ALTER TABLE `Historial_Stock`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `Producto`
--
ALTER TABLE `Producto`
  ADD PRIMARY KEY (`codigo`),
  ADD KEY `id_categoria` (`id_categoria`);

--
-- Indices de la tabla `Stock`
--
ALTER TABLE `Stock`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_producto` (`id_producto`);

--
-- Indices de la tabla `Sub_Venta`
--
ALTER TABLE `Sub_Venta`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_producto` (`id_producto`),
  ADD KEY `id_stock` (`id_stock`);

--
-- Indices de la tabla `Tipo_Gasto`
--
ALTER TABLE `Tipo_Gasto`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `Venta`
--
ALTER TABLE `Venta`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_sub_venta` (`id_sub_venta`);

--
-- Indices de la tabla `venta_tem`
--
ALTER TABLE `venta_tem`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `Categoria`
--
ALTER TABLE `Categoria`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `Gasto`
--
ALTER TABLE `Gasto`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT de la tabla `Historial_Stock`
--
ALTER TABLE `Historial_Stock`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=77;

--
-- AUTO_INCREMENT de la tabla `Producto`
--
ALTER TABLE `Producto`
  MODIFY `codigo` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=86;

--
-- AUTO_INCREMENT de la tabla `Stock`
--
ALTER TABLE `Stock`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=54;

--
-- AUTO_INCREMENT de la tabla `Sub_Venta`
--
ALTER TABLE `Sub_Venta`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=220;

--
-- AUTO_INCREMENT de la tabla `Tipo_Gasto`
--
ALTER TABLE `Tipo_Gasto`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `Venta`
--
ALTER TABLE `Venta`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;

--
-- AUTO_INCREMENT de la tabla `venta_tem`
--
ALTER TABLE `venta_tem`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `Gasto`
--
ALTER TABLE `Gasto`
  ADD CONSTRAINT `Gasto_ibfk_1` FOREIGN KEY (`id_tipo`) REFERENCES `Tipo_Gasto` (`id`);

--
-- Filtros para la tabla `Producto`
--
ALTER TABLE `Producto`
  ADD CONSTRAINT `Producto_ibfk_1` FOREIGN KEY (`id_categoria`) REFERENCES `Categoria` (`id`);

--
-- Filtros para la tabla `Venta`
--
ALTER TABLE `Venta`
  ADD CONSTRAINT `Venta_ibfk_1` FOREIGN KEY (`id_sub_venta`) REFERENCES `Sub_Venta` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

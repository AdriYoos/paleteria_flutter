import cors from 'cors';
import express from 'express';
import db from './db.js';
import multer from 'multer'; // Importar multer
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
import fs from 'fs'; 

const app = express();
app.use(cors());
app.use(express.json());

// const express = require('express');
// const app = express();
// const path = require('path');

// // Configurar Express para servir archivos estáticos
// app.use('/images', express.static(path.join(__dirname, 'uploads')));


// Configuración de Multer para guardar archivos en la carpeta "uploads"
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'uploads/'); // Guardar en la carpeta "uploads"
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1e9);
    cb(null, uniqueSuffix + path.extname(file.originalname)); // Nombre único para el archivo
  },
});

const upload = multer({ storage: storage });

// Crear la carpeta "uploads" si no existe

if (!fs.existsSync('uploads')) {
  fs.mkdirSync('uploads');
}

// Servir archivos estáticos desde la carpeta "uploads"
app.use('/uploads', express.static('uploads'));

app.listen(3000, () => {
  console.log("Server Listening on port 3000");
});

app.get('/', (req, res) => {
  res.send('We are ON');
});

// Obtener la fecha actual
app.get('/date', async (req, res) => {
  const result = await db.query('SELECT NOW()');
  res.json(result[0]);
});

// Obtener lista de productos
app.get('/products', async (req, res) => {
  try {
    const result = await db.query(
      'SELECT Producto.codigo, Producto.sabor, Categoria.categoria, Producto.precio, Stock.stock ' +
      'FROM Producto ' +
      'INNER JOIN Categoria ON Categoria.id = Producto.id_categoria ' +
      'LEFT JOIN Stock ON Stock.id_producto = Producto.codigo;'
    );
    res.json(result[0]);
  } catch (error) {
    res.status(500).json({ error: error.message });
    console.log("Error al obtener productos y stock: ", error.message);
  }
});

app.get('/products3', async (req, res) => {
  try {
    const result = await db.query(
      'SELECT Producto.codigo, Producto.sabor, Categoria.categoria, Producto.precio, Producto.url_image, Stock.stock ' +
      'FROM Producto ' +
      'INNER JOIN Categoria ON Categoria.id = Producto.id_categoria ' +
      'LEFT JOIN Stock ON Stock.id_producto = Producto.codigo;'
    );
    res.json(result[0]);
  } catch (error) {
    res.status(500).json({ error: error.message });
    console.log("Error al obtener productos y stock: ", error.message);
  }
});

// Obtener lista de productos (alternativa)
app.get('/products2', async (req, res) => {
  try {
    const result = await db.query(
      'SELECT Producto.codigo, Producto.sabor, Categoria.categoria, Producto.precio, Producto.id_categoria ' +
      'FROM Producto ' +
      'INNER JOIN Categoria ON Categoria.id = Producto.id_categoria;'
    );
    if (result.length > 0 && result[0].length > 0) {
      res.json(result[0]);
    } else {
      res.status(404).json({ message: 'No se encontraron productos.' });
    }
  } catch (error) {
    console.error('Error al obtener los productos:', error);
    res.status(500).json({ message: 'Error interno del servidor.' });
  }
});

// Obtener categorías
app.get('/categories', async (req, res) => {
  const result = await db.query('SELECT * FROM Categoria;');
  res.json(result[0]);
});

// Agregar producto con imagen
app.post('/addProduct', upload.single('image'), async (req, res) => {
  const { sabor, id_categoria, precio } = req.body;
  const imagePath = req.file ? `/uploads/${req.file.filename}` : null; // Ruta de la imagen
  
  try {
    const [productResult] = await db.query(
      'INSERT INTO `Producto` (`sabor`, `id_categoria`, `precio`, `url_image`) VALUES (?, ?, ?, ?);',
      [sabor, id_categoria, precio, imagePath]
    );
    const productId = productResult.insertId;

    await db.query('INSERT INTO `Stock` (`id_producto`) VALUES (?);', [productId]);

    await db.query(
      'INSERT INTO `Historial_Stock` (`fecha`, `id_producto`, `descripcion`, `cantidad`, `id_categoria`, `sabor`) VALUES (CURDATE(), ?, ?, ?, ?, ?);',
      [productId, 'Se agregó producto', 0, id_categoria, sabor]
    );

    res.json({ status: 'success', id: productId, imageUrl: imagePath });
    console.log(productId);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});



app.post('/addProductNulll', async (req, res) => {
  const { id, sabor, categoria, precio } = req.body;
  try {
    const [result] = await db.query('INSERT INTO `Producto` (`codigo`, `id_sabor`, `id_categoria`, `precio`) VALUES (?, ?, ?, ?);', [id, sabor, categoria, precio]);
    res.json({ status: 'success', id: result.insertId });
  } catch (error) {
    res.status(500).json({ error: error.messge });
  }
});


//POST

//RegistrarVenta

app.post('/addSale', async (req, res) => {
  const { id, total, fecha } = req.body;
  try {
    const [result] = await db.query('INSERT INTO `Venta` (`id`, `total`, `fecha`) VALUES (?, ?, ?);', [210, 123, '2025-01-21']);
    res.json({ status: 'success', id: result.insertId });
  } catch (error) {
    res.status(500).json({ error: error.messge });
    console.log("HOolajakjajajaaskjbdalisbdalñkjsdbalkjbdañ");
  }}
);

//AgregarStock OK
app.post('/addStock', async (req, res) => {

  console.log(req.body);
  const { id_product, amountToAdd } = req.body;
  try {
    console.log(id_product, amountToAdd);
    const result = await db.query("UPDATE `Stock`SET stock = stock + ?  WHERE `Stock`.`id_producto` = ?; ", [amountToAdd, id_product]);
    res.json({ status: 'success', id: result.insertId });
  } catch (error) {
    res.status(500).json({ error: error.messge });
  }
});

//EliminarStock OK

app.post('/deleteStock', async (req, res) => {

  console.log(req.body);
  const { id_product, amountToDelete } = req.body;
  try {
    console.log(id_product, amountToDelete);
    const result = await db.query("UPDATE `Stock`SET stock = stock - ?  WHERE `Stock`.`id_producto` = ?; ", [amountToDelete, id_product]);
    res.json({ status: 'success', id: result.insertId });
  } catch (error) {
    res.status(500).json({ error: error.messge });
  }

  //console.log("delete good");
});


//TODO: ModificarImagen de producto
//ActualizarProducto
app.post('/updateProduct', async (req, res) => {
  console.log(req.body);
  const { id_product, precio } = req.body;
  try {
    const [productData] = await db.query(
      'SELECT `sabor`, `id_categoria`, `precio` FROM `Producto` WHERE `codigo` = ?;',
      [id_product]
    );

    if (!productData.length) {
      return res.status(404).json({ error: 'Producto no encontrado' });
    }

    const { sabor, id_categoria, precio: precio_anterior } = productData[0];

    const [stockData] = await db.query(
      'SELECT `stock` FROM `Stock` WHERE `id_producto` = ?;',
      [id_product]
    );
    
    const cantidad = stockData.length ? stockData[0].stock : 0;

    await db.query(
      'INSERT INTO `Historial_Stock` (`fecha`,`id_producto`, `descripcion`, `cantidad`, `id_categoria`, `sabor`) VALUES (CURDATE(),?, ?, ?, ?, ?);',
      [id_product, `Se modificó el precio de ${precio_anterior} a ${precio}`, cantidad, id_categoria, sabor]
    );

    await db.query(
      'UPDATE `Producto` SET `precio` = ? WHERE `codigo` = ?;',
      [precio, id_product]
    );
    
    res.json({ status: 'success', id: id_product });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});


app.post('/updateStock', async (req, res) => {
  console.log(req.body);
  const { id_product, stock } = req.body;

  try {
    const [productData] = await db.query(
      'SELECT `sabor`, `id_categoria`, `precio` FROM `Producto` WHERE `codigo` = ?;',
      [id_product]
    );
    if (!productData.length) {
      return res.status(404).json({ error: 'Producto no encontrado' });
    }

    const { sabor, id_categoria, precio} = productData[0];
    const [stockData] = await db.query(
      'SELECT `stock` FROM `Stock` WHERE `id_producto` = ?;',
      [id_product]
    );
    const cantidad = stockData.length ? stockData[0].stock : 0;

    await db.query(
      'INSERT INTO `Historial_Stock` (`fecha`,`id_producto`, `descripcion`, `cantidad`, `id_categoria`, `sabor`) VALUES (CURDATE(),?, ?, ?, ?, ?);',
      [id_product, `Se modificó la cantidad de ${cantidad} a ${stock}`, stock, id_categoria, sabor]
    );

    const [result] = await db.query(
      'UPDATE `Stock` SET `stock` = ? WHERE `id_producto` = ?;',
      [stock, id_product]
    );

    if (result.affectedRows > 0) {
      res.json({ status: 'success', message: 'Stock actualizado correctamente' });
    } else {
      res.status(404).json({ status: 'error', message: 'Producto no encontrado' });
    }
  } catch (error) {
    console.error("Error al actualizar el stock:", error.message);
    res.status(500).json({ status: 'error', message: error.message });
  }
});

app.post('/updateStock2', async (req, res) => {
  console.log(req.body);
  const { id_product, stock } = req.body;

  try {
    // Obtener detalles del producto
    const [productData] = await db.query(
      'SELECT `sabor`, `id_categoria`, `precio` FROM `Producto` WHERE `codigo` = ?;',
      [id_product]
    );
    if (!productData.length) {
      return res.status(404).json({ error: 'Producto no encontrado' });
    }

    const { sabor, id_categoria, precio } = productData[0];

    // Obtener el stock actual y perdidas actuales
    const [stockData] = await db.query(
      'SELECT `stock`, `perdidas` FROM `Stock` WHERE `id_producto` = ?;',
      [id_product]
    );
    const cantidad = stockData.length ? stockData[0].stock : 0;

    // Registrar en historial
    await db.query(
      'INSERT INTO `Historial_Stock` (`fecha`,`id_producto`, `descripcion`, `cantidad`, `id_categoria`, `sabor`) VALUES (CURDATE(),?, ?, ?, ?, ?);',
      [id_product, `Se modificó la cantidad de ${cantidad} a ${stock} por perdida`, stock, id_categoria, sabor]
    );
    console.log("llegue aqui ",id_product,stock,id_categoria,sabor)
    // Actualizar stock y perdidas
    const [result] = await db.query(
      'UPDATE `Stock` SET `stock` = ?, `perdidas` = `perdidas` + 1 WHERE `id_producto` = ?;',
      [stock, id_product]
    );

    if (result.affectedRows > 0) {
      res.json({ status: 'success', message: 'Stock y perdidas actualizados correctamente' });
    } else {
      res.status(404).json({ status: 'error', message: 'Producto no encontrado' });
    }
  } catch (error) {
    console.error("Error al actualizar el stock:", error.message);
    res.status(500).json({ status: 'error', message: error.message });
  }
});



//DELETE 

//EliminarProducto

app.delete('/deleteProduct', async (req, res) => {
  const { id } = req.body;

  try {
    // Iniciar una transacción para asegurar la integridad de los datos
    await db.query('START TRANSACTION');

    const [productData] = await db.query(
      'SELECT `sabor`, `id_categoria`, `precio` FROM `Producto` WHERE `codigo` = ?;',
      [id]
    );
    if (!productData.length) {
      return res.status(404).json({ error: 'Producto no encontrado' });
    }

    const { sabor, id_categoria, precio} = productData[0];
    const [stockData] = await db.query(
      'SELECT `stock` FROM `Stock` WHERE `id_producto` = ?;',
      [id]
    );
    const cantidad = stockData.length ? stockData[0].stock : 0;

    await db.query(
      'INSERT INTO `Historial_Stock` (`fecha`,`id_producto`, `descripcion`, `cantidad`, `id_categoria`, `sabor`) VALUES (CURDATE(),?, ?, ?, ?, ?);',
      [id, `Se elimino`, cantidad, id_categoria, sabor]
    );

    // Obtener la ruta de la imagen antes de eliminar el producto
    const [product] = await db.query('SELECT `url_image` FROM `Producto` WHERE `codigo` = ?;', [id]);

    if (product.length > 0 && product[0].url_image) {
      const imagePath = path.join(__dirname, '..', product[0].url_image); // Construir la ruta completa de la imagen

      // Verificar si el archivo existe y eliminarlo
      if (fs.existsSync(imagePath)) {
        fs.unlinkSync(imagePath); // Eliminar el archivo
        console.log(`Imagen eliminada: ${imagePath}`);
      } else {
        console.log(`La imagen no existe: ${imagePath}`);
      }
    }

    // Eliminar del stock
    await db.query('DELETE FROM `Stock` WHERE `id_producto` = ?;', [id]);

    // Eliminar el producto
    const result = await db.query('DELETE FROM `Producto` WHERE `codigo` = ?;', [id]);

    // Confirmar la transacción
    await db.query('COMMIT');

    res.json({ status: 'success', id: result.insertId });
    console.log("Producto y stock eliminados correctamente");
  } catch (error) {
    // Revertir la transacción en caso de error
    await db.query('ROLLBACK');
    res.status(500).json({ error: error.message });
    console.log("Error al eliminar producto y stock: ", error.message);
  }
});

app.post('/updateImage', upload.single('image'), async (req, res) => {
  const { id_product } = req.body;
  
  if (!id_product) {
    return res.status(400).json({ error: 'Falta el ID del producto' });
  }

  try {
    const [productData] = await db.query(
      'SELECT `sabor`, `id_categoria`, `precio` FROM `Producto` WHERE `codigo` = ?;',
      [id_product]
    );
    if (!productData.length) {
      return res.status(404).json({ error: 'Producto no encontrado' });
    }

    const { sabor, id_categoria, precio} = productData[0];

    const [stockData] = await db.query(
      'SELECT `stock` FROM `Stock` WHERE `id_producto` = ?;',
      [id_product]
    );
    const cantidad = stockData.length ? stockData[0].stock : 0;

    await db.query(
      'INSERT INTO `Historial_Stock` (`fecha`,`id_producto`, `descripcion`, `cantidad`, `id_categoria`, `sabor`) VALUES (CURDATE(),?, ?, ?, ?, ?);',
      [id_product, `Se modificó la imagen`, cantidad, id_categoria, sabor]
    );


    // Obtener la imagen actual del producto
    const [product] = await db.query('SELECT `url_image` FROM `Producto` WHERE `codigo` = ?;', [id_product]);

    if (product.length > 0 && product[0].url_image) {
      const oldImagePath = path.join(__dirname, '..', product[0].url_image);

      // Verificar si el archivo existe y eliminarlo
      if (fs.existsSync(oldImagePath)) {
        fs.unlinkSync(oldImagePath);
        console.log(`Imagen anterior eliminada: ${oldImagePath}`);
      } else {
        console.log(`No se encontró la imagen anterior: ${oldImagePath}`);
      }
    }

    // Guardar la nueva imagen
    const newImagePath = req.file ? `/uploads/${req.file.filename}` : null;
    if (!newImagePath) {
      return res.status(400).json({ error: 'No se recibió una nueva imagen' });
    }

    // Actualizar la URL en la base de datos
    await db.query('UPDATE `Producto` SET `url_image` = ? WHERE `codigo` = ?;', [newImagePath, id_product]);

    res.json({ status: 'success', imageUrl: newImagePath });
    console.log(`Imagen actualizada para producto ${id_product}: ${newImagePath}`);
  } catch (error) {
    console.error('Error al actualizar la imagen:', error);
    res.status(500).json({ error: error.message });
  }
});

// Obtener tipos de gasto
app.get('/tipos_gasto', async (req, res) => {
  const result= await db.query('SELECT * FROM Tipo_Gasto;');
  res.json(result[0])
});

// Registrar un gasto
app.post('/gastos', async (req, res) => {
  const { descripcion, unidades, fecha, total, id_tipo, precio_unidad } = req.body;

  try {
    const [result] = await db.query(
      'INSERT INTO `Gasto` (`descripcion`, `unidades`, `fecha`, `total`, `id_tipo`, `precio_unidad`) VALUES (?, ?, ?, ?, ?, ?);',
      [descripcion, unidades, fecha, total, id_tipo, precio_unidad]
    );

    const gastoId = result.insertId;
    console.log(gastoId);

    res.json({ success: true, id: gastoId });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/historial_Inventario', async (req, res) => {
  try {
    const { startDate, endDate } = req.query;

    let query = `
      SELECT 
        Historial_Stock.id,
        Historial_Stock.fecha,
        Historial_Stock.id_producto,
        Historial_Stock.descripcion,
        Historial_Stock.cantidad,
        Categoria.categoria,
        Historial_Stock.sabor
      FROM Historial_Stock
      INNER JOIN Categoria ON Categoria.id = Historial_Stock.id_categoria
    `;

    if (startDate && endDate) {
      query += ` WHERE Historial_Stock.fecha BETWEEN '${startDate}' AND '${endDate}'`;
    }

    const result = await db.query(query);
    res.json(result[0]);
  } catch (error) {
    res.status(500).json({ error: error.message });
    console.log("Error al obtener productos y stock: ", error.message);
  }
});

app.post('/addToSubVenta', async (req, res) => {
  const { id_producto, cantidad, num_venta } = req.body;

  try {
    // Verificar si hay suficiente stock
    const [stock] = await db.query('SELECT id, stock FROM Stock WHERE id_producto = ?', [id_producto]);
    console.log("Stock encontrado:", stock);

    if (stock.length === 0 || stock[0].stock < cantidad) {
      return res.status(400).json({ error: 'Stock insuficiente o producto no encontrado en stock' });
    }

    const id_stock = stock[0].id;
    const stock_actual = stock[0].stock;

    // Obtener el precio del producto
    const [producto] = await db.query('SELECT precio FROM Producto WHERE codigo = ?', [id_producto]);
    console.log("Producto encontrado:", producto);

    if (producto.length === 0) {
      return res.status(400).json({ error: 'Producto no encontrado' });
    }

    const precio_unidad = producto[0].precio;
    const sub_total = precio_unidad * cantidad;

    // Insertar en Sub_Venta y obtener el ID insertado
    const [result] = await db.query(
      'INSERT INTO Sub_Venta (id_producto, sub_total, num_venta, id_stock, precio_unidad, stock_tem) VALUES (?, ?, ?, ?, ?, ?)',
      [id_producto, sub_total, num_venta, id_stock, precio_unidad, cantidad]
    );

    const id_sub_venta = result.insertId;  // Obtener el ID generado

    // Reducir el stock usando el ID correcto
    await db.query('UPDATE Stock SET stock = stock - ? WHERE id = ?', [cantidad, id_stock]);
    console.log("Stock actualizado para id_stock:", id_stock);
    
    res.json({ 
      status: 'success', 
      message: 'Producto agregado a sub_venta y stock actualizado', 
      id_sub_venta: id_sub_venta  // Devolver el id_sub_venta 
    });

    console.log("Éxito:", id_producto, cantidad, num_venta, "ID SubVenta:", id_sub_venta);
  } catch (error) {
    res.status(500).json({ error: error.message });
    console.log("Error:", error.message);
  }
});





app.post('/removeFromSubVenta', async (req, res) => {
  const { id_sub_venta } = req.body;

  try {
    // Obtener los datos de la sub_venta
    const [subVenta] = await db.query('SELECT id_producto, stock_tem ,precio_unidad FROM Sub_Venta WHERE id = ?', [id_sub_venta]);
    if (subVenta.length === 0) {
      console.log("no se encontro")
      return res.status(404).json({ error: 'Sub_venta no encontrada' });
    }

    const id_producto = subVenta[0].id_producto;
    const stock_tem = subVenta[0].stock_tem;

    // Eliminar la sub_venta
    await db.query('DELETE FROM Sub_Venta WHERE id = ?', [id_sub_venta]);

    // Restaurar el stock
    await db.query('UPDATE Stock SET stock = stock + ? WHERE id_producto = ?', [stock_tem,id_producto]);
    console.log("termine bien")
    res.json({ status: 'success', message: 'Unidad eliminada y stock restaurado' });
  } catch (error) {
    res.status(500).json({ error: error.message });
    console.log("fallee")
  }
});

app.post('/disminuirSubVenta', async (req, res) => {
  const { id_sub_venta } = req.body;

  if (!id_sub_venta) {
    return res.status(400).json({ error: 'id_sub_venta es obligatorio' });
  }

  try {
    // Obtener la sub_venta actual
    const [subVenta] = await db.query('SELECT id_producto, stock_tem FROM Sub_Venta WHERE id = ?', [id_sub_venta]);
    console.log("subVenta no encontrada")

    if (subVenta.length === 0) {
      console.log("subVenta no encontrada")
      return res.status(404).json({ error: 'SubVenta no encontrada' });
    }

    const id_producto = subVenta[0].id_producto;
    const stock_tem = subVenta[0].stock_tem;

    if (stock_tem > 1) {
      // Disminuir en 1 el stock y el stock_tem
      await db.query('UPDATE Sub_Venta SET stock_tem = stock_tem - 1 WHERE id = ?', [id_sub_venta]);
      await db.query('UPDATE Stock SET stock = stock + 1 WHERE id_producto = ?', [id_producto]);
      return res.json({ status: 'success', message: 'Stock disminuido en 1' });
    } else {
      // Eliminar la sub_venta si el stock_tem llega a 0
      await db.query('DELETE FROM Sub_Venta WHERE id = ?', [id_sub_venta]);
      await db.query('UPDATE Stock SET stock = stock + 1 WHERE id_producto = ?', [id_producto]);
      return res.json({ status: 'success', message: 'SubVenta eliminada, stock_tem llegó a 0' });
    }
  } catch (error) {
    console.log("subVenta no existe ")
    res.status(500).json({ error: error.message });
  }
});


app.post('/saveAsPending', async (req, res) => {
  const { num_venta, total } = req.body;

  if (!num_venta || total === undefined) {
    return res.status(400).json({ error: 'num_venta y total son obligatorios' });
  }

  try {
    const [ventaExistente] = await db.query('SELECT id FROM venta_tem WHERE id = ?', [num_venta]);

    if (ventaExistente.length > 0) {
      await db.query('UPDATE venta_tem SET total = ? WHERE id = ?', [total, num_venta]);
      return res.json({ status: 'success', message: 'Venta actualizada', id_venta_tem: num_venta });
    }

    await db.query('INSERT INTO venta_tem (id, total, fecha) VALUES (?, ?, NOW())', [num_venta, total]);
    await db.query('UPDATE Sub_Venta SET num_venta = ? WHERE num_venta = ?', [num_venta, num_venta]);
    
    res.json({ status: 'success', message: 'Venta guardada como pendiente', id_venta_tem: num_venta });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});



app.post('/confirmVenta', async (req, res) => {
  const { id_venta_tem } = req.body;

  try {
    // Verificar si la venta temporal existe
    const [ventaTem] = await db.query('SELECT * FROM venta_tem WHERE id = ?', [id_venta_tem]);
    if (ventaTem.length === 0) {
      return res.status(404).json({ error: 'Venta temporal no encontrada' });
    }

    // Mover los datos a venta
    await db.query('INSERT INTO Venta (total, fecha) SELECT total, fecha FROM venta_tem WHERE id = ?', [id_venta_tem]);

    // Obtener el id de la venta confirmada
    const [venta] = await db.query('SELECT LAST_INSERT_ID() as id');
    const id_venta = venta[0].id;

    // Asociar las sub_ventas a la venta confirmada
    await db.query('UPDATE Sub_Venta SET num_venta = ? WHERE num_venta = ?', [id_venta, id_venta_tem]);

    // Eliminar la venta temporal
    await db.query('DELETE FROM venta_tem WHERE id = ?', [id_venta_tem]);

    res.json({ status: 'success', message: 'Venta confirmada', id_venta });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post('/productosPorVenta', async (req, res) => {
  const { num_venta } = req.body;  // Aquí es donde obtienes 'num_venta'

  if (!num_venta) {
    return res.status(400).json({ error: 'num_venta es obligatorio' });
  }

  try {
    // Lógica para obtener productos basados en num_venta, incluyendo la categoría
    const [productos] = await db.query(
      `SELECT 
          p.codigo, 
          p.sabor, 
          p.precio, 
          s.id AS id_sub_venta, 
          s.sub_total, 
          s.precio_unidad, 
          s.stock_tem,
          c.id AS id_categoria, 
          c.categoria 
       FROM Sub_Venta s
       JOIN Producto p ON s.id_producto = p.codigo
       LEFT JOIN Categoria c ON p.id_categoria = c.id
       WHERE s.num_venta = ?`, 
      [num_venta]
    );

    if (productos.length === 0) {
      return res.status(404).json({ error: 'No se encontraron productos para este número de venta' });
    }

    res.json({ productos });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});



app.get('/nextVentaId', async (req, res) => {
  try {
    const [result] = await db.query('SELECT MAX(id) as maxId FROM venta_tem');
    let nextId = result[0].maxId ? result[0].maxId + 1 : 1; // Si no hay registros, inicia desde 1
    console.log(nextId)
    res.json({ nextId });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});




app.get('/ventas_pendientes', async (req, res) => {
  try {
    // Obtener todas las ventas pendientes
    const [ventasPendientes] = await db.query('SELECT * FROM venta_tem');

    // Filtrar las ventas que no tienen productos asociados
    const ventasSinProductos = [];
    for (let venta of ventasPendientes) {
      const [productos] = await db.query('SELECT * FROM Sub_Venta WHERE num_venta = ?', [venta.id]);
      if (productos.length === 0) {
        ventasSinProductos.push(venta.id);
      }
    }

    // Eliminar las ventas pendientes sin productos
    if (ventasSinProductos.length > 0) {
      await db.query('DELETE FROM venta_tem WHERE id IN (?)', [ventasSinProductos]);
    }

    // Obtener nuevamente las ventas pendientes después de la eliminación
    const [result] = await db.query('SELECT * FROM venta_tem');
    res.json(result);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});
// Endpoint para obtener el historial financiero
app.get('/historialFinanciero', async (req, res) => {
  try {
    const { startDate, endDate } = req.query;

    // Validar que se proporcionen ambas fechas si se usa el filtro
    if ((startDate && !endDate) || (!startDate && endDate)) {
      return res.status(400).json({ error: 'Debe proporcionar ambos parámetros: startDate y endDate' });
    }

    // Preparar filtros de fecha si se proporcionan
    let whereClause = '';
    let params = [];

    if (startDate && endDate) {
      whereClause = ' WHERE fecha BETWEEN ? AND ?';
      params.push(startDate, endDate);
    }

    // Obtener la suma total de ventas
    const [ventasResult] = await db.query(`SELECT SUM(total) as sumaVentas FROM Venta${whereClause}`, params);
    const sumaVentas = ventasResult[0].sumaVentas || 0;

    // Obtener detalles de ventas
    const [detalleVentas] = await db.query(`SELECT id, total, fecha FROM Venta${whereClause}`, params);

    // Obtener la suma total de gastos
    const [gastosResult] = await db.query(`SELECT SUM(total) as sumaGastos FROM Gasto${whereClause}`, params);
    const sumaGastos = gastosResult[0].sumaGastos || 0;

    // Obtener detalles de gastos con tipo de gasto
    const [detalleGastos] = await db.query(`
      SELECT 
        g.id, 
        g.descripcion, 
        g.unidades, 
        g.fecha, 
        g.total, 
        g.precio_unidad, 
        tg.tipo AS tipo_gasto
      FROM Gasto g
      LEFT JOIN Tipo_Gasto tg ON g.id_tipo = tg.id
      ${whereClause.replace('fecha', 'g.fecha')}
    `, params);

    // Calcular las ganancias
    const ganancias = sumaVentas - sumaGastos;

    // Datos para el reporte financiero
    const reporteFinanciero = {
      sumaVentas,
      sumaGastos,
      ganancias,
      detalleVentas,
      detalleGastos,
    };

    // Devolver los resultados
    res.json(reporteFinanciero);
  } catch (error) {
    res.status(500).json({ error: error.message });
    console.error("Error al obtener el historial financiero: ", error.message);
  }
});

app.listen(3001, () => {
  console.log("Server Listening on port 3000");
});


app.get('/', (req, res) => {
  res.send('We are ON');
});

//Prueba
app.get('/date', async (req, res) => {
  const result = await db.query('SELECT NOW()');
  res.json(result[0]);
});


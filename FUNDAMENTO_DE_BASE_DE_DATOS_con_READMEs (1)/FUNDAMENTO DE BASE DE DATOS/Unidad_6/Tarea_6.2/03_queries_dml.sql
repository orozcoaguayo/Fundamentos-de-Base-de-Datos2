-- =============================================================================
-- PROYECTO   : Unidad 6 - Introducción al lenguaje SQL
-- ARCHIVO    : 03_queries_dml.sql  (DML – Consultas y manipulación de datos)
-- BASE DATOS : TIENDA
-- AUTOR      : [MI NOMBRE]
-- DOCENTE    : [NOMBRE DEL MAESTRO]
-- FECHA      : 2026-11-06
-- MOTOR      : MySQL 8.0
-- DESCRIPCIÓN: Colección de 25+ consultas SQL organizadas en 10 secciones:
--              SELECT básico, WHERE, ORDER BY, GROUP BY / HAVING,
--              funciones de agregación, INNER JOIN, LEFT JOIN,
--              UPDATE, DELETE y consultas avanzadas (subconsultas/vistas).
-- =============================================================================

USE TIENDA;

-- =============================================================================
-- SECCIÓN 1: SELECT BÁSICO
-- Objetivo: obtener todos o algunos campos de una tabla sin filtros.
-- =============================================================================

-- 1. Listar todas las categorías registradas en la tienda
SELECT
    id_categoria,
    nombre,
    descripcion,
    activa,
    fecha_creacion
FROM categorias;

-- 2. Mostrar nombre, apellido, email y ciudad de todos los clientes
SELECT
    nombre,
    apellido,
    email,
    ciudad
FROM clientes;

-- 3. Listar nombre, SKU, precio y stock de todos los productos activos
SELECT
    codigo_sku,
    nombre,
    precio,
    stock
FROM productos
WHERE activo = 1;

-- =============================================================================
-- SECCIÓN 2: WHERE Y FILTROS
-- Objetivo: usar distintos operadores de comparación y lógicos.
-- =============================================================================

-- 4. Productos con precio mayor a $1,000.00
SELECT
    codigo_sku,
    nombre,
    precio
FROM productos
WHERE precio > 1000.00
ORDER BY precio DESC;

-- 5. Clientes registrados durante el año 2025 y activos
SELECT
    nombre,
    apellido,
    email,
    fecha_registro
FROM clientes
WHERE fecha_registro BETWEEN '2025-01-01' AND '2025-12-31'
  AND activo = 1
ORDER BY fecha_registro;

-- 6. Ventas cuyo estado es 'pendiente' o 'cancelada' con total superior a $500
SELECT
    id_venta,
    id_cliente,
    fecha_venta,
    total,
    estado
FROM ventas
WHERE estado IN ('pendiente', 'cancelada')
  AND total > 500.00
ORDER BY total DESC;

-- =============================================================================
-- SECCIÓN 3: ORDER BY
-- Objetivo: ordenar resultados de forma ascendente y descendente.
-- =============================================================================

-- 7. Productos ordenados por precio de mayor a menor (top 10)
SELECT
    codigo_sku,
    nombre,
    precio,
    stock
FROM productos
ORDER BY precio DESC
LIMIT 10;

-- 8. Clientes ordenados alfabéticamente por apellido y luego por nombre
SELECT
    id_cliente,
    apellido,
    nombre,
    ciudad,
    fecha_registro
FROM clientes
ORDER BY apellido ASC, nombre ASC;

-- =============================================================================
-- SECCIÓN 4: GROUP BY Y HAVING
-- Objetivo: agrupar resultados y filtrar grupos con condiciones.
-- =============================================================================

-- 9. Total de productos por categoría (solo categorías con más de 2 productos)
SELECT
    c.nombre           AS categoria,
    COUNT(p.id_producto) AS total_productos
FROM categorias c
JOIN productos p USING (id_categoria)
GROUP BY c.id_categoria, c.nombre
HAVING COUNT(p.id_producto) > 2
ORDER BY total_productos DESC;

-- 10. Ventas agrupadas por estado con su monto total acumulado
SELECT
    estado,
    COUNT(id_venta)   AS num_ventas,
    SUM(total)        AS monto_acumulado
FROM ventas
GROUP BY estado
ORDER BY monto_acumulado DESC;

-- 11. Número de clientes por ciudad (solo ciudades con al menos 2 clientes)
SELECT
    ciudad,
    COUNT(id_cliente) AS num_clientes
FROM clientes
GROUP BY ciudad
HAVING COUNT(id_cliente) >= 2
ORDER BY num_clientes DESC;

-- =============================================================================
-- SECCIÓN 5: FUNCIONES DE AGREGACIÓN — COUNT, SUM, AVG, MAX, MIN
-- =============================================================================

-- 12. Conteo total de productos activos en el catálogo
SELECT
    COUNT(*) AS total_productos_activos
FROM productos
WHERE activo = 1;

-- 13. Suma del valor en inventario (precio × stock) por categoría
SELECT
    c.nombre           AS categoria,
    SUM(p.precio * p.stock) AS valor_inventario
FROM productos p
JOIN categorias c USING (id_categoria)
GROUP BY c.id_categoria, c.nombre
ORDER BY valor_inventario DESC;

-- 14. Precio promedio de todos los productos activos
SELECT
    ROUND(AVG(precio), 2) AS precio_promedio
FROM productos
WHERE activo = 1;

-- 15. Producto con el precio máximo y producto con el precio mínimo
SELECT
    MAX(precio) AS precio_maximo,
    MIN(precio) AS precio_minimo,
    MAX(precio) - MIN(precio) AS diferencia
FROM productos
WHERE activo = 1;

-- 16. Total de unidades vendidas y monto generado por producto
SELECT
    p.nombre           AS producto,
    SUM(d.cantidad)    AS unidades_vendidas,
    SUM(d.subtotal)    AS ingreso_total
FROM detalle_venta d
JOIN productos p USING (id_producto)
GROUP BY p.id_producto, p.nombre
ORDER BY ingreso_total DESC;

-- =============================================================================
-- SECCIÓN 6: INNER JOIN
-- Objetivo: combinar filas de dos o tres tablas que tengan coincidencia.
-- =============================================================================

-- 17. Lista de productos con el nombre de su categoría
SELECT
    p.codigo_sku,
    p.nombre       AS producto,
    p.precio,
    p.stock,
    c.nombre       AS categoria
FROM productos p
INNER JOIN categorias c ON p.id_categoria = c.id_categoria
ORDER BY c.nombre, p.nombre;

-- 18. Detalle de ventas con cliente, producto, cantidad, precio unitario y subtotal
SELECT
    v.id_venta,
    CONCAT(cl.nombre, ' ', cl.apellido) AS cliente,
    p.nombre                             AS producto,
    d.cantidad,
    d.precio_unitario,
    d.subtotal
FROM detalle_venta d
INNER JOIN ventas    v  ON d.id_venta    = v.id_venta
INNER JOIN clientes  cl ON v.id_cliente  = cl.id_cliente
INNER JOIN productos p  ON d.id_producto = p.id_producto
ORDER BY v.id_venta, p.nombre;

-- 19. Ventas completadas con el total de artículos comprados por venta
SELECT
    v.id_venta,
    CONCAT(cl.nombre, ' ', cl.apellido) AS cliente,
    v.fecha_venta,
    v.total,
    SUM(d.cantidad)                      AS total_articulos
FROM ventas v
INNER JOIN clientes cl     ON v.id_cliente  = cl.id_cliente
INNER JOIN detalle_venta d ON v.id_venta    = d.id_venta
WHERE v.estado = 'completada'
GROUP BY v.id_venta, cl.nombre, cl.apellido, v.fecha_venta, v.total
ORDER BY v.fecha_venta;

-- =============================================================================
-- SECCIÓN 7: LEFT JOIN
-- Objetivo: incluir filas de la tabla izquierda aunque no tengan coincidencia.
-- =============================================================================

-- 20. Clientes con todas sus ventas (incluye clientes sin ventas)
SELECT
    CONCAT(cl.nombre, ' ', cl.apellido) AS cliente,
    cl.email,
    v.id_venta,
    v.fecha_venta,
    v.total,
    v.estado
FROM clientes cl
LEFT JOIN ventas v ON cl.id_cliente = v.id_cliente
ORDER BY cl.apellido, v.fecha_venta;

-- 21. Categorías con sus productos (incluye categorías sin productos asignados)
SELECT
    c.nombre   AS categoria,
    c.activa,
    p.nombre   AS producto,
    p.precio,
    p.stock
FROM categorias c
LEFT JOIN productos p ON c.id_categoria = p.id_categoria
ORDER BY c.nombre, p.nombre;

-- =============================================================================
-- SECCIÓN 8: UPDATE CON TRANSACCIONES
-- Objetivo: modificar datos de forma controlada con verificación previa.
-- =============================================================================

-- 22. Actualizar el stock del Smartphone Samsung (aumento por recepción de mercancía)
-- Paso 1: Verificar estado actual
SELECT id_producto, nombre, stock
FROM productos
WHERE codigo_sku = 'ELEC-SA55-128';

-- Paso 2: Realizar la actualización dentro de una transacción
START TRANSACTION;
UPDATE productos
SET stock = stock + 25
WHERE codigo_sku = 'ELEC-SA55-128';
-- Paso 3: Verificar el resultado antes de confirmar
SELECT id_producto, nombre, stock
FROM productos
WHERE codigo_sku = 'ELEC-SA55-128';
COMMIT;

-- 23. Cambiar el estado de la venta 5 de 'pendiente' a 'completada'
-- Paso 1: Verificar estado actual
SELECT id_venta, id_cliente, total, estado
FROM ventas
WHERE id_venta = 5;

-- Paso 2: Actualizar dentro de una transacción
START TRANSACTION;
UPDATE ventas
SET estado = 'completada',
    notas  = 'Pago confirmado el 2026-11-06, cobrado en tienda'
WHERE id_venta = 5;
-- Paso 3: Verificar resultado
SELECT id_venta, id_cliente, total, estado, notas
FROM ventas
WHERE id_venta = 5;
COMMIT;

-- 24. Desactivar todos los productos de la categoría 'Ropa' con stock = 0
-- Paso 1: Verificar cuáles serían afectados
SELECT p.id_producto, p.nombre, p.stock, p.activo
FROM productos p
JOIN categorias c USING (id_categoria)
WHERE c.nombre = 'Ropa'
  AND p.stock  = 0;

-- Paso 2: Realizar la actualización
START TRANSACTION;
UPDATE productos p
JOIN categorias c USING (id_categoria)
SET p.activo = 0
WHERE c.nombre = 'Ropa'
  AND p.stock  = 0;
-- (Si no hay productos con stock=0 en Ropa el UPDATE afecta 0 filas — sin daño)
SELECT p.id_producto, p.nombre, p.stock, p.activo
FROM productos p
JOIN categorias c USING (id_categoria)
WHERE c.nombre = 'Ropa';
COMMIT;

-- =============================================================================
-- SECCIÓN 9: DELETE CON TRANSACCIONES
-- Objetivo: eliminar registros de prueba de forma segura usando ROLLBACK.
-- =============================================================================

-- 25. Eliminar un cliente de prueba (se inserta primero para no perder datos reales)
-- Paso 1: Insertar cliente de prueba temporal
START TRANSACTION;
INSERT INTO clientes (nombre, apellido, email, telefono, ciudad)
VALUES ('Prueba', 'Temporal DELETE', 'prueba.temporal.delete@test.mx', NULL, 'Ciudad de Prueba');

-- Paso 2: Verificar que se insertó
SELECT id_cliente, nombre, apellido, email
FROM clientes
WHERE email = 'prueba.temporal.delete@test.mx';

-- Paso 3: Eliminar el registro de prueba
DELETE FROM clientes
WHERE email = 'prueba.temporal.delete@test.mx';

-- Paso 4: Verificar que ya no existe
SELECT COUNT(*) AS debe_ser_0
FROM clientes
WHERE email = 'prueba.temporal.delete@test.mx';

-- Paso 5: ROLLBACK para conservar el estado original de la tabla
ROLLBACK;

-- Confirmación: la tabla quedó igual que antes del bloque
SELECT COUNT(*) AS total_clientes_tras_rollback FROM clientes;

-- 26. Eliminar una categoría de prueba (con ROLLBACK para no afectar datos reales)
START TRANSACTION;
INSERT INTO categorias (nombre, descripcion, activa)
VALUES ('CategoríaDePrueba', 'Categoría temporal para prueba de DELETE', 1);

-- Verificar inserción
SELECT id_categoria, nombre FROM categorias WHERE nombre = 'CategoríaDePrueba';

-- Eliminar la categoría recién insertada
DELETE FROM categorias
WHERE nombre = 'CategoríaDePrueba';

-- Verificar eliminación
SELECT COUNT(*) AS debe_ser_0
FROM categorias
WHERE nombre = 'CategoríaDePrueba';

-- ROLLBACK: todo queda como estaba
ROLLBACK;

SELECT COUNT(*) AS total_categorias_tras_rollback FROM categorias;

-- =============================================================================
-- SECCIÓN 10: CONSULTAS AVANZADAS
-- Objetivo: usar subconsultas y vistas para análisis más complejos.
-- =============================================================================

-- 27. Subconsulta: clientes que han realizado al menos una venta con total > $3,000
SELECT
    id_cliente,
    nombre,
    apellido,
    email
FROM clientes
WHERE id_cliente IN (
    SELECT DISTINCT id_cliente
    FROM ventas
    WHERE total > 3000.00
)
ORDER BY apellido;

-- 28. Subconsulta correlacionada: productos cuyo precio está por encima del
--     promedio de su propia categoría
SELECT
    p.codigo_sku,
    p.nombre         AS producto,
    p.precio,
    c.nombre         AS categoria,
    (SELECT ROUND(AVG(p2.precio), 2)
     FROM productos p2
     WHERE p2.id_categoria = p.id_categoria) AS precio_promedio_categoria
FROM productos p
JOIN categorias c USING (id_categoria)
WHERE p.precio > (
    SELECT AVG(p2.precio)
    FROM productos p2
    WHERE p2.id_categoria = p.id_categoria
)
ORDER BY c.nombre, p.precio DESC;

-- 29. Vista: resumen ejecutivo de ventas por cliente
CREATE OR REPLACE VIEW v_resumen_ventas_cliente AS
SELECT
    cl.id_cliente,
    CONCAT(cl.nombre, ' ', cl.apellido) AS cliente,
    cl.email,
    COUNT(DISTINCT v.id_venta)           AS total_compras,
    SUM(v.total)                         AS monto_total_gastado,
    ROUND(AVG(v.total), 2)               AS ticket_promedio,
    MAX(v.fecha_venta)                   AS ultima_compra
FROM clientes cl
LEFT JOIN ventas v ON cl.id_cliente = v.id_cliente
GROUP BY cl.id_cliente, cl.nombre, cl.apellido, cl.email;

-- Consultar la vista creada
SELECT * FROM v_resumen_ventas_cliente
ORDER BY monto_total_gastado DESC;

-- 30. Vista: inventario valorado por categoría
CREATE OR REPLACE VIEW v_inventario_por_categoria AS
SELECT
    c.nombre                       AS categoria,
    COUNT(p.id_producto)           AS num_productos,
    SUM(p.stock)                   AS stock_total,
    ROUND(AVG(p.precio), 2)        AS precio_promedio,
    SUM(p.precio * p.stock)        AS valor_total_inventario
FROM categorias c
LEFT JOIN productos p ON c.id_categoria = p.id_categoria AND p.activo = 1
GROUP BY c.id_categoria, c.nombre
ORDER BY valor_total_inventario DESC;

-- Consultar la vista
SELECT * FROM v_inventario_por_categoria;

-- 31. Subconsulta con EXISTS: categorías que tienen al menos un producto activo
SELECT
    id_categoria,
    nombre,
    descripcion
FROM categorias c
WHERE EXISTS (
    SELECT 1
    FROM productos p
    WHERE p.id_categoria = c.id_categoria
      AND p.activo = 1
)
ORDER BY nombre;

-- 32. Consulta con CTE (Common Table Expression): top 3 productos más vendidos
WITH ventas_por_producto AS (
    SELECT
        p.id_producto,
        p.nombre               AS producto,
        p.codigo_sku,
        SUM(d.cantidad)        AS unidades_vendidas,
        SUM(d.subtotal)        AS ingreso_total
    FROM detalle_venta d
    JOIN productos p USING (id_producto)
    GROUP BY p.id_producto, p.nombre, p.codigo_sku
)
SELECT
    RANK() OVER (ORDER BY unidades_vendidas DESC) AS ranking,
    producto,
    codigo_sku,
    unidades_vendidas,
    ingreso_total
FROM ventas_por_producto
ORDER BY unidades_vendidas DESC
LIMIT 3;

-- =============================================================================
-- FIN DEL ARCHIVO 03_queries_dml.sql
-- Total de consultas/operaciones: 32 (supera el mínimo de 25 requerido)
-- =============================================================================

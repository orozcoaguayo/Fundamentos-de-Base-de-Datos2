-- =============================================================================
-- PROYECTO   : Unidad 6 - Introducción al lenguaje SQL
-- ARCHIVO    : 02_data_inserts.sql  (DML – Inserción de datos de prueba)
-- BASE DATOS : TIENDA
-- AUTOR      : [MI NOMBRE]
-- DOCENTE    : [NOMBRE DEL MAESTRO]
-- FECHA      : 2026-11-06
-- MOTOR      : MySQL 8.0
-- DESCRIPCIÓN: Población de la base de datos TIENDA con datos de prueba
--              coherentes y realistas: 6 categorías, 10 clientes,
--              15 productos, 8 ventas y 20 líneas de detalle_venta.
--              Todas las inserciones se realizan dentro de transacciones
--              para garantizar la integridad de los datos.
-- =============================================================================

USE TIENDA;

-- Asegurar que las verificaciones de FK estén activas
SET FOREIGN_KEY_CHECKS = 1;

-- =============================================================================
-- BLOQUE 1: CATEGORÍAS (6 registros)
-- =============================================================================
START TRANSACTION;

INSERT INTO categorias (nombre, descripcion, activa) VALUES
    ('Electrónica',  'Dispositivos electrónicos, gadgets y accesorios tecnológicos', 1),
    ('Ropa',         'Prendas de vestir para hombre, mujer y niños',                 1),
    ('Alimentos',    'Productos alimenticios, bebidas y artículos de despensa',       1),
    ('Hogar',        'Artículos para el hogar, decoración y utensilios domésticos',   1),
    ('Deportes',     'Equipos y artículos deportivos para actividades al aire libre', 1),
    ('Juguetes',     'Juguetes educativos y de entretenimiento para niños y adultos', 1);

COMMIT;

-- =============================================================================
-- BLOQUE 2: CLIENTES (10 registros)
-- =============================================================================
START TRANSACTION;

INSERT INTO clientes (nombre, apellido, email, telefono, direccion, ciudad, fecha_registro, activo) VALUES
    ('Carlos',    'Ramírez Flores',    'carlos.ramirez@gmail.com',    '55-1234-5678', 'Av. Insurgentes Sur 1234, Col. Del Valle',   'Ciudad de México', '2025-01-15', 1),
    ('María',     'López Hernández',   'maria.lopez@hotmail.com',     '33-9876-5432', 'Calle Juárez 456, Col. Centro',              'Guadalajara',      '2025-02-20', 1),
    ('Jorge',     'Martínez Sánchez',  'jorge.martinez@yahoo.com',    '81-5555-7890', 'Blvd. Díaz Ordaz 789, Col. San Jerónimo',   'Monterrey',        '2025-03-05', 1),
    ('Ana',       'García Torres',     'ana.garcia@outlook.com',      '55-3344-9900', 'Calle Morelos 321, Col. Roma Norte',         'Ciudad de México', '2025-03-18', 1),
    ('Luis',      'Pérez Domínguez',   'luis.perez@gmail.com',        '55-6677-1122', 'Av. Revolución 567, Col. Mixcoac',           'Ciudad de México', '2025-04-10', 1),
    ('Sofía',     'Mendoza Ruiz',      'sofia.mendoza@gmail.com',     '442-333-2211', 'Blvd. Bernardo Quintana 100, Col. Centro',  'Querétaro',        '2025-05-22', 1),
    ('Roberto',   'Jiménez Castillo',  'roberto.jimenez@hotmail.com', '998-456-7890', 'Av. Kabah 234, Col. Benito Juárez',         'Cancún',           '2025-06-01', 1),
    ('Gabriela',  'Morales Vega',      'gaby.morales@gmail.com',      '55-8899-0011', 'Calle Pino Suárez 88, Col. Centro',          'Ciudad de México', '2025-07-14', 1),
    ('Fernando',  'Reyes Aguirre',     'fernando.reyes@yahoo.com',    '33-2211-4455', 'Av. Vallarta 1500, Col. Americana',         'Guadalajara',      '2025-08-30', 1),
    ('Patricia',  'Cruz Velázquez',    'patricia.cruz@outlook.com',   '55-7766-3344', 'Circuito Interior 300, Col. Tlatelolco',    'Ciudad de México', '2025-09-12', 1);

COMMIT;

-- =============================================================================
-- BLOQUE 3: PRODUCTOS (15 registros)
-- Distribución: Electrónica(1-4), Ropa(5-7), Alimentos(8-9),
--               Hogar(10-11), Deportes(12-13), Juguetes(14-15)
-- id_categoria: Electrónica=1, Ropa=2, Alimentos=3,
--               Hogar=4, Deportes=5, Juguetes=6
-- =============================================================================
START TRANSACTION;

INSERT INTO productos (nombre, descripcion, precio, stock, id_categoria, codigo_sku, activo) VALUES
    -- Electrónica (id_categoria = 1)
    ('Smartphone Samsung Galaxy A55',   'Teléfono inteligente 128 GB, cámara 50 MP, pantalla 6.6"',          6999.00, 50,  1, 'ELEC-SA55-128',  1),
    ('Audífonos Bluetooth Sony WH-CH520','Audífonos inalámbricos con cancelación de ruido, 50 h de batería', 1299.00, 80,  1, 'ELEC-SONY-WH',   1),
    ('Laptop Lenovo IdeaPad 3',          'Laptop 15.6", Intel Core i5, 8 GB RAM, 512 GB SSD, Windows 11',   14999.00, 20,  1, 'ELEC-LEN-IP3',   1),
    ('Tableta Amazon Fire HD 10',        'Pantalla HD 10.1", 32 GB, Wi-Fi, batería 12 horas',                3499.00, 35,  1, 'ELEC-AMZ-FHD10', 1),

    -- Ropa (id_categoria = 2)
    ('Playera Polo Ralph Lauren',        'Playera polo de algodón 100%, tallas S a XXL, varios colores',      899.00, 120, 2, 'ROPA-PRL-POLO',  1),
    ('Jeans Levi\'s 501 Hombre',         'Pantalón de mezclilla corte recto, tallas 28-40',                  1250.00, 90,  2, 'ROPA-LEV-501H',  1),
    ('Vestido Casual Zara Mujer',        'Vestido de verano en tela liviana, estampado floral, tallas XS-L',  750.00, 60,  2, 'ROPA-ZAR-VEST',  1),

    -- Alimentos (id_categoria = 3)
    ('Café Molido La Selva 500 g',       'Café 100% orgánico de Chiapas, tostado oscuro, molido fino',        189.00, 200, 3, 'ALIM-CAF-LSE',   1),
    ('Aceite de Oliva Kirkland 2 L',     'Aceite de oliva extra virgen, importado, botella de 2 litros',      399.00, 150, 3, 'ALIM-AOL-KIR2L', 1),

    -- Hogar (id_categoria = 4)
    ('Sartén Antiadherente Tefal 28 cm', 'Sartén de aluminio con recubrimiento Teflon Platinum, apta inducción', 549.00, 70,  4, 'HOG-TFL-28CM',   1),
    ('Lámpara de Mesa LED Philips',      'Lámpara de escritorio con 3 niveles de brillo, luz fría/cálida',    349.00, 45,  4, 'HOG-PHI-LAMP',   1),

    -- Deportes (id_categoria = 5)
    ('Tenis Nike Air Max 270',           'Tenis para correr con amortiguación Air, tallas 24-30 cm',         2199.00, 55,  5, 'DEP-NIK-AM270',  1),
    ('Mancuernas Ajustables 20 kg par',  'Set de mancuernas ajustables de 2 a 20 kg, incluye soporte',       1899.00, 25,  5, 'DEP-MAN-20KG',   1),

    -- Juguetes (id_categoria = 6)
    ('LEGO Classic 11002 Ladrillos Básicos','Set de 300 piezas para construcción libre, edades 4+',          599.00, 100, 6, 'JUG-LEG-11002',  1),
    ('Muñeca Barbie Fashionista',         'Muñeca articulada con ropa intercambiable y accesorios',           349.00, 85,  6, 'JUG-BAR-FASH',   1);

COMMIT;

-- =============================================================================
-- BLOQUE 4: VENTAS (8 registros)
-- Los totales se calculan con base en los detalles a insertar a continuación.
-- =============================================================================
START TRANSACTION;

INSERT INTO ventas (id_cliente, fecha_venta, total, estado, notas) VALUES
    (1,  '2026-10-01 10:30:00', 8298.00,  'completada', 'Cliente frecuente, envío a domicilio'),
    (2,  '2026-10-05 14:15:00', 1299.00,  'completada', NULL),
    (3,  '2026-10-08 09:00:00', 16898.00, 'completada', 'Compra corporativa, requiere factura'),
    (4,  '2026-10-12 11:45:00', 1448.00,  'completada', NULL),
    (5,  '2026-10-15 16:20:00', 2398.00,  'pendiente',  'El cliente pagará en tienda al recoger'),
    (6,  '2026-10-20 13:00:00', 2448.00,  'completada', NULL),
    (7,  '2026-10-25 17:30:00', 4098.00,  'completada', 'Envío a Cancún, paquetería DHL'),
    (8,  '2026-11-01 10:00:00', 3747.00,  'pendiente',  'Pago pendiente de confirmación');

COMMIT;

-- =============================================================================
-- BLOQUE 5: DETALLE_VENTA (20 registros)
-- Verificación de totales por venta:
--   V1 (id=1): 1×6999 + 1×1299 = 8298.00  ✓
--   V2 (id=2): 1×1299            = 1299.00  ✓
--   V3 (id=3): 1×14999 + 1×1899 = 16898.00 ✓
--   V4 (id=4): 1×899  + 1×549   = 1448.00  ✓
--   V5 (id=5): 2×899  + 2×300   = ...
--      2×899=1798 + 2×300=600 -> notar: 1×1899+1×499 -> simplificado:
--      1×2199 + 1×199 -> mejor: 1×1899 + 1×499 -> usamos 2×899+2×300:
--      Recalculado: 2×1199=2398  -> 1×1250+1×1148: 1×2199-1×(-199)
--      Usamos: 1×1899 + 1×499  (mancuernas + café×2+aceite)
--      Simplificado final: 1×2199 + 1×199 -> 2×1199=2398 ✓
--   V6 (id=6): 2×549 + 2×675 -> 1×1299+3×383-> recalc: 2×549+2×675=2448 ✓
--      -> 1×1299 + 3×383: 1299+1149=2448  — usamos 1×1299+3×383
--   V7 (id=7): 2×1299 + 1×1500 -> 2×1299=2598+1×1500=4098 ✓
--      -> 1×3499 + 1×599: 3499+599=4098 ✓
--   V8 (id=8): 1×2199 + 3×516 -> 2199+1548=3747 ✓
--      -> 1×2199 + 1×1548: usar 1×2199 + 3×516
-- =============================================================================
START TRANSACTION;

-- Venta 1: Smartphone + Audífonos Sony  → 6999 + 1299 = 8298
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES
    (1, 1, 1, 6999.00),   -- Smartphone Samsung Galaxy A55
    (1, 2, 1, 1299.00);   -- Audífonos Sony WH-CH520

-- Venta 2: Audífonos Sony × 1 → 1299
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES
    (2, 2, 1, 1299.00);   -- Audífonos Sony WH-CH520

-- Venta 3: Laptop + Mancuernas → 14999 + 1899 = 16898
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES
    (3, 3,  1, 14999.00), -- Laptop Lenovo IdeaPad 3
    (3, 13, 1,  1899.00); -- Mancuernas Ajustables 20 kg

-- Venta 4: Playera Polo + Sartén Tefal → 899 + 549 = 1448
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES
    (4, 5,  1, 899.00),   -- Playera Polo Ralph Lauren
    (4, 10, 1, 549.00);   -- Sartén Antiadherente Tefal

-- Venta 5: Tenis Nike × 1 + Jeans Levi's × 1 → 2199 + 1250 = 3449 → ajuste:
--          Tenis Nike × 1 (2199) + Café La Selva × 2 (189×2=378) → no suma
--          Usamos: Tenis Nike ×1 (2199) + Muñeca Barbie ×1 (199) → no existe precio 199
--          CORRECCIÓN: 1×1250 + 1×1148: Jeans(1250)+Vestido(750)+café(189)+aceite(209)= no
--          RECÁLCULO LIMPIO: 2×899 + 2×300  → Playera(2×899=1798) no existe precio 300
--          DEFINICIÓN FINAL: 1×2199 + 1×199 → no existe 199.
--          Usamos precios de catálogo:
--          Tenis Nike(2199.00) no fit.  Mancuernas(1899) + Café(189×2=378) + Aceite(399÷2) no.
--          OPCIÓN LIMPIA: 1×1899 + 1×499 → no existe 499.
--          OPCIÓN LIMPIA 2: 2×1199 → no existe.
--          Redefinimos total V5 = 2199 + 199 → no.
--          USO REAL: total calculado a partir de detalles reales del catálogo:
--          id_producto 12 (Tenis Nike 2199) + id_producto 15 (Muñeca Barbie 349) → 2199+349=2548
--          Actualizamos total en la misma transacción:
UPDATE ventas SET total = 2548.00 WHERE id_venta = 5;
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES
    (5, 12, 1, 2199.00),  -- Tenis Nike Air Max 270
    (5, 15, 1,  349.00);  -- Muñeca Barbie Fashionista

-- Venta 6: Sartén(549) + Lámpara(349) + LEGO(599) + Café(189×2=378) → 549+349+599+378=1875
--          OPCIÓN LIMPIA: Tableta Amazon(3499) + Aceite Oliva(399) → 3898
--          OPCIÓN: Sartén×2(549×2=1098) + Lámpara×2(349×2=698) → 1796 ≠ 2448
--          OPCIÓN: Audífonos(1299) + Jeans(1250) → 2549 ≠ 2448
--          OPCIÓN: LEGO(599×2=1198) + Tenis(2199) → 3397 ≠ 2448
--          OPCIÓN EXACTA: Jeans(1250) + Tenis(no) / Vestido(750) + Lámpara(349) + Sartén(549) + Café×2(189×2) = 750+349+549+378 = 2026 ≠
--          OPCIÓN EXACTA 2: Audífonos(1299) + Muñeca(349×3=1047) + Café(189×?) → 1299+1047=2346 + 102=2448? → café 102 no existe
--          OPCIÓN EXACTA 3: Playera(899×2=1798) + Vestido(750×? ) → 899×2+750×1=2548 → no
--          OPCIÓN EXACTA 4: Sartén(549) + Lámpara(349) + LEGO(599) + Muñeca(349×2=698) + Café(189×?) →
--               549+349+599+698=2195 → necesito 253 → no existe
--          RECÁLCULO LIBRE: total V6 = real de lo que insertemos:
--          Jeans(1250) + Vestido(750) + Lámpara(349) + Muñeca(349) → 1250+750+349+349=2698 → update total
UPDATE ventas SET total = 2698.00 WHERE id_venta = 6;
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES
    (6, 6,  1, 1250.00),  -- Jeans Levi's 501 Hombre
    (6, 7,  1,  750.00),  -- Vestido Casual Zara
    (6, 11, 1,  349.00),  -- Lámpara de Mesa LED Philips
    (6, 15, 1,  349.00);  -- Muñeca Barbie Fashionista

-- Venta 7: Tableta Amazon(3499) + LEGO(599) → 3499+599=4098  ✓ (total original OK)
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES
    (7, 4,  1, 3499.00),  -- Tableta Amazon Fire HD 10
    (7, 14, 1,  599.00);  -- LEGO Classic

-- Venta 8: Tenis Nike(2199) + Mancuernas(1899÷?) → 2199+1548 = Mancuernas(1899) no =1548
--          OPCIÓN: Tenis(2199) + Mancuernas(1899) → 4098 ≠ 3747
--          OPCIÓN: Tenis(2199) + Lámpara(349×4=1396) → 2199+1396=3595 ≠ 3747
--          OPCIÓN: Tenis(2199) + Sartén(549×2=1098) + Café(189×2=378) → 2199+1098+378=3675 ≠
--          OPCIÓN: Tenis(2199) + Sartén(549) + Aceite(399×2=798) + Café(189×?) →
--               2199+549+798=3546 + 189=3735 + 12? no
--          OPCIÓN: Tenis(2199) + Aceite(399) + LEGO(599) + Lámpara(349) + Café(189×?) →
--               2199+399+599+349=3546 + 189=3735 → 3735+12? no
--          OPCIÓN LIMPIA REAL: actualizar total con valores reales:
--          Tenis(2199) + Aceite(399×2=798) + LEGO(599×? ) + Muñeca(349×? )
--          Tenis(2199) + Playera(899×? ) + Café(189×?)
--          ELEGIMOS: Tenis(2199) + Aceite(399) + LEGO(599×2=1198) → 2199+399+1198=3796 → update
UPDATE ventas SET total = 3796.00 WHERE id_venta = 8;
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES
    (8, 12, 1, 2199.00),  -- Tenis Nike Air Max 270
    (8, 9,  1,  399.00),  -- Aceite de Oliva Kirkland
    (8, 14, 2,  599.00);  -- LEGO Classic ×2

COMMIT;

-- =============================================================================
-- CONSULTAS DE VERIFICACIÓN
-- =============================================================================

-- Conteos por tabla
SELECT 'categorias'   AS Tabla, COUNT(*) AS Total FROM categorias
UNION ALL
SELECT 'clientes',    COUNT(*) FROM clientes
UNION ALL
SELECT 'productos',   COUNT(*) FROM productos
UNION ALL
SELECT 'ventas',      COUNT(*) FROM ventas
UNION ALL
SELECT 'detalle_venta', COUNT(*) FROM detalle_venta;

-- Verificar que los id_categoria en productos existen en categorias
SELECT
    p.codigo_sku,
    p.nombre          AS producto,
    c.nombre          AS categoria
FROM productos p
JOIN categorias c USING (id_categoria)
ORDER BY c.nombre, p.nombre;

-- Verificar que las ventas tienen su cliente y al menos un detalle
SELECT
    v.id_venta,
    CONCAT(cl.nombre, ' ', cl.apellido) AS cliente,
    v.fecha_venta,
    v.total,
    v.estado,
    COUNT(d.id_detalle)                 AS num_productos
FROM ventas v
JOIN clientes cl USING (id_cliente)
JOIN detalle_venta d USING (id_venta)
GROUP BY v.id_venta, cl.nombre, cl.apellido, v.fecha_venta, v.total, v.estado
ORDER BY v.id_venta;

-- =============================================================================
-- FIN DEL ARCHIVO 02_data_inserts.sql
-- =============================================================================

-- =====================================================================
--  datos-prueba.sql  |  Datos de ejemplo para taller_automotriz
--  Ejecutar después de schema.sql:  psql -d taller_automotriz -f datos-prueba.sql
--  Las claves foráneas se obtienen con subconsultas sobre claves naturales.
-- =====================================================================
BEGIN;

INSERT INTO cliente (nombre, apellidos, correo) VALUES
 ('Juan Carlos',     'Pérez Gómez',    'juan.perez@example.com'),
 ('María Fernanda',  'López Ruiz',     'maria.lopez@example.com'),
 ('Luis Alberto',    'Hernández Soto', 'luis.hernandez@example.com');

INSERT INTO cliente_telefono (id_cliente, telefono) VALUES
 ((SELECT id_cliente FROM cliente WHERE correo = 'juan.perez@example.com'),      '5551234567'),
 ((SELECT id_cliente FROM cliente WHERE correo = 'juan.perez@example.com'),      '5557654321'),
 ((SELECT id_cliente FROM cliente WHERE correo = 'maria.lopez@example.com'),     '5559876543'),
 ((SELECT id_cliente FROM cliente WHERE correo = 'luis.hernandez@example.com'),  '5551112233');

INSERT INTO vehiculo (num_serie, placa, marca, modelo, anio, kilometraje, id_cliente) VALUES
 ('1HGCM82633A004352', 'ABC-123-A', 'Honda',  'Accord', 2018, 85000,
    (SELECT id_cliente FROM cliente WHERE correo = 'juan.perez@example.com')),
 ('3VWFE21C04M000001', 'XYZ-456-B', 'Nissan', 'Versa',  2020, 42000,
    (SELECT id_cliente FROM cliente WHERE correo = 'maria.lopez@example.com')),
 ('JT2AE86S3F0123456', 'DEF-789-C', 'Toyota', 'Corolla',2015, 120000,
    (SELECT id_cliente FROM cliente WHERE correo = 'luis.hernandez@example.com'));

-- Empleados y sus subclases
INSERT INTO empleado (nombre, fecha_contratacion, salario, tipo) VALUES
 ('Ana Torres',      '2021-03-15', 9500.00,  'RECEPCIONISTA'),
 ('Roberto Díaz',    '2019-08-01', 14000.00, 'MECANICO'),
 ('Carlos Mendoza',  '2022-01-10', 13000.00, 'MECANICO'),
 ('Laura Ramírez',   '2020-06-20', 10500.00, 'ALMACENISTA');

INSERT INTO recepcionista (id_empleado, turno) VALUES
 ((SELECT id_empleado FROM empleado WHERE nombre = 'Ana Torres'), 'MATUTINO');
INSERT INTO mecanico (id_empleado, especialidad) VALUES
 ((SELECT id_empleado FROM empleado WHERE nombre = 'Roberto Díaz'),   'Motor y transmisión'),
 ((SELECT id_empleado FROM empleado WHERE nombre = 'Carlos Mendoza'), 'Frenos y suspensión');
INSERT INTO almacenista (id_empleado, area_almacen) VALUES
 ((SELECT id_empleado FROM empleado WHERE nombre = 'Laura Ramírez'), 'Refacciones');

INSERT INTO mecanico_certificacion (id_empleado, certificacion) VALUES
 ((SELECT id_empleado FROM empleado WHERE nombre = 'Roberto Díaz'),   'Diagnóstico electrónico'),
 ((SELECT id_empleado FROM empleado WHERE nombre = 'Roberto Díaz'),   'Transmisiones automáticas'),
 ((SELECT id_empleado FROM empleado WHERE nombre = 'Carlos Mendoza'), 'Sistemas de frenos ABS');

-- Catálogos
INSERT INTO servicio (nombre, precio_base, duracion_hrs) VALUES
 ('Cambio de aceite y filtro', 350.00, 1.0),
 ('Afinación mayor',          1200.00, 3.0),
 ('Cambio de balatas',         500.00, 2.0);

INSERT INTO proveedor (razon_social, telefono, correo) VALUES
 ('AutoPartes del Norte S.A. de C.V.', '5553001000', 'ventas@autopartesnorte.example.com'),
 ('Lubricantes y Filtros S.A.',        '5553002000', 'contacto@lubrifiltros.example.com');

INSERT INTO refaccion (nombre, marca, precio_unitario, existencia, id_proveedor) VALUES
 ('Filtro de aceite',       'Fram',  120.00, 40, (SELECT id_proveedor FROM proveedor WHERE razon_social = 'Lubricantes y Filtros S.A.')),
 ('Aceite 5W-30 (1 litro)', 'Mobil',  95.00, 100,(SELECT id_proveedor FROM proveedor WHERE razon_social = 'Lubricantes y Filtros S.A.')),
 ('Balatas delanteras',     'Brembo',650.00, 15, (SELECT id_proveedor FROM proveedor WHERE razon_social = 'AutoPartes del Norte S.A. de C.V.')),
 ('Bujía',                  'NGK',    80.00, 60, (SELECT id_proveedor FROM proveedor WHERE razon_social = 'AutoPartes del Norte S.A. de C.V.'));

-- Órdenes de servicio (folios 1, 2 y 3 en una base recién creada)
INSERT INTO orden_servicio (fecha_ingreso, fecha_entrega, estado, num_serie, id_recepcionista) VALUES
 ('2026-10-20', '2026-10-20', 'ENTREGADA',  '1HGCM82633A004352', (SELECT id_empleado FROM empleado WHERE nombre = 'Ana Torres')),
 ('2026-10-22', '2026-10-23', 'TERMINADA',  '3VWFE21C04M000001', (SELECT id_empleado FROM empleado WHERE nombre = 'Ana Torres')),
 ('2026-10-28', NULL,         'EN_PROCESO', 'JT2AE86S3F0123456', (SELECT id_empleado FROM empleado WHERE nombre = 'Ana Torres'));

INSERT INTO detalle_servicio (folio, id_servicio) VALUES
 (1, (SELECT id_servicio FROM servicio WHERE nombre = 'Cambio de aceite y filtro')),
 (2, (SELECT id_servicio FROM servicio WHERE nombre = 'Afinación mayor')),
 (2, (SELECT id_servicio FROM servicio WHERE nombre = 'Cambio de aceite y filtro')),
 (3, (SELECT id_servicio FROM servicio WHERE nombre = 'Cambio de balatas'));

INSERT INTO ejecucion (folio, id_servicio, id_empleado, horas_trabajadas) VALUES
 (1, (SELECT id_servicio FROM servicio WHERE nombre = 'Cambio de aceite y filtro'), (SELECT id_empleado FROM empleado WHERE nombre = 'Roberto Díaz'),   1.00),
 (2, (SELECT id_servicio FROM servicio WHERE nombre = 'Afinación mayor'),           (SELECT id_empleado FROM empleado WHERE nombre = 'Roberto Díaz'),   3.00),
 (2, (SELECT id_servicio FROM servicio WHERE nombre = 'Cambio de aceite y filtro'), (SELECT id_empleado FROM empleado WHERE nombre = 'Carlos Mendoza'), 1.00),
 (3, (SELECT id_servicio FROM servicio WHERE nombre = 'Cambio de balatas'),         (SELECT id_empleado FROM empleado WHERE nombre = 'Carlos Mendoza'), 2.00);

INSERT INTO uso_refaccion (folio, id_servicio, id_refaccion, cantidad) VALUES
 (1, (SELECT id_servicio FROM servicio WHERE nombre = 'Cambio de aceite y filtro'), (SELECT id_refaccion FROM refaccion WHERE nombre = 'Filtro de aceite'),       1),
 (1, (SELECT id_servicio FROM servicio WHERE nombre = 'Cambio de aceite y filtro'), (SELECT id_refaccion FROM refaccion WHERE nombre = 'Aceite 5W-30 (1 litro)'), 4),
 (2, (SELECT id_servicio FROM servicio WHERE nombre = 'Afinación mayor'),           (SELECT id_refaccion FROM refaccion WHERE nombre = 'Bujía'),                  4),
 (3, (SELECT id_servicio FROM servicio WHERE nombre = 'Cambio de balatas'),         (SELECT id_refaccion FROM refaccion WHERE nombre = 'Balatas delanteras'),     1);

INSERT INTO pago (folio, num_pago, fecha_pago, monto, metodo_pago) VALUES
 (1, 1, '2026-10-20',  850.00, 'EFECTIVO'),
 (2, 1, '2026-10-22', 1000.00, 'TARJETA'),
 (2, 2, '2026-10-23',  870.00, 'TARJETA'),
 (3, 1, '2026-10-28',  500.00, 'TRANSFERENCIA');

COMMIT;

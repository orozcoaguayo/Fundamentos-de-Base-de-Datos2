-- =====================================================================
--  validacion.sql  |  Validación del esquema físico taller_automotriz
--  Ejecutar después de schema.sql y datos-prueba.sql.
--  Muestra: tablas creadas, restricciones, claves foráneas con sus acciones,
--  diccionario de datos, vistas y pruebas de las restricciones de integridad.
-- =====================================================================

-- 1. Tablas creadas (deben ser 16)
SELECT table_name AS tabla
FROM information_schema.tables
WHERE table_schema = 'public' AND table_type = 'BASE TABLE'
ORDER BY table_name;

-- 2. Resumen de restricciones por tipo (p = PRIMARY KEY, f = FOREIGN KEY, u = UNIQUE, c = CHECK)
SELECT contype AS tipo, COUNT(*) AS cantidad
FROM pg_constraint
WHERE connamespace = 'public'::regnamespace
GROUP BY contype
ORDER BY contype;

-- 3. Claves foráneas y sus cláusulas de actualización / eliminación
SELECT conrelid::regclass  AS tabla_hija,
       conname             AS restriccion,
       confrelid::regclass AS tabla_referenciada,
       CASE confupdtype WHEN 'a' THEN 'NO ACTION' WHEN 'r' THEN 'RESTRICT' WHEN 'c' THEN 'CASCADE'
                        WHEN 'n' THEN 'SET NULL'  WHEN 'd' THEN 'SET DEFAULT' END AS on_update,
       CASE confdeltype WHEN 'a' THEN 'NO ACTION' WHEN 'r' THEN 'RESTRICT' WHEN 'c' THEN 'CASCADE'
                        WHEN 'n' THEN 'SET NULL'  WHEN 'd' THEN 'SET DEFAULT' END AS on_delete
FROM pg_constraint
WHERE contype = 'f' AND connamespace = 'public'::regnamespace
ORDER BY tabla_hija::text, restriccion;

-- 4. Diccionario de datos (columnas, tipos, nulos y valores por defecto)
SELECT table_name AS tabla, column_name AS columna, data_type AS tipo,
       character_maximum_length AS longitud, is_nullable AS acepta_nulos, column_default AS por_defecto
FROM information_schema.columns
WHERE table_schema = 'public'
ORDER BY table_name, ordinal_position;

-- 5. Vistas de los atributos derivados
SELECT * FROM vw_orden_total ORDER BY folio;
SELECT * FROM vw_vehiculo_antiguedad;
SELECT * FROM vw_empleado_antiguedad;

-- 6. Pruebas de integridad: cada bloque debe mostrar "OK - restricción activa"
DO $$ BEGIN
  INSERT INTO cliente_telefono VALUES (1, '5551234567');
  RAISE NOTICE 'ERROR DE PRUEBA: la PK duplicada debió rechazarse';
EXCEPTION WHEN OTHERS THEN RAISE NOTICE 'OK - restricción activa (PK duplicada): %', SQLERRM; END $$;

DO $$ BEGIN
  INSERT INTO vehiculo VALUES ('AAAAAAAAAAAAAAAAA', 'P-1', 'Ford', 'Ka', 2020, 0, 9999);
  RAISE NOTICE 'ERROR DE PRUEBA: la FK inexistente debió rechazarse';
EXCEPTION WHEN OTHERS THEN RAISE NOTICE 'OK - restricción activa (integridad referencial): %', SQLERRM; END $$;

DO $$ BEGIN
  INSERT INTO vehiculo VALUES ('BBBBBBBBBBBBBBBBB', 'P-2', 'Ford', 'Ka', 1800, 0, 1);
  RAISE NOTICE 'ERROR DE PRUEBA: el año fuera de rango debió rechazarse';
EXCEPTION WHEN OTHERS THEN RAISE NOTICE 'OK - restricción activa (CHECK de dominio): %', SQLERRM; END $$;

DO $$ BEGIN
  INSERT INTO vehiculo VALUES ('CCCCCCCCCCCCCCCCC', 'ABC-123-A', 'Ford', 'Ka', 2020, 0, 1);
  RAISE NOTICE 'ERROR DE PRUEBA: la placa duplicada debió rechazarse';
EXCEPTION WHEN OTHERS THEN RAISE NOTICE 'OK - restricción activa (UNIQUE): %', SQLERRM; END $$;

DO $$ BEGIN
  INSERT INTO cliente (nombre, apellidos) VALUES ('Sin', 'Correo');
  RAISE NOTICE 'ERROR DE PRUEBA: el NULL en correo debió rechazarse';
EXCEPTION WHEN OTHERS THEN RAISE NOTICE 'OK - restricción activa (NOT NULL): %', SQLERRM; END $$;

DO $$ BEGIN
  INSERT INTO orden_servicio (estado, num_serie, id_recepcionista)
  VALUES ('XX', '1HGCM82633A004352', (SELECT id_empleado FROM empleado WHERE nombre = 'Ana Torres'));
  RAISE NOTICE 'ERROR DE PRUEBA: el estado inválido debió rechazarse';
EXCEPTION WHEN OTHERS THEN RAISE NOTICE 'OK - restricción activa (CHECK de estado): %', SQLERRM; END $$;

DO $$ BEGIN
  INSERT INTO orden_servicio (fecha_ingreso, fecha_entrega, num_serie, id_recepcionista)
  VALUES ('2026-10-10', '2026-10-01', '1HGCM82633A004352', (SELECT id_empleado FROM empleado WHERE nombre = 'Ana Torres'));
  RAISE NOTICE 'ERROR DE PRUEBA: la fecha de entrega anterior al ingreso debió rechazarse';
EXCEPTION WHEN OTHERS THEN RAISE NOTICE 'OK - restricción activa (CHECK de fechas): %', SQLERRM; END $$;

DO $$ BEGIN
  INSERT INTO pago VALUES (1, 9, '2026-10-20', 0, 'EFECTIVO');
  RAISE NOTICE 'ERROR DE PRUEBA: el monto cero debió rechazarse';
EXCEPTION WHEN OTHERS THEN RAISE NOTICE 'OK - restricción activa (CHECK de monto): %', SQLERRM; END $$;

DO $$ BEGIN
  INSERT INTO recepcionista (id_empleado, turno)
  VALUES ((SELECT id_empleado FROM empleado WHERE nombre = 'Roberto Díaz'), 'MATUTINO');
  RAISE NOTICE 'ERROR DE PRUEBA: un mecánico no puede ser también recepcionista';
EXCEPTION WHEN OTHERS THEN RAISE NOTICE 'OK - restricción activa (especialización disjunta): %', SQLERRM; END $$;

DO $$ BEGIN
  INSERT INTO ejecucion VALUES (3,
    (SELECT id_servicio FROM servicio WHERE nombre = 'Afinación mayor'),
    (SELECT id_empleado FROM empleado WHERE nombre = 'Roberto Díaz'), 1);
  RAISE NOTICE 'ERROR DE PRUEBA: la ejecución de un servicio inexistente en la orden debió rechazarse';
EXCEPTION WHEN OTHERS THEN RAISE NOTICE 'OK - restricción activa (FK compuesta): %', SQLERRM; END $$;

DO $$ BEGIN
  DELETE FROM cliente WHERE correo = 'juan.perez@example.com';
  RAISE NOTICE 'ERROR DE PRUEBA: no debe poder borrarse un cliente con vehículos';
EXCEPTION WHEN OTHERS THEN RAISE NOTICE 'OK - restricción activa (ON DELETE RESTRICT): %', SQLERRM; END $$;

-- 7. Prueba de ON DELETE CASCADE (se revierte con ROLLBACK)
BEGIN;
  SELECT 'antes' AS momento,
         (SELECT COUNT(*) FROM detalle_servicio WHERE folio = 2) AS detalles,
         (SELECT COUNT(*) FROM ejecucion        WHERE folio = 2) AS ejecuciones,
         (SELECT COUNT(*) FROM uso_refaccion    WHERE folio = 2) AS usos,
         (SELECT COUNT(*) FROM pago             WHERE folio = 2) AS pagos;
  DELETE FROM orden_servicio WHERE folio = 2;
  SELECT 'despues' AS momento,
         (SELECT COUNT(*) FROM detalle_servicio WHERE folio = 2) AS detalles,
         (SELECT COUNT(*) FROM ejecucion        WHERE folio = 2) AS ejecuciones,
         (SELECT COUNT(*) FROM uso_refaccion    WHERE folio = 2) AS usos,
         (SELECT COUNT(*) FROM pago             WHERE folio = 2) AS pagos;
ROLLBACK;

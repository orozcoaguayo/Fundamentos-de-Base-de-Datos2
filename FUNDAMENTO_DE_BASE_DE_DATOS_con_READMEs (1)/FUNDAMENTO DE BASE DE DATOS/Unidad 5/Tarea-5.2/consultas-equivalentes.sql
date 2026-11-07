-- =====================================================================
--  consultas-equivalentes.sql  |  Base de datos: taller_automotriz
--  Unidad 5, Tarea 5.2: SQL equivalente a cada expresión de álgebra relacional
--  Ejecutar después de schema.sql y datos-prueba.sql (PostgreSQL 14+).
--  Los resultados coinciden con los del simulador algebra_relacional.py.
-- =====================================================================

-- Consulta 1: Órdenes en proceso (Básica)
-- Requerimiento: Mostrar todas las órdenes de servicio cuyo estado es EN_PROCESO.
-- RelaX: sigma estado = 'EN_PROCESO' (orden_servicio)
SELECT * FROM orden_servicio WHERE estado = 'EN_PROCESO';

-- Consulta 2: Datos de contacto de los clientes (Básica)
-- Requerimiento: Obtener el nombre, los apellidos y el correo de todos los clientes.
-- RelaX: pi nombre, apellidos, correo (cliente)
SELECT DISTINCT nombre, apellidos, correo FROM cliente;

-- Consulta 3: Vehículos recientes (Básica)
-- Requerimiento: Listar la placa, marca y modelo de los vehículos del año 2018 en adelante.
-- RelaX: pi placa, marca, modelo (sigma anio >= 2018 (vehiculo))
SELECT DISTINCT placa, marca, modelo FROM vehiculo WHERE anio >= 2018;

-- Consulta 4: Clientes y sus vehículos (Básica)
-- Requerimiento: Mostrar el nombre de cada cliente junto con la placa de sus vehículos.
-- RelaX: pi nombre, apellidos, placa (cliente natural join vehiculo)
SELECT DISTINCT c.nombre, c.apellidos, v.placa FROM cliente c JOIN vehiculo v ON v.id_cliente = c.id_cliente;

-- Consulta 5: Servicios de una orden (Intermedia)
-- Requerimiento: Obtener el nombre y el precio base de los servicios incluidos en la orden con folio 2.
-- RelaX: pi nombre, precio_base (sigma folio = 2 (detalle_servicio) natural join servicio)
SELECT DISTINCT s.nombre, s.precio_base FROM detalle_servicio d JOIN servicio s ON s.id_servicio = d.id_servicio WHERE d.folio = 2;

-- Consulta 6: Clientes con vehículos en servicio (Avanzada)
-- Requerimiento: Obtener el nombre del cliente y la placa de los vehículos cuya orden está EN_PROCESO.
-- RelaX: pi nombre, apellidos, placa ((sigma estado = 'EN_PROCESO' (orden_servicio)) natural join vehiculo natural join cliente)
SELECT DISTINCT c.nombre, c.apellidos, v.placa FROM orden_servicio o JOIN vehiculo v ON v.num_serie = o.num_serie JOIN cliente c ON c.id_cliente = v.id_cliente WHERE o.estado = 'EN_PROCESO';

-- Consulta 7: Empleados que ganan más que un recepcionista (Avanzada)
-- Requerimiento: Obtener el nombre y el salario de los empleados que ganan más que algún recepcionista (producto cartesiano y renombrado).
-- RelaX: pi e1.nombre, e1.salario (sigma e1.salario > e2.salario and e2.tipo = 'RECEPCIONISTA' ((rho e1 (empleado)) cross join (rho e2 (empleado))))
SELECT DISTINCT e1.nombre, e1.salario FROM empleado e1, empleado e2 WHERE e1.salario > e2.salario AND e2.tipo = 'RECEPCIONISTA';

-- Consulta 8: Correos de clientes y proveedores (Intermedia)
-- Requerimiento: Obtener una lista única con todos los correos de clientes y de proveedores.
-- RelaX: (pi correo (cliente)) union (pi correo (proveedor))
SELECT correo FROM cliente UNION SELECT correo FROM proveedor;

-- Consulta 9: Clientes sin órdenes terminadas (Intermedia)
-- Requerimiento: Obtener los clientes que tienen vehículos registrados pero ninguna orden en estado TERMINADA.
-- RelaX: pi nombre, apellidos (cliente natural join ((pi id_cliente (vehiculo)) \ (pi id_cliente (sigma estado = 'TERMINADA' (orden_servicio) natural join vehiculo))))
SELECT DISTINCT c.nombre, c.apellidos FROM cliente c WHERE c.id_cliente IN (SELECT id_cliente FROM vehiculo EXCEPT SELECT v.id_cliente FROM orden_servicio o JOIN vehiculo v ON v.num_serie = o.num_serie WHERE o.estado = 'TERMINADA');

-- Consulta 10: Servicios comunes a dos órdenes (Intermedia)
-- Requerimiento: Obtener el nombre de los servicios que se realizaron tanto en la orden 1 como en la orden 2.
-- RelaX: pi nombre (servicio natural join ((pi id_servicio (sigma folio = 1 (detalle_servicio))) intersect (pi id_servicio (sigma folio = 2 (detalle_servicio)))))
SELECT DISTINCT s.nombre FROM servicio s WHERE s.id_servicio IN (SELECT id_servicio FROM detalle_servicio WHERE folio = 1 INTERSECT SELECT id_servicio FROM detalle_servicio WHERE folio = 2);

-- Consulta 11: Mecánicos que ejecutaron todos los servicios de una orden (Avanzada)
-- Requerimiento: Obtener los mecánicos que han ejecutado todos los servicios incluidos en la orden 2 (división).
-- RelaX: pi nombre (empleado natural join ((pi id_empleado, id_servicio (ejecucion)) / (pi id_servicio (sigma folio = 2 (detalle_servicio)))))
SELECT DISTINCT e.nombre FROM empleado e WHERE e.id_empleado IN (SELECT id_empleado FROM (SELECT DISTINCT id_empleado, id_servicio FROM ejecucion) x WHERE id_servicio IN (SELECT id_servicio FROM detalle_servicio WHERE folio = 2) GROUP BY id_empleado HAVING COUNT(DISTINCT id_servicio) = (SELECT COUNT(DISTINCT id_servicio) FROM detalle_servicio WHERE folio = 2));

-- Consulta 12: Total pagado por orden (Intermedia)
-- Requerimiento: Calcular el monto total pagado en cada orden de servicio (agregación con agrupamiento).
-- RelaX: gamma folio; sum(monto)->total_pagado (pago)
SELECT folio, SUM(monto) AS total_pagado FROM pago GROUP BY folio;

-- Consulta 13: Resumen general de pagos (Intermedia)
-- Requerimiento: Obtener el número de pagos, el ingreso total, el pago promedio y el pago máximo (agregación sin agrupamiento).
-- RelaX: gamma ; count(num_pago)->num_pagos, sum(monto)->ingresos_totales, avg(monto)->pago_promedio, max(monto)->pago_maximo (pago)
SELECT COUNT(num_pago) AS num_pagos, SUM(monto) AS ingresos_totales, AVG(monto) AS pago_promedio, MAX(monto) AS pago_maximo FROM pago;

-- Consulta 14: Empleados y su especialidad (reunión externa) (Intermedia)
-- Requerimiento: Mostrar a todos los empleados con su especialidad; quienes no son mecánicos deben aparecer con especialidad nula.
-- RelaX: pi nombre, tipo, especialidad (empleado natural left outer join mecanico)
SELECT e.nombre, e.tipo, m.especialidad FROM empleado e LEFT JOIN mecanico m ON m.id_empleado = e.id_empleado AND m.tipo = e.tipo;

-- Consulta 15: Cliente, orden y total pagado de órdenes concluidas (Avanzada)
-- Requerimiento: Para las órdenes TERMINADAS o ENTREGADAS, mostrar el nombre del cliente, el folio, el estado y el total pagado.
-- RelaX: pi nombre, apellidos, folio, estado, total_pagado (cliente natural join vehiculo natural join (sigma estado = 'TERMINADA' or estado = 'ENTREGADA' (orden_servicio)) natural join (gamma folio; sum(monto)->total_pagado (pago)))
SELECT c.nombre, c.apellidos, o.folio, o.estado, p.total_pagado FROM cliente c JOIN vehiculo v ON v.id_cliente = c.id_cliente JOIN orden_servicio o ON o.num_serie = v.num_serie JOIN (SELECT folio, SUM(monto) AS total_pagado FROM pago GROUP BY folio) p ON p.folio = o.folio WHERE o.estado IN ('TERMINADA', 'ENTREGADA');

-- Consulta 16: Mecánicos y refacciones de una orden (Avanzada)
-- Requerimiento: Para la orden 1, mostrar qué mecánico ejecutó cada servicio y qué refacciones se usaron, con la cantidad (proyección generalizada con renombrado).
-- RelaX: pi nombre_mecanico, nombre_refaccion, cantidad (sigma folio = 1 (ejecucion natural join uso_refaccion) natural join (rho nombre_mecanico<-nombre (pi id_empleado, nombre (empleado))) natural join (rho nombre_refaccion<-nombre (pi id_refaccion, nombre (refaccion))))
SELECT DISTINCT e.nombre AS nombre_mecanico, r.nombre AS nombre_refaccion, u.cantidad FROM ejecucion x JOIN uso_refaccion u ON u.folio = x.folio AND u.id_servicio = x.id_servicio JOIN empleado e ON e.id_empleado = x.id_empleado JOIN refaccion r ON r.id_refaccion = u.id_refaccion WHERE x.folio = 1;

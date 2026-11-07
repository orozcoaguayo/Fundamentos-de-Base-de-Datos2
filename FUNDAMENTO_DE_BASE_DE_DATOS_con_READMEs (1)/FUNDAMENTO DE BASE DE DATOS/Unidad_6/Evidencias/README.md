# 📸 Evidencias de Ejecución - Unidad 6 SQL

Este directorio contiene (o contendrá) todas las capturas de pantalla que demuestran la ejecución exitosa de los scripts SQL del proyecto **TIENDA**.

---

## 📋 Instrucciones para Capturar Evidencias

A continuación se detallan las 9 evidencias requeridas, con instrucciones precisas sobre qué debe mostrarse en cada captura:

---

### EVIDENCIA_01_schema.png
**Descripción:** Captura de la ejecución exitosa de `01_schema_ddl.sql` en MySQL Workbench.

**Qué debe mostrar:**
- El script `01_schema_ddl.sql` abierto en el editor de MySQL Workbench.
- El panel **Output** (parte inferior) mostrando "Query OK" o mensajes de éxito para la creación de cada tabla: `categorias`, `clientes`, `productos`, `pedidos` y `detalle_pedido`.
- El panel **Navigator** (izquierda) mostrando la base de datos `tienda` y sus 5 tablas recién creadas.
- Sin mensajes de error (ningún texto en rojo en el Output).

**Pasos para capturarla:**
1. Ejecuta el script completo con **Ctrl+Shift+Enter**.
2. Espera a que termine la ejecución.
3. Haz clic en el panel Output para asegurarte de que sea visible.
4. Presiona **F5** en el Navigator para refrescar y ver las tablas.
5. Toma la captura con `Win+Shift+S` (Windows), `Cmd+Shift+4` (macOS) o tu herramienta preferida.

---

### EVIDENCIA_02_datos.png
**Descripción:** Captura mostrando los datos insertados correctamente tras ejecutar `02_data_inserts.sql`.

**Qué debe mostrar:**
- El panel Output con los mensajes de éxito del script de inserción (filas afectadas por tabla).
- Opcionalmente: el resultado de un `SELECT COUNT(*) FROM clientes;` u otra tabla para confirmar que los datos están presentes.

**Pasos para capturarla:**
1. Ejecuta `02_data_inserts.sql` con **Ctrl+Shift+Enter**.
2. Verifica el panel Output (debe mostrar las inserciones exitosas).
3. Ejecuta `SELECT COUNT(*) FROM clientes; SELECT COUNT(*) FROM productos;` para confirmar.
4. Toma la captura mostrando ambos: el Output y/o los resultados del SELECT COUNT.

---

### EVIDENCIA_03_select_clientes.png
**Descripción:** Resultado del `SELECT * FROM clientes` mostrando todos los registros de la tabla.

**Qué debe mostrar:**
- La consulta `SELECT * FROM clientes;` escrita en el editor.
- La cuadrícula de resultados (Result Grid) con todos los clientes insertados.
- Columnas visibles: `id_cliente`, `nombre`, `apellido`, `email`, `telefono`, `ciudad`.

**Pasos para capturarla:**
1. Escribe o selecciona la consulta: `SELECT * FROM clientes;`
2. Ejecuta con **Ctrl+Enter** (solo la línea seleccionada).
3. Captura la pantalla asegurándote de que el Result Grid sea visible completo.

---

### EVIDENCIA_04_select_productos.png
**Descripción:** Resultado de la consulta de productos con sus categorías usando JOIN.

**Qué debe mostrar:**
- La consulta JOIN entre `productos` y `categorias` en el editor.
- El Result Grid con columnas de ambas tablas: nombre del producto, precio, stock, nombre de la categoría.

**Consulta a ejecutar:**
```sql
SELECT p.id_producto, p.nombre AS producto,
       c.nombre AS categoria, p.precio, p.stock
FROM productos p
INNER JOIN categorias c ON p.id_categoria = c.id_categoria
ORDER BY c.nombre, p.nombre;
```

---

### EVIDENCIA_05_aggregaciones.png
**Descripción:** Resultado de consultas con funciones de agregación (COUNT, SUM, AVG).

**Qué debe mostrar:**
- Una o más consultas de agregación en el editor.
- El Result Grid con los resultados calculados (totales, promedios, conteos).

**Consultas sugeridas:**
```sql
SELECT COUNT(*) AS total_clientes FROM clientes;
SELECT COUNT(*) AS total_productos FROM productos;
SELECT AVG(precio) AS precio_promedio, MAX(precio) AS precio_maximo,
       MIN(precio) AS precio_minimo FROM productos;
SELECT SUM(total) AS ventas_totales FROM pedidos WHERE estado = 'entregado';
```

---

### EVIDENCIA_06_joins.png
**Descripción:** Resultado de operaciones INNER JOIN y LEFT JOIN.

**Qué debe mostrar:**
- Una consulta INNER JOIN y/o LEFT JOIN compleja.
- El Result Grid con datos combinados de múltiples tablas.
- Preferiblemente que muestre también los registros NULL del LEFT JOIN (clientes sin pedidos, si los hay).

**Consulta sugerida:**
```sql
-- LEFT JOIN para ver clientes con y sin pedidos
SELECT CONCAT(c.nombre, ' ', c.apellido) AS cliente,
       c.ciudad, p.id_pedido, p.fecha_pedido, p.total
FROM clientes c
LEFT JOIN pedidos p ON c.id_cliente = p.id_cliente
ORDER BY c.apellido;
```

---

### EVIDENCIA_07_update.png
**Descripción:** Resultado del UPDATE controlado sobre un registro.

**Qué debe mostrar:**
- La sentencia UPDATE en el editor.
- El mensaje de éxito en el Output (ej. "1 row(s) affected").
- Opcionalmente: un SELECT antes y después del UPDATE para mostrar el cambio.

**Consulta sugerida:**
```sql
-- Ver antes
SELECT id_producto, nombre, precio FROM productos WHERE id_producto = 1;

-- Ejecutar el UPDATE
UPDATE productos SET precio = 999.99 WHERE id_producto = 1;

-- Ver después
SELECT id_producto, nombre, precio FROM productos WHERE id_producto = 1;
```

---

### EVIDENCIA_08_delete.png
**Descripción:** Resultado del DELETE con ROLLBACK para demostrar el uso de transacciones.

**Qué debe mostrar:**
- El bloque completo `START TRANSACTION / DELETE / SELECT / ROLLBACK` en el editor.
- El Output mostrando cada paso ejecutado exitosamente.
- El SELECT posterior al ROLLBACK confirmando que el registro fue restaurado.

**Consulta sugerida:**
```sql
START TRANSACTION;
-- Ver el registro antes de eliminarlo
SELECT * FROM clientes WHERE id_cliente = 10;
-- Eliminar (dentro de la transacción)
DELETE FROM clientes WHERE id_cliente = 10;
-- Confirmar que fue eliminado temporalmente
SELECT COUNT(*) AS clientes_tras_delete FROM clientes;
-- Revertir el cambio
ROLLBACK;
-- Confirmar que fue restaurado
SELECT COUNT(*) AS clientes_tras_rollback FROM clientes;
```

---

### EVIDENCIA_09_diagrama_er.png
**Descripción:** Diagrama Entidad-Relación (ER) generado en MySQL Workbench mediante Reverse Engineer.

**Qué debe mostrar:**
- El diagrama ER completo con las 5 tablas de la base de datos `tienda`.
- Las relaciones (líneas de cardinalidad) entre las tablas.
- Los nombres de las columnas y sus tipos de datos visibles en cada entidad.

**Pasos para generarlo:**
1. En MySQL Workbench, ve al menú: **Database → Reverse Engineer** (Ctrl+R).
2. Selecciona tu conexión y haz clic en **Next**.
3. Selecciona la base de datos `tienda` y haz clic en **Next**.
4. Acepta las opciones predeterminadas y haz clic en **Execute**.
5. Al finalizar, se abrirá el diagrama EER automáticamente.
6. Ajusta la posición de las tablas para que el diagrama quede claro y ordenado.
7. Toma la captura de pantalla del diagrama completo.

---

## 📸 Cómo Tomar las Capturas en MySQL Workbench

### En Windows:
- **Método 1:** `Win + Shift + S` → Recorte y boceto (te permite seleccionar el área).
- **Método 2:** `PrtScn` (captura toda la pantalla) + pegar en Paint o PowerPoint.
- **Método 3:** Usar la herramienta **Snipping Tool** buscándola en el menú Inicio.
- **Método 4:** Usar **Lightshot**, **Greenshot** o **ShareX** (herramientas gratuitas).

### En macOS:
- `Cmd + Shift + 4` → Seleccionar área específica.
- `Cmd + Shift + 3` → Captura de pantalla completa.

### En Linux:
- `PrtScn` o la herramienta **Flameshot** (`flameshot gui`).

### Recomendaciones generales:
- Guarda todas las capturas en esta misma carpeta (`Evidencias/`).
- Usa el nombre exacto indicado para cada evidencia (ej. `EVIDENCIA_01_schema.png`).
- Asegúrate de que el texto en las capturas sea **legible** (zoom al 100% en Workbench).
- Formato recomendado: **PNG** (mejor calidad).

---

## 📊 Estado de Evidencias

| # | Evidencia                            | Descripción                                      | Estado         |
|---|--------------------------------------|--------------------------------------------------|----------------|
| 1 | `EVIDENCIA_01_schema.png`            | Ejecución exitosa de 01_schema_ddl.sql           | ⏳ PENDIENTE   |
| 2 | `EVIDENCIA_02_datos.png`             | Datos insertados correctamente                   | ⏳ PENDIENTE   |
| 3 | `EVIDENCIA_03_select_clientes.png`   | SELECT * FROM clientes                           | ⏳ PENDIENTE   |
| 4 | `EVIDENCIA_04_select_productos.png`  | SELECT productos con JOIN de categorías          | ⏳ PENDIENTE   |
| 5 | `EVIDENCIA_05_aggregaciones.png`     | Consultas con COUNT, SUM, AVG                    | ⏳ PENDIENTE   |
| 6 | `EVIDENCIA_06_joins.png`             | INNER JOIN y LEFT JOIN                           | ⏳ PENDIENTE   |
| 7 | `EVIDENCIA_07_update.png`            | UPDATE controlado con verificación               | ⏳ PENDIENTE   |
| 8 | `EVIDENCIA_08_delete.png`            | DELETE con START TRANSACTION y ROLLBACK          | ⏳ PENDIENTE   |
| 9 | `EVIDENCIA_09_diagrama_er.png`       | Diagrama ER generado en MySQL Workbench          | ⏳ PENDIENTE   |

---

> 💡 **Tip:** Una vez que captures y guardes cada evidencia en esta carpeta, actualiza la tabla cambiando `⏳ PENDIENTE` por `✅ COMPLETADA`.

---

<div align="center">

📸 *Evidencias — Unidad 6 SQL — Noviembre 2026*

</div>

-- =============================================================================
-- PROYECTO   : Unidad 6 - Introducción al lenguaje SQL
-- ARCHIVO    : 01_schema_ddl.sql  (DDL – Definición del esquema)
-- BASE DATOS : TIENDA
-- AUTOR      : [MI NOMBRE]
-- DOCENTE    : [NOMBRE DEL MAESTRO]
-- FECHA      : 2026-11-06
-- MOTOR      : MySQL 8.0
-- DESCRIPCIÓN: Creación completa de la base de datos TIENDA y sus cinco
--              tablas: categorias, clientes, productos, ventas y
--              detalle_venta.  Incluye restricciones de integridad
--              (PRIMARY KEY, UNIQUE, CHECK, FOREIGN KEY) y comentarios
--              explicativos en cada objeto.
-- =============================================================================

-- =========================================================
-- 0. ELIMINAR Y RECREAR LA BASE DE DATOS
-- =========================================================

DROP DATABASE IF EXISTS TIENDA;

CREATE DATABASE TIENDA
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_spanish_ci
    COMMENT 'Base de datos académica para la gestión de una tienda';

USE TIENDA;

-- =========================================================
-- 1. TABLA: categorias
--    Catálogo de categorías a las que pertenecen los
--    productos.  Es la primera tabla en crearse porque
--    "productos" depende de ella mediante FK.
-- =========================================================

CREATE TABLE categorias (
    id_categoria  INT           NOT NULL AUTO_INCREMENT,
    nombre        VARCHAR(80)   NOT NULL,
    descripcion   TEXT              DEFAULT NULL,
    activa        TINYINT(1)    NOT NULL DEFAULT 1,
    fecha_creacion TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Restricciones de columna
    CONSTRAINT pk_categorias        PRIMARY KEY (id_categoria),
    CONSTRAINT uq_categorias_nombre UNIQUE      (nombre),
    CONSTRAINT ck_categorias_activa CHECK       (activa IN (0, 1))
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_spanish_ci
  COMMENT = 'Catálogo de categorías de productos';

-- =========================================================
-- 2. TABLA: clientes
--    Información de los clientes registrados en la tienda.
--    No tiene dependencias de otras tablas, por eso se
--    crea antes que "ventas".
-- =========================================================

CREATE TABLE clientes (
    id_cliente      INT          NOT NULL AUTO_INCREMENT,
    nombre          VARCHAR(100) NOT NULL,
    apellido        VARCHAR(100) NOT NULL,
    email           VARCHAR(150) NOT NULL,
    telefono        VARCHAR(20)      DEFAULT NULL,
    direccion       VARCHAR(250)     DEFAULT NULL,
    ciudad          VARCHAR(80)      DEFAULT 'Ciudad de México',
    fecha_registro  DATE         NOT NULL DEFAULT (CURRENT_DATE),
    activo          TINYINT(1)   NOT NULL DEFAULT 1,

    -- Restricciones de columna
    CONSTRAINT pk_clientes        PRIMARY KEY (id_cliente),
    CONSTRAINT uq_clientes_email  UNIQUE      (email),
    CONSTRAINT ck_clientes_activo CHECK       (activo IN (0, 1))
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_spanish_ci
  COMMENT = 'Clientes registrados en la tienda';

-- =========================================================
-- 3. TABLA: productos
--    Inventario de productos disponibles.  Referencia la
--    tabla "categorias" a través de la FK id_categoria.
-- =========================================================

CREATE TABLE productos (
    id_producto  INT            NOT NULL AUTO_INCREMENT,
    nombre       VARCHAR(150)   NOT NULL,
    descripcion  TEXT               DEFAULT NULL,
    precio       DECIMAL(10, 2) NOT NULL,
    stock        INT            NOT NULL DEFAULT 0,
    id_categoria INT            NOT NULL,
    codigo_sku   VARCHAR(50)    NOT NULL,
    activo       TINYINT(1)     NOT NULL DEFAULT 1,
    fecha_alta   TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Restricciones de columna
    CONSTRAINT pk_productos         PRIMARY KEY (id_producto),
    CONSTRAINT uq_productos_sku     UNIQUE      (codigo_sku),
    CONSTRAINT ck_productos_precio  CHECK       (precio > 0),
    CONSTRAINT ck_productos_stock   CHECK       (stock  >= 0),
    CONSTRAINT ck_productos_activo  CHECK       (activo IN (0, 1)),

    -- Llave foránea hacia categorias
    CONSTRAINT fk_productos_categoria
        FOREIGN KEY (id_categoria)
        REFERENCES categorias (id_categoria)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_spanish_ci
  COMMENT = 'Inventario de productos de la tienda';

-- =========================================================
-- 4. TABLA: ventas
--    Encabezado de cada transacción de venta.  Referencia
--    la tabla "clientes" a través de la FK id_cliente.
-- =========================================================

CREATE TABLE ventas (
    id_venta    INT                                      NOT NULL AUTO_INCREMENT,
    id_cliente  INT                                      NOT NULL,
    fecha_venta DATETIME                                 NOT NULL DEFAULT CURRENT_TIMESTAMP,
    total       DECIMAL(12, 2)                           NOT NULL DEFAULT 0.00,
    estado      ENUM('pendiente', 'completada', 'cancelada') NOT NULL DEFAULT 'pendiente',
    notas       TEXT                                         DEFAULT NULL,

    -- Restricciones de columna
    CONSTRAINT pk_ventas       PRIMARY KEY (id_venta),
    CONSTRAINT ck_ventas_total CHECK       (total >= 0),

    -- Llave foránea hacia clientes
    CONSTRAINT fk_ventas_cliente
        FOREIGN KEY (id_cliente)
        REFERENCES clientes (id_cliente)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_spanish_ci
  COMMENT = 'Encabezado de ventas realizadas en la tienda';

-- =========================================================
-- 5. TABLA: detalle_venta
--    Líneas de producto de cada venta.  Referencia tanto
--    "ventas" (con CASCADE) como "productos" (con RESTRICT).
--    La columna "subtotal" es generada (GENERATED ALWAYS AS).
-- =========================================================

CREATE TABLE detalle_venta (
    id_detalle      INT            NOT NULL AUTO_INCREMENT,
    id_venta        INT            NOT NULL,
    id_producto     INT            NOT NULL,
    cantidad        INT            NOT NULL,
    precio_unitario DECIMAL(10, 2) NOT NULL,
    subtotal        DECIMAL(12, 2)
                        GENERATED ALWAYS AS (cantidad * precio_unitario) STORED,

    -- Restricciones de columna
    CONSTRAINT pk_detalle_venta        PRIMARY KEY (id_detalle),
    CONSTRAINT uq_venta_producto       UNIQUE      (id_venta, id_producto),
    CONSTRAINT ck_detalle_cantidad     CHECK       (cantidad        > 0),
    CONSTRAINT ck_detalle_precio_unit  CHECK       (precio_unitario > 0),

    -- Llave foránea hacia ventas (CASCADE: si se borra una venta, se borran sus líneas)
    CONSTRAINT fk_detalle_venta
        FOREIGN KEY (id_venta)
        REFERENCES ventas (id_venta)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    -- Llave foránea hacia productos (RESTRICT: no se puede borrar un producto con líneas)
    CONSTRAINT fk_detalle_producto
        FOREIGN KEY (id_producto)
        REFERENCES productos (id_producto)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_spanish_ci
  COMMENT = 'Líneas de detalle de cada venta (productos vendidos)';

-- =========================================================
-- 6. VERIFICACIONES POST-CREACIÓN
-- =========================================================

-- 6.1  Listar todas las tablas creadas en la base de datos TIENDA
SHOW TABLES;

-- 6.2  Verificar las llaves foráneas registradas en INFORMATION_SCHEMA
SELECT
    TABLE_NAME        AS 'Tabla hija',
    COLUMN_NAME       AS 'Columna FK',
    CONSTRAINT_NAME   AS 'Nombre constraint',
    REFERENCED_TABLE_NAME  AS 'Tabla referenciada',
    REFERENCED_COLUMN_NAME AS 'Columna referenciada'
FROM
    INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE
    TABLE_SCHEMA            = 'TIENDA'
    AND REFERENCED_TABLE_NAME IS NOT NULL
ORDER BY
    TABLE_NAME, COLUMN_NAME;

-- 6.3  Mostrar la estructura completa de cada tabla
DESCRIBE categorias;
DESCRIBE clientes;
DESCRIBE productos;
DESCRIBE ventas;
DESCRIBE detalle_venta;

-- =============================================================================
-- FIN DEL ARCHIVO 01_schema_ddl.sql
-- =============================================================================

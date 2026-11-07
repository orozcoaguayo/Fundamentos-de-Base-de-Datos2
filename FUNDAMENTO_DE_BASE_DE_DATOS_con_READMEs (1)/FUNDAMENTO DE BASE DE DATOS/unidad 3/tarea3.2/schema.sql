-- =====================================================================
--  schema.sql  |  Base de datos: taller_automotriz
--  Unidad 3, Tarea 3.2: esquema físico (script DDL)
--  SGBD: PostgreSQL 14 o superior
--  Uso:  psql -U postgres -d taller_automotriz -f schema.sql
--  El script es re-ejecutable: elimina los objetos previos y los vuelve a crear.
-- =====================================================================

BEGIN;

-- ---------------------------------------------------------------------
--  0. Limpieza (orden inverso a las dependencias)
-- ---------------------------------------------------------------------
DROP VIEW  IF EXISTS vw_orden_total          CASCADE;
DROP VIEW  IF EXISTS vw_empleado_antiguedad  CASCADE;
DROP VIEW  IF EXISTS vw_vehiculo_antiguedad  CASCADE;
DROP TABLE IF EXISTS pago                   CASCADE;
DROP TABLE IF EXISTS uso_refaccion          CASCADE;
DROP TABLE IF EXISTS ejecucion              CASCADE;
DROP TABLE IF EXISTS detalle_servicio       CASCADE;
DROP TABLE IF EXISTS orden_servicio         CASCADE;
DROP TABLE IF EXISTS refaccion              CASCADE;
DROP TABLE IF EXISTS proveedor              CASCADE;
DROP TABLE IF EXISTS servicio               CASCADE;
DROP TABLE IF EXISTS mecanico_certificacion CASCADE;
DROP TABLE IF EXISTS almacenista            CASCADE;
DROP TABLE IF EXISTS mecanico               CASCADE;
DROP TABLE IF EXISTS recepcionista          CASCADE;
DROP TABLE IF EXISTS empleado               CASCADE;
DROP TABLE IF EXISTS vehiculo               CASCADE;
DROP TABLE IF EXISTS cliente_telefono       CASCADE;
DROP TABLE IF EXISTS cliente                CASCADE;

-- ---------------------------------------------------------------------
--  1. Clientes y vehículos
-- ---------------------------------------------------------------------
CREATE TABLE cliente (
    id_cliente  INTEGER GENERATED ALWAYS AS IDENTITY,
    nombre      VARCHAR(60)  NOT NULL,
    apellidos   VARCHAR(80)  NOT NULL,
    correo      VARCHAR(100) NOT NULL,
    CONSTRAINT pk_cliente        PRIMARY KEY (id_cliente),
    CONSTRAINT uq_cliente_correo UNIQUE (correo),
    CONSTRAINT ck_cliente_correo CHECK (correo LIKE '%_@_%._%')
);

-- Atributo multivalorado "teléfono" de CLIENTE
CREATE TABLE cliente_telefono (
    id_cliente  INTEGER     NOT NULL,
    telefono    VARCHAR(15) NOT NULL,
    CONSTRAINT pk_cliente_telefono PRIMARY KEY (id_cliente, telefono),
    CONSTRAINT fk_clitel_cliente   FOREIGN KEY (id_cliente)
        REFERENCES cliente (id_cliente) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT ck_clitel_telefono  CHECK (telefono ~ '^[0-9]{10,15}$')
);

CREATE TABLE vehiculo (
    num_serie    VARCHAR(17) NOT NULL,
    placa        VARCHAR(10) NOT NULL,
    marca        VARCHAR(40) NOT NULL,
    modelo       VARCHAR(40) NOT NULL,
    anio         SMALLINT    NOT NULL,
    kilometraje  INTEGER     NOT NULL DEFAULT 0,
    id_cliente   INTEGER     NOT NULL,
    CONSTRAINT pk_vehiculo         PRIMARY KEY (num_serie),
    CONSTRAINT uq_vehiculo_placa   UNIQUE (placa),
    CONSTRAINT ck_vehiculo_serie   CHECK (LENGTH(num_serie) = 17),
    CONSTRAINT ck_vehiculo_anio    CHECK (anio BETWEEN 1950 AND 2100),
    CONSTRAINT ck_vehiculo_km      CHECK (kilometraje >= 0),
    CONSTRAINT fk_vehiculo_cliente FOREIGN KEY (id_cliente)
        REFERENCES cliente (id_cliente) ON UPDATE CASCADE ON DELETE RESTRICT
);

-- ---------------------------------------------------------------------
--  2. Empleados: especialización disjunta y total (tabla por subclase)
--     La columna "tipo" y la clave foránea compuesta (id_empleado, tipo)
--     garantizan que un empleado pertenezca a un solo tipo.
-- ---------------------------------------------------------------------
CREATE TABLE empleado (
    id_empleado         INTEGER GENERATED ALWAYS AS IDENTITY,
    nombre              VARCHAR(100)  NOT NULL,
    fecha_contratacion  DATE          NOT NULL DEFAULT CURRENT_DATE,
    salario             NUMERIC(10,2) NOT NULL,
    tipo                VARCHAR(15)   NOT NULL,
    CONSTRAINT pk_empleado        PRIMARY KEY (id_empleado),
    CONSTRAINT uq_empleado_tipo   UNIQUE (id_empleado, tipo),
    CONSTRAINT ck_empleado_salario CHECK (salario >= 0),
    CONSTRAINT ck_empleado_tipo   CHECK (tipo IN ('RECEPCIONISTA', 'MECANICO', 'ALMACENISTA'))
);

CREATE TABLE recepcionista (
    id_empleado  INTEGER     NOT NULL,
    tipo         VARCHAR(15) NOT NULL DEFAULT 'RECEPCIONISTA',
    turno        VARCHAR(10) NOT NULL,
    CONSTRAINT pk_recepcionista      PRIMARY KEY (id_empleado),
    CONSTRAINT ck_recepcionista_tipo CHECK (tipo = 'RECEPCIONISTA'),
    CONSTRAINT ck_recepcionista_turno CHECK (turno IN ('MATUTINO', 'VESPERTINO', 'NOCTURNO')),
    CONSTRAINT fk_recepcionista_empleado FOREIGN KEY (id_empleado, tipo)
        REFERENCES empleado (id_empleado, tipo) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE mecanico (
    id_empleado   INTEGER     NOT NULL,
    tipo          VARCHAR(15) NOT NULL DEFAULT 'MECANICO',
    especialidad  VARCHAR(60) NOT NULL,
    CONSTRAINT pk_mecanico      PRIMARY KEY (id_empleado),
    CONSTRAINT ck_mecanico_tipo CHECK (tipo = 'MECANICO'),
    CONSTRAINT fk_mecanico_empleado FOREIGN KEY (id_empleado, tipo)
        REFERENCES empleado (id_empleado, tipo) ON UPDATE CASCADE ON DELETE CASCADE
);

-- Atributo multivalorado "certificaciones" de MECÁNICO
CREATE TABLE mecanico_certificacion (
    id_empleado    INTEGER      NOT NULL,
    certificacion  VARCHAR(80)  NOT NULL,
    CONSTRAINT pk_mecanico_certificacion PRIMARY KEY (id_empleado, certificacion),
    CONSTRAINT fk_meccert_mecanico FOREIGN KEY (id_empleado)
        REFERENCES mecanico (id_empleado) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE almacenista (
    id_empleado   INTEGER     NOT NULL,
    tipo          VARCHAR(15) NOT NULL DEFAULT 'ALMACENISTA',
    area_almacen  VARCHAR(60) NOT NULL,
    CONSTRAINT pk_almacenista      PRIMARY KEY (id_empleado),
    CONSTRAINT ck_almacenista_tipo CHECK (tipo = 'ALMACENISTA'),
    CONSTRAINT fk_almacenista_empleado FOREIGN KEY (id_empleado, tipo)
        REFERENCES empleado (id_empleado, tipo) ON UPDATE CASCADE ON DELETE CASCADE
);

-- ---------------------------------------------------------------------
--  3. Catálogos: servicios, proveedores y refacciones
-- ---------------------------------------------------------------------
CREATE TABLE servicio (
    id_servicio   INTEGER GENERATED ALWAYS AS IDENTITY,
    nombre        VARCHAR(80)   NOT NULL,
    precio_base   NUMERIC(10,2) NOT NULL,
    duracion_hrs  NUMERIC(4,1)  NOT NULL,
    CONSTRAINT pk_servicio          PRIMARY KEY (id_servicio),
    CONSTRAINT uq_servicio_nombre   UNIQUE (nombre),
    CONSTRAINT ck_servicio_precio   CHECK (precio_base >= 0),
    CONSTRAINT ck_servicio_duracion CHECK (duracion_hrs > 0)
);

CREATE TABLE proveedor (
    id_proveedor  INTEGER GENERATED ALWAYS AS IDENTITY,
    razon_social  VARCHAR(100) NOT NULL,
    telefono      VARCHAR(15),
    correo        VARCHAR(100),
    CONSTRAINT pk_proveedor        PRIMARY KEY (id_proveedor),
    CONSTRAINT uq_proveedor_razon  UNIQUE (razon_social)
);

CREATE TABLE refaccion (
    id_refaccion     INTEGER GENERATED ALWAYS AS IDENTITY,
    nombre           VARCHAR(80)   NOT NULL,
    marca            VARCHAR(40),
    precio_unitario  NUMERIC(10,2) NOT NULL,
    existencia       INTEGER       NOT NULL DEFAULT 0,
    id_proveedor     INTEGER       NOT NULL,
    CONSTRAINT pk_refaccion            PRIMARY KEY (id_refaccion),
    CONSTRAINT ck_refaccion_precio     CHECK (precio_unitario >= 0),
    CONSTRAINT ck_refaccion_existencia CHECK (existencia >= 0),
    CONSTRAINT fk_refaccion_proveedor  FOREIGN KEY (id_proveedor)
        REFERENCES proveedor (id_proveedor) ON UPDATE CASCADE ON DELETE RESTRICT
);

-- ---------------------------------------------------------------------
--  4. Órdenes de servicio y agregación INCLUYE
-- ---------------------------------------------------------------------
CREATE TABLE orden_servicio (
    folio             INTEGER GENERATED ALWAYS AS IDENTITY,
    fecha_ingreso     DATE        NOT NULL DEFAULT CURRENT_DATE,
    fecha_entrega     DATE,
    estado            VARCHAR(12) NOT NULL DEFAULT 'RECIBIDA',
    num_serie         VARCHAR(17) NOT NULL,
    id_recepcionista  INTEGER     NOT NULL,
    CONSTRAINT pk_orden_servicio  PRIMARY KEY (folio),
    CONSTRAINT ck_orden_estado    CHECK (estado IN ('RECIBIDA', 'EN_PROCESO', 'TERMINADA', 'ENTREGADA', 'CANCELADA')),
    CONSTRAINT ck_orden_fechas    CHECK (fecha_entrega IS NULL OR fecha_entrega >= fecha_ingreso),
    CONSTRAINT fk_orden_vehiculo  FOREIGN KEY (num_serie)
        REFERENCES vehiculo (num_serie) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_orden_recepcionista FOREIGN KEY (id_recepcionista)
        REFERENCES recepcionista (id_empleado) ON UPDATE CASCADE ON DELETE RESTRICT
);

-- Relación M:N INCLUYE (ORDEN_SERVICIO - SERVICIO); también es la agregación
CREATE TABLE detalle_servicio (
    folio        INTEGER NOT NULL,
    id_servicio  INTEGER NOT NULL,
    CONSTRAINT pk_detalle_servicio PRIMARY KEY (folio, id_servicio),
    CONSTRAINT fk_detalle_orden    FOREIGN KEY (folio)
        REFERENCES orden_servicio (folio) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_detalle_servicio FOREIGN KEY (id_servicio)
        REFERENCES servicio (id_servicio) ON UPDATE CASCADE ON DELETE RESTRICT
);

-- Relación EJECUTA: agregación INCLUYE - MECÁNICO
CREATE TABLE ejecucion (
    folio             INTEGER      NOT NULL,
    id_servicio       INTEGER      NOT NULL,
    id_empleado       INTEGER      NOT NULL,
    horas_trabajadas  NUMERIC(5,2) NOT NULL,
    CONSTRAINT pk_ejecucion        PRIMARY KEY (folio, id_servicio, id_empleado),
    CONSTRAINT ck_ejecucion_horas  CHECK (horas_trabajadas > 0),
    CONSTRAINT fk_ejecucion_detalle  FOREIGN KEY (folio, id_servicio)
        REFERENCES detalle_servicio (folio, id_servicio) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_ejecucion_mecanico FOREIGN KEY (id_empleado)
        REFERENCES mecanico (id_empleado) ON UPDATE CASCADE ON DELETE RESTRICT
);

-- Relación USA: agregación INCLUYE - REFACCIÓN
CREATE TABLE uso_refaccion (
    folio         INTEGER NOT NULL,
    id_servicio   INTEGER NOT NULL,
    id_refaccion  INTEGER NOT NULL,
    cantidad      INTEGER NOT NULL,
    CONSTRAINT pk_uso_refaccion      PRIMARY KEY (folio, id_servicio, id_refaccion),
    CONSTRAINT ck_uso_cantidad       CHECK (cantidad > 0),
    CONSTRAINT fk_uso_detalle        FOREIGN KEY (folio, id_servicio)
        REFERENCES detalle_servicio (folio, id_servicio) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_uso_refaccion      FOREIGN KEY (id_refaccion)
        REFERENCES refaccion (id_refaccion) ON UPDATE CASCADE ON DELETE RESTRICT
);

-- Entidad débil PAGO: su clave incluye la clave de la orden
CREATE TABLE pago (
    folio        INTEGER       NOT NULL,
    num_pago     INTEGER       NOT NULL,
    fecha_pago   DATE          NOT NULL DEFAULT CURRENT_DATE,
    monto        NUMERIC(10,2) NOT NULL,
    metodo_pago  VARCHAR(15)   NOT NULL,
    CONSTRAINT pk_pago         PRIMARY KEY (folio, num_pago),
    CONSTRAINT ck_pago_numero  CHECK (num_pago > 0),
    CONSTRAINT ck_pago_monto   CHECK (monto > 0),
    CONSTRAINT ck_pago_metodo  CHECK (metodo_pago IN ('EFECTIVO', 'TARJETA', 'TRANSFERENCIA')),
    CONSTRAINT fk_pago_orden   FOREIGN KEY (folio)
        REFERENCES orden_servicio (folio) ON UPDATE CASCADE ON DELETE CASCADE
);

-- ---------------------------------------------------------------------
--  5. Vistas para los atributos derivados (no se almacenan)
-- ---------------------------------------------------------------------
CREATE VIEW vw_vehiculo_antiguedad AS
SELECT num_serie, placa, anio,
       EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER - anio AS antiguedad
FROM vehiculo;

CREATE VIEW vw_empleado_antiguedad AS
SELECT id_empleado, nombre, fecha_contratacion,
       EXTRACT(YEAR FROM AGE(CURRENT_DATE, fecha_contratacion))::INTEGER AS antiguedad
FROM empleado;

CREATE VIEW vw_orden_total AS
SELECT o.folio,
       COALESCE((SELECT SUM(s.precio_base)
                   FROM detalle_servicio d
                   JOIN servicio s ON s.id_servicio = d.id_servicio
                  WHERE d.folio = o.folio), 0)
     + COALESCE((SELECT SUM(u.cantidad * r.precio_unitario)
                   FROM uso_refaccion u
                   JOIN refaccion r ON r.id_refaccion = u.id_refaccion
                  WHERE u.folio = o.folio), 0) AS total
FROM orden_servicio o;

COMMIT;

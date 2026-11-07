#!/usr/bin/env python3
"""
algebra_relacional.py  |  Simulador de álgebra relacional (Python estándar, sin dependencias)
Unidad 5, Tarea 5.2: base de datos del taller automotriz.

Implementa los operadores: selección, proyección (generalizada), renombrado, producto cartesiano,
unión, intersección, diferencia, reunión natural y theta, división, agregación (G) y
reuniones externas (izquierda, derecha y completa). Ejecuta el catálogo de 16 consultas
sobre los datos de prueba (los mismos de datos-prueba.sql) e imprime sus resultados.

Uso:  python3 algebra_relacional.py
"""
from itertools import product as _product

class Rel:
    def __init__(self, cols, rows):
        self.cols = list(cols)
        vistos, filas = set(), []
        for r in rows:                      # una relación es un conjunto: sin tuplas duplicadas
            t = tuple(r)
            if t not in vistos: vistos.add(t); filas.append(t)
        self.rows = filas
    def _d(self, t): return dict(zip(self.cols, t))
    # --- operadores unarios ---
    def sel(self, pred):                                   # σ
        return Rel(self.cols, [t for t in self.rows if pred(self._d(t))])
    def proj(self, *items):                                # π (generalizada)
        cols, fs = [], []
        for it in items:
            if isinstance(it, str): cols.append(it); fs.append(lambda d, c=it: d[c])
            else:
                nombre, f = it; cols.append(nombre)
                fs.append((lambda d, c=f: d[c]) if isinstance(f, str) else f)
        return Rel(cols, [tuple(f(self._d(t)) for f in fs) for t in self.rows])
    def ren(self, prefijo=None, **mapa):                   # ρ
        if prefijo: return Rel([f"{prefijo}.{c}" for c in self.cols], self.rows)
        return Rel([mapa.get(c, c) for c in self.cols], self.rows)
    # --- operadores binarios ---
    def prod(self, o):                                     # ×
        assert not set(self.cols) & set(o.cols), "El producto requiere atributos con nombres distintos (use ρ)"
        return Rel(self.cols + o.cols, [a + b for a, b in _product(self.rows, o.rows)])
    def _compat(self, o): assert self.cols == o.cols, "Las relaciones no son compatibles para la unión"
    def union(self, o): self._compat(o); return Rel(self.cols, self.rows + o.rows)          # ∪
    def inter(self, o): self._compat(o); s = set(o.rows); return Rel(self.cols, [t for t in self.rows if t in s])   # ∩
    def diff(self, o): self._compat(o); s = set(o.rows); return Rel(self.cols, [t for t in self.rows if t not in s])  # −
    def join(self, o, theta=None, tipo="inner"):           # ⋈  (natural si theta es None), ⟕ ⟖ ⟗
        if theta is not None:                              # reunión theta: σθ(R × S)
            return self.prod(o).sel(theta)
        com = [c for c in self.cols if c in o.cols]
        resto = [c for c in o.cols if c not in com]
        cols = self.cols + resto; filas, usados = [], set()
        for a in self.rows:
            da = self._d(a); hubo = False
            for j, b in enumerate(o.rows):
                db = o._d(b)
                if all(da[c] == db[c] for c in com):
                    filas.append(a + tuple(db[c] for c in resto)); usados.add(j); hubo = True
            if not hubo and tipo in ("left", "full"):
                filas.append(a + (None,) * len(resto))
        if tipo in ("right", "full"):
            for j, b in enumerate(o.rows):
                if j not in usados:
                    db = o._d(b)
                    filas.append(tuple(db.get(c) if c in com else None for c in self.cols) + tuple(db[c] for c in resto))
        return Rel(cols, filas)
    def div(self, o):                                      # ÷
        x = [c for c in self.cols if c not in o.cols]
        cand = Rel(x, [tuple(self._d(t)[c] for c in x) for t in self.rows])
        r = set(self.rows); res = []
        for t in cand.rows:
            if all(tuple((dict(zip(x, t)) | o._d(s))[c] for c in self.cols) in r for s in o.rows): res.append(t)
        return Rel(x, res)
    def group(self, por, *aggs):                           # G
        fn = {"sum": sum, "avg": lambda v: sum(v) / len(v), "min": min, "max": max, "count": len}
        grupos = {}
        for t in self.rows:
            d = self._d(t); grupos.setdefault(tuple(d[c] for c in por), []).append(d)
        filas = []
        for k, ds in grupos.items():
            filas.append(k + tuple(fn[f]([d[c] for d in ds if d[c] is not None]) for f, c, _ in aggs))
        return Rel(list(por) + [a for _, _, a in aggs], filas)
    def __len__(self): return len(self.rows)

def fmt(v):
    if v is None: return "NULL"
    if isinstance(v, float): return f"{v:.2f}"
    return str(v)

# ----------------------------------------------------------------------------------
#  Instancia de la base de datos (datos-prueba.sql)
# ----------------------------------------------------------------------------------
DATOS = {
 "cliente": (["id_cliente", "nombre", "apellidos", "correo"], [
    (1, "Juan Carlos", "Pérez Gómez", "juan.perez@example.com"), (2, "María Fernanda", "López Ruiz", "maria.lopez@example.com"),
    (3, "Luis Alberto", "Hernández Soto", "luis.hernandez@example.com")]),
 "vehiculo": (["num_serie", "placa", "marca", "modelo", "anio", "kilometraje", "id_cliente"], [
    ("1HGCM82633A004352", "ABC-123-A", "Honda", "Accord", 2018, 85000, 1), ("3VWFE21C04M000001", "XYZ-456-B", "Nissan", "Versa", 2020, 42000, 2),
    ("JT2AE86S3F0123456", "DEF-789-C", "Toyota", "Corolla", 2015, 120000, 3)]),
 "empleado": (["id_empleado", "nombre", "fecha_contratacion", "salario", "tipo"], [
    (1, "Ana Torres", "2021-03-15", 9500.0, "RECEPCIONISTA"), (2, "Roberto Díaz", "2019-08-01", 14000.0, "MECANICO"),
    (3, "Carlos Mendoza", "2022-01-10", 13000.0, "MECANICO"), (4, "Laura Ramírez", "2020-06-20", 10500.0, "ALMACENISTA")]),
 "recepcionista": (["id_empleado", "tipo", "turno"], [(1, "RECEPCIONISTA", "MATUTINO")]),
 "mecanico": (["id_empleado", "tipo", "especialidad"], [(2, "MECANICO", "Motor y transmisión"), (3, "MECANICO", "Frenos y suspensión")]),
 "servicio": (["id_servicio", "nombre", "precio_base", "duracion_hrs"], [
    (1, "Cambio de aceite y filtro", 350.0, 1.0), (2, "Afinación mayor", 1200.0, 3.0), (3, "Cambio de balatas", 500.0, 2.0)]),
 "proveedor": (["id_proveedor", "razon_social", "telefono", "correo"], [
    (1, "AutoPartes del Norte S.A. de C.V.", "5553001000", "ventas@autopartesnorte.example.com"),
    (2, "Lubricantes y Filtros S.A.", "5553002000", "contacto@lubrifiltros.example.com")]),
 "refaccion": (["id_refaccion", "nombre", "marca", "precio_unitario", "existencia", "id_proveedor"], [
    (1, "Filtro de aceite", "Fram", 120.0, 40, 2), (2, "Aceite 5W-30 (1 litro)", "Mobil", 95.0, 100, 2),
    (3, "Balatas delanteras", "Brembo", 650.0, 15, 1), (4, "Bujía", "NGK", 80.0, 60, 1)]),
 "orden_servicio": (["folio", "fecha_ingreso", "fecha_entrega", "estado", "num_serie", "id_recepcionista"], [
    (1, "2026-10-20", "2026-10-20", "ENTREGADA", "1HGCM82633A004352", 1), (2, "2026-10-22", "2026-10-23", "TERMINADA", "3VWFE21C04M000001", 1),
    (3, "2026-10-28", None, "EN_PROCESO", "JT2AE86S3F0123456", 1)]),
 "detalle_servicio": (["folio", "id_servicio"], [(1, 1), (2, 2), (2, 1), (3, 3)]),
 "ejecucion": (["folio", "id_servicio", "id_empleado", "horas_trabajadas"], [(1, 1, 2, 1.0), (2, 2, 2, 3.0), (2, 1, 3, 1.0), (3, 3, 3, 2.0)]),
 "uso_refaccion": (["folio", "id_servicio", "id_refaccion", "cantidad"], [(1, 1, 1, 1), (1, 1, 2, 4), (2, 2, 4, 4), (3, 3, 3, 1)]),
 "pago": (["folio", "num_pago", "fecha_pago", "monto", "metodo_pago"], [
    (1, 1, "2026-10-20", 850.0, "EFECTIVO"), (2, 1, "2026-10-22", 1000.0, "TARJETA"), (2, 2, "2026-10-23", 870.0, "TARJETA"),
    (3, 1, "2026-10-28", 500.0, "TRANSFERENCIA")]),
}
D = {k: Rel(c, r) for k, (c, r) in DATOS.items()}

def consultas():
    """Devuelve el catálogo: lista de dicts con id, titulo, nivel, req, formal (marcado), relax, sql y pasos."""
    d = D; Q = []
    def q(**kw): Q.append(kw)
    # 1
    r = d["orden_servicio"].sel(lambda t: t["estado"] == "EN_PROCESO")
    q(id=1, titulo="Órdenes en proceso", nivel="Básica", req="Mostrar todas las órdenes de servicio cuyo estado es EN_PROCESO.",
      formal="σ<sub>estado='EN_PROCESO'</sub>(orden_servicio)", relax="sigma estado = 'EN_PROCESO' (orden_servicio)",
      sql="SELECT * FROM orden_servicio WHERE estado = 'EN_PROCESO';",
      pasos=[("R", "σ<sub>estado='EN_PROCESO'</sub>(orden_servicio)", r, None)])
    # 2
    r = d["cliente"].proj("nombre", "apellidos", "correo")
    q(id=2, titulo="Datos de contacto de los clientes", nivel="Básica", req="Obtener el nombre, los apellidos y el correo de todos los clientes.",
      formal="π<sub>nombre, apellidos, correo</sub>(cliente)", relax="pi nombre, apellidos, correo (cliente)",
      sql="SELECT DISTINCT nombre, apellidos, correo FROM cliente;", pasos=[("R", "π<sub>nombre, apellidos, correo</sub>(cliente)", r, None)])
    # 3
    t1 = d["vehiculo"].sel(lambda t: t["anio"] >= 2018); r = t1.proj("placa", "marca", "modelo")
    q(id=3, titulo="Vehículos recientes", nivel="Básica", req="Listar la placa, marca y modelo de los vehículos del año 2018 en adelante.",
      formal="π<sub>placa, marca, modelo</sub>(σ<sub>anio ≥ 2018</sub>(vehiculo))", relax="pi placa, marca, modelo (sigma anio >= 2018 (vehiculo))",
      sql="SELECT DISTINCT placa, marca, modelo FROM vehiculo WHERE anio >= 2018;",
      pasos=[("T1", "σ<sub>anio ≥ 2018</sub>(vehiculo)", t1, ["num_serie", "placa", "marca", "modelo", "anio"]), ("R", "π<sub>placa, marca, modelo</sub>(T1)", r, None)])
    # 4
    t1 = d["cliente"].join(d["vehiculo"]); r = t1.proj("nombre", "apellidos", "placa")
    q(id=4, titulo="Clientes y sus vehículos", nivel="Básica", req="Mostrar el nombre de cada cliente junto con la placa de sus vehículos.",
      formal="π<sub>nombre, apellidos, placa</sub>(cliente ⋈ vehiculo)", relax="pi nombre, apellidos, placa (cliente natural join vehiculo)",
      sql="SELECT DISTINCT c.nombre, c.apellidos, v.placa FROM cliente c JOIN vehiculo v ON v.id_cliente = c.id_cliente;",
      pasos=[("T1", "cliente ⋈ vehiculo", t1, ["id_cliente", "nombre", "apellidos", "num_serie", "placa"]), ("R", "π<sub>nombre, apellidos, placa</sub>(T1)", r, None)])
    # 5
    t1 = d["detalle_servicio"].sel(lambda t: t["folio"] == 2); t2 = t1.join(d["servicio"]); r = t2.proj("nombre", "precio_base")
    q(id=5, titulo="Servicios de una orden", nivel="Intermedia", req="Obtener el nombre y el precio base de los servicios incluidos en la orden con folio 2.",
      formal="π<sub>nombre, precio_base</sub>(σ<sub>folio=2</sub>(detalle_servicio) ⋈ servicio)", relax="pi nombre, precio_base (sigma folio = 2 (detalle_servicio) natural join servicio)",
      sql="SELECT DISTINCT s.nombre, s.precio_base FROM detalle_servicio d JOIN servicio s ON s.id_servicio = d.id_servicio WHERE d.folio = 2;",
      pasos=[("T1", "σ<sub>folio=2</sub>(detalle_servicio)", t1, None), ("T2", "T1 ⋈ servicio", t2, ["folio", "id_servicio", "nombre", "precio_base"]), ("R", "π<sub>nombre, precio_base</sub>(T2)", r, None)])
    # 6
    t1 = d["orden_servicio"].sel(lambda t: t["estado"] == "EN_PROCESO"); t2 = t1.join(d["vehiculo"]); t3 = t2.join(d["cliente"]); r = t3.proj("nombre", "apellidos", "placa")
    q(id=6, titulo="Clientes con vehículos en servicio", nivel="Avanzada", req="Obtener el nombre del cliente y la placa de los vehículos cuya orden está EN_PROCESO.",
      formal="π<sub>nombre, apellidos, placa</sub>(σ<sub>estado='EN_PROCESO'</sub>(orden_servicio) ⋈ vehiculo ⋈ cliente)",
      relax="pi nombre, apellidos, placa ((sigma estado = 'EN_PROCESO' (orden_servicio)) natural join vehiculo natural join cliente)",
      sql="SELECT DISTINCT c.nombre, c.apellidos, v.placa FROM orden_servicio o JOIN vehiculo v ON v.num_serie = o.num_serie JOIN cliente c ON c.id_cliente = v.id_cliente WHERE o.estado = 'EN_PROCESO';",
      pasos=[("T1", "σ<sub>estado='EN_PROCESO'</sub>(orden_servicio)", t1, ["folio", "estado", "num_serie"]), ("T2", "T1 ⋈ vehiculo", t2, ["folio", "num_serie", "placa", "id_cliente"]),
             ("T3", "T2 ⋈ cliente", t3, ["folio", "placa", "id_cliente", "nombre", "apellidos"]), ("R", "π<sub>nombre, apellidos, placa</sub>(T3)", r, None)])
    # 7
    e1, e2 = d["empleado"].ren("e1"), d["empleado"].ren("e2")
    t1 = e1.prod(e2); t2 = t1.sel(lambda t: t["e1.salario"] > t["e2.salario"] and t["e2.tipo"] == "RECEPCIONISTA"); r = t2.proj(("nombre", "e1.nombre"), ("salario", "e1.salario"))
    q(id=7, titulo="Empleados que ganan más que un recepcionista", nivel="Avanzada", req="Obtener el nombre y el salario de los empleados que ganan más que algún recepcionista (producto cartesiano y renombrado).",
      formal="π<sub>e1.nombre, e1.salario</sub>(σ<sub>e1.salario &gt; e2.salario ∧ e2.tipo='RECEPCIONISTA'</sub>(ρ<sub>e1</sub>(empleado) × ρ<sub>e2</sub>(empleado)))",
      relax="pi e1.nombre, e1.salario (sigma e1.salario > e2.salario and e2.tipo = 'RECEPCIONISTA' ((rho e1 (empleado)) cross join (rho e2 (empleado))))",
      sql="SELECT DISTINCT e1.nombre, e1.salario FROM empleado e1, empleado e2 WHERE e1.salario > e2.salario AND e2.tipo = 'RECEPCIONISTA';",
      pasos=[("T1", "ρ<sub>e1</sub>(empleado) × ρ<sub>e2</sub>(empleado)", t1, "conteo"), ("T2", "σ<sub>e1.salario &gt; e2.salario ∧ e2.tipo='RECEPCIONISTA'</sub>(T1)", t2, ["e1.nombre", "e1.salario", "e2.nombre", "e2.salario", "e2.tipo"]),
             ("R", "π<sub>e1.nombre, e1.salario</sub>(T2)", r, None)])
    # 8
    a = d["cliente"].proj("correo"); b = d["proveedor"].proj("correo"); r = a.union(b)
    q(id=8, titulo="Correos de clientes y proveedores", nivel="Intermedia", req="Obtener una lista única con todos los correos de clientes y de proveedores.",
      formal="π<sub>correo</sub>(cliente) ∪ π<sub>correo</sub>(proveedor)", relax="(pi correo (cliente)) union (pi correo (proveedor))",
      sql="SELECT correo FROM cliente UNION SELECT correo FROM proveedor;",
      pasos=[("T1", "π<sub>correo</sub>(cliente)", a, None), ("T2", "π<sub>correo</sub>(proveedor)", b, None), ("R", "T1 ∪ T2", r, None)])
    # 9
    t1 = d["vehiculo"].proj("id_cliente"); t2 = d["orden_servicio"].sel(lambda t: t["estado"] == "TERMINADA").join(d["vehiculo"]).proj("id_cliente")
    t3 = t1.diff(t2); r = d["cliente"].join(t3).proj("nombre", "apellidos")
    q(id=9, titulo="Clientes sin órdenes terminadas", nivel="Intermedia", req="Obtener los clientes que tienen vehículos registrados pero ninguna orden en estado TERMINADA.",
      formal="π<sub>nombre, apellidos</sub>(cliente ⋈ (π<sub>id_cliente</sub>(vehiculo) − π<sub>id_cliente</sub>(σ<sub>estado='TERMINADA'</sub>(orden_servicio) ⋈ vehiculo)))",
      relax="pi nombre, apellidos (cliente natural join ((pi id_cliente (vehiculo)) \\ (pi id_cliente (sigma estado = 'TERMINADA' (orden_servicio) natural join vehiculo))))",
      sql="SELECT DISTINCT c.nombre, c.apellidos FROM cliente c WHERE c.id_cliente IN (SELECT id_cliente FROM vehiculo EXCEPT SELECT v.id_cliente FROM orden_servicio o JOIN vehiculo v ON v.num_serie = o.num_serie WHERE o.estado = 'TERMINADA');",
      pasos=[("T1", "π<sub>id_cliente</sub>(vehiculo)", t1, None), ("T2", "π<sub>id_cliente</sub>(σ<sub>estado='TERMINADA'</sub>(orden_servicio) ⋈ vehiculo)", t2, None),
             ("T3", "T1 − T2", t3, None), ("R", "π<sub>nombre, apellidos</sub>(cliente ⋈ T3)", r, None)])
    # 10
    a = d["detalle_servicio"].sel(lambda t: t["folio"] == 1).proj("id_servicio"); b = d["detalle_servicio"].sel(lambda t: t["folio"] == 2).proj("id_servicio")
    c = a.inter(b); r = d["servicio"].join(c).proj("nombre")
    q(id=10, titulo="Servicios comunes a dos órdenes", nivel="Intermedia", req="Obtener el nombre de los servicios que se realizaron tanto en la orden 1 como en la orden 2.",
      formal="π<sub>nombre</sub>(servicio ⋈ (π<sub>id_servicio</sub>(σ<sub>folio=1</sub>(detalle_servicio)) ∩ π<sub>id_servicio</sub>(σ<sub>folio=2</sub>(detalle_servicio))))",
      relax="pi nombre (servicio natural join ((pi id_servicio (sigma folio = 1 (detalle_servicio))) intersect (pi id_servicio (sigma folio = 2 (detalle_servicio)))))",
      sql="SELECT DISTINCT s.nombre FROM servicio s WHERE s.id_servicio IN (SELECT id_servicio FROM detalle_servicio WHERE folio = 1 INTERSECT SELECT id_servicio FROM detalle_servicio WHERE folio = 2);",
      pasos=[("T1", "π<sub>id_servicio</sub>(σ<sub>folio=1</sub>(detalle_servicio))", a, None), ("T2", "π<sub>id_servicio</sub>(σ<sub>folio=2</sub>(detalle_servicio))", b, None),
             ("T3", "T1 ∩ T2", c, None), ("R", "π<sub>nombre</sub>(servicio ⋈ T3)", r, None)])
    # 11
    e = d["ejecucion"].proj("id_empleado", "id_servicio"); s = d["detalle_servicio"].sel(lambda t: t["folio"] == 2).proj("id_servicio")
    dv = e.div(s); r = d["empleado"].join(dv).proj("nombre")
    q(id=11, titulo="Mecánicos que ejecutaron todos los servicios de una orden", nivel="Avanzada", req="Obtener los mecánicos que han ejecutado todos los servicios incluidos en la orden 2 (división).",
      formal="π<sub>nombre</sub>(empleado ⋈ (π<sub>id_empleado, id_servicio</sub>(ejecucion) ÷ π<sub>id_servicio</sub>(σ<sub>folio=2</sub>(detalle_servicio))))",
      relax="pi nombre (empleado natural join ((pi id_empleado, id_servicio (ejecucion)) / (pi id_servicio (sigma folio = 2 (detalle_servicio)))))",
      sql="SELECT DISTINCT e.nombre FROM empleado e WHERE e.id_empleado IN (SELECT id_empleado FROM (SELECT DISTINCT id_empleado, id_servicio FROM ejecucion) x WHERE id_servicio IN (SELECT id_servicio FROM detalle_servicio WHERE folio = 2) GROUP BY id_empleado HAVING COUNT(DISTINCT id_servicio) = (SELECT COUNT(DISTINCT id_servicio) FROM detalle_servicio WHERE folio = 2));",
      pasos=[("T1", "π<sub>id_empleado, id_servicio</sub>(ejecucion)", e, None), ("T2", "π<sub>id_servicio</sub>(σ<sub>folio=2</sub>(detalle_servicio))", s, None),
             ("T3", "T1 ÷ T2", dv, None), ("R", "π<sub>nombre</sub>(empleado ⋈ T3)", r, None)])
    # 12
    r = d["pago"].group(["folio"], ("sum", "monto", "total_pagado"))
    q(id=12, titulo="Total pagado por orden", nivel="Intermedia", req="Calcular el monto total pagado en cada orden de servicio (agregación con agrupamiento).",
      formal="<sub>folio</sub>G<sub>sum(monto) → total_pagado</sub>(pago)", relax="gamma folio; sum(monto)->total_pagado (pago)",
      sql="SELECT folio, SUM(monto) AS total_pagado FROM pago GROUP BY folio;", pasos=[("R", "<sub>folio</sub>G<sub>sum(monto) → total_pagado</sub>(pago)", r, None)])
    # 13
    r = d["pago"].group([], ("count", "num_pago", "num_pagos"), ("sum", "monto", "ingresos_totales"), ("avg", "monto", "pago_promedio"), ("max", "monto", "pago_maximo"))
    q(id=13, titulo="Resumen general de pagos", nivel="Intermedia", req="Obtener el número de pagos, el ingreso total, el pago promedio y el pago máximo (agregación sin agrupamiento).",
      formal="G<sub>count(num_pago) → num_pagos, sum(monto) → ingresos_totales, avg(monto) → pago_promedio, max(monto) → pago_maximo</sub>(pago)",
      relax="gamma ; count(num_pago)->num_pagos, sum(monto)->ingresos_totales, avg(monto)->pago_promedio, max(monto)->pago_maximo (pago)",
      sql="SELECT COUNT(num_pago) AS num_pagos, SUM(monto) AS ingresos_totales, AVG(monto) AS pago_promedio, MAX(monto) AS pago_maximo FROM pago;",
      pasos=[("R", "G<sub>count(num_pago), sum(monto), avg(monto), max(monto)</sub>(pago)", r, None)])
    # 14
    t1 = d["empleado"].join(d["mecanico"], tipo="left"); r = t1.proj("nombre", "tipo", "especialidad")
    q(id=14, titulo="Empleados y su especialidad (reunión externa)", nivel="Intermedia", req="Mostrar a todos los empleados con su especialidad; quienes no son mecánicos deben aparecer con especialidad nula.",
      formal="π<sub>nombre, tipo, especialidad</sub>(empleado ⟕ mecanico)", relax="pi nombre, tipo, especialidad (empleado natural left outer join mecanico)",
      sql="SELECT e.nombre, e.tipo, m.especialidad FROM empleado e LEFT JOIN mecanico m ON m.id_empleado = e.id_empleado AND m.tipo = e.tipo;",
      pasos=[("T1", "empleado ⟕ mecanico", t1, ["id_empleado", "nombre", "tipo", "especialidad"]), ("R", "π<sub>nombre, tipo, especialidad</sub>(T1)", r, None)])
    # 15
    t1 = d["orden_servicio"].sel(lambda t: t["estado"] in ("TERMINADA", "ENTREGADA")); t2 = d["pago"].group(["folio"], ("sum", "monto", "total_pagado"))
    t3 = d["cliente"].join(d["vehiculo"]).join(t1).join(t2); r = t3.proj("nombre", "apellidos", "folio", "estado", "total_pagado")
    q(id=15, titulo="Cliente, orden y total pagado de órdenes concluidas", nivel="Avanzada",
      req="Para las órdenes TERMINADAS o ENTREGADAS, mostrar el nombre del cliente, el folio, el estado y el total pagado.",
      formal="π<sub>nombre, apellidos, folio, estado, total_pagado</sub>(cliente ⋈ vehiculo ⋈ σ<sub>estado='TERMINADA' ∨ estado='ENTREGADA'</sub>(orden_servicio) ⋈ <sub>folio</sub>G<sub>sum(monto) → total_pagado</sub>(pago))",
      relax="pi nombre, apellidos, folio, estado, total_pagado (cliente natural join vehiculo natural join (sigma estado = 'TERMINADA' or estado = 'ENTREGADA' (orden_servicio)) natural join (gamma folio; sum(monto)->total_pagado (pago)))",
      sql="SELECT c.nombre, c.apellidos, o.folio, o.estado, p.total_pagado FROM cliente c JOIN vehiculo v ON v.id_cliente = c.id_cliente JOIN orden_servicio o ON o.num_serie = v.num_serie JOIN (SELECT folio, SUM(monto) AS total_pagado FROM pago GROUP BY folio) p ON p.folio = o.folio WHERE o.estado IN ('TERMINADA', 'ENTREGADA');",
      pasos=[("T1", "σ<sub>estado='TERMINADA' ∨ estado='ENTREGADA'</sub>(orden_servicio)", t1, ["folio", "estado", "num_serie"]), ("T2", "<sub>folio</sub>G<sub>sum(monto) → total_pagado</sub>(pago)", t2, None),
             ("T3", "cliente ⋈ vehiculo ⋈ T1 ⋈ T2", t3, ["id_cliente", "nombre", "apellidos", "folio", "estado", "total_pagado"]), ("R", "π<sub>nombre, apellidos, folio, estado, total_pagado</sub>(T3)", r, None)])
    # 16
    E = d["empleado"].proj("id_empleado", ("nombre_mecanico", "nombre")); F = d["refaccion"].proj("id_refaccion", ("nombre_refaccion", "nombre"))
    t1 = d["ejecucion"].join(d["uso_refaccion"]).sel(lambda t: t["folio"] == 1); t2 = t1.join(E).join(F); r = t2.proj("nombre_mecanico", "nombre_refaccion", "cantidad")
    q(id=16, titulo="Mecánicos y refacciones de una orden", nivel="Avanzada", req="Para la orden 1, mostrar qué mecánico ejecutó cada servicio y qué refacciones se usaron, con la cantidad (proyección generalizada con renombrado).",
      formal="π<sub>nombre_mecanico, nombre_refaccion, cantidad</sub>(σ<sub>folio=1</sub>(ejecucion ⋈ uso_refaccion) ⋈ π<sub>id_empleado, nombre→nombre_mecanico</sub>(empleado) ⋈ π<sub>id_refaccion, nombre→nombre_refaccion</sub>(refaccion))",
      relax="pi nombre_mecanico, nombre_refaccion, cantidad (sigma folio = 1 (ejecucion natural join uso_refaccion) natural join (rho nombre_mecanico<-nombre (pi id_empleado, nombre (empleado))) natural join (rho nombre_refaccion<-nombre (pi id_refaccion, nombre (refaccion))))",
      sql="SELECT DISTINCT e.nombre AS nombre_mecanico, r.nombre AS nombre_refaccion, u.cantidad FROM ejecucion x JOIN uso_refaccion u ON u.folio = x.folio AND u.id_servicio = x.id_servicio JOIN empleado e ON e.id_empleado = x.id_empleado JOIN refaccion r ON r.id_refaccion = u.id_refaccion WHERE x.folio = 1;",
      pasos=[("E", "π<sub>id_empleado, nombre→nombre_mecanico</sub>(empleado)", E, None), ("F", "π<sub>id_refaccion, nombre→nombre_refaccion</sub>(refaccion)", F, None),
             ("T1", "σ<sub>folio=1</sub>(ejecucion ⋈ uso_refaccion)", t1, None), ("T2", "T1 ⋈ E ⋈ F", t2, ["folio", "id_servicio", "nombre_mecanico", "nombre_refaccion", "cantidad"]),
             ("R", "π<sub>nombre_mecanico, nombre_refaccion, cantidad</sub>(T2)", r, None)])
    return Q

def mostrar(rel, cols=None):
    cols = cols or rel.cols; idx = [rel.cols.index(c) for c in cols]
    anchos = [max(len(c), *(len(fmt(t[i])) for t in rel.rows)) if rel.rows else len(c) for c, i in zip(cols, idx)]
    print("  " + " | ".join(c.ljust(w) for c, w in zip(cols, anchos)))
    print("  " + "-+-".join("-" * w for w in anchos))
    for t in rel.rows: print("  " + " | ".join(fmt(t[i]).ljust(w) for i, w in zip(idx, anchos)))

if __name__ == "__main__":
    for c in consultas():
        print(f"\nConsulta {c['id']}: {c['titulo']} ({c['nivel']})\n  {c['req']}")
        for etiqueta, _, rel, cols in c["pasos"]:
            if cols == "conteo": print(f"  {etiqueta}: {len(rel)} tuplas"); continue
            print(f"  {etiqueta}:"); mostrar(rel, cols)

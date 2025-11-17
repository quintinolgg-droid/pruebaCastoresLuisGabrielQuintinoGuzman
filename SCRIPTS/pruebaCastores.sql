/*
================================================================================
ESQUEMA DE INVENTARIO - PRUEBACASTORES
================================================================================

Este script SQL define la estructura completa de la base de datos para el sistema
de gestión de inventario, incluyendo la definición de roles, usuarios, catálogo
de productos y el registro detallado de movimientos de stock.
*/

/* ----------------------------------------------------------------------------
   CREACIÓN Y USO DE LA BASE DE DATOS
   ---------------------------------------------------------------------------- */
/* CREACION DE LA BASE DE DATOS: Nombre del proyecto o sistema. */
CREATE DATABASE pruebaCastores;

/* USAMOS LA BASE DE DATOS: Selecciona la base de datos para ejecutar los comandos subsiguientes. */
USE pruebaCastores;


/* ----------------------------------------------------------------------------
   TABLA ROLES
   Define los niveles de acceso y permisos de los usuarios en el sistema.
   ---------------------------------------------------------------------------- */
CREATE TABLE roles (
	/* idRol: Identificador único y numérico para cada rol. Es la clave primaria. */
	id_rol TINYINT(2) AUTO_INCREMENT PRIMARY KEY,
	/* nombreRol: Nombre descriptivo del rol (ej. 'Administrador', 'Almacenista'). Debe ser único. */
	nombre_rol VARCHAR(50) NOT NULL UNIQUE
);

/* INSERTAR LOS VALORES PREDEFINIDOS PARA ROLES: Inicializa los roles básicos del sistema.
   Uso la sintaxis INSERT INTO ... (columnas) VALUES ... */
INSERT INTO roles (id_rol, nombre_rol) values
	(01,"Administrador"), /* Rol con permisos totales. */
	(02,"Almacenista"); /* Rol con permisos restringidos a la gestión de inventario. */

/* ----------------------------------------------------------------------------
   TABLA USUARIOS
   Almacena la información de acceso y personal de cada empleado.
   ---------------------------------------------------------------------------- */
CREATE TABLE usuarios(
	/* idUsuario: Identificador único y numérico para cada usuario. Es la clave primaria. */
	id_usuario INT(6) PRIMARY KEY AUTO_INCREMENT,
	/* nombre: Nombre completo del usuario. */
	nombre VARCHAR(100) NOT NULL,
	/* correo: Correo electrónico del usuario. Utilizado para el inicio de sesión y debe ser único. */
	correo VARCHAR(50) NOT NULL UNIQUE,
	/* contrasena: Contraseña del usuario. */
	contrasena VARCHAR(25) NOT NULL, /* RECOMENDABLE CAMBIAR A MAYOR VARCHAR (ej. 255) PARA MAYOR SEGURIDAD CON UN HASH (ej. bcrypt) */
	/* idRol: Clave foránea que enlaza con la tabla 'roles', especificando el nivel de acceso del usuario. */
	id_rol TINYINT(2) NOT NULL,
	/* estatus: Indica si la cuenta de usuario está activa (1) o inactiva (0). Por defecto es activa. */
	estatus TINYINT(1) NOT NULL DEFAULT 1,
	/* Restricción: Asegura que 'estatus' solo pueda tomar los valores 0 o 1. */
	CHECK (estatus IN (0, 1)),
	/* Definición de la Clave Foránea: Conecta con la tabla 'roles'. */
	FOREIGN KEY (id_rol) REFERENCES roles(id_rol)
);

/* ----------------------------------------------------------------------------
   TABLA PRODUCTOS
   Catálogo que lista todos los productos gestionados en el inventario.
   ---------------------------------------------------------------------------- */
CREATE TABLE productos (
	/* idProducto: Identificador único del producto. Es la clave primaria. */
	id_producto INT(11) AUTO_INCREMENT PRIMARY KEY,
	/* nombre: Nombre corto y descriptivo del producto. */
	nombre VARCHAR(100) NOT NULL,
	/* descripcion: Descripción detallada o especificaciones del producto. */
	descripcion TEXT NOT NULL,
	/* cantidad: Stock actual disponible del producto. Por defecto se inicializa en 0. */
	cantidad INT(11) NOT NULL DEFAULT 0,
	/* estatus: Indica si el producto está activo/disponible (1) o descontinuado/inactivo (0). */
	estatus TINYINT(1) NOT NULL DEFAULT 1,
	/* Restricción: Asegura que 'estatus' solo pueda tomar los valores 0 o 1. */
	CHECK (estatus IN (0, 1))
);

/* ----------------------------------------------------------------------------
   TABLA MOVIMIENTOS
   Registro histórico de todas las entradas y salidas de stock, esencial para
   auditoría y trazabilidad del inventario.
   ---------------------------------------------------------------------------- */
CREATE TABLE movimientos (
	/* idMovimiento: Identificador único para cada transacción de inventario. Es la clave primaria. */
	id_movimiento INT(11) AUTO_INCREMENT PRIMARY KEY,
	/* idProducto: Clave foránea al producto que se está moviendo. */
	id_producto INT(11) NOT NULL,
	/* idUsuario: Clave foránea al usuario que registró el movimiento. */
	id_usuario INT(11) NOT NULL,
	/* tipoMovimiento: Especifica si el movimiento fue una 'Entrada' de stock o una 'Salida' de stock. */
	tipo_movimiento ENUM('Entrada','Salida') NOT NULL,
	/* cantidad: El número de unidades movidas en esta transacción. */
	cantidad INT(11) NOT NULL,
	/* fechaHora: Sello de tiempo que registra el momento exacto del movimiento. Por defecto toma la hora actual. */
	fecha_hora DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	/* Definición de la Clave Foránea: Conecta con la tabla 'productos'. */
	FOREIGN KEY (id_producto) REFERENCES productos(id_producto),
	/* Definición de la Clave Foránea: Conecta con la tabla 'usuarios'. */
	FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario)
);


/*
================================================================================
NOTA IMPORTANTE SOBRE LA CONSISTENCIA DEL INVENTARIO
================================================================================

Para asegurar que la columna 'productos.cantidad' se mantenga siempre precisa,
es crucial implementar TRIGGERS (Disparadores) en la base de datos que:
1. Al insertar un nuevo registro en 'movimientos', actualicen automáticamente
   el campo 'cantidad' en la tabla 'productos' (sumando para 'Entrada', restando
   para 'Salida').
2. Verifiquen que no se permita una 'Salida' si la 'cantidad' resultante es negativa.
*/


INSERT INTO usuarios (nombre, correo, contrasena, id_rol, estatus) VALUES
('Ana García', 'ana.garcia@castores.com', 'Pass1234', 1, 1), /* Administrador activo */
('Juan Pérez', 'juan.perez@castores.com', 'Cajas5678', 2, 1), /* Almacenista activo */
('María López', 'maria.lopez@castores.com', 'SafePass', 2, 1), /* Almacenista activo */
('Carlos Ruiz', 'carlos.ruiz@castores.com', 'TestPass', 2, 0), /* Almacenista inactivo */
('Elena Torres', 'elena.torres@castores.com', 'SecurePwd', 1, 1);

/* ----------------------------------------------------------------------------
   INSERCIÓN DE DATOS INICIALES EN TABLA PRODUCTOS
   ---------------------------------------------------------------------------- */
INSERT INTO productos (nombre, descripcion, cantidad, estatus) VALUES
('Palet Europallet', 'Base de madera estándar para transporte de mercancía.', 150, 1),
('Caja Cartón GRANDE', 'Caja doble corrugada para embalajes pesados.', 2000, 1),
('Etiquetas Térmicas', 'Rollos de etiquetas de 4x6 pulgadas.', 50, 1),
('Montacargas Pequeño', 'Equipo descontinuado, solo para registro.', 0, 0), /* Producto inactivo */
('Rollo de Stretch Film', 'Película plástica para asegurar palets.', 450, 1);

/* ----------------------------------------------------------------------------
   INSERCIÓN DE DATOS DE MOVIMIENTOS
   NOTA: Las cantidades de los productos en la tabla 'productos' (150, 2000, 50, 450)
   NO se actualizarán automáticamente con estas inserciones, pues no hay TRIGGERS.
   Estos movimientos solo quedan registrados.
   ---------------------------------------------------------------------------- */
INSERT INTO movimientos (id_producto, id_usuario, tipo_movimiento, cantidad, fecha_hora) VALUES
(2, 2, 'Entrada', 500, NOW()), /* Entrada de 500 Cajas por Juan Pérez */
(1, 2, 'Salida', 10, '2025-11-14 10:30:00'), /* Salida de 10 Palets por Juan Pérez */
(5, 1, 'Entrada', 100, '2025-11-13 15:45:00'), /* Entrada de 100 Rollos de Film por Ana García */
(2, 3, 'Salida', 50, NOW()), /* Salida de 50 Cajas por María López */
(3, 2, 'Entrada', 20, NOW()); /* Entrada de 20 Etiquetas por Juan Pérez */



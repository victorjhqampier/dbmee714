/*
 1. tablas, esqueemas protegidas (config, private)
 	1.1. tablas o vistas acccedidas solo por la api
 		no respeta ningun estandiracion
 	tablas y otros protegidos pero accedidos por arixshell si cumple la estadarización
 	1.2. nombre de tabla = plural
 		id de tabla = [nombre de tabla][singular]+_id
 */

/*---------------PRIVATE----------------------------------------*/
CREATE SCHEMA private;
create table private.departamentos( /*P01*/
	departamento_id INT not null,
	departamento VARCHAR(60) not null,
    primary key (departamento_id)
);
create table private.provincias (/*P02*/
	provincia_id int not null,
	departamento_id int not null,
	provincia varchar(60) not null,
	foreign key (departamento_id) references private.departamentos (departamento_id),
	primary key (provincia_id)	
);
create table private.distritos(/*P03*/
	distrito_id int not null,
	provincia_id int not null,
	distrito varchar(60) not null,
	foreign key (provincia_id) references private.provincias (provincia_id),
	primary key (distrito_id)
);
create table private.personas( /*P04*/
	persona_id serial,
    distrito_id int not null,
	documento VARCHAR(11) not null,
	nombres VARCHAR(60) not null,
	paterno VARCHAR(60) not null,
	materno VARCHAR(60) not null,
	nacimiento DATE	not null,
	sexo int not null CHECK(sexo > 0 and sexo <4), /*1:Male, 2: Female, 3: None, */
    telefono VARCHAR(20),
    fotografia VARCHAR(70) not null,
    direccion VARCHAR(70) not null,
    correo VARCHAR(60),
	fcreacion TIMESTAMP default CURRENT_TIMESTAMP,
	factualizacion TIMESTAMP default CURRENT_TIMESTAMP,
    foreign key (distrito_id) references private.distritos(distrito_id),
	primary key (persona_id)
); CREATE UNIQUE INDEX unique_persona_documento ON private.personas (documento);

create table private.permisos(/*---para los permisos de los botones leer, crear, actualizar, eliminar,*/
	permiso_id int not null,
	binario int not null,
	permiso varchar (60) not null,
	primary key (permiso_id)
);

create table private.roles(
	rol_id int not null,
    rol_padre int default 1,/*Rol padre*/
	rol VARCHAR(15) not null,
	descripcion text default 'Sin descripcion',
    foreign key (rol_padre) references private.roles(rol_id),
	primary key (rol_id)    
);

create table private.apps (
	app_id int not null check (app_id >1000),
    id_app int default 1001,
	app VARCHAR(20) not null unique,
    controller VARCHAR(30) not null,
    autor VARCHAR(30) not null,	
	awebsite VARCHAR(60) not null,
    version VARCHAR(10) not null,
    descricpcion VARCHAR(60) not null,
    estado bool not null default true,/*esta instalado? true*/
	fregistro TIMESTAMP not null default current_timestamp,
    foreign key (id_app) references private.apps (app_id),
	primary key (app_id) 
);

create table private.submenus(
	submenu_id int not null,
    app_id int not null,
    submenu varchar(50) not null,
    foreign key (app_id) references private.apps(app_id),
    primary key (submenu_id)
);
create table private.subapps(
	subapp_id serial,
    submenu_id int not null,
    subapp varchar(40) not null, 
    controller varchar (50) not null,/*[Controller]/[function/method]*/    
    rol int not null default 6 check (rol < 8 and rol > 3), /*4=mas confidencial; 7 = menos confidencial*/
    foreign key (submenu_id) references private.submenus(submenu_id),
    primary key (subapp_id)
); CREATE INDEX index_rol_subapps ON private.subapps (rol);

/*---------------CONFIG----------------------------------------*/
create schema config;

create table config.departamentos(
	departamento_id int not null,
	departamento_padre int default 2,
	departamento varchar(70) not null,
	factualizacion TIMESTAMP not null default current_timestamp,
	fregistro TIMESTAMP not null default current_timestamp,
	foreign key (departamento_padre) references config.departamentos(departamento_id),
	primary key (departamento_id)
);

create table config.puestos(
	puesto_id int not null,
	departamento_id int not null,
	puesto varchar(70) not null,
	factualizacion TIMESTAMP not null default current_timestamp,
	fregistro TIMESTAMP not null default current_timestamp,
	foreign key (departamento_id) references config.departamentos(departamento_id),
	primary key (puesto_id)	
);
create table config.profesiones(
	profesion_id SERIAL,
    profesion varchar (80) not null,
    primary key (profesion_id)
);

create table config.empcategorias( /*compcategorias_C08*/
	categoria_id char(13) not null,
	categoria VARCHAR(50) not null,
	primary key (categoria_id)
);
create table config.empsubcategorias( /*compsubcategorias_C09*/
	subcategoria_id char(13) not null,
	categoria_id char(13) not null,
	subcategoria VARCHAR(50) not null,
	foreign key (categoria_id) references config.empcategorias (categoria_id),
	primary key (subcategoria_id)
);

create table config.sucursales (
	sucursal_id SERIAL,
	sucpadre_id INT default 1,
	distrito_id INT not null,
    subcategoria_id char(13) not null,
    numero int not null,
    imagen varchar(80) not null,
	ruc VARCHAR(11) not null,
	rsocial VARCHAR(90) not null,
	nombre VARCHAR(80) not null,
	direccion VARCHAR(80) not null,
	estado boolean not null default true,
	fregistro TIMESTAMP not null default current_timestamp,
    foreign key (sucpadre_id) references config.sucursales(sucursal_id),/*cambiar*/
    foreign key (distrito_id) references private.distritos (distrito_id),
    foreign key (subcategoria_id) references config.empsubcategorias(subcategoria_id),
    primary key (sucursal_id)
); CREATE INDEX index_sucursales_num ON config.sucursales (numero);
--alter table config.sucursales ADD COLUMN estado boolean not null default true
--ALTER TABLE config.sucursales rename COLUMN numero to numero int not null

create table config.areas(
	area_id SERIAL,
	sucursal_id INT not null,
	departamento_id INT not null,
	estado boolean not null default false, --es un area unico? si = true, no = false
	descripcion text not null,	
	factualizacion TIMESTAMP not null default current_timestamp,
	fregistro TIMESTAMP not null default current_timestamp,
    foreign key (sucursal_id) references config.sucursales (sucursal_id),
    foreign key (departamento_id) references config.departamentos (departamento_id),
    primary key (area_id)
);

--uno es empleado si y solo si, tiene un contrato vigente con la empresa
create table config.contratos (
	contrato_id serial,	
	persona_id int not null,--empleado_id
	area_id int not null,
	puesto_id int not null, --cargo del empleado
	contrato_padre int default 1,--usuarios principales no son mostrados en la interfaz
	numero int not null, --numero de contrato
	cinicio date not null,--segun el contrato
	cfinal date default null,
	estado boolean not null default true,-- true = vijente, false = terminado
	finicio date not null,--segun formalmente, asistió
	ffinal date default null, -- puede ser despedido, el contrato se anula
	fregistro TIMESTAMP not null default current_timestamp,
    fmodificacion timestamp not null default current_timestamp,
    foreign key (persona_id) references private.personas (persona_id),
    foreign key (area_id) references config.areas (area_id),
    foreign key (puesto_id) references config.puestos(puesto_id),
    foreign key (contrato_padre) references config.contratos(contrato_id),
    primary key(contrato_id)
);

/*+++++ESTOY AQUI+++++*/
/*create table config.empleados(
	empleado_id SERIAL,
    persona_id int not null,
	area_id INT not null,
    jefe_id INT default 1,
    profesion_id int not null,
    codigo char(6) not null,
	estado BOOL not null default true,
	fregistro TIMESTAMP not null default current_timestamp,
    fmodificacion timestamp not null default current_timestamp,
	foreign key (persona_id) references private.personas (persona_id),
	foreign key (jefe_id) references config.empleados (empleado_id),
	foreign key (area_id) references config.areas (area_id),
	foreign key (profesion_id) references config.profesiones (profesion_id),
	primary key (empleado_id)
);*/

create table config.cuentas (
	cuenta_id serial,
	contrato_id INT not null,
    root_id int default 1,/*Id del usuario root que todos dependen*/
    permiso_id int not null, /*Lectura o escritura*/
	correo VARCHAR(100) not null unique,
	pass VARCHAR(100) not null,
    passini VARCHAR(100) not null,
	estado BOOL default true, /*puede estar suspendido*/
	fregistro timestamp not null default current_timestamp,
    fmodificacion timestamp not null default current_timestamp,
	foreign key (contrato_id)  references config.contratos (contrato_id),
    foreign key (root_id)  references config.cuentas (cuenta_id),
    foreign key (permiso_id) references private.permisos(permiso_id),
	primary key (cuenta_id)
);

create table config.cuentaapprol(
	app_id INT not null,
	cuenta_id INT not null,
	rol_id INT not null default 4,
	fregistro TIMESTAMP not null default current_timestamp,
	foreign key (app_id) references private.apps (app_id),
	foreign key (cuenta_id) references config.cuentas (cuenta_id),
	foreign key (rol_id) references private.roles (rol_id),
	primary key (app_id,cuenta_id)	
);

create table config.cuentasucursal(
	cuenta_id int not null,
	sucursal_id int not null,
	foreign key (cuenta_id) references config.cuentas (cuenta_id),
	foreign key (sucursal_id) references config.sucursales (sucursal_id),
	primary key (cuenta_id, sucursal_id)
);

/*---------VISTAS PARA CONFIG------------------- */
CREATE or replace VIEW config.v_cuenta_permiso as
select c.permiso_id, p.binario, c.cuenta_id
	from config.cuentas c 
	inner join private.permisos p on c.permiso_id = p.permiso_id;

--Consulta para enlistar las sucursals asociadas a una cuenta
CREATE or replace VIEW config.v_cuenta_sucursal as
select s.nombre, cs.cuenta_id, cs.sucursal_id, s.estado, s.numero
	from config.cuentasucursal cs
	inner join config.sucursales s on cs.sucursal_id = s.sucursal_id;

--Vista que detalla app, cuenta y rol
CREATE VIEW config.v_cuenta_app_rol AS 
select
   ca.cuenta_id, a.app_id, a.id_app, a.app, a.controller, r.rol_id, r.rol
from
	config.cuentaapprol ca 
	inner join
		private.apps a 
		on ca.app_id = a.app_id
	inner join 
		private.roles r
		on ca.rol_id = r.rol_id;

--Vista que detalla submenus y subapp de cada app
CREATE OR REPLACE VIEW config.v_menu_subapp AS
select
	ap.subapp_id,
	ap.subapp,
    ap.controller,
    ap.rol,
    me.app_id,
    me.submenu_id,
    me.submenu	
from
   private.submenus me 
   inner join
      private.subapps ap 
      on me.submenu_id = ap.submenu_id;

--Vista detalla la cuenta de usuario
create or replace view config.v_persona_empleado_cuenta as
	select p.documento, p.nombres, p.paterno, p.materno, p.telefono, p.fotografia, p.direccion, p.correo,
		e.fmodificacion, e.fregistro, c.estado, e.area_id, p.distrito_id, p.persona_id, c.cuenta_id
	from private.personas p
		inner join config.contratos e on p.persona_id = e.persona_id
		inner join config.cuentas c on e.contrato_id = c.contrato_id;
	
-- Vista que detalla al empleado
create or replace view config.v_persona_empleado as 
	select p.documento, e.numero, p.nombres, p.paterno, p.materno, p.nacimiento, p.sexo, p.telefono, p.fotografia, p.direccion, p.correo,
		e.fmodificacion, e.fregistro, e.estado econtrato, c.estado ecuenta, e.cinicio, e.cfinal, e.area_id, e.puesto_id, p.distrito_id, p.persona_id 
	from private.personas p
		inner join config.contratos e on p.persona_id = e.persona_id
		left join config.cuentas c on e.contrato_id = c.contrato_id
		
--Vista que detalla los permisos asociados a una cuenta
create or replace view config.v_cuenta_permiso as 
	select c.cuenta_id, c.contrato_id, c.permiso_id, p.binario
		from config.cuentas c
		inner join private.permisos p on c.permiso_id = p.permiso_id
table private.permisos 

--vista que detalla distrito provincia departamento
create or replace view config.v_distr_prov_depa as 
	select di.distrito_id, di.provincia_id, pr.departamento_id, di.distrito, pr.provincia, de.departamento
		from private.distritos di
		inner join private.provincias pr on pr.provincia_id = di.provincia_id
		inner join private.departamentos de on pr.departamento_id = de.departamento_id
	where di.distrito_id = 1645




/*----------------BASES PARA EL CIFRADO*/
	select * from config.sucursales
create table private.traductores(
	traductor_id serial,
    sal char(13) not null unique,
    llave varchar (40) not null,
    primary key (traductor_id)
);
create table config.recursos(/*css y js*/
	recurso_id serial,
	recurso varchar(30) not null,
	direction varchar(80) not null,
	tipo int not null default 1, /*1 = js, 2 = css*/
	primary key (recurso_id)
);create unique index in_for_recursos on config.recursos(recurso_id);

create table config.botones(/*los bonotes del sistema*/
	boton_id serial,
	permiso int not null,
	boton varchar(50) not null,
	icono varchar(70) not null,
	titulo varchar (60) not null,
	primary key(boton_id)	
);
--Estas tablas pueden ser leidas accedidas desde otras app a parde de: (inicio, configuraciones, arix core)
create table private.tabla_publicas(
	tabla_publica_id int not null,
	tabla varchar(30) not null,
	tuplas text not null,
	primary key(tabla_publica_id)
);
create drop table private.tabla_dependencias(
	tabla_publica_id int not null,
	tabla_publica_dependencia int not null,
	foreign key (tabla_publica_id) references private.tabla_dependencias (tabla_publica_id),
	foreign key (tabla_publica_dependencia) references private.tabla_dependencias (tabla_publica_id),
	primary key (tabla_publica_id)
);






/*PRUEBAS*/
/*-----2 Vista que detalla cuenta, rol y empleado------*/
CREATE OR REPLACE VIEW config_xuseremprol AS 
select
   ca.cuenta_id, a.app, a.controller, r.rol, cu.empleado_id
from
	config_cuentaapprol ca	
	inner join 
		private_roles r
		on ca.rol_id = r.rol_id
	inner join
		private_apps a 
		on ca.app_id = a.app_id
	inner join 
		config_cuentas cu
		on ca.cuenta_id = cu.cuenta_id;
/*-----end view------*/
	/*7 vista que trae cucursal y areas del sucursal----------------------------------------------------*****/
CREATE OR REPLACE VIEW config_xsucuarea AS
select
   su.sucursal_id,
   su.nombre,
   ar.area_id,
   ar.areaminimal,
   ar.area
from
   config_sucusales su /*cambiar*/
   inner join
      config_areas ar 
      on su.sucursal_id = ar.sucursal_id;
 /*-----6 Vista que recupera distri_id_pro_id y dep_id apartir de distrito_id------*/
CREATE VIEW config_xdisprovdep AS
select
   nd.distrito_id,
   np.provincia_id,
   np.departamento_id 
from
   private_distritos nd 
   inner join
      private_provincias np 
      on nd.provincia_id = np.provincia_id;
/*-----4 Vista que detalla empleado y persona------*/
CREATE OR replace VIEW config_xempleadoper
AS
SELECT 	em.jefe_id,
		em.empleado_id,
		em.persona_id,
		em.estado,
        em.fregistro,
        em.profesion_id,
        pe.distrito_id,
		pe.documento,
        pe.nombres,
        pe.paterno,
        pe.materno,
        pe.nacimiento,
        pe.sexo,
        pe.direccion,
        pe.correo,
        pe.telefono,
        ar.areaminimal,
		ar.area,
        ar.area_id
FROM config_empleados em
	inner join private_personas pe on em.persona_id = pe.persona_id
inner join config_areas ar on em.area_id = ar.area_id
WHERE em.jefe_id IS NOT NULL;/*por verificar*/

/*-----5 Vista que detalla usuario empleado y persona----select * from config_xuserempleado--*/
CREATE OR REPLACE VIEW config_xuserempleado
AS
SELECT 	 pe.documento,
         cu.correo,
         cu.cuenta_id,
         cu.empleado_id,
         cu.estado,
         cu.fregistro,
         pe.nombres,
         pe.paterno,
         pe.materno
FROM	config_empleados em
         INNER JOIN config_cuentas cu
                 ON cu.empleado_id = em.empleado_id
         INNER JOIN private_personas pe
                 ON em.persona_id = pe.persona_id
WHERE em.jefe_id IS NOT NULL;
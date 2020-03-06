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
    id_rol int default 1,/*Rol padre*/
	rol VARCHAR(15) not null,
	descripcion VARCHAR(80) not null,
    foreign key (id_rol) references private.roles(rol_id),
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
create table config.sucusales (
	sucursal_id SERIAL,
	sucpadre_id INT default 1,
	distrito_id INT not null,
    subcategoria_id char(13) not null,
    adminstrador_id INT not null,
	ruc VARCHAR(11) not null,
	rsocial VARCHAR(90) not null,
	nombre VARCHAR(80) not null,
	direccion VARCHAR(80) not null,
	fregistro TIMESTAMP not null default current_timestamp,
    foreign key (sucpadre_id) references config.sucusales(sucursal_id),
    foreign key (distrito_id) references private.distritos (distrito_id),
    foreign key (adminstrador_id) references private.personas(persona_id),
    foreign key (subcategoria_id) references config.EMPsubcategorias(subcategoria_id),
    primary key (sucursal_id)
);
create table config.areas(
	area_id SERIAL,
	sucursal_id INT not null,
    areaminimal VARCHAR(7) not null, /*Abreviatura*/
	area VARCHAR(50) not null,
	funciones VARCHAR(100) not null,
	f_registro TIMESTAMP not null default current_timestamp,
    foreign key (sucursal_id) references config.sucusales (sucursal_id),
    primary key (area_id)
);
create table config.profesiones(
	profesion_id SERIAL,
    profesion varchar (80) not null,
    primary key (profesion_id)
);

create table config.empleados(
	empleado_id SERIAL,
    persona_id int not null,
	area_id INT not null,
    jefe_id INT default 1,/*DE ESTA MISMA TABLA*/
    profesion_id int not null,
    codigo char(6) not null,
	estado BOOL not null default true, /*Activo o no*/
	fregistro TIMESTAMP not null default current_timestamp,
    fmodificacion timestamp not null default current_timestamp,
	foreign key (persona_id) references private.personas (persona_id),
	foreign key (jefe_id) references config.empleados (empleado_id),
	foreign key (area_id) references config.areas (area_id),
	foreign key (profesion_id) references config.profesiones (profesion_id),
	primary key (empleado_id)
);

create table config.cuentas (
	cuenta_id serial,
	empleado_id INT not null,
    root_id int default 1,/*Id del usuario root que todos dependen*/
    permiso_id int not null, /*Lectura o escritura*/
	correo VARCHAR(90) not null unique,
	pass VARCHAR(62) not null,
    passini VARCHAR(62) not null,
	estado BOOL default true, /*puede estar suspendido*/
	fregistro timestamp not null default current_timestamp,
    fmodificacion timestamp not null default current_timestamp,
	foreign key (empleado_id)  references config.empleados (empleado_id),
    foreign key (root_id)  references config.cuentas (cuenta_id),
    foreign key (permiso_id) references private.permisos(permiso_id),
	primary key (cuenta_id)
);

create table config.cuentaapprol(
	app_id INT not null,
	cuenta_id INT not null,
	rol_id INT not null default 1,
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
	foreign key (sucursal_id) references config.sucusales (sucursal_id),
	primary key (cuenta_id, sucursal_id)
);


/*---------VISTAS PARA CONFIG------------------- */

/*Consulta para enlistar las aplicaciones de un usuario*/
CREATE VIEW config.v_cuenta_sucursal as
select s.nombre, cs.cuenta_id, cs.sucursal_id from config.cuentasucursal cs
	inner join config.sucusales s on cs.sucursal_id = s.sucursal_id

/*-----Vista que detalla app, cuenta y rol------*/
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
/*-----end view------*/

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

/*-----3 Vista que detalla submenus y subapp de cada app------*/
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

create or replace view config.v_persona_empleado_cuenta as
	select p.documento, p.nombres, p.paterno, p.materno, e.empleado_id, p.persona_id, c.cuenta_id
		from private.personas p
			inner join config.empleados e on p.persona_id = e.persona_id
				inner join config.cuentas c on e.empleado_id = c.empleado_id
	
create or replace view config.v_persona_empleado as 
	select p.documento, e.codigo, p.nombres, p.paterno, p.materno, p.nacimiento, p.sexo, p.telefono, p.fotografia, p.direccion, p.correo,
		e.profesion_id, e.fmodificacion, e.fregistro, e.estado, e.jefe_id, e.area_id, p.distrito_id, p.persona_id, e.empleado_id, c.estado ecuenta
		from private.personas p
			inner join config.empleados e on p.persona_id = e.persona_id
				left join config.cuentas c on e.empleado_id = c.empleado_id
     
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
      
/*7 vista que trae cucursal y areas del sucursal----------------------------------------------------*****/
CREATE OR REPLACE VIEW config_xsucuarea AS
select
   su.sucursal_id,
   su.nombre,
   ar.area_id,
   ar.areaminimal,
   ar.area
from
   config_sucusales su 
   inner join
      config_areas ar 
      on su.sucursal_id = ar.sucursal_id;
      
/*----------------BASES PARA EL CIFRADO*/
create table private.traductores(
	traductor_id serial,
    sal char(13) not null unique,
    llave varchar (40) not null,
    primary key (traductor_id)
);
/*Procedimiento para cifrar palabras*/
delimiter $$
create procedure private_p_cifrador(in palabra varchar(45), in llave varchar(35))
	begin
		select HEX(AES_ENCRYPT(palabra, llave)) as cifrado;
        #select concat(palabra,' ',llave,nombre);
end $$
delimiter $$
create procedure private_p_decifrador(in palabra varchar(45), in llave varchar(35))
	begin
		#select HEX(AES_ENCRYPT(palabra, llave)) as nombre;
        select AES_DECRYPT(UNHEX(palabra),llave) as decifrado;
end $$


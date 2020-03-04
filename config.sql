USE arixmee;
/*DDL ----------------------------------------------------*****/
create table config_sucusales (
	sucursal_id INT auto_increment,
	suc_padre INT default 1,
	distrito_id INT not null,
	ruc VARCHAR(11) not null,
	r_social VARCHAR(90) not null,
	nombre VARCHAR(80) not null,
	direccion VARCHAR(80) not null,
	licencia date not null,
	f_registro TIMESTAMP not null default current_timestamp,
    foreign key (suc_padre) references config_sucusales(sucursal_id),
    foreign key (distrito_id) references nprivate_distritos (distrito_id),
    primary key (sucursal_id)
);
create table config_empleados(
	empleado_id int not null,
	area_id INT not null,
    empleado_pid INT default 1,
    profesion varchar(45) not null default 'Ninguno',
	estado BOOL not null default true,
	f_registro TIMESTAMP not null default current_timestamp,
    f_modify timestamp not null default current_timestamp,
	foreign key (empleado_id) references nprivate_personas (persona_id),
	foreign key (empleado_pid) references config_empleados (empleado_id),
	foreign key (area_id) references config_areas (area_id),	
	primary key (empleado_id)
);
create table config_cuentas (
	cuenta_id int auto_increment,
	empleado_id INT not null,
    cuenta_pid int default 1,
	correo VARCHAR(90) not null unique,
	pass VARCHAR(62) not null,
    passini VARCHAR(62) not null,
	estado BOOL default true,
	f_registro timestamp not null default current_timestamp,
    f_modify timestamp not null default current_timestamp,
	foreign key (empleado_id)  references config_empleados (empleado_id),
    foreign key (cuenta_pid)  references config_cuentas (cuenta_id),
	primary key (cuenta_id, empleado_id)
);
describe config_cuentas
ALTER TABLE config_cuentas MODIFY passini VARCHAR(62) not null;/*Solo cambia el tipo de dato*/
delete from config_cuentas where cuenta_pid is not null;
drop table config_cuentaapprol;
create table config_cuentaapprol(
	app_id INT not null,
	cuenta_id INT not null,
	rol_id INT not null default 1,
	f_registro TIMESTAMP not null default current_timestamp,
	foreign key (app_id) references nprivate_apps (app_id),
	foreign key (cuenta_id) references config_cuentas (cuenta_id),
	foreign key (rol_id) references nprivate_roles (rol_id),
	primary key (app_id,cuenta_id)	
);
drop table config_cuentaapprol;

/*-----1 Vista que detalla app, cuenta y rol------*/
CREATE VIEW config_xapprolcuenta AS 
select
   ca.cuenta_id, a.app_id, a.app, a.controller, r.rol_id, r.rol
from
	config_cuentaapprol ca 
	inner join
		nprivate_apps a 
		on ca.app_id = a.app_id
	inner join 
		nprivate_roles r
		on ca.rol_id = r.rol_id;
/*-----end view------*/
/*-----2 Vista que detalla cuenta, rol y empleado------*/
CREATE OR REPLACE VIEW config_xuseremprol AS 
select
   ca.cuenta_id, a.app, a.controller, r.rol, cu.empleado_id
from
	config_cuentaapprol ca	
	inner join 
		nprivate_roles r
		on ca.rol_id = r.rol_id
	inner join
		nprivate_apps a 
		on ca.app_id = a.app_id
	inner join 
		config_cuentas cu
		on ca.cuenta_id = cu.cuenta_id;
/*-----end view------*/

/*-----3 Vista que detalla submenus y subapp de cada app------*/
CREATE OR REPLACE VIEW config_xsubmenusubapp AS
select
	ap.subapp_id,
	ap.subapp,
    ap.controller,
    ap.rol,
    me.app_id,
    me.submenu_id,
    me.submenu	
from
   nprivate_submenus me 
   inner join
      nprivate_subapps ap 
      on me.submenu_id = ap.submenu_id;
      
/*-----Vista que detalla empleado y persona------*/
CREATE OR replace VIEW config_xempleadoper
AS
  SELECT em.empleado_id,
         em.estado,
         em.profesion,
         em.f_registro,
         ar.codigo,
         ar.area,
         ar.area_id,
         pe.distrito_id,
         pe.dni,
         pe.nombre,
         pe.apellido,
         pe.f_nacimiento,
         pe.sexo,
         pe.direccion,
         pe.correo,
         pe.cel
  FROM   config_empleados em
         inner join nprivate_personas pe
                 ON em.empleado_id = pe.persona_id
         inner join config_areas ar
                 ON em.area_id = ar.area_id
WHERE em.empleado_pid IS NOT NULL;

/*-----Vista que detalla usuario empleado y persona----select * from config_xuserempleado--*/
CREATE OR REPLACE VIEW config_xuserempleado
AS
SELECT 	 pe.dni,
         cu.correo,
         cu.cuenta_id,
         cu.empleado_id,
         cu.estado,
         cu.f_registro,
         pe.nombre,
         pe.apellido
FROM	config_cuentas cu
         INNER JOIN config_empleados em
                 ON cu.empleado_id = em.empleado_id
         INNER JOIN nprivate_personas pe
                 ON em.empleado_id = pe.persona_id
WHERE em.empleado_pid IS NOT NULL;

/*-----Vista que recupera distri_id_pro_id y dep_id apartir de distrito_id------*/
CREATE VIEW config_xdisprovdep AS
select
   nd.distrito_id,
   np.provincia_id,
   np.departamento_id 
from
   nprivate_distritos nd 
   inner join
      nprivate_provincias np 
      on nd.provincia_id = np.provincia_id;

/*vista que trae cucursal y areas del sucursal----------------------------------------------------*****/
CREATE OR REPLACE VIEW config_xsucuarea AS
select
   su.sucursal_id,
   su.nombre,
   ar.area_id,
   ar.codigo,
   ar.area
from
   config_sucusales su 
   inner join
      config_areas ar 
      on su.sucursal_id = ar.sucursal_id;
/*MDL ----------------------------------------------------*****/

insert into config_sucusales (suc_padre,distrito_id,ruc,r_social,nombre, direccion, licencia) 
values (null,1594,'20146247084','MUNICIPALIDAD PROVINCIAL DE PUNO', 'Biblioteca Municipal Gamaliel Churata','Jr. Deustua Nro. 458 Cercado','2021/12/31');
/*insert into config_sucusales (distrito_id,ruc,r_social,nombre, direccion, licencia)
values (1594,'20146247084','MUNICIPALIDAD PROVINCIAL DE PUNO', 'Biblioteca Municipal Preuniversitaria','Jr. Acora Nro. 158 Cercado','2021/12/31');*/
select * from config_sucusales;

insert into config_areas (sucursal_id, codigo, area, funciones)
values (1,'JEF','JEFATURA','Especialista de Biblioteca'),
(1,'CIRC','CIRCULACION','préstamo y catalogacion de libros'),
(1,'INFO','INFORMATICA','Sistematizacion, administracion, catalogacion y afines');
/*,(2,'CIR-II','CIRCULACION','préstamo y catalogacion de libros'),
(2,'INF-II','INFORMATICA','Sistematizacion, administracion, catalogacion y afines');*/
select * from config_areas;

insert into config_empleados (empleado_id, area_id,empleado_pid)
values (1,1, null);
insert into config_empleados (empleado_id, area_id)
values (2,2),(3,2),(4,2);
select * from config_empleados;

insert into config_cuentas (empleado_id, cuenta_pid, correo, pass, passini) values
(1,null,'user-root@gmail.com','$2y$12$7XBLmNAuuiDHjP0v06/pW.CFNB2vSrRQHzXIIG9EFLSWGOfzkE/Ue','$2y$12$7XBLmNAuuiDHjP0v06/pW.CFNB2vSrRQHzXIIG9EFLSWGOfzkE/Ue');/*gettherefast71428-07bc12bd8632852a70b1cea301*/
insert into config_cuentas (empleado_id, correo, pass, passini) values
(2,'pepearanibar@gmail.com','6e9552c9bd8e61c8f277c21220160234','6e9552c9bd8e61c8f277c21220160234'),
(3,'victorjhampier@gmail.com','6e9552c9bd8e61c8f277c21220160234','6e9552c9bd8e61c8f277c21220160234'), 
(4,'johnever@gmail.com','6e9552c9bd8e61c8f277c21220160234','6e9552c9bd8e61c8f277c21220160234');
select * from config_cuentas;

insert into config_cuentaapprol (app_id, cuenta_id, rol_id) values
(1,1,2), (2,1,2), (3,1,2);/*Root Por defecto a todas las apps*/

insert into config_cuentaapprol (app_id, cuenta_id, rol_id) values
(1,2,3),(2,2,3),/*Usuario Uno----*/
(1,3,4),(2,3,1);/*Usuario Dos*/
insert into config_cuentaapprol (app_id, cuenta_id, rol_id) values
(3,1,2);/*Root Por defecto a todas las app APP PMP USER*/
select * from config_cuentaapprol;
SELECT * FROM config_xdisprovdep where distrito_id = 1641;

select * from config_xsucuarea where area_id = 5

select * from nprivate_personas where dni = '41249225';
select AES_ENCRYPT(dni,"mama") dni ,nombre,apellido,empleado_id gvotacion,area_id,distrito_id,f_nacimiento,sexo,profesion, direccion,correo,cel 
from config_xempleadoper where dni = '41249225';
select * from config_empleados;
select *from config_xuserempleado
select * from config_cuentas
update config_cuentas set estado = false where cuenta_id =100
select * from config_xempleadoper
select * from nprivate_roles;
select * from nprivate_apps 
pepearanibar@gmail.com
select * from config_empleados;
/**CONSULTAS***/
select * from config_cuentas;
select * from config_cuentaapprol;
select * from config_xuseremprol;
select * from config_cuentaapprol WHERE f_registro = '2019-11-11 11:11:11';
/*Muy Importante*/
INSERT INTO config_cuentaapprol (app_id, cuenta_id, rol_id)VALUES(2,3,2)ON DUPLICATE KEY UPDATE rol_id = 2;
select * from config_xsubmenusubapp 
where app_id = 2 AND (rol = 5 OR rol = 7)

select HEX(AES_ENCRYPT('Informacion', 'munffdo')) id;/*AES_DECRYPT y UNHEX.*/
create table example(
	id int auto_increment,
    nombre varchar(30),
    primary key (id)
);
select UNHEX('BC4755EABB340DFE500BDC4A26A60466')
insert into example(nombre) value ('victor'),('Juan'),('pedro');
select * from example 
select * from config_xapprolcuenta
select * from config_xempleadoper;


select * from config_cuentaapprol where cuenta_id = 4 and app_id>1;

select * from config_xuserempleado where dni = '48207109';

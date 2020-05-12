create database _munipunominierp;
use _munipunominierp;

create table nprivate_apps (
	app_id int auto_increment,
	app VARCHAR(20) not null unique,
	descricpcion VARCHAR(60) not null,
	controller VARCHAR(30) not null,
	autor VARCHAR(30) not null,
	f_registro TIMESTAMP not null default current_timestamp,
	primary key (app_id)
); 
create table nprivate_submenus (
	submenu_id int auto_increment,
    app_id int not null,
    submenu varchar(40) not null,
    foreign key (app_id) references nprivate_apps(app_id),
    primary key (submenu_id)
);
create table nprivate_subapps(
	subapp_id int auto_increment,
    submenu_id int not null,
    subapp varchar(40) not null, 
    controller varchar (50) not null unique,/*[Controller]/[function/method]*/
    foreign key (submenu_id) references nprivate_submenus(submenu_id),
    primary key (subapp_id)
);

create table nprivate_roles(
	rol_id int auto_increment,
    id_rol int not null default 1,
	rol VARCHAR(15) not null,
	descripcion VARCHAR(80) not null,    
	primary key (rol_id)
);
insert into nprivate_roles (rol, descripcion) values ('Ninguno','Sin Privilegios');
select * from nprivate_roles; ALTER TABLE nprivate_roles ADD foreign key (id_rol) references nprivate_roles(rol_id);

create table nprivate_departamentos(
	departamento_id INT not null,
	departamento VARCHAR(60) not null,
    primary key (departamento_id)
);
/*create table nprivate_provincias (
	provincia_id int not null,
	departamento_id int not null,
	provincia varchar(60) not null,
	foreign key (departamento_id) references nprivate_departamentos (departamento_id),
	primary key (provincia_id)	
);

create table nprivate_distritos(
	distrito_id int not null,
	provincia_id int not null,
	distrito varchar(60) not null,
	foreign key (provincia_id) references nprivate_provincias (provincia_id),
	primary key (distrito_id)
);
create table nprivate_personas(
	persona_id int auto_increment,
	distrito_id INT not null,
	dni CHAR(8) not null,
	nombre VARCHAR(60) not null,
	apellido VARCHAR(60) not null,
	sexo int not NULL check (sexo < 4 and sexo > 0),mem_cuentas
	f_nacimiento DATE not null,
	direccion VARCHAR(60) not null,
	correo VARCHAR(60) not null,
	cel VARCHAR(15),
	f_registro TIMESTAMP not null default current_timestamp,
	foreign key (distrito_id) references nprivate_distritos (distrito_id),
	primary key (persona_id)	
);*/

create table mem_grupos(
	grupo_id int auto_increment,
    grupo varchar(30) not null unique,
    descripcion varchar(60) not null,
    primary key (grupo_id)    
);


create table mem_miembros (
	miembro_id int not null,
	grupo_id INT not null,
	estado BOOL not null default true,
	f_registro TIMESTAMP not null default current_timestamp,
	foreign key (miembro_id) references nprivate_personas (persona_id),	
	foreign key (grupo_id) references mem_grupos (grupo_id),	
	primary key (miembro_id)
);
select * from mem_cuentas;
create table mem_cuentas (
	cuenta_id int auto_increment,
	miembro_id INT not null,
	correo VARCHAR(80) not null,
	pass VARCHAR(32) not null,
	estado BOOL default true,
	f_registro timestamp not null default current_timestamp,
	foreign key (miembro_id)  references mem_miembros (miembro_id),
	primary key (cuenta_id, miembro_id)
);
create table mem_cuenta_app(
	app_id INT not null,
	cuenta_id INT not null,
	rol_id INT not null,
	f_registro TIMESTAMP not null default current_timestamp,
	foreign key (app_id) references nprivate_apps (app_id),
	foreign key (cuenta_id) references mem_cuentas (cuenta_id),
	foreign key (rol_id) references nprivate_roles (rol_id),
	primary key (app_id,cuenta_id)	
);

CREATE VIEW mem_app_rol_cuenta AS 
select
   ca.cuenta_id, a.app_id, a.app, a.controller, r.rol_id, r.rol
from
	mem_cuenta_app ca 
	inner join
		nprivate_apps a 
		on ca.app_id = a.app_id
	inner join 
		nprivate_roles r
		on ca.rol_id = r.rol_id;
/*-----end view------*/
CREATE VIEW submenu_subapp AS 
select
	ap.subapp_id,
	ap.subapp,
	me.submenu_id,
    me.submenu,
	me.app_id   
from
   nprivate_submenus me 
   inner join
      nprivate_subapps ap 
      on me.submenu_id = ap.submenu_id;



select * from submenu_subapp;
select * from nprivate_submenus;
select * from mem_app_rol_cuenta;

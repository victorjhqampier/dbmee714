create table contenedores(
	contenedor_id int not null,
	num_seccion int not null, --000,200,800 literatura
	num_paginacion int not null,
	num_totalbook int not null,
	repo_code varchar(11) not null,
	repo_name varchar(100) not null,
	repo_url varchar (100) not null,
	primary key (contenedor_id)
)

create table scraping(
	scraping_id int not null,
	contenedor_id int not null,
	last_seccion int not null,
	last_paginacion int not null,
	last_totalbook int not null,
	foreign key (contenedor_id) references contenedores (contenedor_id),
	primary key (scraping_id)
)

--BASE DE DATOS DE LIBROS
create schema book;

create table book.editoriales(
	editorial_id int not null,
	editorial varchar (254) not null,
	url varchar (100) not null,
	primary key (editorial_id)
)
create table book.personas(
	persona_id int not null,
	apellidos varchar(200) not null,
	nombres varchar (200),
	descripcion varchar (200),
	primary key (persona_id)	
)

create table book.clasificacione(
	clasificacion_id int not null,
	codigo varchar(15) not null,
	descripcion varchar (200),
	primary key (clasificacion_id)
)

create table libros (
	libro_id int not null,
	clasificacion_id int not null,
	code varchar(11) not null,
	titulo varchar(224) not null,
	fpublicacion varchar(50) not null, --2015 primera edicion
	nota text,
	nota2 text,
	image_url varchar(200) not null, 
	foreign key (clasificacion_id) references clasificaciones (clasificacion_id),
	primary key (libros_id)	
)

create table v_persona_libros (
	personas_id int not null,
	
)
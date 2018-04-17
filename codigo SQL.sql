DROP TABLE votosPublicacion;
DROP TABLE publicacion;
DROP TABLE logroConseguido;
DROP TABLE logro;
DROP TABLE juegoPendiente;
DROP TABLE juegoCompletado;
DROP TABLE juegoEnCurso;
DROP TABLE juego;
DROP TABLE seguidor;
DROP TABLE usuario;
CREATE TABLE usuario(
	seudonimo VARCHAR(20) PRIMARY KEY NOT NULL,
	nombre VARCHAR(50) NOT NULL,
	email VARCHAR(75) NOT NULL UNIQUE,
	password VARCHAR(200) NOT NULL,
	imagen VARCHAR(250) DEFAULT 'default',
	experiencia INT DEFAULT 0,
	nivel INT DEFAULT 1
	);

CREATE TABLE seguidor(
	usuario VARCHAR(20),
	usuario_seguido VARCHAR(20),
	fecha DATE NOT NULL,
	CONSTRAINT PK_seguidor PRIMARY KEY (usuario, usuario_seguido),
	CONSTRAINT FK_usuario FOREIGN KEY (usuario) REFERENCES usuario(seudonimo),
	CONSTRAINT FK_usuario_seguido FOREIGN KEY (usuario_seguido) REFERENCES usuario(seudonimo)
	);

CREATE TABLE juego(
	id_juego INT PRIMARY KEY NOT NULL,
	nombre VARCHAR(100) NOT NULL
	);

CREATE TABLE juegoPendiente(
	usuario VARCHAR(20) NOT NULL,
	id_juego INT NOT NULL,	CONSTRAINT PK_jueg_pend PRIMARY KEY (id_juego, usuario),
	CONSTRAINT FK_jp_juego FOREIGN KEY (id_juego) REFERENCES juego(id_juego),
	CONSTRAINT FK_jp_usur FOREIGN KEY (usuario) REFERENCES usuario(seudonimo)
	);

CREATE TABLE juegoEnCurso(
	usuario VARCHAR(20) NOT NULL,
	id_juego INT NOT NULL,
	CONSTRAINT PK_jueg_EC PRIMARY KEY (id_juego, usuario),
	CONSTRAINT FK_ec_juego FOREIGN KEY (id_juego) REFERENCES juego(id_juego),
	CONSTRAINT FK_ec_usur FOREIGN KEY (usuario) REFERENCES usuario(seudonimo)
	);

CREATE TABLE juegoCompletado(
	usuario VARCHAR(20) NOT NULL,
	id_juego INT NOT NULL,
	CONSTRAINT PK_jueg_comp PRIMARY KEY (id_juego, usuario),
	CONSTRAINT FK_cp_juego FOREIGN KEY (id_juego) REFERENCES juego(id_juego),
	CONSTRAINT FK_cp_usur FOREIGN KEY (usuario) REFERENCES usuario(seudonimo)
	);

CREATE TABLE logro(
	id_logro VARCHAR(50) PRIMARY KEY NOT NULL,
	nombre VARCHAR(100) NOT NULL,
	imagen VARCHAR(250) DEFAULT 'sin_imagen',
	imagen_conseguido VARCHAR(250) DEFAULT 'sin_imagen_2',
	descripcion TEXT NOT NULL,
	experiencia INT NOT NULL,
	secreto TINYINT(1) NOT NULL DEFAULT 0
	);

CREATE TABLE logroConseguido(
	usuario VARCHAR(20) NOT NULL,
	id_logro VARCHAR(50) NOT NULL,
	CONSTRAINT Pk_lgr_cons PRIMARY KEY (id_logro, usuario),
	CONSTRAINT FK_lgr_log FOREIGN KEY (id_logro) REFERENCES logro(id_logro),
	CONSTRAINT FK_lgr_usr FOREIGN KEY (usuario) REFERENCES usuario(seudonimo)
	);

CREATE TABLE publicacion(
	id_publicacion INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
	usuario VARCHAR(20) NOT NULL,
	fecha DATE NOT NULL,
	spoiler TINYINT(1) NOT NULL DEFAULT 0,
	juego INT DEFAULT NULL,
	texto TEXT NOT NULL,
	reports INT NOT NULL DEFAULT 0,
	CONSTRAINT FK_publicacion_usuario FOREIGN KEY (usuario) REFERENCES usuario (seudonimo),
	CONSTRAINT FK_publicacion_juego FOREIGN KEY (juego) REFERENCES juego (id_juego)
	);

CREATE TABLE votosPublicacion(
	usuario VARCHAR(20) NOT NULL,
	id_publicacion INT NOT NULL,
    fecha DATE NOT NULL,
	CONSTRAINT PK_votos PRIMARY KEY (usuario, id_publicacion),
	CONSTRAINT FK_votos_pu FOREIGN KEY (id_publicacion) REFERENCES publicacion(id_publicacion),
	CONSTRAINT FK_votos_us FOREIGN KEY (usuario) REFERENCES usuario(seudonimo)
	);

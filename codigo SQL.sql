DROP TABLE votosPublicacion;
DROP TABLE publicacion;
DROP TABLE logroConseguido;
DROP TABLE juegoPendiente;
DROP TABLE juegoCompletado;
DROP TABLE juegoEnCurso;
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

-- Trigger Obtener logros -> Escribir publicaciones
CREATE TRIGGER logro_escribir_publicaciones
  AFTER INSERT ON publicacion
  FOR EACH ROW
  BEGIN
    IF (SELECT COUNT(*) FROM publicacion WHERE usuario = NEW.usuario) = 1 THEN
      INSERT INTO logroConseguido (usuario, id_logro) VALUE (NEW.usuario, 'coment_1');
    end if;

    IF (SELECT COUNT(*) FROM publicacion WHERE usuario = NEW.usuario) = 10 THEN
      INSERT INTO logroConseguido (usuario, id_logro) VALUE (NEW.usuario, 'coment_10');
    end if;

    IF (SELECT COUNT(*) FROM publicacion WHERE usuario = NEW.usuario) = 100 THEN
      INSERT INTO logroConseguido (usuario, id_logro) VALUE (NEW.usuario, 'coment_100');
    end if;

    IF (SELECT COUNT(*) FROM publicacion WHERE usuario = NEW.usuario) = 2000 THEN
      INSERT INTO logroConseguido (usuario, id_logro) VALUE (NEW.usuario, 'coment_2000');
    end if;
  end;

-- Creatte trigger logros -> HACKS
CREATE TRIGGER logro_hacks
  AFTER UPDATE ON publicacion
  FOR EACH ROW
  BEGIN
    IF NEW.reports >= 100 THEN
      INSERT INTO logroConseguido (usuario, id_logro) VALUE (NEW.usuario, 'hacks');
    end if;
  end;

-- Trigger añadir experiencia a usuario
CREATE TRIGGER add_exp_user
  AFTER INSERT ON logroConseguido
  FOR EACH ROW
  BEGIN
    UPDATE usuario SET experiencia = experiencia + (SELECT experiencia
                                                    FROM logro
                                                    WHERE logro.id_logro = NEW.id_logro)
    WHERE seudonimo = NEW.usuario;
  end;

-- Triger actualizar nivel usuario
CREATE TRIGGER actualizar_nivel
  BEFORE UPDATE ON usuario
  FOR EACH ROW
  BEGIN
    WHILE NEW.experiencia >= (100*((NEW.nivel DIV 10) + 1)) DO
      SET NEW.experiencia = NEW.experiencia - (100*((NEW.nivel DIV 10) + 1)), NEW.nivel = NEW.nivel + 1;
    end while;
  end;

-- trigger logros -> tabla seguidores
CREATE TRIGGER seguidores_logros
  AFTER INSERT ON seguidor
  FOR EACH ROW
  BEGIN
    -- SEGUIR
    IF (SELECT COUNT(*) FROM seguidor WHERE usuario = NEW.usuario) = 1 THEN
      INSERT INTO logroConseguido (usuario, id_logro) VALUE (NEW.usuario, 'ec_ojo');
    end if;

    IF (SELECT COUNT(*) FROM seguidor WHERE usuario = NEW.usuario) = 50 THEN
      INSERT INTO logroConseguido (usuario, id_logro) VALUE (NEW.usuario, 'cu_man');
    end if;

    IF (SELECT COUNT(*) FROM seguidor WHERE usuario = NEW.usuario) = 100 THEN
      INSERT INTO logroConseguido (usuario, id_logro) VALUE (NEW.usuario, 'gra_mar');
    end if;

    IF (SELECT COUNT(*) FROM seguidor WHERE usuario = NEW.usuario) = 1000 THEN
      INSERT INTO logroConseguido (usuario, id_logro) VALUE (NEW.usuario, 'todo_oye');
    end if;

    -- SUBXSUB
    IF (SELECT COUNT(*) FROM seguidor WHERE usuario = NEW.usuario) > 50 THEN
      IF (SELECT COUNT(*) FROM seguidor WHERE usuario_seguido = NEW.usuario) > 50 THEN
        IF (SELECT COUNT(*) FROM seguidor WHERE usuario = NEW.usuario) = (SELECT COUNT(*) FROM seguidor WHERE usuario_seguido = NEW.usuario) THEN
          IF (SELECT COUNT(*) FROM logroConseguido WHERE logroConseguido.usuario = NEW.usuario AND id_logro = 'subxsub') = 0 THEN
            INSERT INTO logroConseguido (usuario, id_logro) VALUE (NEW.usuario, 'subxsub');
          end if;
        end if;
      end if;
    end if;

    IF (SELECT COUNT(*) FROM seguidor WHERE usuario = NEW.usuario_seguido) > 50 THEN
      IF (SELECT COUNT(*) FROM seguidor WHERE usuario_seguido = NEW.usuario_seguido) > 50 THEN
        IF (SELECT COUNT(*) FROM seguidor WHERE usuario = NEW.usuario_seguido) = (SELECT COUNT(*) FROM seguidor WHERE usuario_seguido = NEW.usuario_seguido) THEN
          IF (SELECT COUNT(*) FROM logroConseguido WHERE logroConseguido.usuario = NEW.usuario_seguido AND id_logro = 'subxsub') = 0 THEN
            INSERT INTO logroConseguido (usuario, id_logro) VALUE (NEW.usuario_seguido, 'subxsub');
          end if;
        end if;
      end if;
    end if;

    -- SEGUIDO
    IF (SELECT COUNT(*) FROM seguidor WHERE usuario_seguido = NEW.usuario_seguido) = 1 THEN
      INSERT INTO logroConseguido (usuario, id_logro) VALUE (NEW.usuario_seguido, 'er_pop');
    end if;

    IF (SELECT COUNT(*) FROM seguidor WHERE usuario_seguido = NEW.usuario_seguido) = 100 THEN
      INSERT INTO logroConseguido (usuario, id_logro) VALUE (NEW.usuario_seguido, 'te_me_mo');
    end if;

    IF (SELECT COUNT(*) FROM seguidor WHERE usuario_seguido = NEW.usuario_seguido) = 500 THEN
      INSERT INTO logroConseguido (usuario, id_logro) VALUE (NEW.usuario_seguido, 'boein_747');
    end if;

    IF (SELECT COUNT(*) FROM seguidor WHERE usuario_seguido = NEW.usuario_seguido) = 1000 THEN
      INSERT INTO logroConseguido (usuario, id_logro) VALUE (NEW.usuario_seguido, 'eje_fans');
    end if;
  end;

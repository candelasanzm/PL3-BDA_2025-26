---------- Cuestión 0
SELECT pg_reload_conf();

---------- Cuestión 1

-- Ver si el wal está activo
SHOW wal_level;

-- Determinar cuál es el directorio
SHOW data_directory;

-- Donde se guarda el archivo
SELECT pg_walfile_name(pg_current_wal_lsn());

---------- Cuestión 2

-- Eliminamos las tablas en caso de que existan para evitar errores
DROP TABLE IF EXISTS public."Grupo" CASCADE;
DROP TABLE IF EXISTS public."Conciertos" CASCADE;
DROP TABLE IF EXISTS public."Musicos" CASCADE;
DROP TABLE IF EXISTS public."Discos" CASCADE;
DROP TABLE IF EXISTS public."Grupos_Tocan_Conciertos" CASCADE;
DROP TABLE IF EXISTS public."Canciones" CASCADE;
DROP TABLE IF EXISTS public."Entradas" CASCADE;

-- Vamos a crear las tablas usando lo que nos dio pgmodeler. Primero creamos las que no tienen FKs
CREATE TABLE public."Grupo" (
    "Codigo_grupo" integer NOT NULL,
    "Nombre" text NOT NULL,
    "Genero_musical" text NOT NULL,
    "Pais" text NOT NULL,
    "Sitio_web" text NOT NULL,
    CONSTRAINT "Grupo_pk" PRIMARY KEY ("Codigo_grupo")
);

CREATE TABLE public."Conciertos" (
    "Codigo_concierto" integer NOT NULL,
    "Fecha_realizacion" date NOT NULL,
    "Pais" text NOT NULL,
    "Ciudad" text NOT NULL,
    "Recinto" text NOT NULL,
    CONSTRAINT "Conciertos_pk" PRIMARY KEY ("Codigo_concierto")
);

-- Luego las tablas con FKs
CREATE TABLE public."Musicos" (
    codigo_musico integer NOT NULL,
    "DNI" char(10) NOT NULL,
    "Nombre" text NOT NULL,
    "Direccion" text NOT NULL,
    "Codigo_Postal" integer NOT NULL,
    "Ciudad" text NOT NULL,
    "Provincia" text NOT NULL,
    telefono integer NOT NULL,
    "Instrumentos" text NOT NULL,
    "Codigo_grupo_Grupo" integer NOT NULL,
    CONSTRAINT "Musicos_pk" PRIMARY KEY (codigo_musico),
    CONSTRAINT "Unique_DNI" UNIQUE ("DNI"),
    CONSTRAINT "Grupo_fk" FOREIGN KEY ("Codigo_grupo_Grupo")
        REFERENCES public."Grupo" ("Codigo_grupo")
        ON DELETE RESTRICT ON UPDATE RESTRICT
);

CREATE TABLE public."Discos" (
    "Codigo_disco" integer NOT NULL,
    "Titulo" text NOT NULL,
    "Fecha_edicion" date NOT NULL,
    "Genero" text NOT NULL,
    "Formato" text NOT NULL,
    "Codigo_grupo_Grupo" integer NOT NULL,
    CONSTRAINT "Discos_pk" PRIMARY KEY ("Codigo_disco"),
    CONSTRAINT "Grupo_fk" FOREIGN KEY ("Codigo_grupo_Grupo")
        REFERENCES public."Grupo" ("Codigo_grupo")
        ON DELETE RESTRICT ON UPDATE RESTRICT
);

CREATE TABLE public."Canciones" (
    "Codigo_cancion" integer NOT NULL,
    "Nombre" text NOT NULL,
    "Compositor" text NOT NULL,
    "Fecha_grabacion" date NOT NULL,
    "Duracion" time NOT NULL,
    "Codigo_disco_Discos" integer NOT NULL,
    CONSTRAINT "Canciones_pk" PRIMARY KEY ("Codigo_cancion"),
    CONSTRAINT "Discos_fk" FOREIGN KEY ("Codigo_disco_Discos")
        REFERENCES public."Discos" ("Codigo_disco")
        ON DELETE RESTRICT ON UPDATE RESTRICT
);

CREATE TABLE public."Entradas" (
    "Codigo_entrada" integer NOT NULL,
    "Localidad" text NOT NULL,
    "Precio" money NOT NULL,
    "Usuario" text NOT NULL,
    "Codigo_concierto_Conciertos" integer NOT NULL,
    CONSTRAINT "Entradas_pk" PRIMARY KEY ("Codigo_entrada"),
    CONSTRAINT "Conciertos_fk" FOREIGN KEY ("Codigo_concierto_Conciertos")
        REFERENCES public."Conciertos" ("Codigo_concierto")
        ON DELETE RESTRICT ON UPDATE RESTRICT
);

CREATE TABLE public."Grupos_Tocan_Conciertos" (
    "Codigo_grupo_Grupo" integer NOT NULL,
    "Codigo_concierto_Conciertos" integer NOT NULL,
    CONSTRAINT "Grupos_Tocan_Conciertos_pk" PRIMARY KEY ("Codigo_grupo_Grupo","Codigo_concierto_Conciertos"),
    CONSTRAINT "Grupo_fk" FOREIGN KEY ("Codigo_grupo_Grupo")
        REFERENCES public."Grupo" ("Codigo_grupo")
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT "Conciertos_fk" FOREIGN KEY ("Codigo_concierto_Conciertos")
        REFERENCES public."Conciertos" ("Codigo_concierto")
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- Limpiamos los datos antes de hacer nada por si volvemos a lanzarlo evitar problemas
DELETE FROM public."Musicos" WHERE codigo_musico = 1;
DELETE FROM public."Grupo" WHERE "Codigo_grupo" = 1;

-- Abrimos la transacción
BEGIN;

-- Insertamos un grupo nuevo
INSERT INTO public."Grupo" ("Codigo_grupo", "Nombre", "Genero_musical", "Pais", "Sitio_web")
VALUES (1, 'Cuestion2', 'pop', 'España', 'www.cuestion2.com');

-- Insertamos un nuevo músico
INSERT INTO public."Musicos" (codigo_musico, "DNI", "Nombre", "Direccion", "Codigo_Postal", "Ciudad", "Provincia", telefono, "Instrumentos", "Codigo_grupo_Grupo")
VALUES (1, '123456789A', 'Cuestion2', 'Calle2', 28180, 'Madrid', 'Madrid', 612345789, 'Flauta', 1);

-- Cerramos la transacción
COMMIT;

---------- Cuestión 4

-- Para ver el identificador de la transacción se usa el comando xmin
SELECT xmin, * FROM public."Grupo" WHERE "Codigo_grupo" = 1;
SELECT xmin, * FROM public."Musicos" WHERE codigo_musico = 1;

---------- Cuestión 7

-- Eliminamos los usuarios si existen para evitar errores al relanzar el script, DROP OWNED BY elimina todos los permisos del usuario antes de borrarlo
DROP OWNED BY musico1;
DROP USER IF EXISTS musico1;

DROP OWNED BY musico2;
DROP USER IF EXISTS musico2;

DROP OWNED BY musico3;
DROP USER IF EXISTS musico3;

-- Creamos los tres usuarios
CREATE USER musico1 WITH PASSWORD 'musico1';
CREATE USER musico2 WITH PASSWORD 'musico2';
CREATE USER musico3 WITH PASSWORD 'musico3';

-- Damos permiso de conexión a la base de datos
GRANT CONNECT ON DATABASE musicos TO musico1, musico2, musico3;

-- Damos permiso para acceder al esquema public
GRANT USAGE ON SCHEMA public TO musico1, musico2, musico3;

-- Damos permiso de lectura y escritura, pero que no modifique la estructura
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO musico1, musico2, musico3;

---------- Cuestión 8

-- Abrimos la conexión de musico1 (nuevo data source con usuario y contraseña musico1 y database musicos)

-- En la consola de esta nueva conexión ejecutamos lo siguiente sin cerrar la transacción
-- Limpiamos los datos antes de hacer nada por si volvemos a lanzarlo evitar problemas
DELETE FROM public."Musicos" WHERE codigo_musico = 1300;
DELETE FROM public."Grupo" WHERE "Codigo_grupo" = 1300;

BEGIN;

INSERT INTO public."Grupo" ("Codigo_grupo", "Nombre", "Genero_musical", "Pais", "Sitio_web")
VALUES (1300, 'Piedras Negras', 'rock', 'España', 'www.piedrasnegras.com');

INSERT INTO public."Musicos" (codigo_musico, "DNI", "Nombre", "Direccion", "Codigo_Postal", "Ciudad", "Provincia", telefono, "Instrumentos", "Codigo_grupo_Grupo")
VALUES (1300, '123456789X', 'Musico_1300', 'Calle_1300', 39001, 'Santander', 'Cantabria', 612345789, 'Guitarra', 1300);

-- Comprobamos que los datos se han insertado correctamente
SELECT * FROM public."Grupo" WHERE "Codigo_grupo" = 1300;
SELECT * FROM public."Musicos" WHERE "DNI" = '123456789X';

-- En la consola de postgres comprobamos la actividad del sistema
SELECT pid, usename, state, query, wait_event_type, wait_event
FROM pg_stat_activity
WHERE datname = 'musicos';

---------- Cuestión 9

-- CONEXIÓN musico2: Abrir nuevo data source con usuario musico2, contraseña musico2 y database musicos
-- Ejecutar en la consola de musico2:
BEGIN;
SELECT * FROM public."Grupo" WHERE "Codigo_grupo" = 1300;

-- Ejecutar en la consola de postgres para ver la actividad del sistema:
SELECT pid, usename, state, query, wait_event_type, wait_event
FROM pg_stat_activity
WHERE datname = 'musicos';

---------- Cuestión 10

-- Comprobamos si los datos están físicamente en la tabla desde la conexión de postgres
SELECT * FROM public."Grupo" WHERE "Codigo_grupo" = 1300;
SELECT * FROM public."Musicos" WHERE codigo_musico = 1300;

---------- Cuestión 11

-- En la consola de la conexión de musico1
COMMIT;
SELECT * FROM public."Grupo" WHERE "Codigo_grupo" = 1300;
SELECT * FROM public."Musicos" WHERE codigo_musico = 1300;

-- En la consola de la conexión de musico2
SELECT * FROM public."Grupo" WHERE "Codigo_grupo" = 1300;
SELECT * FROM public."Musicos" WHERE codigo_musico = 1300;

---------- Cuestión 12

-- Limpiamos por si ya existen los datos
DELETE FROM public."Musicos" WHERE codigo_musico = 1400;
DELETE FROM public."Grupo" WHERE "Codigo_grupo" = 1400;

-- Abrimos en la consola del músico que queramos (en nuestro caso musico2)
BEGIN;

INSERT INTO public."Grupo" ("Codigo_grupo", "Nombre", "Genero_musical", "Pais", "Sitio_web")
VALUES (1400, 'Cuestion12', 'pop', 'España', 'www.cuestion12.com');

INSERT INTO public."Musicos" (codigo_musico, "DNI", "Nombre", "Direccion", "Codigo_Postal", "Ciudad", "Provincia", telefono, "Instrumentos", "Codigo_grupo_Grupo")
VALUES (1400, '123450000X', 'Musico1400', 'Calle_1400', 28180, 'Murcia', 'Murcia', 612345789, 'Oboe', 1400);

UPDATE public."Musicos" SET telefono = 918856931 WHERE codigo_musico = 1400;

UPDATE public."Grupo" SET "Codigo_grupo" = 1300 WHERE "Codigo_grupo" = 1400;

UPDATE public."Grupo" SET "Nombre" = 'Héroes del Silencio' WHERE "Codigo_grupo" = 1400;

COMMIT;

---------- Cuestión 13

-- Abrimos la conexión de musico1
-- En la consola de esta nueva conexión ejecutamos lo siguiente sin cerrar la transacción
-- Limpiamos los datos antes de hacer nada por si volvemos a lanzarlo evitar problemas
DELETE FROM public."Musicos" WHERE codigo_musico = 1500;
DELETE FROM public."Grupo" WHERE "Codigo_grupo" = 1500;

BEGIN;

INSERT INTO public."Grupo" ("Codigo_grupo", "Nombre", "Genero_musical", "Pais", "Sitio_web")
VALUES (1500, 'Piedras Blancas', 'pop', 'España', 'www.piedrasblancas.com');

INSERT INTO public."Musicos" (codigo_musico, "DNI", "Nombre", "Direccion", "Codigo_Postal", "Ciudad", "Provincia", telefono, "Instrumentos", "Codigo_grupo_Grupo")
VALUES (1500, '000000001X', 'Musico_1500', 'Calle_1500', 29001, 'Badajoz', 'Extremadura', 612345789, 'Guitarra', 1500);

-- Comprobamos que los datos se han insertado correctamente
SELECT * FROM public."Grupo" WHERE "Codigo_grupo" = 1500;
SELECT * FROM public."Musicos" WHERE codigo_musico = 1500;

-- En la consola de postgres comprobamos la actividad del sistema
SELECT pid, usename, state, query, wait_event_type, wait_event
FROM pg_stat_activity
WHERE datname = 'musicos';

-- CONEXIÓN musico2: Abrir nuevo data source con usuario musico2, contraseña musico2 y database musicos
-- Ejecutar en la consola de musico2:
BEGIN;
SELECT * FROM public."Grupo" WHERE "Codigo_grupo" = 1500;
SELECT * FROM public."Musicos" WHERE codigo_musico = 1500;

-- Ejecutar en la consola de postgres para ver la actividad del sistema:
SELECT pid, usename, state, query, wait_event_type, wait_event
FROM pg_stat_activity
WHERE datname = 'musicos';

-- En musico1 ejecutamos
ROLLBACK;

-- Volvemos a ejecutar en musico1 y musico2
SELECT * FROM public."Grupo" WHERE "Codigo_grupo" = 1500;
SELECT * FROM public."Musicos" WHERE codigo_musico = 1500;

---------- Cuestión 14

CREATE TABLE public."ValorA" (
    A real not NULL,
    CONSTRAINT "ValorA_pk" PRIMARY KEY (A)
);

CREATE TABLE public."ValorB" (
    B real not NULL,
    CONSTRAINT "ValorB_pk" PRIMARY KEY (B)
);

CREATE TABLE public."ValorC" (
    C real not NULL,
    CONSTRAINT "ValorC_pk" PRIMARY KEY (C)
);

INSERT INTO public."ValorA" (A) VALUES (40);
INSERT INTO public."ValorB" (B) VALUES (50);
INSERT INTO public."ValorC" (C) VALUES (60);

---------- Cuestión 15



---------- Cuestión 16



---------- Cuestión 17



---------- Cuestión 18
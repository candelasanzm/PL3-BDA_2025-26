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

---------- Cuestión 3



---------- Cuestión 4
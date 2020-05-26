--I CREANDO
--Tablas
create table BIENES (
	codigo CHAR(7) NOT NULL,
	nombre VARCHAR(30) NOT NULL,
	medida CHAR(2) NOT NULL,
	unitario NUMBER(5) NOT NULL,
	retirado CHAR(1) NOT NULL
);

create table FAMILIAS (
	numero NUMBER(5) NOT NULL,
    representante NUMBER(7) NOT NULL
);

create table PERSONAS (
	codigo NUMBER(7) NOT NULL,
	nombre VARCHAR(50) NOT NULL,
	familia NUMBER(5)
);

create table ASIGNACIONES (
	numero NUMBER(9) NOT NULL,
	fecha DATE NOT NULL,
	aceptado CHAR(1),
	familia NUMBER(5) NOT NULL
);

create table BIENESASIGNADOS(
	asignacion NUMBER(9) NOT NULL,
    bien CHAR(7) NOT NULL
);

create table BIENESFAMILIAS(
	bien CHAR(7) NOT NULL,
	familia NUMBER(5) NOT NULL
);

create table OPINIONES(
	numero NUMBER(5) NOT NULL,
	fecha DATE NOT NULL,
	opinion CHAR(1) NOT NULL,
	justificacion VARCHAR(20) NOT NULL,
	bien CHAR(7) NOT NULL,
	persona NUMBER(7) NOT NULL
);

create table OPINIONESGRUPALES(
	numero NUMBER(5) NOT NULL,
	detalle VARCHAR(200),
	estrellas NUMBER(1) NOT NULL
);

--xTablas
drop table BIENES;
drop table FAMILIAS;
drop table PERSONAS;
drop table ASIGNACIONES;
drop table BIENESASIGNADOS;
drop table BIENESFAMILIA;
drop table OPINIONES;
drop table OPINIONESGRUPALES;

--II PROTEGIENDO
--Atributos
ALTER TABLE OPINIONES
    ADD CONSTRAINT CK_TOPINION
        CHECK(opinion='E' OR opinion='B' OR opinion='R' OR opinion='M');

ALTER TABLE OPINIONESGRUPALES
    ADD CONSTRAINT CK_TDETALLE
        CHECK(detalle LIKE 'Adjetivo: %. Descripcion: %. Puntaje: %.');
		
ALTER TABLE OPINIONESGRUPALES
    ADD CONSTRAINT CK_TESTRELLA
        CHECK(estrellas>0 AND estrellas<6);

--Primarias
ALTER TABLE BIENES ADD CONSTRAINT PK_BIENES
 PRIMARY KEY(codigo);
 
ALTER TABLE PERSONAS ADD CONSTRAINT PK_PERSONAS
 PRIMARY KEY(codigo);
 
ALTER TABLE OPINIONES ADD CONSTRAINT PK_BIENES
 PRIMARY KEY(numero);
 
ALTER TABLE OPINIONESGRUPALES ADD CONSTRAINT PK_OP_GRUPALES
 PRIMARY KEY(numero);
 
--Unicas
ALTER TABLE OPINIONES ADD CONSTRAINT UK_OPINIONES UNIQUE (justificacion); 

--Foraneas
ALTER TABLE PERSONAS ADD CONSTRAINT FK_PERSONA_FAMILIA
    FOREIGN KEY (familia) REFERENCES FAMILIAS(numero);

ALTER TABLE OPINIONES ADD CONSTRAINT FK_OPINION_BIEN
    FOREIGN KEY (bien) REFERENCES BIENES(codigo);
	
ALTER TABLE OPINIONESGRUPALES ADD CONSTRAINT FK_OPGRUP_OPINION
    FOREIGN KEY (numero) REFERENCES OPINIONES(numero);
	
--III PROBANDO Y CONSULTANDO	
--Poblar

insert into OPINIONES(numero,fecha,opinion,justificacion,bien,persona) values (25146,TO_DATE('21/05/2020','DD/MM/YYYY'),'E','Un bien muy bueno','2548963','5478965');
insert into OPINIONES(numero,fecha,opinion,justificacion,bien,persona) values (57896,TO_DATE('19/02/2020','DD/MM/YYYY'),'R','Un bien muy regular','5786423','7845963');
--PoblarNoOk

insert into OPINIONES(numero,fecha,opinion,justificacion,bien,persona) values (12345,'21/05/2020','M','Un bien muy malo','4589654');
insert into OPINIONES(numero,fecha,opinion,justificacion,bien,persona) values (78945,TO_DATE('19/02/2020','DD/MM/YYYY'),'R','Un bien muy regular',5786423);
insert into OPINIONES(numero,fecha,opinion,justificacion,bien,persona) values (12348,'E','Un bien muy bueno','2548963','5478965');

--Beneficiario- Consultar los bienes más populares del ultimo mes

SELECT BIENES.codigo,BIENES.nombre,COUNT(OPINIONES.opinion) FROM BIENES JOIN OPINIONES ON BIENES.codigo=OPINIONES.bien
	WHERE a.opinion='E' AND fecha<'2020-04-21'
		ORDER BY ;

--IV DEFINIENDO DATOS EN XML
--Poblar xml

<?xml version="1.0"?>

<!DOCTYPE opiniones SYSTEM ayudar2.dtd>

<opiniones>
	<opinion>
		<numero>15236</numero>
		<fecha>2020-05-21</fecha>
		<opinionPersona>E</opinionPersona>
		<justificacion>Un bien muy bueno</justificacion>
		<bien>2548963</bien>
		<persona>5478965</persona>
	</opinion>
	<opinion>
		<numero>57896</numero>
		<fecha>2020-05-19</fecha>
		<opinionPersona>R</opinionPersona>
		<justificacion>Un bien muy regular</justificacion>
		<bien>5786423</bien>
		<persona>7845963</persona>
	</opinion>
</opiniones>


--VI PAQUETES
--CRUDE
	CREATE OR REPLACE PACKAGE PC_OPINION IS
		PROCEDURE AD_BIENES (xcodigo IN CHAR, xnombre IN VARCHAR, xmedida IN CHAR, xunitario IN NUMBER,xretirado IN CHAR);
		PROCEDURE AD_PERSONAS (xcodigo IN NUMBER, xnombre IN VARCHAR, xfamilia IN NUMBER);
		PROCEDURE AD_OPINIONES (xnumero IN NUMBER, xfecha IN DATE, xopinion IN CHAR, xjustificacion IN VARCHAR, xbien IN CHAR, xpersona IN NUMBER);
		PROCEDURE AD_OPINIONESGRUPALES (xnumero IN NUMBER, xdetalle IN VARCHAR, xestrellas IN NUMBER);
		FUNCTION CO_REGISTRAR_OPINION RETURN SYS_REFCURSOR;
	END PC_OPINION;

--CRUDI
CREATE OR REPLACE PACKAGE BODY PC_ACTIVIDAD IS
		PROCEDURE AD_BIENES (xcodigo IN CHAR, xnombre IN VARCHAR, xmedida IN CHAR, xunitario IN NUMBER,xretirado IN CHAR) IS
		BEGIN
			INSERT INTO BIENES(codigo,nombre,medida,unitario,retirado) VALUES (xcodigo,xnombre,xmedida,xunitario,xretirado);
			COMMIT;
			EXCEPTION
				WHEN OTHERS THEN 
				ROLLBACK;
				RAISE_APPLICATION_ERROR(-20001, 'No se puede insertar el bien.');
		END;
		
		PROCEDURE AD_PERSONAS (xcodigo IN NUMBER, xnombre IN VARCHAR, xfamilia IN NUMBER) IS
		BEGIN
			INSERT INTO PERSONAS(codigo,nombre,familia) VALUES (xcodigo,xnombre,xfamilia);
			COMMIT;
			EXCEPTION
				WHEN OTHERS THEN 
				ROLLBACK;
				RAISE_APPLICATION_ERROR(-20001, 'No se puede insertar la familia.');
		END;
		
		PROCEDURE AD_OPINIONES (xnumero IN NUMBER, xfecha IN DATE, xopinion IN CHAR, xjustificacion IN VARCHAR, xbien IN CHAR, xpersona IN NUMBER) IS
		BEGIN
			INSERT INTO OPINIONES(numero,fecha,opinion,justificacion,bien,persona) VALUES (xnumero,xfecha,xopinion,xjustificacion,xbien,xpersona);
			COMMIT;
			EXCEPTION
				WHEN OTHERS THEN 
				ROLLBACK;
				RAISE_APPLICATION_ERROR(-20001, 'No se puede insertar la opinion.');
		END;
		
		PROCEDURE AD_OPINIONESGRUPALES (xnumero IN NUMBER, xdetalle IN VARCHAR, xestrellas IN NUMBER) IS
		BEGIN
			INSERT INTO OPINIONESGRUPALES(numero,detalle,estrellas) VALUES (xnumero,xdetalle,xestrellas);
			COMMIT;
			EXCEPTION
				WHEN OTHERS THEN 
				ROLLBACK;
				RAISE_APPLICATION_ERROR(-20001, 'No se puede insertar la opinion grupal.');
		END;
		
		FUNCTION CO_REGISTRAR_OPINION RETURN SYS_REFCURSOR IS CO_OP SYS_REFCURSOR;
		BEGIN
		OPEN CO_OP FOR
			
		END;
	END PC_ACTIVIDAD;




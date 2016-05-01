--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.1
-- Dumped by pg_dump version 9.5.1

-- Started on 2016-05-01 19:07:34

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 1 (class 3079 OID 12355)
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- TOC entry 2220 (class 0 OID 0)
-- Dependencies: 1
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

--
-- TOC entry 195 (class 1255 OID 16394)
-- Name: f_actualizar_posicion(integer, integer, numeric, numeric); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION f_actualizar_posicion(integer, integer, numeric, numeric) RETURNS integer
    LANGUAGE plpgsql
    AS $_$
	DECLARE
		
	BEGIN
		INSERT INTO hist_ubicacion (recursoid,estado,ubicacionlat,ubicacionlng)
		VALUES ($1,$2,$3,$4);
		RETURN 1;
	EXCEPTION
		WHEN OTHERS THEN
			RETURN -2;
	END
$_$;


ALTER FUNCTION public.f_actualizar_posicion(integer, integer, numeric, numeric) OWNER TO postgres;

--
-- TOC entry 196 (class 1255 OID 16395)
-- Name: f_check_recurso(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION f_check_recurso(integer) RETURNS integer
    LANGUAGE plpgsql
    AS $_$
    DECLARE
		count integer;
	BEGIN
		count:=-1;
		
		PERFORM *
		FROM recursos
		WHERE recursoid = $1;
		
		GET DIAGNOSTICS count = ROW_COUNT;
		return count;
	EXCEPTION
		WHEN OTHERS THEN
			RETURN -2;
		
	END
$_$;


ALTER FUNCTION public.f_check_recurso(integer) OWNER TO postgres;

--
-- TOC entry 198 (class 1255 OID 16396)
-- Name: f_check_user(character varying, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION f_check_user(v_user character varying, pass text) RETURNS TABLE(usuarioid integer, privilegios integer, nombre character varying, apellido character varying, direccion character varying, telefono character varying, dni character varying, notas text, username character varying, password text)
    LANGUAGE plpgsql
    AS $$
	BEGIN
	RETURN QUERY
		SELECT *
		FROM USUARIOS U
		WHERE U.USERNAME = v_user AND U.PASSWORD = pass;
	END
$$;


ALTER FUNCTION public.f_check_user(v_user character varying, pass text) OWNER TO postgres;

--
-- TOC entry 199 (class 1255 OID 16397)
-- Name: f_check_user_email(character varying, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION f_check_user_email(v_email character varying, pass text) RETURNS integer
    LANGUAGE plpgsql
    AS $$
	DECLARE
		i_email VARCHAR;
	BEGIN
		IF (hashed == 1) THEN
			SELECT USERNAME INTO i_email
			FROM USUARIOS
			WHERE USERNAME = v_email AND PASSWORD = pass;
		ELSE
			SELECT USERNAME INTO i_email
			FROM USUARIOS
			WHERE USERNAME = v_email AND PASSWORD = crypt(pass, PASSWORD);
		END IF;
		IF (i_user == NULL) THEN
			RETURN 1;
		ELSE
			RETURN 0;
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			RETURN -2;
	END
$$;


ALTER FUNCTION public.f_check_user_email(v_email character varying, pass text) OWNER TO postgres;

--
-- TOC entry 213 (class 1255 OID 16398)
-- Name: f_check_user_username(character varying, text, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION f_check_user_username(v_user character varying, pass text, hashed integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
	DECLARE
		i_user VARCHAR;
	BEGIN
		IF (hashed == 1) THEN
			SELECT USERNAME INTO i_user
			FROM USUARIOS
			WHERE USERNAME = v_user AND PASSWORD = pass;
		ELSE
			SELECT USERNAME INTO i_user
			FROM USUARIOS
			WHERE USERNAME = v_user AND PASSWORD = crypt(pass, PASSWORD);
		END IF;
		IF (i_user == NULL) THEN
			RETURN 1;
		ELSE
			RETURN 0;
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			RETURN -2;
	END
$$;


ALTER FUNCTION public.f_check_user_username(v_user character varying, pass text, hashed integer) OWNER TO postgres;

--
-- TOC entry 197 (class 1255 OID 16399)
-- Name: f_delete_user_username(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION f_delete_user_username(v_user character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
	DECLARE
		id INTEGER := -1;
	BEGIN
		DELETE FROM USUARIOS WHERE USERNAME = v_user
		RETURNING USUARIOID INTO id;
		RETURN result;
	EXCEPTION
		WHEN OTHERS THEN
			RETURN -2;
	END
$$;


ALTER FUNCTION public.f_delete_user_username(v_user character varying) OWNER TO postgres;

--
-- TOC entry 200 (class 1255 OID 16400)
-- Name: f_fin_incidencia(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION f_fin_incidencia(integer) RETURNS integer
    LANGUAGE plpgsql
    AS $_$
	DECLARE
		count integer;
	BEGIN
		UPDATE hist_incidencias SET
		fecharesolucion = now(),
		resolucion = -1
		WHERE incidenciaid = $1;
		GET DIAGNOSTICS count = ROW_COUNT;
		return count;
	EXCEPTION
		WHEN OTHERS THEN
			RETURN -2;
	END
$_$;


ALTER FUNCTION public.f_fin_incidencia(integer) OWNER TO postgres;

--
-- TOC entry 214 (class 1255 OID 16401)
-- Name: f_get_estacion(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION f_get_estacion(integer) RETURNS TABLE(estacionid integer, tiporecursoid integer, nombreestacion character varying, ubicacionestacionlat numeric, ubicacionestacionlng numeric)
    LANGUAGE plpgsql
    AS $_$
	BEGIN
	RETURN QUERY
		SELECT *
		FROM ESTACIONES
		WHERE ESTACIONES.ESTACIONID=$1;
	END
$_$;


ALTER FUNCTION public.f_get_estacion(integer) OWNER TO postgres;

--
-- TOC entry 215 (class 1255 OID 16402)
-- Name: f_get_estaciones(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION f_get_estaciones() RETURNS TABLE(estacionid integer, tiporecursoid integer, nombreestacion character varying, ubicacionestacionlat numeric, ubicacionestacionlng numeric)
    LANGUAGE plpgsql
    AS $$
	BEGIN
	RETURN QUERY
		SELECT *
		FROM ESTACIONES;
	END
$$;


ALTER FUNCTION public.f_get_estaciones() OWNER TO postgres;

--
-- TOC entry 216 (class 1255 OID 16403)
-- Name: f_get_estaciones(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION f_get_estaciones(integer) RETURNS TABLE(estacionid integer, tiporecursoid integer, nombreestacion character varying, ubicacionestacionlat numeric, ubicacionestacionlng numeric)
    LANGUAGE plpgsql
    AS $_$
	BEGIN
	RETURN QUERY
		SELECT *
		FROM ESTACIONES
		WHERE ESTACIONES.tiporecursoid=$1;
	END
$_$;


ALTER FUNCTION public.f_get_estaciones(integer) OWNER TO postgres;

--
-- TOC entry 217 (class 1255 OID 16404)
-- Name: f_get_incidencias_abiertas(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION f_get_incidencias_abiertas() RETURNS TABLE(incidenciaid integer, tipoincidenciaid integer, fechanotificacion timestamp without time zone, fecharesolucion timestamp without time zone, ubicacionlat numeric, ubicacionlng numeric, usuarioid integer, telefono character varying, notas text, gravedad integer, numeroafectados integer, resolucion integer)
    LANGUAGE plpgsql
    AS $$
	BEGIN
	RETURN QUERY
		SELECT *
		FROM hist_incidencias
		WHERE hist_incidencias.fecharesolucion IS NULL
		ORDER BY hist_incidencias.gravedad DESC, hist_incidencias.fechanotificacion;
	END
$$;


ALTER FUNCTION public.f_get_incidencias_abiertas() OWNER TO postgres;

--
-- TOC entry 218 (class 1255 OID 16405)
-- Name: f_get_incidencias_abiertas_usuario(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION f_get_incidencias_abiertas_usuario(integer) RETURNS TABLE(incidenciaid integer, tipoincidenciaid integer, fechanotificacion timestamp without time zone, fecharesolucion timestamp without time zone, ubicacionlat numeric, ubicacionlng numeric, usuarioid integer, telefono character varying, notas text, gravedad integer, numeroafectados integer, resolucion integer)
    LANGUAGE plpgsql
    AS $_$
	BEGIN
	RETURN QUERY
		SELECT *
		FROM hist_incidencias
		WHERE hist_incidencias.fecharesolucion IS NULL AND $1>0 AND (hist_incidencias.usuarioid = $1 OR (SELECT privilegios FROM usuarios WHERE usuarios.usuarioid=$1) = 1)
		ORDER BY hist_incidencias.fechanotificacion;
	END
$_$;


ALTER FUNCTION public.f_get_incidencias_abiertas_usuario(integer) OWNER TO postgres;

--
-- TOC entry 219 (class 1255 OID 16406)
-- Name: f_get_location_resource(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION f_get_location_resource(id integer) RETURNS TABLE(estado integer, lat numeric, lng numeric)
    LANGUAGE plpgsql
    AS $$
	DECLARE
		
	BEGIN
	RETURN QUERY
		SELECT H1.ESTADO, H1.UBICACIONLAT, H1.UBICACIONLNG
		FROM HIST_UBICACION H1 LEFT JOIN HIST_UBICACION H2
		ON (H1.RECURSOID = H2.RECURSOID AND H1.FECHA < H2.FECHA)
		WHERE H1.RECURSOID = id AND H2.FECHA IS NULL;
	END
$$;


ALTER FUNCTION public.f_get_location_resource(id integer) OWNER TO postgres;

--
-- TOC entry 220 (class 1255 OID 16407)
-- Name: f_get_location_station(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION f_get_location_station(id integer) RETURNS record
    LANGUAGE plpgsql
    AS $$
	DECLARE
		x RECORD;
	BEGIN
		SELECT E.UBICACIONLAT AS LAT, E.UBICACIONLNG AS LNG INTO x
		FROM ESTACIONES E
		WHERE E.ESTACIONID = id;
		RETURN x;
	EXCEPTION
		WHEN OTHERS THEN
			RETURN NULL;
	END
$$;


ALTER FUNCTION public.f_get_location_station(id integer) OWNER TO postgres;

--
-- TOC entry 221 (class 1255 OID 16408)
-- Name: f_get_name_station(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION f_get_name_station(id integer) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
	DECLARE
		name VARCHAR := 'N/A';
	BEGIN
		SELECT E.NOMBREESTACION AS name
		FROM ESTACIONES E
		WHERE E.ESTACIONID = id;
		RETURN name;
	EXCEPTION
		WHEN OTHERS THEN
			RETURN NULL;
	END
$$;


ALTER FUNCTION public.f_get_name_station(id integer) OWNER TO postgres;

--
-- TOC entry 222 (class 1255 OID 16409)
-- Name: f_get_nearest_resource(numeric, numeric, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION f_get_nearest_resource(lat numeric, lng numeric, type integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
	DECLARE

	BEGIN

	END
$$;


ALTER FUNCTION public.f_get_nearest_resource(lat numeric, lng numeric, type integer) OWNER TO postgres;

--
-- TOC entry 223 (class 1255 OID 16410)
-- Name: f_get_recurso(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION f_get_recurso(integer) RETURNS TABLE(recursoid integer, estacionid integer, nombrerecurso character varying)
    LANGUAGE plpgsql
    AS $_$
	BEGIN
	RETURN QUERY
		SELECT *
		FROM recursos
		WHERE recursos.recursoid = $1;
	END
$_$;


ALTER FUNCTION public.f_get_recurso(integer) OWNER TO postgres;

--
-- TOC entry 224 (class 1255 OID 16411)
-- Name: f_get_recursos(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION f_get_recursos() RETURNS TABLE(recursoid integer, estacionid integer, nombrerecurso character varying)
    LANGUAGE plpgsql
    AS $$
	BEGIN
	RETURN QUERY
		SELECT *
		FROM recursos;
	END
$$;


ALTER FUNCTION public.f_get_recursos() OWNER TO postgres;

--
-- TOC entry 225 (class 1255 OID 16412)
-- Name: f_get_recursos(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION f_get_recursos(integer) RETURNS TABLE(recursoid integer, estacionid integer, nombrerecurso character varying)
    LANGUAGE plpgsql
    AS $_$
	BEGIN
	RETURN QUERY
		SELECT recursos.*
		FROM recursos INNER JOIN estaciones ON recursos.estacionid = estaciones.estacionid
		WHERE estaciones.tiporecursoid = $1;
	END
$_$;


ALTER FUNCTION public.f_get_recursos(integer) OWNER TO postgres;

--
-- TOC entry 226 (class 1255 OID 16413)
-- Name: f_get_severity_incident(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION f_get_severity_incident(integer) RETURNS integer
    LANGUAGE plpgsql
    AS $_$
	DECLARE
		severity INTEGER := -1;
	BEGIN
		SELECT 
		60*(EXTRACT(HOUR FROM (NOW()::TIMESTAMP - I.FECHANOTIFICACION))) + (EXTRACT(MINUTE FROM (NOW()::TIMESTAMP - I.FECHANOTIFICACION))) + I.GRAVEDAD
		INTO severity
		FROM HIST_INCIDENCIAS I
		WHERE I.incidenciaid = $1;
		RETURN severity;
	EXCEPTION
		WHEN OTHERS THEN
			RETURN -2;
	END
$_$;


ALTER FUNCTION public.f_get_severity_incident(integer) OWNER TO postgres;

--
-- TOC entry 227 (class 1255 OID 16414)
-- Name: f_get_tipos_incidencia(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION f_get_tipos_incidencia() RETURNS TABLE(tipoincidenciaid integer, nombretipoincidencia character varying)
    LANGUAGE plpgsql
    AS $$
	BEGIN
	RETURN QUERY
		SELECT *
		FROM TIPO_INCIDENCIA;
	END
$$;


ALTER FUNCTION public.f_get_tipos_incidencia() OWNER TO postgres;

--
-- TOC entry 228 (class 1255 OID 16415)
-- Name: f_get_type_resource(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION f_get_type_resource(id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
	DECLARE
		type_id INTEGER := -1;
	BEGIN
		SELECT E.TIPORECURSOID INTO type_id FROM ESTACIONES E
		JOIN RECURSOS R ON R.ESTACIONID = E.ESTACIONID
		WHERE R.RECURSOID = id;
		RETURN type_id;
	EXCEPTION
		WHEN OTHERS THEN
			RETURN -2;
	END
$$;


ALTER FUNCTION public.f_get_type_resource(id integer) OWNER TO postgres;

--
-- TOC entry 229 (class 1255 OID 16416)
-- Name: f_get_type_station(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION f_get_type_station(id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
	DECLARE
		type_id INTEGER := -1;
	BEGIN
		SELECT E.TIPORECURSOID INTO type_id FROM ESTACIONES E
		WHERE E.ESTACIONID = id;
		RETURN type_id;
	EXCEPTION
		WHEN OTHERS THEN
			RETURN -2;
	END
$$;


ALTER FUNCTION public.f_get_type_station(id integer) OWNER TO postgres;

--
-- TOC entry 230 (class 1255 OID 16417)
-- Name: f_get_user_id(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION f_get_user_id(dni character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
	DECLARE
		id INTEGER := -1;
	BEGIN
		SELECT U.USUARIOID INTO id
		FROM USUARIOS U
		WHERE U.DNI = dni;
		RETURN id;
	EXCEPTION
		WHEN OTHERS THEN
			RETURN -2;
	END
$$;


ALTER FUNCTION public.f_get_user_id(dni character varying) OWNER TO postgres;

--
-- TOC entry 231 (class 1255 OID 16418)
-- Name: f_insert_user(character varying, character varying, character varying, character varying, character varying, character varying, character varying, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION f_insert_user(name character varying, ape character varying, dir character varying, tlf character varying, obs character varying, dni character varying, v_user character varying, pass text) RETURNS integer
    LANGUAGE plpgsql
    AS $$
	DECLARE
		cod INTEGER := -1;
	BEGIN
		INSERT INTO USUARIOS (NOMBRE, APELLIDO, DIRECCION, TELEFONO, NOTAS, DNI, USERNAME, PASSWORD)
		VALUES (name, ape, dir, tlf, obs, dni, v_user, pass)
		RETURNING USUARIOID INTO cod;
		RETURN cod;
	EXCEPTION
		WHEN OTHERS THEN
			RETURN -2;
	END
$$;


ALTER FUNCTION public.f_insert_user(name character varying, ape character varying, dir character varying, tlf character varying, obs character varying, dni character varying, v_user character varying, pass text) OWNER TO postgres;

--
-- TOC entry 232 (class 1255 OID 16419)
-- Name: f_nueva_incidencia(integer, numeric, numeric, integer, character varying, text, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION f_nueva_incidencia(integer, numeric, numeric, integer, character varying, text, integer, integer) RETURNS integer
    LANGUAGE plpgsql
    AS $_$
	DECLARE
		ret integer;
	BEGIN
		ret:=-1;
		INSERT INTO hist_incidencias(tipoincidenciaid,ubicacionlat,ubicacionlng,usuarioid,telefono,notas,gravedad,numeroafectados,resolucion)
		VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$8) RETURNING incidenciaid INTO ret;
		RETURN ret;
	EXCEPTION
		WHEN OTHERS THEN
			RETURN -2;
	END
$_$;


ALTER FUNCTION public.f_nueva_incidencia(integer, numeric, numeric, integer, character varying, text, integer, integer) OWNER TO postgres;

--
-- TOC entry 233 (class 1255 OID 16420)
-- Name: f_nuevo_recurso(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION f_nuevo_recurso(integer) RETURNS integer
    LANGUAGE plpgsql
    AS $_$
	DECLARE
		cod INTEGER := -1;
	BEGIN
		INSERT INTO recursos (estacionid,nombrerecurso)
		VALUES ($1,(SELECT nombretiporecurso FROM tipo_recurso WHERE tiporecursoid = f_get_type_station($1)))
		RETURNING recursoid INTO cod;
		RETURN cod;
	EXCEPTION
		WHEN OTHERS THEN
			RETURN -2;
	END
$_$;


ALTER FUNCTION public.f_nuevo_recurso(integer) OWNER TO postgres;

--
-- TOC entry 234 (class 1255 OID 16421)
-- Name: f_persona_recogida(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION f_persona_recogida(integer) RETURNS integer
    LANGUAGE plpgsql
    AS $_$
	DECLARE
		count integer;
		ret integer;
	BEGIN
		count = 0;
		UPDATE hist_incidencias SET
		resolucion = resolucion-1
		WHERE incidenciaid = $1 AND resolucion>0
		RETURNING resolucion INTO count;

		IF count = 0 THEN
			ret = (SELECT * FROM f_fin_incidencia($1));
		END IF;
		
		return count;
	EXCEPTION
		WHEN OTHERS THEN
			RETURN -2;
	END
$_$;


ALTER FUNCTION public.f_persona_recogida(integer) OWNER TO postgres;

--
-- TOC entry 235 (class 1255 OID 16422)
-- Name: f_puntuar_incidencia(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION f_puntuar_incidencia(integer, integer) RETURNS integer
    LANGUAGE plpgsql
    AS $_$
	DECLARE
		count integer;
	BEGIN
		count:=-1;
		IF $2>=0 AND $2<=10 THEN
			UPDATE hist_incidencias SET
			resolucion = $2
			WHERE incidenciaid = $1;
			GET DIAGNOSTICS count = ROW_COUNT;
		END IF;
		return count;
	EXCEPTION
		WHEN OTHERS THEN
			RETURN -2;
	END
$_$;


ALTER FUNCTION public.f_puntuar_incidencia(integer, integer) OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 181 (class 1259 OID 16423)
-- Name: estaciones; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE estaciones (
    estacionid integer NOT NULL,
    tiporecursoid integer NOT NULL,
    nombreestacion character varying(20),
    ubicacionestacionlat numeric(9,6),
    ubicacionestacionlng numeric(9,6)
);


ALTER TABLE estaciones OWNER TO postgres;

--
-- TOC entry 182 (class 1259 OID 16426)
-- Name: estaciones_estacionid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE estaciones_estacionid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE estaciones_estacionid_seq OWNER TO postgres;

--
-- TOC entry 2221 (class 0 OID 0)
-- Dependencies: 182
-- Name: estaciones_estacionid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE estaciones_estacionid_seq OWNED BY estaciones.estacionid;


--
-- TOC entry 183 (class 1259 OID 16428)
-- Name: hist_incidencias; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE hist_incidencias (
    incidenciaid integer NOT NULL,
    tipoincidenciaid integer NOT NULL,
    fechanotificacion timestamp without time zone DEFAULT now(),
    fecharesolucion timestamp without time zone,
    ubicacionlat numeric(9,6),
    ubicacionlng numeric(9,6),
    usuarioid integer DEFAULT 0,
    telefono character varying(9),
    notas text,
    gravedad integer,
    numeroafectados integer,
    resolucion integer
);


ALTER TABLE hist_incidencias OWNER TO postgres;

--
-- TOC entry 184 (class 1259 OID 16436)
-- Name: hist_incidencias_incidenciaid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE hist_incidencias_incidenciaid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE hist_incidencias_incidenciaid_seq OWNER TO postgres;

--
-- TOC entry 2222 (class 0 OID 0)
-- Dependencies: 184
-- Name: hist_incidencias_incidenciaid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE hist_incidencias_incidenciaid_seq OWNED BY hist_incidencias.incidenciaid;


--
-- TOC entry 185 (class 1259 OID 16438)
-- Name: hist_incidencias_recursos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE hist_incidencias_recursos (
    incidenciaid integer NOT NULL,
    recursoid integer NOT NULL,
    ubicacionorigenlat numeric(9,6),
    ubicacionorigenlng numeric(9,6),
    fechasalida timestamp without time zone,
    fechallegada timestamp without time zone
);


ALTER TABLE hist_incidencias_recursos OWNER TO postgres;

--
-- TOC entry 186 (class 1259 OID 16441)
-- Name: hist_ubicacion; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE hist_ubicacion (
    recursoid integer NOT NULL,
    fecha timestamp without time zone DEFAULT now() NOT NULL,
    estado integer,
    ubicacionlat numeric(9,6),
    ubicacionlng numeric(9,6)
);


ALTER TABLE hist_ubicacion OWNER TO postgres;

--
-- TOC entry 187 (class 1259 OID 16445)
-- Name: recursos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE recursos (
    recursoid integer NOT NULL,
    estacionid integer NOT NULL,
    nombrerecurso character varying(20)
);


ALTER TABLE recursos OWNER TO postgres;

--
-- TOC entry 188 (class 1259 OID 16448)
-- Name: recursos_recursoid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE recursos_recursoid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE recursos_recursoid_seq OWNER TO postgres;

--
-- TOC entry 2223 (class 0 OID 0)
-- Dependencies: 188
-- Name: recursos_recursoid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE recursos_recursoid_seq OWNED BY recursos.recursoid;


--
-- TOC entry 189 (class 1259 OID 16450)
-- Name: tipo_incidencia; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE tipo_incidencia (
    tipoincidenciaid integer NOT NULL,
    nombretipoincidencia character varying(20)
);


ALTER TABLE tipo_incidencia OWNER TO postgres;

--
-- TOC entry 190 (class 1259 OID 16453)
-- Name: tipo_incidencia_tipoincidenciaid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE tipo_incidencia_tipoincidenciaid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE tipo_incidencia_tipoincidenciaid_seq OWNER TO postgres;

--
-- TOC entry 2224 (class 0 OID 0)
-- Dependencies: 190
-- Name: tipo_incidencia_tipoincidenciaid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE tipo_incidencia_tipoincidenciaid_seq OWNED BY tipo_incidencia.tipoincidenciaid;


--
-- TOC entry 191 (class 1259 OID 16455)
-- Name: tipo_recurso; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE tipo_recurso (
    tiporecursoid integer NOT NULL,
    nombretiporecurso character varying(20)
);


ALTER TABLE tipo_recurso OWNER TO postgres;

--
-- TOC entry 192 (class 1259 OID 16458)
-- Name: tipo_recurso_tiporecursoid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE tipo_recurso_tiporecursoid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE tipo_recurso_tiporecursoid_seq OWNER TO postgres;

--
-- TOC entry 2225 (class 0 OID 0)
-- Dependencies: 192
-- Name: tipo_recurso_tiporecursoid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE tipo_recurso_tiporecursoid_seq OWNED BY tipo_recurso.tiporecursoid;


--
-- TOC entry 193 (class 1259 OID 16460)
-- Name: usuarios; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE usuarios (
    usuarioid integer NOT NULL,
    privilegios integer DEFAULT 0,
    nombre character varying(30),
    apellido character varying(30),
    direccion character varying(80),
    telefono character varying(9),
    dni character varying(9),
    notas text,
    username character varying(20),
    password text
);


ALTER TABLE usuarios OWNER TO postgres;

--
-- TOC entry 194 (class 1259 OID 16467)
-- Name: usuarios_usuarioid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE usuarios_usuarioid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE usuarios_usuarioid_seq OWNER TO postgres;

--
-- TOC entry 2226 (class 0 OID 0)
-- Dependencies: 194
-- Name: usuarios_usuarioid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE usuarios_usuarioid_seq OWNED BY usuarios.usuarioid;


--
-- TOC entry 2050 (class 2604 OID 16469)
-- Name: estacionid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY estaciones ALTER COLUMN estacionid SET DEFAULT nextval('estaciones_estacionid_seq'::regclass);


--
-- TOC entry 2053 (class 2604 OID 16470)
-- Name: incidenciaid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY hist_incidencias ALTER COLUMN incidenciaid SET DEFAULT nextval('hist_incidencias_incidenciaid_seq'::regclass);


--
-- TOC entry 2055 (class 2604 OID 16471)
-- Name: recursoid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY recursos ALTER COLUMN recursoid SET DEFAULT nextval('recursos_recursoid_seq'::regclass);


--
-- TOC entry 2056 (class 2604 OID 16472)
-- Name: tipoincidenciaid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY tipo_incidencia ALTER COLUMN tipoincidenciaid SET DEFAULT nextval('tipo_incidencia_tipoincidenciaid_seq'::regclass);


--
-- TOC entry 2057 (class 2604 OID 16473)
-- Name: tiporecursoid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY tipo_recurso ALTER COLUMN tiporecursoid SET DEFAULT nextval('tipo_recurso_tiporecursoid_seq'::regclass);


--
-- TOC entry 2059 (class 2604 OID 16474)
-- Name: usuarioid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY usuarios ALTER COLUMN usuarioid SET DEFAULT nextval('usuarios_usuarioid_seq'::regclass);


--
-- TOC entry 2199 (class 0 OID 16423)
-- Dependencies: 181
-- Data for Name: estaciones; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO estaciones (estacionid, tiporecursoid, nombreestacion, ubicacionestacionlat, ubicacionestacionlng) VALUES (5, 1, 'AMBULANCIAS ARRASATE', 43.063081, -2.505862);
INSERT INTO estaciones (estacionid, tiporecursoid, nombreestacion, ubicacionestacionlat, ubicacionestacionlng) VALUES (6, 2, 'POLICIAS ARRASATE', 43.072096, -2.473052);


--
-- TOC entry 2227 (class 0 OID 0)
-- Dependencies: 182
-- Name: estaciones_estacionid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('estaciones_estacionid_seq', 6, true);


--
-- TOC entry 2201 (class 0 OID 16428)
-- Dependencies: 183
-- Data for Name: hist_incidencias; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO hist_incidencias (incidenciaid, tipoincidenciaid, fechanotificacion, fecharesolucion, ubicacionlat, ubicacionlng, usuarioid, telefono, notas, gravedad, numeroafectados, resolucion) VALUES (85, 1, '2016-03-03 17:06:55.092716', '2016-03-03 17:09:41.070209', 43.275966, -1.985596, 10, '637937045', '', 4, 1, -1);
INSERT INTO hist_incidencias (incidenciaid, tipoincidenciaid, fechanotificacion, fecharesolucion, ubicacionlat, ubicacionlng, usuarioid, telefono, notas, gravedad, numeroafectados, resolucion) VALUES (86, 1, '2016-03-03 17:08:52.790448', '2016-03-03 17:10:40.229593', 43.275859, -1.986454, 0, '634466831', '', 4, 1, -1);
INSERT INTO hist_incidencias (incidenciaid, tipoincidenciaid, fechanotificacion, fecharesolucion, ubicacionlat, ubicacionlng, usuarioid, telefono, notas, gravedad, numeroafectados, resolucion) VALUES (87, 1, '2016-03-03 17:14:10.429615', NULL, 43.278950, -1.984636, 10, '637937045', '', 4, 1, 1);


--
-- TOC entry 2228 (class 0 OID 0)
-- Dependencies: 184
-- Name: hist_incidencias_incidenciaid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('hist_incidencias_incidenciaid_seq', 87, true);


--
-- TOC entry 2203 (class 0 OID 16438)
-- Dependencies: 185
-- Data for Name: hist_incidencias_recursos; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 2204 (class 0 OID 16441)
-- Dependencies: 186
-- Data for Name: hist_ubicacion; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 16:55:14.893667', 0, 43.061967, -2.506544);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 16:55:24.891239', 0, 43.061967, -2.506544);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 16:55:34.891811', 0, 43.061967, -2.506544);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 16:55:44.893383', 0, 43.061967, -2.506544);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 16:55:54.892955', 0, 43.061967, -2.506544);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 16:56:04.901527', 0, 43.061967, -2.506544);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 16:56:14.897099', 0, 43.061967, -2.506544);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 16:56:24.903671', 0, 43.061967, -2.506544);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 16:56:34.896243', 0, 43.061967, -2.506544);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 16:56:44.902815', 0, 43.061967, -2.506544);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 16:56:54.904387', 0, 43.061967, -2.506544);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 16:57:04.895959', 0, 43.061967, -2.506544);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 16:57:14.903531', 0, 43.061967, -2.506544);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 16:57:24.901103', 0, 43.061967, -2.506544);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 16:57:34.898675', 0, 43.061967, -2.506544);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 16:57:44.903247', 0, 43.061967, -2.506544);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 16:57:54.899819', 0, 43.061967, -2.506544);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 16:58:04.900391', 0, 43.061967, -2.506544);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 16:58:14.899963', 0, 43.061967, -2.506544);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 16:58:24.901535', 0, 43.061967, -2.506544);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 16:58:34.900107', 0, 43.061967, -2.506544);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 16:58:44.904679', 0, 43.061967, -2.506544);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 16:58:54.901251', 0, 43.061967, -2.506544);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 16:59:04.900823', 0, 43.061967, -2.506544);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 16:59:14.903395', 0, 43.061967, -2.506544);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 16:59:24.902967', 0, 43.061967, -2.506544);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 16:59:34.900538', 0, 43.061967, -2.506544);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 16:59:44.90111', 0, 43.061967, -2.506544);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 16:59:54.903683', 0, 43.061967, -2.506544);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 17:00:04.901254', 0, 43.061967, -2.506544);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 17:00:14.899826', 0, 43.061967, -2.506544);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 17:00:24.900398', 0, 43.061967, -2.506544);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 17:00:34.89797', 0, 43.061967, -2.506544);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 17:00:44.904542', 0, 43.061967, -2.506544);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 17:00:54.903114', 0, 43.061967, -2.506544);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 17:01:04.903686', 0, 43.061967, -2.506544);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 17:01:14.906258', 0, 43.061967, -2.506544);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 17:01:24.90183', 0, 43.061967, -2.506544);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 17:01:34.904402', 0, 43.061967, -2.506544);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 17:01:44.904974', 0, 43.061967, -2.506544);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 17:01:54.904546', 0, 43.061967, -2.506544);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 17:02:04.904118', 0, 43.061967, -2.506544);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 17:02:14.90469', 0, 43.061967, -2.506544);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 17:02:24.904262', 0, 43.061967, -2.506544);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 17:02:34.945836', 0, 43.061967, -2.506544);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 17:02:44.906406', 0, 43.061967, -2.506544);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 17:02:54.904978', 0, 43.061967, -2.506544);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 17:03:04.90655', 0, 43.061967, -2.506544);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 17:03:14.906122', 0, 43.061967, -2.506544);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 17:03:24.905694', 0, 43.061967, -2.506544);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 17:03:34.907266', 0, 43.061967, -2.506544);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 17:03:44.905838', 0, 43.061967, -2.506544);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 17:03:54.90641', 0, 43.061967, -2.506544);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 17:04:04.908982', 0, 43.061967, -2.506544);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 17:04:14.908554', 0, 43.061967, -2.506544);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 17:04:24.910126', 0, 43.061967, -2.506544);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 17:04:34.909698', 0, 43.061967, -2.506544);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 17:04:44.91427', 0, 43.061967, -2.506544);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 17:04:54.909842', 0, 43.061967, -2.506544);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 17:05:04.922415', 0, 43.061967, -2.506544);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 17:05:14.908986', 0, 43.061967, -2.506544);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 17:05:24.910558', 0, 43.061967, -2.506544);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 17:05:34.91213', 0, 43.061967, -2.506544);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 17:05:44.913702', 0, 43.061967, -2.506544);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 17:05:54.913274', 0, 43.061967, -2.506544);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 17:06:04.908846', 0, 43.061967, -2.506544);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 17:06:14.910418', 0, 43.061967, -2.506544);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 17:06:24.91199', 0, 43.061967, -2.506544);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 17:06:34.911562', 0, 43.061967, -2.506544);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 17:06:44.911134', 0, 43.061967, -2.506544);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 17:06:54.912706', 0, 43.061967, -2.506544);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 17:07:04.911278', 0, 43.061967, -2.506544);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 17:07:08.560486', 1, 43.061967, -2.506544);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 17:07:14.91685', 1, 43.161409, -2.441822);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 17:07:24.927422', 1, 43.233462, -2.264200);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 17:07:34.914994', 1, 43.282936, -2.066934);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 17:07:37.952167', 0, 43.282936, -2.066934);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 17:07:38.00017', 2, 43.282936, -2.066934);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 17:07:44.951568', 2, 43.271835, -2.195625);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 17:07:54.914138', 2, 43.211735, -2.393065);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 17:08:04.91471', 2, 43.053610, -2.490589);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 17:08:05.999772', 0, 43.053610, -2.490589);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 17:08:06.629808', 1, 43.053610, -2.490589);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 17:08:07.828876', 0, 43.053610, -2.490589);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 17:08:07.857878', 2, 43.053610, -2.490589);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 17:08:11.295075', 0, 43.053610, -2.490589);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 17:08:13.628208', 1, 43.053610, -2.490589);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 17:08:14.913281', 1, 43.083132, -2.477993);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 17:08:24.913853', 1, 43.213672, -2.343107);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 17:08:34.920426', 1, 43.263146, -2.145840);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 17:08:37.840593', 0, 43.263146, -2.145840);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 17:08:37.868594', 0, 43.263146, -2.145840);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 17:08:44.912997', 0, 43.280462, -2.076797);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 17:08:54.913569', 0, 43.280462, -2.076797);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 17:09:04.915141', 0, 43.280462, -2.076797);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 17:09:07.981317', 1, 43.280462, -2.076797);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 17:09:12.596581', 2, 43.280462, -2.076797);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 17:09:14.921714', 2, 43.273191, -2.090044);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 17:09:24.917285', 2, 43.241785, -2.294345);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 17:09:34.914857', 2, 43.141303, -2.447322);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 17:09:41.041208', 0, 43.141303, -2.447322);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 17:09:41.735247', 1, 43.141303, -2.447322);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 17:09:44.92643', 1, 43.180712, -2.430874);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 17:09:54.930002', 1, 43.238409, -2.244474);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 17:10:04.922574', 1, 43.287883, -2.047207);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 17:10:07.768736', 2, 43.287883, -2.047207);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 17:10:14.917145', 2, 43.273665, -2.117489);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 17:10:24.916717', 2, 43.227446, -2.314404);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 17:10:34.92729', 2, 43.121832, -2.452245);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 17:10:40.199591', 0, 43.121832, -2.452245);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 17:10:44.917861', 0, 43.061967, -2.506544);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 17:10:54.917433', 0, 43.061967, -2.506544);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 17:11:04.919005', 0, 43.061967, -2.506544);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 17:11:14.927578', 0, 43.061967, -2.506544);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 17:11:24.917149', 0, 43.061967, -2.506544);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 17:11:34.919721', 0, 43.061967, -2.506544);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 17:11:44.919293', 0, 43.061967, -2.506544);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 17:11:54.922865', 0, 43.061967, -2.506544);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 17:12:04.921437', 0, 43.061967, -2.506544);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 17:12:15.45904', 0, 43.061967, -2.506544);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 17:12:24.940582', 0, 43.061967, -2.506544);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 17:12:34.920153', 0, 43.061967, -2.506544);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 17:12:44.920725', 0, 43.061967, -2.506544);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 17:12:54.919297', 0, 43.061967, -2.506544);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 17:13:04.919869', 0, 43.061967, -2.506544);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 17:13:14.964443', 0, 43.061967, -2.506544);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 17:13:24.922013', 0, 43.061967, -2.506544);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 17:13:34.920585', 0, 43.061967, -2.506544);
INSERT INTO hist_ubicacion (recursoid, fecha, estado, ubicacionlat, ubicacionlng) VALUES (1, '2016-03-03 17:13:45.711201', 0, 43.061967, -2.506544);


--
-- TOC entry 2205 (class 0 OID 16445)
-- Dependencies: 187
-- Data for Name: recursos; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO recursos (recursoid, estacionid, nombrerecurso) VALUES (1, 5, 'Ambulancia');
INSERT INTO recursos (recursoid, estacionid, nombrerecurso) VALUES (2, 5, 'Ambulancia');
INSERT INTO recursos (recursoid, estacionid, nombrerecurso) VALUES (3, 6, 'Policia');
INSERT INTO recursos (recursoid, estacionid, nombrerecurso) VALUES (4, 6, 'Policia');
INSERT INTO recursos (recursoid, estacionid, nombrerecurso) VALUES (5, 6, 'Policia');
INSERT INTO recursos (recursoid, estacionid, nombrerecurso) VALUES (6, 6, 'Policia');
INSERT INTO recursos (recursoid, estacionid, nombrerecurso) VALUES (7, 5, 'Ambulancia');


--
-- TOC entry 2229 (class 0 OID 0)
-- Dependencies: 188
-- Name: recursos_recursoid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('recursos_recursoid_seq', 7, true);


--
-- TOC entry 2207 (class 0 OID 16450)
-- Dependencies: 189
-- Data for Name: tipo_incidencia; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO tipo_incidencia (tipoincidenciaid, nombretipoincidencia) VALUES (1, 'Ambulancia');
INSERT INTO tipo_incidencia (tipoincidenciaid, nombretipoincidencia) VALUES (2, 'Policia');
INSERT INTO tipo_incidencia (tipoincidenciaid, nombretipoincidencia) VALUES (3, 'Bomberos');


--
-- TOC entry 2230 (class 0 OID 0)
-- Dependencies: 190
-- Name: tipo_incidencia_tipoincidenciaid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('tipo_incidencia_tipoincidenciaid_seq', 1, true);


--
-- TOC entry 2209 (class 0 OID 16455)
-- Dependencies: 191
-- Data for Name: tipo_recurso; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO tipo_recurso (tiporecursoid, nombretiporecurso) VALUES (1, 'Ambulancia');
INSERT INTO tipo_recurso (tiporecursoid, nombretiporecurso) VALUES (2, 'Policia');
INSERT INTO tipo_recurso (tiporecursoid, nombretiporecurso) VALUES (3, 'Bomberos');


--
-- TOC entry 2231 (class 0 OID 0)
-- Dependencies: 192
-- Name: tipo_recurso_tiporecursoid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('tipo_recurso_tiporecursoid_seq', 1, true);


--
-- TOC entry 2211 (class 0 OID 16460)
-- Dependencies: 193
-- Data for Name: usuarios; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO usuarios (usuarioid, privilegios, nombre, apellido, direccion, telefono, dni, notas, username, password) VALUES (1, 1, 'Jon', 'Ayerdi', 'Pontxi Zabala 7 2ºB', '688683155', '12345678Z', 'Alergico a los cacahuetes.', 'jayer', '1234');
INSERT INTO usuarios (usuarioid, privilegios, nombre, apellido, direccion, telefono, dni, notas, username, password) VALUES (2, 1, 'Urko', 'Pineda', 'Durango', '946555698', '98765432A', 'Feo.', 'turkish', '4321');
INSERT INTO usuarios (usuarioid, privilegios, nombre, apellido, direccion, telefono, dni, notas, username, password) VALUES (3, 1, 'Gorka', 'Olalde', 'Monte', '123456789', '98765432P', 'âº', 'olaldiko', '1324');
INSERT INTO usuarios (usuarioid, privilegios, nombre, apellido, direccion, telefono, dni, notas, username, password) VALUES (4, 0, 'a', 'a', 'a', '123456789', '12345678A', 'a', 'a', 'a');
INSERT INTO usuarios (usuarioid, privilegios, nombre, apellido, direccion, telefono, dni, notas, username, password) VALUES (5, 0, 'b', 'b', 'b', '123456789', '12345678B', 'b', 'b', 'b');
INSERT INTO usuarios (usuarioid, privilegios, nombre, apellido, direccion, telefono, dni, notas, username, password) VALUES (0, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'INVITADO', NULL);
INSERT INTO usuarios (usuarioid, privilegios, nombre, apellido, direccion, telefono, dni, notas, username, password) VALUES (9, 0, 'Urko', 'Pineda', 'C/ Blablabla', '634466831', '72851274Q', '', 'urkopineda', '1234');
INSERT INTO usuarios (usuarioid, privilegios, nombre, apellido, direccion, telefono, dni, notas, username, password) VALUES (10, 0, 'Gorka', 'Olalde', 'Salsamendi nÂº22', '637937045', '72826088S', '', 'gorka', '123456');


--
-- TOC entry 2232 (class 0 OID 0)
-- Dependencies: 194
-- Name: usuarios_usuarioid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('usuarios_usuarioid_seq', 10, true);


--
-- TOC entry 2061 (class 2606 OID 16476)
-- Name: estaciones_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY estaciones
    ADD CONSTRAINT estaciones_pk PRIMARY KEY (estacionid);


--
-- TOC entry 2063 (class 2606 OID 16478)
-- Name: hist_incidencias_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY hist_incidencias
    ADD CONSTRAINT hist_incidencias_pk PRIMARY KEY (incidenciaid);


--
-- TOC entry 2065 (class 2606 OID 16480)
-- Name: hist_incidencias_recursos_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY hist_incidencias_recursos
    ADD CONSTRAINT hist_incidencias_recursos_pk PRIMARY KEY (incidenciaid, recursoid);


--
-- TOC entry 2067 (class 2606 OID 16482)
-- Name: hist_ubicacion_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY hist_ubicacion
    ADD CONSTRAINT hist_ubicacion_pk PRIMARY KEY (recursoid, fecha);


--
-- TOC entry 2069 (class 2606 OID 16484)
-- Name: recursos_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY recursos
    ADD CONSTRAINT recursos_pk PRIMARY KEY (recursoid);


--
-- TOC entry 2071 (class 2606 OID 16486)
-- Name: tipo_incidencia_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY tipo_incidencia
    ADD CONSTRAINT tipo_incidencia_pk PRIMARY KEY (tipoincidenciaid);


--
-- TOC entry 2073 (class 2606 OID 16488)
-- Name: tipo_recurso_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY tipo_recurso
    ADD CONSTRAINT tipo_recurso_pk PRIMARY KEY (tiporecursoid);


--
-- TOC entry 2075 (class 2606 OID 16490)
-- Name: usuarios_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY usuarios
    ADD CONSTRAINT usuarios_pk PRIMARY KEY (usuarioid);


--
-- TOC entry 2077 (class 2606 OID 16492)
-- Name: usuarios_username_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY usuarios
    ADD CONSTRAINT usuarios_username_key UNIQUE (username);


--
-- TOC entry 2078 (class 2606 OID 16493)
-- Name: estaciones_tipo_recurso_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY estaciones
    ADD CONSTRAINT estaciones_tipo_recurso_fk FOREIGN KEY (tiporecursoid) REFERENCES tipo_recurso(tiporecursoid);


--
-- TOC entry 2081 (class 2606 OID 16498)
-- Name: hist_incidencias_recursos_hist_incidencias_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY hist_incidencias_recursos
    ADD CONSTRAINT hist_incidencias_recursos_hist_incidencias_fk FOREIGN KEY (incidenciaid) REFERENCES hist_incidencias(incidenciaid);


--
-- TOC entry 2082 (class 2606 OID 16503)
-- Name: hist_incidencias_recursos_recursos_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY hist_incidencias_recursos
    ADD CONSTRAINT hist_incidencias_recursos_recursos_fk FOREIGN KEY (recursoid) REFERENCES recursos(recursoid);


--
-- TOC entry 2079 (class 2606 OID 16508)
-- Name: hist_incidencias_tipo_incidencia_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY hist_incidencias
    ADD CONSTRAINT hist_incidencias_tipo_incidencia_fk FOREIGN KEY (tipoincidenciaid) REFERENCES tipo_incidencia(tipoincidenciaid);


--
-- TOC entry 2080 (class 2606 OID 16513)
-- Name: hist_incidencias_usuarios_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY hist_incidencias
    ADD CONSTRAINT hist_incidencias_usuarios_fk FOREIGN KEY (usuarioid) REFERENCES usuarios(usuarioid);


--
-- TOC entry 2083 (class 2606 OID 16518)
-- Name: hist_ubicacion_recursos_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY hist_ubicacion
    ADD CONSTRAINT hist_ubicacion_recursos_fk FOREIGN KEY (recursoid) REFERENCES recursos(recursoid);


--
-- TOC entry 2084 (class 2606 OID 16523)
-- Name: recursos_estaciones_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY recursos
    ADD CONSTRAINT recursos_estaciones_fk FOREIGN KEY (estacionid) REFERENCES estaciones(estacionid);


--
-- TOC entry 2219 (class 0 OID 0)
-- Dependencies: 7
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


-- Completed on 2016-05-01 19:07:35

--
-- PostgreSQL database dump complete
--


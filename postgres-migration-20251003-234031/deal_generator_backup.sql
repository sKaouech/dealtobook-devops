--
-- PostgreSQL database dump
--

\restrict 3oiR2X940MpcVdnGP9XxSLsrCDTLNA5pBQdkPpU6sTsUFTJaZhe5c8k2cLt4j7y

-- Dumped from database version 14.18
-- Dumped by pg_dump version 14.19 (Homebrew)

-- Started on 2025-10-03 23:40:41 CEST

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

ALTER TABLE IF EXISTS ONLY public.request_extra_services DROP CONSTRAINT IF EXISTS fkpx42p8k7pr6rmom4w3ui9r6ci;
ALTER TABLE IF EXISTS ONLY public.room_type_style DROP CONSTRAINT IF EXISTS fkm3mtunep984456hb3aa9eqpsr;
ALTER TABLE IF EXISTS ONLY public.sub_request_client DROP CONSTRAINT IF EXISTS fki3w7t8ohdy8pf8lydrxbii7lw;
ALTER TABLE IF EXISTS ONLY public.response_facility_tier DROP CONSTRAINT IF EXISTS fkgki74vpv8gjeb4uwsttaru9dx;
ALTER TABLE IF EXISTS ONLY public.response_tour_service DROP CONSTRAINT IF EXISTS fkatirfj3fkgp7n3f97127udmhw;
ALTER TABLE IF EXISTS ONLY public.request_facility DROP CONSTRAINT IF EXISTS fk3ijji0b40oxirt3dd4dafcoeo;
ALTER TABLE IF EXISTS ONLY public.request_client_tour_service DROP CONSTRAINT IF EXISTS fk36jfaqhtvmpynye3ffslvyk0d;
ALTER TABLE IF EXISTS ONLY public.jhi_persistent_audit_evt_data DROP CONSTRAINT IF EXISTS fk2ehnyx2si4tjd2nt4q7y40v8m;
ALTER TABLE IF EXISTS ONLY public.request_client DROP CONSTRAINT IF EXISTS uk_16eid32es3hrr70okdobcbjlm;
ALTER TABLE IF EXISTS ONLY public.sub_request_client DROP CONSTRAINT IF EXISTS sub_request_client_pkey;
ALTER TABLE IF EXISTS ONLY public.room_type_style DROP CONSTRAINT IF EXISTS room_type_style_pkey;
ALTER TABLE IF EXISTS ONLY public.response_tour_service DROP CONSTRAINT IF EXISTS response_tour_service_pkey;
ALTER TABLE IF EXISTS ONLY public.response_facility_tier DROP CONSTRAINT IF EXISTS response_facility_tier_pkey;
ALTER TABLE IF EXISTS ONLY public.request_notif DROP CONSTRAINT IF EXISTS request_notif_pkey;
ALTER TABLE IF EXISTS ONLY public.request_client_tour_service DROP CONSTRAINT IF EXISTS request_client_tour_service_pkey;
ALTER TABLE IF EXISTS ONLY public.request_client DROP CONSTRAINT IF EXISTS request_client_pkey;
ALTER TABLE IF EXISTS ONLY public.margin_of_profit_setting DROP CONSTRAINT IF EXISTS margin_of_profit_setting_pkey;
ALTER TABLE IF EXISTS ONLY public.marge_of_profit DROP CONSTRAINT IF EXISTS marge_of_profit_pkey;
ALTER TABLE IF EXISTS ONLY public.jhi_persistent_audit_evt_data DROP CONSTRAINT IF EXISTS jhi_persistent_audit_evt_data_pkey;
ALTER TABLE IF EXISTS ONLY public.jhi_persistent_audit_event DROP CONSTRAINT IF EXISTS jhi_persistent_audit_event_pkey;
DROP TABLE IF EXISTS public.sub_request_client;
DROP SEQUENCE IF EXISTS public.sequence_generator;
DROP TABLE IF EXISTS public.room_type_style;
DROP TABLE IF EXISTS public.response_tour_service;
DROP TABLE IF EXISTS public.response_facility_tier;
DROP TABLE IF EXISTS public.request_notif;
DROP TABLE IF EXISTS public.request_facility;
DROP TABLE IF EXISTS public.request_extra_services;
DROP TABLE IF EXISTS public.request_client_tour_service;
DROP TABLE IF EXISTS public.request_client;
DROP TABLE IF EXISTS public.margin_of_profit_setting;
DROP TABLE IF EXISTS public.marge_of_profit;
DROP TABLE IF EXISTS public.jhi_persistent_audit_evt_data;
DROP TABLE IF EXISTS public.jhi_persistent_audit_event;
SET default_table_access_method = heap;

--
-- TOC entry 209 (class 1259 OID 29222)
-- Name: jhi_persistent_audit_event; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.jhi_persistent_audit_event (
    event_id bigint NOT NULL,
    event_date timestamp without time zone,
    event_type character varying(255),
    principal character varying(255) NOT NULL
);


--
-- TOC entry 210 (class 1259 OID 29229)
-- Name: jhi_persistent_audit_evt_data; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.jhi_persistent_audit_evt_data (
    event_id bigint NOT NULL,
    value character varying(255),
    name character varying(255) NOT NULL
);


--
-- TOC entry 211 (class 1259 OID 29236)
-- Name: marge_of_profit; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.marge_of_profit (
    id bigint NOT NULL,
    created_by character varying(50) NOT NULL,
    created_date timestamp without time zone,
    last_modified_by character varying(50),
    last_modified_date timestamp without time zone,
    begin_period date NOT NULL,
    end_period date NOT NULL,
    marge_mode character varying(255) NOT NULL,
    public_id character varying(255) NOT NULL,
    marge_value double precision NOT NULL,
    priority integer NOT NULL,
    service_public_id character varying(255) NOT NULL,
    tier_public_id character varying(255) NOT NULL
);


--
-- TOC entry 212 (class 1259 OID 29243)
-- Name: margin_of_profit_setting; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.margin_of_profit_setting (
    id bigint NOT NULL,
    created_by character varying(50) NOT NULL,
    created_date timestamp without time zone,
    last_modified_by character varying(50),
    last_modified_date timestamp without time zone,
    all_country boolean,
    country character varying(255),
    country_public_id character varying(255),
    marge_mode character varying(255) NOT NULL,
    marge_value double precision NOT NULL,
    public_id character varying(255) NOT NULL,
    service_type character varying(255) NOT NULL,
    year_date integer NOT NULL
);


--
-- TOC entry 213 (class 1259 OID 29250)
-- Name: request_client; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.request_client (
    req_id bigint NOT NULL,
    created_by character varying(50) NOT NULL,
    created_date timestamp without time zone,
    last_modified_by character varying(50),
    last_modified_date timestamp without time zone,
    adult_nbr integer NOT NULL,
    alert boolean,
    base_url character varying(255),
    budget double precision,
    child_age character varying(255),
    child_nbr integer,
    close boolean,
    comment character varying(255),
    cron integer,
    currency character varying(255),
    email character varying(255) NOT NULL,
    expire boolean,
    first_trait boolean,
    req_from date NOT NULL,
    full_name character varying(255),
    phone character varying(255),
    phone_code character varying(255),
    public_id character varying(255),
    room_nbr integer NOT NULL,
    second_trait boolean,
    tier_public_id character varying(255),
    req_to date NOT NULL,
    user_public_id character varying(255),
    client_email character varying(255),
    client_first_name character varying(255),
    client_last_name character varying(255),
    client_phone character varying(255),
    client_phone_code character varying(255),
    from_deal_user boolean,
    day_nbr integer,
    to_deal_provider boolean
);


--
-- TOC entry 214 (class 1259 OID 29257)
-- Name: request_client_tour_service; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.request_client_tour_service (
    req_id bigint NOT NULL,
    service_public_id character varying(255) NOT NULL,
    sub_req_id bigint NOT NULL,
    tier_public_id character varying(255) NOT NULL,
    created_by character varying(50) NOT NULL,
    created_date timestamp without time zone,
    last_modified_by character varying(50),
    last_modified_date timestamp without time zone,
    close boolean,
    email character varying(255),
    req_public_id character varying(255),
    sub_req_public_id character varying(255),
    tier_code character varying(255),
    confirmed boolean,
    country_public_id character varying(255),
    response boolean,
    service_type character varying(255),
    adult_nbr integer,
    bb_age integer,
    bb_nbr integer,
    child_age integer,
    child_nbr integer
);


--
-- TOC entry 216 (class 1259 OID 29271)
-- Name: request_extra_services; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.request_extra_services (
    req_id bigint NOT NULL,
    service_type character varying(255)
);


--
-- TOC entry 217 (class 1259 OID 29274)
-- Name: request_facility; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.request_facility (
    req_id bigint NOT NULL,
    facility character varying(255)
);


--
-- TOC entry 215 (class 1259 OID 29264)
-- Name: request_notif; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.request_notif (
    id bigint NOT NULL,
    created_by character varying(50) NOT NULL,
    created_date timestamp without time zone,
    last_modified_by character varying(50),
    last_modified_date timestamp without time zone,
    active boolean,
    country_name character varying(255),
    country_id character varying(255),
    email character varying(255),
    public_id character varying(255) NOT NULL,
    notif_type character varying(255) NOT NULL,
    time_notif double precision NOT NULL
);


--
-- TOC entry 218 (class 1259 OID 29277)
-- Name: response_facility_tier; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.response_facility_tier (
    id bigint NOT NULL,
    req_public_id character varying(255) NOT NULL,
    tier_public_id character varying(255) NOT NULL,
    created_by character varying(50) NOT NULL,
    created_date timestamp without time zone,
    last_modified_by character varying(50),
    last_modified_date timestamp without time zone,
    facility character varying(255),
    tier_name character varying(255)
);


--
-- TOC entry 219 (class 1259 OID 29284)
-- Name: response_tour_service; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.response_tour_service (
    id bigint NOT NULL,
    req_id bigint NOT NULL,
    service_public_id character varying(255) NOT NULL,
    sub_req_id bigint NOT NULL,
    tier_public_id character varying(255) NOT NULL,
    created_by character varying(50) NOT NULL,
    created_date timestamp without time zone,
    last_modified_by character varying(50),
    last_modified_date timestamp without time zone,
    arrangement character varying(255),
    close boolean,
    expire_offer boolean,
    first_price double precision,
    max_adult integer,
    max_child integer,
    new_marge double precision,
    normal_occup integer,
    pre_choose boolean,
    request_create_date timestamp without time zone,
    req_public_id character varying(255),
    room_nbr integer,
    room_style character varying(255),
    room_type character varying(255),
    room_type_style_id character varying(255),
    second_price double precision,
    sub_req_public_id character varying(255),
    tier_code character varying(255),
    tier_name character varying(255),
    total_price double precision,
    validate_choose boolean,
    release_date integer,
    confirmed boolean
);


--
-- TOC entry 220 (class 1259 OID 29291)
-- Name: room_type_style; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.room_type_style (
    id bigint NOT NULL,
    req_id bigint NOT NULL,
    sub_req_id bigint NOT NULL,
    created_by character varying(50) NOT NULL,
    created_date timestamp without time zone,
    last_modified_by character varying(50),
    last_modified_date timestamp without time zone,
    max_adult integer,
    max_child integer,
    normal_occup integer,
    public_id character varying(255),
    req_public_id character varying(255),
    room_style character varying(255),
    room_style_id character varying(255),
    room_type character varying(255),
    room_type_id character varying(255),
    sub_req_public_id character varying(255)
);


--
-- TOC entry 222 (class 1259 OID 29307)
-- Name: sequence_generator; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sequence_generator
    START WITH 1
    INCREMENT BY 50
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 221 (class 1259 OID 29298)
-- Name: sub_request_client; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sub_request_client (
    req_id bigint NOT NULL,
    sub_req_id bigint NOT NULL,
    created_by character varying(50) NOT NULL,
    created_date timestamp without time zone,
    last_modified_by character varying(50),
    last_modified_date timestamp without time zone,
    alert boolean,
    arrangement character varying(255),
    base_url character varying(255),
    city character varying(255) NOT NULL,
    city_id character varying(255),
    star character varying(255) NOT NULL,
    close boolean,
    country character varying(255) NOT NULL,
    country_code character varying(255),
    country_id character varying(255),
    first_trait boolean,
    public_id character varying(255),
    req_public_id character varying(255),
    second_trait boolean,
    serv_type character varying(255) NOT NULL,
    zone character varying(255),
    zone_id character varying(255),
    to_deal_provider boolean
);


--
-- TOC entry 3993 (class 0 OID 29222)
-- Dependencies: 209
-- Data for Name: jhi_persistent_audit_event; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.jhi_persistent_audit_event (event_id, event_date, event_type, principal) FROM stdin;
\.


--
-- TOC entry 3994 (class 0 OID 29229)
-- Dependencies: 210
-- Data for Name: jhi_persistent_audit_evt_data; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.jhi_persistent_audit_evt_data (event_id, value, name) FROM stdin;
\.


--
-- TOC entry 3995 (class 0 OID 29236)
-- Dependencies: 211
-- Data for Name: marge_of_profit; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.marge_of_profit (id, created_by, created_date, last_modified_by, last_modified_date, begin_period, end_period, marge_mode, public_id, marge_value, priority, service_public_id, tier_public_id) FROM stdin;
52	marblearch@gmail.com	2023-05-16 13:58:51.404628	marblearch@gmail.com	2023-05-16 13:58:51.404628	2023-05-16	2023-12-31	percent	e10147eb-e9a9-4362-a18f-735999810f1e	8	0	6542d646-2baa-459d-b18a-9f80d5a8d1cc	daf98a2e-bce5-42d6-bf90-18cb87ee0f12
53	marblearch@gmail.com	2023-05-16 13:59:54.742874	marblearch@gmail.com	2023-05-16 13:59:54.742874	2024-01-01	2024-12-31	euro	d14cf431-2263-4164-af31-9e6179f2ee8d	18	1	6542d646-2baa-459d-b18a-9f80d5a8d1cc	daf98a2e-bce5-42d6-bf90-18cb87ee0f12
54	marblearch@gmail.com	2023-05-16 14:06:25.711389	marblearch@gmail.com	2023-05-16 14:06:25.711389	2025-01-01	2025-12-31	euro	c8dd6e21-6751-497c-ba04-d5565bf31a08	20	2	6542d646-2baa-459d-b18a-9f80d5a8d1cc	daf98a2e-bce5-42d6-bf90-18cb87ee0f12
55	service-account-dealsetting	2023-05-16 16:19:55.512545	service-account-dealsetting	2023-05-16 16:19:55.512545	2023-05-16	2023-12-31	euro	0cfe4f17-7dea-49bc-961b-d8f1f9189e41	20	0	813b4ff7-25bd-4140-b0b2-5be8323be0b0	d9cfe3d7-60f0-4cbe-8fed-5cfbd26c2737
56	service-account-dealsetting	2023-05-16 16:19:55.513158	service-account-dealsetting	2023-05-16 16:19:55.513158	2023-05-16	2023-12-31	percent	c1d95f7c-b4bb-4502-9c7c-2e88a19e584b	12	0	813b4ff7-25bd-4140-b0b2-5be8323be0b0	d9cfe3d7-60f0-4cbe-8fed-5cfbd26c2737
57	service-account-dealsetting	2023-05-16 16:19:55.515162	service-account-dealsetting	2023-05-16 16:19:55.515162	2024-01-01	2024-05-15	euro	1bbaa449-e42c-4503-b000-60e504c3d0f5	23	0	813b4ff7-25bd-4140-b0b2-5be8323be0b0	d9cfe3d7-60f0-4cbe-8fed-5cfbd26c2737
58	service-account-dealsetting	2023-05-16 16:19:55.516762	service-account-dealsetting	2023-05-16 16:19:55.516762	2024-01-01	2024-05-15	percent	432af12c-6aa5-4b0c-9cdf-d58947446e46	12	0	813b4ff7-25bd-4140-b0b2-5be8323be0b0	d9cfe3d7-60f0-4cbe-8fed-5cfbd26c2737
59	service-account-dealsetting	2023-05-16 21:26:32.689139	service-account-dealsetting	2023-05-16 21:26:32.689139	2023-05-16	2023-12-31	euro	3b5ddb23-929e-4741-84a6-57f9fcc0c5c4	20	0	c0e29e4a-9f3c-44f6-af4e-48dc015af1ee	e6d563db-7add-4b43-bea9-ab41a940ad53
60	service-account-dealsetting	2023-05-16 21:26:32.689509	service-account-dealsetting	2023-05-16 21:26:32.689509	2023-05-16	2023-12-31	percent	4af3940f-e308-41b0-be92-024bc9ce7897	12	0	c0e29e4a-9f3c-44f6-af4e-48dc015af1ee	e6d563db-7add-4b43-bea9-ab41a940ad53
61	service-account-dealsetting	2023-05-16 21:26:32.689662	service-account-dealsetting	2023-05-16 21:26:32.689662	2024-01-01	2024-05-15	euro	ec5bc130-d2b7-4cc1-a251-918baa33fc40	23	0	c0e29e4a-9f3c-44f6-af4e-48dc015af1ee	e6d563db-7add-4b43-bea9-ab41a940ad53
62	service-account-dealsetting	2023-05-16 21:26:32.689844	service-account-dealsetting	2023-05-16 21:26:32.689844	2024-01-01	2024-05-15	percent	3b62dfda-4677-4851-bd92-30bb7199c05a	12	0	c0e29e4a-9f3c-44f6-af4e-48dc015af1ee	e6d563db-7add-4b43-bea9-ab41a940ad53
66	service-account-dealsetting	2023-05-17 17:31:32.936927	service-account-dealsetting	2023-05-17 17:31:32.936927	2023-05-17	2023-12-31	euro	4eee6706-fa35-4856-ba9f-15e13650a498	15	0	bd56a7b3-599a-4869-a433-ee18e49e118d	e6d563db-7add-4b43-bea9-ab41a940ad53
67	service-account-dealsetting	2023-05-17 17:31:32.937431	service-account-dealsetting	2023-05-17 17:31:32.937431	2023-05-17	2023-12-31	percent	b6404050-2dd0-46ea-a771-db898e2a1540	12	0	bd56a7b3-599a-4869-a433-ee18e49e118d	e6d563db-7add-4b43-bea9-ab41a940ad53
68	service-account-dealsetting	2023-05-17 17:31:32.937629	service-account-dealsetting	2023-05-17 17:31:32.937629	2024-01-01	2024-05-16	euro	6d29d016-2573-45b0-9426-3dcf0ce1e7ad	18	0	bd56a7b3-599a-4869-a433-ee18e49e118d	e6d563db-7add-4b43-bea9-ab41a940ad53
69	service-account-dealsetting	2023-05-17 17:31:32.937796	service-account-dealsetting	2023-05-17 17:31:32.937796	2024-01-01	2024-05-16	percent	7d130597-47b8-44e9-b2ee-3168b9ab5736	12	0	bd56a7b3-599a-4869-a433-ee18e49e118d	e6d563db-7add-4b43-bea9-ab41a940ad53
70	amine@ee.dd	2023-05-17 17:33:28.510469	amine@ee.dd	2023-05-17 17:33:28.510469	2024-12-31	2025-12-30	percent	0bf5e3d0-473b-4755-b729-e4d1149b5507	10	1	bd56a7b3-599a-4869-a433-ee18e49e118d	e6d563db-7add-4b43-bea9-ab41a940ad53
252	service-account-dealsetting	2023-07-07 08:29:39.87738	service-account-dealsetting	2023-07-07 08:29:39.87738	2023-07-07	2023-12-31	percent	954e1fed-1f1e-4022-849c-7364cddeb1fc	20	0	4bb5f4c3-1541-46fc-8487-136afc63ba7e	d11af5a5-49fc-4039-99d0-761b3d29806d
253	service-account-dealsetting	2023-07-07 08:29:39.906962	service-account-dealsetting	2023-07-07 08:29:39.906962	2024-01-01	2024-07-06	percent	75bee847-830d-487a-adb5-0927b5404737	22	0	4bb5f4c3-1541-46fc-8487-136afc63ba7e	d11af5a5-49fc-4039-99d0-761b3d29806d
254	service-account-dealsetting	2023-07-09 09:07:51.98002	service-account-dealsetting	2023-07-09 09:07:51.98002	2023-07-09	2023-12-31	percent	e724ba37-01ed-49b7-8a3f-0b1bee192668	20	0	83a92a82-f77b-4ed8-b50a-07da022e47ed	d1b17b54-5110-4b77-800b-60b02baf5826
255	service-account-dealsetting	2023-07-09 09:07:51.980392	service-account-dealsetting	2023-07-09 09:07:51.980392	2024-01-01	2024-07-08	percent	abb75d25-d5e0-4cee-bd19-ed36d7c07fea	22	0	83a92a82-f77b-4ed8-b50a-07da022e47ed	d1b17b54-5110-4b77-800b-60b02baf5826
256	service-account-dealsetting	2023-07-11 03:41:02.385452	service-account-dealsetting	2023-07-11 03:41:02.385452	2023-07-11	2023-12-31	percent	e167c287-dc2e-4bad-986c-fd28097eee84	20	0	29ecf9c0-febb-436f-9b65-c3e1b494acfb	8f3053ee-bd1d-41e8-bbea-319c68723835
257	service-account-dealsetting	2023-07-11 03:41:02.385765	service-account-dealsetting	2023-07-11 03:41:02.385765	2024-01-01	2024-07-10	percent	81a3cb6a-ee3e-47d6-839a-38733f483ee7	22	0	29ecf9c0-febb-436f-9b65-c3e1b494acfb	8f3053ee-bd1d-41e8-bbea-319c68723835
258	service-account-dealsetting	2023-07-11 12:41:52.684019	service-account-dealsetting	2023-07-11 12:41:52.684019	2023-07-11	2023-12-31	percent	9c636312-5e7c-4e3f-9999-f97d7896a9cf	18	0	350b310d-bd3d-48c3-8ef7-d293900aaa19	009608a0-9ac5-4bad-b798-e88f1546abaa
259	service-account-dealsetting	2023-07-11 12:41:52.684735	service-account-dealsetting	2023-07-11 12:41:52.684735	2024-01-01	2024-07-10	euro	512bb206-27f5-4931-b979-a18090d68bd5	23	0	350b310d-bd3d-48c3-8ef7-d293900aaa19	009608a0-9ac5-4bad-b798-e88f1546abaa
260	service-account-dealsetting	2023-07-12 14:52:41.120032	service-account-dealsetting	2023-07-12 14:52:41.120032	2023-07-12	2023-12-31	percent	5b93732e-bf8d-4e04-accb-7a6c413cd342	20	0	72266178-ae28-498e-a983-c637e1c25eb0	d11af5a5-49fc-4039-99d0-761b3d29806d
261	service-account-dealsetting	2023-07-12 14:52:41.12037	service-account-dealsetting	2023-07-12 14:52:41.12037	2024-01-01	2024-07-11	percent	fee96064-6f23-4c3f-b28c-391c8159e3cd	22	0	72266178-ae28-498e-a983-c637e1c25eb0	d11af5a5-49fc-4039-99d0-761b3d29806d
262	service-account-dealsetting	2023-07-12 15:29:21.679775	service-account-dealsetting	2023-07-12 15:29:21.679775	2023-07-12	2023-12-31	percent	e94fb4f2-5bf3-4f2e-824a-cb7b1a2b14ab	20	0	68ae2401-5b63-43ad-8b73-073d9166126a	dab51000-499c-44d8-83ef-f9ef7fd6a4ba
263	service-account-dealsetting	2023-07-12 15:29:21.680117	service-account-dealsetting	2023-07-12 15:29:21.680117	2024-01-01	2024-07-11	percent	bce70694-c1a7-4c07-b59b-393bd6b1ccff	22	0	68ae2401-5b63-43ad-8b73-073d9166126a	dab51000-499c-44d8-83ef-f9ef7fd6a4ba
264	service-account-dealsetting	2023-07-14 15:48:55.731493	service-account-dealsetting	2023-07-14 15:48:55.731493	2023-07-14	2023-12-31	percent	0e58b905-1cea-4d77-bbb7-c8de195b8bf9	18	0	81e5c573-7b21-4f4d-aaf7-4d64d53921fd	e20887e3-31bf-45f5-9d0a-64c455c10369
265	service-account-dealsetting	2023-07-14 15:48:55.731809	service-account-dealsetting	2023-07-14 15:48:55.731809	2024-01-01	2024-07-13	euro	31d3db75-a267-436f-a06e-168583a062ba	23	0	81e5c573-7b21-4f4d-aaf7-4d64d53921fd	e20887e3-31bf-45f5-9d0a-64c455c10369
266	service-account-dealsetting	2023-07-14 16:34:53.316061	service-account-dealsetting	2023-07-14 16:34:53.316061	2023-07-14	2023-12-31	percent	ebdc5754-7772-4ece-b323-74a41be6bdcd	18	0	04fed501-6a7b-4079-8c81-c0f948cb81cd	75240701-0e40-489b-a625-89b7ebe5073f
267	service-account-dealsetting	2023-07-14 16:34:53.317078	service-account-dealsetting	2023-07-14 16:34:53.317078	2024-01-01	2024-07-13	euro	2eb9ecb6-3dd6-4ad1-a1ed-3d0e1621893b	23	0	04fed501-6a7b-4079-8c81-c0f948cb81cd	75240701-0e40-489b-a625-89b7ebe5073f
268	service-account-dealsetting	2023-07-15 18:09:54.990939	service-account-dealsetting	2023-07-15 18:09:54.990939	2023-07-15	2023-12-31	percent	fb381efe-b589-46a8-a59a-cc0301e43e9f	20	0	c3708a23-4e87-4ca6-9029-1c60078b2054	1baad5af-6de5-4363-a9d9-f9ef1c3906ff
269	service-account-dealsetting	2023-07-15 18:09:54.991231	service-account-dealsetting	2023-07-15 18:09:54.991231	2024-01-01	2024-07-14	percent	ede39d2d-b721-4070-b1a6-c41e0caf6f18	22	0	c3708a23-4e87-4ca6-9029-1c60078b2054	1baad5af-6de5-4363-a9d9-f9ef1c3906ff
302	dealtobook.admin@dealtobook.com	2023-10-06 22:13:20.092479	dealtobook.admin@dealtobook.com	2023-10-06 22:13:20.092479	2024-07-10	2024-12-31	euro	11dfc54f-2170-4f26-874c-887ec8baedfd	20	1	68ae2401-5b63-43ad-8b73-073d9166126a	dab51000-499c-44d8-83ef-f9ef7fd6a4ba
354	service-account-dealsetting	2023-11-06 23:10:33.693798	service-account-dealsetting	2023-11-06 23:10:33.693798	2023-11-06	2023-12-31	percent	46fd85b4-8781-4b2b-93ed-c9049ed57b80	20	0	b2feb005-ec11-4f92-b83e-9a53b4609fa6	5eb82e7d-6be4-4cf8-a01d-71d4aa6a2056
355	service-account-dealsetting	2023-11-06 23:10:33.694344	service-account-dealsetting	2023-11-06 23:10:33.694344	2024-01-01	2024-11-05	percent	e628c60c-f468-48c0-93a6-aed30ec999d1	22	0	b2feb005-ec11-4f92-b83e-9a53b4609fa6	5eb82e7d-6be4-4cf8-a01d-71d4aa6a2056
402	service-account-dealsetting	2023-11-13 23:13:44.092799	service-account-dealsetting	2023-11-13 23:13:44.092799	2023-11-13	2023-12-31	percent	2d23e3dd-b2b1-453b-ae5b-56c524dd30f0	20	0	4cb2f3b0-9bf1-4c9f-b120-ff7cd983e6d1	3d0b5251-476b-4cc8-b740-5740570b9b98
403	service-account-dealsetting	2023-11-13 23:13:44.193872	service-account-dealsetting	2023-11-13 23:13:44.193872	2024-01-01	2024-11-12	percent	1d32e5ad-d32a-424f-9b29-2758bbce6b57	22	0	4cb2f3b0-9bf1-4c9f-b120-ff7cd983e6d1	3d0b5251-476b-4cc8-b740-5740570b9b98
404	service-account-dealsetting	2023-11-15 19:36:12.114775	service-account-dealsetting	2023-11-15 19:36:12.114775	2023-11-15	2023-12-31	percent	a091412b-6dc6-4028-951d-b3533c0c9e6f	20	0	0107961e-220e-4415-aa46-bdbb3b598e0f	3d0b5251-476b-4cc8-b740-5740570b9b98
406	service-account-dealsetting	2023-11-15 19:47:40.692711	service-account-dealsetting	2023-11-15 19:47:40.692711	2023-11-15	2023-12-31	percent	5f6ecd1d-92b2-4815-b563-6efe0fd047d7	20	0	2b4961dc-03fa-4b23-be7f-9f607db0f618	5eb82e7d-6be4-4cf8-a01d-71d4aa6a2056
407	service-account-dealsetting	2023-11-15 19:47:40.693362	service-account-dealsetting	2023-11-15 19:47:40.693362	2024-01-01	2024-11-14	percent	46c90c45-49df-4b7a-8bfd-3ddab2b51333	22	0	2b4961dc-03fa-4b23-be7f-9f607db0f618	5eb82e7d-6be4-4cf8-a01d-71d4aa6a2056
408	service-account-dealsetting	2023-11-16 22:08:49.501051	service-account-dealsetting	2023-11-16 22:08:49.501051	2023-11-16	2023-12-31	percent	066bb1a3-b4e0-404c-b512-ff50058ddfa0	18	0	ee41a12d-725e-4fba-84c1-14edf02b1d65	3d0b5251-476b-4cc8-b740-5740570b9b98
409	service-account-dealsetting	2023-11-16 22:08:49.501478	service-account-dealsetting	2023-11-16 22:08:49.501478	2024-01-01	2024-11-15	euro	fa6c7eac-2453-4446-a0e1-d9adde50e7ba	23	0	ee41a12d-725e-4fba-84c1-14edf02b1d65	3d0b5251-476b-4cc8-b740-5740570b9b98
410	service-account-dealsetting	2023-11-16 22:09:16.318217	service-account-dealsetting	2023-11-16 22:09:16.318217	2023-11-16	2023-12-31	euro	a4f3cfda-e5e3-4cd9-9eb9-d6b45f938e3a	15	0	c8049212-ff0c-4506-9327-1eea42c7131e	3d0b5251-476b-4cc8-b740-5740570b9b98
411	service-account-dealsetting	2023-11-16 22:09:16.318504	service-account-dealsetting	2023-11-16 22:09:16.318504	2024-01-01	2024-11-15	percent	bb6478f6-b94c-4b08-9124-ca758d36cd36	12	0	c8049212-ff0c-4506-9327-1eea42c7131e	3d0b5251-476b-4cc8-b740-5740570b9b98
412	service-account-dealsetting	2023-11-16 22:11:09.368682	service-account-dealsetting	2023-11-16 22:11:09.368682	2023-11-16	2023-12-31	euro	ecc935f7-f1fe-4f1f-937c-baef6cb53d0a	15	0	4d9c7f1f-7cf6-46c1-8edb-73ecc3745c77	3d0b5251-476b-4cc8-b740-5740570b9b98
413	service-account-dealsetting	2023-11-16 22:11:09.368977	service-account-dealsetting	2023-11-16 22:11:09.368977	2024-01-01	2024-11-15	percent	871dfbeb-ac04-4a00-a393-ef63ef267f0f	12	0	4d9c7f1f-7cf6-46c1-8edb-73ecc3745c77	3d0b5251-476b-4cc8-b740-5740570b9b98
414	service-account-dealsetting	2023-11-16 22:12:02.53199	service-account-dealsetting	2023-11-16 22:12:02.53199	2023-11-16	2023-12-31	percent	e5c3106e-ffe0-4054-8e49-cd9194f764b5	20	0	e8df012f-8ea3-4577-af25-8035f8f3efb4	3d0b5251-476b-4cc8-b740-5740570b9b98
415	service-account-dealsetting	2023-11-16 22:12:02.532726	service-account-dealsetting	2023-11-16 22:12:02.532726	2024-01-01	2024-11-15	percent	9f5d849f-b04a-45f7-bea4-ecbfe4a1422f	22	0	e8df012f-8ea3-4577-af25-8035f8f3efb4	3d0b5251-476b-4cc8-b740-5740570b9b98
416	op.manager@thegladtone.co.uk	2023-11-16 23:49:53.318614	op.manager@thegladtone.co.uk	2023-11-16 23:49:53.318614	2024-01-01	2024-12-31	percent	48a659c3-bba7-444c-9662-201ddb1bb46c	25	1	0107961e-220e-4415-aa46-bdbb3b598e0f	3d0b5251-476b-4cc8-b740-5740570b9b98
502	trabelsitasnim2@gmail.com	2024-04-25 22:50:47.390996	trabelsitasnim2@gmail.com	2024-04-25 22:50:47.390996	2024-04-25	2024-12-31	euro	134a8947-e78d-4de8-a1c5-9d848a506e3b	12	0	35aaa3bb-40a0-40d7-b87d-31d2013c0bfa	9f50341a-00bb-4099-93a2-5266f55c0acf
503	service-account-dealsetting	2024-09-25 18:25:05.588973	service-account-dealsetting	2024-09-25 18:25:05.588973	2024-09-25	2024-12-31	euro	26b0fd2b-bdb3-4a6a-9965-3931a15ebd46	23	0	b7e1d8d5-6c6d-4d77-8154-03712f56a849	17d05dc0-4615-4119-8c68-bd9b431a5169
504	service-account-dealsetting	2024-09-25 18:25:05.589418	service-account-dealsetting	2024-09-25 18:25:05.589418	2025-01-01	2025-09-24	euro	e6acd5de-a7ba-407d-90bc-a5cf38ca0e8b	25	0	b7e1d8d5-6c6d-4d77-8154-03712f56a849	17d05dc0-4615-4119-8c68-bd9b431a5169
505	service-account-dealsetting	2024-09-28 22:12:35.813371	service-account-dealsetting	2024-09-28 22:12:35.813371	2024-09-28	2024-12-31	euro	85ad8e18-85fd-4675-9084-b8b6cda722f1	23	0	fd11cad2-b09c-468f-9ea0-460c3e75a806	17d05dc0-4615-4119-8c68-bd9b431a5169
506	service-account-dealsetting	2024-09-28 22:12:35.814111	service-account-dealsetting	2024-09-28 22:12:35.814111	2025-01-01	2025-09-27	euro	b2445317-843a-4ef8-b28a-bd6b4645393c	25	0	fd11cad2-b09c-468f-9ea0-460c3e75a806	17d05dc0-4615-4119-8c68-bd9b431a5169
\.


--
-- TOC entry 3996 (class 0 OID 29243)
-- Dependencies: 212
-- Data for Name: margin_of_profit_setting; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.margin_of_profit_setting (id, created_by, created_date, last_modified_by, last_modified_date, all_country, country, country_public_id, marge_mode, marge_value, public_id, service_type, year_date) FROM stdin;
2	dealtobook.admin@dealtobook.com	2023-05-16 13:35:57.443077	dealtobook.admin@dealtobook.com	2023-05-16 13:35:57.443077	t	\N	\N	euro	15	02b1859e-ab51-435e-9bf8-f59ebdb93aab	VILLA	2023
6	dealtobook.admin@dealtobook.com	2023-05-16 13:37:41.497532	dealtobook.admin@dealtobook.com	2023-05-16 13:37:41.497532	t	\N	\N	percent	12	23342bde-a526-4a8d-8c5e-c25b3fd95fde	VILLA	2024
9	dealtobook.admin@dealtobook.com	2023-05-16 13:38:51.620287	dealtobook.admin@dealtobook.com	2023-05-16 13:38:51.620287	t	\N	\N	euro	23	915d5c23-94d6-42ff-b57b-fb24e7776e2d	HOTEL	2024
10	dealtobook.admin@dealtobook.com	2023-05-16 13:39:12.677738	dealtobook.admin@dealtobook.com	2023-05-16 13:39:12.677738	t	\N	\N	euro	25	cec14db4-83fa-4b1b-a6c3-01d2e07d53c0	HOTEL	2025
105	dealtobook.admin@dealtobook.com	2023-05-31 11:34:52.497766	dealtobook.admin@dealtobook.com	2023-05-31 11:34:52.497766	t	\N	\N	percent	12	25b0fac1-dc66-48d8-9ebc-5aa0f5249fc2	VILLA	2025
11	dealtobook.admin@dealtobook.com	2023-05-16 13:39:38.599861	dealtobook.admin@dealtobook.com	2023-05-31 14:59:02.111352	t	\N	\N	percent	18	ae8504e2-8611-4b3d-9218-9cfe1b71d21d	HOTEL	2023
102	dealtobook.admin@dealtobook.com	2023-05-31 11:05:19.599186	dealtobook.admin@dealtobook.com	2023-05-31 14:59:47.004271	t	\N	\N	euro	30	c94a4ec7-bf94-4e7c-bbc5-d7a715ab7416	TRANSFER	2023
103	dealtobook.admin@dealtobook.com	2023-05-31 11:05:50.101527	dealtobook.admin@dealtobook.com	2023-05-31 15:00:46.305671	t	\N	\N	euro	35	c60bbcb7-0256-4984-be83-ae61305df59e	TRANSFER	2024
104	dealtobook.admin@dealtobook.com	2023-05-31 11:06:18.179359	dealtobook.admin@dealtobook.com	2023-05-31 15:01:41.647248	t	\N	\N	percent	20	3aae6c56-13e4-406a-805c-18cc5729a1e3	TRANSFER	2025
122	dealtobook.admin@dealtobook.com	2023-05-31 15:12:37.675648	dealtobook.admin@dealtobook.com	2023-05-31 15:12:37.675648	t	\N	\N	euro	15	968792b6-2f6c-4b77-a4ff-749445ec834f	COTTAGE	2023
123	dealtobook.admin@dealtobook.com	2023-05-31 15:13:25.580446	dealtobook.admin@dealtobook.com	2023-05-31 15:13:25.580446	t	\N	\N	percent	12	b76c5a13-94a0-4aad-8f3e-faaa1119f953	COTTAGE	2024
124	dealtobook.admin@dealtobook.com	2023-05-31 15:13:55.143471	dealtobook.admin@dealtobook.com	2023-05-31 15:13:55.143471	t	\N	\N	percent	12	0849485a-0409-413b-9363-5080ffba6311	COTTAGE	2025
138	dealtobook.admin@dealtobook.com	2023-05-31 15:32:36.830744	dealtobook.admin@dealtobook.com	2023-05-31 15:32:36.830744	t	\N	\N	percent	20	77752a35-1478-4318-876c-1cc40016d287	APART_HOTEL	2023
143	dealtobook.admin@dealtobook.com	2023-05-31 15:39:24.844843	dealtobook.admin@dealtobook.com	2023-05-31 15:39:24.844843	t	\N	\N	percent	22	20e21895-db0f-45ba-aad0-316a5131b1dc	APART_HOTEL	2024
144	dealtobook.admin@dealtobook.com	2023-05-31 15:39:48.614399	dealtobook.admin@dealtobook.com	2023-05-31 15:39:48.614399	t	\N	\N	percent	25	593e45ae-4043-4ae0-b91f-e42ea2c44ec4	APART_HOTEL	2025
149	dealtobook.admin@dealtobook.com	2023-05-31 15:49:35.133819	dealtobook.admin@dealtobook.com	2023-05-31 15:49:35.133819	t	\N	\N	percent	20	0c6808d0-2bdd-4d96-bb3b-56330280d8e2	APARTMENT	2023
153	dealtobook.admin@dealtobook.com	2023-05-31 15:51:45.182556	dealtobook.admin@dealtobook.com	2023-05-31 15:51:45.182556	t	\N	\N	percent	22	b71a4a0f-65a8-4e9d-8258-5aee9cd6dc26	APARTMENT	2024
155	dealtobook.admin@dealtobook.com	2023-05-31 15:52:39.136657	dealtobook.admin@dealtobook.com	2023-05-31 15:52:39.136657	t	\N	\N	percent	25	e96d819d-ac82-4381-8daa-5c18dae61424	APARTMENT	2025
160	dealtobook.admin@dealtobook.com	2023-05-31 15:57:43.688598	dealtobook.admin@dealtobook.com	2023-05-31 15:57:43.688598	t	\N	\N	percent	20	adac7dd2-84a2-4305-a9fe-1a6dc390e029	CITY_TOUR	2023
165	dealtobook.admin@dealtobook.com	2023-05-31 16:00:32.76027	dealtobook.admin@dealtobook.com	2023-05-31 16:00:32.76027	t	\N	\N	percent	22	7060d8d3-bc0f-4c15-8687-91441f9b86a9	CITY_TOUR	2024
166	dealtobook.admin@dealtobook.com	2023-05-31 16:00:58.347016	dealtobook.admin@dealtobook.com	2023-05-31 16:00:58.347016	t	\N	\N	percent	25	5b5b43b6-fd4d-495c-b1e1-b91f5209a8fb	CITY_TOUR	2025
167	dealtobook.admin@dealtobook.com	2023-05-31 16:01:41.800111	dealtobook.admin@dealtobook.com	2023-05-31 16:01:41.800111	t	\N	\N	percent	25	98220a96-b59b-4ab9-8de1-2eb86a622c13	TOUR_4_CITIES	2025
168	dealtobook.admin@dealtobook.com	2023-05-31 16:02:45.32485	dealtobook.admin@dealtobook.com	2023-05-31 16:02:45.32485	t	\N	\N	percent	22	cf8450b1-2a5f-486a-aafc-0652b0fad03c	TOUR_4_CITIES	2024
169	dealtobook.admin@dealtobook.com	2023-05-31 16:03:25.316007	dealtobook.admin@dealtobook.com	2023-05-31 16:03:25.316007	t	\N	\N	percent	20	1cdbd563-73aa-4770-8b7f-24967b0d4d4b	TOUR_4_CITIES	2023
\.


--
-- TOC entry 3997 (class 0 OID 29250)
-- Dependencies: 213
-- Data for Name: request_client; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.request_client (req_id, created_by, created_date, last_modified_by, last_modified_date, adult_nbr, alert, base_url, budget, child_age, child_nbr, close, comment, cron, currency, email, expire, first_trait, req_from, full_name, phone, phone_code, public_id, room_nbr, second_trait, tier_public_id, req_to, user_public_id, client_email, client_first_name, client_last_name, client_phone, client_phone_code, from_deal_user, day_nbr, to_deal_provider) FROM stdin;
452	anonymousUser	2024-02-12 17:58:54.798583	system	2024-02-12 19:00:00.588525	2	f	https://website-dev.dealtobook.com	222	5	1	t		24	EUR	s.kaoueche@omicrone.fr	f	t	2024-02-13	\N	0033323332332	\N	3427c931-fb73-4da2-8951-4f36caaee318	2	t	\N	2024-02-20	\N	\N	\N	\N	\N	\N	f	7	\N
752	anonymousUser	2025-05-20 11:49:44.434443	system	2025-05-20 13:30:00.142547	2	f	https://website-dev.dealtobook.com	\N	6,10	2	t	High floor	72	GBP	ahmed.khouadja@gmail.com	f	t	2025-05-27	\N	00447508904761	\N	84999ad7-63e3-4cb0-91ec-4fc01486886d	2	t	\N	2025-05-29	\N	\N	\N	\N	\N	\N	f	2	\N
453	anonymousUser	2024-03-07 20:36:36.886319	system	2024-03-07 22:00:00.305977	2	f	https://website-dev.dealtobook.com	300	3	1	t	Gftesttty tggg	48	GBP	expertof@gmail.com	f	t	2024-03-21	\N	00442089765432	\N	6c187664-13f4-4f72-8c92-368e1f051419	1	t	\N	2024-03-23	\N	\N	\N	\N	\N	\N	f	2	\N
552	anonymousUser	2024-12-16 00:18:22.5213	system	2024-12-16 20:30:00.347408	2	f	https://website-dev.dealtobook.com	\N	\N	\N	t	High floor 	24	GBP	exe.consultant@live.co.uk	f	t	2024-12-25	\N	00447508601731	\N	3be5272a-f10a-4166-8603-fbdd63fa844d	1	t	\N	2024-12-31	\N	\N	\N	\N	\N	\N	f	6	\N
803	anonymousUser	2025-06-21 06:25:49.709378	system	2025-06-21 07:30:00.12651	2	f	https://website-dev.dealtobook.com	569990	4,4	2	t	Fggghh	24	GBP	Ahnv@gmail.co.uj	f	t	2025-06-24	\N	00443658908856	\N	8bd49b46-6987-47ee-bd95-cbd2707de4ed	2	t	\N	2025-06-29	\N	\N	\N	\N	\N	\N	f	5	\N
602	anonymousUser	2025-02-12 13:09:36.162096	system	2025-02-12 14:00:00.261082	2	f	https://website-dev.dealtobook.com	\N	3,5,7	3	t	Nothing \nVIP\n	24	GBP	ahmed.khouadja@gmail.com	f	t	2025-04-14	\N	00447508904761	\N	29256c2f-8f44-4a10-9c8f-f7530796c61d	2	t	\N	2025-04-21	\N	\N	\N	\N	\N	\N	f	7	\N
753	anonymousUser	2025-05-21 02:39:49.008732	system	2025-05-21 03:30:00.063277	4	f	https://website-dev.dealtobook.com	\N	2,1	2	t	High Floor	24	GBP	ahmed.khouadja@gmail.com	f	t	2025-05-26	\N	00447508904761	\N	51302341-ee2a-4470-a213-66538b685352	4	t	\N	2025-05-29	\N	\N	\N	\N	\N	\N	f	3	\N
652	anonymousUser	2025-02-12 14:48:04.664122	system	2025-02-12 16:00:00.359915	2	f	https://website-dev.dealtobook.com	\N	1,4	2	t		24	GBP	ahmed.khouadja@gmail.com	f	t	2025-02-24	\N	00447508904761	\N	922e01ac-d1a2-4df9-a622-690284ed76fb	2	t	\N	2025-02-27	\N	\N	\N	\N	\N	\N	f	3	\N
653	anonymousUser	2025-02-12 15:00:26.879058	system	2025-02-12 16:30:00.173329	2	f	https://website-dev.dealtobook.com	\N	4,5	2	t	Special Request:	72	GBP	ahmed.khouadja@gmail.com	f	t	2025-04-14	\N	00447508904761	\N	3d329c33-f53a-4bcc-9e44-ecc516dd9a5f	2	t	\N	2025-04-21	\N	\N	\N	\N	\N	\N	f	7	\N
654	anonymousUser	2025-02-12 15:35:18.41727	system	2025-02-12 16:30:00.173788	2	f	https://website-dev.dealtobook.com	\N	4,6	2	t	Trrre	24	GBP	ahmed.khouadja@gmail.com	f	t	2025-02-25	\N	00447508904761	\N	185d1517-fba4-4355-b89a-c1ea1d13c244	2	t	\N	2025-02-27	\N	\N	\N	\N	\N	\N	f	2	\N
754	anonymousUser	2025-05-23 11:00:45.148032	system	2025-05-23 12:30:00.056412	3	f	https://website-dev.dealtobook.com	\N	9	1	t	Higher	72	GBP	ahmed.khouadja@gmail.com	f	t	2025-05-29	\N	00447508904761	\N	4a848c8d-b706-4ca8-b149-103c6b12668a	2	t	\N	2025-05-30	\N	\N	\N	\N	\N	\N	f	1	\N
655	anonymousUser	2025-02-18 08:23:20.474563	system	2025-02-18 09:30:00.069228	2	f	https://website-dev.dealtobook.com	\N	3,17	2	t	Room quiet and high floor	48	GBP	ahmed.khouadja@gmail.com	f	t	2025-04-22	\N	00447446911488	\N	515dfa3c-c7e1-4541-ae4b-3bcb80b93d6f	2	t	\N	2025-04-29	\N	\N	\N	\N	\N	\N	f	7	\N
702	anonymousUser	2025-05-07 21:28:43.863538	system	2025-05-07 22:30:00.276781	3	f	https://website-dev.dealtobook.com	\N	6,6	2	t	hhhh	24	GBP	ahmed.khouadja@gmail.com	f	t	2025-05-26	\N	00447508904761	\N	21d70de8-f5a1-4240-8159-0fc5b80be155	2	t	\N	2025-05-29	\N	\N	\N	\N	\N	\N	f	3	\N
755	anonymousUser	2025-05-26 13:16:25.313809	system	2025-05-26 14:30:00.059306	3	f	https://website-dev.dealtobook.com	\N	3	1	t	higher floor	72	GBP	ahmed.khouadja@gmail.com	f	t	2025-05-28	\N	00447508904761	\N	41f70d00-3a62-459a-8325-e4abc9fd5151	2	t	\N	2025-05-29	\N	\N	\N	\N	\N	\N	f	1	\N
756	anonymousUser	2025-05-26 13:17:37.181983	system	2025-05-26 14:30:00.059583	2	f	https://website-dev.dealtobook.com	\N	4,8	2	t	High Floor	48	GBP	ahmed.khouadja@gmail.com	f	t	2025-05-28	\N	00447508904761	\N	f7566ea0-bb23-4d51-a7b3-fd72e2cb9129	2	t	\N	2025-05-29	\N	\N	\N	\N	\N	\N	f	1	\N
802	anonymousUser	2025-06-18 15:03:26.226159	system	2025-06-18 16:00:00.311093	2	f	https://website-dev.dealtobook.com	33345	4	1	t	High floor\nQuiet Room\nRoom Service	48	GBP	Addgg@gmail.com	f	t	2025-06-24	\N	00447446911488	\N	ff3b1af3-e6c2-4363-ad90-13de36fcc085	1	t	\N	2025-06-25	\N	\N	\N	\N	\N	\N	f	1	\N
\.


--
-- TOC entry 3998 (class 0 OID 29257)
-- Dependencies: 214
-- Data for Name: request_client_tour_service; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.request_client_tour_service (req_id, service_public_id, sub_req_id, tier_public_id, created_by, created_date, last_modified_by, last_modified_date, close, email, req_public_id, sub_req_public_id, tier_code, confirmed, country_public_id, response, service_type, adult_nbr, bb_age, bb_nbr, child_age, child_nbr) FROM stdin;
\.


--
-- TOC entry 4000 (class 0 OID 29271)
-- Dependencies: 216
-- Data for Name: request_extra_services; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.request_extra_services (req_id, service_type) FROM stdin;
\.


--
-- TOC entry 4001 (class 0 OID 29274)
-- Dependencies: 217
-- Data for Name: request_facility; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.request_facility (req_id, facility) FROM stdin;
452	e0ad3f89-4636-478f-9677-149408350aad
452	78f39d43-fbf0-42f7-9064-e9b0141cd228
453	f24f2512-4411-483c-9b3b-14f40d89d480
552	6045bfc1-0c36-4111-a11c-d0a2bab251ea
552	e3e6fc43-f5eb-48c5-b981-c56008f06b2c
552	1b56fe1c-c0d8-4307-8a20-5ded141e3107
653	a373cd52-a091-4d66-9003-4e2c8e331da4
\.


--
-- TOC entry 3999 (class 0 OID 29264)
-- Dependencies: 215
-- Data for Name: request_notif; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.request_notif (id, created_by, created_date, last_modified_by, last_modified_date, active, country_name, country_id, email, public_id, notif_type, time_notif) FROM stdin;
\.


--
-- TOC entry 4002 (class 0 OID 29277)
-- Dependencies: 218
-- Data for Name: response_facility_tier; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.response_facility_tier (id, req_public_id, tier_public_id, created_by, created_date, last_modified_by, last_modified_date, facility, tier_name) FROM stdin;
\.


--
-- TOC entry 4003 (class 0 OID 29284)
-- Dependencies: 219
-- Data for Name: response_tour_service; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.response_tour_service (id, req_id, service_public_id, sub_req_id, tier_public_id, created_by, created_date, last_modified_by, last_modified_date, arrangement, close, expire_offer, first_price, max_adult, max_child, new_marge, normal_occup, pre_choose, request_create_date, req_public_id, room_nbr, room_style, room_type, room_type_style_id, second_price, sub_req_public_id, tier_code, tier_name, total_price, validate_choose, release_date, confirmed) FROM stdin;
\.


--
-- TOC entry 4004 (class 0 OID 29291)
-- Dependencies: 220
-- Data for Name: room_type_style; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.room_type_style (id, req_id, sub_req_id, created_by, created_date, last_modified_by, last_modified_date, max_adult, max_child, normal_occup, public_id, req_public_id, room_style, room_style_id, room_type, room_type_id, sub_req_public_id) FROM stdin;
1	452	1	anonymousUser	2024-02-12 17:58:55.993654	anonymousUser	2024-02-12 17:58:55.993654	2	1	1	22fe7559-6962-4a17-95d2-35769b08f394	3427c931-fb73-4da2-8951-4f36caaee318	Standards	a430c972-32fd-4097-8d36-f156053ebd69	Double Room (DBL)	55b0c45c-5156-418a-a612-ce21c3f47615	0f7fe8aa-b8d1-4510-82fd-857d0c1f1a56
2	452	1	anonymousUser	2024-02-12 17:58:56.094525	anonymousUser	2024-02-12 17:58:56.094525	1	0	1	b1f6e0f3-ecda-4f85-96c8-874e89f796c0	3427c931-fb73-4da2-8951-4f36caaee318	Deluxe	a7ba9c05-b294-4bb9-b987-b1a1c63a8cc3	Single Room (SGL)	1cb0425d-be27-45eb-80d9-5a59d3823b6f	0f7fe8aa-b8d1-4510-82fd-857d0c1f1a56
1	452	2	anonymousUser	2024-02-12 17:58:56.192656	anonymousUser	2024-02-12 17:58:56.192656	1	0	1	84b4c82f-b1ab-4b70-94aa-cc9cb13945a3	3427c931-fb73-4da2-8951-4f36caaee318	Default	\N	Single Room (SGL)	1cb0425d-be27-45eb-80d9-5a59d3823b6f	fd6aa6f0-792d-43cd-a58a-f9d83822402c
2	452	2	anonymousUser	2024-02-12 17:58:56.198077	anonymousUser	2024-02-12 17:58:56.198077	2	1	1	2216a398-a99d-4e28-80b7-83c247bf9a0e	3427c931-fb73-4da2-8951-4f36caaee318	Default	\N	Twin Room (TW)	4808deb8-83a7-4c3b-b9c1-14862b663daa	fd6aa6f0-792d-43cd-a58a-f9d83822402c
1	452	3	anonymousUser	2024-02-12 17:58:56.301347	anonymousUser	2024-02-12 17:58:56.301347	2	1	1	d936bece-a754-4bbf-b651-2c2c70a84dcc	3427c931-fb73-4da2-8951-4f36caaee318	Standards	a430c972-32fd-4097-8d36-f156053ebd69	Double Room (DBL)	55b0c45c-5156-418a-a612-ce21c3f47615	79536573-a94b-46da-bfbd-b62bb76a44d9
2	452	3	anonymousUser	2024-02-12 17:58:56.390837	anonymousUser	2024-02-12 17:58:56.390837	1	0	1	e6961282-d04a-4ba9-b041-fb2ea918dc8a	3427c931-fb73-4da2-8951-4f36caaee318	Deluxe	a7ba9c05-b294-4bb9-b987-b1a1c63a8cc3	Single Room (SGL)	1cb0425d-be27-45eb-80d9-5a59d3823b6f	79536573-a94b-46da-bfbd-b62bb76a44d9
1	452	4	anonymousUser	2024-02-12 17:58:56.403069	anonymousUser	2024-02-12 17:58:56.403069	1	0	1	c18570f9-26aa-438d-8ce7-3012de97ddc4	3427c931-fb73-4da2-8951-4f36caaee318	Default	\N	Single Room (SGL)	1cb0425d-be27-45eb-80d9-5a59d3823b6f	67afe568-4b95-4a51-a086-9f738c77346b
2	452	4	anonymousUser	2024-02-12 17:58:56.491482	anonymousUser	2024-02-12 17:58:56.491482	2	1	1	d85a59ba-b4a4-441a-bb3c-4a52e523074d	3427c931-fb73-4da2-8951-4f36caaee318	Default	\N	Twin Room (TW)	4808deb8-83a7-4c3b-b9c1-14862b663daa	67afe568-4b95-4a51-a086-9f738c77346b
1	452	5	anonymousUser	2024-02-12 17:58:56.590287	anonymousUser	2024-02-12 17:58:56.590287	3	0	1	cddd47db-5adc-4756-b5d3-65bd80f56302	3427c931-fb73-4da2-8951-4f36caaee318	Deluxe	a8e7b85f-e712-4200-ac2f-cb834807ac62	01 Bedroom	8bed2e0b-9eaf-45b6-9b29-01a5f0b3f991	bc70932a-89f9-4ee1-b790-ca42055bcd0b
1	452	6	anonymousUser	2024-02-12 17:58:56.602201	anonymousUser	2024-02-12 17:58:56.602201	4	2	2	191691ca-b2a8-4ef9-82f5-7b55cdd6b7c6	3427c931-fb73-4da2-8951-4f36caaee318	Default	\N	Penthouse 	749d8c07-f9d0-4834-bc9f-e3d2d960e114	0c7ba2b7-1fc3-4d9a-a159-cd4a3d527a72
1	452	7	anonymousUser	2024-02-12 17:58:56.697849	anonymousUser	2024-02-12 17:58:56.697849	2	1	1	ef82f2ff-6ee5-43b7-b814-1ae793c7f7e7	3427c931-fb73-4da2-8951-4f36caaee318	Standards	a430c972-32fd-4097-8d36-f156053ebd69	Double Room (DBL)	55b0c45c-5156-418a-a612-ce21c3f47615	1f4ce5fa-6c8d-4851-9c1b-5eed80f2fdbf
2	452	7	anonymousUser	2024-02-12 17:58:56.701815	anonymousUser	2024-02-12 17:58:56.701815	1	0	1	fa9db057-fec0-465c-aabd-a1d863dc2a3a	3427c931-fb73-4da2-8951-4f36caaee318	Deluxe	a7ba9c05-b294-4bb9-b987-b1a1c63a8cc3	Single Room (SGL)	1cb0425d-be27-45eb-80d9-5a59d3823b6f	1f4ce5fa-6c8d-4851-9c1b-5eed80f2fdbf
1	452	8	anonymousUser	2024-02-12 17:58:56.712424	anonymousUser	2024-02-12 17:58:56.712424	1	0	1	1ea8b527-b262-4c28-9404-256c3ec80b9a	3427c931-fb73-4da2-8951-4f36caaee318	Default	\N	Single Room (SGL)	1cb0425d-be27-45eb-80d9-5a59d3823b6f	4a241359-641f-4e48-b6fc-9bedcc867985
2	452	8	anonymousUser	2024-02-12 17:58:56.790957	anonymousUser	2024-02-12 17:58:56.790957	2	1	1	2c54e0d4-b0e7-4549-9586-81f83537fffb	3427c931-fb73-4da2-8951-4f36caaee318	Default	\N	Twin Room (TW)	4808deb8-83a7-4c3b-b9c1-14862b663daa	4a241359-641f-4e48-b6fc-9bedcc867985
1	452	9	anonymousUser	2024-02-12 17:58:56.80412	anonymousUser	2024-02-12 17:58:56.80412	2	1	1	c5ebfb6a-2072-4a4b-879e-9f2a4762cac6	3427c931-fb73-4da2-8951-4f36caaee318	Standards	a430c972-32fd-4097-8d36-f156053ebd69	Double Room (DBL)	55b0c45c-5156-418a-a612-ce21c3f47615	5cdc3e21-1f61-4184-a796-bbb287d999f7
2	452	9	anonymousUser	2024-02-12 17:58:56.890805	anonymousUser	2024-02-12 17:58:56.890805	1	0	1	cf0ebb57-d5d0-4b9b-9a80-b5a38bac6d1c	3427c931-fb73-4da2-8951-4f36caaee318	Deluxe	a7ba9c05-b294-4bb9-b987-b1a1c63a8cc3	Single Room (SGL)	1cb0425d-be27-45eb-80d9-5a59d3823b6f	5cdc3e21-1f61-4184-a796-bbb287d999f7
1	452	10	anonymousUser	2024-02-12 17:58:56.902495	anonymousUser	2024-02-12 17:58:56.902495	1	0	1	e5004524-c76b-4c4e-aede-8790805c728c	3427c931-fb73-4da2-8951-4f36caaee318	Default	\N	Single Room (SGL)	1cb0425d-be27-45eb-80d9-5a59d3823b6f	c965bb00-c334-40a8-9e9f-c82922ba8199
2	452	10	anonymousUser	2024-02-12 17:58:56.906503	anonymousUser	2024-02-12 17:58:56.906503	2	1	1	aea38e07-5eba-4eb2-9a3f-844b5dc9d091	3427c931-fb73-4da2-8951-4f36caaee318	Default	\N	Twin Room (TW)	4808deb8-83a7-4c3b-b9c1-14862b663daa	c965bb00-c334-40a8-9e9f-c82922ba8199
1	452	11	anonymousUser	2024-02-12 17:58:56.999743	anonymousUser	2024-02-12 17:58:56.999743	3	0	1	f2231cc4-c56b-4b55-87dc-09557a9a7ee5	3427c931-fb73-4da2-8951-4f36caaee318	Deluxe	a8e7b85f-e712-4200-ac2f-cb834807ac62	01 Bedroom	8bed2e0b-9eaf-45b6-9b29-01a5f0b3f991	e94a8515-dde4-43df-8630-bb9ef199febf
1	452	12	anonymousUser	2024-02-12 17:58:57.087383	anonymousUser	2024-02-12 17:58:57.087383	4	2	2	a85871b9-05c1-4442-91ee-804243cd7897	3427c931-fb73-4da2-8951-4f36caaee318	Default	\N	Penthouse 	749d8c07-f9d0-4834-bc9f-e3d2d960e114	8962b700-5200-417f-a629-a01c22b191fc
1	453	1	anonymousUser	2024-03-07 20:36:37.009795	anonymousUser	2024-03-07 20:36:37.009795	2	1	1	13c2452e-a958-4848-88dd-c2bded9b4f83	6c187664-13f4-4f72-8c92-368e1f051419	Standards	a430c972-32fd-4097-8d36-f156053ebd69	Double Room (DBL)	55b0c45c-5156-418a-a612-ce21c3f47615	66caf9b6-faa7-4435-b6d1-df2532ecd04c
1	453	2	anonymousUser	2024-03-07 20:36:37.018588	anonymousUser	2024-03-07 20:36:37.018588	2	1	1	9df73a18-8b16-4a39-9c7f-5a4ffdf03d76	6c187664-13f4-4f72-8c92-368e1f051419	Standards	a430c972-32fd-4097-8d36-f156053ebd69	Double Room (DBL)	55b0c45c-5156-418a-a612-ce21c3f47615	2944005b-5d3c-4960-9f26-9ee8a034d8f9
1	453	3	anonymousUser	2024-03-07 20:36:37.030947	anonymousUser	2024-03-07 20:36:37.030947	4	2	3	e09a74db-c059-40fc-b4a7-310153baa1c0	6c187664-13f4-4f72-8c92-368e1f051419	Standards	dca35d65-f981-4531-915b-4412bfaeb2d8	02 Bedrooms	af25e2f7-d1e4-4b6a-8676-99221f60fe61	15430aea-3780-43ec-8958-f6cbe3af20b0
1	453	4	anonymousUser	2024-03-07 20:36:37.0433	anonymousUser	2024-03-07 20:36:37.0433	2	1	1	8210ab1a-773b-4f87-9eb9-da9dfcf2394d	6c187664-13f4-4f72-8c92-368e1f051419	Standards	a430c972-32fd-4097-8d36-f156053ebd69	Double Room (DBL)	55b0c45c-5156-418a-a612-ce21c3f47615	16d7a87e-dc84-4141-8b28-d3d9330f194f
1	453	5	anonymousUser	2024-03-07 20:36:37.112967	anonymousUser	2024-03-07 20:36:37.112967	2	1	1	c39218cc-4f07-4a59-9033-4dbcfdca2710	6c187664-13f4-4f72-8c92-368e1f051419	Standards	a430c972-32fd-4097-8d36-f156053ebd69	Double Room (DBL)	55b0c45c-5156-418a-a612-ce21c3f47615	79e9c64e-aaad-4a9e-b247-5927d98e0519
1	453	6	anonymousUser	2024-03-07 20:36:37.132971	anonymousUser	2024-03-07 20:36:37.132971	4	2	3	c71face8-76ab-4b02-9536-5cc781173411	6c187664-13f4-4f72-8c92-368e1f051419	Standards	dca35d65-f981-4531-915b-4412bfaeb2d8	02 Bedrooms	af25e2f7-d1e4-4b6a-8676-99221f60fe61	4636756d-dcd4-48fb-b9b9-c70af33f3765
1	552	1	anonymousUser	2024-12-16 00:18:23.436758	anonymousUser	2024-12-16 00:18:23.436758	2	1	1	ea0c6739-3628-4078-9a8e-eb0b27f8b6e6	3be5272a-f10a-4166-8603-fbdd63fa844d	Standards	a430c972-32fd-4097-8d36-f156053ebd69	Double Room (DBL)	55b0c45c-5156-418a-a612-ce21c3f47615	47b4f3fd-2cce-4fa2-9627-49ebf657a252
1	602	1	anonymousUser	2025-02-12 13:09:36.971292	anonymousUser	2025-02-12 13:09:36.971292	1	0	1	05599d5d-dad4-484d-ac96-3aae2bb9d380	29256c2f-8f44-4a10-9c8f-f7530796c61d	Deluxe	a7ba9c05-b294-4bb9-b987-b1a1c63a8cc3	Single Room (SGL)	1cb0425d-be27-45eb-80d9-5a59d3823b6f	ecf921c1-1f82-4362-8e48-3c726d10e319
2	602	1	anonymousUser	2025-02-12 13:09:37.065984	anonymousUser	2025-02-12 13:09:37.065984	2	1	1	c564772f-edad-4a1f-9a27-329daba71b25	29256c2f-8f44-4a10-9c8f-f7530796c61d	Deluxe	a7ba9c05-b294-4bb9-b987-b1a1c63a8cc3	Twin Room (TW)	4808deb8-83a7-4c3b-b9c1-14862b663daa	ecf921c1-1f82-4362-8e48-3c726d10e319
1	652	1	anonymousUser	2025-02-12 14:48:05.774854	anonymousUser	2025-02-12 14:48:05.774854	2	1	1	7c8e4388-3056-4e56-8756-a728037455ea	922e01ac-d1a2-4df9-a622-690284ed76fb	Deluxe	a7ba9c05-b294-4bb9-b987-b1a1c63a8cc3	Double Room (DBL)	55b0c45c-5156-418a-a612-ce21c3f47615	dbf655f0-90a6-4121-82e5-92aaef3c1805
2	652	1	anonymousUser	2025-02-12 14:48:05.865092	anonymousUser	2025-02-12 14:48:05.865092	1	0	1	210c013f-8e5d-4707-9dd0-aa2d466c133c	922e01ac-d1a2-4df9-a622-690284ed76fb	Deluxe	a7ba9c05-b294-4bb9-b987-b1a1c63a8cc3	Single Room (SGL)	1cb0425d-be27-45eb-80d9-5a59d3823b6f	dbf655f0-90a6-4121-82e5-92aaef3c1805
1	653	1	anonymousUser	2025-02-12 15:00:26.978477	anonymousUser	2025-02-12 15:00:26.978477	2	1	1	927f469f-a717-4a8e-a51c-84e7be4111d3	3d329c33-f53a-4bcc-9e44-ecc516dd9a5f	Deluxe	a7ba9c05-b294-4bb9-b987-b1a1c63a8cc3	Double Room (DBL)	55b0c45c-5156-418a-a612-ce21c3f47615	f98e7ad9-3e67-4eae-b948-f2f99160acc2
2	653	1	anonymousUser	2025-02-12 15:00:27.061928	anonymousUser	2025-02-12 15:00:27.061928	1	0	1	612b4e8a-017a-42ac-9f2f-8f02f33cff19	3d329c33-f53a-4bcc-9e44-ecc516dd9a5f	Deluxe	a7ba9c05-b294-4bb9-b987-b1a1c63a8cc3	Single Room (SGL)	1cb0425d-be27-45eb-80d9-5a59d3823b6f	f98e7ad9-3e67-4eae-b948-f2f99160acc2
1	653	2	anonymousUser	2025-02-12 15:00:27.161188	anonymousUser	2025-02-12 15:00:27.161188	3	0	1	d93a3f5d-21b7-4c64-9f66-9f635d1535ae	3d329c33-f53a-4bcc-9e44-ecc516dd9a5f	Superior	82814a9b-cfc9-4b23-a2c6-6b1a7f7f0a9c	01 Bedroom	0d515a7d-b563-40b8-9286-d877624c7221	b96fa7e6-3b11-4626-af5a-c861a5dcf210
1	654	1	anonymousUser	2025-02-12 15:35:18.461721	anonymousUser	2025-02-12 15:35:18.461721	2	1	1	80635eec-79b1-464a-891c-359b5d9a1caf	185d1517-fba4-4355-b89a-c1ea1d13c244	Deluxe	a7ba9c05-b294-4bb9-b987-b1a1c63a8cc3	Double Room (DBL)	55b0c45c-5156-418a-a612-ce21c3f47615	8010ea9c-6485-4369-8ef0-df659027a10c
2	654	1	anonymousUser	2025-02-12 15:35:18.466735	anonymousUser	2025-02-12 15:35:18.466735	1	0	1	27da59a6-d6eb-405e-8a31-5af4efce974f	185d1517-fba4-4355-b89a-c1ea1d13c244	Deluxe	a7ba9c05-b294-4bb9-b987-b1a1c63a8cc3	Single Room (SGL)	1cb0425d-be27-45eb-80d9-5a59d3823b6f	8010ea9c-6485-4369-8ef0-df659027a10c
1	655	1	anonymousUser	2025-02-18 08:23:20.760545	anonymousUser	2025-02-18 08:23:20.760545	2	1	1	e376f797-eb6e-43d7-a112-985fa271af6c	515dfa3c-c7e1-4541-ae4b-3bcb80b93d6f	Deluxe	a7ba9c05-b294-4bb9-b987-b1a1c63a8cc3	Double Room (DBL)	55b0c45c-5156-418a-a612-ce21c3f47615	e3d10e2f-06b4-4ff0-97b3-5f0126e44dc3
2	655	1	anonymousUser	2025-02-18 08:23:20.764286	anonymousUser	2025-02-18 08:23:20.764286	1	0	1	2504ca26-d78e-4305-bf74-df7572d366c2	515dfa3c-c7e1-4541-ae4b-3bcb80b93d6f	Deluxe	a7ba9c05-b294-4bb9-b987-b1a1c63a8cc3	Single Room (SGL)	1cb0425d-be27-45eb-80d9-5a59d3823b6f	e3d10e2f-06b4-4ff0-97b3-5f0126e44dc3
1	702	1	anonymousUser	2025-05-07 21:28:45.061038	anonymousUser	2025-05-07 21:28:45.061038	2	1	1	70fadba2-6a39-47b4-8bac-b0914873a95b	21d70de8-f5a1-4240-8159-0fc5b80be155	Standards	a430c972-32fd-4097-8d36-f156053ebd69	Double Room (DBL)	55b0c45c-5156-418a-a612-ce21c3f47615	fc297b9e-fff6-42d3-94e6-e89169f2fc18
2	702	1	anonymousUser	2025-05-07 21:28:45.075729	anonymousUser	2025-05-07 21:28:45.075729	1	0	1	db62f2de-dc90-4833-a968-342ac4cb886f	21d70de8-f5a1-4240-8159-0fc5b80be155	Standards	a430c972-32fd-4097-8d36-f156053ebd69	Single Room (SGL)	1cb0425d-be27-45eb-80d9-5a59d3823b6f	fc297b9e-fff6-42d3-94e6-e89169f2fc18
1	752	1	anonymousUser	2025-05-20 11:49:45.542509	anonymousUser	2025-05-20 11:49:45.542509	2	1	1	9e31b1f6-1c26-40fe-8690-26d0fcc69501	84999ad7-63e3-4cb0-91ec-4fc01486886d	Deluxe	a7ba9c05-b294-4bb9-b987-b1a1c63a8cc3	Double Room (DBL)	55b0c45c-5156-418a-a612-ce21c3f47615	61457015-cbc6-41cf-8742-eaaa528a25a9
2	752	1	anonymousUser	2025-05-20 11:49:45.639898	anonymousUser	2025-05-20 11:49:45.639898	1	0	1	971d258d-3a18-4770-8741-f0d0451edf31	84999ad7-63e3-4cb0-91ec-4fc01486886d	Standards	a430c972-32fd-4097-8d36-f156053ebd69	Single Room (SGL)	1cb0425d-be27-45eb-80d9-5a59d3823b6f	61457015-cbc6-41cf-8742-eaaa528a25a9
1	752	2	anonymousUser	2025-05-20 11:49:45.742349	anonymousUser	2025-05-20 11:49:45.742349	1	0	1	f8d08d98-8892-4b5a-9784-5bc0a46e43a2	84999ad7-63e3-4cb0-91ec-4fc01486886d	Standards	a430c972-32fd-4097-8d36-f156053ebd69	Single Room (SGL)	1cb0425d-be27-45eb-80d9-5a59d3823b6f	623b7e54-170c-460b-aa63-6f1489cd065a
2	752	2	anonymousUser	2025-05-20 11:49:45.831743	anonymousUser	2025-05-20 11:49:45.831743	2	1	1	2d3a1292-5349-469b-a84c-ad784440452f	84999ad7-63e3-4cb0-91ec-4fc01486886d	Deluxe	a7ba9c05-b294-4bb9-b987-b1a1c63a8cc3	Twin Room (TW)	4808deb8-83a7-4c3b-b9c1-14862b663daa	623b7e54-170c-460b-aa63-6f1489cd065a
1	753	1	anonymousUser	2025-05-21 02:39:49.152164	anonymousUser	2025-05-21 02:39:49.152164	2	1	1	b3fb78f7-d59d-4d71-a3e1-75800c0ec2fc	51302341-ee2a-4470-a213-66538b685352	Standards	a430c972-32fd-4097-8d36-f156053ebd69	Double Room (DBL)	55b0c45c-5156-418a-a612-ce21c3f47615	f3aff146-fcac-4476-8f81-5d64b64711ef
2	753	1	anonymousUser	2025-05-21 02:39:49.155926	anonymousUser	2025-05-21 02:39:49.155926	1	0	1	450eb785-f46e-4f63-8acc-89afc3d40a02	51302341-ee2a-4470-a213-66538b685352	Standards	a430c972-32fd-4097-8d36-f156053ebd69	Single Room (SGL)	1cb0425d-be27-45eb-80d9-5a59d3823b6f	f3aff146-fcac-4476-8f81-5d64b64711ef
3	753	1	anonymousUser	2025-05-21 02:39:49.158987	anonymousUser	2025-05-21 02:39:49.158987	1	0	1	7de1ff24-a4b4-4746-b162-8996f6d1032c	51302341-ee2a-4470-a213-66538b685352	Standards	a430c972-32fd-4097-8d36-f156053ebd69	Single Room (SGL)	1cb0425d-be27-45eb-80d9-5a59d3823b6f	f3aff146-fcac-4476-8f81-5d64b64711ef
4	753	1	anonymousUser	2025-05-21 02:39:49.162117	anonymousUser	2025-05-21 02:39:49.162117	1	0	1	5c974b0c-a507-443f-95b0-cf702e9f9a6f	51302341-ee2a-4470-a213-66538b685352	Standards	a430c972-32fd-4097-8d36-f156053ebd69	Single Room (SGL)	1cb0425d-be27-45eb-80d9-5a59d3823b6f	f3aff146-fcac-4476-8f81-5d64b64711ef
1	754	1	anonymousUser	2025-05-23 11:00:45.265305	anonymousUser	2025-05-23 11:00:45.265305	2	1	1	a581bc5c-59f1-4804-891d-8084edd35942	4a848c8d-b706-4ca8-b149-103c6b12668a	Deluxe	a7ba9c05-b294-4bb9-b987-b1a1c63a8cc3	Double Room (DBL)	55b0c45c-5156-418a-a612-ce21c3f47615	2cab6a9e-3f21-403e-acb8-5dcb50108139
2	754	1	anonymousUser	2025-05-23 11:00:45.351954	anonymousUser	2025-05-23 11:00:45.351954	1	0	1	1dbb9db0-39d0-498a-acfa-2a5e14a9af15	4a848c8d-b706-4ca8-b149-103c6b12668a	Deluxe	a7ba9c05-b294-4bb9-b987-b1a1c63a8cc3	Single Room (SGL)	1cb0425d-be27-45eb-80d9-5a59d3823b6f	2cab6a9e-3f21-403e-acb8-5dcb50108139
1	755	1	anonymousUser	2025-05-26 13:16:25.345219	anonymousUser	2025-05-26 13:16:25.345219	2	1	1	ecc17f02-c234-4469-bfa8-036e7a278f9e	41f70d00-3a62-459a-8325-e4abc9fd5151	Deluxe	a7ba9c05-b294-4bb9-b987-b1a1c63a8cc3	Double Room (DBL)	55b0c45c-5156-418a-a612-ce21c3f47615	d68b18bd-9dc6-41bb-ba95-7fa2dd57458e
2	755	1	anonymousUser	2025-05-26 13:16:25.348606	anonymousUser	2025-05-26 13:16:25.348606	1	0	1	d1d51869-69ed-47f7-89ba-5ee53b7e3f72	41f70d00-3a62-459a-8325-e4abc9fd5151	Superior	73013dec-ab0a-4cee-8bcf-f0bb0243630f	Single Room (SGL)	1cb0425d-be27-45eb-80d9-5a59d3823b6f	d68b18bd-9dc6-41bb-ba95-7fa2dd57458e
1	756	1	anonymousUser	2025-05-26 13:17:37.196683	anonymousUser	2025-05-26 13:17:37.196683	2	1	1	ba9cc5c5-5886-4f94-9611-3483788e9f6c	f7566ea0-bb23-4d51-a7b3-fd72e2cb9129	Superior	73013dec-ab0a-4cee-8bcf-f0bb0243630f	Double Room (DBL)	55b0c45c-5156-418a-a612-ce21c3f47615	5c70c026-d2e4-48ec-8d8f-99839c2a3a91
2	756	1	anonymousUser	2025-05-26 13:17:37.200037	anonymousUser	2025-05-26 13:17:37.200037	1	0	1	085abe0f-b074-4928-ab2b-385fdd646340	f7566ea0-bb23-4d51-a7b3-fd72e2cb9129	Superior	73013dec-ab0a-4cee-8bcf-f0bb0243630f	Single Room (SGL)	1cb0425d-be27-45eb-80d9-5a59d3823b6f	5c70c026-d2e4-48ec-8d8f-99839c2a3a91
1	802	1	anonymousUser	2025-06-18 15:03:27.313775	anonymousUser	2025-06-18 15:03:27.313775	2	1	1	bff2b3d0-3054-44fd-adee-325eadb47752	ff3b1af3-e6c2-4363-ad90-13de36fcc085	Deluxe	a7ba9c05-b294-4bb9-b987-b1a1c63a8cc3	Double Room (DBL)	55b0c45c-5156-418a-a612-ce21c3f47615	028db9de-33a9-41b7-bad8-84032dbdebae
1	803	1	anonymousUser	2025-06-21 06:25:49.813628	anonymousUser	2025-06-21 06:25:49.813628	3	0	1	bd6db870-bb0d-421f-b1a4-8bae35b9576c	8bd49b46-6987-47ee-bd95-cbd2707de4ed	Standards	0d19fd0c-7cf6-4ff7-b2e3-61bd4b832aa6	01 Bedroom with 01 Toilet	49cd94ae-46bd-435f-9f90-12a477350376	210e5746-a4ff-49d1-b8fb-3086e3d59f92
\.


--
-- TOC entry 4005 (class 0 OID 29298)
-- Dependencies: 221
-- Data for Name: sub_request_client; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.sub_request_client (req_id, sub_req_id, created_by, created_date, last_modified_by, last_modified_date, alert, arrangement, base_url, city, city_id, star, close, country, country_code, country_id, first_trait, public_id, req_public_id, second_trait, serv_type, zone, zone_id, to_deal_provider) FROM stdin;
453	1	anonymousUser	2024-03-07 20:36:37.005309	system	2024-03-07 22:00:00.306139	f	ROOM_ONLY	\N	London	b653d9c8-0ac4-498c-bb5a-bf82bb460b05	FOUR	t	United Kingdom	GB	c57d4118-1598-4144-b2fb-2088829f6d61	t	66caf9b6-faa7-4435-b6d1-df2532ecd04c	6c187664-13f4-4f72-8c92-368e1f051419	t	HOTEL	\N	\N	\N
453	2	anonymousUser	2024-03-07 20:36:37.015452	system	2024-03-07 22:00:00.306261	f	BREAKFAST	\N	London	b653d9c8-0ac4-498c-bb5a-bf82bb460b05	FOUR	t	United Kingdom	GB	c57d4118-1598-4144-b2fb-2088829f6d61	t	2944005b-5d3c-4960-9f26-9ee8a034d8f9	6c187664-13f4-4f72-8c92-368e1f051419	t	HOTEL	\N	\N	\N
453	3	anonymousUser	2024-03-07 20:36:37.027557	system	2024-03-07 22:00:00.306352	f	\N	\N	London	b653d9c8-0ac4-498c-bb5a-bf82bb460b05	FOUR	t	United Kingdom	GB	c57d4118-1598-4144-b2fb-2088829f6d61	t	15430aea-3780-43ec-8958-f6cbe3af20b0	6c187664-13f4-4f72-8c92-368e1f051419	t	APART_HOTEL	\N	\N	\N
453	4	anonymousUser	2024-03-07 20:36:37.040285	system	2024-03-07 22:00:00.30642	f	ROOM_ONLY	\N	London	b653d9c8-0ac4-498c-bb5a-bf82bb460b05	FOUR_PLUS	t	United Kingdom	GB	c57d4118-1598-4144-b2fb-2088829f6d61	t	16d7a87e-dc84-4141-8b28-d3d9330f194f	6c187664-13f4-4f72-8c92-368e1f051419	t	HOTEL	\N	\N	\N
452	1	anonymousUser	2024-02-12 17:58:55.812496	system	2024-02-12 19:00:00.588931	f	ROOM_ONLY	\N	Paris	e9fba3a3-668c-4708-ab3c-1cc3724b0acd	FOUR	t	France	FR	cea44d2f-588d-4b30-91f4-842a2c9428d4	t	0f7fe8aa-b8d1-4510-82fd-857d0c1f1a56	3427c931-fb73-4da2-8951-4f36caaee318	t	HOTEL	\N	\N	\N
452	2	anonymousUser	2024-02-12 17:58:56.106478	system	2024-02-12 19:00:00.590322	f	ROOM_ONLY	\N	Paris	e9fba3a3-668c-4708-ab3c-1cc3724b0acd	FOUR	t	France	FR	cea44d2f-588d-4b30-91f4-842a2c9428d4	t	fd6aa6f0-792d-43cd-a58a-f9d83822402c	3427c931-fb73-4da2-8951-4f36caaee318	t	HOTEL	\N	\N	\N
452	3	anonymousUser	2024-02-12 17:58:56.296261	system	2024-02-12 19:00:00.591213	f	BREAKFAST	\N	Paris	e9fba3a3-668c-4708-ab3c-1cc3724b0acd	FOUR	t	France	FR	cea44d2f-588d-4b30-91f4-842a2c9428d4	t	79536573-a94b-46da-bfbd-b62bb76a44d9	3427c931-fb73-4da2-8951-4f36caaee318	t	HOTEL	\N	\N	\N
452	4	anonymousUser	2024-02-12 17:58:56.398048	system	2024-02-12 19:00:00.591842	f	BREAKFAST	\N	Paris	e9fba3a3-668c-4708-ab3c-1cc3724b0acd	FOUR	t	France	FR	cea44d2f-588d-4b30-91f4-842a2c9428d4	t	67afe568-4b95-4a51-a086-9f738c77346b	3427c931-fb73-4da2-8951-4f36caaee318	t	HOTEL	\N	\N	\N
452	5	anonymousUser	2024-02-12 17:58:56.501653	system	2024-02-12 19:00:00.592039	f	\N	\N	Paris	e9fba3a3-668c-4708-ab3c-1cc3724b0acd	FOUR	t	France	FR	cea44d2f-588d-4b30-91f4-842a2c9428d4	t	bc70932a-89f9-4ee1-b790-ca42055bcd0b	3427c931-fb73-4da2-8951-4f36caaee318	t	APARTMENT	\N	\N	\N
452	6	anonymousUser	2024-02-12 17:58:56.597863	system	2024-02-12 19:00:00.592204	f	\N	\N	Paris	e9fba3a3-668c-4708-ab3c-1cc3724b0acd	FOUR	t	France	FR	cea44d2f-588d-4b30-91f4-842a2c9428d4	t	0c7ba2b7-1fc3-4d9a-a159-cd4a3d527a72	3427c931-fb73-4da2-8951-4f36caaee318	t	APARTMENT	\N	\N	\N
452	7	anonymousUser	2024-02-12 17:58:56.692838	system	2024-02-12 19:00:00.592365	f	ROOM_ONLY	\N	Paris	e9fba3a3-668c-4708-ab3c-1cc3724b0acd	FOUR_PLUS	t	France	FR	cea44d2f-588d-4b30-91f4-842a2c9428d4	t	1f4ce5fa-6c8d-4851-9c1b-5eed80f2fdbf	3427c931-fb73-4da2-8951-4f36caaee318	t	HOTEL	\N	\N	\N
452	8	anonymousUser	2024-02-12 17:58:56.707663	system	2024-02-12 19:00:00.592523	f	ROOM_ONLY	\N	Paris	e9fba3a3-668c-4708-ab3c-1cc3724b0acd	FOUR_PLUS	t	France	FR	cea44d2f-588d-4b30-91f4-842a2c9428d4	t	4a241359-641f-4e48-b6fc-9bedcc867985	3427c931-fb73-4da2-8951-4f36caaee318	t	HOTEL	\N	\N	\N
452	9	anonymousUser	2024-02-12 17:58:56.80013	system	2024-02-12 19:00:00.593368	f	BREAKFAST	\N	Paris	e9fba3a3-668c-4708-ab3c-1cc3724b0acd	FOUR_PLUS	t	France	FR	cea44d2f-588d-4b30-91f4-842a2c9428d4	t	5cdc3e21-1f61-4184-a796-bbb287d999f7	3427c931-fb73-4da2-8951-4f36caaee318	t	HOTEL	\N	\N	\N
452	10	anonymousUser	2024-02-12 17:58:56.898941	system	2024-02-12 19:00:00.59429	f	BREAKFAST	\N	Paris	e9fba3a3-668c-4708-ab3c-1cc3724b0acd	FOUR_PLUS	t	France	FR	cea44d2f-588d-4b30-91f4-842a2c9428d4	t	c965bb00-c334-40a8-9e9f-c82922ba8199	3427c931-fb73-4da2-8951-4f36caaee318	t	HOTEL	\N	\N	\N
452	11	anonymousUser	2024-02-12 17:58:56.994596	system	2024-02-12 19:00:00.594579	f	\N	\N	Paris	e9fba3a3-668c-4708-ab3c-1cc3724b0acd	FOUR_PLUS	t	France	FR	cea44d2f-588d-4b30-91f4-842a2c9428d4	t	e94a8515-dde4-43df-8630-bb9ef199febf	3427c931-fb73-4da2-8951-4f36caaee318	t	APARTMENT	\N	\N	\N
452	12	anonymousUser	2024-02-12 17:58:57.005649	system	2024-02-12 19:00:00.595463	f	\N	\N	Paris	e9fba3a3-668c-4708-ab3c-1cc3724b0acd	FOUR_PLUS	t	France	FR	cea44d2f-588d-4b30-91f4-842a2c9428d4	t	8962b700-5200-417f-a629-a01c22b191fc	3427c931-fb73-4da2-8951-4f36caaee318	t	APARTMENT	\N	\N	\N
754	1	anonymousUser	2025-05-23 11:00:45.256982	system	2025-05-23 12:30:00.05658	f	ROOM_ONLY	\N	Aberdeen	7162b3c9-730c-4f93-97cc-98bb9ac47c51	FOUR	t	United Kingdom	GB	c57d4118-1598-4144-b2fb-2088829f6d61	t	2cab6a9e-3f21-403e-acb8-5dcb50108139	4a848c8d-b706-4ca8-b149-103c6b12668a	t	HOTEL	\N	\N	\N
655	1	anonymousUser	2025-02-18 08:23:20.66546	system	2025-02-18 09:30:00.069999	f	ROOM_ONLY	\N	Aberdeen	7162b3c9-730c-4f93-97cc-98bb9ac47c51	FOUR	t	United Kingdom	GB	c57d4118-1598-4144-b2fb-2088829f6d61	t	e3d10e2f-06b4-4ff0-97b3-5f0126e44dc3	515dfa3c-c7e1-4541-ae4b-3bcb80b93d6f	t	HOTEL	\N	\N	\N
453	5	anonymousUser	2024-03-07 20:36:37.103814	system	2024-03-07 22:00:00.306484	f	BREAKFAST	\N	London	b653d9c8-0ac4-498c-bb5a-bf82bb460b05	FOUR_PLUS	t	United Kingdom	GB	c57d4118-1598-4144-b2fb-2088829f6d61	t	79e9c64e-aaad-4a9e-b247-5927d98e0519	6c187664-13f4-4f72-8c92-368e1f051419	t	HOTEL	\N	\N	\N
453	6	anonymousUser	2024-03-07 20:36:37.129549	system	2024-03-07 22:00:00.306547	f	\N	\N	London	b653d9c8-0ac4-498c-bb5a-bf82bb460b05	FOUR_PLUS	t	United Kingdom	GB	c57d4118-1598-4144-b2fb-2088829f6d61	t	4636756d-dcd4-48fb-b9b9-c70af33f3765	6c187664-13f4-4f72-8c92-368e1f051419	t	APART_HOTEL	\N	\N	\N
552	1	anonymousUser	2024-12-16 00:18:23.327726	system	2024-12-16 20:30:00.347772	f	ROOM_ONLY	\N	Aberdeen	7162b3c9-730c-4f93-97cc-98bb9ac47c51	FOUR_PLUS	t	United Kingdom	GB	c57d4118-1598-4144-b2fb-2088829f6d61	t	47b4f3fd-2cce-4fa2-9627-49ebf657a252	3be5272a-f10a-4166-8603-fbdd63fa844d	t	HOTEL	\N	\N	\N
602	1	anonymousUser	2025-02-12 13:09:36.891237	system	2025-02-12 14:00:00.261327	f	ROOM_ONLY	\N	Aberdeen	7162b3c9-730c-4f93-97cc-98bb9ac47c51	FOUR	t	United Kingdom	GB	c57d4118-1598-4144-b2fb-2088829f6d61	t	ecf921c1-1f82-4362-8e48-3c726d10e319	29256c2f-8f44-4a10-9c8f-f7530796c61d	t	HOTEL	\N	\N	\N
702	1	anonymousUser	2025-05-07 21:28:44.870792	system	2025-05-07 22:30:00.277015	f	ALL_INCLUSIVE	\N	London	b653d9c8-0ac4-498c-bb5a-bf82bb460b05	THREE_PLUS	t	United Kingdom	GB	c57d4118-1598-4144-b2fb-2088829f6d61	t	fc297b9e-fff6-42d3-94e6-e89169f2fc18	21d70de8-f5a1-4240-8159-0fc5b80be155	t	HOTEL	\N	\N	\N
652	1	anonymousUser	2025-02-12 14:48:05.673095	system	2025-02-12 16:00:00.36018	f	ROOM_ONLY	\N	Aberdeen	7162b3c9-730c-4f93-97cc-98bb9ac47c51	FOUR	t	United Kingdom	GB	c57d4118-1598-4144-b2fb-2088829f6d61	t	dbf655f0-90a6-4121-82e5-92aaef3c1805	922e01ac-d1a2-4df9-a622-690284ed76fb	t	HOTEL	\N	\N	\N
653	1	anonymousUser	2025-02-12 15:00:26.972399	system	2025-02-12 16:30:00.173551	f	BREAKFAST	\N	Aberdeen	7162b3c9-730c-4f93-97cc-98bb9ac47c51	FOUR	t	United Kingdom	GB	c57d4118-1598-4144-b2fb-2088829f6d61	t	f98e7ad9-3e67-4eae-b948-f2f99160acc2	3d329c33-f53a-4bcc-9e44-ecc516dd9a5f	t	HOTEL	\N	\N	\N
653	2	anonymousUser	2025-02-12 15:00:27.070318	system	2025-02-12 16:30:00.173666	f	\N	\N	Aberdeen	7162b3c9-730c-4f93-97cc-98bb9ac47c51	FOUR	t	United Kingdom	GB	c57d4118-1598-4144-b2fb-2088829f6d61	t	b96fa7e6-3b11-4626-af5a-c861a5dcf210	3d329c33-f53a-4bcc-9e44-ecc516dd9a5f	t	VILLA	\N	\N	\N
654	1	anonymousUser	2025-02-12 15:35:18.431317	system	2025-02-12 16:30:00.371575	f	ROOM_ONLY	\N	Aberdeen	7162b3c9-730c-4f93-97cc-98bb9ac47c51	FOUR_PLUS	t	United Kingdom	GB	c57d4118-1598-4144-b2fb-2088829f6d61	t	8010ea9c-6485-4369-8ef0-df659027a10c	185d1517-fba4-4355-b89a-c1ea1d13c244	t	HOTEL	\N	\N	\N
752	1	anonymousUser	2025-05-20 11:49:45.428916	system	2025-05-20 13:30:00.142753	f	ROOM_ONLY	\N	Aberdeen	7162b3c9-730c-4f93-97cc-98bb9ac47c51	FOUR	t	United Kingdom	GB	c57d4118-1598-4144-b2fb-2088829f6d61	t	61457015-cbc6-41cf-8742-eaaa528a25a9	84999ad7-63e3-4cb0-91ec-4fc01486886d	t	HOTEL	\N	\N	\N
752	2	anonymousUser	2025-05-20 11:49:45.734413	system	2025-05-20 13:30:00.142871	f	ROOM_ONLY	\N	Aberdeen	7162b3c9-730c-4f93-97cc-98bb9ac47c51	FOUR	t	United Kingdom	GB	c57d4118-1598-4144-b2fb-2088829f6d61	t	623b7e54-170c-460b-aa63-6f1489cd065a	84999ad7-63e3-4cb0-91ec-4fc01486886d	t	HOTEL	\N	\N	\N
803	1	anonymousUser	2025-06-21 06:25:49.747373	system	2025-06-21 07:30:00.126876	f	\N	\N	Anglesey	c7bebcc7-bc46-43e5-834d-b6c2229c726c	FOUR	t	United Kingdom	GB	c57d4118-1598-4144-b2fb-2088829f6d61	t	210e5746-a4ff-49d1-b8fb-3086e3d59f92	8bd49b46-6987-47ee-bd95-cbd2707de4ed	t	COTTAGE	\N	\N	\N
753	1	anonymousUser	2025-05-21 02:39:49.064579	system	2025-05-21 03:30:00.063438	f	ROOM_ONLY	\N	Aberdeen	7162b3c9-730c-4f93-97cc-98bb9ac47c51	FOUR	t	United Kingdom	GB	c57d4118-1598-4144-b2fb-2088829f6d61	t	f3aff146-fcac-4476-8f81-5d64b64711ef	51302341-ee2a-4470-a213-66538b685352	t	HOTEL	\N	\N	\N
755	1	anonymousUser	2025-05-26 13:16:25.336127	system	2025-05-26 14:30:00.059464	f	ROOM_ONLY	\N	Aberdeen	7162b3c9-730c-4f93-97cc-98bb9ac47c51	FOUR	t	United Kingdom	GB	c57d4118-1598-4144-b2fb-2088829f6d61	t	d68b18bd-9dc6-41bb-ba95-7fa2dd57458e	41f70d00-3a62-459a-8325-e4abc9fd5151	t	HOTEL	\N	\N	\N
756	1	anonymousUser	2025-05-26 13:17:37.192234	system	2025-05-26 14:30:00.167422	f	ROOM_ONLY	\N	Aberdeen	7162b3c9-730c-4f93-97cc-98bb9ac47c51	FOUR	t	United Kingdom	GB	c57d4118-1598-4144-b2fb-2088829f6d61	t	5c70c026-d2e4-48ec-8d8f-99839c2a3a91	f7566ea0-bb23-4d51-a7b3-fd72e2cb9129	t	HOTEL	\N	\N	\N
802	1	anonymousUser	2025-06-18 15:03:27.12771	system	2025-06-18 16:00:00.311352	f	BREAKFAST	\N	Aberdeen	7162b3c9-730c-4f93-97cc-98bb9ac47c51	FOUR	t	United Kingdom	GB	c57d4118-1598-4144-b2fb-2088829f6d61	t	028db9de-33a9-41b7-bad8-84032dbdebae	ff3b1af3-e6c2-4363-ad90-13de36fcc085	t	HOTEL	\N	\N	\N
\.


--
-- TOC entry 4012 (class 0 OID 0)
-- Dependencies: 222
-- Name: sequence_generator; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.sequence_generator', 851, true);


--
-- TOC entry 3823 (class 2606 OID 29228)
-- Name: jhi_persistent_audit_event jhi_persistent_audit_event_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.jhi_persistent_audit_event
    ADD CONSTRAINT jhi_persistent_audit_event_pkey PRIMARY KEY (event_id);


--
-- TOC entry 3825 (class 2606 OID 29235)
-- Name: jhi_persistent_audit_evt_data jhi_persistent_audit_evt_data_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.jhi_persistent_audit_evt_data
    ADD CONSTRAINT jhi_persistent_audit_evt_data_pkey PRIMARY KEY (event_id, name);


--
-- TOC entry 3827 (class 2606 OID 29242)
-- Name: marge_of_profit marge_of_profit_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.marge_of_profit
    ADD CONSTRAINT marge_of_profit_pkey PRIMARY KEY (id);


--
-- TOC entry 3829 (class 2606 OID 29249)
-- Name: margin_of_profit_setting margin_of_profit_setting_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.margin_of_profit_setting
    ADD CONSTRAINT margin_of_profit_setting_pkey PRIMARY KEY (id);


--
-- TOC entry 3831 (class 2606 OID 29256)
-- Name: request_client request_client_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.request_client
    ADD CONSTRAINT request_client_pkey PRIMARY KEY (req_id);


--
-- TOC entry 3835 (class 2606 OID 29263)
-- Name: request_client_tour_service request_client_tour_service_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.request_client_tour_service
    ADD CONSTRAINT request_client_tour_service_pkey PRIMARY KEY (req_id, service_public_id, sub_req_id, tier_public_id);


--
-- TOC entry 3837 (class 2606 OID 29270)
-- Name: request_notif request_notif_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.request_notif
    ADD CONSTRAINT request_notif_pkey PRIMARY KEY (id);


--
-- TOC entry 3839 (class 2606 OID 29283)
-- Name: response_facility_tier response_facility_tier_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.response_facility_tier
    ADD CONSTRAINT response_facility_tier_pkey PRIMARY KEY (id, req_public_id, tier_public_id);


--
-- TOC entry 3841 (class 2606 OID 29290)
-- Name: response_tour_service response_tour_service_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.response_tour_service
    ADD CONSTRAINT response_tour_service_pkey PRIMARY KEY (id, req_id, service_public_id, sub_req_id, tier_public_id);


--
-- TOC entry 3843 (class 2606 OID 29297)
-- Name: room_type_style room_type_style_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.room_type_style
    ADD CONSTRAINT room_type_style_pkey PRIMARY KEY (id, req_id, sub_req_id);


--
-- TOC entry 3845 (class 2606 OID 29304)
-- Name: sub_request_client sub_request_client_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sub_request_client
    ADD CONSTRAINT sub_request_client_pkey PRIMARY KEY (req_id, sub_req_id);


--
-- TOC entry 3833 (class 2606 OID 29306)
-- Name: request_client uk_16eid32es3hrr70okdobcbjlm; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.request_client
    ADD CONSTRAINT uk_16eid32es3hrr70okdobcbjlm UNIQUE (public_id);


--
-- TOC entry 3846 (class 2606 OID 29308)
-- Name: jhi_persistent_audit_evt_data fk2ehnyx2si4tjd2nt4q7y40v8m; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.jhi_persistent_audit_evt_data
    ADD CONSTRAINT fk2ehnyx2si4tjd2nt4q7y40v8m FOREIGN KEY (event_id) REFERENCES public.jhi_persistent_audit_event(event_id);


--
-- TOC entry 3847 (class 2606 OID 29313)
-- Name: request_client_tour_service fk36jfaqhtvmpynye3ffslvyk0d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.request_client_tour_service
    ADD CONSTRAINT fk36jfaqhtvmpynye3ffslvyk0d FOREIGN KEY (req_id, sub_req_id) REFERENCES public.sub_request_client(req_id, sub_req_id);


--
-- TOC entry 3849 (class 2606 OID 29323)
-- Name: request_facility fk3ijji0b40oxirt3dd4dafcoeo; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.request_facility
    ADD CONSTRAINT fk3ijji0b40oxirt3dd4dafcoeo FOREIGN KEY (req_id) REFERENCES public.request_client(req_id);


--
-- TOC entry 3851 (class 2606 OID 29333)
-- Name: response_tour_service fkatirfj3fkgp7n3f97127udmhw; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.response_tour_service
    ADD CONSTRAINT fkatirfj3fkgp7n3f97127udmhw FOREIGN KEY (req_id, sub_req_id) REFERENCES public.sub_request_client(req_id, sub_req_id);


--
-- TOC entry 3850 (class 2606 OID 29328)
-- Name: response_facility_tier fkgki74vpv8gjeb4uwsttaru9dx; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.response_facility_tier
    ADD CONSTRAINT fkgki74vpv8gjeb4uwsttaru9dx FOREIGN KEY (req_public_id) REFERENCES public.request_client(public_id);


--
-- TOC entry 3853 (class 2606 OID 29343)
-- Name: sub_request_client fki3w7t8ohdy8pf8lydrxbii7lw; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sub_request_client
    ADD CONSTRAINT fki3w7t8ohdy8pf8lydrxbii7lw FOREIGN KEY (req_public_id) REFERENCES public.request_client(public_id);


--
-- TOC entry 3852 (class 2606 OID 29338)
-- Name: room_type_style fkm3mtunep984456hb3aa9eqpsr; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.room_type_style
    ADD CONSTRAINT fkm3mtunep984456hb3aa9eqpsr FOREIGN KEY (req_id, sub_req_id) REFERENCES public.sub_request_client(req_id, sub_req_id);


--
-- TOC entry 3848 (class 2606 OID 29318)
-- Name: request_extra_services fkpx42p8k7pr6rmom4w3ui9r6ci; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.request_extra_services
    ADD CONSTRAINT fkpx42p8k7pr6rmom4w3ui9r6ci FOREIGN KEY (req_id) REFERENCES public.request_client(req_id);


-- Completed on 2025-10-03 23:40:57 CEST

--
-- PostgreSQL database dump complete
--

\unrestrict 3oiR2X940MpcVdnGP9XxSLsrCDTLNA5pBQdkPpU6sTsUFTJaZhe5c8k2cLt4j7y


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

--
-- Name: numeric; Type: COLLATION; Schema: public; Owner: -
--

CREATE COLLATION public."numeric" (provider = icu, locale = 'en-u-kn');


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: active_storage_attachments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_storage_attachments (
    id bigint NOT NULL,
    name character varying NOT NULL,
    record_type character varying NOT NULL,
    record_id bigint NOT NULL,
    blob_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL
);


--
-- Name: active_storage_attachments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.active_storage_attachments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_storage_attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.active_storage_attachments_id_seq OWNED BY public.active_storage_attachments.id;


--
-- Name: active_storage_blobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_storage_blobs (
    id bigint NOT NULL,
    key character varying NOT NULL,
    filename character varying NOT NULL,
    content_type character varying,
    metadata text,
    service_name character varying NOT NULL,
    byte_size bigint NOT NULL,
    checksum character varying,
    created_at timestamp(6) without time zone NOT NULL
);


--
-- Name: active_storage_blobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.active_storage_blobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_storage_blobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.active_storage_blobs_id_seq OWNED BY public.active_storage_blobs.id;


--
-- Name: active_storage_variant_records; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_storage_variant_records (
    id bigint NOT NULL,
    blob_id bigint NOT NULL,
    variation_digest character varying NOT NULL
);


--
-- Name: active_storage_variant_records_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.active_storage_variant_records_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_storage_variant_records_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.active_storage_variant_records_id_seq OWNED BY public.active_storage_variant_records.id;


--
-- Name: affiliations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.affiliations (
    id bigint NOT NULL,
    contributor_id bigint,
    institution character varying NOT NULL,
    uri character varying NOT NULL,
    department character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: affiliations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.affiliations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: affiliations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.affiliations_id_seq OWNED BY public.affiliations.id;


--
-- Name: ahoy_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ahoy_events (
    id bigint NOT NULL,
    visit_id bigint,
    user_id bigint,
    name character varying,
    properties jsonb,
    "time" timestamp(6) without time zone
);


--
-- Name: ahoy_events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ahoy_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ahoy_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ahoy_events_id_seq OWNED BY public.ahoy_events.id;


--
-- Name: ahoy_visits; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ahoy_visits (
    id bigint NOT NULL,
    visit_token character varying,
    visitor_token character varying,
    user_id bigint,
    ip character varying,
    user_agent text,
    referrer text,
    referring_domain character varying,
    landing_page text,
    browser character varying,
    os character varying,
    device_type character varying,
    country character varying,
    region character varying,
    city character varying,
    latitude double precision,
    longitude double precision,
    utm_source character varying,
    utm_medium character varying,
    utm_term character varying,
    utm_content character varying,
    utm_campaign character varying,
    app_version character varying,
    os_version character varying,
    platform character varying,
    started_at timestamp(6) without time zone
);


--
-- Name: ahoy_visits_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ahoy_visits_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ahoy_visits_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ahoy_visits_id_seq OWNED BY public.ahoy_visits.id;


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: collection_depositors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.collection_depositors (
    collection_id bigint NOT NULL,
    user_id bigint NOT NULL
);


--
-- Name: collection_managers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.collection_managers (
    collection_id bigint NOT NULL,
    user_id bigint NOT NULL
);


--
-- Name: collection_reviewers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.collection_reviewers (
    collection_id bigint NOT NULL,
    user_id bigint NOT NULL
);


--
-- Name: collections; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.collections (
    id bigint NOT NULL,
    druid character varying,
    title character varying NOT NULL,
    user_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    object_updated_at timestamp(6) without time zone,
    release_option character varying,
    release_duration character varying,
    access character varying,
    doi_option character varying DEFAULT 'yes'::character varying,
    license_option character varying DEFAULT 'required'::character varying NOT NULL,
    license character varying,
    custom_rights_statement_option character varying,
    provided_custom_rights_statement character varying,
    custom_rights_statement_instructions character varying,
    email_when_participants_changed boolean DEFAULT true NOT NULL,
    email_depositors_status_changed boolean DEFAULT true NOT NULL,
    review_enabled boolean DEFAULT false NOT NULL,
    deposit_state character varying DEFAULT 'deposit_not_in_progress'::character varying NOT NULL,
    version integer DEFAULT 1 NOT NULL,
    work_type character varying,
    work_subtypes character varying[] DEFAULT '{}'::character varying[],
    works_contact_email character varying,
    github_deposit_enabled boolean DEFAULT false NOT NULL,
    article_deposit_enabled boolean DEFAULT false NOT NULL
);


--
-- Name: collections_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.collections_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: collections_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.collections_id_seq OWNED BY public.collections.id;


--
-- Name: content_files; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.content_files (
    id bigint NOT NULL,
    file_type character varying NOT NULL,
    filepath character varying NOT NULL,
    label character varying NOT NULL,
    external_identifier character varying,
    fileset_external_identifier character varying,
    size bigint,
    mime_type character varying,
    md5_digest character varying,
    sha1_digest character varying,
    content_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    hide boolean DEFAULT false NOT NULL,
    path_parts character varying[],
    basename character varying,
    extname character varying,
    new boolean DEFAULT false
);


--
-- Name: content_files_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.content_files_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: content_files_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.content_files_id_seq OWNED BY public.content_files.id;


--
-- Name: contents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.contents (
    id bigint NOT NULL,
    user_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    globus_state character varying DEFAULT 'globus_not_in_progress'::character varying,
    work_id bigint
);


--
-- Name: contents_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.contents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: contents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.contents_id_seq OWNED BY public.contents.id;


--
-- Name: contributors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.contributors (
    id bigint NOT NULL,
    collection_id bigint,
    first_name character varying,
    last_name character varying,
    organization_name character varying,
    role character varying,
    role_type character varying,
    suborganization_name character varying,
    orcid character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: contributors_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.contributors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: contributors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.contributors_id_seq OWNED BY public.contributors.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: shares; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.shares (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    work_id bigint NOT NULL,
    permission character varying DEFAULT 'view'::character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: shares_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.shares_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: shares_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.shares_id_seq OWNED BY public.shares.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    email_address character varying NOT NULL,
    name character varying NOT NULL,
    first_name character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    agreed_to_terms_at timestamp(6) without time zone,
    terms_reminder_email_last_sent_at timestamp(6) without time zone,
    github_access_token character varying,
    github_uid character varying,
    github_nickname character varying,
    github_connected_at timestamp(6) without time zone,
    github_updated_at timestamp(6) without time zone
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: works; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.works (
    id bigint NOT NULL,
    druid character varying,
    title character varying NOT NULL,
    user_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    collection_id bigint NOT NULL,
    object_updated_at timestamp(6) without time zone,
    doi_assigned boolean DEFAULT false NOT NULL,
    review_state character varying DEFAULT 'review_not_in_progress'::character varying NOT NULL,
    review_rejected_reason character varying,
    deposit_state character varying DEFAULT 'deposit_not_in_progress'::character varying NOT NULL,
    version integer DEFAULT 1 NOT NULL,
    last_deposited_at timestamp(6) without time zone,
    type character varying DEFAULT 'Work'::character varying NOT NULL,
    github_repository_id bigint,
    github_repository_name character varying,
    github_deposit_enabled boolean DEFAULT false NOT NULL
);


--
-- Name: works_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.works_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: works_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.works_id_seq OWNED BY public.works.id;


--
-- Name: active_storage_attachments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_attachments ALTER COLUMN id SET DEFAULT nextval('public.active_storage_attachments_id_seq'::regclass);


--
-- Name: active_storage_blobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_blobs ALTER COLUMN id SET DEFAULT nextval('public.active_storage_blobs_id_seq'::regclass);


--
-- Name: active_storage_variant_records id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_variant_records ALTER COLUMN id SET DEFAULT nextval('public.active_storage_variant_records_id_seq'::regclass);


--
-- Name: affiliations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.affiliations ALTER COLUMN id SET DEFAULT nextval('public.affiliations_id_seq'::regclass);


--
-- Name: ahoy_events id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ahoy_events ALTER COLUMN id SET DEFAULT nextval('public.ahoy_events_id_seq'::regclass);


--
-- Name: ahoy_visits id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ahoy_visits ALTER COLUMN id SET DEFAULT nextval('public.ahoy_visits_id_seq'::regclass);


--
-- Name: collections id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collections ALTER COLUMN id SET DEFAULT nextval('public.collections_id_seq'::regclass);


--
-- Name: content_files id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_files ALTER COLUMN id SET DEFAULT nextval('public.content_files_id_seq'::regclass);


--
-- Name: contents id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contents ALTER COLUMN id SET DEFAULT nextval('public.contents_id_seq'::regclass);


--
-- Name: contributors id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contributors ALTER COLUMN id SET DEFAULT nextval('public.contributors_id_seq'::regclass);


--
-- Name: shares id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shares ALTER COLUMN id SET DEFAULT nextval('public.shares_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: works id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.works ALTER COLUMN id SET DEFAULT nextval('public.works_id_seq'::regclass);


--
-- Name: active_storage_attachments active_storage_attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_attachments
    ADD CONSTRAINT active_storage_attachments_pkey PRIMARY KEY (id);


--
-- Name: active_storage_blobs active_storage_blobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_blobs
    ADD CONSTRAINT active_storage_blobs_pkey PRIMARY KEY (id);


--
-- Name: active_storage_variant_records active_storage_variant_records_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_variant_records
    ADD CONSTRAINT active_storage_variant_records_pkey PRIMARY KEY (id);


--
-- Name: affiliations affiliations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.affiliations
    ADD CONSTRAINT affiliations_pkey PRIMARY KEY (id);


--
-- Name: ahoy_events ahoy_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ahoy_events
    ADD CONSTRAINT ahoy_events_pkey PRIMARY KEY (id);


--
-- Name: ahoy_visits ahoy_visits_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ahoy_visits
    ADD CONSTRAINT ahoy_visits_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: collections collections_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collections
    ADD CONSTRAINT collections_pkey PRIMARY KEY (id);


--
-- Name: content_files content_files_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_files
    ADD CONSTRAINT content_files_pkey PRIMARY KEY (id);


--
-- Name: contents contents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contents
    ADD CONSTRAINT contents_pkey PRIMARY KEY (id);


--
-- Name: contributors contributors_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contributors
    ADD CONSTRAINT contributors_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: shares shares_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shares
    ADD CONSTRAINT shares_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: works works_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.works
    ADD CONSTRAINT works_pkey PRIMARY KEY (id);


--
-- Name: index_active_storage_attachments_on_blob_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_active_storage_attachments_on_blob_id ON public.active_storage_attachments USING btree (blob_id);


--
-- Name: index_active_storage_attachments_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_active_storage_attachments_uniqueness ON public.active_storage_attachments USING btree (record_type, record_id, name, blob_id);


--
-- Name: index_active_storage_blobs_on_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_active_storage_blobs_on_key ON public.active_storage_blobs USING btree (key);


--
-- Name: index_active_storage_variant_records_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_active_storage_variant_records_uniqueness ON public.active_storage_variant_records USING btree (blob_id, variation_digest);


--
-- Name: index_affiliations_on_contributor_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_affiliations_on_contributor_id ON public.affiliations USING btree (contributor_id);


--
-- Name: index_ahoy_events_on_name_and_time; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ahoy_events_on_name_and_time ON public.ahoy_events USING btree (name, "time");


--
-- Name: index_ahoy_events_on_properties; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ahoy_events_on_properties ON public.ahoy_events USING gin (properties jsonb_path_ops);


--
-- Name: index_ahoy_events_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ahoy_events_on_user_id ON public.ahoy_events USING btree (user_id);


--
-- Name: index_ahoy_events_on_visit_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ahoy_events_on_visit_id ON public.ahoy_events USING btree (visit_id);


--
-- Name: index_ahoy_visits_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ahoy_visits_on_user_id ON public.ahoy_visits USING btree (user_id);


--
-- Name: index_ahoy_visits_on_visit_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_ahoy_visits_on_visit_token ON public.ahoy_visits USING btree (visit_token);


--
-- Name: index_ahoy_visits_on_visitor_token_and_started_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ahoy_visits_on_visitor_token_and_started_at ON public.ahoy_visits USING btree (visitor_token, started_at);


--
-- Name: index_collection_depositors_on_collection_id_and_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_collection_depositors_on_collection_id_and_user_id ON public.collection_depositors USING btree (collection_id, user_id);


--
-- Name: index_collection_managers_on_collection_id_and_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_collection_managers_on_collection_id_and_user_id ON public.collection_managers USING btree (collection_id, user_id);


--
-- Name: index_collection_reviewers_on_collection_id_and_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_collection_reviewers_on_collection_id_and_user_id ON public.collection_reviewers USING btree (collection_id, user_id);


--
-- Name: index_collections_on_deposit_state; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_collections_on_deposit_state ON public.collections USING btree (deposit_state);


--
-- Name: index_collections_on_druid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_collections_on_druid ON public.collections USING btree (druid);


--
-- Name: index_collections_on_object_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_collections_on_object_updated_at ON public.collections USING btree (object_updated_at);


--
-- Name: index_collections_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_collections_on_user_id ON public.collections USING btree (user_id);


--
-- Name: index_content_files_on_content_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_content_files_on_content_id ON public.content_files USING btree (content_id);


--
-- Name: index_content_files_on_content_id_and_filepath; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_content_files_on_content_id_and_filepath ON public.content_files USING btree (content_id, filepath);


--
-- Name: index_contents_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_contents_on_user_id ON public.contents USING btree (user_id);


--
-- Name: index_contents_on_work_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_contents_on_work_id ON public.contents USING btree (work_id);


--
-- Name: index_contributors_on_collection_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_contributors_on_collection_id ON public.contributors USING btree (collection_id);


--
-- Name: index_shares_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_shares_on_user_id ON public.shares USING btree (user_id);


--
-- Name: index_shares_on_work_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_shares_on_work_id ON public.shares USING btree (work_id);


--
-- Name: index_users_on_email_address; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email_address ON public.users USING btree (email_address);


--
-- Name: index_users_on_github_uid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_github_uid ON public.users USING btree (github_uid);


--
-- Name: index_works_on_collection_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_works_on_collection_id ON public.works USING btree (collection_id);


--
-- Name: index_works_on_deposit_state; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_works_on_deposit_state ON public.works USING btree (deposit_state);


--
-- Name: index_works_on_druid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_works_on_druid ON public.works USING btree (druid);


--
-- Name: index_works_on_github_deposit_enabled; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_works_on_github_deposit_enabled ON public.works USING btree (github_deposit_enabled);


--
-- Name: index_works_on_object_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_works_on_object_updated_at ON public.works USING btree (object_updated_at);


--
-- Name: index_works_on_review_state; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_works_on_review_state ON public.works USING btree (review_state);


--
-- Name: index_works_on_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_works_on_type ON public.works USING btree (type);


--
-- Name: index_works_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_works_on_user_id ON public.works USING btree (user_id);


--
-- Name: contents fk_rails_24593c7092; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contents
    ADD CONSTRAINT fk_rails_24593c7092 FOREIGN KEY (work_id) REFERENCES public.works(id);


--
-- Name: content_files fk_rails_28017e8654; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_files
    ADD CONSTRAINT fk_rails_28017e8654 FOREIGN KEY (content_id) REFERENCES public.contents(id);


--
-- Name: works fk_rails_2d4237af37; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.works
    ADD CONSTRAINT fk_rails_2d4237af37 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: contributors fk_rails_429a90613a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contributors
    ADD CONSTRAINT fk_rails_429a90613a FOREIGN KEY (collection_id) REFERENCES public.collections(id);


--
-- Name: works fk_rails_7ea9207fbe; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.works
    ADD CONSTRAINT fk_rails_7ea9207fbe FOREIGN KEY (collection_id) REFERENCES public.collections(id);


--
-- Name: contents fk_rails_854287fee7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contents
    ADD CONSTRAINT fk_rails_854287fee7 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: shares fk_rails_90b9094a57; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shares
    ADD CONSTRAINT fk_rails_90b9094a57 FOREIGN KEY (work_id) REFERENCES public.works(id);


--
-- Name: active_storage_variant_records fk_rails_993965df05; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_variant_records
    ADD CONSTRAINT fk_rails_993965df05 FOREIGN KEY (blob_id) REFERENCES public.active_storage_blobs(id);


--
-- Name: collections fk_rails_9b33697360; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collections
    ADD CONSTRAINT fk_rails_9b33697360 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: active_storage_attachments fk_rails_c3b3935057; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_attachments
    ADD CONSTRAINT fk_rails_c3b3935057 FOREIGN KEY (blob_id) REFERENCES public.active_storage_blobs(id);


--
-- Name: shares fk_rails_d671d25093; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shares
    ADD CONSTRAINT fk_rails_d671d25093 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: affiliations fk_rails_e75af2882e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.affiliations
    ADD CONSTRAINT fk_rails_e75af2882e FOREIGN KEY (contributor_id) REFERENCES public.contributors(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20260209140935'),
('20260205132650'),
('20260204215055'),
('20260204142423'),
('20250723233849'),
('20250630163537'),
('20250619163206'),
('20250616125424'),
('20250610120209'),
('20250604121142'),
('20250527121840'),
('20250509151132'),
('20250318195336'),
('20250313174420'),
('20250313120842'),
('20250310201020'),
('20250226213052'),
('20250224190134'),
('20250220231211'),
('20250123195702'),
('20250123120038'),
('20250122145633'),
('20250122135332'),
('20250121174735'),
('20250120142833'),
('20250116173206'),
('20250114195340'),
('20250108112958'),
('20250107153556'),
('20250106212515'),
('20241211213303'),
('20241206021849'),
('20241205222413'),
('20241205212622'),
('20241205013747'),
('20241125181104'),
('20241122204826'),
('20241121122120'),
('20241120134012'),
('20241120133926'),
('20241115001146'),
('20241115001126'),
('20241111223829'),
('20241106143736');


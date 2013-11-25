--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: access; Type: TABLE; Schema: public; Owner: c370_s19; Tablespace: 
--

CREATE TABLE access (
    accountid integer NOT NULL,
    supporterid integer NOT NULL
);


ALTER TABLE public.access OWNER TO c370_s19;

--
-- Name: account; Type: TABLE; Schema: public; Owner: c370_s19; Tablespace: 
--

CREATE TABLE account (
    id integer NOT NULL,
    purpose character varying(60),
    bank character varying(60)
);


ALTER TABLE public.account OWNER TO c370_s19;

--
-- Name: campaign; Type: TABLE; Schema: public; Owner: c370_s19; Tablespace: 
--

CREATE TABLE campaign (
    title character varying(40) NOT NULL,
    slogan character varying(60) DEFAULT ''::character varying,
    currentphase integer DEFAULT 1
);


ALTER TABLE public.campaign OWNER TO c370_s19;

--
-- Name: eight; Type: TABLE; Schema: public; Owner: c370_s19; Tablespace: 
--

CREATE TABLE eight (
    name character varying(60),
    phone character varying(20),
    email character varying(60),
    sum bigint
);


ALTER TABLE public.eight OWNER TO c370_s19;

--
-- Name: employee; Type: TABLE; Schema: public; Owner: c370_s19; Tablespace: 
--

CREATE TABLE employee (
    id integer NOT NULL,
    salary integer NOT NULL
);


ALTER TABLE public.employee OWNER TO c370_s19;

--
-- Name: event; Type: TABLE; Schema: public; Owner: c370_s19; Tablespace: 
--

CREATE TABLE event (
    id integer NOT NULL,
    name character varying(40),
    location character varying(60),
    starttimestamp timestamp with time zone,
    endtimestamp timestamp with time zone
);


ALTER TABLE public.event OWNER TO c370_s19;

--
-- Name: expensedonation; Type: TABLE; Schema: public; Owner: c370_s19; Tablespace: 
--

CREATE TABLE expensedonation (
    paymentid integer NOT NULL,
    campaigntitle character varying(40) NOT NULL
);


ALTER TABLE public.expensedonation OWNER TO c370_s19;

--
-- Name: organizes; Type: TABLE; Schema: public; Owner: c370_s19; Tablespace: 
--

CREATE TABLE organizes (
    supporterid integer NOT NULL,
    campaigntitle character varying(40) NOT NULL
);


ALTER TABLE public.organizes OWNER TO c370_s19;

--
-- Name: supporter; Type: TABLE; Schema: public; Owner: c370_s19; Tablespace: 
--

CREATE TABLE supporter (
    id integer NOT NULL,
    phone character varying(20),
    email character varying(60),
    name character varying(60),
    title character varying(60)
);


ALTER TABLE public.supporter OWNER TO c370_s19;

--
-- Name: five; Type: VIEW; Schema: public; Owner: c370_s19
--

CREATE VIEW five AS
    SELECT supporter.name, supporter.phone, supporter.email, supporter.title, organizes.campaigntitle FROM (supporter JOIN organizes ON ((supporter.id = organizes.supporterid)));


ALTER TABLE public.five OWNER TO c370_s19;

--
-- Name: participatedin; Type: TABLE; Schema: public; Owner: c370_s19; Tablespace: 
--

CREATE TABLE participatedin (
    supporterid integer NOT NULL,
    eventid integer NOT NULL
);


ALTER TABLE public.participatedin OWNER TO c370_s19;

--
-- Name: four; Type: VIEW; Schema: public; Owner: c370_s19
--

CREATE VIEW four AS
    SELECT supporter.name, supporter.phone, supporter.email FROM supporter supporter WHERE (NOT (EXISTS (SELECT participatedin.supporterid, participatedin.eventid FROM participatedin WHERE (supporter.id = participatedin.supporterid))));


ALTER TABLE public.four OWNER TO c370_s19;

--
-- Name: fundingstream; Type: TABLE; Schema: public; Owner: c370_s19; Tablespace: 
--

CREATE TABLE fundingstream (
    accountid integer NOT NULL,
    title character varying(60) NOT NULL
);


ALTER TABLE public.fundingstream OWNER TO c370_s19;

--
-- Name: payment; Type: TABLE; Schema: public; Owner: c370_s19; Tablespace: 
--

CREATE TABLE payment (
    id integer NOT NULL,
    accountid integer,
    amount integer,
    datetime timestamp with time zone,
    description character varying(120)
);


ALTER TABLE public.payment OWNER TO c370_s19;

--
-- Name: reimbursementdonation; Type: TABLE; Schema: public; Owner: c370_s19; Tablespace: 
--

CREATE TABLE reimbursementdonation (
    paymentid integer NOT NULL,
    supporterid integer NOT NULL
);


ALTER TABLE public.reimbursementdonation OWNER TO c370_s19;

--
-- Name: nine; Type: VIEW; Schema: public; Owner: c370_s19
--

CREATE VIEW nine AS
    SELECT supporter.name, supporter.id AS supporterid, payment.amount, payment.id AS paymentid, account.id AS accountid, account.purpose, payment.description FROM (((payment JOIN reimbursementdonation ON ((reimbursementdonation.paymentid = payment.id))) JOIN supporter ON ((reimbursementdonation.supporterid = supporter.id))) JOIN account ON ((payment.accountid = account.id))) WHERE (payment.amount <= 0) ORDER BY supporter.name;


ALTER TABLE public.nine OWNER TO c370_s19;

--
-- Name: one; Type: TABLE; Schema: public; Owner: c370_s19; Tablespace: 
--

CREATE TABLE one (
    id integer,
    purpose character varying(60),
    bank character varying(60),
    balance bigint
);


ALTER TABLE public.one OWNER TO c370_s19;

--
-- Name: partof; Type: TABLE; Schema: public; Owner: c370_s19; Tablespace: 
--

CREATE TABLE partof (
    eventid integer NOT NULL,
    title character varying(60) NOT NULL,
    phasenumber integer NOT NULL
);


ALTER TABLE public.partof OWNER TO c370_s19;

--
-- Name: phase; Type: TABLE; Schema: public; Owner: c370_s19; Tablespace: 
--

CREATE TABLE phase (
    phasenumber integer NOT NULL,
    campaigntitle character varying(40) NOT NULL,
    goal character varying(80),
    starttimestamp timestamp with time zone,
    endtimestamp timestamp with time zone
);


ALTER TABLE public.phase OWNER TO c370_s19;

--
-- Name: seven; Type: VIEW; Schema: public; Owner: c370_s19
--

CREATE VIEW seven AS
    SELECT event.id AS eventid, partof.title, event.name, partof.phasenumber FROM (event JOIN partof ON ((event.id = partof.eventid))) ORDER BY partof.title;


ALTER TABLE public.seven OWNER TO c370_s19;

--
-- Name: six; Type: TABLE; Schema: public; Owner: c370_s19; Tablespace: 
--

CREATE TABLE six (
    name character varying(60),
    phone character varying(20),
    email character varying(60),
    title character varying(60),
    count bigint
);


ALTER TABLE public.six OWNER TO c370_s19;

--
-- Name: ten; Type: VIEW; Schema: public; Owner: c370_s19
--

CREATE VIEW ten AS
    SELECT campaign.title, account.id AS accountid, account.purpose, payment.amount, payment.id AS paymentid, payment.description FROM (((campaign JOIN fundingstream ON (((campaign.title)::text = (fundingstream.title)::text))) JOIN account ON ((account.id = fundingstream.accountid))) JOIN payment ON ((payment.accountid = account.id))) ORDER BY campaign.title;


ALTER TABLE public.ten OWNER TO c370_s19;

--
-- Name: three; Type: TABLE; Schema: public; Owner: c370_s19; Tablespace: 
--

CREATE TABLE three (
    name character varying(60),
    phone character varying(20),
    email character varying(60),
    title character varying(60),
    numberofevents bigint
);


ALTER TABLE public.three OWNER TO c370_s19;

--
-- Name: two; Type: TABLE; Schema: public; Owner: c370_s19; Tablespace: 
--

CREATE TABLE two (
    name character varying(60),
    phone character varying(20),
    email character varying(60),
    title character varying(60),
    numberofevents bigint
);


ALTER TABLE public.two OWNER TO c370_s19;

--
-- Name: workswith; Type: TABLE; Schema: public; Owner: c370_s19; Tablespace: 
--

CREATE TABLE workswith (
    supporter1 integer NOT NULL,
    supporter2 integer NOT NULL
);


ALTER TABLE public.workswith OWNER TO c370_s19;

--
-- Data for Name: access; Type: TABLE DATA; Schema: public; Owner: c370_s19
--

COPY access (accountid, supporterid) FROM stdin;
4	8
5	9
6	10
4	7
5	7
6	7
3	7
2	7
1	7
4	6
5	6
6	6
3	6
2	6
1	6
4	5
5	5
6	5
3	5
2	5
1	5
\.


--
-- Data for Name: account; Type: TABLE DATA; Schema: public; Owner: c370_s19
--

COPY account (id, purpose, bank) FROM stdin;
1	General Operations	Vancity
2	Payroll	Vancity
3	Media and Materials	Vancity
4	Global Warming Campaign	Vancity
5	Northern Gateway Campaign	Coast Capital
6	Keystone Campaign	Coast Capital
\.


--
-- Data for Name: campaign; Type: TABLE DATA; Schema: public; Owner: c370_s19
--

COPY campaign (title, slogan, currentphase) FROM stdin;
Global Warming	Don't leave the oven on!	1
Northern Gateway	Don't kill the whales yet	2
Keystone	Environment before profits!	2
\.


--
-- Data for Name: employee; Type: TABLE DATA; Schema: public; Owner: c370_s19
--

COPY employee (id, salary) FROM stdin;
5	500
6	500
7	1000
\.


--
-- Data for Name: event; Type: TABLE DATA; Schema: public; Owner: c370_s19
--

COPY event (id, name, location, starttimestamp, endtimestamp) FROM stdin;
1	Gala Opening Dinner	Victoria Convention Center	2013-10-05 18:00:00-07	2013-10-05 21:00:00-07
2	Legislature Protest	BC Legislature Protest	2013-10-10 13:00:00-07	2013-10-10 03:00:00-07
3	Street Canvasing	Downtown Victoria, meet at Bay Center	2013-10-15 12:00:00-07	2013-10-15 15:00:00-07
4	Rally Against Gas Companies	Centennial Square	2013-10-20 12:00:00-07	2013-10-20 15:00:00-07
5	Closing Gala Dinner	October 31 17:00:00 2013 PST	2013-10-31 21:00:00-07	\N
6	Gala Opening Dinner	Victoria Convention Center	2013-10-06 18:00:00-07	2013-10-06 21:00:00-07
7	Legislature Protest	BC Legislature Protest	2013-10-11 13:00:00-07	2013-10-11 03:00:00-07
8	Street Canvasing	Downtown Victoria, meet at Bay Center	2013-10-14 12:00:00-07	2013-10-14 15:00:00-07
9	Rally Against Enbridge	Centennial Square	2013-10-21 12:00:00-07	2013-10-21 15:00:00-07
10	Closing Gala Dinner	October 30 17:00:00 2013 PST	2013-10-30 21:00:00-07	\N
11	Gala Opening Dinner	Victoria Convention Center	2013-10-16 18:00:00-07	2013-10-16 21:00:00-07
12	Legislature Protest	BC Legislature Protest	2013-10-17 13:00:00-07	2013-10-17 03:00:00-07
13	Street Canvasing	Downtown Victoria, meet at Bay Center	2013-11-02 12:00:00-07	2013-11-02 15:00:00-07
14	Rally Against Enbridge	Centennial Square	2013-11-05 11:00:00-08	2013-11-05 14:00:00-08
15	Closing Gala Dinner	November 30 17:00:00 2013 PST	2013-11-30 20:00:00-08	\N
\.


--
-- Data for Name: expensedonation; Type: TABLE DATA; Schema: public; Owner: c370_s19
--

COPY expensedonation (paymentid, campaigntitle) FROM stdin;
1	Global Warming
2	Global Warming
22	Global Warming
23	Global Warming
3	Northern Gateway
4	Northern Gateway
5	Northern Gateway
6	Northern Gateway
24	Keystone
25	Keystone
26	Keystone
27	Keystone
\.


--
-- Data for Name: fundingstream; Type: TABLE DATA; Schema: public; Owner: c370_s19
--

COPY fundingstream (accountid, title) FROM stdin;
4	Global Warming
5	Northern Gateway
6	Keystone
\.


--
-- Data for Name: organizes; Type: TABLE DATA; Schema: public; Owner: c370_s19
--

COPY organizes (supporterid, campaigntitle) FROM stdin;
8	Global Warming
9	Northern Gateway
10	Keystone
\.


--
-- Data for Name: participatedin; Type: TABLE DATA; Schema: public; Owner: c370_s19
--

COPY participatedin (supporterid, eventid) FROM stdin;
7	1
7	2
7	3
7	4
7	5
7	6
7	7
7	8
7	9
7	10
7	11
7	12
7	13
7	14
7	15
5	1
5	2
5	3
5	4
5	5
5	6
5	7
5	8
5	9
5	10
5	11
5	12
5	13
5	14
5	15
6	1
6	2
6	3
6	4
6	5
6	6
6	7
6	8
6	9
6	10
6	11
6	12
6	13
6	14
6	15
8	1
8	2
8	3
8	4
8	5
9	6
9	7
9	8
9	9
9	10
10	11
10	12
10	13
10	14
10	15
1	1
1	5
1	6
1	10
2	1
2	5
\.


--
-- Data for Name: partof; Type: TABLE DATA; Schema: public; Owner: c370_s19
--

COPY partof (eventid, title, phasenumber) FROM stdin;
1	Global Warming	1
2	Global Warming	1
3	Global Warming	1
4	Global Warming	2
5	Global Warming	2
6	Northern Gateway	1
7	Northern Gateway	1
8	Northern Gateway	1
9	Northern Gateway	2
10	Northern Gateway	2
11	Keystone	1
12	Keystone	1
13	Keystone	2
14	Keystone	2
15	Keystone	2
\.


--
-- Data for Name: payment; Type: TABLE DATA; Schema: public; Owner: c370_s19
--

COPY payment (id, accountid, amount, datetime, description) FROM stdin;
1	4	5000	2013-10-05 11:00:00-07	Donation fron Wilfred Wolf
2	4	-250	2013-10-14 18:00:00-07	Printing costs
22	4	9000	2013-10-14 18:00:00-07	Donation from Betty Bear
23	4	-950	2013-10-14 18:00:00-07	Rally costs
3	5	2000	2013-10-10 14:00:00-07	Donation from Val Volpix
4	5	-350	2013-10-14 14:00:00-07	Printing costs
5	5	-350	2013-10-19 14:00:00-07	Printing costs
6	5	5000	2013-10-30 17:00:00-07	Donation from Betty Bear
24	6	2000	2013-10-20 14:00:00-07	Donation from Wally Wolf
25	6	-350	2013-10-25 14:00:00-07	Printing costs
26	6	-350	2013-11-13 13:00:00-08	Printing costs
27	6	5000	2013-11-15 16:00:00-08	Donation from Val Volpix
7	1	500	2013-10-01 10:00:00-07	Administration costs
8	1	-100	2013-10-01 10:00:01-07	Telephone & Internet Fees
9	1	-100	2013-10-01 10:00:01-07	Web hosting fees
10	1	-200	2013-10-01 10:00:01-07	Strata Fees
11	1	-100	2013-10-01 10:00:01-07	Printer contract with Xerox.
12	2	2000	2013-10-01 10:00:00-07	Salary Deposit.
13	2	-500	2013-10-01 10:00:01-07	Salary for Olly Octopus.
14	2	-500	2013-10-01 10:00:01-07	Salary for Sarah Skunk
15	2	-1000	2013-10-01 10:00:01-07	Salary for Crazy CEO Cat
16	2	2000	2013-10-15 10:00:00-07	Salary Deposit.
17	2	-500	2013-10-14 10:00:01-07	Salary for Olly Octopus.
18	2	-500	2013-10-15 10:00:01-07	Salary for Sarah Skunk
19	2	-1000	2013-10-15 10:00:01-07	Salary for Crazy CEO Cat
20	3	100	2013-10-02 10:00:00-07	Initial Deposit for general printing funds.
21	3	-22	2013-10-15 11:30:00-07	Costs for printing a few posters
\.


--
-- Data for Name: phase; Type: TABLE DATA; Schema: public; Owner: c370_s19
--

COPY phase (phasenumber, campaigntitle, goal, starttimestamp, endtimestamp) FROM stdin;
1	Global Warming	Spread the word about Global Warming.	2013-10-05 10:00:00-07	2013-10-15 21:00:00-07
2	Global Warming	Promote government attention to the topic.	2013-10-16 10:00:00-07	2013-10-31 21:00:00-07
1	Northern Gateway	It's not worth it, block the pipeline!	2013-10-05 10:00:00-07	2013-10-15 21:00:00-07
2	Northern Gateway	Hold a rally to show our concerns.	2013-10-16 10:00:00-07	2013-10-31 21:00:00-07
1	Keystone	It's not worth it, block the pipeline!	2013-10-16 10:00:00-07	2013-10-31 21:00:00-07
2	Keystone	Hold a rally to show our concerns.	2013-11-01 10:00:00-07	2013-11-30 20:00:00-08
\.


--
-- Data for Name: reimbursementdonation; Type: TABLE DATA; Schema: public; Owner: c370_s19
--

COPY reimbursementdonation (paymentid, supporterid) FROM stdin;
1	1
6	2
22	2
3	3
27	3
24	4
4	5
5	6
20	5
21	6
7	7
8	7
9	7
10	7
11	7
\.


--
-- Data for Name: supporter; Type: TABLE DATA; Schema: public; Owner: c370_s19
--

COPY supporter (id, phone, email, name, title) FROM stdin;
1	250-123-12345	Wilfred@wolf.com	Wilfred Wolf	\N
2	250-124-12345	betty@bear.com	Betty Bear	\N
3	250-125-12345	val@volpix.com	Val Volpix	\N
4	250-126-12345	wally@wolf.com	Wally Wolf	\N
5	250-128-12345	olly@octopus.com	Olly Octopus	Chief Fundraiser
6	250-128-12345	sarah@skunk.com	Sarah Skunk	Chief Organizer
7	250-120-12345	crazy@cat.com	Crazy CEO Cat	CEO
8	250-120-2345	peter@porpoise.com	Peter Porpoise	Global Warming Contact
9	250-120-4345	pal@polarbear.com	Pal Polar Bear	Northern Gateway Contact
10	250-120-4348	fella@fox.com	Fella Fox	Keystone Contact
11	250-124-4745	ally@antelope.com	Ally Antelope	\N
12	250-124-4785	buddy@beaver.com	Buddy Beaver	\N
\.


--
-- Data for Name: workswith; Type: TABLE DATA; Schema: public; Owner: c370_s19
--

COPY workswith (supporter1, supporter2) FROM stdin;
5	6
5	7
5	8
5	9
5	10
6	7
6	8
6	9
6	10
\.


--
-- Name: access_pkey; Type: CONSTRAINT; Schema: public; Owner: c370_s19; Tablespace: 
--

ALTER TABLE ONLY access
    ADD CONSTRAINT access_pkey PRIMARY KEY (accountid, supporterid);


--
-- Name: account_pkey; Type: CONSTRAINT; Schema: public; Owner: c370_s19; Tablespace: 
--

ALTER TABLE ONLY account
    ADD CONSTRAINT account_pkey PRIMARY KEY (id);


--
-- Name: campaign_pkey; Type: CONSTRAINT; Schema: public; Owner: c370_s19; Tablespace: 
--

ALTER TABLE ONLY campaign
    ADD CONSTRAINT campaign_pkey PRIMARY KEY (title);


--
-- Name: employee_pkey; Type: CONSTRAINT; Schema: public; Owner: c370_s19; Tablespace: 
--

ALTER TABLE ONLY employee
    ADD CONSTRAINT employee_pkey PRIMARY KEY (id, salary);


--
-- Name: event_pkey; Type: CONSTRAINT; Schema: public; Owner: c370_s19; Tablespace: 
--

ALTER TABLE ONLY event
    ADD CONSTRAINT event_pkey PRIMARY KEY (id);


--
-- Name: expensedonation_pkey; Type: CONSTRAINT; Schema: public; Owner: c370_s19; Tablespace: 
--

ALTER TABLE ONLY expensedonation
    ADD CONSTRAINT expensedonation_pkey PRIMARY KEY (paymentid, campaigntitle);


--
-- Name: fundingstream_pkey; Type: CONSTRAINT; Schema: public; Owner: c370_s19; Tablespace: 
--

ALTER TABLE ONLY fundingstream
    ADD CONSTRAINT fundingstream_pkey PRIMARY KEY (accountid, title);


--
-- Name: organizes_pkey; Type: CONSTRAINT; Schema: public; Owner: c370_s19; Tablespace: 
--

ALTER TABLE ONLY organizes
    ADD CONSTRAINT organizes_pkey PRIMARY KEY (supporterid, campaigntitle);


--
-- Name: participatedin_pkey; Type: CONSTRAINT; Schema: public; Owner: c370_s19; Tablespace: 
--

ALTER TABLE ONLY participatedin
    ADD CONSTRAINT participatedin_pkey PRIMARY KEY (supporterid, eventid);


--
-- Name: partof_pkey; Type: CONSTRAINT; Schema: public; Owner: c370_s19; Tablespace: 
--

ALTER TABLE ONLY partof
    ADD CONSTRAINT partof_pkey PRIMARY KEY (eventid, title, phasenumber);


--
-- Name: payment_pkey; Type: CONSTRAINT; Schema: public; Owner: c370_s19; Tablespace: 
--

ALTER TABLE ONLY payment
    ADD CONSTRAINT payment_pkey PRIMARY KEY (id);


--
-- Name: phase_pkey; Type: CONSTRAINT; Schema: public; Owner: c370_s19; Tablespace: 
--

ALTER TABLE ONLY phase
    ADD CONSTRAINT phase_pkey PRIMARY KEY (phasenumber, campaigntitle);


--
-- Name: reimbursementdonation_pkey; Type: CONSTRAINT; Schema: public; Owner: c370_s19; Tablespace: 
--

ALTER TABLE ONLY reimbursementdonation
    ADD CONSTRAINT reimbursementdonation_pkey PRIMARY KEY (paymentid, supporterid);


--
-- Name: supporter_pkey; Type: CONSTRAINT; Schema: public; Owner: c370_s19; Tablespace: 
--

ALTER TABLE ONLY supporter
    ADD CONSTRAINT supporter_pkey PRIMARY KEY (id);


--
-- Name: workswith_pkey; Type: CONSTRAINT; Schema: public; Owner: c370_s19; Tablespace: 
--

ALTER TABLE ONLY workswith
    ADD CONSTRAINT workswith_pkey PRIMARY KEY (supporter1, supporter2);


--
-- Name: _RETURN; Type: RULE; Schema: public; Owner: c370_s19
--

CREATE RULE "_RETURN" AS ON SELECT TO one DO INSTEAD SELECT account.id, account.purpose, account.bank, sum(payment.amount) AS balance FROM (payment JOIN account ON ((payment.accountid = account.id))) GROUP BY account.id;


--
-- Name: _RETURN; Type: RULE; Schema: public; Owner: c370_s19
--

CREATE RULE "_RETURN" AS ON SELECT TO two DO INSTEAD SELECT supporter.name, supporter.phone, supporter.email, supporter.title, count(participatedin.*) AS numberofevents FROM (supporter JOIN participatedin ON ((supporter.id = participatedin.supporterid))) GROUP BY supporter.id;


--
-- Name: _RETURN; Type: RULE; Schema: public; Owner: c370_s19
--

CREATE RULE "_RETURN" AS ON SELECT TO three DO INSTEAD SELECT query.name, query.phone, query.email, query.title, query.numberofevents FROM (SELECT supporter.name, supporter.phone, supporter.email, supporter.title, count(participatedin.*) AS numberofevents FROM (supporter JOIN participatedin ON ((supporter.id = participatedin.supporterid))) GROUP BY supporter.id) query WHERE (query.numberofevents > 3);


--
-- Name: _RETURN; Type: RULE; Schema: public; Owner: c370_s19
--

CREATE RULE "_RETURN" AS ON SELECT TO six DO INSTEAD SELECT supporter.name, supporter.phone, supporter.email, supporter.title, count(supporter.id) AS count FROM (supporter JOIN workswith ON (((supporter.id = workswith.supporter1) OR (supporter.id = workswith.supporter2)))) GROUP BY supporter.id;


--
-- Name: _RETURN; Type: RULE; Schema: public; Owner: c370_s19
--

CREATE RULE "_RETURN" AS ON SELECT TO eight DO INSTEAD SELECT DISTINCT supporter.name, supporter.phone, supporter.email, sum(payment.amount) AS sum FROM ((reimbursementdonation JOIN payment ON ((reimbursementdonation.paymentid = payment.id))) JOIN supporter ON ((reimbursementdonation.supporterid = supporter.id))) WHERE (payment.amount >= 0) GROUP BY supporter.id;


--
-- Name: access_accountid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: c370_s19
--

ALTER TABLE ONLY access
    ADD CONSTRAINT access_accountid_fkey FOREIGN KEY (accountid) REFERENCES account(id);


--
-- Name: access_supporterid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: c370_s19
--

ALTER TABLE ONLY access
    ADD CONSTRAINT access_supporterid_fkey FOREIGN KEY (supporterid) REFERENCES supporter(id);


--
-- Name: employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: c370_s19
--

ALTER TABLE ONLY employee
    ADD CONSTRAINT employee_id_fkey FOREIGN KEY (id) REFERENCES supporter(id);


--
-- Name: expensedonation_campaigntitle_fkey; Type: FK CONSTRAINT; Schema: public; Owner: c370_s19
--

ALTER TABLE ONLY expensedonation
    ADD CONSTRAINT expensedonation_campaigntitle_fkey FOREIGN KEY (campaigntitle) REFERENCES campaign(title);


--
-- Name: expensedonation_paymentid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: c370_s19
--

ALTER TABLE ONLY expensedonation
    ADD CONSTRAINT expensedonation_paymentid_fkey FOREIGN KEY (paymentid) REFERENCES payment(id);


--
-- Name: fundingstream_accountid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: c370_s19
--

ALTER TABLE ONLY fundingstream
    ADD CONSTRAINT fundingstream_accountid_fkey FOREIGN KEY (accountid) REFERENCES account(id);


--
-- Name: fundingstream_title_fkey; Type: FK CONSTRAINT; Schema: public; Owner: c370_s19
--

ALTER TABLE ONLY fundingstream
    ADD CONSTRAINT fundingstream_title_fkey FOREIGN KEY (title) REFERENCES campaign(title);


--
-- Name: organizes_campaigntitle_fkey; Type: FK CONSTRAINT; Schema: public; Owner: c370_s19
--

ALTER TABLE ONLY organizes
    ADD CONSTRAINT organizes_campaigntitle_fkey FOREIGN KEY (campaigntitle) REFERENCES campaign(title);


--
-- Name: organizes_supporterid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: c370_s19
--

ALTER TABLE ONLY organizes
    ADD CONSTRAINT organizes_supporterid_fkey FOREIGN KEY (supporterid) REFERENCES supporter(id);


--
-- Name: participatedin_eventid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: c370_s19
--

ALTER TABLE ONLY participatedin
    ADD CONSTRAINT participatedin_eventid_fkey FOREIGN KEY (eventid) REFERENCES event(id);


--
-- Name: participatedin_supporterid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: c370_s19
--

ALTER TABLE ONLY participatedin
    ADD CONSTRAINT participatedin_supporterid_fkey FOREIGN KEY (supporterid) REFERENCES supporter(id);


--
-- Name: partof_eventid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: c370_s19
--

ALTER TABLE ONLY partof
    ADD CONSTRAINT partof_eventid_fkey FOREIGN KEY (eventid) REFERENCES event(id);


--
-- Name: partof_title_fkey; Type: FK CONSTRAINT; Schema: public; Owner: c370_s19
-
-- Select all Tables:
-- select table_name from information_schema.tables where table_schema='public' and table_type='BASE TABLE';
drop table organizes, account, employee, supporter, workswith, reimbursementdonation, participatedin, fundingstream, event, payment, partof, expensedonation, access, phase, campaign cascade;

-- Select all Views:
-- select table_name from INFORMATION_SCHEMA.views WHERE table_schema = ANY (current_schemas(false));
drop view one, two, three, four, five, six, seven, eight, nine, ten cascade;

--------------------------------------------
---------------- Tables --------------------
--------------------------------------------
create table Campaign (
  Title           varchar(40),
  Slogan          varchar(60) default '',
  CurrentPhase    int default 1,  -- Ref's to Phase
  annotation      text, -- For A4
  primary key(Title)
);

create table Phase (
  PhaseNumber     int,
  CampaignTitle   varchar(40) references Campaign(Title) ON UPDATE CASCADE,
  Goal            varchar(80),
  StartTimestamp  timestamp with time zone,                          -- Like 'January 8 04:05:06 1999 PST'
  EndTimestamp    timestamp with time zone,
  primary key(PhaseNumber, CampaignTitle)
);

create table Event (
  ID              int,
  name            varchar(40),
  Location        varchar(60),
  StartTimestamp  timestamp with time zone,
  EndTimestamp    timestamp with time zone,
  annotation      text, -- For A4
  primary key(ID)
);

create table PartOf (
  EventID         int         references Event(ID) ON DELETE CASCADE ON UPDATE CASCADE,
  Title           varchar(60) references Campaign(Title) ON DELETE CASCADE ON UPDATE CASCADE,
  PhaseNumber     int,
  primary key(EventID, Title, PhaseNumber)
);

create table Account (
  ID              int,
  Purpose         varchar(60),
  Bank            varchar(60),
  annotation      text, -- For A4
  primary key(ID)
);

create table FundingStream (
  AccountID       int         references Account(ID) ON DELETE CASCADE ON UPDATE CASCADE,
  Title           varchar(60) references Campaign(Title) ON DELETE CASCADE ON UPDATE CASCADE,
  primary key(AccountID, Title)
);

create table Payment (
  ID              int,
  AccountID       int         references Account(ID) ON DELETE CASCADE ON UPDATE CASCADE,
  Amount          int,
  DateTime        timestamp with time zone,
  Description     varchar(120),
  primary key(ID)
);

create table Supporter(
  ID              int,
  Phone           varchar(20),
  Email           varchar(60),
  Name            varchar(60),
  Title           varchar(60),
  annotation      text, -- For A4
  primary key(ID)
);

create table ExpenseDonation (
  PaymentID       int references Payment(ID) ON DELETE CASCADE ON UPDATE CASCADE,
  CampaignTitle   varchar(40) references Campaign(Title) ON DELETE CASCADE ON UPDATE CASCADE,
  primary key(PaymentID, CampaignTitle)
);

create table ReimbursementDonation (
  PaymentID       int references Payment(ID) ON DELETE CASCADE ON UPDATE CASCADE,
  SupporterID     int references Supporter(ID) ON DELETE CASCADE ON UPDATE CASCADE,
  primary key(PaymentID, SupporterID)
);

create table Employee (
  ID              int references Supporter(ID) ON DELETE CASCADE ON UPDATE CASCADE,
  Salary          int,
  primary key(ID, Salary)
);

create table Access (
  AccountID       int references Account(ID) ON DELETE CASCADE ON UPDATE CASCADE,
  SupporterID     int references Supporter(ID) ON DELETE CASCADE ON UPDATE CASCADE,
  primary key(AccountID, SupporterID)
);

create table WorksWith (
  Supporter1      int references Supporter(ID) ON DELETE CASCADE ON UPDATE CASCADE,
  Supporter2      int references Supporter(ID) ON DELETE CASCADE ON UPDATE CASCADE,
  primary key(Supporter1, Supporter2)
);

create table ParticipatedIn (
  SupporterID     int references Supporter(ID) ON DELETE CASCADE ON UPDATE CASCADE,
  EventID         int references Event(ID) ON DELETE CASCADE ON UPDATE CASCADE,
  primary key(SupporterID, EventID)
);

create table Organizes (
  SupporterID     int references Supporter(ID) ON DELETE CASCADE ON UPDATE CASCADE,
  CampaignTitle   varchar(40) references Campaign(Title) ON DELETE CASCADE ON UPDATE CASCADE,
  primary key(SupporterID, CampaignTitle)
);

--------------------------------------------
---------------- Views ---------------------
--------------------------------------------
-- Balance Sheet
create view one as
  select Account.ID, Purpose, Bank, Sum(Amount) as Balance
  from Payment 
  inner join Account on (Payment.AccountID = Account.ID)
  group by Account.ID;

-- Volunteers
create view two as
  select Name, Phone, Email, Title, count(ParticipatedIn) as NumberOfEvents
  from Supporter 
  inner join ParticipatedIn on (Supporter.ID = ParticipatedIn.SupporterID)
  group by Supporter.ID;

-- Senior Volunteers
create view three as
  select Name, Phone, Email, Title, NumberOfEvents
  from (
    select Name, Phone, Email, Title, count(ParticipatedIn) as NumberOfEvents
    from Supporter
    inner join ParticipatedIn on (Supporter.ID = ParticipatedIn.SupporterID)
    group by Supporter.ID
  ) as query where NumberOfEvents > 3;

-- Members
create view four as
  select Name, Phone, Email
  from Supporter supporter
  where not exists (
    select *
    from ParticipatedIn
    where supporter.ID = SupporterID
  );

-- Campaign Organizers
create view five as
  select Name, Phone, Email, Supporter.Title, Organizes.CampaignTitle
  from Supporter
  inner join Organizes on (Supporter.ID = Organizes.SupporterID);

-- Social Groups
create view six as
  select Name, Phone, Email, Title, Count(Supporter.ID)
  from Supporter
  inner join WorksWith on (Supporter.ID = WorksWith.Supporter1)
    or (Supporter.ID = WorksWith.Supporter2)
  group by Supporter.ID;
  
-- Events By Campaign
create view seven as
  select Event.ID as EventID, Title, Name, PhaseNumber
  from Event
  inner join PartOf on (Event.ID = PartOf.EventID)
  order by Title;

-- Donors
create view eight as
  select distinct Supporter.name, Supporter.Phone, Supporter.email, sum(Amount)
  from ReimbursementDonation
  inner join Payment on (ReimbursementDonation.PaymentID = Payment.ID)
  inner join Supporter on (ReimbursementDonation.SupporterID = Supporter.ID)
  where (Payment.Amount >= 0)
  group by Supporter.ID;

-- Reimbursement Audit
create view nine as
  select Supporter.name, Supporter.ID as SupporterID, Payment.amount, Payment.ID as PaymentID, Account.ID as AccountID, Account.Purpose, Description
  from Payment
  inner join ReimbursementDonation on (ReimbursementDonation.PaymentID = Payment.ID)
  inner join Supporter on (ReimbursementDonation.SupporterID = Supporter.ID)
  inner join Account on (Payment.AccountID = Account.ID)
  where (Payment.Amount <= 0)
  order by Supporter.name;
 
-- Campaign Audit 
create view ten as
  select Campaign.Title, Account.ID as AccountID, Account.Purpose, Payment.amount, Payment.ID as PaymentID, Payment.description
  from Campaign
  inner join FundingStream on (Campaign.Title = FundingStream.Title)
  inner join Account on (Account.id = FundingStream.AccountID)
  inner join Payment on (Payment.AccountID = Account.id)
  order by Campaign.Title;

--------------------------------------------
------------- Sample Data ------------------
--------------------------------------------
--------------
-- Campaign --
--------------
insert into Campaign values (
  'Global Warming',
  'Don''t leave the oven on!',
  1
);

insert into Campaign values (
  'Northern Gateway',
  'Don''t kill the whales yet',
  2
);

insert into Campaign values (
  'Keystone',
  'Environment before profits!',
  2
);

-----------
-- Phase --
-----------
insert into Phase values (
  1,
  'Global Warming',
  'Spread the word about Global Warming.',
  'October 5 09:00:00 2013 PST',
  'October 15 20:00:00 2013 PST'
);

insert into Phase values (
  2,
  'Global Warming',
  'Promote government attention to the topic.',
  'October 16 09:00:00 2013 PST',
  'October 31 20:00:00 2013 PST'
);

insert into Phase values (
  1,
  'Northern Gateway',
  'It''s not worth it, block the pipeline!',
  'October 5 09:00:00 2013 PST',
  'October 15 20:00:00 2013 PST'
);

insert into Phase values (
  2,
  'Northern Gateway',
  'Hold a rally to show our concerns.',
  'October 16 09:00:00 2013 PST',
  'October 31 20:00:00 2013 PST'
);

insert into Phase values (
  1,
  'Keystone',
  'It''s not worth it, block the pipeline!',
  'October 16 09:00:00 2013 PST',
  'October 31 20:00:00 2013 PST'
);

insert into Phase values (
  2,
  'Keystone',
  'Hold a rally to show our concerns.',
  'November 1 09:00:00 2013 PST',
  'November 30 20:00:00 2013 PST'
);

-----------
-- Event --
-----------
-- Global Warming
-- Phase 1
insert into Event values (
  1,
  'Gala Opening Dinner',
  'Victoria Convention Center',
  'October 5 17:00:00 2013 PST',
  'October 5 20:00:00 2013 PST'
);

insert into Event values (
  2,
  'Legislature Protest',
  'BC Legislature Protest',
  'October 10 12:00:00 2013 PST',
  'October 10 2:00:00 2013 PST'
);

insert into Event values (
  3,
  'Street Canvasing',
  'Downtown Victoria, meet at Bay Center',
  'October 15 11:00:00 2013 PST',
  'October 15 14:00:00 2013 PST'
);

-- Phase 2
insert into Event values (
  4,
  'Rally Against Gas Companies',
  'Centennial Square',
  'October 20 11:00:00 2013 PST',
  'October 20 14:00:00 2013 PST'
);

insert into Event values (
  5,
  'Closing Gala Dinner',
  'October 31 17:00:00 2013 PST',
  'October 31 20:00:00 2013 PST'
);

-- Northern Gateway
-- Phase 1
insert into Event values (
  6,
  'Gala Opening Dinner',
  'Victoria Convention Center',
  'October 6 17:00:00 2013 PST',
  'October 6 20:00:00 2013 PST'
);

insert into Event values (
  7,
  'Legislature Protest',
  'BC Legislature Protest',
  'October 11 12:00:00 2013 PST',
  'October 11 2:00:00 2013 PST'
);

insert into Event values (
  8,
  'Street Canvasing',
  'Downtown Victoria, meet at Bay Center',
  'October 14 11:00:00 2013 PST',
  'October 14 14:00:00 2013 PST'
);
-- Phase 2
insert into Event values (
  9,
  'Rally Against Enbridge',
  'Centennial Square',
  'October 21 11:00:00 2013 PST',
  'October 21 14:00:00 2013 PST'
);

insert into Event values (
  10,
  'Closing Gala Dinner',
  'October 30 17:00:00 2013 PST',
  'October 30 20:00:00 2013 PST'
);

-- Keystone
-- Phase 1
insert into Event values (
  11,
  'Gala Opening Dinner',
  'Victoria Convention Center',
  'October 16 17:00:00 2013 PST',
  'October 16 20:00:00 2013 PST'
);

insert into Event values (
  12,
  'Legislature Protest',
  'BC Legislature Protest',
  'October 17 12:00:00 2013 PST',
  'October 17 2:00:00 2013 PST'
);
-- Phase 2
insert into Event values (
  13,
  'Street Canvasing',
  'Downtown Victoria, meet at Bay Center',
  'November 2 11:00:00 2013 PST',
  'November 2 14:00:00 2013 PST'
);

insert into Event values (
  14,
  'Rally Against Enbridge',
  'Centennial Square',
  'November 5 11:00:00 2013 PST',
  'November 5 14:00:00 2013 PST'
);

insert into Event values (
  15,
  'Closing Gala Dinner',
  'November 30 17:00:00 2013 PST',
  'November 30 20:00:00 2013 PST'
);

-------------
-- Part Of --
-------------
-- Global Warming
insert into PartOf values (
  1,
  'Global Warming',
  1
);

insert into PartOf values (
  2,
  'Global Warming',
  1
);

insert into PartOf values (
  3,
  'Global Warming',
  1
);

insert into PartOf values (
  4,
  'Global Warming',
  2
);

insert into PartOf values (
  5,
  'Global Warming',
  2
);

-- Northern Gateway
insert into PartOf values (
  6,
  'Northern Gateway',
  1
);

insert into PartOf values (
  7,
  'Northern Gateway',
  1
);

insert into PartOf values (
  8,
  'Northern Gateway',
  1
);

insert into PartOf values (
  9,
  'Northern Gateway',
  2
);

insert into PartOf values (
  10,
  'Northern Gateway',
  2
);

-- Keystone
insert into PartOf values (
  11,
  'Keystone',
  1
);

insert into PartOf values (
  12,
  'Keystone',
  1
);

insert into PartOf values (
  13,
  'Keystone',
  2
);

insert into PartOf values (
  14,
  'Keystone',
  2
);

insert into PartOf values (
  15,
  'Keystone',
  2
);

-------------
-- Account --
-------------
insert into Account values (
  1,
  'General Operations',
  'Vancity'
);

insert into Account values (
  2,
  'Payroll',
  'Vancity'
);

insert into Account values (
  3,
  'Media and Materials',
  'Vancity'
);

insert into Account values (
  4,
  'Global Warming Campaign',
  'Vancity'
);

insert into Account values (
  5,
  'Northern Gateway Campaign',
  'Coast Capital'
);

insert into Account values (
  6,
  'Keystone Campaign',
  'Coast Capital'
);

-------------------
-- FundingStream --
-------------------
insert into FundingStream values (
  4,
  'Global Warming'
);

insert into FundingStream values (
  5,
  'Northern Gateway'
);

insert into FundingStream values (
  6,
  'Keystone'
);

-------------
-- Payment --
-------------
-- Global Warming
-- P1
insert into Payment values (
  1,
  4,
  5000,
  'October 5 10:00:00 2013 PST',
  'Donation fron Wilfred Wolf'
);

insert into Payment values (
  2,
  4,
  -250,
  'October 14 17:00:00 2013 PST',
  'Printing costs'
);
-- P2
insert into Payment values (
  22,
  4,
  9000,
  'October 14 17:00:00 2013 PST',
  'Donation from Betty Bear'
);

insert into Payment values (
  23,
  4,
  -950,
  'October 14 17:00:00 2013 PST',
  'Rally costs'
);

-- Northern Gateway
-- P1
insert into Payment values (
  3,
  5,
  2000,
  'October 10 13:00:00 2013 PST',
  'Donation from Val Volpix'
);

insert into Payment values (
  4,
  5,
  -350,
  'October 14 13:00:00 2013 PST',
  'Printing costs'
);

-- P2
insert into Payment values (
  5,
  5,
  -350,
  'October 19 13:00:00 2013 PST',
  'Printing costs'
);

insert into Payment values (
  6,
  5,
  5000,
  'October 30 16:00:00 2013 PST',
  'Donation from Betty Bear'
);

-- Keystone
-- P1
insert into Payment values (
  24,
  6,
  2000,
  'October 20 13:00:00 2013 PST',
  'Donation from Wally Wolf'
);

insert into Payment values (
  25,
  6,
  -350,
  'October 25 13:00:00 2013 PST',
  'Printing costs'
);
-- P2
insert into Payment values (
  26,
  6,
  -350,
  'November 13 13:00:00 2013 PST',
  'Printing costs'
);

insert into Payment values (
  27,
  6,
  5000,
  'November 15 16:00:00 2013 PST',
  'Donation from Val Volpix'
);

-- General
insert into Payment values (
  7,
  1,
  500,
  'October 1 09:00:00 2013 PST',
  'Administration costs'
);

insert into Payment values (
  8,
  1,
  -100,
  'October 1 09:00:01 2013 PST',
  'Telephone & Internet Fees'
);

insert into Payment values (
  9,
  1,
  -100,
  'October 1 09:00:01 2013 PST',
  'Web hosting fees'
);

insert into Payment values (
  10,
  1,
  -200,
  'October 1 09:00:01 2013 PST',
  'Strata Fees'
);

insert into Payment values (
  11,
  1,
  -100,
  'October 1 09:00:01 2013 PST',
  'Printer contract with Xerox.'
);
-- Payroll
insert into Payment values (
  12,
  2,
  2000,
  'October 1 09:00:00 2013 PST',
  'Salary Deposit.'
);

insert into Payment values (
  13,
  2,
  -500,
  'October 1 09:00:01 2013 PST',
  'Salary for Olly Octopus.'
);

insert into Payment values (
  14,
  2,
  -500,
  'October 1 09:00:01 2013 PST',
  'Salary for Sarah Skunk'
);

insert into Payment values (
  15,
  2,
  -1000,
  'October 1 09:00:01 2013 PST',
  'Salary for Crazy CEO Cat'
);

insert into Payment values (
  16,
  2,
  2000,
  'October 15 09:00:00 2013 PST',
  'Salary Deposit.'
);

insert into Payment values (
  17,
  2,
  -500,
  'October 14 09:00:01 2013 PST',
  'Salary for Olly Octopus.'
);

insert into Payment values (
  18,
  2,
  -500,
  'October 15 09:00:01 2013 PST',
  'Salary for Sarah Skunk'
);

insert into Payment values (
  19,
  2,
  -1000,
  'October 15 09:00:01 2013 PST',
  'Salary for Crazy CEO Cat'
);
-- Media
insert into Payment values (
  20,
  3,
  100,
  'October 2 09:00:00 2013 PST',
  'Initial Deposit for general printing funds.'
);

insert into Payment values (
  21,
  3,
  -22,
  'October 15 10:30:00 2013 PST',
  'Costs for printing a few posters'
);

----------------
-- Supporters --
----------------
-- Donors
insert into Supporter values (
  1,
  '250-123-12345',
  'Wilfred@wolf.com',
  'Wilfred Wolf',
  NULL
);

insert into Supporter values (
  2,
  '250-124-12345',
  'betty@bear.com',
  'Betty Bear',
  NULL
);

insert into Supporter values (
  3,
  '250-125-12345',
  'val@volpix.com',
  'Val Volpix',
  NULL
);

insert into Supporter values (
  4,
  '250-126-12345',
  'wally@wolf.com',
  'Wally Wolf',
  NULL
);
-- Employees
insert into Supporter values (
  5,
  '250-128-12345',
  'olly@octopus.com',
  'Olly Octopus',
  'Chief Fundraiser'
);

insert into Supporter values (
  6,
  '250-128-12345',
  'sarah@skunk.com',
  'Sarah Skunk',
  'Chief Organizer'
);

insert into Supporter values (
  7,
  '250-120-12345',
  'crazy@cat.com',
  'Crazy CEO Cat',
  'CEO'
);
-- Volunteers
insert into Supporter values (
  8,
  '250-120-2345',
  'peter@porpoise.com',
  'Peter Porpoise',
  'Global Warming Contact'
);

insert into Supporter values (
  9,
  '250-120-4345',
  'pal@polarbear.com',
  'Pal Polar Bear',
  'Northern Gateway Contact'
);

insert into Supporter values (
  10,
  '250-120-4348',
  'fella@fox.com',
  'Fella Fox',
  'Keystone Contact'
);

-- Plain old members
insert into Supporter values (
  11,
  '250-124-4745',
  'ally@antelope.com',
  'Ally Antelope',
  NULL
);

insert into Supporter values (
  12,
  '250-124-4785',
  'buddy@beaver.com',
  'Buddy Beaver',
  NULL
);

---------------------
-- ExpenseDonation --
---------------------
-- Global Warming
insert into ExpenseDonation values (
  1,
  'Global Warming'
);

insert into ExpenseDonation values (
  2,
  'Global Warming'
);

insert into ExpenseDonation values (
  22,
  'Global Warming'
);

insert into ExpenseDonation values (
  23,
  'Global Warming'
);
-- Northern Gateway
insert into ExpenseDonation values (
  3,
  'Northern Gateway'
);

insert into ExpenseDonation values (
  4,
  'Northern Gateway'
);

insert into ExpenseDonation values (
  5,
  'Northern Gateway'
);

insert into ExpenseDonation values (
  6,
  'Northern Gateway'
);
-- Keystone
insert into ExpenseDonation values (
  24,
  'Keystone'
);

insert into ExpenseDonation values (
  25,
  'Keystone'
);

insert into ExpenseDonation values (
  26,
  'Keystone'
);

insert into ExpenseDonation values (
  27,
  'Keystone'
);

---------------------------
-- ReimbursementDonation --
---------------------------
-- Donations
-- Wilfred
insert into ReimbursementDonation values (
  1,
  1
);
-- Betty
insert into ReimbursementDonation values (
  6,
  2
);

insert into ReimbursementDonation values (
  22,
  2
);
-- Val
insert into ReimbursementDonation values (
  3,
  3
);

insert into ReimbursementDonation values (
  27,
  3
);
-- Wally
insert into ReimbursementDonation values (
  24,
  4
);
-- Olly Octopus
insert into ReimbursementDonation values (
  4,
  5
);

insert into ReimbursementDonation values (
  5,
  6
);

insert into ReimbursementDonation values (
  20,
  5
);
-- Sarah Skunk
insert into ReimbursementDonation values (
  21,
  6
);
-- Crazy
insert into ReimbursementDonation values (
  7,
  7
);

insert into ReimbursementDonation values (
  8,
  7
);

insert into ReimbursementDonation values (
  9,
  7
);

insert into ReimbursementDonation values (
  10,
  7
);

insert into ReimbursementDonation values (
  11,
  7
);

--------------
-- Employee --
--------------
insert into Employee values (
  5,
  500
);

insert into Employee values (
  6,
  500
);

insert into Employee values (
  7,
  1000
);

------------
-- Access --
------------
-- Contacts
insert into Access values (
  4,
  8
);

insert into Access values (
  5,
  9
);

insert into Access values (
  6,
  10
);
-- Crazy
insert into Access values (
  4,
  7
);

insert into Access values (
  5,
  7
);

insert into Access values (
  6,
  7
);

insert into Access values (
  3,
  7
);

insert into Access values (
  2,
  7
);

insert into Access values (
  1,
  7
);

-- Sarah
insert into Access values (
  4,
  6
);

insert into Access values (
  5,
  6
);

insert into Access values (
  6,
  6
);

insert into Access values (
  3,
  6
);

insert into Access values (
  2,
  6
);

insert into Access values (
  1,
  6
);

-- Olly
insert into Access values (
  4,
  5
);

insert into Access values (
  5,
  5
);

insert into Access values (
  6,
  5
);

insert into Access values (
  3,
  5
);

insert into Access values (
  2,
  5
);

insert into Access values (
  1,
  5
);

---------------
-- WorksWith --
---------------
-- Olly
insert into WorksWith values (
  5,
  6
);

insert into WorksWith values (
  5,
  7
);

insert into WorksWith values (
  5,
  8
);

insert into WorksWith values (
  5,
  9
);

insert into WorksWith values (
  5,
  10
);
-- Sarah
insert into WorksWith values (
  6,
  7
);

insert into WorksWith values (
  6,
  8
);

insert into WorksWith values (
  6,
  9
);

insert into WorksWith values (
  6,
  10
);

--------------------
-- ParticipatedIn --
--------------------
-- Crazy
insert into ParticipatedIn values (7, 1);
insert into ParticipatedIn values (7, 2);
insert into ParticipatedIn values (7, 3);
insert into ParticipatedIn values (7, 4);
insert into ParticipatedIn values (7, 5);
insert into ParticipatedIn values (7, 6);
insert into ParticipatedIn values (7, 7);
insert into ParticipatedIn values (7, 8);
insert into ParticipatedIn values (7, 9);
insert into ParticipatedIn values (7, 10);
insert into ParticipatedIn values (7, 11);
insert into ParticipatedIn values (7, 12);
insert into ParticipatedIn values (7, 13);
insert into ParticipatedIn values (7, 14);
insert into ParticipatedIn values (7, 15);
-- Olly
insert into ParticipatedIn values (5, 1);
insert into ParticipatedIn values (5, 2);
insert into ParticipatedIn values (5, 3);
insert into ParticipatedIn values (5, 4);
insert into ParticipatedIn values (5, 5);
insert into ParticipatedIn values (5, 6);
insert into ParticipatedIn values (5, 7);
insert into ParticipatedIn values (5, 8);
insert into ParticipatedIn values (5, 9);
insert into ParticipatedIn values (5, 10);
insert into ParticipatedIn values (5, 11);
insert into ParticipatedIn values (5, 12);
insert into ParticipatedIn values (5, 13);
insert into ParticipatedIn values (5, 14);
insert into ParticipatedIn values (5, 15);
-- Sarah
insert into ParticipatedIn values (6, 1);
insert into ParticipatedIn values (6, 2);
insert into ParticipatedIn values (6, 3);
insert into ParticipatedIn values (6, 4);
insert into ParticipatedIn values (6, 5);
insert into ParticipatedIn values (6, 6);
insert into ParticipatedIn values (6, 7);
insert into ParticipatedIn values (6, 8);
insert into ParticipatedIn values (6, 9);
insert into ParticipatedIn values (6, 10);
insert into ParticipatedIn values (6, 11);
insert into ParticipatedIn values (6, 12);
insert into ParticipatedIn values (6, 13);
insert into ParticipatedIn values (6, 14);
insert into ParticipatedIn values (6, 15);
-- Peter
insert into ParticipatedIn values (8, 1);
insert into ParticipatedIn values (8, 2);
insert into ParticipatedIn values (8, 3);
insert into ParticipatedIn values (8, 4);
insert into ParticipatedIn values (8, 5);
-- Pal
insert into ParticipatedIn values (9, 6);
insert into ParticipatedIn values (9, 7);
insert into ParticipatedIn values (9, 8);
insert into ParticipatedIn values (9, 9);
insert into ParticipatedIn values (9, 10);
-- Fella
insert into ParticipatedIn values (10, 11);
insert into ParticipatedIn values (10, 12);
insert into ParticipatedIn values (10, 13);
insert into ParticipatedIn values (10, 14);
insert into ParticipatedIn values (10, 15);
-- Wilfred
insert into ParticipatedIn values (1, 1);
insert into ParticipatedIn values (1, 5);
insert into ParticipatedIn values (1, 6);
insert into ParticipatedIn values (1, 10);
-- Betty
insert into ParticipatedIn values (2, 1);
insert into ParticipatedIn values (2, 5);

---------------
-- Organizes --
---------------
insert into Organizes values (8, 'Global Warming');
insert into Organizes values (9, 'Northern Gateway');
insert into Organizes values (10, 'Keystone');

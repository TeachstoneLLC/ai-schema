insert into job_statuses (key, description)
values
('SUBMITTED', 'Submitted and ready to be processed'),
('IN_PROGRESS', 'Currently being processed'),
('COMPLETED', 'Processing has completed'),
('ERROR', 'An error occurred and no further processing is being done');

create table job_types (
   key varchar(32) not null primary key,
   description varchar not null);
comment on table job_types is 'Lists the types of job we accept';
comment on column job_types.description is 'Explains what kinds of jobs fall into this category';
insert into job_types (key, description)
values
('CODERBOT', 'Coderbot - takes video observation sessions and provides CLASS scores'),
('TRANSLATOR', 'Given a document in English, translates it to one or more other languages');


create table pipelines (
   key varchar(32) not null primary key,
   description varchar not null);
comment on table pipelines is 'Corresponds to the processing pipeline that will be used to process a job';
comment on column pipelines.description is 'Description of the processing pipeline';
insert into pipelines (key, description)
values
('CODER_GPT_4', 'Coderbot pipeline that uses ChatGPT 4'),
('CODER_GPT_4o', 'Coderbot pipeline that uses ChatGPT 4o');


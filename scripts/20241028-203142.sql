alter table jobs drop column if exists input_file_id;
alter table job_files add column if not exists sequence int not null default 1;

comment on column job_files.sequence is 'The sequence number of the file in the job; starts at 1. By definition the file where sequence = 1 is the primary input file.';

create table if not exists job_steps (
    key varchar(32) primary key,
    description varchar not null
    );
comment on table job_steps is 'Describes the possible steps in a job processing pipeline.';

create table job_history (
    id serial primary key,
    sequence int not null,
    step varchar(32) not null references job_steps(key),
    processing_start_time timestamp without time zone not null,
    processing_end_time timestamp without time zone null,
    error_text text null
);
create unique index on job_history (id, sequence);

comment on table job_history is 'Tracks the history of a job''s processing steps.';
comment on column job_history.sequence is 'The sequence number of the step in the job; starts at 1.';
comment on column job_history.step is 'The step in the job processing pipeline; maps to the job_steps table.';
comment on column job_history.processing_start_time is 'UTC timestamp at which step processing began.';
comment on column job_history.processing_end_time is 'UTC timestamp at which step processing ended; this is null for steps that haven''t finished processing yet.';
comment on column job_history.error_text is 'Text of any error that occurred during processing of this step; this is null if no error occurred.';

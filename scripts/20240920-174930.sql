create table jobs (
    id SERIAL,
    status varchar(32) not null default 'SUBMITTED' references job_statuses (key),
    job_type varchar(32) not null references job_types(key),
    pipeline varchar(32) not null references pipelines(key),
    submitted_by_user_guid uuid not null,
    processing_start_time timestamp without time zone null,
    processing_end_time timestamp without time zone null,
    processing_server_name varchar null,
    created_at timestamp without time zone not null default current_timestamp,
    updated_at timestamp without time zone not null default current_timestamp,
    deleted_at timestamp without time zone null);
comment on table jobs is 'Tracks AI jobs - 1 record per job';
comment on column jobs.status is 'Job status, maps to job_statuses table';
comment on column jobs.job_type is 'Job type, maps to job_types table';
comment on column jobs.pipeline is 'Pipeline the job is using, maps to the pipelines table';
comment on column jobs.submitted_by_user_guid is 'UUID of the user who submitted the job; this comes from the onelogin.users table';
comment on column jobs.processing_start_time is 'UTC timestamp at which job processing began; this is null for jobs that haven''t been processed yet';
comment on column jobs.processing_end_time is 'UTC timestamp at which job processing ended; this is null for jobs that haven''t finished processing yet';
comment on column jobs.processing_server_name is 'Identifier of the server/container that is processing this job';

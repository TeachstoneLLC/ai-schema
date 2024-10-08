alter table jobs add primary key (id);
create table job_files (
    id SERIAL primary key,
    uuid UUID NOT NULL default gen_random_uuid(),
    filename varchar not null,
    mime_type varchar not null,
    s3_bucket varchar(63) not null,
    s3_key varchar(1024) not null,
    byte_length bigint not null,
    job_id integer NOT NULL references jobs (id),
    created_at timestamp without time zone not null default current_timestamp,
    updated_at timestamp without time zone not null default current_timestamp,
    deleted_at timestamp without time zone null);
CREATE TRIGGER job_files_update_trigger BEFORE UPDATE ON job_files FOR EACH ROW EXECUTE PROCEDURE updated_at_timestamp();

create unique index idx_job_files_name on job_files (s3_bucket, s3_key) where deleted_at is null;
create unique index idx_job_files_uuid on job_files (uuid);
create index idx_job_files_job_id on job_files (job_id);

comment on table job_files is 'Tracks files, stored on AWS S3, used in the processing of AI jobs';
comment on column job_files.filename is 'Original file name, not necessarily used in S3';
comment on column job_files.mime_type is 'MIME type of the file, e.g. "video/mp4"';
comment on column job_files.s3_bucket is 'Bucket on S3 where the object is stored';
comment on column job_files.s3_key is 'Key in the S3 bucket in which the object is stored';
comment on column job_files.byte_length is 'File size, in bytes';
comment on column job_files.job_id is 'Identifies the job to which this file belongs';

alter table jobs add column if not exists input_file_id integer references job_files (id);
comment on column jobs.input_file_id is 'ID of the initial file used as input data for the job - see job_files';

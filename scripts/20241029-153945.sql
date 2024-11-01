alter table job_histories add column if not exists job_id int not null references jobs(id);
drop index job_history_id_sequence_idx;
create unique index job_history_job_id_sequence_idx on job_histories (job_id, sequence);
comment on column job_histories.job_id is 'Job to which this history step belongs';

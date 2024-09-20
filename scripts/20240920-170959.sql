create table job_statuses (
   key varchar(32) not null primary key,
   description varchar not null);
comment on table job_statuses is 'Lists the states a job can be in over time';
comment on column job_statuses.description is 'Explains what the state is intended to mean';

CREATE TABLE job_metrics (
    id SERIAL PRIMARY KEY,
    job_id INT NOT NULL REFERENCES jobs (id),
    user_uuid UUID NOT NULL,
    metric VARCHAR(32) NOT NULL REFERENCES metric_names (key),
    metric_value_int INT NOT NULL,
    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITHOUT TIME ZONE
);

create trigger job_metrics_update_trigger before
update on job_metrics for each row execute procedure updated_at_timestamp ();

comment on table job_metrics is 'Stores metrics associated with specific jobs';
comment on column job_metrics.job_id is 'From the jobs table, the ID of the job to which this metric applies';
comment on column job_metrics.user_uuid is 'The UUID of the user who submitted the job';
comment on column job_metrics.metric is 'The kind of metric being recorded, from the metric_names table';
comment on column job_metrics.metric_value_int is 'The value of the metric being recorded';
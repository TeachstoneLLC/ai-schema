CREATE TABLE job_metrics (
    id SERIAL PRIMARY KEY,                              
    job_id INT NOT NULL REFERENCES jobs(id),            
    metric_name VARCHAR(32) NOT NULL REFERENCES metric_names(name), 
    metric_value_int INT NOT NULL,                      
    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP, 
    updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,     
    deleted_at TIMESTAMP WITHOUT TIME ZONE                               
);

create trigger job_metrics_update_trigger before update on job_metrics for each row execute procedure updated_at_timestamp();

comment on column id is 'NOT NULL, primary key';
comment on column job_id is 'NOT NULL, foreign key to the jobs table';
comment on column metric_value_int is 'NOT NULL, the integer value of the metric';

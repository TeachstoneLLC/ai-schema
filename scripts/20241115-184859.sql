CREATE TABLE metric_names (
    key varchar(32) PRIMARY KEY,     
    description varchar NOT NULL,
    name varchar(32) NOT NULL,  
    UNIQUE(name)                
);

comment on column metric_names.key IS 'The unique identifier for the metric.';
comment on column metric_names.description IS 'A brief description of what the metric represents.';

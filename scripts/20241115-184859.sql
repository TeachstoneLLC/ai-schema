CREATE TABLE metric_names ( 
    name varchar(32) PRIMARY KEY NOT NULL,
    description varchar NOT NULL,             
);

comment on table metric_names is 'Stores the unique key and description for metrics.';

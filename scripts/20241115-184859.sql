CREATE TABLE metric_names ( 
    key varchar(32) PRIMARY KEY NOT NULL,
    description varchar NOT NULL
);

comment on table metric_names is 'Tracks the different kinds of metrics that can be collected.';

insert into metric_names (key, description) 
values 
('ACCURACY', 'On a scale of 1 (not at all) to 5 (perfect), how accurate was the result?'),
('EASE', 'On a scale of 1 (very difficult) to 5 (very easy), how easy was it to use the system?'),
('SPEED', 'On a scale of 1 (very slow) to 5 (very fast), how quickly did you get your result?');
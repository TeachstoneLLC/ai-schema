alter table jobs add column if not exists uuid UUID NOT NULL default gen_random_uuid();

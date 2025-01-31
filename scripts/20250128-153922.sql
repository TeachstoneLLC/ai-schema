create table file_types ( id varchar(50) primary key );

-- Insert our known file types
insert into file_types (id) values
                                ('SOURCE_VIDEO'),
                                ('EXTRACTED_AUDIO'),
                                ('WHISPER_TRANSCRIPT'),
                                ('DIARIZATION_RTTM'),
                                ('DIARIZED_TRANSCRIPT'),
                                ('CLASS_ANALYSIS');

-- Add file_type column to job_files with foreign key constraint
alter table job_files
    add column file_type varchar(50) not null,
  add constraint fk_job_files_file_type
    foreign key (file_type) references file_types(id);

-- Add an index for faster lookups by job_id + file_type
create index idx_job_files_job_id_file_type
    on job_files(job_id, file_type);
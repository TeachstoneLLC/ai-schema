delete from cached_video_scores;
delete from benchmark_video_scores;
delete from benchmark_videos;

alter table benchmark_videos drop column job_file_id;
alter table benchmark_video_scores add column job_file_id integer not null references job_files(id);
alter table benchmark_video_scores drop column pipeline;

comment on column benchmark_video_scores.job_file_id is 'Indicates the job_files record the scores belong to';

create unique index idx_benchmark_videos_video_id on benchmark_videos (video_guid) where deleted_at is null;
create unique index idx_cached_video_scores_benchmark_video_id_dimension on cached_video_scores (benchmark_video_id, dimension) where deleted_at is null;
create unique index idx_benchmark_video_scores_job_file_id_dimension on benchmark_video_scores (job_file_id, dimension) where deleted_at is null;
create index idx_benchmark_video_scores_benchmark_video_id on benchmark_video_scores (benchmark_video_id);
create index idx_benchmark_video_scores_job_file_id on benchmark_video_scores (job_file_id);

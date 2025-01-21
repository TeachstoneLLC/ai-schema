CREATE TABLE benchmark_videos (
  id SERIAL PRIMARY KEY,
  video_guid UUID,
  video_host_id VARCHAR(191) NOT NULL,
  job_file_id INTEGER NOT NULL REFERENCES job_files(id),
  scored_at TIMESTAMP WITHOUT TIME ZONE,
  created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  deleted_at TIMESTAMP WITHOUT TIME ZONE
);
COMMENT ON TABLE benchmark_videos IS 'Represents video files that can be used for benchmarking Coderbot';
COMMENT ON COLUMN benchmark_videos.video_guid IS 'Internal UUID of the video, from onelogin';
COMMENT ON COLUMN benchmark_videos.video_host_id IS 'Kaltura entry ID - uniquely identifies a video in the Kaltura system';
COMMENT ON COLUMN benchmark_videos.job_file_id IS 'Indicates the job_files record this belongs to';
COMMENT ON COLUMN benchmark_videos.scored_at IS 'Date/time this record was last benchmarked - assumed to be UTC, stored without time zone';

CREATE TABLE benchmark_video_scores (
  id SERIAL PRIMARY KEY,
  benchmark_video_id INTEGER NOT NULL REFERENCES benchmark_videos(id),
  pipeline VARCHAR(32) NOT NULL REFERENCES pipelines(key),
  dimension VARCHAR(80) NOT NULL,
  benchmark_score INTEGER NOT NULL,
  created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  deleted_at TIMESTAMP WITHOUT TIME ZONE
);
COMMENT ON TABLE benchmark_video_scores IS 'CLASS scoring for a Coderbot video, using a pipeline; this is the candidate score set';
COMMENT ON COLUMN benchmark_video_scores.benchmark_video_id IS 'References the benchmark_videos record to which these scores apply';
COMMENT ON COLUMN benchmark_video_scores.pipeline IS 'Identifies the AI pipeline in use';
COMMENT ON COLUMN benchmark_video_scores.dimension IS 'CLASS 2E dimension, from envscales.dimensions table';
COMMENT ON COLUMN benchmark_video_scores.benchmark_score IS 'AI-generated score, 1-7';

CREATE TABLE cached_video_scores (
  id SERIAL PRIMARY KEY,
  benchmark_video_id INTEGER NOT NULL REFERENCES benchmark_videos(id),
  dimension VARCHAR(80) NOT NULL,
  expected_score INTEGER NOT NULL,
  cached_at TIMESTAMP WITHOUT TIME ZONE NOT NULL,
  created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  deleted_at TIMESTAMP WITHOUT TIME ZONE
);
COMMENT ON TABLE cached_video_scores IS 'Standard scores on benchmark videos, pulled from env-scales and cached';
COMMENT ON COLUMN cached_video_scores.benchmark_video_id IS 'Benchmark video to which the score applies';
COMMENT ON COLUMN cached_video_scores.dimension IS 'CLASS 2E dimension, from envscales.dimensions table';
COMMENT ON COLUMN cached_video_scores.expected_score IS 'Standard score for this dimension, 1-7';
COMMENT ON COLUMN cached_video_scores.cached_at IS 'Date/time at which the record was cached';

BEGIN;

UPDATE job_steps
SET key = 'PYANNOTE_DIARIZE_AUDIO'
WHERE key = 'PYANOTE_DIARIZE_AUDIO';

UPDATE job_steps
SET description = 'Use pyannote to transcribe and diarize audio'
WHERE key = 'PYANNOTE_DIARIZE_AUDIO';

COMMIT;

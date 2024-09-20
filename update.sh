#!/bin/zsh

# This script is intended to run only in development (on your laptop).
# For production, we call `sem-apply` directly.

sem-apply --url postgresql://svc_ai@localhost:5432/ai_development
sem-apply --url postgresql://svc_ai@localhost:5432/ai_test

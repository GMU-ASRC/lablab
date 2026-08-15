# worker

Pulls a Godot dedicated-server build and runs simulation
evals for the `astroswarm.autonomousrobotics.club` server, reporting
results back over `SERVER_URL`. Reserves one NVIDIA GPU via
`deploy.resources.reservations.devices` (the host's RTX 2080 Ti, see
`../../docker.md` for the container toolkit setup this needs). `WORKER_MAX_JOBS`
and `EVAL_SHARD_COUNT` should be tuned to what the GPU and CPU can
actually sustain, especially since `immich`'s machine-learning container
shares the same card.

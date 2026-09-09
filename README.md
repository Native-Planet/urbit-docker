`docker buildx build --build-arg TAG=$tag --push --tag nativeplanet/urbit:${tag} --platform linux/amd64,linux/arm64 .`

## vere32 / vere64

The `canary` image carries both loom widths of the same vere release:

- `/usr/local/vere/32/urbit` – 32-bit loom (default; `/bin/urbit` points here)
- `/usr/local/vere/64/urbit` – 64-bit loom

Pick one by prepending its directory to `PATH`, or pass `--vere-bits=32|64` to
`start-urbit`. Booting a pier with the other width migrates its snapshot in
place (vere 5.0+); a 64-bit snapshot can only go back to 32-bit if it fits in
the 32-bit loom (16 GB).

# ec-sdk-buildpack

## to run
```bash
docker run --network host \
-v $(pwd):/build \
-e DIND_PATH="" \
--env-file build.list -it wzlib:v1.1beta
```

````markdown
```bash
docker rm -f sandbox-jupyter 2>/dev/null || true
docker volume create jupyter_config
docker run -d \
  --name=sandbox-jupyter \
  -e JUPYTER_ENABLE_LAB=yes \
  -e JUPYTER_TOKEN='şuraya-token' \
  -p 8888:8888 \
  -v jupyter_config:/home/jovyan/work \
  --user root \
  jupyter/datascience-notebook:latest \
  start-notebook.sh --NotebookApp.token='şuraya-token' --NotebookApp.password='' --NotebookApp.allow_root=True
```
````
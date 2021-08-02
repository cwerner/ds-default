FROM nvcr.io/nvidia/pytorch:21.02-py3
LABEL maintainer="Christian Werner <christian.werner@kit.edu>"

ARG NB_USER="jovyan"
ARG NB_UID="1000"
ARG NB_GID="100"

USER root

WORKDIR /    

COPY environment.yml ./
COPY entrypoint.sh /usr/bin/entrypoint.sh

RUN apt-get update && apt-get -yq dist-upgrade                               &&\
    apt-get install -yq --no-install-recommends wget bzip2 ca-certificates     \
                                                sudo locales fonts-liberation  \
                                                run-one                      &&\
    rm -rf /var/lib/apt/lists/*

RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && locale-gen

# Add a script that we will use to correct permissions after running certain commands
ADD fix-permissions /usr/local/bin/fix-permissions

RUN conda install -y -c conda-forge libjpeg-turbo                            &&\
    CFLAGS="${CFLAGS} -mavx2"                                                &&\
    pip install --upgrade --no-cache-dir --force-reinstall --no-binary :all:   \
                --compile pillow-simd                                        &&\
    conda install -y -c zegami libtiff-libjpeg-turbo                         &&\
    conda install -y jpeg libtiff                                            &&\
    conda env update --file environment.yml                                  &&\
    conda clean --all -f -y                                                  &&\
    jupyter nbextension enable --py widgetsnbextension --sys-prefix          &&\
    jupyter labextension install @jupyter-widgets/jupyterlab-manager --no-build &&\
    jupyter labextension install @bokeh/jupyter_bokeh --no-build             &&\
    jupyter labextension install dask-labextension --no-build                &&\
    jupyter labextension install @pyviz/jupyterlab_pyviz --no-build          &&\
    jupyter labextension install jupyterlab_tensorboard --no-build           &&\
    jupyter labextension install jupyterlab-nvdashboard                      &&\
    jupyter lab build                                                       &&\
    jupyter lab clean                                                        &&\
    jlpm cache clean                                                         &&\
    npm cache clean --force                                                  &&\
    rm -rf $HOME/.node-gyp                                                   &&\
    rm -rf $HOME/.local                                                      &&\
    rm -rf $CONDA_DIR/share/jupyter/lab/staging 

# Import matplotlib the first time to build the font cache.
##ENV XDG_CACHE_HOME /home/$NB_USER/.cache/
RUN MPLBACKEND=Agg python -c "import matplotlib.pyplot" 

RUN mkdir -p /repos /data /glacier /glacier2 /scratch                        &&\
    chown -R $USER:$USER /repos /data /glacier /glacier2 /scratch

# Switch back to jovyan to avoid accidental container runs as root
##USER $NB_UID

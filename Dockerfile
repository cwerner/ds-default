FROM nvcr.io/nvidia/pytorch:21.07-py3
LABEL maintainer="Christian Werner <christian.werner@kit.edu>"

ARG NB_USER="jovyan"
ARG NB_UID="1000"
ARG NB_GID="100"

USER root

WORKDIR /    

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Berlin

RUN apt-get update && apt-get -yq dist-upgrade                               &&\
    apt-get install -yq --no-install-recommends wget bzip2 ca-certificates     \
                                                sudo locales fonts-liberation  \
                                                run-one awscli               &&\
    rm -rf /var/lib/apt/lists/*

RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && locale-gen

# Add a script that we will use to correct permissions after running certain commands
ADD fix-permissions /usr/local/bin/fix-permissions

COPY environment.yml ./

#
RUN conda env update --file environment.yml && \
    conda clean --all -f -y

COPY entrypoint.sh /usr/bin/entrypoint.sh 

RUN MPLBACKEND=Agg python -c "import matplotlib.pyplot" 

RUN mkdir -p /repos /data /glacier /glacier2 /scratch                        &&\
    chown -R $USER:$USER /repos /data /glacier /glacier2 /scratch


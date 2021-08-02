FROM nvcr.io/nvidia/pytorch:21.07-py3
LABEL maintainer="Christian Werner <christian.werner@kit.edu>"

ARG NB_USER="jovyan"
ARG NB_UID="1000"
ARG NB_GID="100"

USER root

WORKDIR /    

COPY environment.pytorch-base.yml ./environment.yml
COPY entrypoint.sh /usr/bin/entrypoint.sh

RUN --mount=type=secret,id=AWS_ACCESS_KEY_ID                                   \
    --mount=type=secret,id=AWS_SECRET_ACCESS_KEY                               \
    export AWS_ACCESS_KEY_ID=$(cat /run/secrets/AWS_ACCESS_KEY_ID)           &&\
    export AWS_SECRET_ACCESS_KEY=$(cat /run/secrets/AWS_SECRET_ACCESS_KEY)   &&\
    apt-get update && apt-get -yq dist-upgrade                               &&\
    apt-get install -yq --no-install-recommends wget bzip2 ca-certificates     \
                                                sudo locales fonts-liberation  \
                                                run-one awscli               &&\
    rm -rf /var/lib/apt/lists/*

RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && locale-gen

# Add a script that we will use to correct permissions after running certain commands
ADD fix-permissions /usr/local/bin/fix-permissions

#
RUN conda env update --file environment.yml && \
    conda clean --all -f -y

RUN MPLBACKEND=Agg python -c "import matplotlib.pyplot" 

RUN mkdir -p /repos /data /glacier /glacier2 /scratch                        &&\
    chown -R $USER:$USER /repos /data /glacier /glacier2 /scratch


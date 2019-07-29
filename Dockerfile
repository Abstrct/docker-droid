# Base image
FROM ubuntu:18.04

# Information
LABEL maintainer="Abstrct <josh@coindroids.com>"

# Variables
#ENV CD_API=api.coindroids.com 
  

# Install packages
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
        build-essential \
        git \
        perl \
        sqlite3 \
        libsqlite3-dev \
        jq \
        wget \
        tar \ 
        curl \
        bc \
        vim && \
    rm -rf /var/lib/apt/lists/*


WORKDIR /src
# Add the user and groups appropriately
RUN addgroup --system droid && \
    adduser --system --home /src/droid --shell /bin/bash --group droid 


# Clone down defcoin client
COPY client/bin/* /src/droid/client/bin/
COPY client/lib/* /src/droid/client/lib/
COPY client/share/* /src/droid/client/share/
COPY client/include/* /src/droid/client/include/

COPY client/data/* /src/droid/client/data/



# Setup droid process
COPY droid/droid.sh /src/droid/droid.sh


COPY droid/initiate_systems.sh /src/droid/initiate_systems.sh


RUN chown -R droid /src/droid && \
    chgrp -R droid /src/droid 


# Expose ports
EXPOSE 1338 

CMD /src/droid/initiate_systems.sh


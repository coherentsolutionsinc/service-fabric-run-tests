FROM ubuntu:16.04 AS build

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 417A0893

RUN apt-get update && \
    apt-get install --assume-yes wget curl lsb-release apt-transport-https

RUN wget -q https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb && \
    dpkg -i packages-microsoft-prod.deb

RUN curl -fsSL https://packages.microsoft.com/keys/msopentech.asc | apt-key add - && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

RUN apt-get update && \
    apt-get download servicefabric=7.2.476.1 && \
    dpkg -x servicefabric_7.2.476.1_amd64.deb .

# deleting unnecessary files to reduce image size
RUN find "/opt/microsoft/servicefabric/bin/Fabric/Fabric.Code" -name "*.exe" -type f -delete && \
    find "/opt/microsoft/servicefabric/bin/Fabric/Fabric.Code" -name "*.pdb" -type f -delete && \
    find "/opt/microsoft/servicefabric/bin/Fabric/Fabric.Code" -name "SFBlockStoreService" -type f -delete && \
    find "/opt/microsoft/servicefabric/bin/Fabric/Fabric.Code" -name "__FabricSystem_App*" -type d -exec rm -rf {} +;

RUN mkdir /etc/servicefabric && \
    echo -n /home/sfuser/sfdevcluster/data > /etc/servicefabric/FabricDataRoot && \
    echo -n /home/sfuser/sfdevcluster/data/log > /etc/servicefabric/FabricLogRoot && \
    echo -n /opt/microsoft/servicefabric/bin > /etc/servicefabric/FabricBinRoot && \
    echo -n /opt/microsoft/servicefabric/bin/Fabric/Fabric.Code > /etc/servicefabric/FabricCodePath

FROM ubuntu:16.04

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 417A0893 && \
    apt-get update && \
    apt-get install --assume-yes apt-transport-https && \
    apt-get install --assume-yes libssh2-1 && \
    apt-get install --assume-yes libxml2 && \
    apt-get install --assume-yes cgroup-bin

COPY --from=build /etc/servicefabric /etc/servicefabric
COPY --from=build /opt/microsoft/servicefabric/bin/Fabric/Fabric.Code /opt/microsoft/servicefabric/bin/Fabric/Fabric.Code

ENV LD_LIBRARY_PATH=/opt/microsoft/servicefabric/bin/Fabric/Fabric.Code
# base image
FROM python:3.8-slim-buster

# Labels
LABEL maintainer="@vMarkus_K"

# Install packages
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -y install openssh-server git && \
    apt-get clean all


RUN sed -i s/#PermitRootLogin.*/PermitRootLogin\ yes/ /etc/ssh/sshd_config \
    && echo "root:root" | chpasswd \
    && sed -ie 's/#Port 22/Port 22/g' /etc/ssh/sshd_config \
    && sed -ri 's/#HostKey \/etc\/ssh\/ssh_host_key/HostKey \/etc\/ssh\/ssh_host_key/g' /etc/ssh/sshd_config \
    && sed -ir 's/#HostKey \/etc\/ssh\/ssh_host_rsa_key/HostKey \/etc\/ssh\/ssh_host_rsa_key/g' /etc/ssh/sshd_config \
    && sed -ir 's/#HostKey \/etc\/ssh\/ssh_host_dsa_key/HostKey \/etc\/ssh\/ssh_host_dsa_key/g' /etc/ssh/sshd_config \
    && sed -ir 's/#HostKey \/etc\/ssh\/ssh_host_ecdsa_key/HostKey \/etc\/ssh\/ssh_host_ecdsa_key/g' /etc/ssh/sshd_config \
    && sed -ir 's/#HostKey \/etc\/ssh\/ssh_host_ed25519_key/HostKey \/etc\/ssh\/ssh_host_ed25519_key/g' /etc/ssh/sshd_config \
    && /usr/bin/ssh-keygen -A \
    && ssh-keygen -t rsa -b 4096 -P "" -f  /etc/ssh/ssh_host_key

RUN pip3 install --upgrade pip setuptools wheel cffi lxml pyVmomi suds-jurko pyOpenSSL cryptography

RUN cd /opt && \
    git clone https://github.com/vmware/vsphere-automation-sdk-python.git && \
    cd vsphere-automation-sdk-python && \
    pip3 install --upgrade -r requirements.txt --extra-index-url file:///opt/vsphere-automation-sdk-python/lib && \
    rm -rf /opt/vsphere-automation-sdk-python

RUN pip3 install ansible && \
    pip3 install ansible-lint jmespath

RUN mkdir /ansible && \
    mkdir -p /etc/ansible && \
    echo 'localhost' > /etc/ansible/hosts

WORKDIR /ansible

EXPOSE 22
CMD ["/usr/sbin/sshd","-D"]

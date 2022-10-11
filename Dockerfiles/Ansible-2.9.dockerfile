# ---------------------------------------------------------------------------- #
#                   Docker Image for Testing Environment                       #
# ---------------------------------------------------------------------------- #
FROM python:3.7-slim-buster
WORKDIR /usr/src/app
# ------------- Environment Variables ------------- #
# * These paths will exist after volume mount performed by Jenkins
# Path to Ansible modules
ENV ANSIBLE_LIBRARY=${env.WORKSPACE}/${REPO}/plugins/modules/
# Path to Ansible config
ENV ANSIBLE_CONFIG=${env.WORKSPACE}/${REPO}/tests/ansible.cfg
COPY ${REPO}/tests/requirements.txt ./
# --------------------------- Package installation Stage 1 --------------------------- #
RUN apt-get update && apt-get install -y gnupg2 && apt-get update && apt-get install -y git python3-pip openssh-client ansible python2.7 python-pip && pip3 install --no-cache-dir -r requirements.txt && pip3 install ansible-lint yamllint pylint pytest-ansible virtualenv bandit
# ----------------------------- Copy dependencies ---------------------------- #
COPY ${REPO} ./${REPO}/
# --------------------------- Package installation Stage 2 --------------------------- #
# Update package info, install ansible and openssh
RUN cd ${REPO} && ansible-galaxy collection build . --force && ansible-galaxy collection install ibm-${REPO}* --force -p . && cd ansible_collections/ibm/${REPO}/ && ansible-test sanity --requirements || true
# It turns out that rstcheck needs to be version-locked, because 4.0+ deprecated python 3.7
RUN pip3 install rstcheck===3.3.1
# -------------------- Map UID and GID to Jenkins host IDs ------------------- #
ARG UNAME=jenkins
ARG UID=114
ARG GID=121
RUN groupadd -g $GID -o $UNAME
RUN useradd -m -u $UID -g $GID -o -s /bin/bash $UNAME
USER ${UNAME}
ENV PATH="/home/jenkins/.local/bin:${PATH}"
# ----------------------------- Configure SSH key ---------------------------- #
# Address of host to run tests against
ARG TARGET_HOST
# Private key contents that can be used to connect to TARGET_HOST
ARG TARGET_HOST_PRIVATE_KEY
RUN mkdir -p /home/jenkins/.ssh/
COPY --chown=jenkins:jenkins ${TARGET_HOST_PRIVATE_KEY} /home/jenkins/.ssh/id_rsa
# COPY --chown=jenkins:jenkins configuration.yml ./
# Add SSH key to system and ensure domain is accepted
RUN chmod 600 /home/jenkins/.ssh/id_rsa && \
    touch /home/jenkins/.ssh/known_hosts && \
    ssh-keyscan "${TARGET_HOST}" >> /home/jenkins/.ssh/known_hosts
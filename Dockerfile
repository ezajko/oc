FROM centos:8
RUN dnf install -y epel-release
RUN dnf install -y git python3-netaddr python3-pip libcurl-devel openssl-devel python3-pycurl libxml2-devel gcc python3-devel
RUN pip3 install --user 'ansible>=2.8,<2.9' ovirt-engine-sdk-python junit_xml
RUN echo export PATH=$PATH:$HOME/.local/bin > /etc/profile.d/local-path.sh
WORKDIR /data
ENV JUNIT_OUTPUT_DIR=.
RUN echo stdout_callback = junit >> ansible.cfg
CMD /root/.local/bin/ansible-playbook all.yaml -i inventory/test_hosts -e @test/answers-simple.yaml

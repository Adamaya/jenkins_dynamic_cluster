
# Website deployment Automation using Dynamic remote cluster:
To create an architecture that will Deploy the Website using Dynamic remote Clusters to manage the runtime duration and automation.
architecture is provisioned in such a way that when the developer will commit the his website code including Dockerfile to the GitHub, a jenkins job that is configured on remote Node will launch a dynamic distributed kubernates cluster that pull the code and build the docker image, an another job will launch the Web Server container and will Deploy the Website. If the developer modifies the code and again comit it, the Cluster will use its Rolling Updates feature to update the Website in the main Deployment Server, updating it with zero downtime.

![configure docker services](/readme_images/Untitled%20document%20(1).jpg)

This was a complete Architecture that will Deploy the Website and keep on updating it on runtime using Dynamic Distributed Clusters. One of the main advantage of having this kind of architecture is that as soon as the Containers are Deployed, the remote Clusters get shut down immediately so that there is no wastage of resources. Hence they are termed as Dynamic Distributed Clusters.

## Prerequisites:

- RedHat 8 VM configured on your virtual machine.
- Minikube installed on your base operating system.
- kubectl must be downloaded and given execution access.
- Jenkins must be configured on your Redhat 8 VM
- Docker must be installed your Redhat 8 VM.
- Git/GitHub account must be configured.


## Steps to implement the Project

- Set up the GitHub account and configure it accordingly from the Git.

- Create a Docker image having Kubectl configured in it, using Dockerfile. 

**Note: kubectl must be downloaded and copied to the same folder. it must have executive access.**

K8s Dockerfile:
```
FROM centos

RUN yum install sudo -y
RUN yum install java -y
RUN yum install git -y
RUN yum install openssh-server -y
RUN mkdir /var/run/sshd

#for changing root pasword
RUN echo 'root:root' | chpasswd
RUN ssh-keygen -A

# for configuring kubectl
COPY kubectl /usr/bin
# add your client.key, client.crt and ca.crt
COPY client.key /root
COPY client.crt /root
COPY ca.crt /root
RUN mkdir .kube
COPY .kube /root/.kube

EXPOSE 22
CMD [ "/usr/sbin/sshd", "-D" ]
```


- create a Docker image having Web Server configured inside it

Webserver Dockerfile:

```
FROM centos:8

RUN yum install httpd -y
RUN yum install php -y

COPY * /var/www/html/

EXPOSE 80

CMD /usr/sbin/httpd -DFOREGROUND
```


- We need to configure Docker Service from the localhost to work as a Client and not as a Server. To configure edit the file /usr/lib/systemd/system/docker.service as follows:

`vim /usr/lib/systemd/system/docker.service `

add line:

![configure docker services](/readme_images/dconf.JPG)


This will allow any port to access the Docker service remotely from other systems. Enter the following command in the remote system:

`export DOCKER_HOST=192.168.99.103:2375`


- open the Jenkins WebUI to configure the Clouds and Nodes before configuring our Jobs

**Go to Manage Jenkins > Manage Nodes and Clouds > Configure Clouds > Add a new Cloud > Docker**

Set the Credentials as follows:

Set any name and enter the Docker Host URL of the remote Cluster along with the Port number you have set while configuring the Docker.

![configure cloud nodes](/readme_images/configcloud.JPG)

Set the Image name built using the Kubernetes Dockerfile

![configure cloud nodes](/readme_images/configcloud1.JPG)
![configure cloud nodes](/readme_images/configcloud2.JPG)


Once done create two Jobs in Jenkins- Developer Job and the Kubernetes_Deployment Job

Job1: Developer

This Job will pull the GitHub repo and download the Dockerfile and the Website. On downloading the Dockerfile, it will build the respective Docker image on runtime.

![configure job1](/readme_images/1.JPG)
![configure job1](/readme_images/2.JPG)

**Note:- change image name according to your dockerhub ID.**

![configure job1](/readme_images/3.JPG)



Once the Developer job gets stable, it will create a Docker image for our Web Server, copy the Website code inside it and at the same time push it in the Docker Hub repository.

![configure job1](/readme_images/4.JPG)
![configure job1](/readme_images/5.JPG)

This will trigger the Second Job Kubernetes_Deployment.

**Job 2: Deployment**

This job will match the labels we used to configure the job and will launch the Cloud Node accordingly.
**Note:- change image name according to your dockerhub image.**

![configure job2](/readme_images/6.JPG)

 it will create Deployments using the Container created using Image built in the Developer Job. It will expose the Deployments and will keep on updating the Containers as soon as the developer commits the updated code again on the GitHub.

## How to Test
- build an pipeline view for better visual.
- execute job 1 and moniter the pipeline.

![configure job2](/readme_images/7.JPG)

## Common problem that may Occur.
- enter `setenforce 0` command for dissabling firewall in your RHEL VM.
- start your minikube by entring `minikube start` .

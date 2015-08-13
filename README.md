This is the Docker image for Apache Bloodhound, an issues tracking and managing of software projects. 
The image includes postgresql database, apache2 web server, and apache bloodhound.

Building docker image, the image name is bloodhound, for example:
    
    git clone  https://github.com/quinghui/docker-bloodhound.git
    cd docker-bloodhound
    docker build -t bloodhound .

Executing docker with the image:

    docker run -d -p 8080:8080 bloodhound

the Bloodhound link, if running on local: 
    
    http://localhost:8080/bloodhound

Admin user & passwd: 
    
    admin/password


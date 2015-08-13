This is the Docker image for Apache Bloodhound. 
The image includes postgres database, apache2 web server, and apache bloodhound
issue tracking and managing of software projects.

Building docker image, the image name is bloodhound, for example:
    
    docker build -t bloodhound .

Executing docker with the image:

    docker run -d -p 8080:8080 bloodhound

Admin user & passwd: 
    
    admin/password


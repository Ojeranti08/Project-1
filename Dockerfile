# Use an official Tomcat runtime as the base image
FROM tomcat:latest

# Remove the existing contents of the Tomcat webapps directory
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy the WAR file from the target directory to Tomcat webapps
COPY target/*.war /usr/local/tomcat/webapps/

EXPOSE 8080
#CMD ["catalina.sh", "run"]
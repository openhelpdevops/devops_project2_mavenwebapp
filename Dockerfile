FROM tomcat:latest
MAINTAINER Sreejith <sreejithedl@gmail.com>
EXPOSE 8080
COPY target/maven-web-app.war /usr/local/tomcat/webapps/maven-web-app.war

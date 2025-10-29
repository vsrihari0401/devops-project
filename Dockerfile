FROM tomcat:9-jdk17
LABEL maintainer="vsriharisrihari9@gmail.com"
RUN rm -rf /usr/local/tomcat/webapps/ROOT
COPY target/*.war /usr/local/tomcat/webapps/ROOT.war
EXPOSE 8084
CMD ["catalina.sh", "run"]

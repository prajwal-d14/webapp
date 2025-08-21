FROM openjdk:17-alpine
WORKDIR /app

ARG BUILD_NUMBER
ARG NEXUS_IP

RUN apk add --no-cache curl && \
    curl -v -o webapp.jar "http://${NEXUS_IP}:31020/repository/bankartifact-repo/webapp-${BUILD_NUMBER}.jar"
ENTRYPOINT ["java", "-jar", "/app/webapp.jar"]
EXPOSE 8081

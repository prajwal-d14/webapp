FROM openjdk:17-alpine
WORKDIR /app
RUN apk add --no-cache curl && \
    curl -u admin:'!Keep0ut!' -O ""http://$13.127.150.83:31020/repository/bankartifact-repo/webapp-1.jar""
ENTRYPOINT ["java", "-jar", "/app/webapp.jar"]
EXPOSE 8081

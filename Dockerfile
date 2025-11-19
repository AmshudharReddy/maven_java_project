# Build stage (optional here as we build jar with Maven in Jenkins agent)
FROM openjdk:17-jdk-slim AS runtime
WORKDIR /app


# Copy the jar produced by the Maven build
# The Jenkins pipeline will create target/jenkins-starter-1.0.0.jar
COPY target/jenkins-starter-1.0.0.jar /app/app.jar


EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
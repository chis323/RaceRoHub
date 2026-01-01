
FROM maven:3.9.9-eclipse-temurin-17 AS build
WORKDIR /app

COPY pom.xml .
COPY .mvn .mvn
COPY mvnw mvnw
RUN chmod +x mvnw && ./mvnw -q -DskipTests dependency:go-offline

# Copy source and build
COPY src src
RUN ./mvnw -DskipTests clean package

# -------- RUNTIME STAGE --------
FROM eclipse-temurin:17-jre
WORKDIR /app

# Render exposes PORT, but 8080 is fine locally
EXPOSE 8080

# Create upload directory (ephemeral)
RUN mkdir -p /tmp/uploads

# Copy jar from build stage
COPY --from=build /app/target/*.jar app.jar

# JVM safety for small containers
ENV JAVA_TOOL_OPTIONS="-XX:MaxRAMPercentage=75"

CMD ["java", "-jar", "app.jar"]

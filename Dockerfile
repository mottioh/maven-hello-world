# ===== Stage 1: Build the application =====
FROM maven:3.9.6-eclipse-temurin-17 AS mavenbase

WORKDIR /app

# Copy the pom.xml and download dependencies first (caching optimization)
COPY myapp/pom.xml .
RUN mvn dependency:go-offline

# Copy the rest of the project files
COPY myapp/ .

# Build the application
RUN mvn clean package -DskipTests

# ===== Stage 2: Create a lightweight runtime image =====
FROM eclipse-temurin:17-jre-alpine

# Create a non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

WORKDIR /app
COPY --from=mavenbase /app/target/myapp-*.jar /app/myapp.jar

# Define ENTRYPOINT as the base command
ENTRYPOINT ["java", "-jar", "/app/myapp.jar"]

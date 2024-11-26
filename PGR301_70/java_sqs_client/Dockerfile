# bygg
FROM maven:3.8.8-eclipse-temurin-17-alpine AS builder

# sett workdir i build
WORKDIR /app

# kopier prosjektfiler
COPY . .

# Bygg JAR-filen
RUN mvn clean package

# lightweight 
FROM eclipse-temurin:17-jre-alpine

# sett workdir i runtime
WORKDIR /app

# kopier fil fra bygg
COPY --from=builder /app/target/imagegenerator-0.0.1-SNAPSHOT.jar app.jar

# miljøvariabel 
ENV SQS_QUEUE_URL="https://sqs.eu-west-1.amazonaws.com/244530008913/image-processing-queue-70"

# kjøre app
ENTRYPOINT ["java", "-jar", "app.jar"]

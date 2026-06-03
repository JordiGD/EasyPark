# Multi-stage build for subscription-service
FROM maven:3.9-eclipse-temurin-21-alpine as builder

WORKDIR /app

# Copiar pom.xml
COPY pom.xml .

# Descargar dependencias
RUN mvn dependency:resolve

# Copiar código fuente
COPY src/ src/

# Compilar aplicación
RUN mvn clean package -DskipTests

# Stage final
FROM eclipse-temurin:21-jre-alpine

WORKDIR /app

# Copiar JAR desde builder
COPY --from=builder /app/target/subscription-0.0.1-SNAPSHOT.jar subscription-service.jar

# Puerto
EXPOSE 8083

# Ejecutar aplicación
ENTRYPOINT ["java", "-jar", "subscription-service.jar"]

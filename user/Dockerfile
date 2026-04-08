# Dockerfile para Backend (Spring Boot)
FROM maven:3.9-eclipse-temurin-21-alpine AS builder

WORKDIR /app

# Copiar archivos de configuración Maven
COPY pom.xml .
COPY mvnw .
COPY .mvn .mvn

# Copiar código fuente
COPY src ./src

# Build de la aplicación
RUN mvn clean package -DskipTests

# Stage de runtime
FROM eclipse-temurin:21-jre-alpine

WORKDIR /app

# Copiar JAR desde el builder
COPY --from=builder /app/target/*.jar app.jar

# Exponer puerto
EXPOSE 8080

# Comando para ejecutar la app
ENTRYPOINT ["java", "-jar", "app.jar"]

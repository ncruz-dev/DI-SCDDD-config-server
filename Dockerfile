FROM maven:3.9-eclipse-temurin-21 AS build

WORKDIR /config-server

COPY pom.xml .
RUN mvn -B -q -e -DskipTests dependency:go-offline

COPY src ./src

RUN mvn clean package -DskipTests

FROM eclipse-temurin:21-jre-jammy
WORKDIR /config-server

RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

COPY --from=build /config-server/target/*.jar config-server.jar

EXPOSE 7777

ENTRYPOINT ["java", "-jar", "config-server.jar"]

HEALTHCHECK --interval=30s --timeout=5s \
  CMD curl -f http://localhost:7777/actuator/health || exit 1

FROM maven:3.9.8-eclipse-temurin-17 AS build
WORKDIR /workspace
COPY pom.xml ./
COPY src ./src
RUN mvn -q -B -DskipTests package

FROM eclipse-temurin:17-jre-jammy
WORKDIR /app
COPY --from=build /workspace/target/api-0.1.0-MVP.jar ./api.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "api.jar"]

FROM maven:3.9.8-eclipse-temurin-17 AS build
WORKDIR /workspace
COPY pom.xml ./
RUN mvn dependency:go-offline -q -B
COPY src ./src
RUN mvn -q -B -DskipTests package

FROM eclipse-temurin:17-jre-jammy
WORKDIR /app
RUN addgroup --system app && adduser --system --ingroup app app
COPY --from=build /workspace/target/*.jar ./api.jar
EXPOSE 8080
USER app
ENTRYPOINT ["java", "-XX:MaxRAMPercentage=75.0", "-jar", "api.jar"]

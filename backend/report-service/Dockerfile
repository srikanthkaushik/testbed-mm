FROM eclipse-temurin:21-jre-jammy
WORKDIR /app
ARG JAR_FILE=*.jar
COPY ${JAR_FILE} app.jar
RUN useradd -r -u 1001 -g root appuser && chown appuser app.jar
USER appuser
ENTRYPOINT ["sh", "-c", "exec java ${JAVA_OPTS} -Djava.security.egd=file:/dev/./urandom -jar app.jar"]

FROM amazoncorretto:11.0.9-alpine

RUN wget -O dd-java-agent.jar 'https://repository.sonatype.org/service/local/repositories/central-proxy/content/com/datadoghq/dd-java-agent/0.72.0/dd-java-agent-0.72.0.jar'

ARG DEPENDENCY=build/dependency
COPY ${DEPENDENCY}/BOOT-INF/lib /app/lib
COPY ${DEPENDENCY}/META-INF /app/META-INF
COPY ${DEPENDENCY}/BOOT-INF/classes /app
ENTRYPOINT ["java", "-javaagent:dd-java-agent.jar", "-cp" , "app:app/lib/*", "template.App"]
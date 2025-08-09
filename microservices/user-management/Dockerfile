FROM eclipse-temurin:17-jre-alpine as builder
WORKDIR /app
COPY build/libs/*.jar app.jar
RUN java -Djarmode=layertools -jar app.jar extract

FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

# Add non-root user
RUN addgroup --system --gid 1001 appuser && \
    adduser --system --uid 1001 --ingroup appuser appuser

# Copy layers from builder stage
COPY --from=builder /app/dependencies/ ./
COPY --from=builder /app/spring-boot-loader/ ./
COPY --from=builder /app/snapshot-dependencies/ ./
COPY --from=builder /app/application/ ./

# Security hardening
RUN apk add --no-cache tzdata && \
    rm -rf /var/cache/apk/*

# Set permissions
RUN chown -R appuser:appuser /app
USER appuser

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=30s --retries=3 \
  CMD wget -q --spider http://localhost:8080/api/v1/actuator/health || exit 1

# Run the application
ENTRYPOINT ["java", "org.springframework.boot.loader.JarLauncher"]
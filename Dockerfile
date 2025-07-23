FROM openjdk:17-jdk-slim

# Set working directory
WORKDIR /app

# Install wget and curl
RUN apt-get update && apt-get install -y wget curl && rm -rf /var/lib/apt/lists/*

# Download GraphHopper JAR
RUN wget https://repo1.maven.org/maven2/com/graphhopper/graphhopper-web/10.0/graphhopper-web-10.0.jar -O graphhopper-web.jar

# Create data directory
RUN mkdir -p /app/data

# Create optimized config for your 256GB server
RUN cat > /app/config.yml << 'EOF'
graphhopper:
  datareader.file: /app/data/australian_capital_territory-latest.osm.pbf
  graph.location: /app/data/graph-cache
  graph.dataaccess.default_type: RAM_STORE
  graph.encoded_values: road_class,road_class_link,road_environment,max_speed,road_access
  prepare.lm.landmarks: 64
  profiles:
    - name: car
      custom_model_files: [car.json]
  profiles_ch:
    - profile: car
  profiles_lm:
    - profile: car
  prepare.min_network_size: 200

server:
  application_connectors:
    - type: http
      port: 8989
      bind_host: 0.0.0.0
  admin_connectors:
    - type: http
      port: 8990
      bind_host: 0.0.0.0

logging:
  appenders:
    - type: console
      time_zone: UTC
      log_format: "%d{yyyy-MM-dd HH:mm:ss.SSS} [%thread] %-5level %logger{36} - %msg%n"
EOF

# Expose port
EXPOSE 8989

# Set Java memory options for your 256GB server
ENV JAVA_OPTS="-Xmx32g -Xms8g -XX:+UseG1GC -XX:MaxGCPauseMillis=200"

# Download OSM data and start GraphHopper
CMD ["sh", "-c", "wget -O /app/data/australian_capital_territory-latest.osm.pbf https://osmextracts.findnearest.com.au/australian_capital_territory-latest.osm.pbf && java $JAVA_OPTS -jar graphhopper-web.jar server config.yml"]
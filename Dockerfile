FROM openjdk:17-jdk-slim

# Set working directory
WORKDIR /app

# Install wget and curl
RUN apt-get update && apt-get install -y wget curl && rm -rf /var/lib/apt/lists/*

# Download GraphHopper JAR
RUN wget https://repo1.maven.org/maven2/com/graphhopper/graphhopper-web/10.0/graphhopper-web-10.0.jar -O graphhopper-web.jar

# Create data directory
RUN mkdir -p /app/data

# Create config with car and truck profiles using VALID encoded values
RUN echo 'graphhopper:' > /app/config.yml && \
    echo '  datareader.file: /app/data/australian_capital_territory-latest.osm.pbf' >> /app/config.yml && \
    echo '  graph.location: /app/data/graph-cache' >> /app/config.yml && \
    echo '  graph.dataaccess.default_type: RAM_STORE' >> /app/config.yml && \
    echo '  graph.encoded_values: road_class, road_class_link, road_environment, max_speed, road_access, car_access, car_average_speed, hgv, max_width, max_height, max_weight' >> /app/config.yml && \
    echo '  graph.elevation.provider: srtm' >> /app/config.yml && \
    echo '  graph.elevation.cache_dir: /app/data/elevation-cache' >> /app/config.yml && \
    echo '  graph.elevation.dataaccess: MMAP' >> /app/config.yml && \
    echo '  graph.elevation.interpolate: bilinear' >> /app/config.yml && \
    echo '  prepare.lm.landmarks: 64' >> /app/config.yml && \
    echo '  import.osm.ignored_highways: footway,cycleway,path,pedestrian,steps' >> /app/config.yml && \
    echo '  profiles:' >> /app/config.yml && \
    echo '    - name: car' >> /app/config.yml && \
    echo '      custom_model_files: [car.json]' >> /app/config.yml && \
    echo '      turn_costs:' >> /app/config.yml && \
    echo '        vehicle_types: [motorcar, motor_vehicle]' >> /app/config.yml && \
    echo '        u_turn_costs: 60' >> /app/config.yml && \
    echo '    - name: truck' >> /app/config.yml && \
    echo '      custom_model_files: [truck.json]' >> /app/config.yml && \
    echo '      turn_costs:' >> /app/config.yml && \
    echo '        vehicle_types: [hgv, motor_vehicle]' >> /app/config.yml && \
    echo '        u_turn_costs: 120' >> /app/config.yml && \
    echo '  profiles_ch:' >> /app/config.yml && \
    echo '    - profile: car' >> /app/config.yml && \
    echo '    - profile: truck' >> /app/config.yml && \
    echo '  profiles_lm:' >> /app/config.yml && \
    echo '    - profile: car' >> /app/config.yml && \
    echo '    - profile: truck' >> /app/config.yml && \
    echo '  prepare.min_network_size: 200' >> /app/config.yml && \
    echo '' >> /app/config.yml && \
    echo 'server:' >> /app/config.yml && \
    echo '  application_connectors:' >> /app/config.yml && \
    echo '    - type: http' >> /app/config.yml && \
    echo '      port: 8989' >> /app/config.yml && \
    echo '      bind_host: 0.0.0.0' >> /app/config.yml && \
    echo '  admin_connectors:' >> /app/config.yml && \
    echo '    - type: http' >> /app/config.yml && \
    echo '      port: 8990' >> /app/config.yml && \
    echo '      bind_host: 0.0.0.0' >> /app/config.yml && \
    echo '' >> /app/config.yml && \
    echo 'logging:' >> /app/config.yml && \
    echo '  appenders:' >> /app/config.yml && \
    echo '    - type: console' >> /app/config.yml && \
    echo '      time_zone: UTC' >> /app/config.yml && \
    echo '      log_format: "%d{yyyy-MM-dd HH:mm:ss.SSS} [%thread] %-5level %logger{36} - %msg%n"' >> /app/config.yml

# Expose port
EXPOSE 8989

# Set Java memory options for your 256GB server
ENV JAVA_OPTS="-Xmx32g -Xms8g -XX:+UseG1GC -XX:MaxGCPauseMillis=200"

# Simple startup command
CMD ["sh", "-c", "wget -O /app/data/australian_capital_territory-latest.osm.pbf https://osmextracts.findnearest.com.au/australian_capital_territory-latest.osm.pbf || true && java $JAVA_OPTS -jar graphhopper-web.jar server config.yml"]
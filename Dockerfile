FROM openjdk:17-jdk-slim

# Set working directory
WORKDIR /app

# Install wget and curl
RUN apt-get update && apt-get install -y wget curl && rm -rf /var/lib/apt/lists/*

# Download GraphHopper JAR
RUN wget https://repo1.maven.org/maven2/com/graphhopper/graphhopper-web/10.0/graphhopper-web-10.0.jar -O graphhopper-web.jar

# Create data directory
RUN mkdir -p /app/data

# Create car_custom.json custom model that prefers motorways and discourages U-turns
RUN echo '{' > /app/car_custom.json && \
    echo '  "priority": [' >> /app/car_custom.json && \
    echo '    {' >> /app/car_custom.json && \
    echo '      "if": "road_class == MOTORWAY",' >> /app/car_custom.json && \
    echo '      "multiply_by": "1.3"' >> /app/car_custom.json && \
    echo '    },' >> /app/car_custom.json && \
    echo '    {' >> /app/car_custom.json && \
    echo '      "if": "road_class == TRUNK",' >> /app/car_custom.json && \
    echo '      "multiply_by": "1.2"' >> /app/car_custom.json && \
    echo '    },' >> /app/car_custom.json && \
    echo '    {' >> /app/car_custom.json && \
    echo '      "if": "road_class == PRIMARY",' >> /app/car_custom.json && \
    echo '      "multiply_by": "1.1"' >> /app/car_custom.json && \
    echo '    },' >> /app/car_custom.json && \
    echo '    {' >> /app/car_custom.json && \
    echo '      "if": "road_environment == BRIDGE || road_environment == TUNNEL",' >> /app/car_custom.json && \
    echo '      "multiply_by": "0.9"' >> /app/car_custom.json && \
    echo '    }' >> /app/car_custom.json && \
    echo '  ],' >> /app/car_custom.json && \
    echo '  "speed": [' >> /app/car_custom.json && \
    echo '    {' >> /app/car_custom.json && \
    echo '      "if": "road_class == MOTORWAY",' >> /app/car_custom.json && \
    echo '      "limit_to": "130"' >> /app/car_custom.json && \
    echo '    },' >> /app/car_custom.json && \
    echo '    {' >> /app/car_custom.json && \
    echo '      "if": "road_class == TRUNK",' >> /app/car_custom.json && \
    echo '      "limit_to": "110"' >> /app/car_custom.json && \
    echo '    }' >> /app/car_custom.json && \
    echo '  ],' >> /app/car_custom.json && \
    echo '  "distance_influence": 70' >> /app/car_custom.json && \
    echo '}' >> /app/car_custom.json

# Create truck_custom.json custom model
RUN echo '{' > /app/truck_custom.json && \
    echo '  "priority": [' >> /app/truck_custom.json && \
    echo '    {' >> /app/truck_custom.json && \
    echo '      "if": "road_class == MOTORWAY",' >> /app/truck_custom.json && \
    echo '      "multiply_by": "1.2"' >> /app/truck_custom.json && \
    echo '    },' >> /app/truck_custom.json && \
    echo '    {' >> /app/truck_custom.json && \
    echo '      "if": "road_class == TRUNK",' >> /app/truck_custom.json && \
    echo '      "multiply_by": "1.1"' >> /app/truck_custom.json && \
    echo '    },' >> /app/truck_custom.json && \
    echo '    {' >> /app/truck_custom.json && \
    echo '      "if": "max_width < 3.0",' >> /app/truck_custom.json && \
    echo '      "multiply_by": "0"' >> /app/truck_custom.json && \
    echo '    },' >> /app/truck_custom.json && \
    echo '    {' >> /app/truck_custom.json && \
    echo '      "if": "max_height < 4.0",' >> /app/truck_custom.json && \
    echo '      "multiply_by": "0"' >> /app/truck_custom.json && \
    echo '    }' >> /app/truck_custom.json && \
    echo '  ],' >> /app/truck_custom.json && \
    echo '  "speed": [' >> /app/truck_custom.json && \
    echo '    {' >> /app/truck_custom.json && \
    echo '      "if": "road_class == MOTORWAY",' >> /app/truck_custom.json && \
    echo '      "limit_to": "100"' >> /app/truck_custom.json && \
    echo '    },' >> /app/truck_custom.json && \
    echo '    {' >> /app/truck_custom.json && \
    echo '      "if": "road_class == TRUNK",' >> /app/truck_custom.json && \
    echo '      "limit_to": "90"' >> /app/truck_custom.json && \
    echo '    }' >> /app/truck_custom.json && \
    echo '  ],' >> /app/truck_custom.json && \
    echo '  "distance_influence": 80' >> /app/truck_custom.json && \
    echo '}' >> /app/truck_custom.json

# Create improved config with turn costs and motorway preference
RUN echo 'graphhopper:' > /app/config.yml && \
    echo '  datareader.file: /app/data/new-south-wales-latest.osm.pbf' >> /app/config.yml && \
    echo '  graph.location: /app/data/graph-cache' >> /app/config.yml && \
    echo '  graph.dataaccess.default_type: RAM_STORE' >> /app/config.yml && \
    echo '  graph.encoded_values: road_class, road_class_link, road_environment, max_speed, road_access, car_access, car_average_speed, hgv, max_width, max_height, max_weight, toll' >> /app/config.yml && \
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

# Set Java memory options
ENV JAVA_OPTS="-Xmx32g -Xms8g -XX:+UseG1GC -XX:MaxGCPauseMillis=200"

# Simple startup: download once and start
CMD ["sh", "-c", "wget -O /app/data/new-south-wales-latest.osm.pbf https://osmextracts.findnearest.com.au/new_south_wales-latest.osm.pbf || true && java $JAVA_OPTS -jar graphhopper-web.jar server config.yml"]
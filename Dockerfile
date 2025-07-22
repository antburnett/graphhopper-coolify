FROM openjdk:17-jdk-slim

# Set working directory
WORKDIR /app

# Install wget and curl
RUN apt-get update && apt-get install -y wget curl && rm -rf /var/lib/apt/lists/*

# Download GraphHopper JAR and config
RUN wget https://repo1.maven.org/maven2/com/graphhopper/graphhopper-web/10.0/graphhopper-web-10.0.jar -O graphhopper-web.jar
RUN wget https://raw.githubusercontent.com/graphhopper/graphhopper/10.x/config-example.yml -O config-example.yml

# Create data directory
RUN mkdir -p /app/data

# Create optimized config for your 256GB server
RUN echo 'graphhopper:\n\
  datareader.file: /app/data/australian_capital_territory-latest.osm.pbf\n\
  graph.location: /app/data/graph-cache\n\
  graph.dataaccess: RAM_STORE\n\
  graph.encoded_values: road_class,road_class_link,road_environment,max_speed,road_access\n\
  prepare.lm.active: true\n\
  prepare.lm.landmarks: 64\n\
  prepare.ch.weightings: fastest\n\
  profiles:\n\
    - name: car\n\
      vehicle: car\n\
      weighting: fastest\n\
      turn_costs: true\n\
    - name: bike\n\
      vehicle: bike\n\
      weighting: fastest\n\
    - name: foot\n\
      vehicle: foot\n\
      weighting: fastest\n\
server:\n\
  application_connectors:\n\
    - type: http\n\
      port: 8989\n\
      bind_host: 0.0.0.0' > /app/config.yml

# Expose port
EXPOSE 8989

# Set Java memory options for your 256GB server
ENV JAVA_OPTS="-Xmx32g -Xms8g -XX:+UseG1GC -XX:MaxGCPauseMillis=200"

# Download OSM data and start GraphHopper
CMD ["sh", "-c", "wget -O /app/data/australian_capital_territory-latest.osm.pbf https://download.openstreetmap.fr/extracts/oceania/australia/australian_capital_territory-latest.osm.pbf && java $JAVA_OPTS -jar graphhopper-web.jar server config.yml"]
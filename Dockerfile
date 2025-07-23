FROM openjdk:17-jdk-slim

# Set working directory
WORKDIR /app

# Install wget and curl
RUN apt-get update && apt-get install -y wget curl && rm -rf /var/lib/apt/lists/*

# Download GraphHopper JAR and official config
RUN wget https://repo1.maven.org/maven2/com/graphhopper/graphhopper-web/10.0/graphhopper-web-10.0.jar -O graphhopper-web.jar
RUN wget https://raw.githubusercontent.com/graphhopper/graphhopper/10.x/config-example.yml -O config.yml

# Create data directory
RUN mkdir -p /app/data

# Modify the config to use our ACT data file and optimize for your 256GB server
RUN sed -i 's|datareader.file:.*|datareader.file: /app/data/australian_capital_territory-latest.osm.pbf|' config.yml && \
    sed -i 's|graph.location:.*|graph.location: /app/data/graph-cache|' config.yml && \
    sed -i 's|graph.dataaccess:.*|graph.dataaccess: RAM_STORE|' config.yml

# Expose port
EXPOSE 8989

# Set Java memory options for your 256GB server
ENV JAVA_OPTS="-Xmx32g -Xms8g -XX:+UseG1GC -XX:MaxGCPauseMillis=200"

# Download OSM data and start GraphHopper
# CMD ["sh", "-c", "wget -O /app/data/australian_capital_territory-latest.osm.pbf https://download.openstreetmap.fr/extracts/oceania/australia/australian_capital_territory-latest.osm.pbf && java $JAVA_OPTS -jar graphhopper-web.jar server config.yml"]
CMD ["sh", "-c", "wget -O /app/data/australian_capital_territory-latest.osm.pbf https://osmextracts.findnearest.com.au/australian_capital_territory-latest.osm.pbf && java $JAVA_OPTS -jar graphhopper-web.jar server config.yml"]
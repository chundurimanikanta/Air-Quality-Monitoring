

apiKey = '';              % OpenWeatherMap API Key
city = input('Enter the city name: ', 's');  % City Name
channelID = 2969963;                  % ThingSpeak Channel ID 
writeAPIKey = '';   % ThingSpeak Write API Key

% === Step 1: Get City Coordinates ===
geoURL = sprintf('http://api.openweathermap.org/geo/1.0/direct?q=%s&limit=1&appid=%s', city, apiKey);
locationData = webread(geoURL);

if isempty(locationData)
    error('City not found. Try another name.');
end

lat = locationData(1).lat;
lon = locationData(1).lon;

% === Step 2: Get Air Quality Data ===
airURL = sprintf('http://api.openweathermap.org/data/2.5/air_pollution?lat=%.4f&lon=%.4f&appid=%s', ...
    lat, lon, apiKey);
airData = webread(airURL);

components = airData.list.components;
aqi = airData.list.main.aqi;
aqiDesc = ["Good", "Fair", "Moderate", "Poor", "Very Poor"];

% === Step 3: Extract Pollutant Values ===
pm25 = components.pm2_5;
pm10 = components.pm10;
co   = components.co;
no2  = components.no2;
o3   = components.o3;
so2  = components.so2;
nh3  = components.nh3;

% === Step 4: Display Output in MATLAB ===
fprintf('\n Air Quality in %s (%.2f, %.2f):\n', city, lat, lon);
fprintf('--------------------------------------------\n');
fprintf('PM2.5: %.2f µg/m³\n', pm25);
fprintf('PM10:  %.2f µg/m³\n', pm10);
fprintf('CO:    %.2f µg/m³\n', co);
fprintf('NO₂:   %.2f µg/m³\n', no2);
fprintf('O₃:    %.2f µg/m³\n', o3);
fprintf('SO₂:   %.2f µg/m³\n', so2);
fprintf('NH₃:   %.2f µg/m³\n', nh3);
fprintf('AQI:   %d (%s)\n', aqi, aqiDesc(aqi));

% === Step 5: Plot Bar Graph ===
figure;
bar([pm25, pm10, co, no2, o3, so2, nh3]);
set(gca, 'XTickLabel', {'PM2.5','PM10','CO','NO₂','O₃','SO₂','NH₃'});
ylabel('Concentration (µg/m³)'); %xaxis polutents and y axis concentrations
title(sprintf('Air Quality in %s (AQI: %d - %s)', city, aqi, aqiDesc(aqi)));

% === Step 6: Send to ThingSpeak ===
data = [pm25, pm10, co, no2, o3, so2, nh3, aqi];  % Max 8 fields allowed
thingSpeakWrite(channelID, data, 'WriteKey', writeAPIKey);

disp(' Data sent to ThingSpeak successfully!');

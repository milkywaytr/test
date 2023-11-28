from flask import Flask, request, jsonify, render_template
import pandas as pd
from geopy.distance import geodesic

app = Flask(__name__)

# Load the CSV file into a pandas DataFrame
df = pd.read_csv('new.csv')

# Initialize the distance column with zeros
df['distance'] = 0.0

@app.route('/api/gas_stations', methods=['GET'])
def get_gas_stations():
    # Get the user-provided location and radius
    user_latitude = request.args.get('latitude')
    user_longitude = request.args.get('longitude')
    radius = int(request.args.get('radius'))

    # Check if latitude and longitude are provided and not None
    if user_latitude is None or user_longitude is None:
        return jsonify({"error": "Latitude and longitude are required."}), 400

    # Convert latitude and longitude to float if they are not None
    try:
        user_location = (float(user_latitude), float(user_longitude))
    except ValueError:
        return jsonify({"error": "Invalid latitude or longitude format."}), 400

    # Update the distance column with geodesic distances
    df['distance'] = df.apply(lambda row: geodesic(user_location, (row['latitude'], row['longitude'])).km, axis=1)

    # Filter the DataFrame to only include gas stations within the specified radius
    nearby_gas_stations = df[df['distance'] <= radius]

    # Convert the filtered DataFrame to a list of dictionaries (for JSON conversion)
    gas_stations_list = nearby_gas_stations.to_dict('records')

    return jsonify(gas_stations_list)

#@app.route('/')
#def index():
#    return render_template('index.html')

if __name__ == '__main__':
    app.run(debug=True)

"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.fetchNearbyAmenities = fetchNearbyAmenities;
const axios_1 = require("axios");
const GOOGLE_MAPS_API_KEY = process.env.GOOGLE_MAPS_API_KEY || 'YOUR_API_KEY_HERE';
async function fetchNearbyAmenities(lat, lng) {
    const types = ['school', 'park', 'transit_station', 'supermarket', 'restaurant'];
    const radius = 1000;
    const amenities = [];
    for (const type of types) {
        const url = `https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${lat},${lng}&radius=${radius}&type=${type}&key=${GOOGLE_MAPS_API_KEY}`;
        try {
            const res = await axios_1.default.get(url);
            if (res.data.results) {
                amenities.push(...res.data.results.map((place) => ({
                    name: place.name,
                    type,
                    address: place.vicinity,
                    location: place.geometry?.location,
                    rating: place.rating,
                })));
            }
        }
        catch (err) {
        }
    }
    return amenities;
}
//# sourceMappingURL=location-ai.utils.js.map
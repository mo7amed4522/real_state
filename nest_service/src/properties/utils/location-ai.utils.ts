import axios from 'axios';

// You must set your Google Maps API key in the environment or config
const GOOGLE_MAPS_API_KEY = process.env.GOOGLE_MAPS_API_KEY || 'YOUR_API_KEY_HERE';

export async function fetchNearbyAmenities(lat: number, lng: number): Promise<any[]> {
  // Example: fetch schools, parks, transit, etc. within 1km
  const types = ['school', 'park', 'transit_station', 'supermarket', 'restaurant'];
  const radius = 1000; // meters
  const amenities: any[] = [];

  for (const type of types) {
    const url = `https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${lat},${lng}&radius=${radius}&type=${type}&key=${GOOGLE_MAPS_API_KEY}`;
    try {
      const res = await axios.get(url);
      if (res.data.results) {
        amenities.push(...res.data.results.map((place: any) => ({
          name: place.name,
          type,
          address: place.vicinity,
          location: place.geometry?.location,
          rating: place.rating,
        })));
      }
    } catch (err) {
      // Ignore errors for missing types
    }
  }
  return amenities;
} 
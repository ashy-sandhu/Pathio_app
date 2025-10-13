# Quick API Reference for Flutter

## 🚀 **Base URL**
```
https://web-production-40bd5.up.railway.app
```

## 📋 **Essential Endpoints**

### **Health Check**
```
GET /health/
```

### **Places**
```
GET /api/places/                    # All places
GET /api/places/{id}/               # Single place
```

### **Cities**
```
GET /api/cities/                    # All cities
GET /api/cities/{id}/               # Single city with places
```

### **Countries**
```
GET /api/countries/                 # All countries
GET /api/countries/{id}/            # Single country with cities
```

### **Search**
```
GET /api/search/?query=lahore       # Search places/cities/countries
```

### **Popular Places**
```
GET /api/popular/                   # Popular places only
```

### **Nearby Places**
```
GET /api/nearby/?lat=31.5204&lon=74.3587&radius=50
```

## 📊 **Place Object Structure**
```json
{
  "id": 1,
  "name": "Badshahi Mosque",
  "description": "A magnificent Mughal-era mosque...",
  "image_url": "https://example.com/image.jpg",
  "lat": 31.5880,
  "lon": 74.3106,
  "city_name": "Lahore",
  "country_name": "Pakistan",
  "category": "religious",
  "rating": 4.8,
  "is_popular": true
}
```

## 🔧 **Flutter HTTP Example**
```dart
// Get all places
final response = await http.get(
  Uri.parse('https://web-production-40bd5.up.railway.app/api/places/')
);

// Search places
final searchResponse = await http.get(
  Uri.parse('https://web-production-40bd5.up.railway.app/api/search/?query=lahore')
);
```

## 📱 **Current Data**
- **Countries:** 21
- **Cities:** 91  
- **Places:** ~180+
- **Top Cities:** Lahore (24), Hunza (22), Taxila (18), Karachi (15)

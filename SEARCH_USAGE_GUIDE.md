# Search Places by Name - Usage Guide

## Overview
The `search_place_by_name.py` script allows you to search for specific places by name using the OpenTripMap API and automatically add them to your database if they meet quality criteria.

## Usage

### Basic Command
```bash
python search_place_by_name.py "Place Name"
```

### Examples
```bash
# Search for famous Pakistani landmarks
python search_place_by_name.py "Badshahi Mosque"
python search_place_by_name.py "Lahore Fort"
python search_place_by_name.py "Shah Faisal Mosque"

# Search for mountains (use full names)
python search_place_by_name.py "Mount Everest"
python search_place_by_name.py "Nanga Parbat"

# Search for cities or regions
python search_place_by_name.py "Islamabad"
python search_place_by_name.py "Karachi"
```

## How It Works

1. **Search**: Uses OpenTripMap's autosuggest API to find places matching the name
2. **Filter**: Only processes places with rating 3+ for quality data
3. **Validate**: Ensures each place has complete data (name, description, image, coordinates)
4. **Locate**: Automatically finds the nearest city in your database based on coordinates
5. **Add**: Adds the place to your database if it's not already there

## Quality Criteria

The script only adds places that have:
- ✅ **Rating 3+** (ensures quality)
- ✅ **Complete name** (not empty)
- ✅ **Wikipedia description** (detailed information)
- ✅ **High-quality image** (from Wikimedia Commons)
- ✅ **Accurate coordinates** (lat/lon)
- ✅ **Valid city assignment** (within 100km of existing cities)

## Features

- **Automatic city detection**: Uses coordinates to find the nearest city in your database
- **Duplicate prevention**: Skips places that already exist
- **Rate limiting**: Respects API limits (6 seconds between requests)
- **Error handling**: Gracefully handles API errors and missing data
- **Detailed logging**: Shows exactly what's happening with each place

## Search Tips

1. **Use full names**: "Badshahi Mosque" works better than "Badshahi"
2. **Minimum 3 characters**: API requires at least 3 characters
3. **Try variations**: If "Faisal Mosque" doesn't work, try "Shah Faisal Mosque"
4. **Be specific**: "Lahore Fort" is better than just "Fort"

## Output Example

```
=== SEARCHING FOR PLACES NAMED: 'BADSHAHI MOSQUE' ===

--- Searching for 'Badshahi Mosque' ---
✅ Found 1 places matching 'Badshahi Mosque'

--- Processing result 1/1 ---
✅ Added: Badshahi Mosque (Rating: 3, Popular: False, Category: religious)
   Location: Lahore, Pakistan

=== SUMMARY FOR 'BADSHAHI MOSQUE' ===
Places added: 1
Places skipped: 0
```

## Successfully Added Places

The script has successfully added these famous Pakistani landmarks:
- Badshahi Mosque (Lahore)
- Begum Shahi Mosque (Lahore) 
- Lahore Fort (Lahore)

And many more from the automated city-based searches!

import os
import json
from datetime import datetime

def save_form_data(name, email, phone, location):
    """Save form data to a JSON file with timestamp as identifier"""
    # Create Data directory if it doesn't exist
    os.makedirs("Data", exist_ok=True)
    
    # Generate timestamp for identifier
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    filename = "Data/form_submissions.json"
    
    # Create form data with timestamp as identifier
    form_data = {
        timestamp: {
            "name": name,
            "email": email,
            "phone": phone,
            "location": location,
            "submission_time": datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        }
    }
    
    # Load existing data or create new if file doesn't exist
    if os.path.exists(filename):
        try:
            with open(filename, "r") as file:
                existing_data = json.load(file)
                existing_data.update(form_data)
        except json.JSONDecodeError:
            # If the file exists but is not valid JSON, start fresh
            existing_data = form_data
    else:
        existing_data = form_data
    
    # Write the updated data back to the file
    with open(filename, "w") as file:
        json.dump(existing_data, file, indent=4)
    
    return timestamp

def get_all_submissions():
    """Retrieve all form submissions from the JSON file"""
    filename = "Data/form_submissions.json"
    
    if os.path.exists(filename):
        try:
            with open(filename, "r") as file:
                data = json.load(file)
                # Convert to list of entries with ID included
                entries = []
                for id, entry in data.items():
                    entry_with_id = entry.copy()
                    entry_with_id["id"] = id
                    entries.append(entry_with_id)
                # Sort by submission time (newest first)
                entries.sort(key=lambda x: x["submission_time"], reverse=True)
                return entries
        except json.JSONDecodeError:
            return []
    else:
        return []

import requests
import pandas as pd
import os


# Define your variables
tenant_id = os.getenv('TENANT_ID')
client_id = os.getenv('CLIENT_ID')
client_secret = os.getenv('CLIENT_SECRET')


resource = 'https://graph.microsoft.com/'
site_name = "file_server_clients"
document_library = "File Server Clients"
base_url = f"https://employsure.sharepoint.com/sites/{site_name}"

# Authenticate and get an access token
try:
    auth_url = f"https://login.microsoftonline.com/{tenant_id}/oauth2/v2.0/token"
    auth_body = {
        'grant_type': 'client_credentials',
        'client_id': client_id,
        'client_secret': client_secret,
        'scope': scope
    }
    auth_response = requests.post(auth_url, data=auth_body, verify=False)  # Disable SSL verification
    auth_response.raise_for_status()
    access_token = auth_response.json().get('access_token')
    print("Access Token:", access_token)
except requests.exceptions.RequestException as e:
    print(f"Error fetching access token: {e}")
    exit(1)

# Set headers for subsequent requests
headers = {
    'Authorization': f'Bearer {access_token}',
    'Accept': 'application/json;odata=verbose'
}

# Define the endpoint for retrieving items from the document library
endpoint = f"{base_url}/_api/web/lists/getbytitle('{document_library}')/items?$top=10"

# Make the request to retrieve items
try:
    response = requests.get(endpoint, headers=headers, verify=False)  # Disable SSL verification
    response.raise_for_status()
    items = response.json()['d']['results']
except requests.exceptions.RequestException as e:
    print(f"Error fetching items from document library: {e}")
    exit(1)

# Extract relevant data
data = [{'ClientTradingName': item['FileLeafRef']} for item in items]

# Convert to a DataFrame
df = pd.DataFrame(data)

# Define file path for the CSV file
csv_file_path = "C:/temp/test/newsharepointitems.csv"

# Save to CSV
df.to_csv(csv_file_path, index=False)

print(f"All SharePoint items exported to {csv_file_path}")

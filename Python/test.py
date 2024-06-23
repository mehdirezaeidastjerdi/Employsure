import pandas as pd

# Load the Excel file and the specific sheet into a DataFrame
file_path = 'path_to_your_file/Book1.xlsx'  # Update this with the correct file path
sheet_name = 'Files_Modified_in_Clients '  # Update this if the sheet name is different

# Read the Excel sheet into a DataFrame
df = pd.read_excel(file_path, sheet_name=sheet_name)

# Extract the parent folders down to the specific client folder level
df['ParentFolder'] = df['Location'].apply(lambda x: '\\'.join(x.split('\\')[:6]))

# Keep only unique parent folders and associated users
unique_parent_folders_with_users = df[['ParentFolder', 'Modified by']].drop_duplicates()

# Save to a new CSV file
csv_file_path_with_users = 'path_to_save/UniqueParentFolders_ClientLevel_WithUsers.csv'  # Update this with the desired save location
unique_parent_folders_with_users.to_csv(csv_file_path_with_users, index=False)

print(f"CSV file with unique parent folders and users saved to: {csv_file_path_with_users}")

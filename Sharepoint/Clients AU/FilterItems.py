import pandas as pd
# Define the path to your CSV file
csv_path = "C:/temp/extracted_EMP_numbers.csv"

# Read the CSV file
df = pd.read_csv(csv_path)

# Ensure the column names match your CSV file
column1 = "ClientTradingName_Technology"
column2 = "ClientTradingName_Clients"

# Filter rows where Column2 contains the value from Column1
filtered_df = df[df.apply(lambda row: str(row[column1]) in str(row[column2]), axis=1)]

# Save the filtered data to a new CSV file
filtered_df.to_csv("C:/temp/filtered_output.csv", index=False)

# Print the filtered data
print(filtered_df)

# import pandas as pd
# import re

# # Define the path to your CSV file
# csv_path = "C:/temp/Technology_Clients_EMP_Old_Complete.csv"

# # Read the CSV file
# df = pd.read_csv(csv_path)

# # Define the column you want to extract EMP numbers from
# column_to_clean = "ClientTradingName_Clients"  # Change this to match your column name

# # Extract only the EMP... part using regex
# df[column_to_clean] = df[column_to_clean].apply(lambda x: ''.join(re.findall(r"EMP\d+", str(x))) if pd.notna(x) else '')

# # Save the cleaned data to a new CSV file
# df.to_csv("C:/temp/extracted_EMP_numbers.csv", index=False)

# # Print the cleaned data
# print(df)

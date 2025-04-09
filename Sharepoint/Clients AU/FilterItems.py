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
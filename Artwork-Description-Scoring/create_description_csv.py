import os
import pandas as pd

# Define paths
script_dir = os.path.dirname(os.path.abspath(__file__))

images_folder = os.path.join(script_dir, "images")
descriptions_folder = os.path.join(script_dir, "descriptions")

# Get list of image files
image_files = [f for f in os.listdir(images_folder) if os.path.isfile(os.path.join(images_folder, f)) and not f.startswith('.')]

# Initialize list for storing rows of data
data = []

# Loop through each image file
for image_file in image_files:
    row = [image_file]
    
    # Get the base name without the file extension
    base_name = os.path.splitext(image_file)[0]
    
    # Read corresponding description files
    for i in range(1, 5):
        description_file = os.path.join(descriptions_folder, f"{base_name}_{i}.txt")
        if os.path.isfile(description_file):
            with open(description_file, 'r', encoding='utf-8') as file:
                row.append(file.read().strip())
        else:
            row.append("")
    
    data.append(row)

# Create DataFrame
columns = ["Image", "Claude 3.5 Sonnet", "GPT-4 Turbo", "GPT-4o", "Gemini 1.5 Flash"]
df = pd.DataFrame(data, columns=columns)

# Save DataFrame to CSV
output_path = os.path.join(script_dir, "Artwork_Descriptions_Text.csv")
df.to_csv(output_path, index=False)

print(f"CSV file created successfully at {output_path}")

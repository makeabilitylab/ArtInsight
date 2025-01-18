import os
import pandas as pd

# Define paths
script_dir = os.path.dirname(os.path.abspath(__file__))
images_folder = os.path.join(script_dir, "images")
scores_folder = os.path.join(script_dir, "scores")

def extract_total_score(text):
    # Split the text into lines
    lines = text.split('\n')
    
    # Loop through each line to find the "Total Score" line
    for line in lines:
        if "Total Score:" in line:
            # Extract the score by splitting the line
            parts = line.split(':')
            if len(parts) > 1:
                # Extract the score within the parentheses and convert to integer
                score = parts[1].strip().strip('()').split('/')[0]
                return int(score)
    
    # If the "Total Score" line is not found, return None
    return None

# Get list of image files
image_files = [f for f in os.listdir(images_folder) if os.path.isfile(os.path.join(images_folder, f)) and not f.startswith('.')]

# Initialize list for storing rows of data
data = []

# Loop through each image file
for image_file in image_files:
    row = [image_file]
    
    # Get the base name without the file extension
    base_name = os.path.splitext(image_file)[0]
    
    # Read corresponding score files
    for i in range(1, 5):
        score_file = os.path.join(scores_folder, f"{base_name}_{i}-score.txt")
        if os.path.isfile(score_file):
            with open(score_file, 'r', encoding='utf-8') as file:
                row.append(extract_total_score(file.read().strip()))
        else:
            row.append(None)
    
    data.append(row)

# Create DataFrame
columns = ["Image", "Claude 3.5 Sonnet", "GPT-4 Turbo", "GPT-4o", "Gemini 1.5 Flash"]
df = pd.DataFrame(data, columns=columns)

# Calculate the average score for each column
average_scores = df.iloc[:, 1:].mean()

# Append average scores to DataFrame
average_scores_row = pd.DataFrame([['Average'] + average_scores.tolist()], columns=columns)
df = pd.concat([df, average_scores_row], ignore_index=True)

# Save DataFrame to CSV
output_path = os.path.join(script_dir, "Artwork_Description_Scores.csv")
df.to_csv(output_path, index=False)

print(f"CSV file created successfully at {output_path}")
print("Average scores for each column:")
print(average_scores)
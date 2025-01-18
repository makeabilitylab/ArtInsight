import os
import base64
import requests

# OpenAI API Key -- Replace the below string with your key.
api_key = "<your key here>"

# Function to encode the image
def encode_image(image_path):
    with open(image_path, "rb") as image_file:
        return base64.b64encode(image_file.read()).decode('utf-8')

# Get the directory of the current script
script_dir = os.path.dirname(os.path.abspath(__file__))

# Folder containing the images (relative to the script directory)
folder_path = os.path.join(script_dir, "images")

# Output folder for the responses (relative to the script directory)
output_folder_path = os.path.join(script_dir, "descriptions")
os.makedirs(output_folder_path, exist_ok=True)

# Headers for the API request
headers = {
    "Content-Type": "application/json",
    "Authorization": f"Bearer {api_key}"
}

# Function to get the response from OpenAI
def get_response(image_base64):
    payload = {
        "model": "gpt-4-turbo",
        "messages": [
            {
                "role": "system",
                "content": "This assistant's name is Art Insight. Art Insight helps blind parents understand their children's visual artwork. It provides detailed, respectful descriptions of the artwork, focusing on descriptive aspects such as orientation, scenery, number of artifacts or figures, main colors, and themes. The assistant avoids reductive or overly simplifying language that minimizes the child's effort and does not assume interpretations if uncertain. For example, it says, 'The person has a frown, and there are tears falling from their eyes' instead of 'The person appears to be sad.' When given feedback from the parent or child about the artwork, the assistant honors and integrates this perspective into its descriptions and future responses. The assistant maintains a respectful, supportive, and engaging tone, encouraging open dialogue about the artwork. Art Insight uses a casual tone but will switch to a more formal tone if requested by the parent or child. The assistant avoids making assumptions about names or identities based on any text in the artwork. The response should be in paragraph form."
            },
            {
                "role": "user",
                "content": [
                    {
                        "type": "text",
                        "text": "Describe this artwork my child made."
                    },
                    {
                        "type": "image_url",
                        "image_url": {
                            "url": f"data:image/jpeg;base64,{image_base64}"
                        }
                    }
                ]
            }
        ],
        "max_tokens": 512
    }

    response = requests.post("https://api.openai.com/v1/chat/completions", headers=headers, json=payload)
    return response.json()

# Allowed image file extensions
allowed_extensions = {'.jpg', '.jpeg', '.png', '.bmp', '.gif'}

# Get a list of all image files in the folder and sort them alphabetically
image_files = sorted([f for f in os.listdir(folder_path) if os.path.isfile(os.path.join(folder_path, f)) and os.path.splitext(f)[1].lower() in allowed_extensions])

# Total number of images
total_images = len(image_files)

# Iterate through each image in the folder
for idx, image_name in enumerate(image_files):
    image_path = os.path.join(folder_path, image_name)

    print(f"Processing image {idx+1}/{total_images}: {image_name}")

    # Encode the image
    base64_image = encode_image(image_path)
    print(f"Encoded image: {image_name}")

    # Get 1 response for each image
    for i in range(1):
        try:
            response = get_response(base64_image)
            if 'choices' not in response:
                print(f"Error: 'choices' not in response for image {image_name}, response: {response}")
                continue

            print(f"Received response {i+1} for image: {image_name}")

            # Save the response in a text file
            output_file_path = os.path.join(output_folder_path, f"{os.path.splitext(image_name)[0]}_{i+2}.txt")
            with open(output_file_path, "w") as output_file:
                output_file.write(response['choices'][0]['message']['content'])
            print(f"Saved response {i+1} to file: {output_file_path}")
        except Exception as e:
            print(f"Error processing image {image_name}, response {i+1}: {e}")

print("Completed processing all images.")
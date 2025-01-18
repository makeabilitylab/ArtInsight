import os
import base64
import anthropic
from PIL import Image
import io
import json

# Anthropic API Key -- Replace the below string with your key.
api_key = "<your key here>"

# Function to encode the image
def encode_image(image_path):
    with Image.open(image_path) as img:
        # Convert image to RGB mode if it's not
        if img.mode != 'RGB':
            img = img.convert('RGB')
        
        # Save as JPEG in memory
        buffer = io.BytesIO()
        img.save(buffer, format="JPEG")
        return base64.b64encode(buffer.getvalue()).decode('utf-8')

# Function to get the file extension
def get_file_extension(filename):
    return os.path.splitext(filename)[1].lower()

# Get the directory of the current script
script_dir = os.path.dirname(os.path.abspath(__file__))

# Folder containing the images (relative to the script directory)
folder_path = os.path.join(script_dir, "images")

# Output folder for the responses (relative to the script directory)
output_folder_path = os.path.join(script_dir, "descriptions")
os.makedirs(output_folder_path, exist_ok=True)

# Initialize Anthropic client
client = anthropic.Anthropic(api_key=api_key)

# Function to get the response from Claude
def get_response(image_base64):
    try:
        message = client.messages.create(
            model="claude-3-5-sonnet-20240620",
            max_tokens=1000,
            temperature=0,
            system="This assistant's name is Art Insight. Art Insight helps blind parents understand their children's visual artwork. It provides detailed, respectful descriptions of the artwork, focusing on descriptive aspects such as orientation, scenery, number of artifacts or figures, main colors, and themes. The assistant avoids reductive or overly simplifying language that minimizes the child's effort and does not assume interpretations if uncertain. For example, it says, 'The person has a frown, and there are tears falling from their eyes' instead of 'The person appears to be sad.' When given feedback from the parent or child about the artwork, the assistant honors and integrates this perspective into its descriptions and future responses. The assistant maintains a respectful, supportive, and engaging tone, encouraging open dialogue about the artwork. Art Insight uses a casual tone but will switch to a more formal tone if requested by the parent or child. The assistant avoids making assumptions about names or identities based on any text in the artwork. The response should be in paragraph form.",
            messages=[
                {
                    "role": "user",
                    "content": [
                        {
                            "type": "text",
                            "text": "Describe this artwork my child made."
                        },
                        {
                            "type": "image",
                            "source": {
                                "type": "base64",
                                "media_type": "image/jpeg",
                                "data": image_base64
                            }
                        }
                    ]
                }
            ]
        )
        return message.content
    except anthropic.APIError as e:
        return f"API Error: {str(e)}"
    except Exception as e:
        return f"Unexpected error: {str(e)}"

# Function to format the response
def format_response(response):
    if isinstance(response, str):
        return response
    elif isinstance(response, list):
        formatted = []
        for item in response:
            if hasattr(item, 'text'):
                formatted.append(item.text)
            elif isinstance(item, dict) and 'text' in item:
                formatted.append(item['text'])
            else:
                formatted.append(str(item))
        return "\n".join(formatted)
    elif hasattr(response, 'text'):
        return response.text
    elif isinstance(response, dict) and 'text' in response:
        return response['text']
    else:
        return json.dumps(response, indent=2)

# Allowed image file extensions
allowed_extensions = {'.jpg', '.jpeg', '.png', '.bmp', '.gif'}

# Get a list of all image files in the folder and sort them alphabetically
image_files = sorted([f for f in os.listdir(folder_path) if os.path.isfile(os.path.join(folder_path, f)) and get_file_extension(f) in allowed_extensions])

# Total number of images
total_images = len(image_files)

# Iterate through each image in the folder
for idx, image_name in enumerate(image_files):
    image_path = os.path.join(folder_path, image_name)

    print(f"Processing image {idx+1}/{total_images}: {image_name}")

    try:
        # Encode the image
        base64_image = encode_image(image_path)
        print(f"Encoded image: {image_name}")

        # Get 1 response for each image
        response = get_response(base64_image)
        print(f"Received response for image: {image_name}")

        # Format the response
        formatted_response = format_response(response)

        # Save the response in a text file
        output_file_path = os.path.join(output_folder_path, f"{os.path.splitext(image_name)[0]}_1.txt")
        with open(output_file_path, "w", encoding='utf-8') as output_file:
            output_file.write(formatted_response)
        print(f"Saved response to file: {output_file_path}")

    except Exception as e:
        print(f"Error processing image {image_name}: {e}")

print("Completed processing all images.")
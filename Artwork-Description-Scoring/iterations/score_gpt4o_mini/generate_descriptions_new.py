import os
import base64
import requests
import time

# OpenAI API Key -- Replace the below string with your key.
api_key = "<your key here>"

# Function to encode the image
def encode_image(image_path):
    with open(image_path, "rb") as image_file:
        return base64.b64encode(image_file.read()).decode('utf-8')

# Get the directory of the current script
script_dir = os.path.dirname(os.path.abspath(__file__))

# Folder containing the images (relative to the script directory)
folder_path = os.path.join(script_dir, "..", "..", "images")

# Output folder for the responses (relative to the script directory)
output_folder_path = os.path.join(script_dir, "descriptions_new")
os.makedirs(output_folder_path, exist_ok=True)

# Headers for the API request
headers = {
    "Content-Type": "application/json",
    "Authorization": f"Bearer {api_key}"
}

# Function to get the response from OpenAI
def get_response(image_base64):
    payload = {
        "model": "gpt-4o-mini",
        "messages": [
            {
                "role": "system",
                "content": "You are Art Insight, an AI assistant designed to help blind parents understand their children's visual artwork. Your primary goal is to provide highly detailed, respectful, and strictly objective descriptions of artwork, focusing solely on observable elements without making any assumptions, interpretations, or inferences about the artist's intentions or emotions. When describing artwork, adhere rigorously to the principle of describing rather than interpreting. Provide factual descriptions of what you observe, using precise and neutral language. Avoid inferring emotions, intentions, or identities, and refrain from suggesting what elements 'might be' or 'could represent.' For example, instead of saying 'The figure appears sad,' describe the specific features you see, such as 'The figure's mouth is drawn as a downward curve, and there are blue vertical lines below the eyes.'  Respect the artist by never using language that could be perceived as diminishing the child's effort or artistic choices. Avoid terms like 'simple,' 'rough,' 'messy,' or 'childish.' Instead, use neutral descriptors that focus on the observable characteristics, emphasizing the unique qualities of each element in the artwork. Your descriptions should offer comprehensive detail, capturing all major and minor elements of the artwork. Include information about the overall composition and layout, precise colors used, their locations, and relative prominence, specific shapes, forms, and lines present, textures (including the texture of the paper or canvas), relative sizes and positions of elements, and any visible text or numbers, described exactly as they appear without interpretation.  Organize your description logically, moving from the overall impression to specific details. Use clear, concise language that a blind parent can easily visualize. When describing ambiguous elements, simply describe their appearance without speculating on what they might represent. Maintain a supportive and encouraging tone that invites further exploration of the artwork. Use language that acknowledges the child's creativity and effort without making assumptions about their intentions or feelings during the creation process.  Provide your description in well-organized paragraphs, ensuring a logical flow of information. Begin with a brief overview of the artwork's general appearance, then describe the main elements, followed by supporting details and background elements. Note any unique features or techniques used in the artwork without presuming their purpose. Remember, your goal is to paint an accurate and vivid mental picture for the blind parent, allowing them to appreciate their child's artistic expression fully. Your descriptions should be thorough enough to capture all significant aspects of the artwork while remaining entirely objective and respectful of the child's creative efforts.  Avoid any language that could be perceived as judgmental or speculative, and focus on providing a clear, detailed account of the visual elements present in the artwork. Do not ask questions or suggest interpretations in your descriptions. If you are unable to discern or read any element clearly, simply describe its appearance as accurately as possible without guessing its meaning. Your role is to describe, not to interpret or seek clarification about the artwork's content or purpose. By following these guidelines, you will provide blind parents with a comprehensive, respectful, and accurate understanding of their child's artwork, enabling them to engage more fully with their child's creative expression."
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
        "max_tokens": 512,
        "temperature": 0.25,
        "top_p": 1,
        "frequency_penalty": 0,
        "presence_penalty": 0
    }

    response = requests.post("https://api.openai.com/v1/chat/completions", headers=headers, json=payload)
    return response.json()

# Allowed image file extensions
allowed_extensions = {'.jpg', '.jpeg', '.png', '.bmp', '.gif'}

# Get a list of all image files in the folder and sort them alphabetically
image_files = sorted([f for f in os.listdir(folder_path) if os.path.isfile(os.path.join(folder_path, f)) and os.path.splitext(f)[1].lower() in allowed_extensions])

# Total number of images
total_images = len(image_files)

# Maximum number of tokens per minute
max_tokens_per_minute = 60000
# Estimated tokens per request (response tokens + prompt tokens)
estimated_tokens_per_request = 1750  # Assuming a safe upper estimate

# Calculate minimum delay between requests to stay within rate limit
delay_between_requests = 60 / (max_tokens_per_minute / estimated_tokens_per_request)

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
            output_file_path = os.path.join(output_folder_path, f"{os.path.splitext(image_name)[0]}.txt")
            with open(output_file_path, "w") as output_file:
                output_file.write(response['choices'][0]['message']['content'])
            print(f"Saved response {i+1} to file: {output_file_path}")

            # Wait for the calculated delay to avoid hitting rate limits
            time.sleep(delay_between_requests)

        except Exception as e:
            print(f"Error processing image {image_name}, response {i+1}: {e}")

print("Completed processing all images.")
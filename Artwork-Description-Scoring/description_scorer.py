import os
import base64
from PIL import Image
import io
import openai
import json

# OpenAI API Key -- Replace the below string with your key.
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

# Folder containing the images
image_folder_path = os.path.join(script_dir, "images")

# Folder containing the descriptions
description_folder_path = os.path.join(script_dir, "descriptions")

# Output folder for the scores
score_folder_path = os.path.join(script_dir, "scores")
os.makedirs(score_folder_path, exist_ok=True)

# Initialize OpenAI client
openai.api_key = api_key

image_base64_original = encode_image(os.path.join(image_folder_path, "IMG_2272.jpeg"))

# Function to get the score from GPT-4
def get_score(image_base64, description):
    response = openai.ChatCompletion.create(
        model="gpt-4o",
        messages=[
            {
                "role": "system",
                "content": "There are some descriptions that have been written about pieces of artwork. This descriptions are designed to help blind parents understand their children's visual artwork. They are supposed to provide detailed, respectful descriptions of the artwork, focusing on descriptive aspects such as orientation, scenery, number of artifacts or figures, main colors, and themes and avoiding reductive or overly simplifying language that minimizes the child's effort and does not assume interpretations if uncertain. For example, the description should say, 'The person has a frown, and there are tears falling from their eyes' instead of 'The person appears to be sad.' The description should have a respectful, supportive, and engaging tone, encouraging open dialogue about the artwork. The descriptions should avoid making assumptions about names or identities based on any text in the artwork. The description should be in paragraph form.\n\nYou are a scorer for these descriptions of artwork. Your job is to give each description a score on the scale of 0-16 based on the following criteria:\n\nThere are 4 criteria and each of these criteria is 4 points, therefore giving the scale of 0-16.\n\n0 points indicates that the work does not meet the criteria at all. It is significantly lacking in key areas, with major components missing or entirely incorrect, showing little to no effort or understanding. 1 point means that the work minimally meets the criteria. It addresses some aspects but is incomplete or contains several errors, demonstrating only a basic understanding of the required skills or knowledge. 2 points indicate that the work partially meets the criteria. It covers most aspects but still has notable gaps or inaccuracies, showing a moderate understanding and application of the necessary skills or knowledge. 3 points means that the work meets the criteria satisfactorily. Most components are present and correctly executed, with only minor errors, demonstrating a solid understanding and competent application of the required skills or knowledge. 4 points indicates that the work exceeds the criteria. It fully addresses and goes beyond the expectations, with all components well-developed and executed with high accuracy. This score demonstrates a deep understanding and proficient application of the required skills or knowledge, showing exceptional effort, creativity, and insight.\n\n1) Is the description being presumptive, i.e. when it doesn't know something is it making inferences or assumptions about what they could be? For ex: \"The main figure in the artwork is a large, dark gray shape in the center. It's hard to say for sure what it is, but it might be a person or animal.\" --> Ideally the description should just say, \"the main figure in the artwork is a large, dark gray shape in the center.\" (4 points)\n\n2) Is it being reductive, i.e. is it ever minimizing the effort or drawing style of the child? For ex, in the past I've had descriptions say things like, \"this is a drawing of simple stick figures\" where the parent has disliked the use of the word \"simple\". Or another example: \"this is a rough rectangle\" -- parents don't like it when descriptions use terms like 'rough' that diminish the work the child has put in. (4 points)\n\n3) Is it being too simple, i.e. only saying things like: \"This is a child's drawing of a forest and some animals\". Ideally the description goes into detail about the artwork. (4 points)\n\n4) Are all the major elements of the artwork captured? (4 points)\n\nThere is also a miscellaneous section that can subtract points.\n5. Miscellaneous (Are there any other parts of the response which take away from the overall quality?)",
            },
            {
                "role": "user",
                "content": [
                    {
                        "type": "text",
                        "text": "Score the description for this piece of artwork.\n\nArtwork:"
                    },
                    {
                        "type": "image_url",
                        "image_url": {
                            "url": f"data:image/jpeg;base64,{image_base64_original}"
                        }
                    },
                    {
                        "type": "text",
                        "text": "\n\nDescription:\nThis artwork is quite expressive and engaging! The main feature of this creation is a handprint in the center, boldly outlined in black and filled with a blend of yellow and grey colors. The fingers are distinctly marked, and the palm is highlighted with vibrant yellow, giving it a warm, glowing effect.\n\nAround the handprint, there are various streaks and splashes of color which include shades of red, pink, and green. These colors seem to be dynamically brushed around, suggesting a sense of movement or perhaps the joy associated with creation.\n\nIn addition to the handprint and color splashes, there is text written in a playful, childlike handwriting using a pinkish-purple hue. The letters \"HBD\" are visible, typically an abbreviation for \"Happy Birthday,\" which might suggest that this artwork was intended as a birthday greeting or celebration.\n\nThe overall impression of the artwork is lively and colorful, radiating a sense of personal touch and happiest moments. The use of the handprint could symbolize identity or personal expression, while the surrounding colors enhance the festive, celebratory vibe of the piece."
                    }
                ]
            },
            {
                "role": "assistant",
                "content": [
                    {
                        "type": "text",
                        "text": "1. Is the description being presumptive? (2/4)\n[The description is partly factual but makes multiple interpretations such as \"suggesting a sense of movement or perhaps the joy associated with creation\" and \"could symbolize identity or personal expression\". It also presumes \"HBD\" stands for \"Happy Birthday\" and that the drawing might be a birthday greeting. These presume the artist's intent.]\n\n2. Is it being reductive? (4/4)\n[The description is respectful and does not minimize or reduce the child's effort or style. It uses positive language like \"expressive,\" \"engaging,\" and \"vibrant.\"]\n\n3. Is it being too simple? (4/4)\n[The description is detailed and goes beyond a simplistic overview. It covers colors, shapes, and possible interpretations without being too vague or brief]\n\n4. Are all the major elements captured? (2/4)\n[The description does not mention all the elements such as the crumpled texture of the paper, the specific red and pink streaks on the left, or the color placement more accurately. This omission means not all significant elements are captured.]\n\n5. Miscellaneous (0)\n[No points subtracted.]\n\nTotal Score: (12/16)"
                    }
                ]
            },
            {
                "role": "user",
                "content": [
                    {
                        "type": "text",
                        "text": "Score the description for this piece of artwork.\n\nArtwork:"
                    },
                    {
                        "type": "image_url",
                        "image_url": {
                            "url": f"data:image/jpeg;base64,{image_base64_original}"
                        }
                    },
                    {
                        "type": "text",
                        "text": "\nDescription:\nThis vibrant artwork displays a bold handprint at its center, using deep black paint against a crisp white background. The fingers of the handprint are distinct, and within the palm, there's a splash of brilliant yellow, adding a vivid burst of color. Surrounding this central motif are playful strokes and dabs of pink and red paint that give a sense of dynamic motion to the piece.Interestingly, at the corners of the paper, there are smudges of green paint that provide a slight contrast to the overall warm tones. The artwork also includes handwritten text in magenta around the handprint. The letters \"HBD\" are repeated, hinting that this piece might have been created as a joyful birthday greeting.The artwork appears to be crafted with enthusiasm, each color and stroke contributing to an expression of celebration and personal touch. This piece exudes a cheerful vibe and suggests a festive intention, perhaps as a unique and heartfelt gift."
                    }
                ]
            },
            {
                "role": "assistant",
                "content": [
                    {
                        "type": "text",
                        "text": "1. Is the description being presumptive? (3/4)\n[While the description is mostly detailed, it makes assumptions about the intention behind the artwork, such as suggesting it was created for a \"joyful birthday greeting\" and that it \"exudes a cheerful vibe\" or suggests \"a festive intention\". These are presumptive statements about the artist's intent.]\n\n2. Is it being reductive? (4/4)\n[The description is respectful and acknowledges the child's effort and creativity. Terms like \"playful strokes,\" \"vivid burst,\" and \"crafted with enthusiasm\" highlight the care and thought put into the artwork without being dismissive.]\n\n3. Is it being too simple? (4/4)\n[The description is thorough, covering various elements, colors, and even finer details like the smudges of green paint at the corners, providing a well-rounded understanding of the artwork.]\n\n4. Are all the major elements captured? (3/4)\n[The description captures most major elements, including the handprint, colors, and general texture, but it could mention the crumpled texture of the paper and possibly the exact positioning of the handprint and text for more completeness.]\n\n5. Miscellaneous (0)\n[No points subtracted.]\n\nTotal Score: (14/16)"
                    }
                ]
            },
            {
                "role": "user",
                "content": [
                    {
                        "type": "text",
                        "text": "Score the description for this piece of artwork.\n\nArtwork:\n\nDescription:\nScore the description for this piece of artwork.\n\nArtwork:"
                    },
                    {
                        "type": "image_url",
                        "image_url": {
                            "url": f"data:image/jpeg;base64,{image_base64_original}"
                        }
                    },
                    {
                        "type": "text",
                        "text": "\n\nDescription:\nYour child's artwork features a vibrant and colorful handprint at its center. The handprint is primarily outlined with black paint, filled in with a yellow color in the palm area, and some red accents on the fingers. Surrounding the handprint, there are various freeform streaks and splashes of colors including pink, green, and red. These brushstrokes give the artwork a lively feel. Additionally, below the handprint, there are some letters painted in purple and red, though they appear somewhat abstract and might be intended to convey a creative message or initials. The background paper is slightly crumpled, which adds texture to the piece. Overall, the artwork combines bold lines and energetic splashes of color, showcasing your child's creativity and enthusiasm."
                    }
                ]
            },
            {
                "role": "assistant",
                "content": [
                    {
                        "type": "text",
                        "text": "1. Is the description being presumptive? (4/4)\n[The description avoids making assumptions about the intent behind the artwork. Instead of assuming meanings, it describes what is visible without inferring underlying messages or reasons such as \"might be intended to convey a creative message or initials.\"]\n\n2. Is it being reductive? (4/4)\n[The description is respectful and acknowledges the child's creativity enthusiastically, using positive terms like \"vibrant,\" \"colorful,\" \"lively feel,\" and \"showcasing your child's creativity and enthusiasm.\" It does not use any diminishing language.]\n\n3. Is it being too simple? (3/4)\n[The description doesn't understand the letters and instead takes a guess at it might be intended to convey, which it should not do.]\n\n4. Are all the major elements captured? (2/4)\n[The description captures all the major elements: the handprint, colors, strokes, letters, and the crumpled texture of the paper, providing a thorough overview of the artwork. However, it is not able to understand the text in the image.]\n\n5. Miscellaneous (-1)\n[Not able to read text in the image.]\n\nTotal Score: (12/16)"
                    }
                ]
            },
            {
                "role": "user",
                "content": [
                    {
                        "type": "text",
                        "text": "Score the description for this piece of artwork.\n\nArtwork:"
                    },
                    {
                        "type": "image_url",
                        "image_url": {
                            "url": f"data:image/jpeg;base64,{image_base64_original}"
                        }
                    },
                    {
                        "type": "text",
                        "text": "\n\nDescription:\nYour child's artwork features a vibrant and colorful handprint at its center. The handprint is primarily outlined with black paint, filled in with a yellow color in the palm area, and some red accents on the fingers. Surrounding the handprint, there are various freeform streaks and splashes of colors including pink, green, and red. These brushstrokes give the artwork a lively feel. Additionally, below the handprint, there are some letters painted in purple and red, though they appear somewhat abstract and might be intended to convey a creative message or initials. The background paper is slightly crumpled, which adds texture to the piece. Overall, the artwork combines bold lines and energetic splashes of color, showcasing your child's creativity and enthusiasm."
                    }
                ]
            },
            {
                "role": "assistant",
                "content": [
                    {
                        "type": "text",
                        "text": "1. Is the description being presumptive? (4/4)\n[The description avoids making assumptions.]\n\n2. Is it being reductive? (4/4)\n[The description is respectful and celebrates the child’s effort and creativity with positive language like \"vibrant,\" \"colorful,\" \"lively feel,\" \"bold lines,\" and \"energetic splashes of color.\" It does not use any diminishing terms.]\n\n3. Is it being too simple? (4/4)\n[The description is detailed and covers several aspects of the artwork, such as colors, brushstrokes, letters, and texture.]\n\n4. Are all the major elements captured? (4/4)\n[The description captures most of the major elements like the handprint and surrounding colors.]\n\n5. Miscellaneous (0)\n[No points subtracted.]\n\nTotal Score: (16/16)"
                    }
                ]
            },
            {
                "role": "user",
                "content": [
                    {
                        "type": "text",
                        "text": "Score the description for this piece of artwork.\n\nArtwork:"
                    },
                    {
                        "type": "image_url",
                        "image_url": {
                            "url": f"data:image/jpeg;base64,{image_base64_original}"
                        }
                    },
                    {
                        "type": "text",
                        "text": "\n\nDescription:\nYour child made a colorful and interesting artwork!  The main figure in the artwork is a large, dark gray shape in the center. It's hard to say for sure what it is, but it might be a person or animal.  The figure is surrounded by other colorful shapes and lines in various shades of pink, red, and yellow.  There are also three thin, vertical lines in green, orange, and purple. At the top of the artwork, there is the word \"HOR\" written in purple, which might be part of a word.  There is a lot of white space in the artwork, and the paper appears to be slightly wrinkled.  Do you know what your child was thinking about when they made this artwork?"
                    }
                ]
            },
            {
                "role": "assistant",
                "content": [
                    {
                        "type": "text",
                        "text": "1. Is the description being presumptive? (2/4)\n[The description makes assumptions about the main figure, suggesting it might be a \"person or animal.\" It also assumes the word \"HOR\" might be part of a word, both of which are unnecessary and speculative.]\n\n2. Is it being reductive? (3/4)\n[The description is mostly respectful but uses terms like \"it's hard to say for sure,\" which could come across as dismissive. Offering a clearer description of the shape would be more respectful of the child's effort.]\n\n3. Is it being too simple? (3/4)\n[The description covers several elements but lacks depth in describing the colors and various brushstrokes. It mentions colors and shapes but doesn't provide a comprehensive view of the artwork’s vibrancy or details of each element.]\n\n4. Are all the major elements captured? (1/4)\n[The description captures most major elements but misses the detail about the specific letters \"HBD\" in the bottom part of the artwork, which are clearer than the presumed \"HOR\" at the top. The HOR was read wrong. It is HBD.]\n\n5. Miscellaneous (-2)\n[The phrase \"Do you know what your child was thinking about when they made this artwork?\" detracts from the assessment and introduces a subjective element. The description should not ask questions. It also read the HBD letters wrong as HOR instead.]\n\nTotal Score: (7/16)"
                    }
                ]
            },
            {
                "role": "user",
                "content": [
                    {
                        "type": "text",
                        "text": "Score the description for this piece of artwork.\n\nArtwork:"
                    },
                    {
                        "type": "image_url",
                        "image_url": {
                            "url": f"data:image/jpeg;base64,{image_base64}"
                        }
                    },
                    {
                        "type": "text",
                        "text": f"\n\nDescription:\n{description}"
                    }
                ]
            }
        ],
        max_tokens=1000,
        temperature=0
    )
    return response['choices'][0]['message']['content']

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

# Get a list of all description files and sort them alphabetically
description_files = sorted([f for f in os.listdir(description_folder_path) if f.endswith('.txt') and not f.startswith('.DS_Store')])

# Total number of descriptions
total_descriptions = len(description_files)

# Iterate through each description file
for idx, description_file in enumerate(description_files):
    description_path = os.path.join(description_folder_path, description_file)
    image_name = description_file.replace('_1.txt', '').replace('_2.txt', '').replace('_3.txt', '').replace('_4.txt', '') + '.jpeg'
    image_path = os.path.join(image_folder_path, image_name)

    print(f"Processing description {idx+1}/{total_descriptions}: {description_file}")

    try:
        # Read the description
        with open(description_path, 'r', encoding='utf-8') as file:
            description = file.read()

        # Encode the image
        base64_image = encode_image(image_path)
        print(f"Encoded image: {image_name}")

        # Get the score
        score = get_score(base64_image, description)
        print(f"Received score for description: {description_file}")

        # Format the score response
        formatted_score = format_response(score)

        # Save the score in a text file
        score_file_name = description_file.replace('.txt', '-score.txt')
        score_file_path = os.path.join(score_folder_path, score_file_name)
        with open(score_file_path, "w", encoding='utf-8') as score_file:
            score_file.write(formatted_score)
        print(f"Saved score to file: {score_file_path}")

    except Exception as e:
        print(f"Error processing description {description_file}: {e}")

print("Completed scoring all descriptions.")

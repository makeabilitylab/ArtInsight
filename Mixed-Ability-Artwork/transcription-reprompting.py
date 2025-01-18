import requests
import time
import json

transcription_prompt = """

You will now be provided with a transcription of the conversation between the blind parent and the child about the artwork with more accurate information about the child's intentions when creating the artwork.

Using the information provided in the transcription, your task is to regenerate your response with the 4 parts. Your goal is to use the new information from the transcriptions to modify the original information and add new details based on those insights. The new questions you generate must help continue and enhance the conversation from the transcription.

Here is the transcription:

"""

transcription = """

Look, Mom! I made a turkey!
Oh, wow! Your turkey sounds very colorful and lively. Can you tell me what colors you used for its feathers?
Sure! I used green, yellow, blue, pink, orange, and red. I wanted it to be really bright and happy!
That sounds wonderful. I bet it looks like a burst of colors. How did you decide to pick those colors?
I just thought about all my favorite colors and mixed them up. I wanted it to look like a rainbow turkey.
That’s such a great idea. The colors must make the turkey look really vibrant. I noticed there are swirly lines in the background too. What do they represent?
Oh, those! I think they make the background look fun. They kind of show the wind blowing around the turkey’s feathers.
That sounds very imaginative. The swirls must give the picture a nice sense of movement. What was your favorite part about creating this turkey artwork?
I liked painting the feathers the most. It was fun to blend all the colors together and see how they turned out.
It must have been a lot of fun working with so many colors. You did a fantastic job, and I can tell you put a lot of effort into making each feather special. Thank you for sharing it with me!
Thanks, Mom! I’m happy you like it.

"""

class OpenAIService:
    def __init__(self, api_key, assistant_id):
        self.api_key = api_key
        self.assistant_id = assistant_id
        self.headers = {
            "Authorization": f"Bearer {self.api_key}",
            "Content-Type": "application/json",
            "OpenAI-Beta": "assistants=v2"
        }

    def upload_image(self, image_path):
        url = "https://api.openai.com/v1/files"
        files = {
            'file': ('image.jpg', open(image_path, 'rb'), 'image/jpeg'),
            'purpose': (None, 'vision')
        }
        response = requests.post(url, headers={'Authorization': f"Bearer {self.api_key}"}, files=files)
        if response.status_code == 200:
            return response.json()['id']
        else:
            print("Failed to upload image:", response.text)
            return None

    def create_thread(self):
        url = "https://api.openai.com/v1/threads"
        response = requests.post(url, headers=self.headers)
        if response.status_code == 200:
            return response.json()['id']
        else:
            print("Failed to create thread:", response.text)
            return None

    def add_message_to_thread(self, thread_id, user_message, image_id=None):
        url = f"https://api.openai.com/v1/threads/{thread_id}/messages"
        content = [{"type": "text", "text": user_message}]
        if image_id:
            content.append({"type": "image_file", "image_file": {"file_id": image_id}})
        
        payload = {
            "role": "user",
            "content": content
        }
        response = requests.post(url, headers=self.headers, json=payload)
        if response.status_code != 200:
            print("Failed to add message to thread:", response.text)

    def run_thread(self, thread_id):
        url = f"https://api.openai.com/v1/threads/{thread_id}/runs"
        payload = {
            "assistant_id": self.assistant_id
        }
        response = requests.post(url, headers=self.headers, json=payload)
        if response.status_code == 200:
            return response.json()['id']
        else:
            print("Failed to run thread:", response.text)
            return None

    def poll_for_result(self, thread_id, run_id, interval=5, timeout=60):
        url = f"https://api.openai.com/v1/threads/{thread_id}/runs/{run_id}"
        start_time = time.time()
        while time.time() - start_time < timeout:
            response = requests.get(url, headers=self.headers)
            if response.status_code == 200:
                run = response.json()
                if run['status'] == 'completed':
                    return True
                elif run['status'] == 'failed':
                    print("Run failed:", run.get('last_error', 'No error message provided'))
                    return False
            else:
                print("Failed to poll for result:", response.text)
                return False
            time.sleep(interval)
        print("Polling timed out")
        return False

    def get_messages(self, thread_id):
        url = f"https://api.openai.com/v1/threads/{thread_id}/messages"
        response = requests.get(url, headers=self.headers)
        if response.status_code == 200:
            messages = response.json()['data']
            if messages:
                content = messages[0]['content']
                if content:
                    return content[0].get('text', {}).get('value', "No description found")
        print("Failed to get messages:", response.text)
        return None

    def describe(self, image_path):
        print("Uploading image...")
        image_id = self.upload_image(image_path)
        if not image_id:
            return

        print("Creating thread...")
        thread_id = self.create_thread()
        if not thread_id:
            return

        print("Adding initial message to thread...")
        user_message = "Describe this artwork my child made."
        self.add_message_to_thread(thread_id, user_message, image_id)

        print("Running initial description...")
        run_id = self.run_thread(thread_id)
        if not run_id:
            return

        print("Polling for result...")
        if self.poll_for_result(thread_id, run_id):
            print("Fetching messages...")
            description = self.get_messages(thread_id)
            if description:
                print("Image description:", description)
                
                # Example follow-up question
                follow_up_question = transcription + transcription_prompt
                print("Sending follow-up question...")
                self.add_message_to_thread(thread_id, follow_up_question)
                
                print("Running follow-up...")
                follow_up_run_id = self.run_thread(thread_id)
                if follow_up_run_id:
                    print("Polling for follow-up result...")
                    if self.poll_for_result(thread_id, follow_up_run_id):
                        print("Fetching follow-up messages...")
                        follow_up_description = self.get_messages(thread_id)
                        if follow_up_description:
                            print("Follow-up description:", follow_up_description)
                        else:
                            print("Failed to get follow-up description")
                    else:
                        print("Polling for follow-up failed")
                else:
                    print("Failed to run follow-up question")
            else:
                print("Failed to get image description")
        else:
            print("Polling failed")

# Open AI API Key -- Replace the below string with your key.
api_key = '<your key here>'
assistant_id = 'asst_0LIabJN7YRsy5hLyH1B3MeX0'
image_path = '/Users/adityasengupta/Documents/GitHub/Mixed-Ability-Artwork/Artwork-Description-Scoring/images/turkey.jpeg'

service = OpenAIService(api_key, assistant_id)
service.describe(image_path)

# Code Output

'''
Uploading image...
Creating thread...
Adding initial message to thread...
Running initial description...
Polling for result...
Fetching messages...
Image description: 

Title: Colorful-Turkey

%%%

Descriptive Description: This artwork features a large, stylized depiction of a turkey, centralized prominently. The turkey has large, round eyes that dominate its face, each eye outlined in black with white centers and large black pupils. The beak is triangular and orange with a red wattle hanging from the side. The turkey's body is composed of a large, rounded shape filled with varying shades of brown, giving it a textured appearance.

Its tail feathers fan out around the body and are divided into multiple sections, each filled with different colors. These sections include shades of green, blue, pink, yellow, and orange, and they are bordered in bold black lines. Some sections appear to have subtle watercolor gradients, blending slightly rather than being solid blocks of color. Around the edge of the tail feathers, there are details drawn in black, such as curved lines and loops, giving additional texture to the feathers.

The background of the image is a light blue color, with small, irregular black dots scattered throughout. The entire artwork is outlined and partitioned with bold black lines that create a stained-glass effect. The overall appearance is vibrant and lively, with a playful mix of colors and structured details.

%%%

Creative Description: This artwork brings to life a wonderfully whimsical turkey, bursting with colors and charm. Dominated by its big, round eyes that exude curiosity, this turkey is a delightful character. Its orange beak and the red wattle add a touch of character, giving the impression of a playful, animated bird ready to gobble.

The turkey's body is shaded in rich browns, providing a realistic texture as if the feathers are soft to touch. The tail feathers fan out in a rainbow of colors, featuring shades of green, blue, pink, yellow, and orange. These feathers are artistically filled with watercolor effects, blending gently to create a sense of depth and movement.

The background complements the turkey beautifully with a light blue hue scattered with small black dots, perhaps suggesting a gentle snowfall or a starry sky. The entire artwork is outlined in bold black lines, creating a striking stained-glass effect that makes the colors pop even more. Swirling lines and loops add an extra layer of detail to the feathers, enhancing the whimsical feel of this playful creature.

%%%

What inspired you to choose these particular colors for the turkey's feathers?

Can you tell me about the patterns and details you added around the turkey's feathers?

How did you decide on the background design with the blue and black dots?

Sending follow-up question...
Running follow-up...
Polling for follow-up result...
Fetching follow-up messages...
Follow-up description: 

Title: Rainbow-Turkey

%%%

Descriptive Description: This artwork features a large, stylized depiction of a turkey, centralized prominently. The turkey has large, round eyes that dominate its face, each eye outlined in black with white centers and large black pupils. The beak is triangular and orange with a red wattle hanging from the side. The turkey's body is composed of a large, rounded shape filled with varying shades of brown, giving it a textured appearance.

Its tail feathers fan out around the body and are divided into multiple sections, each filled with bright colors that the child mentioned: green, blue, pink, yellow, orange, and red. These sections are bordered in bold black lines. Some sections appear to have subtle watercolor gradients, blending slightly rather than being solid blocks of color. Around the edge of the tail feathers, there are details drawn in black, such as curved lines and loops, giving additional texture to the feathers.

The background of the image is a light blue color, with small, irregular black dots scattered throughout. The entire artwork is outlined and partitioned with bold black lines that create a stained-glass effect. The swirly lines in the background, mentioned by the child, add a sense of wind blowing around the turkey's feathers, enhancing the dynamic feel of the composition. The overall appearance is vibrant and lively, with a playful mix of colors and structured details.

%%%

Creative Description: This artwork bursts with the joyful spirit of a rainbow turkey, crafted with a colorful and lively touch. Dominated by its big, round eyes that express a sense of curiosity, this turkey invites a smile. Its bright orange beak and vibrant red wattle give it a whimsical personality, making it stand out against the backdrop.

The turkey's body is richly shaded with browns, creating a natural and textured appearance that contrasts beautifully with the vivid, multicolored tail feathers. These feathers fan out magnificently in a blend of green, blue, pink, yellow, orange, and red, reflecting all the artist's favorite colors. The watercolor gradients create a sense of fluidity, while the bold black outlines and swirly details add a delightful touch of movement, as if the feathers are fluttering in the breeze.

The background provides a complementary setting with a light blue hue scattered with small black dots, evoking a playful, almost magical atmosphere. The swirling lines mentioned by the child suggest a gentle wind, giving the whole scene a dynamic and 'fun' feel, as if the turkey is standing proudly in a breezy meadow. With its vibrant colors and imaginative details, this turkey captures a sense of joy and creativity, making it a truly eye-catching piece.

%%%

What inspired you to blend the colors together for the feathers? 

Can you tell me more about how you created the texture on the turkey's body?

What other elements or details would you like to add to this scene to make it even more fun?
'''
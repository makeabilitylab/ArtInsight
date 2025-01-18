from PIL import Image
import os

# Define the directory containing the images (same directory as the script)
image_folder = os.path.join(os.path.dirname(__file__), 'images')

# Define the maximum width and height
max_size = (1000, 1000)

# Loop through all files in the directory
for filename in os.listdir(image_folder):
    if filename.lower().endswith('.jpg') or filename.lower().endswith('.jpeg'):
        filepath = os.path.join(image_folder, filename)
        
        with Image.open(filepath) as img:
            # Get current width and height
            width, height = img.size
            
            # Check if resizing is needed
            if width > max_size[0] or height > max_size[1]:
                # Calculate the new size while maintaining aspect ratio
                img.thumbnail(max_size, Image.LANCZOS)
                
                # Save the resized image
                img.save(filepath)
                print(f'Resized {filename}')
            else:
                print(f'{filename} is already within the size limits')
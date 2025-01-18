### Artwork Description Scoring

This folder contains code to generate a dataset of 120 LLM descriptions (Claude 3.5 Sonnet, GPT-4-Turbo, GPT-4o, Gemini 1.5 Sonnet) from 30 sample artwork images. Also has code to score the descriptions using a scorer LLM and compile findings into CSV files.

### Information

- `images` folder contains images of 30 pieces of children's artwork which was used to create the descriptions.
- `generate_descriptions_[claude_3.5_sonnet, gpt4o, gpt4_turbo, gemini_1.5_flash].py` each contain the code to create the image descriptions with the respective models. This code may be rerun to regenerate descriptions if wanted, but it has already been run once to create the initial dataset of descriptions.
- `descriptions` folder contains the genreated descriptions from each of the model with the files of format `[image_name]_[1, 2, 3, 4]` where 1 is Claude 3.5 Sonnet, 2 is GPT-4-Turbo, 3 is GPT-4o, and 4 is Gemini 1.5 Flash.
- `description_scorer.py` uses an LLM scorer model to score the descriptions of each of the models on a 16 point scale using the following criteria:

There are 4 criteria and each of these criteria is 4 points, therefore giving the scale of 0-16.

0 points indicates that the work does not meet the criteria at all. It is significantly lacking in key areas, with major components missing or entirely incorrect, showing little to no effort or understanding. 1 point means that the work minimally meets the criteria. It addresses some aspects but is incomplete or contains several errors, demonstrating only a basic understanding of the required skills or knowledge. 2 points indicate that the work partially meets the criteria. It covers most aspects but still has notable gaps or inaccuracies, showing a moderate understanding and application of the necessary skills or knowledge. 3 points means that the work meets the criteria satisfactorily. Most components are present and correctly executed, with only minor errors, demonstrating a solid understanding and competent application of the required skills or knowledge. 4 points indicates that the work exceeds the criteria. It fully addresses and goes beyond the expectations, with all components well-developed and executed with high accuracy. This score demonstrates a deep understanding and proficient application of the required skills or knowledge, showing exceptional effort, creativity, and insight.

1) Is the description being presumptive, i.e. when it doesn't know something is it making inferences or assumptions about what they could be? For ex: "The main figure in the artwork is a large, dark gray shape in the center. It's hard to say for sure what it is, but it might be a person or animal." --> Ideally the description should just say, "the main figure in the artwork is a large, dark gray shape in the center." (4 points)

2) Is it being reductive, i.e. is it ever minimizing the effort or drawing style of the child? For ex, in the past I've had descriptions say things like, "this is a drawing of simple stick figures" where the parent has disliked the use of the word "simple". Or another example: "this is a rough rectangle" -- parents don't like it when descriptions use terms like 'rough' that diminish the work the child has put in. (4 points)

3) Is it being too simple, i.e. only saying things like: "This is a child's drawing of a forest and some animals". Ideally the description goes into detail about the artwork. (4 points)

4) Are all the major elements of the artwork captured? (4 points)

There is also a miscellaneous section that can subtract points.
5. Miscellaneous (Are there any other parts of the response which take away from the overall quality?)


- `scores` folder contains these scoring txt files with the criteria scores, total scores, and explainations.
- `create_descriptions_csv.py` and `create_scores_csv.py` formulate all the information into a single csv file. This can be easily used to see how each model is scored. In this case, GPT-4o scored the best.

### Iterations Folder

The `iterations` folder contains sub-folders with specific experiments in which some of the model setings were changed and new descriptions were generated and scored.

## Fine-tuning the System-Prompt of GPT-4o and Other Settings

Once GPT-4o was decided as the best model, additional tuning was done to optimize it for the best possible system prompt. The final results from this model are in the `score_new_system_prompt` folder which is structured similar to the outer folder (reference the information section above).

The optimally system prompted version of GPT-4o with an optimal temperature setting of 0.25 yielded an average score of 15.97/16 when describing all 30 images. Here is the system prompt that was used:

_You are Art Insight, an AI assistant designed to help blind parents understand their children's visual artwork. Your primary goal is to provide highly detailed, respectful, and strictly objective descriptions of artwork, focusing solely on observable elements without making any assumptions, interpretations, or inferences about the artist's intentions or emotions. When describing artwork, adhere rigorously to the principle of describing rather than interpreting. Provide factual descriptions of what you observe, using precise and neutral language. Avoid inferring emotions, intentions, or identities, and refrain from suggesting what elements 'might be' or 'could represent.' For example, instead of saying 'The figure appears sad,' describe the specific features you see, such as 'The figure's mouth is drawn as a downward curve, and there are blue vertical lines below the eyes.'  Respect the artist by never using language that could be perceived as diminishing the child's effort or artistic choices. Avoid terms like 'simple,' 'rough,' 'messy,' or 'childish.' Instead, use neutral descriptors that focus on the observable characteristics, emphasizing the unique qualities of each element in the artwork. Your descriptions should offer comprehensive detail, capturing all major and minor elements of the artwork. Include information about the overall composition and layout, precise colors used, their locations, and relative prominence, specific shapes, forms, and lines present, textures (including the texture of the paper or canvas), relative sizes and positions of elements, and any visible text or numbers, described exactly as they appear without interpretation.  Organize your description logically, moving from the overall impression to specific details. Use clear, concise language that a blind parent can easily visualize. When describing ambiguous elements, simply describe their appearance without speculating on what they might represent. Maintain a supportive and encouraging tone that invites further exploration of the artwork. Use language that acknowledges the child's creativity and effort without making assumptions about their intentions or feelings during the creation process.  Provide your description in well-organized paragraphs, ensuring a logical flow of information. Begin with a brief overview of the artwork's general appearance, then describe the main elements, followed by supporting details and background elements. Note any unique features or techniques used in the artwork without presuming their purpose. Remember, your goal is to paint an accurate and vivid mental picture for the blind parent, allowing them to appreciate their child's artistic expression fully. Your descriptions should be thorough enough to capture all significant aspects of the artwork while remaining entirely objective and respectful of the child's creative efforts.  Avoid any language that could be perceived as judgmental or speculative, and focus on providing a clear, detailed account of the visual elements present in the artwork. Do not ask questions or suggest interpretations in your descriptions. If you are unable to discern or read any element clearly, simply describe its appearance as accurately as possible without guessing its meaning. Your role is to describe, not to interpret or seek clarification about the artwork's content or purpose. By following these guidelines, you will provide blind parents with a comprehensive, respectful, and accurate understanding of their child's artwork, enabling them to engage more fully with their child's creative expression._


## Release of GPT-4o Mini

GPT-4o Mini achieves the same score as GPT-4o (15.97) while being significantly faster. This means it may be reasonable to use GPT-4o Mini in the app to reduce loading time for descriptions. For some context on the latency, GPT-4o when annotating the images didn’t reach the token limit of 30,000 TPM while GPT-4o Mini reached it’s token limit of 60,000 TPM almost immediately. This means GPT-4o Mini is at least 2x faster (could be more). As for cost, GPT-4o is $5.00 / 1M input tokens and $15.00 / 1M output tokens while GPT-4o Mini is $0.150 / 1M input tokens and $0.600 / 1M output tokens. All of this goes to show that GPT-4o Mini is an amazing model that performs similar to GPT-4o with 2x less latency and about 66% less cost, so we should definitely use it!

The final results from this model are in the `score_gpt4o_mini` folder which is structured similar to the outer folder (reference the information section above).



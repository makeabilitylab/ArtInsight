//
//  Variables.swift
//  Mixed-Ability-Artwork
//
//  Created by Ritesh Kanchi on 7/26/24.
//

import SwiftUI

struct ButtonVals {
    var icon: String
    var iconFill: String
    var text: String
    var bgColor: Color
    var foreColor: Color = .white
    var index: Int
}

let detents: Set<PresentationDetent> = Set([.small, .medium, .large])

let buttons: [ButtonVals] = [
    ButtonVals(icon: "text.viewfinder", iconFill: "text.viewfinder", text: "Descriptions", bgColor: .yellow, foreColor: .black, index: 0),
    ButtonVals(icon: "mic", iconFill: "mic.fill", text: "Recording", bgColor: .red, index: 1),
    ButtonVals(icon: "questionmark.bubble", iconFill: "questionmark.bubble.fill", text: "Questions", bgColor: .purple, index: 2)
]

let root = "Mixed-Ability-Artwork/Descriptions"

let samples = [ImageDescription(id: "Image-1", uiImage: UIImage(named: "children1")!, descriptiveDescription: "Description 1", creativeDescription: "creative 1", questions: ""),
               ImageDescription(id: "Image-2", uiImage: UIImage(named: "children2")!, descriptiveDescription: "Description 2", creativeDescription: "creative 2", questions: ""),]

let transcriptionPrompt = """
You will now be provided with a transcription of the conversation between the blind parent and the child about the artwork with more accurate information about the child's intentions when creating the artwork.
Using the information provided in the transcription, your task is to regenerate your response with the 4 parts. Your goal is to use the new information from the transcriptions to modify the original information and add new details based on those insights. The new questions you generate must help continue and enhance the conversation from the transcription.
Here is the transcription:
"""

let transSample = """
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


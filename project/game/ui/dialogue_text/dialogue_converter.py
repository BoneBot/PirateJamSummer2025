import json
import os
import re

def convert_to_json(plain_text):
    # Pattern matches lines like: SPEAKER (emotion): dialogue
    pattern = re.compile(r'^(\w+)\s+\(([^)]+)\):\s+(.+)$')
    output = []

    for line in plain_text.strip().split('\n'):
        match = pattern.match(line)
        if match:
            speaker, emotion, text = match.groups()
            entry = {
                "speaker": speaker.lower(),
                "text": text.strip(),
                "emotion": emotion.strip().lower()
            }
            output.append(entry)
        else:
            print(f"Skipping line (format issue): {line}")

    return output

# Example usage
if __name__ == "__main__":
    plain_text = """
SOL (neutral): Hey, Dolly? 

DOLLY (neutral): Yes Sol? 

SOL (neutral): Do you know where we are? 
DOLLY (neutral): I believe we're in the forest, keeping busy and out of the way while dad fixes the car tire. 
SOL (unamused): Right, but do you know where we are in the forest? 
DOLLY (neutral): Oh, well we should be... 
DOLLY (neutral): Um... 
DOLLY (nervous): Oh dear, I don't see the pathway we came from. 
DOLLY (nervous): Are we lost? 
SOL (nervous): Um, I think we are. 
DOLLY (nervous): What?! Oh no no no! Mom and dad will be worried sick! 
DOLLY (nervous): How are we going to get back to them? 
SOL (determined): Well... I guess we'll just have to find our way back out. 
SOL (happy): It can't be too hard, right? 
DOLLY (nervous): Oh, but what if we get more lost? Or one of us gets hurt? I don't want my face to get chipped... Or yours, for that matter. 
SOL (happy): Well, we can't just stay in one spot right? Then we'll never have a chance of getting out. 
DOLLY (nervous): Well, I suppose you have a point... But we'll be careful, right? 
SOL (laughing): Of course we will. 
DOLLY (happy): Oh, good! Then let's continue on. 
"""

    json_output = convert_to_json(plain_text)

    # Print each JSON object separately
    # for item in json_output:
    #     print(json.dumps(item, indent=4) + ',')

    # Define path to temp.txt in current directory
    output_path = os.path.join(os.path.dirname(__file__), "temp.txt")

    # Write each JSON dictionary with trailing comma to the file
    with open(output_path, 'w', encoding='utf-8') as f:
        for item in json_output:
            f.write(json.dumps(item, indent=4))
            f.write(',\n')  # Add a comma and newline after each entry

    print(f"Output written to {output_path}")

import json
import re
import os

def convert_to_json(plain_text):
    # Pattern matches lines like: SPEAKER (emotion): dialogue
    pattern = re.compile(r'^(\w+)\s+\(([^)]+)\):\s+(.+)$')
    output = []

    for line in plain_text.strip().split('\n'):
        line = line.strip()
        if not line:
            continue  # Skip empty lines
        match = pattern.match(line)
        if match:
            speaker, emotion, text = match.groups()
            entry = {
                "speaker": speaker.lower(),
                "text": text.strip(),
                "emotion": emotion.strip().lower()
            }
        else:
            # Treat as narration if not matching speaker format
            entry = {
                "text": line
            }
        output.append(entry)

    return output

# Example usage
if __name__ == "__main__":
    plain_text = """
SOL (scared): What?! There are so many roses! How are we going to find our way out? 

TEDDY (happy): Ooohhh, pretty! 

SOL (determined): Teddy, we need to find the right roses to get out of here! How are we going to tell the right ones apart? 

TEDDY (concerned): Hmm? Well- 

SOL (nervous): And what if we never find the right roses? What if we don't find mom and dad again? 

TEDDY (happy): Hey, Sol- 

SOL (scared): Then we'll be stuck here forever and ever with no way out and-

TEDDY (surprised): Sol! 

SOL (nervous): Yeah? 

TEDDY (happy): It'll all be ok. We'll find our way back. 

SOL (neutral): You... really think so? 

TEDDY (happy): Sure! We made it this far, right? We just had to slow down, stop, and think for a little bit, yeah? 

SOL (neutral): Yeah, we just had to stop... 

SOL (unamused): ...and smell the roses... 

SOL (unamused): Oh man, that was so corny! 

TEDDY (happy): Aww, no it wasn't, it was sweet! Like the smell of roses! 

TEDDY (happy): Or like apple pie... 

SOL (laughing): Mmm... apple pie... ha ha! 

"""

    json_output = convert_to_json(plain_text)

    # Define path to temp.txt in current directory
    output_path = os.path.join(os.path.dirname(__file__), "temp.txt")

    # Write each JSON dictionary with trailing comma to the file
    with open(output_path, 'w', encoding='utf-8') as f:
        for item in json_output:
            f.write(json.dumps(item, indent=4))
            f.write(',\n')  # Add a comma and newline after each entry

    print(f"Output written to {output_path}")

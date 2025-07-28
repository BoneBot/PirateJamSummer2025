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
You investigate the flower closer. It's a rose with the brightest red petals you've ever seen. 

SOL (surprised): Wow, that's... beautiful. I didn't even notice it before. 

TEDDY (happy): Isn't it? Aaahhh, I love the forest. It's so much more colorful than the bed, haha! 

TEDDY (sleepy): Ahh, bed... sleepy... zzz... 

SOL (determined): What- hey, hey! Teddy! 

TEDDY (surprised): zzz... UP, I'm up! I'm not asleep! 

SOL (laughing): Ha ha! You almost fell asleep standing up! 

TEDDY (concerned): Ha ha... Yeah, um, I almost did. 

SOL (neutral): Do you think mom would like the rose? 

TEDDY (happy): Well of course she would! We should bring it to her! 

SOL (happy): Yeah, she would. 

You try to pluck the rose. As your fingers brush the petals, you hear a creaking of vines shifting from the other end of the clearing. 

SOL (neutral): Did you hear that? 

TEDDY (happy): Hmm? 

SOL (surprised): I think the rose loosened those vines over there. 

SOL (happy): Maybe there's more! And maybe if we find them, we can get through the vines! 

TEDDY (happy): Yes, genius! Let's go look for more. 

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

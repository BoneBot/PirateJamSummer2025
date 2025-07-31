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
SOL (Surprised): There's the exit!

SHADOW (neutral): So, it was you two who moved my things around. 

SOL (scared): Eek!!!

JACK (Joking): Whoa! Who's this ugly mug?

SHADOW (neutral): ...Ugly? Now that seems uncalled for. 

SOL (Nervous): I-I apologize for my friend, Mr. Forest-spirit-guy-sir!  We just wanted to get out of the forest.

JACK (Angry): Yeah! You left so much junk laying around we were trapped for ages!

SHADOW (nervous): Trapped? In the forest? Didn't you see the path I made?

SOL (Surprised): ......PATH???

SHADOW (neutral): Well of course. It even had a machine for concessions on the way out. 

SHADOW (neutral): The miniature donuts are quite... delicious. Perfect for a pair of travelers like you. 

JACK (Smug): Weeeeellll this was a fun chit chat, but it's really time we get goin'. 

SOL (Laughing): Maybe next time we can visit the vending machine, Mr. Shadow Guy!

SHADOW (neutral): Yes, yes, next time. Perhaps... 

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

# Extracting Chakobsa Dialogue

Write a perl script that can extract the Chakobsa dialogue from the text files found in sources/txt/.  The data needs to be written out as JSON, including the following data:

1. The scene number
2. The character name
3. The English dialogue
4. The Chakobsa translation
5. The phonetic transcription
6. The English translation of the Chakobsa translation

Here is an example of the data I want extracted:

For this element of the script:
```
------------------------------------------------------------------37

INT. DINING HALL - DAY

37

(JESSICA_DUNE_10.mp3)
JESSICA
You’re Fremen.
TRANSLATION
She Fremin.
PHONETIC
she FRE-min.
You (are) Fremen.
```

The JSON should look like this:

```json
[
  {
    "scene": 37,
    "character": "JESSICA",
    "english_dialogue": "You’re Fremen.",
    "chakobsa_translation": "She Fremin.",
    "phonetic_transcription": "she FRE-min.",
    "translation_english": "You (are) Fremen."
  }
]
```

The script should process all the files in sources/txt/ and output the JSON to a single file at `sources/chakobsa.json`.  Call this script `extract_chakobsa.pl`.  It should be written in safe perl 5.30 with `strict` and `warnings` pragmas enabled.  It should use the `JSON` module to output the JSON data.  It should be written in a way that is easy to understand and maintain.  It should be well-documented with comments explaining the code.

## Follow-up

Have the script replace any U+2019 characters with a standard apostrophe.  Also skip any entries that have "(Please see video.)" as the Chakobsa translation.
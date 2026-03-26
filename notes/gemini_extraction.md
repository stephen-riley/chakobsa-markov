# Extracting the Chakobsa using Gemini 3.1 Pro

This was done on the PDF script files.

## Prompt

```
Extract the Chakobsa text, its phonetic transcription, and the English translation of the Chakobsa from these Dune movie scripts and present it as structured JSON.  Include the following data for each translation.

1. Which movie and the line number from the script as `"line": "1/10"`, which would mean "the 10th line of the first movie script".
1. The phonetic transcription as `phonetic`.
1. The English translation of the Chakobsa translation as `translation`.

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

Ignore any sections that:
* say something to the effect of "please see video"
* say "N/A"
* Are spoken by Sardukar characters

Please replace any Unicode symbols with the closest ASCII symbols, just as U+2019 to a plain apostrophe and "fancy" quotation marks to simple ASCII ones.

Be sure to process all of both documents and return a single JSON structure.
```

# Adding parts of speech to the dictionary

## Prompt

```
`chakobsa.json` is an extract from the scripts for the movies "Dune: Parts 1 and 2".  `phonetic_dictionary.json` was built from `chakobsa.json`.  What I need you to do is add the parts of speech of each Chakobsa word in the phonetic dictionary based on its use in the script extracts.  Use 3 or 4 letter abbreviations for the parts of speech as needed and make these codes all caps; for example, "NOUN", "VERB", "ADJ", "ADV", "PREP".  Put these in a `pos` field in the JSON of the dictionary.  Return the updated form of the phonetic dictionary in clean JSON.  Only return the JSON--don't add any commentary or explanation.
```
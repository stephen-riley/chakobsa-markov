# Part of speech algorithm

## Prompt

```markdown
Can you sketch out an algorithm with the requirements below, or should I use a coding tool like Antigravity or Claude?

Requirements:
* May only use the tables
* Must accept a list of Chakobsa words 
* For each word
   ** Identify all the parts of speech that the word might be
   ** For each of the possible parts of speech, indicate its aspect or declension or whatever the right terms are for nouns, verbs, etc.; indicate its stem; and indicate the meaning of all prefixes and/or suffixes
```

## Response

I can certainly sketch out the structural logic for this algorithm for you! Because I am an AI participating in a chat, I cannot execute the code against a live list of words for you, so taking this algorithmic logic to a dedicated coding tool like Claude or a Python environment would be the perfect next step to actually build and run the script.

Based **strictly on the provided Chakobsa grammar tables**, here is how an algorithm would process a list of words to identify their parts of speech, properties, stems, and affixes.

### **Phase 1: Build the Lexicon (The Knowledge Base)**

Before processing any words, the algorithm must load the finite rules and stems from the tables into its memory.

* **Load Pronouns & Affixes:** Store the exact strings for all prefixes and suffixes.

  * *Dependent Suffixes:* `-yi`, `-ii`, `-(a)sh`, `-(a)ha`, `-(i)m`, `-(a)k`, `-bit`, `-bet`.
  * *Object Suffixes:* `-ni`, `-nii`, `-sha`, `-shii`, `-la`, `-ho`, `-ma`, `-ga`, `-kaa`, `-bi`, `-ba`.
  * *Case Prefixes:* `un-`, `n-` (Locative); `a-`, `h-` (Allative); `is-`, `ish-`, `s-` (Ablative).

* **Load Noun Stems & Paradigms:** Store the base unmodified stems (e.g., *ekkeri*, *kwadi*, *ukri*, *shadvi*) and map them to their C-Initial, V-Initial, or G-Final declension patterns (Nominative, Accusative, Genitive, Locative, Allative, Ablative) for both Singular and Plural, Unmodified and Modified states.

* **Load Verb Stems & Paradigms:** Store the base unmodified verb stems (e.g., *shuna*, *nakala*) and map them to their Standard, Causative, and Passive conjugation patterns for both the Imperfect and Perfect aspects, across all persons and stem modifications.

### **Phase 2: Word Processing Loop**

**Input:** A list of Chakobsa words.
**Action:** For each `word` in the list, initialize an empty `possible_parses` list. The algorithm will run the `word` through three checks:

**Check 1: Exact Match Evaluation**
The algorithm compares the `word` directly against the generated Lexicon.

* If `word` matches an independent pronoun (like *ne*, *she*, *ho*, *mem*, *kaah*, *bit*, *bet*), tag the part of speech as **Pronoun**, and output its person and number.
* If `word` matches an inflected noun exactly (e.g., *dauman*), tag as **Noun**, indicate its stem (*dumin*), declension case (Genitive), number (Plural), and stem state (Modified).
* If `word` matches an inflected verb exactly (e.g., *nakkulim*), tag as **Verb**, indicate its stem (*nakala*), voice (Causative), aspect (Perfect), person (1st Person Plural), and stem state (Modified).

**Check 2: Prefix Analysis (Nouns)**
If the word does not match a base form, the algorithm checks the beginning of the word for case markers.

* *Action:* Strip leading prefixes like `un-`, `n-`, `a-`, `h-`, `is-`, `ish-`, or `s-`.
* *Validation:* Does the remaining substring match a known noun stem from Phase 1?
* *Output generation:* If yes, tag as **Noun**, output the core stem, and output the meaning of the prefix:
  * `un-` or `n-` means **Locative case**.
  * `a-` or `h-` means **Allative case**.
  * `is-`, `ish-`, or `s-` means **Ablative case**.

**Check 3: Suffix Analysis (Possession & Objects)**
The algorithm checks the end of the word to account for attached dependent or object pronouns.

* *Action:* Strip ending suffixes (e.g., `-ii`, `-ash`, `-aha`, `-im`, `-ak`, etc.).
* *Validation:* Does the remaining substring match a known noun OR verb stem?
* *Output generation:* Because suffixes apply to multiple parts of speech, the algorithm must append all valid interpretations to `possible_parses`:
  * If the root is a noun, tag as **Noun** and output the suffix meaning as **Dependent Possessive** (e.g., `-aha` means "Third Person Singular possession").
  * If the root is a verb, tag as **Verb** and output the suffix meaning as the **Dependent Subject** or **Object Receiver** of the action (e.g., `-aha` means "Third Person Singular subject").

### **Phase 3: Output Generation**

For each word, the algorithm prints the `possible_parses` list.

**Example Algorithm Output for the word "un-kaudi":**

* **Part of Speech:** Noun
* **Declension:** Locative Case, Plural, Modified Stem.
* **Stem:** *kwadi*.
* **Affix Meanings:** The prefix `un-` indicates the Locative case.

**Example Algorithm Output for the word "shunaaha":**

* **Possibility A:**
  * **Part of Speech:** Verb
  * **Aspect:** Imperfect, Standard voice, Unmodified stem.
  * **Stem:** *shuna*.
  * **Affix Meanings:** The suffix `-ha` indicates the Third Person Singular.
* **Possibility B:**
  * **Part of Speech:** Noun
  * **Declension:** Nominative/Infinitive base, Singular.
  * **Stem:** *shuna* (Assuming *shuna* acts as a noun "sleep" in the lexicon).
  * **Affix Meanings:** The suffix `-aha` indicates a Third Person Singular dependent possessive.

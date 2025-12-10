
# Chapter 1: Understanding Zero Trust

## Resume Parser Example

[resume-parser.py](resume-parser.py) - A Python-based resume parsing tool that demonstrates text extraction and natural language processing techniques. This example:

- **Extracts structured data** from resume files (PDF and DOCX formats)
- **Identifies key information** including names, phone numbers, email addresses, and work experience years using regular expressions and NLP
- **Performs skills matching** against predefined skill databases for AWS and Azure cloud platforms
- **Uses NLTK library** for natural language processing tasks like tokenization, named entity recognition, and n-gram generation


```
from pdfminer.high_level 
import extract_text as pdf_extract_text
import docx2txt 
import nltk 
import re
import subprocess nltk.download('stopwords')
nltk.download('punkt') 
nltk.download('averaged_perceptron_tagger') 
nltk.download('maxent_ne_chunker') 
nltk.download('words')

```

Notice the number of import statements in the code and the number of downloads before you start processing a single resume. Any of these imported libraries could introduce a vulnerability that could send your data to an external system or URL. Imagine if such a program were processing confidential data. This is the simplest example and only one type of threat. In a world where everything runs on code, various threat actors with lots of money can do a lot of damage, let alone causing accidental issues such as what happened at CrowdStrike due to a mistake.

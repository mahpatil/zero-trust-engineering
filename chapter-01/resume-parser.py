# Inspired by promptapi.com build-your-own-resume-parser-using-python-and-nlp

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

PHONE_REG = re.compile(r'[\+\(]?[1-9][0-9 .\-\(\)]{8,}[0-9]')
#YEARS_REG = re.compile('(?P<month>([a-zA-Z]+)|(\d{2}))(\s|,)+(?P<year>\d{4})')
YEARS_REG = re.compile('((?:Jan(?:uary)?|Feb(?:ruary)?|Mar(?:ch)?|Apr(?:il)?|May|Jun(?:e)?|Jul(?:y)?|Aug(?:ust)?|Sep(?:tember)?|Oct(?:ober)?|(Nov|Dec)(?:ember)?)\D?)\s+(?P<year>\d{4})')

EMAIL_REG = re.compile(r'[a-z0-9\.\-+_]+@[a-z0-9\.\-+_]+\.[a-z]+', re.IGNORECASE)


SKILLS_DB_AWS = [
    'aws',
    'kubernetes', 'EKS', 'containers', 'docker',
    's3',
    'rds',
    'vpc', 'subnet', 
    'cloudwatch', 'cloudtrail',
    'terraform', 'jenkins'
 ]
SKILLS_DB_AZURE = [
    'Azure',
    'Kubernetes', 'AKS', 'Containers', 'Docker',
    'VNET', 'Firewall', 'AppGateway', 'Application Gateway'
    'Azure Monitor', 'Monitor', 'Log Analytics', 'LogAnalytics',
    'Terraform', 'Azure DevOps'
 ]

class ResumeProcessor:
    text = None

    def __init__(self, filepath):
        self.filepath = filepath
        self.text = None
        self.phone_numbers = []
        self.years = []
        self.person_names = []
        self.extract_text()
        self.extract_names()
        self.extract_phone_numbers()
        self.extract_years()
        self.extract_emails()
        
    def extract_text(self):
        self.text = None
        
    def extract_names(self):

        for sent in nltk.sent_tokenize(self.text):
            for chunk in nltk.ne_chunk(nltk.pos_tag(nltk.word_tokenize(sent))):
                if hasattr(chunk, 'label') and chunk.label() == 'PERSON':
                    self.person_names.append(
                        ' '.join(chunk_leave[0] for chunk_leave in chunk.leaves())
                    )
    def extract_phone_numbers(self):
        numbers = re.findall(PHONE_REG, self.text)
        for n in numbers:
            if len(n.replace(' ', '')) >= 10:
                temp_phone = ''.join(n)
                if self.text.find(temp_phone) >= 0 and len(temp_phone) < 20:
                    #print(f'found phone number len>10 and len<20')
                    self.phone_numbers.append(temp_phone)

    def extract_years(self):
        years = re.findall(YEARS_REG, self.text)
        for n in years:
            self.years.append(int(n[len(n)-1]))
        #print(min(self.years))
    
    def extract_emails(self):
        self.email_address = re.findall(EMAIL_REG, self.text)


    def extract_skills(self, profile_type):
        stop_words = set(nltk.corpus.stopwords.words('english'))
        word_tokens = nltk.tokenize.word_tokenize(self.text)

        # remove the stop words
        filtered_tokens = [w for w in word_tokens if w not in stop_words]

        # remove the punctuation
        filtered_tokens = [w for w in word_tokens if w.isalpha()]

        # generate bigrams and trigrams (such as artificial intelligence)
        bigrams_trigrams = list(map(' '.join, nltk.everygrams(filtered_tokens, 2, 3)))

        # we create a set to keep the results in.
        found_skills = set()

        if profile_type == 'aws':
            SKILLS_DB = SKILLS_DB_AWS
        elif profile_type == 'azure':
            SKILLS_DB = SKILLS_DB_AZURE

        # we search for each token in our skills database
        for token in filtered_tokens:
            if token.lower() in SKILLS_DB:
                found_skills.add(token)

        # we search for each bigram and trigram in our skills database
        for ngram in bigrams_trigrams:
            if ngram.lower() in SKILLS_DB:
                found_skills.add(ngram)
        #self.profile_type(profile_type)
        #self.skills
        return found_skills

class PdfResumeProcessor(ResumeProcessor):
    text = None
    def __init__(self, filepath):
        super().__init__(filepath)
        self.extract_text()

    def extract_text(self):
        self.text = pdf_extract_text(self.filepath)

class DocxResumeProcessor(ResumeProcessor):
    def __init__(self, filepath):
        super().__init__(filepath)
        self.extract_text()
    def extract_text(self):
        txt = docx2txt.process(self.filepath)
        if txt:
            self.text = txt.replace('\t', ' ')
        else:
            self.text = None
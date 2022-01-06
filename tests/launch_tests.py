# ---------- Imports ----------
import xml.etree.ElementTree as ET

# ---------- Constantes ----------
NOM_FICHIER_SH = 'launch_tests.sh'
XML_HEADER = '?xml version="1.0" encoding="UTF-8"?'
TAGS = ("tests", "test", "titre", "description", "entree", "sortie",
        "stdin", XML_HEADER)

# ---------- Fonctions ----------
def format_whitespace(s):
    """
    Replace multiple whitespaces with only one, but keeping `\n`.
    ---
    s: string to which you replace whitespaces.
    Source : https://stackoverflow.com/questions/2077897/substitute-multiple-whitespace-with-single-whitespace-in-python/2077944#comment112437185_2077944
    """
    s = s.splitlines()

    s = filter(lambda x: x != '', s) # remove empty string
    s = list(s)

    s = map(lambda x: x.strip(), s) # strip
    s = list(s)

    s = '\n'.join(s)

    return s


def escape_xml_entities(s):
    """
    Given a string s containing XML, escapes <, > and &, BUT it keeps the TAGS
    of the test format.
    Example : "5 < 3" becomes "5 &lt; 3"
    ---
    s: XML string
    """
    LEFT = "-----LEFT_CHEVRON-----"
    RIGHT = "-----RIGHT_CHEVRON-----"

    for tag in TAGS:
        s = s.replace(f"<{tag}>", f"{LEFT}{tag}{RIGHT}")
        s = s.replace(f"</{tag}>", f"{LEFT}/{tag}{RIGHT}")

    s = s.replace("&", "&amp;")
    s = s.replace("<", "&lt;")
    s = s.replace(">", "&gt;")

    for tag in TAGS:
        s = s.replace(f"{LEFT}{tag}{RIGHT}", f"<{tag}>")
        s = s.replace(f"{LEFT}/{tag}{RIGHT}", f"</{tag}>")

    return s



def unescape_xml_entities(s):
    """
    Given a string s containing XML, unescapes <, > and &.
    Example : "5 &lt; 3" becomes "5 < 3"
    ---
    s: XML string
    """

    s = s.replace("&amp;", "&")
    s = s.replace("&lt;", "<")
    s = s.replace("&gt;", ">")

    return s


def create_tests_list(filename):
    """
    Given the filename of an XML test file, returns the tests list.
    ---
    filename: name of the xml test file
    """
    with open(f'tests/{filename}.xml') as fichier_test:
        xml_text = escape_xml_entities(fichier_test.read())

        root = ET.fromstring(xml_text)

        try:
            titre_tests = root.attrib['titre']
        except:
            titre_tests = ''

        try:
            description_tests = root.attrib['description']
        except:
            description_tests = ''

        tests = []


        for t in root.findall('test'):
            t_dict = {}

            try:
                t_dict['titre'] = t.findall('titre')[0].text
                t_dict['titre'] = unescape_xml_entities(t_dict['titre'])
            except:
                t_dict['titre'] = ''

            try:
                t_dict['description'] = t.findall('description')[0].text
                t_dict['description'] = unescape_xml_entities(t_dict['description'])
            except:
                t_dict['description'] = ''

            try:
                t_dict['entree'] = format_whitespace(t.findall('entree')[0].text.strip())
                t_dict['entree'] = unescape_xml_entities(t_dict['entree'])
            except:
                t_dict['entree'] = ''

            try:
                t_dict['sortie'] = format_whitespace(t.findall('sortie')[0].text.strip())
                t_dict['sortie'] = unescape_xml_entities(t_dict['sortie'])
            except:
                t_dict['sortie'] = ''

            try:
                t_dict['stdin'] = format_whitespace(t.findall('stdin')[0].text.strip())
                t_dict['stdin'] = unescape_xml_entities(t_dict['stdin'])
            except:
                t_dict['stdin'] = ''

            tests.append(t_dict)

    return tests

def add_tests(filename, title):
    """
    Cette fonction ajoute les tests au fichier launch_tests.sh.
    ---
    filename: nom du fichier de test (sans l'extension '.xml')
    title: titre affiché dans le script Bash
    """
    tests = create_tests_list(filename)



    with open(NOM_FICHIER_SH, mode='a') as fichier_sortie:
        fichier_sortie.write(f"echo; echo\n")

        padded_title = (' ' + title + ' ')
        fichier_sortie.write(f"echo {padded_title.center(67, '-')}\n")
        fichier_sortie.write(f"echo\n")

        for test in tests:
            titre = test['titre']
            description = test['description']
            entree = test['entree']
            sortie = test['sortie']
            stdin = test['stdin']

            fichier_sortie.write(f"test_expr '{entree}' '{sortie}'\n")


# ---------- Code ----------
add_tests('expr_arithmetiques', 'Expressions Arithmétiques')
add_tests('booleens', 'Booléens')
add_tests('commentaires', 'Commentaires')
add_tests('declarations', 'Déclarations')
add_tests('exposants', 'Exposants')
add_tests('print', 'Print')
add_tests('if', 'If')
add_tests('else_if', 'Else If')
add_tests('do_while', 'Do While')

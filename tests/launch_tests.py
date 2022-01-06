# ---------- Imports ----------
import xml.etree.ElementTree as ET

# ---------- Constantes ----------
NOM_FICHIER_SH = 'launch_tests.sh'


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


def create_tests_list(filename):
    """
    Given the filename of an XML test file, returns the tests list.

    ---
    filename: name of the xml test file
    """
    with open(f'tests/{filename}.xml') as fichier_test:
        root = ET.fromstring(fichier_test)

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
            except:
                t_dict['titre'] = ''

            try:
                t_dict['description'] = t.findall('description')[0].text
            except:
                t_dict['description'] = ''

            try:
                t_dict['entree'] = format_whitespace(t.findall('entree')[0].text.strip())
            except:
                t_dict['entree'] = ''

            try:
                t_dict['sortie'] = format_whitespace(t.findall('sortie')[0].text.strip())
            except:
                t_dict['sortie'] = ''

            try:
                t_dict['stdin'] = format_whitespace(t.findall('stdin')[0].text.strip())
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

'''
This module is used to store all HED tag attributes in a dictionary. The dictionary is a dictionary of dictionaries.
Each dictionary pertains to a specific attribute associated with the HED tags.

Created on Sept 21, 2017

@author: Jeremy Cockfield

'''

from defusedxml.lxml import parse;
import random;

extension_allowed_tags = {};


def get_hed_root_element(hed_xml_file_path):
    """Parses a xml file and returns the root element.

    Parameters
    ----------
    hed_xml_file_path: string
        The path to a HED XML file.

    Returns
    -------
    RestrictedElement
        The root element of the HED XML file.

    """
    hed_tree = parse(hed_xml_file_path);
    return hed_tree.getroot();


def get_all_ancestor_tag_names(tag_element):
    """Gets all the ancestor tag names of a tag element.

    Parameters
    ----------
    tag_element: Element
        A tag element in the HED XML file.

    Returns
    -------
    list
        A list containing all of the ancestor tag names of a given tag.

    """
    ancestor_tags = [];
    try:
        parent_tag_name = get_parent_tag_name(tag_element);
        parent_element = tag_element.getparent();
        while parent_tag_name:
            ancestor_tags.append(parent_tag_name);
            parent_tag_name = get_parent_tag_name(parent_element);
            parent_element = parent_element.getparent();
    except:
        pass;
    return ancestor_tags;

def get_tag_name(tag_element):
    """Gets the name of the tag element.

    Parameters
    ----------
    tag_element: Element
        A tag element in the HED XML file.

    Returns
    -------
    string
        The name of the tag element. If there is no name then an empty string is returned.

    """
    try:
        return tag_element.find('name').text;
    except:
        return '';

def get_parent_tag_name(tag_element):
    """Gets the name of the tag parent element.

    Parameters
    ----------
    tag_element: Element
        A tag element in the HED XML file.

    Returns
    -------
    string
        The name of the tag element's parent. If there is no parent tag then an empty string is returned.

    """
    try:
        parent_tag_element = tag_element.getparent();
        return parent_tag_element.find('name').text;
    except:
        return '';


# def test_get_all_extension_allowed_tags():
#     hed_tree = parse(self.HED_XML);
#     hed_root_element = hed_tree.getroot();
#     hed_node_elements = hed_root_element.findall('.//node');
#     print(len(hed_node_elements))
#     for hed_node_element in hed_node_elements:
#         if 'extensionAllowed' in hed_node_element.attrib:
#             print("Node name: " + hed_node_element.find('name').text);
#             parent_node = hed_node_element.getparent();
#             print("Parent Node name: " + parent_node.find('name').text)

def generate_random_integer(min, max):
    return random.randint(min, max);

if __name__ == '__main__':
    hed_root_element = get_hed_root_element('../tests/data/HED.xml');
    extension_allowed_tags = hed_root_element.xpath('.//node[@required]');
    print extension_allowed_tags


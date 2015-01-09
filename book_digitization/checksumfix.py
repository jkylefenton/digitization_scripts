from eulxml.xmlmap import XmlObject
from eulxml.xmlmap import load_xmlobject_from_string, load_xmlobject_from_file
from eulxml.xmlmap.fields import StringField, NodeListField, IntegerField
from hashlib import md5
from os import path, walk
from re import search
from shutil import copy2
import sys
import fileinput

class METSFile(XmlObject):
    ROOT_NAME = 'file'
    ROOT_NAMESPACES = {
        'xlink': "http://www.w3.org/1999/xlink",
        'mets': 'http://www.loc.gov/METS/'
    }

    id = StringField('@ID')
    admid = StringField('@ADMID')
    mimetype = StringField('@MIMETYPE')
    loctype = StringField('mets:FLocat/@LOCTYPE')
    href = StringField('mets:FLocat/@xlink:href')


class METStechMD(XmlObject):
    ROOT_NAME = 'techMD'
    ROOT_NAMESPACES = {
        'mix': 'http://www.loc.gov/mix/v20',
        'mets': 'http://www.loc.gov/METS/'
    }

    id = StringField('@ID')
    href = StringField(
        'mets:mdWrap/mets:xmlData/mix:mix/mix:BasicDigitalObjectInformation/mix:ObjectIdentifier/mix:objectIdentifierValue')
    size = IntegerField('mets:mdWrap/mets:xmlData/mix:mix/mix:BasicDigitalObjectInformation/mix:fileSize')
    mimetype = StringField(
        'mets:mdWrap/mets:xmlData/mix:mix/mix:BasicDigitalObjectInformation/mix:FormatDesignation/mix:formatName')
    checksum = StringField(
        'mets:mdWrap/mets:xmlData/mix:mix/mix:BasicDigitalObjectInformation/mix:Fixity/mix:messageDigest')


class Mets(XmlObject):
    XSD_SCHEMA = 'http://www.loc.gov/standards/mets/version191/mets.xsd'
    ROOT_NAME = 'mets'
    ROOT_NAMESPACES = {'mets': 'http://www.loc.gov/METS/'}

    tiffs = NodeListField('mets:fileSec/mets:fileGrp[@ID="TIFF"]/mets:file', METSFile)
    jpegs = NodeListField('mets:fileSec/mets:fileGrp[@ID="JPEG"]/mets:file', METSFile)
    altos = NodeListField('mets:fileSec/mets:fileGrp[@ID="ALTO"]/mets:file', METSFile)
    techmd = NodeListField('mets:amdSec/mets:techMD', METStechMD)


def check(kdip, path):
    mets_dir = '%s/%s/METS/' % (path, kdip)
    mets_file = "%s/%s/METS/%s.mets.xml" % (path, kdip, kdip)
    mets = load_xmlobject_from_file(mets_file, Mets)

    for f in mets.techmd:
        file_path = "%s%s" % (mets_dir, f.href)
        with open(file_path, 'rb') as file:
                mets_checksum = f.checksum
                disk_checksum = md5(file.read()).hexdigest()
                if not mets_checksum == disk_checksum:
                    print(file_path)
                    print('\tChecksum on disk = %s, Checksum in METS = %s' % (disk_checksum, mets_checksum))
                else:
                    print(file_path)
                    print('\tChecksums match!')

def recalc(kdip, path):
    mets_dir = '%s/%s/METS/' % (path, kdip)
    mets_file = "%s/%s/METS/%s.mets.xml" % (path, kdip, kdip)
    mets_file_bak = "%s.bak" % (mets_file)
    mets = load_xmlobject_from_file(mets_file, Mets)

    copy2(mets_file,mets_file_bak)

    for f in mets.techmd:
        file_path = "%s%s" % (mets_dir, f.href)
        with open(file_path, 'rb') as file:
                mets_checksum = f.checksum
                disk_checksum = md5(file.read()).hexdigest()
                if not mets_checksum == disk_checksum:
                    f.checksum = disk_checksum
                    print(file_path)
                    print('\tChecksum on disk = %s, Checksum in METS = %s' % (disk_checksum, mets_checksum))
                else:
                    print(file_path)
                    print('\tChecksums match!')
    with open(mets_file, 'w') as newmets:
        newmets.write(mets.serialize(pretty=True))
    for f in mets.techmd:
        file_path = "%s%s" % (mets_dir, f.href)
        with open(file_path, 'rb') as file:
                mets_checksum = f.checksum
                disk_checksum = md5(file.read()).hexdigest()
                if not mets_checksum == disk_checksum:
                    f.checksum = disk_checksum
                    print(file_path)
                    print('\tChecksum on disk = %s, Checksum in METS = %s' % (disk_checksum, mets_checksum))
                else:
                    print(file_path)
                    print('\tChecksums match!')

kdip_dir = sys.argv[1]
kdip = sys.argv[2]
# kdip_list = {}

# for path, subdirs, files in walk(kdip_dir):
#    for directory in subdirs:
#        kdip = search(r"^[0-9]+$", directory)
#        kdip = sys.argv[2]
#        full_path = '%s/%s' % (path, directory)
#        if kdip and 'out_of_scope' not in full_path:
#            kdip_list[directory] = path

# for k in kdip_list:

recalc(kdip, kdip_dir)
#check(kdip, kdip_dir)

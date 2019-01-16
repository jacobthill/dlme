require_relative 'xml_reader'
require_relative 'dlme_json_resource_writer'
require_relative 'macros/dlme'
require_relative 'macros/extraction'
require_relative 'macros/xml'

extend Macros::DLME
extend Macros::Xml

settings do
  provide 'writer_class_name', 'DlmeJsonResourceWriter'
  provide 'reader_class_name', 'XmlReader'
end

NS = { srw: "http://www.loc.gov/zing/srw/", oai_dc: "http://www.openarchives.org/OAI/2.0/oai_dc/", dc: "http://purl.org/dc/elements/1.1/"}

records = 'srw:records/srw:record/srw:recordData/oai_dc:dc'

# General Questions:
# how to deal with French language metadata?
# several fields have multiple elements; only the first is extracted

# Cho Required
to_field 'id', extract_xml("#{records}/dc:identifier", NS) # can urls be used as identifiers in spotlight?
to_field 'cho_title', extract_xml("#{records}/dc:title", NS) # there are sometimes multiple titles in different languages; only extracts the first

# Cho Other 
to_field 'cho_contributor', extract_xml("#{records}/dc:contributor", NS)
to_field 'cho_creator', extract_xml("#{records}/dc:creator", NS) # has a name and a role; role needs to deleted or normalized
to_field 'cho_date', extract_xml("#{records}/dc:date", NS)
to_field 'cho_description', extract_xml("#{records}/dc:description", NS) 
to_field 'cho_dc_rights', extract_xml("#{records}/dc:rights", NS) 
to_field 'cho_format', extract_xml("#{records}/dc:format", NS)
to_field 'cho_has_type', extract_xml("#{records}/dc:type", NS)
to_field 'cho_language', extract_xml("#{records}/dc:language", NS) # needs to be normalized
to_field 'cho_publisher', extract_xml("#{records}/dc:publisher", NS)
to_field 'cho_relation', extract_xml("#{records}/dc:relation", NS)
to_field 'cho_source', extract_xml("#{records}/dc:source", NS) #
to_field 'cho_subject', extract_xml("#{records}/dc:subject", NS)

# Agg
to_field 'agg_data_provider', literal("The Bibliothèque nationale de France") # the institution we harvested the data from?
to_field 'agg_is_shown_at', extract_xml("srw:records/srw:record/srw:extractRecordData/link", NS)
to_field 'agg_preview', extract_xml("srw:records/srw:record/srw:extractRecordData/thumbnail", NS)




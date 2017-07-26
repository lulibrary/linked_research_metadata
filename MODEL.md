# Data Model
Version 0.2.0

## Prefixes
Prefix | URI
--- | ---
dcterms: | http://purl.org/dc/terms/
foaf: | http://xmlns.com/foaf/0.1/
mads: | http://www.loc.gov/mads/rdf/v1#
owl: | http://www.w3.org/2002/07/owl#
premis: | http://www.loc.gov/premis/rdf/v1#
rdf: | http://www.w3.org/1999/02/22-rdf-syntax-ns#
swpo: | http://sw-portal.deri.org/ontologies/swportal#
vivo: | http://vivoweb.org/ontology/core#
xsd: | http://www.w3.org/2001/XMLSchema#

## Resources

### Dataset
Property | Value | Cardinality
--- | --- | ---
dcterms:available | xsd:date | 1
dcterms:created | xsd:date | 1
dcterms:creator | Person URI | 1..n
dcterms:contributor | Person URI | 0..n
dcterms:description | Literal (String) | 0..1
dcterms:hasPart | File URI | 0..n
dcterms:identifier | DOI URI | 0..1
dcterms:relation | Dataset, Publication URI | 0..n
dcterms:spatial | Literal (String) | 0..n
dcterms:subject | Literal (String) | 0..n
dcterms:temporal | Literal (String). RKMS‐ISO8601 form. | 0..1
dcterms:title | Literal (String) | 1
rdf:type | vivo:Dataset | 1

### File
Property | Value | Cardinality
--- | --- | ---
dcterms:extent | Literal (Integer) | 1
dcterms:format | Literal (String) | 1
dcterms:license | URI | 0..1
dcterms:title | Literal (String) | 1
rdf:type | premis:File | 1

### Organisation
Property | Value | Cardinality
--- | --- | ---
dcterms:title | Literal (String) | 1
rdf:type | foaf:Organization | 1

### Person
Property | Value | Cardinality
--- | --- | ---
foaf:name | Literal (String) | 1
mads:hasAffiliation | Organisation URI | 0..n
rdf:type | foaf:Person | 1
vivo:OrcidId | URI | 0..1

### Project
Property | Value | Cardinality
--- | --- | ---
dcterms:title | Literal (String) | 1
foaf:homepage | URI | 0..1
rdf:type | vivo:Project | 1
vivo:PrincipalInvestigatorRole | Literal (String) | 0..1
vivo:CoPrincipalInvestigatorRole | Literal (String) | 0..n

### Publication
Property | Value | Cardinality
--- | --- | ---
dcterms:title | Literal (String) | 1
rdf:type | swpo:Publication | 1
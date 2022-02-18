library(SPARQL)
library(RCurl)
library(XML)
library(ggmap)
#install.packages(c("SPARQL", "XML", "RCurl"))

endpoint <- "http://bag.basisregistraties.overheid.nl/sparql/"

# we hebben net naast het algemene SPARQL endpoint het endpoint 
# https://bag.basisregistraties.overheid.nl/sparql/now5 geintroduceerd. 


options <- NULL

sparql_prefix <- "PREFIX geo: <http://www.opengis.net/ont/geosparql#>
PREFIX bag: <http://bag.basisregistraties.overheid.nl/def/bag#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>"

query <- paste(sparql_prefix,
'SELECT * {
  ?verblijfsobject bag:hoofdadres ?hoofdadres ;
                   bag:hoofdadres/bag:postcode ?postcode;
                   bag:hoofdadres/bag:huisnummer ?huisnummer;
      				OPTIONAL{?verblijfsobject bag:hoofdadres/bag:huisletter ?huisletter.}.
  ?verblijfsobject	bag:hoofdadres/bag:bijbehorendeOpenbareRuimte/bag:bijbehorendeWoonplaats/bag:naamWoonplaats "Werkendam" ;
                   bag:pandrelatering ?pand ;
  					bag:identificatiecode ?bagid.
  ?pand bag:oorspronkelijkBouwjaar ?wktLabel ;
        bag:geometriePand/geo:asWKT ?wkt .
 
} 
order by asc(?wktLabel)
  ')

res <- SPARQL(endpoint,query)$res

res



d <- SPARQL(url="http://statistics.data.gov.uk/sparql",
            query="SELECT * WHERE { ?s ?p ?o . } LIMIT 10",
            ns=c('time','<http://www.w3.org/2006/time#>'))
is.data.frame(d$results)
head(d$results)

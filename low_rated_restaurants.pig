
business = LOAD 'business.json' using JsonLoader('business_id:chararray,name:chararray,address:chararray,city:chararray,state:chararray,postalcode:chararray,latitude:float,longitude:float,stars:float,review_count:int,is_open:int,
attributes:(GoodForKids:chararray),categories:chararray,hours:(day:chararray, hours:chararray)');




low_rated_bus = FILTER business by stars <=2.0;
low_rated_city = FILTER low_rated_bus BY city == 'Toronto';
low_rated_categ = FILTER low_rated_city BY (categories matches '.*Restaurant*.');


foreach_business = FOREACH low_rated_categ GENERATE business_id,name,city,state,country,latitude,longitude,stars,categories;

business_ordered = ORDER foreach_business BY stars ASC;


limit_business = LIMIT business_ordered 5;


DUMP limit_business;




business = LOAD 'business.json' using JsonLoader('business_id:chararray,name:chararray,address:chararray,city:chararray,state:chararray,postalcode:chararray,latitude:float,longitude:float,stars:float,review_count:int,is_open:int,
attributes:(GoodForKids:chararray),categories:chararray,hours:(day:chararray, hours:chararray)');




top_rated_bus = FILTER business by stars >=4.0;
top_rated_city = FILTER business BY city == 'Toronto';
top_rated_categ = FILTER top_rated_city BY (categories matches '.*Restaurant*.');


foreach_business = FOREACH top_rated_categ GENERATE business_id,name,city,latitude,longitude,stars,categories;

business_ordered = ORDER foreach_business BY stars DESC;

limit_business = LIMIT business_ordered 5;


DUMP limit_business;

STORE limit_business into 'test' using PigStorage(',');

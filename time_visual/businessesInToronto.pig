--LOADING USER.JSON, REVIEW.JSON, BUSINESS.JSON FILES INTO PIG                                                                                                                                                                                                                                                                                                                                                                                                                            users = LOAD 'user.json' using JsonLoader('user_id:chararray,name:chararray,review_count:int,yelping_since:chararray,friends:(friends_id:chararray),useful:int,funny:int,cool:chararray,fans:chararray,elite:(user_elite:int),average_stars:chararray,compliment_hot:int,compliment_more:int,compliment_profile:int,compliment_cute:int,compliment_list:int,compliment_note:int,compliment_plain:int,compliment_cool:int,compliment_funny:int,compliment_writer:int,compliment_photos:int');                                                                                                                                                                                                                                           
review = LOAD 'review.json' using JsonLoader('review_id:chararray,user_id:chararray,business_id:chararray,stars:chararray,cool:chararray,funny:chararray,useful:chararray,text:chararray,date:chararray');

business = LOAD 'business.json' using JsonLoader('business_id:chararray,name:chararray,address:chararray,city:chararray,state:chararray,postalcode:chararray,latitude:float,longitude:float,stars:float,review_count:int,is_open:int,
attributes:(GoodForKids:chararray),categories:chararray,hours:(day:chararray, hours:chararray)');

-- FILTERING RESTAURANTS IN THE CITY OF TORONTO

filter_toronto = FILTER business BY city == 'Toronto';
filter_categ = FILTER filter_toronto BY (categories matches '.*Restaurant*.');

--SELECTING ONLY THE FIELDS THAT ARE NEEDED FORM THE BUSINESS RELATION

foreach_business = FOREACH filter_categ GENERATE business_id,name,city,state,latitude,longitude;

--RELATION TO JUST HAVE THE USER ID AND NAME OF A USER FROM THE USERS RELATION

foreach_user = FOREACH users GENERATE user_id, name;


--RELATION TO JUST HAVE THE USER ID, BUSINESS ID, STARS RATED, TEXT OF REVIEW, DATE OF REVIEW FOR A REVIEW FROM THE REVIEWS RELATION

foreach_review = FOREACH review GENERATE user_id, business_id, stars, date;


--COMBINING BOTH ABOVE RELATIONS TO HAVE A USER NAME ASSOCIATED TO A REVIEW

user_reviews = JOIN foreach_user BY user_id, foreach_review BY user_id;


--ELIMINATING REDUNDANT INFORMATION FROM PREVIOUS RELATION

fr_user_reviews = FOREACH user_reviews GENERATE foreach_user::name,
foreach_review::business_id, foreach_review::stars, foreach_review::date;

--FR_USER_REVIEWS AND FOREACH_BUSINESS WILL BE THE RELATIONS THAT ARE JOINED

businesses_reviews = JOIN foreach_business BY business_id, fr_user_reviews BY business_id;


--ELIMINATING UNNECCESARY FIELDS FROM FINAL RELATION

toronto_busrev = FOREACH businesses_reviews GENERATE foreach_business::name, foreach_business::city, foreach_business::state,
foreach_business::latitude, foreach_business::longitude, fr_user_reviews::foreach_user::name, fr_user_reviews::foreach_review::stars, fr_user_reviews::foreach_review::date;


STORE toronto_busrev into 'restaurantsTorontoReviewTime' using PigStorage(',');
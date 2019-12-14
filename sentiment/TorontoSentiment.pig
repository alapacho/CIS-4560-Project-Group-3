--LOADING USER.JSON, REVIEW.JSON, BUSINESS.JSON FILES INTO PIG                                                       
users = LOAD 'user.json' using JsonLoader('user_id:chararray,user_name:chararray,review_count:int,yelping_since:chararray,friends:(friends_id:chararray),useful:int,funny:int,cool:chararray,fans:chararray,elite:(user_elite:int),average_stars:chararray,compliment_hot:int,compliment_more:int,compliment_profile:int,compliment_cute:int,compliment_list:int,compliment_note:int,compliment_plain:int,compliment_cool:int,compliment_funny:int,compliment_writer:int,compliment_photos:int');                                                                                                                                                                                                                                           
review = LOAD 'review.json' using JsonLoader('review_id:chararray,user_id:chararray,business_id:chararray,stars:chararray,cool:chararray,funny:chararray,useful:chararray,text:chararray,date:chararray');

lowfive = LOAD 'lowfive.csv' using PigStorage(',') AS (business_id:chararray,bus_name:chararray,city:chararray,latitude:float,longitude:float,stars:float);

-- LOADING AFINN WORD DICTIONARY FOR 
dictionary = load 'AFINN.txt' using PigStorage('\t') AS(word:chararray,rating:int);



--SELECTING ONLY THE FIELDS THAT ARE NEEDED FORM THE LOWFIVE RELATION

foreach_business = FOREACH lowfive GENERATE business_id,bus_name;

--RELATION TO JUST HAVE THE USER ID AND NAME OF A USER FROM THE USERS RELATION

foreach_user = FOREACH users GENERATE user_id, user_name;


--RELATION TO JUST HAVE THE USER ID, BUSINESS ID, TEXT OF REVIEW, DATE OF REVIEW FOR A REVIEW FROM THE REVIEWS RELATION

foreach_review = FOREACH review GENERATE user_id, business_id, text, date;


--COMBINING BOTH ABOVE RELATIONS(USERS/REVIEW) TO HAVE A USER NAME ASSOCIATED TO A REVIEW

user_reviews = JOIN foreach_user BY user_id, foreach_review BY user_id;


--ELIMINATING REDUNDANT INFORMATION FROM PREVIOUS RELATION

fr_user_reviews = FOREACH user_reviews GENERATE foreach_user::user_name,
foreach_review::business_id, foreach_review::text, foreach_review::date;

--FR_USER_REVIEWS AND FOREACH_BUSINESS WILL BE THE RELATIONS THAT ARE JOINED

businesses_reviews = JOIN fr_user_reviews BY business_id, foreach_business BY business_id;


--ELIMINATING UNNECCESARY FIELDS FROM FINAL RELATION

toronto_busrev = FOREACH businesses_reviews GENERATE 
    foreach_business::bus_name as bus_name,  
    fr_user_reviews::foreach_user::user_name as user_name , 
    fr_user_reviews::foreach_review::text as text,
    FLATTEN(TOKENIZE(fr_user_reviews::foreach_review::text)) AS word, 
    fr_user_reviews::foreach_review::date as date;

word_rating = JOIN toronto_busrev BY word left outer, dictionary BY word using 'replicated';

word_rating_filter = FILTER word_rating BY dictionary::rating <0;

low_rated_words = FOREACH word_rating_filter GENERATE toronto_busrev::bus_name, dictionary::word, dictionary::rating;

STORE low_rated_words into 'lowRatedWords' using PigStorage (',');

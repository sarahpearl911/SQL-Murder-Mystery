--I lost my crime scene report, so I need to look that up to get started. 

SELECT *
FROM crime_scene_report
WHERE date = 20180115 AND type = "murder" AND city = "SQL City"

--This query returns one entry with crime scene details stating- Security footage shows that there were 2 witnesses. The first witness lives at the last house on "Northwestern Dr". The second witness, named Annabel, lives somewhere on "Franklin Ave".

--To find the first witness, I ran this query

SELECT *
FROM person
WHERE address_street_name = "Northwestern Dr"
ORDER BY address_number DESC

--It looks like the person who lives in the last house on Northwestern Dr is named Morty Schapiro! We can use his ID number, 14887, to pull a transcript of his interview.

SELECT * 
FROM interview
WHERE person_id = 14887

--Morty was able to provide some great information in his interview! He said, “I heard a gunshot and then saw a man run out. He had a "Get Fit Now Gym" bag. The membership number on the bag started with "48Z". Only gold members have those bags. The man got into a car with a plate that included "H42W".”

--Now before we move too far forward, I want to find the second witness and see what they had to say in their interview too. 



SELECT * 
FROM person
WHERE name LIKE "Annabel _%" AND address_street_name = "Franklin Ave"

--From this query, it looks like the name of the second witness is Annabel Miller and her ID number is 16371. Now let’s see what she said in her interview! 

SELECT * 
FROM interview
WHERE person_id = 16371

--Annabel said, “I saw the murder happen, and I recognized the killer from my gym when I was working out last week on January the 9th.”

--So at this point we’ve got a couple of trails to follow. We know that the killer was at Annabel’s gym at the same time she was on January 9. Morty let us know part of the killer’s gym membership number, part of their license plate number, the fact that they have a gold membership with the gym, and that they are male.

--With the partial license plate information from Morty, I ran this query to get more information about whoever is male and has a license plate containing the characters Morty remembered.

SELECT person.name,
	   person.id
FROM drivers_license JOIN person ON drivers_license.id = person.license_id
WHERE drivers_license.plate_number LIKE "%H42W%" 
	  AND drivers_license.gender = "male"


--This query was very helpful because it only returned two people! We have Tushar Chandra whose ID number in the “person” table is 51739 and Jeremy Bowers whose ID number in the “person” table is 67318. Now we just need to find out which of these people matches up with the other information we were given from our witnesses. Using the IDs in the “person” table, let’s do another join to get information about their gym memberships.

SELECT get_fit_now_member.name,
	   get_fit_now_member.membership_status,
	   get_fit_now_member.id
FROM get_fit_now_member JOIN person 
	 ON get_fit_now_member.person_id = person.id
WHERE person.id = 51739 OR person.id = 67318

--This query only returned one person- Jeremy Bowers. So it looks like we have our culprit! I do still want to cross check the additional information the witnesses gave, just to be on the safe side. The above query also let me know that Jeremy has a gold gym membership and that his gym membership number is 48Z55, which matches what Morty told us about the person he saw. Now let’s check and see if Jeremy was at the gym while Annabel was on January 9.
SELECT member.name,
	   check_in.check_in_date,
	   check_in.check_in_time,
	   check_in.check_out_time
FROM get_fit_now_member AS member JOIN get_fit_now_check_in AS check_in
	 ON member.id = check_in.membership_id
WHERE member.person_id = 16371 OR member.id = "48Z55"
	  AND check_in.check_in_date = 20180109

--This query matched exactly with what Annabel said in her interview. It shows that on January 9 Jeremy checked in at the gym at 1530, while Annabel checked in at 1600. They both checked out at 1700. I feel very confident in saying that we have found the the murderer!

--Checking the suspect in the solution table returns this message - “Congrats, you found the murderer! But wait, there's more... If you think you're up for a challenge, try querying the interview transcript of the murderer to find the real villain behind this crime. If you feel especially confident in your SQL skills, try to complete this final step with no more than 2 queries. Use this same INSERT statement with your new suspect to check your answer.”

--Let’s see what Jeremy said in his interview!

SELECT person.name,
	   interview.person_id,
	   interview.transcript
FROM person JOIN interview ON person.id = interview.person_id
WHERE person.name = "Jeremy Bowers"

--Here’s what Jeremy had to say- “I was hired by a woman with a lot of money. I don't know her name but I know she's around 5'5" (65") or 5'7" (67"). She has red hair and she drives a Tesla Model S. I know that she attended the SQL Symphony Concert 3 times in December 2017.”

--So it sounds like he is a hired killer and we now need to find the person who hired him! Let’s use the information Jeremy provided to see who matches that physical description and drives a Tesla Model S.

SELECT *
FROM drivers_license
WHERE car_make = "Tesla" AND car_model = "Model S" AND hair_color = "red"
	  AND height BETWEEN 65 AND 67

--This query returned three possible suspects. Their ID numbers are 202298, 291182, and 918773. Now I’m going to use those ID numbers to get their names, check their incomes, and see who attended the concert three times in December 2017.




SELECT person.name,
	   income.annual_income,
	   event.date
FROM person JOIN facebook_event_checkin AS event
	 ON person.id = event.person_id
	 JOIN income ON person.ssn = income.ssn
WHERE event.event_name = "SQL Symphony Concert" 
	  AND event.date LIKE "201712%"
	  AND person.license_id = 202298 
	  OR person.license_id = 291182
	  OR person.license_id = 918773

--This query returned one person, Miranda Priestly! Her annual income is 310000, which is incredibly high, and she also attended the concert three times during December 2017. I have also checked her name in the solution table and it looks like I found the person who hired Jeremy! Yay mystery solved!

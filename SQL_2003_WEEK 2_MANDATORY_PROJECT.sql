use ig_clone;
show tables;

/*--------------------------------------------------------------------------------------------------------------------------------------------------------------*/
#		PROBLEM 1. Create an ER diagram or draw a schema for the given database.
-- CLICK DATABASE -> REVERSE ENGINEER.. 

/*--------------------------------------------------------------------------------------------------------------------------------------------------------------*/
#		PROBLEM 2. We want to reward the user who has been around the longest, Find the 5 oldest users.
select * from users;
select *, datediff(curdate(), created_at) as Duration_in_Days from users order by created_at limit 5;

/*--------------------------------------------------------------------------------------------------------------------------------------------------------------*/
#		PROBLEM 3. To understand when to run the ad campaign, figure out the day of the week most users register on? 
select * from users;
select dayname(created_at) as WEEKDAY, count(*) as Total_Registrations from users 
group by WEEKDAY order by Total_Registrations desc;

select dayname(created_at) as WEEKDAY, count(*) as Total_Registrations from users
group by weekday having count(*) = (
select distinct(count(*)) as Total_Registrations from users 
group by dayname(created_at) order by Total_Registrations desc limit 1)
order by weekday;

/*--------------------------------------------------------------------------------------------------------------------------------------------------------------*/
#		PROBLEM 4. To target inactive users in an email ad campaign, find the users who have never posted a photo.
select * from photos;

-- Approach 1
select user_id from photos;
select * from users  where id not in(select user_id from photos);

-- Approach 2
select u.id, u.username, u.created_at from users u left join photos p on u.id= p.user_id where p.user_id is null;

/*--------------------------------------------------------------------------------------------------------------------------------------------------------------*/
#		PROBLEM 5. Suppose you are running a contest to find out who got the most likes on a photo. Find out who won?
select * from photos;
select * from users;
select * from likes;

select user_id, count(*) as Total_Photos_Uploaded from photos group by user_id order by Total_Photos_Uploaded desc; -- PHOTOS UPLOADED PER USER

select photo_id, count(*) as total_likes from likes group by photo_id order by total_likes desc; 					-- MOST LIKES ON A PHOTO

select u.id as User_ID, u.username, p.id as Photo_ID, p.Image_URL, count(*) as Total_likes from users u        		-- ANSWER
join photos p on u.id = p.user_id
join likes l on l.photo_id=p.id
group by p.id order by total_likes desc limit 1;

/*--------------------------------------------------------------------------------------------------------------------------------------------------------------*/
#		PROBLEM 6. The investors want to know how many times does the average user post
select count(*) from users;
select count(*) from photos;

select ((select COUNT(*) from photos)/(select COUNT(*) from users)) as Average_user_post;

/*--------------------------------------------------------------------------------------------------------------------------------------------------------------*/
#		PROBLEM 7. A brand wants to know which hashtag to use on a post, and find the top 5 most used hashtags.
select * from photo_tags;
select * from tags;

select pt.tag_id, t.tag_name, count(*) Total from photo_tags pt
join tags t on pt.tag_id=t.id group by pt.tag_id order by pt.tag_id desc limit 5;

/*--------------------------------------------------------------------------------------------------------------------------------------------------------------*/
#		PROBLEM 8. To find out if there are bots, find users who have liked every single photo on the site.
select * from photos;
select * from users;
select * from likes;
select count(*) from photos;

select user_id, username, count(*) Likes from likes l 
join users u on l.user_id = u.id group by id having likes = (select count(*) from photos);

/*--------------------------------------------------------------------------------------------------------------------------------------------------------------*/
# 		PROBLEM 9. To know who the celebrities are, find users who have never commented on a photo.
select * from comments;
select * from users;

-- Appraoch 1 (USING SUBQUERIES)
select user_id from comments;
select id, username from users where id not in (select user_id from comments) order by id;

-- Approach 2 (USING JOINS)
select users.id, username from users left join comments on users.id=comments.user_id where user_id is null group by id;

/*--------------------------------------------------------------------------------------------------------------------------------------------------------------*/
# 		PROBLEM 10. Now it's time to find both of them together, find the users who have never commented on any photo or have commented on every photo.
select * from comments;
select * from users;

-- Approach 1 (USING SUBQUERIES)
select id, username, 'Never commented' as Remarks from users where id not in (select user_id from comments) 	-- USERS WHO NEVER COMMENTED ON ANY PHOTO
UNION ALL
select id, username, 'Always commented' as Remarks from users where id in 
(select user_id from comments group by user_id having count(*) = (select count(*) from photos));			-- USERS WHO COMMENTED ON EVERY PHOTO

-- Approach 2 (USING JOINS)                                                                   
select u.id, username, count(*)=0 as Total_Comments from users u left join comments c on u.id=c.user_id 
where c.user_id is null group by u.id                                                                			-- USERS WHO NEVER COMMENTED ON ANY PHOTO
UNION ALL
select user_id, username, count(*) as Total_comments from comments c											-- USERS WHO COMMENTED ON EVERY PHOTO
join users u on c.user_id=u.id																	 
group by user_id having total_comments =(select count(*) from photos)								     	
order by Total_comments desc;


select * from(
SELECT username,comment_text, row_number() over(order by username) as rn FROM users
LEFT JOIN comments ON users.id = comments.user_id
GROUP BY users.id HAVING comment_text IS NULL) as tableA
RIGHT JOIN 
(SELECT username,comment_text, row_number() over(order by username) as rn FROM users
LEFT JOIN comments ON users.id = comments.user_id
GROUP BY users.id HAVING comment_text IS NOT NULL) as t1
ON tableA.rn = t1.rn;



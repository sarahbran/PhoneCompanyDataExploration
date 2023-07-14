CREATE SCHEMA phone_co;

USE phone_co;
CREATE TABLE users (
  id INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  username VARCHAR(45) NOT NULL,
  password_hash VARCHAR(32) NOT NULL,
  email VARCHAR(100) NOT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb3;

CREATE TABLE user_phones (
  id INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id INT(10) UNSIGNED NOT NULL,
  number VARCHAR(10) NOT NULL,
  model VARCHAR(45) NOT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

CREATE TABLE phone_calls (
  id int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  phone_id int(10) UNSIGNED NOT NULL, 
  call_timestamp TIMESTAMP NOT NULL,
  send_number VARCHAR(10) NOT NULL,
  receive_number VARCHAR(10) NOT NULL,
  call_length INT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

INSERT INTO users (username, password_hash, email) VALUES 
('diskhead', md5('pass1234'), 'nick.mould@gmail.com'),
('megatron', md5('pass'), 'mega@gmail.com'), 
('manbearpig', md5('oneandahalf'), 'algore@gmail.com');

SELECT *
FROM users;

INSERT INTO user_phones (user_id, number, model) VALUES 
('1', '4054885252', 'S3'), 
('1', '4054885253', 'S5'), 
('2', '4054885255', 'S7');

SELECT *
FROM user_phones;

-- INNER JOIN
SELECT users.username, user_phones.number
FROM users
INNER JOIN user_phones ON users.id = user_phones.user_id;

-- LEFT JOIN
SELECT users.username, user_phones.number
FROM users
LEFT JOIN user_phones ON users.id = user_phones.user_id;

INSERT INTO phone_calls (phone_id, call_timestamp, send_number, receive_number, call_length)
VALUES
(1, DATE_SUB(NOW(), INTERVAL 5 MINUTE), '4054885252', '911', 1),
(1, DATE_SUB(NOW(), INTERVAL 4 HOUR), '4054885252', '911', 1),
(1, DATE_SUB(NOW(), INTERVAL 5 MINUTE), '4054885252', '911', 1),
(1, DATE_SUB(NOW(), INTERVAL 4 HOUR), '4054885252', '911', 1),
(3, DATE_SUB(NOW(), INTERVAL 5 MINUTE), '4054885252', '911', 1),
(3, DATE_SUB(NOW(), INTERVAL 4 HOUR), '4054885252', '911', 1);

SELECT *
FROM phone_calls;

-- Perform a complex query to retrieve all of the phone calls made by a particular user: diskhead
SELECT *
FROM phone_calls
INNER JOIN user_phones ON phone_calls.phone_id = user_phones.user_id
INNER JOIN users ON user_phones.user_id = users.id
WHERE username = 'diskhead';

-- Query for the number of phone calls made by a particular user: diskhead
SELECT COUNT(*)
FROM phone_calls
INNER JOIN user_phones ON phone_calls.phone_id = user_phones.id
INNER JOIN users ON user_phones.user_id = users.id
WHERE username = 'diskhead';

-- Query for the number of phone calls made by each user:
SELECT users.username, COUNT(phone_calls.id)
FROM phone_calls
INNER JOIN user_phones ON phone_calls.phone_id = user_phones.id
INNER JOIN users ON user_phones.user_id = users.id
GROUP BY users.username;

 -- Query for the number of phone calls made by each user, then sorty by username:
SELECT users.username, COUNT(phone_calls.id) AS num_phone_calls
FROM phone_calls
INNER JOIN user_phones ON user_phones.id = phone_calls.phone_id
INNER JOIN users ON user_phones.user_id = users.id
GROUP BY users.username
ORDER BY users.username ASC;







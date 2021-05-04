/*
Lane Young
*/

DROP TABLE current_loan;
DROP TABLE history; 
DROP TABLE book;
DROP TABLE member;
Drop VIEW readers_of_MarkTwain;

PROMPT Question 1

-- primary key bookID
CREATE TABLE book (
	bookID int not null,
	ISBN int,
	title varchar(100),
	author varchar(40),
	publish_year varchar(12), 
	category varchar(15),
	PRIMARY KEY (bookID));
	
-- primary key memberID
CREATE TABLE member (
	memberID int not null,
	lastname varchar(20),
	firstname varchar(20),
	address varchar(40),
	phone_number varchar(15),
	limit int,
	PRIMARY KEY (memberID));

-- primary key memberID, bookID
CREATE TABLE current_loan (
	memberID int not null,
	bookID int not null,
	loan_date varchar(12),
	due_date varchar(12),
	PRIMARY KEY (memberID, bookID),
	FOREIGN KEY (memberID) references member,
	FOREIGN KEY (bookID) references book);

-- primary key memberID, bookID, loan_date
CREATE TABLE history (
	memberID int not null,
	bookID int not null,
	loan_date varchar(12) not null,
	return_date varchar(12),
	PRIMARY KEY (memberID, bookID, loan_date),
	FOREIGN KEY(memberID) references member,
	FOREIGN KEY(bookID) references book);

PROMPT Question 2
-- Insert 5 members 
INSERT INTO member values (1, 'Young', 'Lane', '353 Whitebark Ln', '919-995-5777', 10);
INSERT INTO member values (2, 'Young', 'John', '929 Open Field Dr', '305-215-8682', 16);
INSERT INTO member values (3, 'Argenbright', 'David', '2804 Stantonsburg Rd', '252-714-0551', 15);
INSERT INTO member values (4, 'Lancaster', 'Jordan', '252 Winterville Rd', '252-714-3209', 7);
INSERT INTO member values (5, 'Mathis', 'Mitchell', '3323 Allen Rd', '828-896-6254', 18);

-- Insert 10 books, 2 of the same book info
INSERT INTO book values (1, 2252252251850, 'Bench Press', 'Layne Young', '2018-04-22', 'Scifi');
INSERT INTO book values (2, 2252252251850, 'Bench Press', 'Layne Young', '2018-04-22', 'Scifi');
INSERT INTO book values (3, 2052052051350, 'Adventures of Tom Sawyer', 'Mark Twain', '1962-04-21', 'Fiction');
INSERT INTO book values (4, 3153153153150, 'Database Oracle', 'Herchal Pickels', '1927-05-14', 'Scifi');
INSERT INTO book values (5, 1851851851850, 'Learning Basic in 21 Days', 'Johnny Apple', '1995-06-23', 'Fiction');
INSERT INTO book values (6, 1751751751750, 'Database System Concepts', 'Corey Lueda', '1994-04-21', 'Scifi');
INSERT INTO book values (7, 3003003003000, 'Database Design', 'Bryan Stew', '2003-08-10', 'Nonfiction');
INSERT INTO book values (8, 4104104104100, 'Mat Fraser', 'Mat Fraser', '2020-08-30', 'Biography');
INSERT INTO book values (9, 3053053053555, 'Oracle Space Database', 'Aliens', '2303-06-26', 'Fiction');
INSERT INTO book values (10, 3053053053055, 'Database Management Systems', 'Kelly Ann Young', '1968-02-04', 'Nonfiction');

-- Insert 7 current_loan with one member with 5+ books
INSERT INTO current_loan values (1, 1, '2020-08-30', '2020-08-31');
INSERT INTO current_loan values (1, 2, '2020-08-30', '2020-08-31');
INSERT INTO current_loan values (1, 3, '2020-08-30', '2020-08-31');
INSERT INTO current_loan values (1, 4, '2020-08-30', '2020-08-31');
INSERT INTO current_loan values (1, 9, '2020-08-30', '2020-09-02');
INSERT INTO current_loan values (1, 6, '2020-08-28', '2020-08-31');
--INSERT INTO current_loan values (1, 7, '2020-08-30', '2020-09-02');
INSERT INTO current_loan values (4, 10, '2020-08-21', '2020-09-21');

PROMPT history insertion

-- Insert 5 history for comparison with current_loan 
INSERT INTO history values (2, 2, '2020-07-04', '2020-07-05');
INSERT INTO history values (2, 3, '2020-06-02', '2020-06-03');
INSERT INTO history values (3, 5, '2020-05-06', '2020-06-05');
INSERT INTO history values (5, 6, '2020-04-21', '2020-04-22');
INSERT INTO history values (5, 7, '2020-04-22', '2020-04-23');
INSERT INTO history values (5, 1, '2020-02-05', '2020-02-06');

commit;

PROMPT Question 3

-- selects a book with Database and Oracle in the title in any order they appear

SELECT bookID, title, author, publish_year
FROM book
WHERE title like '%Oracle%Database%' or title like '%Database%Oracle%'
ORDER BY publish_year desc;

PROMPT Question 4

-- selects the member that currently has 'Database Management Systems'

SELECT member.memberID, firstname, lastname
FROM book, member, current_loan
WHERE book.bookID = current_loan.bookID and member.memberID = current_loan.memberID and title = 'Database Management Systems';

PROMPT Question 5

-- selects the book that is not currently loaned or been loaned before in history

SELECT bookID, title 
FROM book
MINUS 
SELECT current_loan.bookID, title 
FROM current_loan, book
WHERE book.bookID = current_loan.bookID
MINUS 
SELECT history.bookID, title 
FROM history, book
WHERE book.bookID = history.bookID;

PROMPT Question 6

-- counts the number copies of books

SELECT count(ISBN), title
FROM book
GROUP BY title, ISBN;

PROMPT Question 7

-- selects the member or members that currently have more than 5 books currently loaned.

SELECT member.memberID, lastname, firstname
FROM member, current_loan
WHERE member.memberID = current_loan.memberID
GROUP BY member.memberID, lastname, firstname
HAVING count(distinct bookID) > 5;

PROMPT Homework 2 Question 1

-- creates a view of all the members who have borrowed Mark Twain's books currently or in the bast 

CREATE VIEW readers_of_MarkTwain as
SELECT member.memberID, lastname, firstname, title
FROM current_loan, member, book
WHERE member.memberID = current_loan.memberID and book.bookID = current_loan.bookID and author = 'Mark Twain'
UNION
SELECT member.memberID, lastname, firstname, title
FROM member, history, book
WHERE member.memberID = history.memberID and book.bookID = history.bookID and author = 'Mark Twain';


PROMPT Question 2

-- selects the lastname and firstname of members who have borrowed Mark Twain's book currently or in the past with "Adventures" in the title

SELECT lastname, firstname
FROM readers_of_MarkTwain
WHERE title like '%Adventures%';

PROMPT Question 3

-- delete books with the title "Learning Basic in 21 Days" from all relevant records. Deleting in the right order.

DELETE FROM current_loan WHERE bookID IN (SELECT bookID FROM book WHERE title = 'Learning Basic in 21 Days');
DELETE FROM history WHERE bookID IN (SELECT bookID FROM book WHERE title = 'Learning Basic in 21 Days');
DELETE FROM book WHERE title = 'Learning Basic in 21 Days';

PROMPT Question 4

-- increases the limit by 5 for all members but the max limit cannot exceed 20. Displays the limit before and after update.

SELECT memberID, limit
FROM member;

UPDATE member set limit = limit + 5;
UPDATE member set limit = 20 where limit > 20;

SELECT memberID, limit
FROM member;

PROMPT Question 5

-- selects the bookID, title, author, and publish_year of book that has the oldest publish_year

SELECT bookID, title, author, publish_year
FROM book
WHERE publish_year = (SELECT min(publish_year) FROM book); 

PROMPT Question 6

-- select the member who have borrowed both books titled 'Database System Concepts' and 'Database Design' currently or in the past.

SELECT member.memberID, lastname, firstname
FROM book, member, current_loan
WHERE title = 'Database System Concepts' AND (book.bookID = current_loan.bookID AND member.memberID = current_loan.memberID)
UNION
SELECT member.memberID, lastname, firstname
FROM book, member, history 
WHERE title = 'Database System Concepts' AND (book.bookID = history.bookID AND member.memberID = history.memberID)
INTERSECT
SELECT member.memberID, lastname, firstname
FROM book, member, current_loan
WHERE title = 'Database Design' AND (book.bookID = current_loan.bookID and member.memberID = current_loan.memberID)
UNION
SELECT member.memberID, lastname, firstname
FROM book, member, history
WHERE title = 'Database Design' AND (book.bookID = history.bookID and member.memberID = history.memberID);

PROMPT Question 7

-- selects memberID, lastname, firstname of the member who is currently borrowing the highest number of books.

SELECT member.memberID, lastname, firstname
FROM member, current_loan
WHERE member.memberID = current_loan.memberID
GROUP BY member.memberID, lastname, firstname
HAVING count(*) >= all (SELECT COUNT(distinct memberID) FROM current_loan);

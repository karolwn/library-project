-- MySQL dump 10.13  Distrib 8.0.22, for Win64 (x86_64)
--
-- Host: localhost    Database: g15
-- ------------------------------------------------------
-- Server version	8.0.21

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Dumping events for database 'g15'
--

--
-- Dumping routines for database 'g15'
--
/*!50003 DROP FUNCTION IF EXISTS `cash_penalty` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`g15`@`localhost` FUNCTION `cash_penalty`(
user_login VARCHAR(255)
) RETURNS decimal(10,2)
    DETERMINISTIC
BEGIN
    declare done int default false;
    declare penalty DECIMAL(10,2);
    declare fetched_date date;
    declare cur1 cursor for select b.end_time from borrowed b where b.user_id in (select u.id from users u where u.login = user_login);
    declare continue handler for not found set done = true;
    set penalty = 0;
    
    open cur1;
    
    read_loop: loop
        fetch cur1 into fetched_date;
        if done then
            leave read_loop;
        end if;
        if fetched_date < (SELECT DATE(NOW())) then
            set penalty = penalty + (SELECT ABS(DATEDIFF(DATE(NOW()), fetched_date))) * 0.25;
        end if;

    end loop;
    
    close cur1;
    
    return penalty;
    
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `add_new_book` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`g15`@`localhost` PROCEDURE `add_new_book`(
IN book_title VARCHAR(255),
    IN book_author VARCHAR(255),
    IN for_adults TINYINT,
    IN library_branch INT,
    IN category_names VARCHAR(512),
    IN number_of_book_instances INT
)
BEGIN
    declare new_book_id INT;
    declare number_of_categories INT;
    declare x INT;
    declare category_name_in VARCHAR(255);
    declare category_in_id INT;
    set x = 1;
    if (SELECT EXISTS(SELECT * from books WHERE title = book_title and author = book_author)) = 0 then
    
        INSERT INTO books (
            `author`,
            `for_adults`,
            `title`) 
        VALUES (
            book_author, 
            for_adults, 
            book_title);
            
        set number_of_categories = (SELECT LENGTH(category_names) - LENGTH(REPLACE(category_names, ",", ""))) + 1;
        
        set new_book_id = (SELECT LAST_INSERT_ID());
        
        while x <= number_of_categories do
            set category_name_in = (SELECT SUBSTRING_INDEX(SUBSTRING_INDEX(category_names, ',', x), ',', -1));
            set category_in_id = (SELECT id FROM categories where category_name = category_name_in);
            
            INSERT INTO category_wrapper (
                `book_id`,
                `category_id`) 
            VALUES (
                new_book_id, 
                category_in_id);
            
            set x = x + 1;
        end while;
    end if;
    
    set x = 1;
    set new_book_id = (SELECT id from books where title = book_title and author = book_author);
    while x <= number_of_book_instances do
        
        INSERT INTO book_instances (
            `book_id`, 
            `library_branch_id`) 
        VALUES (
            new_book_id, 
            library_branch);
            
        set x = x + 1;    
    end while;
    
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `calculate_cash_penalty` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`g15`@`localhost` PROCEDURE `calculate_cash_penalty`(
IN user_login VARCHAR(255)
)
BEGIN
    SELECT cash_penalty(user_login) AS "penalty in PLN";        
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `check_availability` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`g15`@`localhost` PROCEDURE `check_availability`(
IN book_title VARCHAR(255),
    IN book_author VARCHAR(255)
)
BEGIN
    SELECT
        lb.id,
        lb.library_branch_name,
        lb.address,
        count(lb.address) as "number of copies",
        group_concat(bi.id) as "book instance ids"
    FROM   library_branches lb
           INNER JOIN book_instances bi
                   ON lb.id = bi.library_branch_id
           INNER JOIN books b
                   ON bi.book_id = b.id
    WHERE  b.title = book_title
           AND b.author = book_author
           AND bi.id NOT IN (SELECT bo.book_instance_id 
                             FROM   borrowed bo)
    GROUP  BY lb.address; 
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `delete_books` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`g15`@`localhost` PROCEDURE `delete_books`(
IN input_book_id INT,
    IN operation_type VARCHAR(255)
)
BEGIN
    if operation_type = 'book' then
        DELETE FROM books b WHERE b.id = input_book_id;
    elseif operation_type = 'instance' then
        if (SELECT Count(*) FROM book_instances bi1, book_instances bi2 where bi1.book_id = bi2.book_id and bi2.id = input_book_id) > 1 then
            DELETE FROM book_instances bi WHERE bi.id = input_book_id;
        else
            DELETE FROM books b WHERE b.id IN (SELECT bi3.book_id FROM book_instances bi3 WHERE bi3.id = input_book_id);
        end if;
    end if;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_books_by_category` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`g15`@`localhost` PROCEDURE `get_books_by_category`(
IN requested_category VARCHAR(255)
)
BEGIN
    SELECT b.title,
           b.author
    FROM   books b
           INNER JOIN category_wrapper cw
                   ON b.id = cw.book_id
           INNER JOIN categories c
                   ON cw.category_id = c.id
    WHERE  c.category_name = requested_category
    ORDER  BY b.title ASC; 
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_books_filter` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`g15`@`localhost` PROCEDURE `get_books_filter`(
IN book_title VARCHAR(255),
    IN book_author VARCHAR(255),
    IN book_category VARCHAR(255)
)
BEGIN
    SELECT DISTINCT
           b.id,
           b.author,
           b.for_adults,
           b.title
    FROM   books b
           INNER JOIN category_wrapper cw
                   ON b.id = cw.book_id
           INNER JOIN categories c
                   ON cw.category_id = c.id
    WHERE  (book_title IS NULL OR b.title LIKE CONCAT('%', book_title, '%'))
        AND (book_author IS NULL OR b.author LIKE CONCAT('%', book_author, '%'))
        AND (book_category IS NULL OR c.category_name = book_category)
    ORDER  BY b.title ASC; 
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_category_of_book` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`g15`@`localhost` PROCEDURE `get_category_of_book`(
IN book_title VARCHAR(255),
    IN book_author VARCHAR(255)
)
BEGIN
    SELECT c.category_name
    FROM   categories c
    WHERE  c.id IN (SELECT cw.category_id
                    FROM   category_wrapper cw
                    WHERE  book_id = (SELECT b.id
                                      FROM   books b
                                      WHERE  b.title = book_title
                                             AND b.author = book_author)); 
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_users_books` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`g15`@`localhost` PROCEDURE `get_users_books`(
IN user_login VARCHAR(255)
)
BEGIN
    SELECT 
           bo.id,
           bo.user_id,
           bo.book_instance_id,
           b.title,
           bo.end_time,
           lb.library_branch_name,
           lb.address
    FROM   books b
           INNER JOIN book_instances bi
                   ON b.id = bi.book_id
           INNER JOIN borrowed bo
                   ON bi.id = bo.book_instance_id
           INNER JOIN library_branches lb
                   ON bi.library_branch_id = lb.id
    WHERE  bo.user_id = (SELECT u.id
                         FROM   users u
                         WHERE  u.login = user_login);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2021-01-18 17:20:48

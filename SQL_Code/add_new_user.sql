CREATE DEFINER=`buer`@`localhost` PROCEDURE `add_new_user`(u_name VARCHAR(20), pwd VARCHAR(20), email VARCHAR(50), id_role INT)
BEGIN
	INSERT INTO `Actionpeach`.`USER`(`uname`,`psw`,`email`,`Role_id`)
			VALUES(MD5(u_name),MD5(pwd),email,id_role);
END
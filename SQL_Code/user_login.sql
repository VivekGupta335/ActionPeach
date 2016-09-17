CREATE DEFINER=`buer`@`localhost` PROCEDURE `user_login`(
		IN i_name VARCHAR(20),IN i_pwd VARCHAR(20)
        )
BEGIN
	SELECT uname, psw from USER where uname = MD5(i_name) AND psw = MD5(i_pwd);
END
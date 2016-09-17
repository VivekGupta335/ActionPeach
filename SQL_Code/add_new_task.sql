CREATE PROCEDURE `add_new_task` ( t_name VARCHAR(20),desp VARCHAR(100), 
	b_time DATETIME,f_time DATETIME, n_owner VARCHAR(20),risk_id INT)
BEGIN
	INSERT INTO `Actionpeach`.`ACTION`(
    `task_name`,`Description`,`begin_time`,`finish_time`,
    `create_time`,`Owner`,`Risk_idRisk`)
	VALUES(
	t_name,desp,b_time,f_time,NOW(),
	n_owner,risk_id);
END

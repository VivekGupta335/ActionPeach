CREATE DEFINER=`buer`@`localhost` PROCEDURE `new_reg_admin`(u_name VARCHAR(20), pwd VARCHAR(20), email VARCHAR(50), id_role INT)
BEGIN
	
    CREATE TABLE `Role` (
	`idRole` int(11) NOT NULL,
	`name` varchar(45) NOT NULL,
	PRIMARY KEY (`idRole`)
	) ENGINE=InnoDB DEFAULT CHARSET=latin1;

    
    CREATE TABLE `Risk` (
	`idRisk` int(11) NOT NULL,
	`Description` varchar(100) DEFAULT NULL,
	PRIMARY KEY (`idRisk`)
	) ENGINE=InnoDB DEFAULT CHARSET=latin1;

	CREATE TABLE `ACTION` (
	`idACTION` int(11) NOT NULL AUTO_INCREMENT,
	`task_name` varchar(45) NOT NULL,
	`Description` varchar(200) NOT NULL,
	`begin_time` datetime NOT NULL,
	`finish_time` datetime NOT NULL,
	`real_finish_time` datetime DEFAULT NULL,
	`create_time` datetime NOT NULL,
	`Owner` varchar(45) DEFAULT NULL,
	`status` varchar(10) DEFAULT NULL,
	`location` varchar(45) DEFAULT NULL,
	`Risk_idRisk` int(11) NOT NULL,
	PRIMARY KEY (`idACTION`),
	KEY `fk_ACTION_Risk1_idx` (`Risk_idRisk`),
	CONSTRAINT `fk_ACTION_Risk1` FOREIGN KEY (`Risk_idRisk`) REFERENCES `Risk` (`idRisk`) ON DELETE NO ACTION ON UPDATE NO ACTION
	) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1;

    
    CREATE TABLE `USER` (
	`uname` varchar(45) NOT NULL,
	`psw` varchar(45) NOT NULL DEFAULT '1111',
	`f_name` varchar(10) DEFAULT NULL,
	`l_name` varchar(10) DEFAULT NULL,
	`email` varchar(50) NOT NULL,
	`Role_id` int(11) NOT NULL,
	PRIMARY KEY (`uname`),
	UNIQUE KEY `username_UNIQUE` (`uname`),
	UNIQUE KEY `email_UNIQUE` (`email`),
	KEY `fk_USER_Role1_idx` (`Role_id`),
	CONSTRAINT `fk_USER_Role1` FOREIGN KEY (`Role_id`) REFERENCES `Role` (`idRole`) ON DELETE NO ACTION ON UPDATE NO ACTION
	) ENGINE=InnoDB DEFAULT CHARSET=latin1;

	CREATE TABLE `Manager_user` (
	`Manager_id` varchar(45) NOT NULL,
	`user_id` varchar(45) NOT NULL,
	KEY `Manager_id_idx` (`Manager_id`),
	CONSTRAINT `fk_9769A2EF-E803-491E-BB35-46A45CAF4AE2` FOREIGN KEY (`Manager_id`) REFERENCES `USER` (`uname`) ON DELETE NO ACTION ON UPDATE NO ACTION
	) ENGINE=InnoDB DEFAULT CHARSET=latin1;

	CREATE TABLE `USER_involve_ACTION` (
	`USER_username` varchar(45) NOT NULL,
	`ACTION_idACTION` int(11) NOT NULL,
	`involve_time` datetime NOT NULL,
	PRIMARY KEY (`USER_username`,`ACTION_idACTION`),
	KEY `fk_USER_has_ACTION_ACTION1_idx` (`ACTION_idACTION`),
	KEY `fk_USER_has_ACTION_USER_idx` (`USER_username`),
	CONSTRAINT `fk_USER_has_ACTION_ACTION1` FOREIGN KEY (`ACTION_idACTION`) REFERENCES `ACTION` (`idACTION`) ON DELETE NO ACTION ON UPDATE NO ACTION,
	CONSTRAINT `fk_USER_has_ACTION_USER` FOREIGN KEY (`USER_username`) REFERENCES `USER` (`uname`) ON DELETE NO ACTION ON UPDATE NO ACTION
	) ENGINE=InnoDB DEFAULT CHARSET=latin1;

	INSERT INTO `Actionpeach`.`USER`(`uname`,`psw`,`email`,`Role_id`)
			VALUES(MD5(u_name),MD5(pwd),email,id_role);
            
	INSERT INTO `Actionpeach`.`Risk`(`idRisk`,`Description`)
    VALUES(1,'level1');
	INSERT INTO `Actionpeach`.`Risk`(`idRisk`,`Description`)
    VALUES(2,'level2');
	INSERT INTO `Actionpeach`.`Risk`(`idRisk`,`Description`)
    VALUES(3,'level3');
    
    INSERT INTO `Actionpeach`.`Role`(`idRole`,`name`)
	VALUES(1,'admin');
    INSERT INTO `Actionpeach`.`Role`(`idRole`,`name`)
	VALUES(2,'manager');
    INSERT INTO `Actionpeach`.`Role`(`idRole`,`name`)
	VALUES(3,'employee');
END
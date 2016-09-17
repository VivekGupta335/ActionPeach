CREATE TABLE `dba-wp-Company` (
  `idcompany` int(11) NOT NULL,
  `name` varchar(45) DEFAULT NULL,
  `description` varchar(45) DEFAULT NULL,
  `Headquarter` varchar(45) DEFAULT NULL,
  `CEO` varchar(45) DEFAULT NULL,
  `type` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`idcompany`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE `dba-wp-Role` (
  `idRole` int(11) NOT NULL,
  `name` varchar(45) NOT NULL,
  PRIMARY KEY (`idRole`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `dba-wp-USER` (
  `uname` varchar(45) NOT NULL,
  `psw` varchar(45) NOT NULL DEFAULT '1111',
  `f_name` varchar(10) DEFAULT NULL,
  `l_name` varchar(10) DEFAULT NULL,
  `email` varchar(50) NOT NULL,
  `Role_id` int(11) NOT NULL,
  `Company_idcompany` int(11) NOT NULL,
  PRIMARY KEY (`uname`,`Company_idcompany`),
  UNIQUE KEY `username_UNIQUE` (`uname`),
  UNIQUE KEY `email_UNIQUE` (`email`),
  KEY `fk_USER_Role1_idx` (`Role_id`),
  KEY `fk_USER_Company1_idx` (`Company_idcompany`),
  CONSTRAINT `fk_USER_Company1` FOREIGN KEY (`Company_idcompany`) REFERENCES `dba-wp-Company` (`idcompany`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_USER_Role1` FOREIGN KEY (`Role_id`) REFERENCES `dba-wp-Role` (`idRole`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE `dba-wp-Risk` (
  `idRisk` int(11) NOT NULL,
  `Description` varchar(100) DEFAULT NULL,
  `idcompany` int(11) NOT NULL,
  PRIMARY KEY (`idRisk`,`idcompany`),
  KEY `fk_Risk_Company1_idx` (`idcompany`),
  CONSTRAINT `fk_Risk_Company1` FOREIGN KEY (`idcompany`) REFERENCES `dba-wp-Company` (`idcompany`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE `dba-wp-Manager_user` (
  `Manager_id` varchar(45) NOT NULL,
  `user_id` varchar(45) NOT NULL,
  KEY `Manager_id_idx` (`Manager_id`),
  CONSTRAINT `manager_id` FOREIGN KEY (`Manager_id`) REFERENCES `dba-wp-USER` (`uname`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE `dba-wp-ACTION` (
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
  CONSTRAINT `fk_ACTION_Risk1` FOREIGN KEY (`Risk_idRisk`) REFERENCES `dba-wp-Risk` (`idRisk`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1;

CREATE TABLE `dba-wp-USER_involve_ACTION` (
  `USER_username` varchar(45) NOT NULL,
  `ACTION_idACTION` int(11) NOT NULL,
  `involve_time` datetime NOT NULL,
  PRIMARY KEY (`USER_username`,`ACTION_idACTION`),
  KEY `fk_USER_has_ACTION_ACTION1_idx` (`ACTION_idACTION`),
  KEY `fk_USER_has_ACTION_USER_idx` (`USER_username`),
  CONSTRAINT `fk_USER_has_ACTION_ACTION1` FOREIGN KEY (`ACTION_idACTION`) REFERENCES `dba-wp-ACTION` (`idACTION`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_USER_has_ACTION_USER` FOREIGN KEY (`USER_username`) REFERENCES `dba-wp-USER` (`uname`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE `dba-wp-Access_Control` (
  `id_Role` int(11) NOT NULL,
  `privileges` varchar(45) DEFAULT NULL,
  `table` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`id_Role`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

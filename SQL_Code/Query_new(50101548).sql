#Query for Org Chart
SELECT DISTINCT	id, #project_name/task_id
		name, #p_name, task name 
        ptall.parent_id #direct parent 
        FROM( # From1 begin 
        SELECT username AS id, 
			   u.name AS name, 
               '' AS progress,
               '' AS parent_id
			FROM dba_wp_v5_user u WHERE username = 'yitian'
		UNION
        SELECT DISTINCT	p.project_name AS id, #project_name/task_id
				p.project_name AS name, #p_name, task name 
				p.progress,
				p.project_manager parent_id #direct parent
        FROM dba_wp_v5_project p WHERE p.project_name IN( 
						SELECT DISTINCT child_name 
						FROM dba_wp_v5_project_closure pc WHERE parent_name = child_name) 
        UNION
        SELECT DISTINCT	p.project_name AS id, #project_name/task_id
				p.project_name AS name, #p_name, task name 
				p.progress,
				pc.parent_name parent_id #direct parent
        FROM dba_wp_v5_project p JOIN dba_wp_v5_project_closure pc ON p.project_name = pc.child_name 
						WHERE p.project_name IN( 
						SELECT DISTINCT child_name 
						FROM dba_wp_v5_project_closure pc WHERE parent_name != child_name)  AND pc.depth = 1
        UNION
		SELECT DISTINCT	t.task_id AS id, #project_name/task_id
				t.task_name AS name, #p_name, task name 
				t.progress,
				t.project_name parent_id #direct parent
        FROM dba_wp_v5_task t JOIN dba_wp_v5_task_closure tc ON t.task_id = tc.child_id
						WHERE t.task_id IN( 
						SELECT DISTINCT tc.child_id 
						FROM dba_wp_v5_task_closure tc WHERE parent_id = child_id) AND tc.depth = 0
		#######################
        UNION
		SELECT DISTINCT	t.task_id AS id, #project_name/task_id
				t.task_name AS name, #p_name, task name 
				t.progress,
				a.performer parent_id #direct parent
        FROM dba_wp_v5_task t JOIN dba_wp_v5_task_closure tc 
									ON t.task_id = tc.child_id 
										JOIN dba_wp_v5_assigned a
											ON a.task_id = t.task_id
						WHERE t.task_id IN( 
						SELECT DISTINCT tc.child_id 
						FROM dba_wp_v5_task_closure tc WHERE parent_id = child_id) AND tc.depth = 0
        #########################
        UNION
		SELECT DISTINCT	t.task_id AS id, #project_name/task_id
				t.task_name AS name, #p_name, task name 
				t.progress,
				tc.parent_id parent_id #direct parent
        FROM dba_wp_v5_task t JOIN dba_wp_v5_task_closure tc ON t.task_id = tc.child_id 
						WHERE t.task_id IN( 
						SELECT DISTINCT child_id 
						FROM dba_wp_v5_task_closure WHERE parent_id != child_id)  AND tc.depth = 1) AS ptall
        WHERE (
				(('admin' OR 'manager') IN 
					(SELECT role_name 
						FROM dba_wp_v5_access_control
						WHERE username = 'yitian')
				AND id = 'yitian' 
                OR  id IN (
                SELECT DISTINCT child_name FROM dba_wp_v5_project_closure WHERE parent_name IN (
						SELECT project_name FROM dba_wp_v5_project WHERE project_manager = 'yitian')
				AND  
                (ptall.parent_id = 'yitian' AND (id IN (SELECT project_name FROM dba_wp_v5_user_has_project WHERE username = 'yitian'))
                #######
					#AND 
                    #(SELECT parent_id FROM ptall WHERE ( id IN SELECT id FROM ptall WHERE parent_id = 'yiitan'))
                    #(id IN ( SELECT id FROM ptall WHERE parent_id = 'yiitan'))
                                                   # AND
                                                    
                                                    #(id IN(
                                                    #SELECT project_name FROM dba_wp_v5_project WHERE project_manager = 'yitian'))
				#UNION
                #SELECT parent_name FROM  dba_wp_v5_project_closure WHERE child_name IN (ptall.parent_id)
						OR ptall.parent_id IN (SELECT child_name
												FROM dba_wp_v5_project_closure 
												WHERE parent_name IN (
						SELECT project_name FROM dba_wp_v5_project WHERE project_manager = 'yitian' ))
						##AND parent_id IN
                        )


                UNION
                SELECT task_id FROM dba_wp_v5_task WHERE project_name IN (
						SELECT child_name 
							FROM dba_wp_v5_project_closure 
                            WHERE parent_name IN (SELECT project_name 
															FROM dba_wp_v5_project 
                                                            WHERE project_manager = 'yitian')
																		 ) 
					AND (
							parent_id IN (SELECT child_name FROM dba_wp_v5_project_closure 
											WHERE parent_name IN (SELECT project_name 
																				FROM dba_wp_v5_project 
                                                                                WHERE project_manager = 'yitian')
											UNION SELECT parent_id FROM dba_wp_v5_task_closure
										 ) 
                        )
                )
			OR 
			 (
                (SELECT COUNT(DISTINCT child_name) FROM dba_wp_v5_project_closure WHERE parent_name IN (
						SELECT project_name FROM dba_wp_v5_project WHERE project_manager = 'yitian')) = 0
			 AND
             id IN
					(SELECT task_id 
						FROM dba_wp_v5_assigned
						WHERE performer = 'yitian'
					)
				) AND parent_id IN ( SELECT 'yitian' UNION ( SELECT task_id 
						FROM dba_wp_v5_assigned
						WHERE performer = 'yitian' ))
)
			OR
			((('worker') IN 
					(SELECT role_name 
						FROM dba_wp_v5_access_control
						WHERE username = 'yitian'))
				AND
                ((parent_id = '' AND (id IN (SELECT project_name FROM dba_wp_v5_user_has_project WHERE username = 'yitian')))
                OR
                (id IN
					(SELECT task_id 
						FROM dba_wp_v5_assigned
						WHERE performer = 'yitian'
					)
				) AND parent_id IN ( SELECT 'yitian' UNION (SELECT task_id 
						FROM dba_wp_v5_assigned
						WHERE performer = 'yitian' ))
				)
	)
)






#Pie Chart 
#month (presented in “January”, “February”, etc.), count
SELECT DATE_FORMAT(tpu.create_time, '%M') AS month, 
	   count(tpu.task_id) AS count
		FROM
        (SELECT u.username, 
				t.create_time, 
				t.task_id, 
                a.performer 
		FROM 
		dba_wp_v5_task t, 
        dba_wp_v5_user u, 
        dba_wp_v5_assigned a
        WHERE u.username = a.username 
        AND a.task_id = t.task_id 
		union
        SELECT u.username,
			   p.begin_time, 
			   p.project_name,
               p.project_manager
        FROM 
		dba_wp_v5_user u, 
        dba_wp_v5_project p
        WHERE u.project_name = p.project_name) AS tpu JOIN dba_wp_v5_access_control ac 
        ON tpu.performer = ac.username
        WHERE
        (tpu.performer = 'yitian'AND 'worker' IN (SELECT role_name 
							FROM dba_wp_v5_access_control
                            WHERE username = 'yitian'))
        OR
        (('manager' OR 'admin') IN (SELECT role_name FROM dba_wp_v5_access_control WHERE username = 'yitian') 
			AND task_id IN ( SELECT child_name 
									FROM dba_wp_v5_project_closure 
									WHERE parent_name IN (SELECT project_name 
																FROM dba_wp_v5_project 
                                                                WHERE project_manager = 'yitian')
								UNION
								SELECT task_id 
									FROM dba_wp_v5_task 
                                    WHERE project_name IN 
									(SELECT child_name 
											FROM dba_wp_v5_project_closure 
											WHERE parent_name IN (SELECT project_name 
																		FROM dba_wp_v5_project 
                                                                        WHERE project_manager = 'yitian'))))
        GROUP BY MONTH;







#Query for Calendar chart: Manager
#
SELECT DISTINCT
		ptu.task_id AS id, 
		DATE_FORMAT(ptu.begin_time, '%Y/%m/%d %h:%i') AS begin_time,
		DATE_FORMAT(ptu.end_time, '%Y/%m/%d %h:%i') AS end_time, 
        ptu.task_name AS name, 
		description
        FROM
        (
		SELECT  a.performer,
				t.task_id, 
				t.begin_time, 
                t.end_time, 
                t.task_name, 
                t.description
        FROM 
        dba_wp_v5_user u,dba_wp_v5_assigned a, dba_wp_v5_task t
        WHERE 
        u.username = a.username AND a.task_id = t.task_id
        UNION
        SELECT  p.project_manager,
				p.project_name, 
				p.begin_time, 
                p.end_time, 
                p.project_name, 
                '' AS description
        FROM 
        dba_wp_v5_user u JOIN dba_wp_v5_project p on
        u.project_name = p.project_name) AS ptu 
				JOIN dba_wp_v5_access_control ac ON
                ptu.performer = ac.username
        WHERE (('admin' OR 'manager') IN 
				(SELECT role_name 
						FROM dba_wp_v5_access_control
						WHERE username = 'yitian')
				AND task_id IN (SELECT child_name 
										FROM dba_wp_v5_project_closure
                                        WHERE parent_name IN ( SELECT project_name 
																FROM dba_wp_v5_project 
                                                                WHERE project_manager = 'yitian'))
                OR 
				ptu.performer = 'yitian'AND 'worker' IN (SELECT role_name 
							FROM dba_wp_v5_access_control
                            WHERE username = 'yitian'))
        







#Query for Gantt chart
SELECT DISTINCT	id, #project_name/task_id
		name, #p_name, task name 
		begin_time_year,
		ptall.begin_time_month,
        ptall.begin_time_day,
        ptall.end_time_year, 
		ptall.end_time_month,
        ptall.end_time_day, 
        ptall.progress, 
        ptall.parent_id #direct parent dba_wp_v5_project
        FROM( # From1 begin 
        SELECT DISTINCT	p.project_name AS id, #project_name/task_id
				p.project_name AS name, #p_name, task name 
				DATE_FORMAT(p.begin_time, '%Y') AS begin_time_year, 
				DATE_FORMAT(p.begin_time, '%m')-1 AS begin_time_month, 
				DATE_FORMAT(p.begin_time, '%d') AS begin_time_day, 
				DATE_FORMAT(p.end_time, '%Y') AS end_time_year,  
				DATE_FORMAT(p.end_time, '%m')-1 AS end_time_month, 
				DATE_FORMAT(p.end_time, '%d') AS end_time_day, 
				p.progress,
				'' parent_id #direct parent
        FROM dba_wp_v5_project p WHERE p.project_name IN( 
						SELECT DISTINCT child_name 
						FROM dba_wp_v5_project_closure pc WHERE parent_name = child_name)
        UNION
        SELECT DISTINCT	p.project_name AS id, #project_name/task_id
				p.project_name AS name, #p_name, task name 
				DATE_FORMAT(p.begin_time, '%Y') AS begin_time_year, 
				DATE_FORMAT(p.begin_time, '%m')-1 AS begin_time_month, 
				DATE_FORMAT(p.begin_time, '%d') AS begin_time_day, 
				DATE_FORMAT(p.end_time, '%Y') AS end_time_year,  
				DATE_FORMAT(p.end_time, '%m')-1 AS end_time_month, 
				DATE_FORMAT(p.end_time, '%d') AS end_time_day, 
				p.progress,
				pc.parent_name parent_id #direct parent
        FROM dba_wp_v5_project p JOIN dba_wp_v5_project_closure pc ON p.project_name = pc.child_name 
						WHERE p.project_name IN( 
						SELECT DISTINCT child_name 
						FROM dba_wp_v5_project_closure pc WHERE parent_name != child_name)  AND pc.depth = 1
        UNION
		
        SELECT DISTINCT	t.task_id AS id, #project_name/task_id
				t.task_name AS name, #p_name, task name 
				DATE_FORMAT(t.begin_time, '%Y') AS begin_time_year, 
				DATE_FORMAT(t.begin_time, '%m')-1 AS begin_time_month, 
				DATE_FORMAT(t.begin_time, '%d') AS begin_time_day, 
				DATE_FORMAT(t.end_time, '%Y') AS end_time_year,  
				DATE_FORMAT(t.end_time, '%m')-1 AS end_time_month, 
				DATE_FORMAT(t.end_time, '%d') AS end_time_day, 
				t.progress,
				t.project_name parent_id #direct parent
        FROM dba_wp_v5_task t JOIN dba_wp_v5_task_closure tc ON t.task_id = tc.child_id
						WHERE t.task_id IN( 
						SELECT DISTINCT tc.child_id 
						FROM dba_wp_v5_task_closure tc WHERE parent_id = child_id) AND tc.depth = 0
                        
		UNION

        SELECT DISTINCT	t.task_id AS id, #project_name/task_id
				t.task_name AS name, #p_name, task name 
				DATE_FORMAT(t.begin_time, '%Y') AS begin_time_year, 
				DATE_FORMAT(t.begin_time, '%m')-1 AS begin_time_month, 
				DATE_FORMAT(t.begin_time, '%d') AS begin_time_day, 
				DATE_FORMAT(t.end_time, '%Y') AS end_time_year,  
				DATE_FORMAT(t.end_time, '%m')-1 AS end_time_month, 
				DATE_FORMAT(t.end_time, '%d') AS end_time_day, 
				t.progress,
				tc.parent_id parent_id #direct parent
        FROM dba_wp_v5_task t JOIN dba_wp_v5_task_closure tc ON t.task_id = tc.child_id 
						WHERE t.task_id IN( 
						SELECT DISTINCT child_id 
						FROM dba_wp_v5_task_closure WHERE parent_id != child_id)  AND tc.depth = 1) 
		AS ptall
        
        WHERE (
				('admin' OR 'manager') IN 
					(SELECT role_name 
						FROM dba_wp_v5_access_control
						WHERE username = 'yitian')
				AND 
                (parent_id = '' AND (id IN (SELECT project_name FROM dba_wp_v5_user_has_project WHERE username = 'yitian')))
                OR
                id IN (
                SELECT child_name FROM dba_wp_v5_project_closure WHERE parent_name IN (
						SELECT project_name FROM dba_wp_v5_project WHERE project_manager = 'yitian' )
				AND (
                         (ptall.parent_id = '' AND (id IN (SELECT project_name FROM dba_wp_v5_user_has_project WHERE username = 'yitian'))
                                                                    )
						OR ptall.parent_id IN (SELECT child_name 
												FROM dba_wp_v5_project_closure 
												WHERE parent_name IN (
						SELECT project_name FROM dba_wp_v5_project WHERE project_manager = 'yitian' )))
                UNION
                SELECT task_id FROM dba_wp_v5_task WHERE project_name IN (
						SELECT child_name 
							FROM dba_wp_v5_project_closure 
                            WHERE parent_name IN (SELECT project_name 
															FROM dba_wp_v5_project 
                                                            WHERE project_manager = 'yitian'))
                )#) Test use
                OR
                ('worker') IN 
					(SELECT role_name 
						FROM dba_wp_v5_access_control
						WHERE username = 'yitian')
				AND
                (parent_id = '' AND (id IN (SELECT project_name FROM dba_wp_v5_user_has_project WHERE username = 'yitian')))
                OR
                (id IN
					(SELECT task_id 
						FROM dba_wp_v5_assigned
						WHERE performer = 'yitian'
					)
				)
)







#Query for Gantt chart for dependency
SELECT DISTINCT	id, #project_name/task_id
		name, #p_name, task name 
		begin_time_year,
		ptall.begin_time_month,
        ptall.begin_time_day,
        ptall.end_time_year, 
		ptall.end_time_month,
        ptall.end_time_day, 
        ptall.progress, 
        ptall.parent_id, #direct parent
        ptall.pre_work
        FROM( # From1 begin 
		SELECT *
        FROM( # From1 begin 
        (SELECT DISTINCT p.project_name AS id, #project_name/task_id
				p.project_name AS name, #p_name, task name 
				DATE_FORMAT(p.begin_time, '%Y') AS begin_time_year, 
				DATE_FORMAT(p.begin_time, '%m')-1 AS begin_time_month, 
				DATE_FORMAT(p.begin_time, '%d') AS begin_time_day, 
				DATE_FORMAT(p.end_time, '%Y') AS end_time_year,  
				DATE_FORMAT(p.end_time, '%m')-1 AS end_time_month, 
				DATE_FORMAT(p.end_time, '%d') AS end_time_day, 
				p.progress,
				'' parent_id #direct parent
        FROM dba_wp_v5_project p WHERE p.project_name IN( 
						SELECT DISTINCT child_name 
						FROM dba_wp_v5_project_closure pc WHERE parent_name = child_name))
                        AS pt LEFT JOIN dba_wp_v5_dependency d 
                                        ON pt.id = d.aft_work)
        UNION
        
        SELECT *
        FROM( # From1 begin 
        (SELECT DISTINCT	p.project_name AS id, #project_name/task_id
				p.project_name AS name, #p_name, task name 
				DATE_FORMAT(p.begin_time, '%Y') AS begin_time_year, 
				DATE_FORMAT(p.begin_time, '%m')-1 AS begin_time_month, 
				DATE_FORMAT(p.begin_time, '%d') AS begin_time_day, 
				DATE_FORMAT(p.end_time, '%Y') AS end_time_year,  
				DATE_FORMAT(p.end_time, '%m')-1 AS end_time_month, 
				DATE_FORMAT(p.end_time, '%d') AS end_time_day, 
				p.progress,
				pc.parent_name parent_id #direct parent
        FROM dba_wp_v5_project p JOIN dba_wp_v5_project_closure pc ON p.project_name = pc.child_name 
						WHERE p.project_name IN( 
						SELECT DISTINCT child_name 
						FROM dba_wp_v5_project_closure pc WHERE parent_name != child_name)  AND pc.depth = 1)
                        AS pt LEFT JOIN dba_wp_v5_dependency d 
                                        ON pt.id = d.aft_work)
        UNION
		
        SELECT *
        FROM( # From1 begin 
        (SELECT DISTINCT	t.task_id AS id, #project_name/task_id
				t.task_name AS name, #p_name, task name 
				DATE_FORMAT(t.begin_time, '%Y') AS begin_time_year, 
				DATE_FORMAT(t.begin_time, '%m')-1 AS begin_time_month, 
				DATE_FORMAT(t.begin_time, '%d') AS begin_time_day, 
				DATE_FORMAT(t.end_time, '%Y') AS end_time_year,  
				DATE_FORMAT(t.end_time, '%m')-1 AS end_time_month, 
				DATE_FORMAT(t.end_time, '%d') AS end_time_day, 
				t.progress,
				t.project_name parent_id #direct parent
        FROM dba_wp_v5_task t JOIN dba_wp_v5_task_closure tc ON t.task_id = tc.child_id
						WHERE t.task_id IN( 
						SELECT DISTINCT tc.child_id 
						FROM dba_wp_v5_task_closure tc WHERE parent_id = child_id) AND tc.depth = 0)
                        AS pt LEFT JOIN dba_wp_v5_dependency d 
                                        ON pt.id = d.aft_work)
		UNION
		
        
        SELECT *
        FROM( # From1 begin 
        (SELECT DISTINCT	t.task_id AS id, #project_name/task_id
				t.task_name AS name, #p_name, task name 
				DATE_FORMAT(t.begin_time, '%Y') AS begin_time_year, 
				DATE_FORMAT(t.begin_time, '%m')-1 AS begin_time_month, 
				DATE_FORMAT(t.begin_time, '%d') AS begin_time_day, 
				DATE_FORMAT(t.end_time, '%Y') AS end_time_year,  
				DATE_FORMAT(t.end_time, '%m')-1 AS end_time_month, 
				DATE_FORMAT(t.end_time, '%d') AS end_time_day, 
				t.progress,
				tc.parent_id parent_id #direct parent
        FROM dba_wp_v5_task t JOIN dba_wp_v5_task_closure tc ON t.task_id = tc.child_id 
						WHERE t.task_id IN( 
						SELECT DISTINCT child_id 
						FROM dba_wp_v5_task_closure WHERE parent_id != child_id)  AND tc.depth = 1))
                        AS pt LEFT JOIN dba_wp_v5_dependency d 
                                        ON pt.id = d.aft_work)
                        
                        AS ptall 
        
        WHERE (
				('admin' OR 'manager') IN 
					(SELECT role_name 
						FROM dba_wp_v5_access_control
						WHERE username = 'yitian')
				AND 
                (parent_id = '' AND (id IN (SELECT project_name FROM dba_wp_v5_user_has_project WHERE username = 'yitian')))
                OR
                id IN (
                SELECT child_name FROM dba_wp_v5_project_closure WHERE parent_name IN (
						SELECT project_name FROM dba_wp_v5_project WHERE project_manager = 'yitian' )
				AND (
                         (ptall.parent_id = '' AND (id IN (SELECT project_name FROM dba_wp_v5_user_has_project WHERE username = 'yitian'))
                                                                    )
						OR ptall.parent_id IN (SELECT child_name 
												FROM dba_wp_v5_project_closure 
												WHERE parent_name IN (
												SELECT project_name FROM dba_wp_v5_project WHERE project_manager = 'yitian' )))
                UNION
                SELECT task_id FROM dba_wp_v5_task WHERE project_name IN (
						SELECT child_name 
							FROM dba_wp_v5_project_closure 
                            WHERE parent_name IN (SELECT project_name 
															FROM dba_wp_v5_project 
                                                            WHERE project_manager = 'yitian'))
                )#) Test use
                OR
                ('worker') IN 
					(SELECT role_name 
						FROM dba_wp_v5_access_control
						WHERE username = 'yitian')
				AND
                (parent_id = '' AND (id IN (SELECT project_name FROM dba_wp_v5_user_has_project WHERE username = 'yitian')))
                OR
                (id IN
					(SELECT task_id 
						FROM dba_wp_v5_assigned
						WHERE performer = 'yitian'
				)
		)
)
				











#Dependency 
SELECT child_name AS aft_work, pre_work FROM(
	(
(SELECT *
        FROM( # From1 begin 
        (
        SELECT DISTINCT child_name  FROM dba_wp_v5_project_closure WHERE parent_name IN (
		SELECT project_name FROM dba_wp_v5_project WHERE project_manager = 'yitian'))
			AS pt LEFT JOIN dba_wp_v5_dependency d 
			ON pt.child_name = d.aft_work))
UNION
(SELECT *
        FROM( # From1 begin 
        (SELECT task_id  FROM dba_wp_v5_task WHERE project_name IN (
						SELECT child_name 
							FROM dba_wp_v5_project_closure 
                            WHERE parent_name IN (SELECT project_name 
															FROM dba_wp_v5_project 
                                                            WHERE project_manager = 'yitian')))
			AS pt LEFT JOIN dba_wp_v5_dependency d 
			ON pt.task_id = d.aft_work))
UNION
(SELECT * FROM( # From1 begin 
        (SELECT DISTINCT t.task_id
        FROM dba_wp_v5_task t JOIN dba_wp_v5_task_closure tc ON t.task_id = tc.child_id
						WHERE t.task_id IN( 
						SELECT DISTINCT tc.child_id 
						FROM dba_wp_v5_task_closure tc WHERE parent_id = child_id) AND tc.depth = 0)
			AS pt LEFT JOIN dba_wp_v5_dependency d 
			ON pt.task_id = d.aft_work))
UNION
(SELECT * FROM( # From1 begin 
        (SELECT DISTINCT	t.task_id #project_name/task_id
        FROM dba_wp_v5_task t JOIN dba_wp_v5_task_closure tc ON t.task_id = tc.child_id 
						WHERE t.task_id IN( 
						SELECT DISTINCT child_id 
						FROM dba_wp_v5_task_closure WHERE parent_id != child_id)  AND tc.depth = 1 )
			AS pt LEFT JOIN dba_wp_v5_dependency d 
			ON pt.task_id = d.aft_work
            ))
	) AS put
) 
WHERE (
		('admin' OR 'manager') IN 
		(SELECT role_name 
		 FROM dba_wp_v5_access_control
				WHERE username = 'yitian')
		AND 
		put.child_name IN (
		SELECT  pre_work
		FROM(
		((SELECT *
        FROM( # From1 begin 
        (
        SELECT DISTINCT child_name  FROM dba_wp_v5_project_closure WHERE parent_name IN (
		SELECT project_name FROM dba_wp_v5_project WHERE project_manager = 'yitian'))
			AS pt LEFT JOIN dba_wp_v5_dependency d 
			ON pt.child_name = d.aft_work))
		UNION
		(SELECT *
        FROM( # From1 begin 
        (SELECT task_id  FROM dba_wp_v5_task WHERE project_name IN (
						SELECT child_name 
							FROM dba_wp_v5_project_closure 
                            WHERE parent_name IN (SELECT project_name 
															FROM dba_wp_v5_project 
                                                            WHERE project_manager = 'yitian'))))
			AS pt LEFT JOIN dba_wp_v5_dependency d 
			ON pt.task_id = d.aft_work)) 
            AS put) 
            WHERE pre_work IS NOT NULL
            )
	OR
	put.pre_work IS NOT NULL
    AND 
    child_name IN (
					SELECT task_id FROM dba_wp_v5_task WHERE project_name IN (
						SELECT child_name 
							FROM dba_wp_v5_project_closure 
                            WHERE parent_name IN (SELECT project_name 
															FROM dba_wp_v5_project 
                                                            WHERE project_manager = 'yitian'))
                                                            )
                                                            
	  OR
	  ('worker') IN 
					(SELECT role_name 
						FROM dba_wp_v5_access_control
						WHERE username = 'yitian')
		AND
		(child_name IN (SELECT project_name FROM dba_wp_v5_user_has_project WHERE username = 'yitian'))
		OR
		(child_name IN
					(SELECT task_id 
						FROM dba_wp_v5_assigned
						WHERE performer = 'yitian'))
)
    
    
    
    


#//Query for Table 
#Format: task_id, task_name, description, begin_time_year, begin_time_month, begin_time_day, end_time_year,  
#end_time_month, end_time_day, projectname, risk, status, performer, delegator, creator. 
select	t.task_id,
		t.task_name,
        t.description,
        DATE_FORMAT(t.begin_time, '%Y') AS begin_time_year, 
		DATE_FORMAT(t.begin_time, '%m')-1 AS begin_time_month, 
		DATE_FORMAT(t.begin_time, '%d') AS begin_time_day, 
		DATE_FORMAT(t.end_time, '%Y') AS end_time_year,  
		DATE_FORMAT(t.end_time, '%m')-1 AS end_time_month, 
		DATE_FORMAT(t.end_time, '%d') AS end_time_day, 
        t.project_name,
		t.risk_name, 
        t.status,
        a.performer,
        a.delegator,
        t.creator_name
from dba_wp_v5_task t  join dba_wp_v5_assigned a on t.task_id = a.task_id 
where(
	   (
        (
			('admin' OR 'manager') IN 
					(SELECT role_name 
						FROM dba_wp_v5_access_control
						WHERE username = 'yitian')
		)
		AND 
			t.task_id IN (
                SELECT task_id FROM dba_wp_v5_task t WHERE project_name IN (
						SELECT child_name 
							FROM dba_wp_v5_project_closure 
                            WHERE parent_name IN (SELECT project_name 
															FROM dba_wp_v5_project 
                                                            WHERE project_manager = 'yitian'))
				U
                )#) Test use
		)
		OR
		(
			('worker') IN 
					(SELECT role_name 
						FROM dba_wp_v5_access_control
						WHERE username = 'yitian')
		)
				AND
                (t.task_id IN
					(SELECT task_id 
						FROM dba_wp_v5_assigned
						WHERE performer = 'yitian'
					)
				)
)
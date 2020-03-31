select * from cmddeploymentdetails
			join cmdsitelocation on (cmddd_slid = cmdslid)
			join cmdfieldsite on (cmdsl_fsid = cmdfsid)
			where cmdslfacility like 'ABOS%' and cmdddname like 'SAZ%'
			order by cmdddname
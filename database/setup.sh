#!/bin/sh

#start sql server and wait until boot up
(/opt/mssql/bin/sqlservr --accept-eula &) | grep -q "Service Broker manager has started"

#Replace with default variables
envsubst < /usr/src/setup.sql.default > /usr/src/setup.sql

#Creates the Database/Schema/User Accounts
/opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "${SA_PASSWORD}" -d master -i /usr/src/setup.sql

#wait for the database save to disk
sleep 90
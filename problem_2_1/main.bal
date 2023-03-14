import ballerina/io;
import ballerina/file;
import ballerinax/java.jdbc;
import ballerina/sql;


function addEmployee(string dbFilePath, string name, string city, string department, int age) returns int {

    string filePath = dbFilePath + ".mv.db";

    //chek if the database file exists
    do {
	    //chek if the database file exists
	    boolean exists = check file:test(filePath, file:EXISTS);

        if (exists) {
            //Create a new database connection for available database file
            jdbc:Client|sql:Error jdbcClient = new("jdbc:h2:file:" + dbFilePath, "root", "root");

            if (jdbcClient is jdbc:Client) {
               
                //insert data in to table using execute method and auto generate auto-generated `employee_id` column without issuing another query to the database use parameterized query
                sql:ParameterizedQuery sqlQuery = `INSERT INTO employee (name, city, department, age) VALUES (${name}, ${city}, ${department}, ${age})`;

                //execute the query
                sql:ExecutionResult|sql:Error result = jdbcClient->execute(sqlQuery);

                if (result is sql:Error) {
                    io:println("Error while executing the query: " + result.message());
                    return -1;
                } else {
                    //get the auto-generated `employee_id` column value
                    // The integer or string generated by the database in response to a query execution.
                    string|int? generatedKey = result.lastInsertId;

                    if (generatedKey is ()) {
                        io:println("Error while getting the auto-generated key");
                        return -1;
                    } else { 
                        return <int>generatedKey;
                    }
                }
            } else {
                io:println("Error: " + jdbcClient.message());
                return -1;
            }
        } else {
            io:println("Database file does not exist");
            return -1;
        }
    } on fail var e {
        io:println("Error: " + e.message());  
        return -1;
    }

}
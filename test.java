/**
* @author 胡荣华
* @Company 世纪龙 21cn
*/
//package com.cjdbc.test;

import java.sql.Connection;
import java.sql.Statement;
import java.sql.DriverManager;
import java.sql.ResultSet;
/**
* 
*/
public class test {

public void generate() {
Connection conn = null;
Statement pstmt = null;
try {
	Class.forName("org.objectweb.cjdbc.driver.Driver").newInstance();
	String url = "jdbc:cjdbc://192.168.110.5:25323/myDB?user=root&password=123456";

       conn = DriverManager.getConnection(url);

try{ 
conn.setAutoCommit(false);
String query="SELECT count(id) from users";
int count=0;
try {
    pstmt = conn.createStatement();
    ResultSet rs = pstmt.executeQuery(query);
    while(rs.next())
        count=rs.getInt(1);
} catch (Exception e) {
    e.printStackTrace();
} finally {
    //...
}
}
catch(Exception ex){
conn.rollback();
ex.printStackTrace();
}
finally{
try {
if( pstmt != null )
pstmt.close();
if( conn != null)
conn.close();
}
catch(Exception e) {
e.printStackTrace();
}
}
} catch (Exception e) {
e.printStackTrace();
}
}

/**
* @param args
*/
public static void main(String[] args) {
// TODO Auto-generated method stub
  test g = new test();
g.generate();

}

}

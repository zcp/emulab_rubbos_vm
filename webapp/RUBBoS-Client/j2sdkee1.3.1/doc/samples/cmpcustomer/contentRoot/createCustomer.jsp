<!--
 Copyright 2002 Sun Microsystems, Inc. All rights reserved.
 SUN PROPRIETARY/CONFIDENTIAL. Use is subject to license terms.
-->

<%@ page language="java" %>
<%@ page import="javax.naming.InitialContext" %>
<%@ page import="customer.LocalCustomer" %>
<%@ page import="customer.LocalCustomerHome" %>
<%@ page import="customer.LocalSubscription" %>
<%@ page import="customer.LocalSubscriptionHome" %>
 
<html>
<head><title>Constainer-Managed Persistence Demo</title></head>
<body bgcolor="white">
<center>
<h2>Container-Managed Persistence Demo</h2>

Create a new customer:
<p>
<form method="post" action="/customer/createCustomer.jsp">
<table border=10>
  <tr>
    <td>Customer ID: </td>
    <td><input type="text" name="id" size="11" value=""></td>
  </tr>
  <tr>
    <td>First Name: </td>
    <td><input type="text" name="firstName" size="25" value=""></td>
  </tr>
  <tr>
    <td>Last Name: </td>
    <td><input type="text" name="lastName" size="25" value=""></td>
  </tr>
</table>
<p>
<input type="submit" name="submit" value="Submit">
<p>
</form>

<%
String id = request.getParameter("id");
String firstName = request.getParameter("firstName");
String lastName = request.getParameter("lastName");

if (id != null && !"".equals(id)) {
    try {
        InitialContext ic = new InitialContext();
        Object o = ic.lookup("java:comp/env/CustomerBeanRef");
        LocalCustomerHome home = (LocalCustomerHome) o;

        LocalCustomer customer = home.create(id, firstName, lastName);
%>
New Customer: 
<a href = "/customer/editCustomer.jsp?cid=<%=id%>">
<%=customer.getLastName()%>, 
<%=customer.getFirstName()%>
</a>
created. 
</p>
<a href = "/customer/searchCustomer.jsp">SEARCH</a></p>
<%
    } catch(Exception e) {
        e.printStackTrace();
        out.println("Create new customer FAILED : " + e.toString());
    }
}
%>
<hr>
[<a href="/customer/index.html">HOME</a>]
</center>
</body>
</html>

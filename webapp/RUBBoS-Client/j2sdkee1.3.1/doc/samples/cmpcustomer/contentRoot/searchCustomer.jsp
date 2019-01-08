<!--
 Copyright 2002 Sun Microsystems, Inc. All rights reserved.
 SUN PROPRIETARY/CONFIDENTIAL. Use is subject to license terms.
-->

<%@ page language="java" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Collection" %>
<%@ page import="javax.ejb.ObjectNotFoundException" %>
<%@ page import="javax.naming.InitialContext" %>
<%@ page import="customer.LocalCustomer" %>
<%@ page import="customer.LocalCustomerHome" %>
 
<html>
<head><title>Container-Managed Persistence Demo</title></head>
<body bgcolor="white">
<center>
<h2>Container-Managed Persistence Demo</h2>

Search for a customer:
<p>
    <form method="get" action="/customer/searchCustomer.jsp">
    Search by 
    <select name="searchCriteria">
      <option value="customerID" selected>Customer ID
      <option value="lastName">Last Name
      <option value="firstName">First Name
    </select>
    <input type="text" name="searchText" size="25">
    <p>
    <input type="submit" value="Search">
    </form>

<%
String text = request.getParameter("searchText");
String criteria = request.getParameter("searchCriteria");

if (text != null && !"".equals(text)) {
    try {
        InitialContext ic = new InitialContext();
        Object o = ic.lookup("java:comp/env/CustomerBeanRef");
        LocalCustomerHome home = (LocalCustomerHome) o;

        Collection customers = new ArrayList();
        if ("customerID".equals(criteria)) {
          try {
            LocalCustomer customer = home.findByPrimaryKey(text);
            customers.add(customer);
          } catch (ObjectNotFoundException ex) {}
        }	  
        else if ("lastName".equals(criteria)) {
          customers = home.findByLastName(text);
        }
        else if ("firstName".equals(criteria)) {
          customers = home.findByFirstName(text);
        }
        else {
        }
  

%>
Results: <p>
<%
for (int i = 0; i < customers.size(); i++) {
  LocalCustomer c = (LocalCustomer)((ArrayList)customers).get(i);
  String cid = (String)c.getPrimaryKey();
%>
<a href="/customer/editCustomer.jsp?cid=<%=cid%>"> 
<%=c.getLastName()%>, <%=c.getFirstName()%></a> has
<%=c.getAddressList().size()%> addresses,
<%=c.getSubscriptionList().size()%> subscriptions.
<p>
<%
}
%>
<%
    } catch(Exception e) {
        e.printStackTrace();
        out.println(e.toString());
    }
}
%>

<hr>
[<a href="/customer/index.html">HOME</a>]
</center>
</body>
</html>

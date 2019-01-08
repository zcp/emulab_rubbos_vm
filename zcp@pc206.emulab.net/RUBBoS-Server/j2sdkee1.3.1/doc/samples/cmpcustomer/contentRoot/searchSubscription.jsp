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
<%@ page import="customer.LocalSubscription" %>
<%@ page import="customer.LocalSubscriptionHome" %>
 
<html>
<head><title>Container-Managed Persistence Demo</title></head>
<body bgcolor="white">
<center>
<h2>Container-Managed Persistence Demo</h2>

Search for a subscription by title:
<p>
    <form method="get" action="/customer/searchSubscription.jsp">
    <input type="text" name="searchText" size="25">
    <p>
    <input type="submit" value="Search">
    </form>

<%
String text = request.getParameter("searchText");

LocalSubscription subscription = null;
if (text != null && !"".equals(text)) {
    try {
        InitialContext ic = new InitialContext();
        Object o = ic.lookup("java:comp/env/SubscriptionBeanRef");
        LocalSubscriptionHome home = (LocalSubscriptionHome) o;

        try {
          subscription = home.findByPrimaryKey(text);
        } catch (ObjectNotFoundException ex) {}

%>
Results: <p>
<%
if (subscription != null) {
%>
<%=subscription.getTitle()%> [<%=subscription.getType()%>] 
<p>
People who has subscription:
<p>
<%
ArrayList customers = subscription.getCustomerList();
for (int i = 0; i < customers.size(); i++) {
  LocalCustomer customer = (LocalCustomer)customers.get(i);
%>
  <a href="/customer/editCustomer.jsp?cid=<%=customer.getCustomerID()%>">
  <%=customer.getLastName()%>, <%=customer.getFirstName()%></a>
  <p>
<%
}
if (customers.size() == 0) {
%>
NONE.
<%}%>
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

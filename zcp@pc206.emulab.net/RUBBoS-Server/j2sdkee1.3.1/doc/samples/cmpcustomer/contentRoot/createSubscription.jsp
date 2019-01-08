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
<%@ page import="customer.SubscriptionType" %>
 
<html>
<head><title>Container-Managed Persistence Demo</title></head>
<body bgcolor="white">
<center>
<h2>Container-Managed Persistence Demo</h2>

Create a new subscription:
<p>
<form method="post" action="/customer/createSubscription.jsp">
<table border=10>
  <tr>
    <td>Title: </td>
    <td><input type="text" name="title" size="20" value=""></td>
  </tr>
  <tr>
    <td>Type: </td>
    <td>
      <select name="type">
        <option><%=SubscriptionType.JOURNAL%></option>
        <option selected><%=SubscriptionType.MAGAZINE%></option>
        <option><%=SubscriptionType.NEWS_PAPER%></option>
        <option><%=SubscriptionType.OTHER%></option>
      </select>
    </td>
  </tr>
</table>
<p>
<input type="submit" name="submit" value="Submit">
<p>
</form>

<%
String title = request.getParameter("title");
String type = request.getParameter("type");

if (title != null && !"".equals(title)) {
    try {
        InitialContext ic = new InitialContext();
        Object o = ic.lookup("java:comp/env/SubscriptionBeanRef");
        LocalSubscriptionHome home = (LocalSubscriptionHome) o;

        LocalSubscription subscription = home.create(title,type);
%>
New Subscription: 
<font color="blue">
<%=subscription.getTitle()%>, 
<%=subscription.getType()%>
</font>
created.
</p>
<%
    } catch(Exception e) {
        e.printStackTrace();
        out.println("Create new subscription FAILED : " + e.toString());
    }
}
%>

<hr>
[<a href="/customer/index.html">HOME</a>]
</center>
</body>
</html>

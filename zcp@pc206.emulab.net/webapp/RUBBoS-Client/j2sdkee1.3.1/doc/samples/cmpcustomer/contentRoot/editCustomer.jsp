<!--
 Copyright 2002 Sun Microsystems, Inc. All rights reserved.
 SUN PROPRIETARY/CONFIDENTIAL. Use is subject to license terms.
-->

<%@ page language="java" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="javax.naming.InitialContext" %>
<%@ page import="customer.LocalAddress" %>
<%@ page import="customer.LocalAddressHome" %>
<%@ page import="customer.LocalCustomer" %>
<%@ page import="customer.LocalCustomerHome" %>
<%@ page import="customer.LocalSubscription" %>
<%@ page import="customer.LocalSubscriptionHome" %>
 
<html>
<head><title>Container-Managed Persistence Demo</title></head>
<body bgcolor="white">
<center>
<h2>Container-Managed Persistence Demo</h2>

<%
String cid = request.getParameter("cid");
LocalCustomer customer = null;

try {
    InitialContext ic = new InitialContext();
    Object o = ic.lookup("java:comp/env/CustomerBeanRef");
    LocalCustomerHome home = (LocalCustomerHome) o;
    customer = home.findByPrimaryKey(cid);
} catch(Exception e) {
    e.printStackTrace();
    out.println(e.toString());
}

String removeCustomer = request.getParameter("removeCustomer");
if ("Remove".equals(removeCustomer)) {
  customer.remove();
}
else {

String sub_title = request.getParameter("subscription");
String add = request.getParameter("addSubscription");
String remove = request.getParameter("removeSubscription");
if (sub_title != null && !"".equals(sub_title)) {
    try {
        if ("Add".equals(add)) {
          customer.addSubscription(sub_title);
        } 
        else if ("Remove".equals(remove)) {
          customer.removeSubscription(sub_title);
        }
        else {}
    } catch(Exception e) {
        e.printStackTrace();
        out.println(e.toString());
    }
}

String id = request.getParameter("id");
String street = request.getParameter("street");
String city = request.getParameter("city");
String zip = request.getParameter("zip");
String state = request.getParameter("state");

if (id != null && !"".equals(id)) {
    try {
        InitialContext ic = new InitialContext();
        Object o = ic.lookup("java:comp/env/AddressBeanRef");
        LocalAddressHome home = (LocalAddressHome) o;

        LocalAddress address = home.create(cid,id,street,city,zip,state);
    } catch(Exception e) {
        e.printStackTrace();
        out.println("Create new address FAILED : " + e.toString());
    }
}

ArrayList allSubscriptions = null;
try {
    InitialContext ic = new InitialContext();

    Object s = ic.lookup("java:comp/env/SubscriptionBeanRef");
    LocalSubscriptionHome sHome = (LocalSubscriptionHome) s;
    allSubscriptions = (ArrayList)sHome.findAllSubscriptions();
} catch(Exception e) {
    e.printStackTrace();
    out.println(e.toString());
}
%>

<table border=10>
  <tr>
    <td>Customer ID: </td>
    <td><%=customer.getCustomerID()%></td>
  </tr>
  <tr>
    <td>First Name: </td>
    <td><%=customer.getFirstName()%></td>
  </tr>
  <tr>
    <td>Last Name: </td>
    <td><%=customer.getLastName()%></td>
  </tr>

<%
ArrayList addresses = customer.getAddressList();
for (int i = 0; i < addresses.size(); i++) {
  LocalAddress address = (LocalAddress)addresses.get(i);
%>
<tr>
    <td>Address [<%=address.getAddressID()%>]</td>
    <td><%=address.getStreet()%></td>
</tr>
<%
}
%>
<%
ArrayList subscriptions = customer.getSubscriptionList();
for (int i = 0; i < subscriptions.size(); i++) {
  LocalSubscription subscription = (LocalSubscription)subscriptions.get(i);
%>
<tr>
    <td>Subscription [<%=subscription.getType()%>]</td>
    <td><%=subscription.getTitle()%></td>
</tr>
<%
}
%>
</table>

<p>

<form method="post" ation="/customer/editCustomer.jsp?cid=<%=cid%>">
<input type="submit" name="removeCustomer" value="Remove">
</form>

<p>

Add New Subscription:
<form method="post" action="/customer/editCustomer.jsp?cid=<%=cid%>">
<table border="2">
<%
if (allSubscriptions.size() == 0) {
%>
<tr>
    <td>Subscription</td>
    <td>None Available. [<a href="/customer/createSubscription.jsp">Create Here.</a>]</td>
</tr>
<%
} else {
%>
<tr>
<td>
<select name="subscription">
<%
  for (int i = 0; i < allSubscriptions.size(); i++) {
    LocalSubscription subscription = (LocalSubscription)allSubscriptions.get(i);
%>
    <option value="<%=subscription.getTitle()%>">
    <%=subscription.getTitle()%>[<%=subscription.getType()%>]</option>
<%
  }
%>
</select>
</td>
<td><input type="submit" name="addSubscription" value="Add"></td>
<td><input type="submit" name="removeSubscription" value="Remove"></td>
</tr>
<p>

<%
}
%>
</table>
</form>

Add an address:
<p>
<form method="post" action="/customer/editCustomer.jsp?cid=<%=cid%>">
<table border=10>
  <tr>
    <td>Address ID:</td>
    <td><input type="text" name="id" size="11" value=""></td>
  </tr>
  <tr>
    <td>Street: </td>
    <td><input type="text" name="street" size="40" value=""></td>
  </tr>
  <tr>
    <td>City: </td>
    <td><input type="text" name="city" size="25" value=""></td>
  </tr>
  <tr>
    <td>State: </td>
    <td><input type="text" name="state" size="25" value=""></td>
  </tr>
  <tr>
    <td>Zip: </td>
    <td><input type="text" name="zip" size="25" value=""></td>
  </tr>
</table>
<p>
<input type="submit" name="submit" value="Add Address">
<p>
</form>

<% } %>
<hr>
[<a href="/customer/index.html">HOME</a>]
</center>
</body>
</html>

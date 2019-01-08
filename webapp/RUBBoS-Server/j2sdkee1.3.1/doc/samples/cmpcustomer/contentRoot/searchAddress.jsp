<!--
 Copyright 2002 Sun Microsystems, Inc. All rights reserved.
 SUN PROPRIETARY/CONFIDENTIAL. Use is subject to license terms.
-->

<%@ page language="java" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Collection" %>
<%@ page import="javax.ejb.ObjectNotFoundException" %>
<%@ page import="javax.naming.InitialContext" %>
<%@ page import="customer.LocalAddress" %>
<%@ page import="customer.LocalAddressHome" %>
 
<html>
<head><title>Container-Managed Persistence Demo</title></head>
<body bgcolor="white">
<center>
<h2>Container-Managed Persistence Demo</h2>

Search for a Address by its ID:
<p>
    <form method="get" action="/customer/searchAddress.jsp">
    <input type="text" name="searchText" size="25">
    <p>
    <input type="submit" value="Search">
    </form>

<%
String text = request.getParameter("searchText");

LocalAddress address = null;
if (text != null && !"".equals(text)) {
    try {
        InitialContext ic = new InitialContext();
        Object o = ic.lookup("java:comp/env/AddressBeanRef");
        LocalAddressHome home = (LocalAddressHome) o;

        try {
          address = home.findByPrimaryKey(text);
        } catch (ObjectNotFoundException ex) {}

%>
Results: <p>
<%
if (address != null) {
%>
Address [<%=address.getAddressID()%>] : 
<%=address.getStreet()%>, <%=address.getCity()%> 
<p>
<%
} else {
%>
Address [<%=text%>] Not Found.
<%
}
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

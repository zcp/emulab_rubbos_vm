/**
 * RUBBoS: Rice University Bulletin Board System.
 * Copyright (C) 2001-2004 Rice University and French National Institute For 
 * Research In Computer Science And Control (INRIA).
 * Contact: jmob@objectweb.org
 * 
 * This library is free software; you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License as published by the
 * Free Software Foundation; either version 2.1 of the License, or any later
 * version.
 * 
 * This library is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License
 * for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public License
 * along with this library; if not, write to the Free Software Foundation,
 * Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA.
 *
 * Initial developer(s): Emmanuel Cecchet.
 * Contributor(s): Niraj Tolia.
 */

package edu.rice.rubbos.servlets;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

//ChienAn
import org.apache.log4j.Logger;

/**
 * Builds the html page with the list of all categories and provides links to
 * browse all items in a category or items in a category for a given region
 */
public class RegisterUser extends RubbosHttpServlet
{
	//ChienAn
	static Logger responseTimeLogger = Logger.getLogger(RegisterUser.class);

  public int getPoolSize()
  {
    return Config.BrowseCategoriesPoolSize;
  }

  private void closeConnection(PreparedStatement stmt, Connection conn)
  {
    try
    {
      if (stmt != null)
        stmt.close(); // close statement
    }
    catch (Exception ignore)
    {
    }

    try
    {
      if (conn != null)
          releaseRWConnection(conn);
    }
    catch (Exception ignore)
    {
    }
  }

  /** Build the html page for the response */
  public void doGet(HttpServletRequest request, HttpServletResponse response)
      throws IOException, ServletException
  {
	//ChienAn
	String            logMessage = request.getRequestURI() + "?urlID=" + request.getParameter("urlID");

    ServletPrinter    sp = null;
    PreparedStatement stmt = null;
    Connection        conn = null;

    sp = new ServletPrinter(response, "RegisterUser");

    String categoryName, nickname, firstname, lastname, email;
    String password = null, creation_date = null;
    int userId;
    int access = 0, id = 0, rating = 0;
    ResultSet rs = null;
    int updateResult;

    firstname = request.getParameter("firstname");
    lastname = request.getParameter("lastname");
    nickname = request.getParameter("nickname");
    email = request.getParameter("email");
    password = request.getParameter("password");

    if (firstname == null)
    {
      sp.printHTML("You must provide a story title!<br>");
      return;
    }

    if (lastname == null)
    {
      sp.printHTML("<h3>You must provide a story body!<br></h3>");
      return;
    }

    if (nickname == null)
    {
      sp.printHTML("<h3>You must provide a category!<br></h3>");
      return;
    }

    if (email == null)
    {
      sp.printHTML("<h3>You must provide an email address!<br></h3>");
      return;
    }

    if (password == null)
    {
      sp.printHTML("<h3>You must provide a password!<br></h3>");
      return;
    }

    conn = getRWConnection();

    //Authenticate the user

    try
    {
      // Yasu: for PostgreSQL
      // stmt = conn.prepareStatement("SELECT * FROM users WHERE nickname=\""
      //     + nickname + "\"",
      stmt = conn.prepareStatement("SELECT * FROM users WHERE nickname='"
//ChienAn          + nickname + "'",
          + nickname + "'" + " /* urlID=" + request.getParameter("urlID") + " */",
            // Yasu: FORWARD_ONLY ResultSet doesn't support first() method.
	    ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_READ_ONLY);

	//ChienAn
	long startNano = System.nanoTime();

      rs = stmt.executeQuery();

	//ChienAn
	long endNano = System.nanoTime();
        long responseTime = (endNano - startNano)/1000;
        logMessage += " DBST(nano)=" + startNano + " DBET(nano)=" + endNano + " DBRT(us)=" + responseTime;
    }
    catch (Exception e)
    {
      sp.printHTML("ERROR: Nickname query failed" + e);
      closeConnection(stmt, conn);

	//ChienAn
	if (responseTimeLogger.isInfoEnabled())
                responseTimeLogger.info(logMessage);

      return;
    }
    try
    {
      if (rs.first())
      {
        sp
            .printHTML("The nickname you have chosen is already taken by someone else. Please choose a new nickname.<br>\n");
        closeConnection(stmt, conn);
        return;
      }
      // Yasu: for PostgreSQL
      // stmt = conn.prepareStatement("INSERT INTO users VALUES (NULL, \""
      //     + firstname + "\", \"" + lastname + "\", \"" + nickname + "\", \""
      //     + password + "\", \"" + email + "\", 0, 0, NOW())");
      stmt = conn.prepareStatement("INSERT INTO users (firstname, lastname,"
          + " nickname, password, email, rating, access, creation_date) VALUES ('"
          + firstname + "', '" + lastname + "', '" + nickname + "', '"
//ChienAn          + password + "', '" + email + "', 0, 0, NOW())");
          + password + "', '" + email + "', 0, 0, NOW())" + " /* urlID=" + request.getParameter("urlID") + " */");

	//ChienAn
	long startNano = System.nanoTime();
	
      updateResult = stmt.executeUpdate();

	//ChienAn
	long endNano = System.nanoTime();
	long responseTime = (endNano - startNano)/1000;
	logMessage += " DBST(nano)=" + startNano + " DBET(nano)=" + endNano + " DBRT(us)=" + responseTime;

      stmt.close();

      // Yasu: for PostgreSQL
      // stmt = conn.prepareStatement("SELECT * FROM users WHERE nickname=\""
      //     + nickname + "\"",
      stmt = conn.prepareStatement("SELECT * FROM users WHERE nickname='"
//ChienAn          + nickname + "'",
          + nickname + "'" + " /* urlID=" + request.getParameter("urlID") + " */",
            // Yasu: FORWARD_ONLY ResultSet doesn't support first() method.
	    ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_READ_ONLY);

	//ChienAn
	startNano = System.nanoTime();	

      rs = stmt.executeQuery();

	//ChienAn
	endNano = System.nanoTime();
        responseTime = (endNano - startNano)/1000;
        logMessage += " DBST(nano)=" + startNano + " DBET(nano)=" + endNano + " DBRT(us)=" + responseTime;

      rs.first();
      id = rs.getInt("id");
      creation_date = rs.getString("creation_date");
      rating = rs.getInt("rating");
      access = rs.getInt("access");

    }
    catch (Exception e)
    {
      sp.printHTML("Exception registering user " + e + "<br>");
      closeConnection(stmt, conn);

	//ChienAn
	if (responseTimeLogger.isInfoEnabled())
                responseTimeLogger.info(logMessage);

      return;
    }

    closeConnection(stmt, conn);

    sp
        .printHTML("<h2>Your registration has been processed successfully</h2><br>\n");
    sp.printHTML("<h3>Welcome " + nickname + "</h3>\n");
    sp
        .printHTML("RUBBoS has stored the following information about you:<br>\n");
    sp.printHTML("First Name : " + firstname + "<br>\n");
    sp.printHTML("Last Name  : " + lastname + "<br>\n");
    sp.printHTML("Nick Name  : " + nickname + "<br>\n");
    sp.printHTML("Email      : " + email + "<br>\n");
    sp.printHTML("Password   : " + password + "<br>\n");
    sp
        .printHTML("<br>The following information has been automatically generated by RUBBoS:<br>\n");
    sp.printHTML("User id       :" + id + "<br>\n");
    sp.printHTML("Creation date :" + creation_date + "<br>\n");
    sp.printHTML("Rating        :" + rating + "<br>\n");
    sp.printHTML("Access        :" + access + "<br>\n");

    sp.printHTMLfooter();

	//ChienAn
	if (responseTimeLogger.isInfoEnabled())
                responseTimeLogger.info(logMessage);
  }

  public void doPost(HttpServletRequest request, HttpServletResponse response)
      throws IOException, ServletException
  {
    doGet(request, response);
  }

}

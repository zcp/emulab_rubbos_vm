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

public class StoreModeratorLog extends RubbosHttpServlet
{
	//ChienAn
	static Logger responseTimeLogger = Logger.getLogger(StoreModeratorLog.class);

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

    String nickname, password, comment_table, commentId, ratingstring;
    int access = 0, userId = 0, rating;
    ResultSet rs = null;

    int updateResult;

    sp = new ServletPrinter(response, "StoreModeratorLog");

    nickname = request.getParameter("nickname");
    password = request.getParameter("password");

    comment_table = request.getParameter("comment_table");
    commentId = request.getParameter("commentId");
    ratingstring = request.getParameter("rating");

    if (nickname == null)
    {
      sp.printHTML("Author, You must provide a nick name!<br>");
      return;
    }

    if (password == null)
    {
      sp.printHTML("Author, You must provide a password!<br>");
      return;
    }

    if (comment_table == null)
    {
      sp.printHTML("Moderating comment, You must provide a comment table!<br>");
      return;
    }

    if (commentId == null)
    {
      sp
          .printHTML("Moderating comment, You must provide a comment identifier!<br>");
      return;
    }

    if (ratingstring == null)
    {
      sp.printHTML("Moderating comment, You must provide a rating!<br>");
      return;
    }
    else
      rating = (Integer.valueOf(request.getParameter("rating"))).intValue();

    conn = getRWConnection();

    if ((nickname != null) && (password != null))
    {
      try
      {
        stmt = conn
            // Yasu: for PostgreSQL
            // .prepareStatement("SELECT id,access FROM users WHERE nickname=\""
            //     + nickname + "\" AND password=\"" + password + "\"",
            .prepareStatement("SELECT id,access FROM users WHERE nickname='"
//ChienAn                + nickname + "' AND password='" + password + "'",
                + nickname + "' AND password='" + password + "'" + " /* urlID=" + request.getParameter("urlID") + " */",
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
        sp.printHTML("Failed to execute Query for BrowseStoriesByCategory: "
            + e);
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
          userId = rs.getInt("id");
          access = rs.getInt("access");
        }
        stmt.close();
      }
      catch (Exception e)
      {
        sp.printHTML("Exception StoreModeratorLog: " + e + "<br>");
        closeConnection(stmt, conn);

	//ChienAn
	if (responseTimeLogger.isInfoEnabled())
                responseTimeLogger.info(logMessage);
        return;
      }
    }

    if ((userId == 0) || (access == 0))
    {
      sp.printHTMLheader("RUBBoS: Moderation");
      sp
          .printHTML("<p><center><h2>Sorry, but this feature is only accessible by users with an author access.</h2></center><p>\n");
    }
    else
    {
      sp.printHTMLheader("RUBBoS: Comment moderation result");
      sp.printHTML("<center><h2>Comment moderation result:</h2></center><p>\n");

      try
      {
        stmt = conn.prepareStatement("SELECT writer,rating FROM "
//ChienAn            + comment_table + " WHERE id=" + commentId,
            + comment_table + " WHERE id=" + commentId + " /* urlID=" + request.getParameter("urlID") + " */",
            // Yasu: FORWARD_ONLY ResultSet doesn't support first() method.
	    ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_READ_ONLY);

	//ChienAn	
	long startNano = System.nanoTime();

        rs = stmt.executeQuery();

	//ChienAn
	long endNano = System.nanoTime();
        long responseTime = (endNano - startNano)/1000;
        logMessage += " DBST(nano)=" + startNano + " DBET(nano)=" + endNano + " DBRT(us)=" + responseTime;

        if (!rs.first())
        {
          sp
              .printHTML("<h3>ERROR: Sorry, but this comment does not exist.</h3><br>\n");
        }
        int rsrating = rs.getInt("rating");
        String writer = rs.getString("writer");

        stmt.close();

        if (((rsrating == -1) && (rating == -1))
            || ((rsrating == 5) && (rating == 1)))
          sp
              .printHTML("Comment rating is already to its maximum, updating only user's rating.");
        else
        {
          // Update ratings
          if (rating != 0)
          {
            stmt = conn.prepareStatement("UPDATE users SET rating=rating+"
//ChienAn                + rating + " WHERE id=" + writer);
                + rating + " WHERE id=" + writer + " /* urlID=" + request.getParameter("urlID") + " */");

		//ChienAn
		startNano = System.nanoTime();

            updateResult = stmt.executeUpdate();

		//ChienAn
		endNano = System.nanoTime();
	        responseTime = (endNano - startNano)/1000;
        	logMessage += " DBST(nano)=" + startNano + " DBET(nano)=" + endNano + " DBRT(us)=" + responseTime;

            stmt.close();

            stmt = conn.prepareStatement("UPDATE " + comment_table
//ChienAn                + " SET rating=rating+" + rating + " WHERE id=" + commentId);
                + " SET rating=rating+" + rating + " WHERE id=" + commentId + " /* urlID=" + request.getParameter("urlID") + " */");

		//ChienAn
		startNano = System.nanoTime();

            updateResult = stmt.executeUpdate();

		//ChienAn
		endNano = System.nanoTime();
		responseTime = (endNano - startNano)/1000;
		logMessage += " DBST(nano)=" + startNano + " DBET(nano)=" + endNano + " DBRT(us)=" + responseTime;

            stmt.close();
          }
        }

        stmt = conn.prepareStatement("SELECT rating FROM " + comment_table
//ChienAn            + " WHERE id=" + commentId,
            + " WHERE id=" + commentId + " /* urlID=" + request.getParameter("urlID") + " */",
            // Yasu: FORWARD_ONLY ResultSet doesn't support first() method.
	    ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_READ_ONLY);

	//ChienAn
	startNano = System.nanoTime();	

        rs = stmt.executeQuery();

	//ChienAn
	endNano = System.nanoTime();
        responseTime = (endNano - startNano)/1000;
        logMessage += " DBST(nano)=" + startNano + " DBET(nano)=" + endNano + " DBRT(us)=" + responseTime;	

        String user_row_rating = null, comment_row_rating = null;

        if (rs.first())
          comment_row_rating = rs.getString("rating");
        stmt.close();

        stmt = conn.prepareStatement("SELECT rating FROM users WHERE id="
//ChienAn            + writer,
            + writer + " /* urlID=" + request.getParameter("urlID") + " */",
            // Yasu: FORWARD_ONLY ResultSet doesn't support first() method.
	    ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_READ_ONLY);
	
	//ChienAn
	startNano = System.nanoTime();

        rs = stmt.executeQuery();

	//ChienAn
	endNano = System.nanoTime();
        responseTime = (endNano - startNano)/1000;
        logMessage += " DBST(nano)=" + startNano + " DBET(nano)=" + endNano + " DBRT(us)=" + responseTime;

        if (rs.first())
          user_row_rating = rs.getString("rating");

        if (!rs.first())
          sp
              .printHTML("<h3>ERROR: Sorry, but this user does not exist.</h3><br>\n");
        stmt.close();

        // Update moderator log
        // for PostgreSQL
        // stmt = conn
        //     .prepareStatement("INSERT INTO moderator_log VALUES (NULL, "
        //         + userId + ", " + commentId + ", " + rating + ", NOW())");
        stmt = conn
            .prepareStatement("INSERT INTO moderator_log"
                + " (moderator_id, comment_id, rating, date) VALUES ("
//ChienAn                + userId + ", " + commentId + ", " + rating + ", NOW())");
                + userId + ", " + commentId + ", " + rating + ", NOW())" + " /* urlID=" + request.getParameter("urlID") + " */");

	//ChienAn
	startNano = System.nanoTime();

        updateResult = stmt.executeUpdate();

	//ChienAn
	endNano = System.nanoTime();
        responseTime = (endNano - startNano)/1000;
        logMessage += " DBST(nano)=" + startNano + " DBET(nano)=" + endNano + " DBRT(us)=" + responseTime;

        sp.printHTML("New comment rating is :" + comment_row_rating + "<br>\n");
        sp.printHTML("New user rating is :" + user_row_rating + "<br>\n");
        sp
            .printHTML("<center><h2>Your moderation has been successfully stored.</h2></center>\n");

      }
      catch (Exception e3)
      {
        sp.printHTML("Exception StoreModeratorLog stmts: " + e3 + "<br>");
      }

    }
    closeConnection(stmt, conn);

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

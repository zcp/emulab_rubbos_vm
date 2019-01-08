package edu.rice.rubbos.servlets;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.log4j.BasicConfigurator;
import org.apache.log4j.Logger;
import org.apache.log4j.PropertyConfigurator;

public class Log4jInit extends RubbosHttpServlet {

	public void init() throws ServletException {
		String prefix = getServletContext().getRealPath("/");
    		String file = getInitParameter("log4j-init-file");
    		if(file!=null){
      			PropertyConfigurator.configure(prefix+file);
    		}
    		System.out.println("Log4j initialized suc!");
	}

  public int getPoolSize()
  {
    return Config.BrowseCategoriesPoolSize;
  }
	
	public void doGet(HttpServletRequest request, HttpServletResponse response){
        	{}
    	}

	//Clean up resources
	public void destroy() {
    	}
}

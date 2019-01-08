/*
 * Copyright 2002 Sun Microsystems, Inc. All rights reserved.
 * SUN PROPRIETARY/CONFIDENTIAL. Use is subject to license terms.
 */

package customer;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Iterator;

import javax.ejb.CreateException;
import javax.ejb.EntityBean;
import javax.ejb.EntityContext;
import javax.naming.Context;
import javax.naming.InitialContext;

import util.Log;

/**
 *
 * @author	Qingqing Ouyang
 * @version
 * @see        
 * @since
 */
public abstract class SubscriptionBean implements EntityBean {

    private EntityContext context;

    //access methods for cmp fields

    public abstract String getTitle();      //primary key
    public abstract void setTitle(String title);
    
    public abstract SubscriptionType getType();
    public abstract void setType(SubscriptionType type);

    //access methods for cmr fields
    public abstract Collection getCustomers();
    public abstract void setCustomers(Collection customers); 

    //business methods
    public ArrayList getCustomerList() {
        ArrayList list = new ArrayList();
        Iterator c = getCustomers().iterator();
        while (c.hasNext()) {
            list.add((LocalCustomer)c.next());
        }
        return list;
    }

    public String ejbCreate (
            String title,
            String type)
        throws CreateException {
        //Log.trace("SubscriptionBean.ejbCreate...");

        if (type.equals(SubscriptionType.MAGAZINE.getType())) {
            ejbCreate(title,SubscriptionType.MAGAZINE);
        } 
        else if (type.equals(SubscriptionType.JOURNAL.getType())) {
            ejbCreate(title,SubscriptionType.JOURNAL);
        } 
        else if (type.equals(SubscriptionType.NEWS_PAPER.getType())) {
            ejbCreate(title,SubscriptionType.NEWS_PAPER);
        }
        else
            ejbCreate(title,SubscriptionType.OTHER);

        return title;
    }

    public String ejbCreate (
            String title,
            SubscriptionType type)
        throws CreateException {
        //Log.trace("SubscriptionBean.ejbCreate...");

        setTitle(title);
        setType(type);
        return title;
    }

    // other EntityBean methods

    public void ejbPostCreate (
            String title,
            SubscriptionType type)
        throws CreateException {
        Log.trace("SubscriptionBean.ejbPostCreate()..." +
                title + " [" + type + "] created");
    }

    public void ejbPostCreate (
            String title,
            String type)
        throws CreateException {
        //Log.trace("SubscriptionBean.ejbPostCreate...");
    }

    public void setEntityContext(EntityContext ctx) {
        //Log.trace("SubscriptionBean.setEntityContext...");
        context = ctx;
    }
    
    public void unsetEntityContext() {
        //Log.trace("SubscriptionBean.unsetEntityContext...");
        context = null;
    }
    
    public void ejbRemove() {
        Log.trace("SubscriptionBean.ejbRemove()..." +
                getTitle() + " [" + getType().toString() + "] removed");
    }
    
    public void ejbLoad() {
        //Log.trace("SubscriptionBean.ejbLoad...");
    }
    
    public void ejbStore() {
        //Log.trace("SubscriptionBean.ejbStore...");
    }
    
    public void ejbPassivate() {
        //Log.trace("SubscriptionBean.ejbPassivate...");
    }
    
    public void ejbActivate() {
        //Log.trace("SubscriptionBean.ejbActivate...");
    }
}

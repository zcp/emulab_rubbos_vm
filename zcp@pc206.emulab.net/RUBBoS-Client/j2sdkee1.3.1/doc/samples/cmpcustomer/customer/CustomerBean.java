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
public abstract class CustomerBean implements EntityBean {

    private EntityContext context;

    //access methods for cmp fields

    public abstract String getCustomerID();      //primary key
    public abstract void setCustomerID(String id);
    
    public abstract String getFirstName();
    public abstract void setFirstName(String firstName);

    public abstract String getLastName();
    public abstract void setLastName(String lastName);


    //access methods for cmr fields
    public abstract Collection getAddresses();
    public abstract void setAddresses (Collection addresses);

    public abstract Collection getSubscriptions();
    public abstract void setSubscriptions (Collection subscriptions);

    //business methods
    public ArrayList getAddressList() {
        ArrayList list = new ArrayList();
        Iterator c = getAddresses().iterator();
        while (c.hasNext()) {
            list.add((LocalAddress)c.next());
        }
        return list;
    }

    public ArrayList getSubscriptionList() {
        ArrayList list = new ArrayList();
        Iterator c = getSubscriptions().iterator();
        while (c.hasNext()) {
            list.add((LocalSubscription)c.next());
        }
        return list;
    }

    public void addAddress (LocalAddress address) {
        getAddresses().add(address);
    }

    public void addSubscription (String subscriptionKey) {
        try {
            Context ic = new InitialContext();
            LocalSubscriptionHome home = (LocalSubscriptionHome)
                ic.lookup("java:comp/env/ejb/SubscriptionRef");
            LocalSubscription subscription = 
                home.findByPrimaryKey(subscriptionKey);
            addSubscription(subscription);

        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }

    public void addSubscription (LocalSubscription subscription) {
        getSubscriptions().add(subscription);
    }

    public void removeSubscription (String subscriptionKey) {
        try {
            Context ic = new InitialContext();
            LocalSubscriptionHome home = (LocalSubscriptionHome)
                ic.lookup("java:comp/env/ejb/SubscriptionRef");
            LocalSubscription subscription = 
                home.findByPrimaryKey(subscriptionKey);

            getSubscriptions().remove(subscription);

        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }

    public String ejbCreate (
            String id,
            String firstName,
            String lastName) 
        throws CreateException {
        //Log.trace("CustomerBean.ejbCreate...");
        return create(id, firstName, lastName);
    }

    private String create(
            String id,
            String firstName,
            String lastName)
        throws CreateException {
        
        setCustomerID(id);
        setFirstName(firstName);
        setLastName(lastName);

        return id;
    }

    // other EntityBean methods
    
    public void ejbPostCreate (
            String id,
            String firstName,
            String lastName)
        throws CreateException {
        Log.trace("CustomerBean.ejbPostCreate(" + 
                id + ", " + firstName + ", " + lastName + ")...");
    }

    public void setEntityContext(EntityContext ctx) {
        //Log.trace("CustomerBean.setEntityContext...");
        context = ctx;
    }
    
    public void unsetEntityContext() {
        //Log.trace("CustomerBean.unsetEntityContext...");
        context = null;
    }
    
    public void ejbRemove() {
        Log.trace("CustomerBean.ejbRemove... [" +
                getLastName() + ", " + getFirstName() + "]");
    }
    
    public void ejbLoad() {
        //Log.trace("CustomerBean.ejbLoad...");
    }
    
    public void ejbStore() {
        //Log.trace("CustomerBean.ejbStore...");
    }
    
    public void ejbPassivate() {
        //Log.trace("CustomerBean.ejbPassivate...");
    }
    
    public void ejbActivate() {
        //Log.trace("CustomerBean.ejbActivate...");
    }

}

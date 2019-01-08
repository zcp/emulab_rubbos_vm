/*
 * Copyright 2002 Sun Microsystems, Inc. All rights reserved.
 * SUN PROPRIETARY/CONFIDENTIAL. Use is subject to license terms.
 */

package customer;

import java.util.Collection;
import java.util.Vector;

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
public abstract class AddressBean implements EntityBean {

    private EntityContext context;

    //access methods for cmp fields

    public abstract String getAddressID();      //primary key
    public abstract void setAddressID(String id);
    
    public abstract String getStreet();
    public abstract void setStreet(String street);

    public abstract String getCity();
    public abstract void setCity(String city);

    public abstract String getZip();
    public abstract void setZip(String zip);

    public abstract String getState();
    public abstract void setState(String state);

    public String ejbCreate (
            String cid,
            String id,
            String street,
            String city,
            String zip,
            String state)
        throws CreateException {
        //Log.trace("AddressBean.ejbCreate...");
        return create (id, street, city, zip, state);
    }

    private String create(
            String id,
            String street,
            String city,
            String zip,
            String state)
        throws CreateException {

        setAddressID(id);
        setStreet(street);
        setCity(city);
        setZip(zip);
        setState(state);

        return id;
    }

    // other EntityBean methods

    public void ejbPostCreate (
            String cid,
            String id,
            String street,
            String city,
            String zip,
            String state)
        throws CreateException {
        //Log.trace("AddressBean.ejbPostCreate...");
        postCreate(cid);
    }

    private void postCreate (String cid) {
        //Log.trace("AddressBean.postCreate...");
        try {
            Context ic = new InitialContext();
            LocalCustomerHome home = (LocalCustomerHome)
                ic.lookup("java:comp/env/ejb/CustomerRef");
            LocalCustomer customer = home.findByPrimaryKey(cid);
            customer.addAddress((LocalAddress)context.getEJBLocalObject());
        } catch (Exception ex) {
            context.setRollbackOnly();
            ex.printStackTrace();
        }
    }
        
    public void setEntityContext(EntityContext ctx) {
        //Log.trace("AddressBean.setEntityContext...");
        context = ctx;
    }
    
    public void unsetEntityContext() {
        //Log.trace("AddressBean.unsetEntityContext...");
        context = null;
    }
    
    public void ejbRemove() {
        Log.trace("AddressBean.ejbRemove...  addressID = " + getAddressID());
    }
    
    public void ejbLoad() {
        //Log.trace("AddressBean.ejbLoad...");
    }
    
    public void ejbStore() {
        //Log.trace("AddressBean.ejbStore...");
    }
    
    public void ejbPassivate() {
        //Log.trace("AddressBean.ejbPassivate...");
    }
    
    public void ejbActivate() {
        //Log.trace("AddressBean.ejbActivate...");
    }
}

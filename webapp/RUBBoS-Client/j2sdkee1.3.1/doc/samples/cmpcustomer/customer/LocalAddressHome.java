/*
 * Copyright 2002 Sun Microsystems, Inc. All rights reserved.
 * SUN PROPRIETARY/CONFIDENTIAL. Use is subject to license terms.
 */

package customer;

import javax.ejb.CreateException;
import javax.ejb.EJBLocalHome;
import javax.ejb.FinderException;

/**
 *
 * @author	Qingqing Ouyang
 */
public interface LocalAddressHome extends EJBLocalHome {

    public LocalAddress create (
            String customerID,
            String addressID,
            String street, 
            String city, 
            String zip, 
            String state)
        throws CreateException;

    public LocalAddress findByPrimaryKey(String addressID)
        throws FinderException;
}

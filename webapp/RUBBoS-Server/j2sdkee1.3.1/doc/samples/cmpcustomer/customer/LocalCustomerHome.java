/*
 * Copyright 2002 Sun Microsystems, Inc. All rights reserved.
 * SUN PROPRIETARY/CONFIDENTIAL. Use is subject to license terms.
 */

package customer;

import java.util.Collection;
import javax.ejb.CreateException;
import javax.ejb.EJBLocalHome;
import javax.ejb.FinderException;

/**
 *
 * @author	Qingqing Ouyang
 */
public interface LocalCustomerHome extends EJBLocalHome {
    
    public LocalCustomer create (
            String customerID,
            String firstName,
            String lastName
    )
        throws CreateException;
    
    public Collection findByLastName (String lastName)
        throws FinderException;

    public Collection findByFirstName (String firstName)
        throws FinderException;
    
    public LocalCustomer findByPrimaryKey (String customerID)
        throws FinderException;
    
}

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
public interface LocalSubscriptionHome extends EJBLocalHome {

    public LocalSubscription create (
            String title,
            String type)
        throws CreateException;

    public LocalSubscription create (
            String title,
            SubscriptionType type)
        throws CreateException;
    
    public Collection findAllSubscriptions ()
        throws FinderException;

    public LocalSubscription findByPrimaryKey(String title)
        throws FinderException;
}

/*
 * Copyright 2002 Sun Microsystems, Inc. All rights reserved.
 * SUN PROPRIETARY/CONFIDENTIAL. Use is subject to license terms.
 */

package customer;

import java.util.ArrayList;
import javax.ejb.EJBLocalObject;

/**
 *
 * @author	Qingqing Ouyang
 */
public interface LocalCustomer extends EJBLocalObject {

    public String getCustomerID();
    public String getFirstName();
    public String getLastName();
    public ArrayList getAddressList();
    public ArrayList getSubscriptionList();

    public void addAddress (LocalAddress address);
    public void addSubscription (LocalSubscription subscription);
    public void addSubscription (String subscriptionKey);

    public void removeSubscription(String subscriptionKey);
}
